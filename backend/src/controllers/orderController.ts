import { Response } from 'express';
import { z } from 'zod';
import { prisma } from '../utils/prisma';
import { AuthenticatedRequest } from '../middleware/auth';

const createOrderSchema = z.object({
  addressId: z.string().trim().min(1, 'addressId is required'),
  deliveryMethod: z.string().trim().optional(),
  deliveryMethodLabel: z.string().trim().optional(),
  deliveryMethodPrice: z.coerce.number().int().optional(),
  paymentMethod: z.string().trim().min(1, 'paymentMethod is required'),
});

function generateOrderNumber(): string {
  const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  let code = '';
  for (let i = 0; i < 6; i++) {
    code += chars.charAt(Math.floor(Math.random() * chars.length));
  }
  return `NL${code}`;
}

export const createOrder = async (req: AuthenticatedRequest, res: Response): Promise<void> => {
  try {
    const userId = req.userId;
    if (!userId) {
      res.status(401).json({ message: 'User authentication required' });
      return;
    }

    const parseResult = createOrderSchema.safeParse(req.body);
    if (!parseResult.success) {
      res.status(400).json({
        message: 'Invalid request payload',
        errors: parseResult.error.flatten().fieldErrors,
      });
      return;
    }

    const { addressId, paymentMethod } = parseResult.data;
    const rawDeliveryMethod = (req.body.deliveryMethod || req.body.deliveryMethodLabel || '').toLowerCase().trim();

    // Wrap the entire order creation in a Prisma transaction
    const result = await prisma.$transaction(async (tx) => {
      // a. Fetch current user's cart with items
      const cart = await tx.cart.findUnique({
        where: { userId },
        include: {
          items: {
            include: {
              product: {
                include: {
                  images: { orderBy: { sortOrder: 'asc' } },
                  sizes: true,
                },
              },
            },
          },
        },
      });

      // b. If cart is empty, return 400
      if (!cart || cart.items.length === 0) {
        return { status: 400, body: { message: "Can't place an empty order" } };
      }

      // c. Fetch the specified Address (verify it belongs to current user)
      const address = await tx.address.findFirst({
        where: { id: addressId, userId },
      });

      if (!address) {
        return { status: 404, body: { message: 'Address not found or does not belong to user' } };
      }

      // d. Server-side StoreSettings lookup & deliveryMethod validation
      let settings = await tx.storeSettings.findFirst();
      if (!settings) {
        settings = await tx.storeSettings.create({
          data: {
            standardDeliveryLabel: 'Standard Delivery',
            standardDeliveryDays: '3-5 days',
            standardDeliveryPrice: 150,
            expressDeliveryLabel: 'Express Delivery',
            expressDeliveryDays: '1-2 days',
            expressDeliveryPrice: 300,
            taxRatePercent: 0,
          },
        });
      }

      let shippingCost = 0;
      let deliveryMethodLabel = '';

      if (rawDeliveryMethod === 'standard' || rawDeliveryMethod.includes('standard')) {
        shippingCost = settings.standardDeliveryPrice;
        deliveryMethodLabel = settings.standardDeliveryLabel;
      } else if (rawDeliveryMethod === 'express' || rawDeliveryMethod.includes('express')) {
        shippingCost = settings.expressDeliveryPrice;
        deliveryMethodLabel = settings.expressDeliveryLabel;
      } else {
        return {
          status: 400,
          body: {
            message: `Invalid deliveryMethod '${req.body.deliveryMethod || req.body.deliveryMethodLabel}'. Allowed values: 'standard', 'express'`,
          },
        };
      }

      // e. Stock verification for EACH cart item
      for (const item of cart.items) {
        const targetSize = item.product.sizes.find(
          (s) => s.label.toLowerCase() === item.sizeLabel.toLowerCase()
        );

        if (!targetSize || targetSize.stock < item.quantity) {
          const availableStock = targetSize ? targetSize.stock : 0;
          return {
            status: 409,
            body: {
              message: `Insufficient stock for product '${item.product.name}' (Size: ${item.sizeLabel}). Available stock: ${availableStock}, requested: ${item.quantity}`,
              productId: item.productId,
              productName: item.product.name,
              sizeLabel: item.sizeLabel,
              requestedQuantity: item.quantity,
              availableStock,
            },
          };
        }
      }

      // f. Deduct ordered quantity from ProductSize.stock for each line item
      for (const item of cart.items) {
        const targetSize = item.product.sizes.find(
          (s) => s.label.toLowerCase() === item.sizeLabel.toLowerCase()
        )!;

        await tx.productSize.update({
          where: { id: targetSize.id },
          data: { stock: { decrement: item.quantity } },
        });
      }

      // g. Calculate subtotal using current product prices
      let subtotal = 0;
      const preparedItems = cart.items.map((item) => {
        const product = item.product;
        const price = Math.round(Number(product.price));
        const discountPrice = product.discountPrice !== null ? Math.round(Number(product.discountPrice)) : null;
        const unitPrice = (discountPrice !== null && discountPrice < price) ? discountPrice : price;
        const lineTotal = unitPrice * item.quantity;

        subtotal += lineTotal;

        const thumbnailUrl = product.images.length > 0 ? product.images[0].url : '';

        return {
          productId: product.id,
          productName: product.name,
          productThumbnailUrl: thumbnailUrl,
          colorName: item.colorName,
          sizeLabel: item.sizeLabel,
          quantity: item.quantity,
          unitPrice,
          lineTotal,
        };
      });

      // Server-side Tax calculation based on StoreSettings.taxRatePercent
      const taxRate = settings.taxRatePercent || 0;
      const tax = Math.round(subtotal * (taxRate / 100));
      const total = subtotal + shippingCost + tax;

      // Generate unique order number
      let orderNumber = generateOrderNumber();
      let isUnique = false;
      while (!isUnique) {
        const existing = await tx.order.findUnique({ where: { orderNumber } });
        if (!existing) {
          isUnique = true;
        } else {
          orderNumber = generateOrderNumber();
        }
      }

      // h. Create Order row with snapshot fields
      const order = await tx.order.create({
        data: {
          userId,
          orderNumber,
          status: 'PENDING',
          subtotal,
          shippingCost,
          tax,
          total,
          deliveryMethodLabel,
          shippingFullName: address.fullName,
          shippingPhone: address.phone,
          shippingAddressLine1: address.addressLine1,
          shippingAddressLine2: address.addressLine2,
          shippingCity: address.city,
          shippingRegion: address.region,
          shippingCountry: address.country,
          paymentMethod,
          items: {
            create: preparedItems,
          },
          statusHistory: {
            create: {
              status: 'PENDING',
            },
          },
        },
        include: {
          items: true,
          statusHistory: true,
        },
      });

      // i. Clear user's cart items
      await tx.cartItem.deleteMany({
        where: { cartId: cart.id },
      });

      // j. Create auto-notification for order placement
      await tx.notification.create({
        data: {
          userId,
          type: 'ORDER_UPDATE',
          title: 'Order Placed',
          body: `Your order #${orderNumber} has been confirmed`,
          relatedOrderId: order.id,
        },
      });

      return { status: 201, body: order };
    });

    res.status(result.status).json(result.body);
  } catch (error) {
    console.error('Error in createOrder:', error);
    res.status(500).json({ message: 'Failed to create order' });
  }
};

