import { Request, Response } from 'express';
import { prisma } from '../utils/prisma';
import { OrderStatus } from '@prisma/client';

/**
 * GET /api/admin/dashboard-stats
 * Returns real, aggregated database statistics for the NextLook Admin Dashboard.
 */
export async function getDashboardStats(_req: Request, res: Response) {
  try {
    // 1. Total Revenue: Sum total for all non-cancelled orders
    // (Chosen because orders currently use Cash on Delivery while gateways are paused)
    const revenueAggregate = await prisma.order.aggregate({
      _sum: {
        total: true,
      },
      where: {
        status: {
          not: OrderStatus.CANCELLED,
        },
      },
    });
    const totalRevenue = revenueAggregate._sum.total || 0;

    // 2. Count of Order rows
    const totalOrders = await prisma.order.count();

    // 3. Count of Product rows
    const activeProducts = await prisma.product.count();

    // 4. Count of Category rows
    const totalCategories = await prisma.category.count();

    // 5. Count of User rows with role CUSTOMER
    const totalCustomers = await prisma.user.count({
      where: {
        role: 'CUSTOMER',
      },
    });

    // 6. Real monthly revenue aggregation (only for actual months with order data)
    const nonCancelledOrders = await prisma.order.findMany({
      where: {
        status: {
          not: OrderStatus.CANCELLED,
        },
      },
      select: {
        total: true,
        createdAt: true,
      },
      orderBy: {
        createdAt: 'asc',
      },
    });

    const monthlyMap: Record<string, number> = {};
    const monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

    for (const order of nonCancelledOrders) {
      const date = new Date(order.createdAt);
      const monthKey = `${monthNames[date.getMonth()]} ${date.getFullYear()}`;
      monthlyMap[monthKey] = (monthlyMap[monthKey] || 0) + order.total;
    }

    const revenueByMonth = Object.entries(monthlyMap).map(([month, revenue]) => ({
      month,
      revenue,
    }));

    // 7. Real sales by category aggregation based on OrderItem quantities
    const orderItems = await prisma.orderItem.findMany({
      where: {
        order: {
          status: {
            not: OrderStatus.CANCELLED,
          },
        },
      },
      select: {
        quantity: true,
        product: {
          select: {
            category: {
              select: {
                name: true,
              },
            },
          },
        },
      },
    });

    const categoryMap: Record<string, number> = {};
    for (const item of orderItems) {
      const categoryName = item.product?.category?.name || 'Uncategorized';
      categoryMap[categoryName] = (categoryMap[categoryName] || 0) + item.quantity;
    }

    const salesByCategory = Object.entries(categoryMap).map(([category, unitsSold]) => ({
      category,
      unitsSold,
    }));

    return res.status(200).json({
      totalRevenue,
      totalOrders,
      activeProducts,
      totalCategories,
      totalCustomers,
      revenueByMonth,
      salesByCategory,
    });
  } catch (error: any) {
    console.error('Error fetching dashboard stats:', error);
    return res.status(500).json({ message: 'Failed to fetch dashboard statistics' });
  }
}
