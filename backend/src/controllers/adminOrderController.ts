import { Request, Response } from 'express';
import { prisma } from '../utils/prisma';
import { OrderStatus, PaymentStatus } from '@prisma/client';

// Define valid state machine transitions
const ALLOWED_TRANSITIONS: Record<OrderStatus, OrderStatus[]> = {
  [OrderStatus.PENDING]: [OrderStatus.PROCESSING, OrderStatus.CANCELLED],
  [OrderStatus.PROCESSING]: [OrderStatus.SHIPPED, OrderStatus.CANCELLED],
  [OrderStatus.SHIPPED]: [OrderStatus.OUT_FOR_DELIVERY, OrderStatus.CANCELLED],
  [OrderStatus.OUT_FOR_DELIVERY]: [OrderStatus.DELIVERED, OrderStatus.CANCELLED],
  [OrderStatus.DELIVERED]: [], // Terminal state
  [OrderStatus.CANCELLED]: [], // Terminal state
};

/**
 * GET /api/admin/orders
 * Returns all orders across all users with customer name/email, status, total, itemCount
 */
export async function getAdminOrders(req: Request, res: Response) {
  try {
    const { status, search } = req.query;

    const where: any = {};

    if (status && typeof status === 'string' && status !== 'ALL') {
      where.status = status as OrderStatus;
    }

    if (search && typeof search === 'string' && search.trim() !== '') {
      const q = search.trim();
      where.OR = [
        { orderNumber: { contains: q, mode: 'insensitive' } },
        { shippingFullName: { contains: q, mode: 'insensitive' } },
        { user: { name: { contains: q, mode: 'insensitive' } } },
        { user: { email: { contains: q, mode: 'insensitive' } } },
      ];
    }

    const orders = await prisma.order.findMany({
      where,
      include: {
        user: { select: { id: true, name: true, email: true } },
        items: true,
      },
      orderBy: { createdAt: 'desc' },
    });

    const formatted = orders.map((o) => {
      const itemCount = o.items.reduce((sum, item) => sum + item.quantity, 0);
      return {
        id: o.id,
        orderNumber: o.orderNumber,
        customerName: o.user?.name || o.shippingFullName,
        customerEmail: o.user?.email || 'N/A',
        status: o.status,
        paymentStatus: o.paymentStatus,
        paymentMethod: o.paymentMethod,
        total: o.total,
        itemCount,
        createdAt: o.createdAt,
      };
    });

    return res.status(200).json(formatted);
  } catch (error: any) {
    console.error('Error fetching admin orders:', error);
    return res.status(500).json({ message: 'Failed to fetch orders' });
  }
}

/**
 * GET /api/admin/orders/:id
 * Returns full order detail including shipping address, customer contact, items, and status history
 */
export async function getAdminOrderById(req: Request, res: Response) {
  try {
    const id = req.params.id as string;

    const order = await prisma.order.findUnique({
      where: { id },
      include: {
        user: { select: { id: true, name: true, email: true } },
        items: true,
        statusHistory: {
          orderBy: { createdAt: 'asc' },
        },
      },
    });

    if (!order) {
      return res.status(404).json({ message: 'Order not found' });
    }

    const allowedNextStatuses = ALLOWED_TRANSITIONS[order.status] || [];

    return res.status(200).json({
      ...order,
      customerName: order.user?.name || order.shippingFullName,
      customerEmail: order.user?.email || 'N/A',
      allowedNextStatuses,
    });
  } catch (error: any) {
    console.error('Error fetching admin order details:', error);
    return res.status(500).json({ message: 'Failed to fetch order details' });
  }
}

/**
 * PUT /api/admin/orders/:id/status
 * Update order status, enforce forward state machine, restore stock on cancellation, and trigger customer notification
 */
