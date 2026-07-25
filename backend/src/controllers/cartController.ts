import { Response } from 'express';
import { PrismaClient } from '@prisma/client';
import { z } from 'zod';
import { AuthenticatedRequest } from '../middleware/auth';

const prisma = new PrismaClient();

const addItemSchema = z.object({
  productId: z.string().trim().min(1, 'productId is required'),
  colorName: z.string().trim().min(1, 'colorName is required'),
  sizeLabel: z.string().trim().min(1, 'sizeLabel is required'),
  quantity: z.number().int().min(1, 'quantity must be at least 1').max(10, 'quantity cannot exceed 10'),
});

const updateItemSchema = z.object({
  quantity: z.number().int().min(0, 'quantity must be greater than or equal to 0').max(10, 'quantity cannot exceed 10'),
});

/// Helper function to build full cart response shape
export async function getFormattedCart(userId: string) {
  const cart = await prisma.cart.findUnique({
    where: { userId },
    include: {
      items: {
        include: {
          product: {
            include: {
              images: { orderBy: { sortOrder: 'asc' } },
              colors: true,
              sizes: true,
            },
          },
        },
        orderBy: { createdAt: 'desc' },
      },
    },
  });

  if (!cart || cart.items.length === 0) {
    return {
      items: [],
      subtotal: 0,
      itemCount: 0,
    };
  }

  let subtotal = 0;
  let itemCount = 0;

  const formattedItems = cart.items.map((item) => {
    const product = item.product;
    const price = Number(product.price);
    const discountPrice = product.discountPrice !== null ? Number(product.discountPrice) : null;
    const unitPrice = (discountPrice !== null && discountPrice < price) ? discountPrice : price;
    const lineTotal = Number((unitPrice * item.quantity).toFixed(2));

    subtotal += lineTotal;
    itemCount += item.quantity;

    // Check stock for this product + sizeLabel
    const targetSize = product.sizes.find(
      (s) => s.label.toLowerCase() === item.sizeLabel.toLowerCase()
    );
    const inStock = targetSize ? targetSize.stock >= item.quantity && targetSize.stock > 0 : false;

    return {
      id: item.id,
      productId: item.productId,
      name: product.name,
      brand: product.brand,
      thumbnailUrl: product.images.length > 0 ? product.images[0].url : null,
      price,
      discountPrice,
      colorName: item.colorName,
      sizeLabel: item.sizeLabel,
      quantity: item.quantity,
      lineTotal,
      inStock,
    };
  });

  return {
    items: formattedItems,
    subtotal: Number(subtotal.toFixed(2)),
    itemCount,
  };
}

export const getCart = async (req: AuthenticatedRequest, res: Response): Promise<void> => {
  try {
    const userId = req.userId;
    if (!userId) {
      res.status(401).json({ message: 'User authentication required' });
      return;
    }

    const cartData = await getFormattedCart(userId);
    res.status(200).json(cartData);
  } catch (error) {
    console.error('Error in getCart:', error);
    res.status(500).json({ message: 'Failed to fetch cart' });
  }
};

export const addItemToCart = async (req: AuthenticatedRequest, res: Response): Promise<void> => {
  try {
    const userId = req.userId;
    if (!userId) {
      res.status(401).json({ message: 'User authentication required' });
      return;
    }

    const parseResult = addItemSchema.safeParse(req.body);
    if (!parseResult.success) {
      res.status(400).json({
        message: 'Invalid request payload',
        errors: parseResult.error.flatten().fieldErrors,
      });
      return;
    }

    const { productId, colorName, sizeLabel, quantity } = parseResult.data;

    // 1. Verify product exists
    const product = await prisma.product.findUnique({
      where: { id: productId },
      include: {
        colors: true,
        sizes: true,
      },
    });

    if (!product) {
      res.status(404).json({ message: 'Product not found' });
      return;
    }

    // 2. Verify color & size exist for product
    const colorExists = product.colors.some(
      (c) => c.name.toLowerCase() === colorName.toLowerCase()
    );
    if (!colorExists) {
      res.status(400).json({ message: `Color '${colorName}' is not available for this product` });
      return;
    }

    const targetSize = product.sizes.find(
      (s) => s.label.toLowerCase() === sizeLabel.toLowerCase()
    );
    if (!targetSize) {
      res.status(400).json({ message: `Size '${sizeLabel}' is not available for this product` });
      return;
    }

    // 3. Find or create Cart for user (lazy creation)
    let cart = await prisma.cart.findUnique({
      where: { userId },
    });

    if (!cart) {
      cart = await prisma.cart.create({
        data: { userId },
      });
    }

    // 4. Check existing item quantity in cart
    const existingItem = await prisma.cartItem.findUnique({
      where: {
        cartId_productId_colorName_sizeLabel: {
          cartId: cart.id,
          productId,
          colorName,
          sizeLabel,
        },
      },
    });

    const combinedQuantity = (existingItem ? existingItem.quantity : 0) + quantity;

    if (combinedQuantity > targetSize.stock) {
      res.status(400).json({
        message: `Requested total quantity (${combinedQuantity}) exceeds available stock (${targetSize.stock}) for size ${sizeLabel}`,
      });
      return;
    }

    // 5. Upsert CartItem
    if (existingItem) {
      await prisma.cartItem.update({
        where: { id: existingItem.id },
        data: { quantity: combinedQuantity },
      });
    } else {
      await prisma.cartItem.create({
        data: {
          cartId: cart.id,
          productId,
          colorName,
          sizeLabel,
          quantity,
        },
      });
    }

    const updatedCart = await getFormattedCart(userId);
    res.status(200).json(updatedCart);
  } catch (error) {
    console.error('Error in addItemToCart:', error);
    res.status(500).json({ message: 'Failed to add item to cart' });
  }
};

