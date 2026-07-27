import { Response } from 'express';
import { prisma } from '../utils/prisma';
import { AuthenticatedRequest } from '../middleware/auth';

/**
 * GET /api/notifications
 * Returns current user's notifications ordered by createdAt desc.
 */
export const getNotifications = async (req: AuthenticatedRequest, res: Response) => {
  try {
    const userId = req.userId!;

    const notifications = await prisma.notification.findMany({
      where: { userId },
      orderBy: { createdAt: 'desc' },
      select: {
        id: true,
        type: true,
        title: true,
        body: true,
        isRead: true,
        relatedOrderId: true,
        createdAt: true,
      },
    });

    res.json(notifications);
  } catch (error) {
    console.error('Error fetching notifications:', error);
    res.status(500).json({ message: 'Failed to fetch notifications' });
  }
};

/**
 * PUT /api/notifications/:id/read
 * Marks a single notification as read.
 */
export const markNotificationAsRead = async (req: AuthenticatedRequest, res: Response) => {
  try {
    const userId = req.userId!;
    const id = req.params.id as string;

    const notification = await prisma.notification.findFirst({
      where: { id, userId },
    });

    if (!notification) {
      return res.status(404).json({ message: 'Notification not found' });
    }

    const updated = await prisma.notification.update({
      where: { id },
      data: { isRead: true },
      select: {
        id: true,
        type: true,
        title: true,
        body: true,
        isRead: true,
        relatedOrderId: true,
        createdAt: true,
      },
    });

    res.json(updated);
  } catch (error) {
    console.error('Error marking notification as read:', error);
    res.status(500).json({ message: 'Failed to mark notification as read' });
  }
};

/**
 * PUT /api/notifications/read-all
 * Marks ALL of current user's notifications as read in one call.
 */
export const markAllNotificationsAsRead = async (req: AuthenticatedRequest, res: Response) => {
  try {
    const userId = req.userId!;

    await prisma.notification.updateMany({
      where: { userId, isRead: false },
      data: { isRead: true },
    });

    res.json({ message: 'All notifications marked as read' });
  } catch (error) {
    console.error('Error marking all notifications as read:', error);
    res.status(500).json({ message: 'Failed to mark all notifications as read' });
  }
};

/**
 * GET /api/notifications/unread-count
 * Returns { count } of unread notifications for badge display.
 */
export const getUnreadNotificationCount = async (req: AuthenticatedRequest, res: Response) => {
  try {
    const userId = req.userId!;

    const count = await prisma.notification.count({
      where: { userId, isRead: false },
    });

    res.json({ count });
  } catch (error) {
    console.error('Error fetching unread notification count:', error);
    res.status(500).json({ message: 'Failed to fetch unread notification count' });
  }
};