export async function updateAdminOrderStatus(req: Request, res: Response) {
  try {
    const id = req.params.id as string;
    const { status: newStatus } = req.body;

    if (!newStatus || !Object.values(OrderStatus).includes(newStatus as OrderStatus)) {
      return res.status(400).json({ message: `Invalid status '${newStatus}' provided` });
    }

    const order = await prisma.order.findUnique({
      where: { id },
      include: {
        items: true,
      },
    });

    if (!order) {
      return res.status(404).json({ message: 'Order not found' });
    }

    const currentStatus = order.status;

    if (currentStatus === newStatus) {
      return res.status(400).json({ message: `Order #${order.orderNumber} is already in status '${currentStatus}'` });
    }

    // Terminal states check
    if (currentStatus === OrderStatus.DELIVERED) {
      return res.status(400).json({ message: 'Order has already been delivered and cannot be modified.' });
    }

    if (currentStatus === OrderStatus.CANCELLED) {
      return res.status(400).json({ message: 'Cancelled orders cannot be modified.' });
    }

    // Validate state machine transition
    const validNextStates = ALLOWED_TRANSITIONS[currentStatus] || [];
    if (!validNextStates.includes(newStatus as OrderStatus)) {
      return res.status(400).json({
        message: `Invalid status transition from '${currentStatus}' to '${newStatus}'. Allowed next states: [${validNextStates.join(
          ', '
        )}]`,
      });
    }

    // Perform status transition in a Prisma Transaction
    const updatedOrder = await prisma.$transaction(async (tx) => {
      // Determine if payment status should update to PAID on delivery
      let paymentStatusUpdate = order.paymentStatus;
      if (newStatus === OrderStatus.DELIVERED) {
        paymentStatusUpdate = PaymentStatus.PAID;
      }

      // 1. Update Order status & paymentStatus
      const updated = await tx.order.update({
        where: { id },
        data: {
          status: newStatus as OrderStatus,
          paymentStatus: paymentStatusUpdate,
        },
        include: {
          items: true,
          statusHistory: { orderBy: { createdAt: 'asc' } },
        },
      });

      // 2. Create OrderStatusHistory record (mobile app tracking timeline reads this!)
      await tx.orderStatusHistory.create({
        data: {
          orderId: id,
          status: newStatus as OrderStatus,
        },
      });

      // 3. If transitioning to CANCELLED, restore product size stock
      if (newStatus === OrderStatus.CANCELLED) {
        for (const item of order.items) {
          const targetSize = await tx.productSize.findFirst({
            where: {
              productId: item.productId,
              label: { equals: item.sizeLabel, mode: 'insensitive' },
            },
          });

          if (targetSize) {
            await tx.productSize.update({
              where: { id: targetSize.id },
              data: { stock: { increment: item.quantity } },
            });

            // Recalculate total product stock sum
            const allSizes = await tx.productSize.findMany({
              where: { productId: item.productId },
            });
            const newTotalStock = allSizes.reduce((sum, s) => sum + s.stock, 0);

            await tx.product.update({
              where: { id: item.productId },
              data: { stock: newTotalStock },
            });
          }
        }
      }

      // 4. Create Notification for the customer
      const notificationMessages: Record<OrderStatus, { title: string; body: string }> = {
        [OrderStatus.PENDING]: { title: 'Order Pending', body: `Your order #${order.orderNumber} is pending confirmation.` },
        [OrderStatus.PROCESSING]: { title: 'Order Processing', body: `Your order #${order.orderNumber} is now being processed.` },
        [OrderStatus.SHIPPED]: { title: 'Order Shipped 🚚', body: `Your order #${order.orderNumber} has been shipped!` },
        [OrderStatus.OUT_FOR_DELIVERY]: { title: 'Out For Delivery 📦', body: `Your order #${order.orderNumber} is out for delivery!` },
        [OrderStatus.DELIVERED]: { title: 'Order Delivered 🎉', body: `Your order #${order.orderNumber} has been delivered. Enjoy your purchase!` },
        [OrderStatus.CANCELLED]: { title: 'Order Cancelled ❌', body: `Your order #${order.orderNumber} has been cancelled.` },
      };

      const msgInfo = notificationMessages[newStatus as OrderStatus];
      await tx.notification.create({
        data: {
          userId: order.userId,
          type: 'ORDER_UPDATE',
          title: msgInfo.title,
          body: msgInfo.body,
          relatedOrderId: order.id,
        },
      });

      return updated;
    });

    const allowedNextStatuses = ALLOWED_TRANSITIONS[updatedOrder.status] || [];

    return res.status(200).json({
      ...updatedOrder,
      allowedNextStatuses,
      message: `Order status updated to '${newStatus}' successfully`,
    });
  } catch (error: any) {
    console.error('Error updating order status:', error);
    return res.status(500).json({ message: 'Failed to update order status' });
  }
}
