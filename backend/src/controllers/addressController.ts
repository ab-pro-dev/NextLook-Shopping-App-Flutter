import { Response } from 'express';
import { PrismaClient } from '@prisma/client';
import { z } from 'zod';
import { AuthenticatedRequest } from '../middleware/auth';

const prisma = new PrismaClient();

const addressSchema = z.object({
  fullName: z.string().trim().min(1, 'fullName is required'),
  phone: z.string().trim().min(1, 'phone is required'),
  addressLine1: z.string().trim().min(1, 'addressLine1 is required'),
  addressLine2: z.string().trim().optional().nullable(),
  city: z.string().trim().min(1, 'city is required'),
  region: z.string().trim().optional().default('Addis Ababa'),
  country: z.string().trim().optional().default('Ethiopia'),
  isDefault: z.boolean().optional().default(false),
});

export const getAddresses = async (req: AuthenticatedRequest, res: Response): Promise<void> => {
  try {
    const userId = req.userId;
    if (!userId) {
      res.status(401).json({ message: 'User authentication required' });
      return;
    }

    const addresses = await prisma.address.findMany({
      where: { userId },
      orderBy: [
        { isDefault: 'desc' },
        { createdAt: 'desc' },
      ],
    });

    res.status(200).json({ addresses });
  } catch (error) {
    console.error('Error in getAddresses:', error);
    res.status(500).json({ message: 'Failed to fetch addresses' });
  }
};

export const createAddress = async (req: AuthenticatedRequest, res: Response): Promise<void> => {
  try {
    const userId = req.userId;
    if (!userId) {
      res.status(401).json({ message: 'User authentication required' });
      return;
    }

    const parseResult = addressSchema.safeParse(req.body);
    if (!parseResult.success) {
      res.status(400).json({
        message: 'Invalid address payload',
        errors: parseResult.error.flatten().fieldErrors,
      });
      return;
    }

    const data = parseResult.data;

    // Check count of existing addresses
    const existingCount = await prisma.address.count({
      where: { userId },
    });

    // Force isDefault to true if this is the user's first address
    let shouldBeDefault = data.isDefault;
    if (existingCount === 0) {
      shouldBeDefault = true;
    }

    const address = await prisma.$transaction(async (tx) => {
      if (shouldBeDefault && existingCount > 0) {
        await tx.address.updateMany({
          where: { userId, isDefault: true },
          data: { isDefault: false },
        });
      }

      return await tx.address.create({
        data: {
          userId,
          fullName: data.fullName,
          phone: data.phone,
          addressLine1: data.addressLine1,
          addressLine2: data.addressLine2 || null,
          city: data.city,
          region: data.region,
          country: data.country,
          isDefault: shouldBeDefault,
        },
      });
    });

    res.status(201).json({ address });
  } catch (error) {
    console.error('Error in createAddress:', error);
    res.status(500).json({ message: 'Failed to create address' });
  }
};

export const updateAddress = async (req: AuthenticatedRequest, res: Response): Promise<void> => {
  try {
    const userId = req.userId;
    const addressId = req.params.id as string;

    if (!userId) {
      res.status(401).json({ message: 'User authentication required' });
      return;
    }

    const parseResult = addressSchema.safeParse(req.body);
    if (!parseResult.success) {
      res.status(400).json({
        message: 'Invalid address payload',
        errors: parseResult.error.flatten().fieldErrors,
      });
      return;
    }

    const existingAddress = await prisma.address.findFirst({
      where: { id: addressId, userId },
    });

    if (!existingAddress) {
      res.status(404).json({ message: 'Address not found' });
      return;
    }

    const data = parseResult.data;
    const shouldBeDefault = data.isDefault;

    const address = await prisma.$transaction(async (tx) => {
      if (shouldBeDefault && !existingAddress.isDefault) {
        await tx.address.updateMany({
          where: { userId, isDefault: true },
          data: { isDefault: false },
        });
      }

      return await tx.address.update({
        where: { id: addressId },
        data: {
          fullName: data.fullName,
          phone: data.phone,
          addressLine1: data.addressLine1,
          addressLine2: data.addressLine2 || null,
          city: data.city,
          region: data.region,
          country: data.country,
          isDefault: shouldBeDefault,
        },
      });
    });

    res.status(200).json({ address });
  } catch (error) {
    console.error('Error in updateAddress:', error);
    res.status(500).json({ message: 'Failed to update address' });
  }
};

export const deleteAddress = async (req: AuthenticatedRequest, res: Response): Promise<void> => {
  try {
    const userId = req.userId;
    const addressId = req.params.id as string;

    if (!userId) {
      res.status(401).json({ message: 'User authentication required' });
      return;
    }

    const existingAddress = await prisma.address.findFirst({
      where: { id: addressId, userId },
    });

    if (!existingAddress) {
      res.status(404).json({ message: 'Address not found' });
      return;
    }

    await prisma.$transaction(async (tx) => {
      await tx.address.delete({
        where: { id: addressId },
      });

      // If deleted address was default, promote the most recently created remaining address
      if (existingAddress.isDefault) {
        const newestRemaining = await tx.address.findFirst({
          where: { userId },
          orderBy: { createdAt: 'desc' },
        });

        if (newestRemaining) {
          await tx.address.update({
            where: { id: newestRemaining.id },
            data: { isDefault: true },
          });
        }
      }
    });

    res.status(200).json({ message: 'Address deleted successfully' });
  } catch (error) {
    console.error('Error in deleteAddress:', error);
    res.status(500).json({ message: 'Failed to delete address' });
  }
};

export const setDefaultAddress = async (req: AuthenticatedRequest, res: Response): Promise<void> => {
  try {
    const userId = req.userId;
    const addressId = req.params.id as string;

    if (!userId) {
      res.status(401).json({ message: 'User authentication required' });
      return;
    }

    const existingAddress = await prisma.address.findFirst({
      where: { id: addressId, userId },
    });

    if (!existingAddress) {
      res.status(404).json({ message: 'Address not found' });
      return;
    }

    const address = await prisma.$transaction(async (tx) => {
      await tx.address.updateMany({
        where: { userId, isDefault: true },
        data: { isDefault: false },
      });

      return await tx.address.update({
        where: { id: addressId },
        data: { isDefault: true },
      });
    });

    res.status(200).json({ address });
  } catch (error) {
    console.error('Error in setDefaultAddress:', error);
    res.status(500).json({ message: 'Failed to set default address' });
  }
};
