import { Request, Response } from 'express';
import { prisma } from '../utils/prisma';
import { Role, OrderStatus } from '@prisma/client';

/**
 * GET /api/admin/customers
 * Returns all registered customer accounts with order counts, total spent, and last order date.
 * Filtered to role CUSTOMER to match the Dashboard's totalCustomers count exactly.
 */
export async function getAdminCustomers(req: Request, res: Response) {
  try {
    const { search } = req.query;

    const where: any = { role: Role.CUSTOMER };

    if (search && typeof search === 'string' && search.trim() !== '') {
      const q = search.trim();
      where.AND = [
        {
          OR: [
            { name: { contains: q, mode: 'insensitive' } },
            { email: { contains: q, mode: 'insensitive' } },
          ],
        },
      ];
    }

    const customers = await prisma.user.findMany({
      where,
      include: {
        orders: {
          select: {
            id: true,
            status: true,
            total: true,
            createdAt: true,
          },
          orderBy: { createdAt: 'desc' },
        },
      },
      orderBy: { createdAt: 'desc' },
    });

    const formatted = customers.map((c) => {
      const totalOrdersCount = c.orders.length;
      const nonCancelledOrders = c.orders.filter((o) => o.status !== OrderStatus.CANCELLED);
      const totalSpent = nonCancelledOrders.reduce((sum, o) => sum + o.total, 0);
      const lastOrderDate = c.orders.length > 0 ? c.orders[0].createdAt : null;

      return {
        id: c.id,
        name: c.name,
        email: c.email,
        avatarUrl: c.avatarUrl,
        role: c.role,
        createdAt: c.createdAt,
        totalOrdersCount,
        totalSpent,
        lastOrderDate,
      };
    });

    return res.status(200).json(formatted);
  } catch (error: any) {
    console.error('Error fetching admin customers:', error);
    return res.status(500).json({ message: 'Failed to fetch customer list' });
  }
}

/**
 * GET /api/admin/customers/:id
 * Returns full customer profile detail including saved delivery addresses and complete order history.
 */
export async function getAdminCustomerById(req: Request, res: Response) {
  try {
    const id = req.params.id as string;

    const customer = await prisma.user.findUnique({
      where: { id },
      select: {
        id: true,
        name: true,
        email: true,
        avatarUrl: true,
        role: true,
        createdAt: true,
        addresses: {
          orderBy: { isDefault: 'desc' },
        },
        orders: {
          orderBy: { createdAt: 'desc' },
          include: {
            items: true,
          },
        },
      },
    });

    if (!customer) {
      return res.status(404).json({ message: 'Customer account not found' });
    }

    const totalOrdersCount = customer.orders.length;
    const nonCancelledOrders = customer.orders.filter((o) => o.status !== OrderStatus.CANCELLED);
    const totalSpent = nonCancelledOrders.reduce((sum, o) => sum + o.total, 0);
    const lastOrderDate = customer.orders.length > 0 ? customer.orders[0].createdAt : null;

    return res.status(200).json({
      ...customer,
      totalOrdersCount,
      totalSpent,
      lastOrderDate,
    });
  } catch (error: any) {
    console.error('Error fetching admin customer detail:', error);
    return res.status(500).json({ message: 'Failed to fetch customer profile' });
  }
}