export const getOrders = async (req: AuthenticatedRequest, res: Response): Promise<void> => {
  try {
    const userId = req.userId;
    if (!userId) {
      res.status(401).json({ message: 'User authentication required' });
      return;
    }

    const orders = await prisma.order.findMany({
      where: { userId },
      orderBy: { createdAt: 'desc' },
      include: {
        items: true,
      },
    });

    const formattedOrders = orders.map((order) => {
      const itemCount = order.items.reduce((sum, item) => sum + item.quantity, 0);
      const thumbnailUrl = order.items.length > 0 ? order.items[0].productThumbnailUrl : null;

      return {
        id: order.id,
        orderNumber: order.orderNumber,
        status: order.status,
        total: order.total,
        itemCount,
        createdAt: order.createdAt,
        thumbnailUrl,
      };
    });

    res.status(200).json(formattedOrders);
  } catch (error) {
    console.error('Error in getOrders:', error);
    res.status(500).json({ message: 'Failed to fetch orders' });
  }
};

export const getOrderById = async (req: AuthenticatedRequest, res: Response): Promise<void> => {
  try {
    const userId = req.userId;
    const orderId = req.params.id as string;

    if (!userId) {
      res.status(401).json({ message: 'User authentication required' });
      return;
    }

    const order = await prisma.order.findFirst({
      where: {
        id: orderId,
        userId,
      },
      include: {
        items: true,
        statusHistory: {
          orderBy: { createdAt: 'asc' },
        },
      },
    });

    if (!order) {
      res.status(404).json({ message: 'Order not found' });
      return;
    }

    res.status(200).json(order);
  } catch (error) {
    console.error('Error in getOrderById:', error);
    res.status(500).json({ message: 'Failed to fetch order details' });
  }
};