export const updateCartItem = async (req: AuthenticatedRequest, res: Response): Promise<void> => {
  try {
    const userId = req.userId;
    const cartItemId = req.params.cartItemId as string;

    if (!userId) {
      res.status(401).json({ message: 'User authentication required' });
      return;
    }

    const parseResult = updateItemSchema.safeParse(req.body);
    if (!parseResult.success) {
      res.status(400).json({
        message: 'Invalid request payload',
        errors: parseResult.error.flatten().fieldErrors,
      });
      return;
    }

    const { quantity } = parseResult.data;

    // Verify cart item exists & belongs to user's cart
    const cartItem = await prisma.cartItem.findFirst({
      where: {
        id: cartItemId,
        cart: { userId },
      },
      include: {
        product: {
          include: { sizes: true },
        },
      },
    });

    if (!cartItem) {
      res.status(404).json({ message: 'Cart item not found' });
      return;
    }

    if (quantity <= 0) {
      // Remove item if quantity set to 0
      await prisma.cartItem.delete({
        where: { id: cartItemId },
      });
    } else {
      // Validate against stock
      const targetSize = cartItem.product.sizes.find(
        (s) => s.label.toLowerCase() === cartItem.sizeLabel.toLowerCase()
      );

      if (targetSize && quantity > targetSize.stock) {
        res.status(400).json({
          message: `Requested quantity (${quantity}) exceeds available stock (${targetSize.stock}) for size ${cartItem.sizeLabel}`,
        });
        return;
      }

      await prisma.cartItem.update({
        where: { id: cartItemId },
        data: { quantity },
      });
    }

    const updatedCart = await getFormattedCart(userId);
    res.status(200).json(updatedCart);
  } catch (error) {
    console.error('Error in updateCartItem:', error);
    res.status(500).json({ message: 'Failed to update cart item' });
  }
};

export const removeCartItem = async (req: AuthenticatedRequest, res: Response): Promise<void> => {
  try {
    const userId = req.userId;
    const cartItemId = req.params.cartItemId as string;

    if (!userId) {
      res.status(401).json({ message: 'User authentication required' });
      return;
    }

    const cartItem = await prisma.cartItem.findFirst({
      where: {
        id: cartItemId,
        cart: { userId },
      },
    });

    if (!cartItem) {
      res.status(404).json({ message: 'Cart item not found' });
      return;
    }

    await prisma.cartItem.delete({
      where: { id: cartItemId },
    });

    const updatedCart = await getFormattedCart(userId);
    res.status(200).json(updatedCart);
  } catch (error) {
    console.error('Error in removeCartItem:', error);
    res.status(500).json({ message: 'Failed to remove cart item' });
  }
};

export const clearCart = async (req: AuthenticatedRequest, res: Response): Promise<void> => {
  try {
    const userId = req.userId;
    if (!userId) {
      res.status(401).json({ message: 'User authentication required' });
      return;
    }

    const cart = await prisma.cart.findUnique({
      where: { userId },
    });

    if (cart) {
      await prisma.cartItem.deleteMany({
        where: { cartId: cart.id },
      });
    }

    const emptyCart = await getFormattedCart(userId);
    res.status(200).json(emptyCart);
  } catch (error) {
    console.error('Error in clearCart:', error);
    res.status(500).json({ message: 'Failed to clear cart' });
  }
};
