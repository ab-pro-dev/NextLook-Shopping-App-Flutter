import { Response } from 'express';
import { PrismaClient } from '@prisma/client';
import { AuthenticatedRequest } from '../middleware/auth';
import { formatProductCard } from './productController';

const prisma = new PrismaClient();

export const getWishlist = async (req: AuthenticatedRequest, res: Response): Promise<void> => {
  try {
    const userId = req.userId;
    if (!userId) {
      res.status(401).json({ message: 'User authentication required' });
      return;
    }

    const items = await prisma.wishlist.findMany({
      where: { userId },
      include: {
        product: {
          include: {
            images: {
              orderBy: { sortOrder: 'asc' },
            },
          },
        },
      },
      orderBy: { createdAt: 'desc' },
    });

    const products = items.map((item) => formatProductCard(item.product));

    res.status(200).json({ products });
  } catch (error) {
    console.error('Error in getWishlist:', error);
    res.status(500).json({ message: 'Failed to fetch wishlist' });
  }
};

export const addToWishlist = async (req: AuthenticatedRequest, res: Response): Promise<void> => {
  try {
    const userId = req.userId;
    const productId = req.params.productId as string;

    if (!userId) {
      res.status(401).json({ message: 'User authentication required' });
      return;
    }

    if (!productId) {
      res.status(400).json({ message: 'Product ID is required' });
      return;
    }

    const product = await prisma.product.findUnique({
      where: { id: productId },
    });

    if (!product) {
      res.status(404).json({ message: 'Product not found' });
      return;
    }

    const existing = await prisma.wishlist.findUnique({
      where: {
        userId_productId: {
          userId,
          productId,
        },
      },
    });

    if (existing) {
      res.status(409).json({ message: 'Product already in wishlist' });
      return;
    }

    await prisma.wishlist.create({
      data: {
        userId,
        productId,
      },
    });

    res.status(201).json({ message: 'Product added to wishlist' });
  } catch (error) {
    console.error('Error in addToWishlist:', error);
    res.status(500).json({ message: 'Failed to add product to wishlist' });
  }
};

export const removeFromWishlist = async (req: AuthenticatedRequest, res: Response): Promise<void> => {
  try {
    const userId = req.userId;
    const productId = req.params.productId as string;

    if (!userId) {
      res.status(401).json({ message: 'User authentication required' });
      return;
    }

    if (!productId) {
      res.status(400).json({ message: 'Product ID is required' });
      return;
    }

    const existing = await prisma.wishlist.findUnique({
      where: {
        userId_productId: {
          userId,
          productId,
        },
      },
    });

    if (!existing) {
      res.status(404).json({ message: 'Product not in wishlist' });
      return;
    }

    await prisma.wishlist.delete({
      where: {
        id: existing.id,
      },
    });

    res.status(200).json({ message: 'Product removed from wishlist' });
  } catch (error) {
    console.error('Error in removeFromWishlist:', error);
    res.status(500).json({ message: 'Failed to remove product from wishlist' });
  }
};
