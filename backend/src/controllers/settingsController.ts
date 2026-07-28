import { Request, Response } from 'express';
import { prisma } from '../utils/prisma';
import { z } from 'zod';

const updateSettingsSchema = z.object({
  standardDeliveryLabel: z.string().trim().min(1).optional(),
  standardDeliveryDays: z.string().trim().min(1).optional(),
  standardDeliveryPrice: z.coerce.number().int().min(0, 'Price must be a non-negative integer').optional(),
  expressDeliveryLabel: z.string().trim().min(1).optional(),
  expressDeliveryDays: z.string().trim().min(1).optional(),
  expressDeliveryPrice: z.coerce.number().int().min(0, 'Price must be a non-negative integer').optional(),
  taxRatePercent: z.coerce.number().min(0, 'Tax rate must be >= 0').max(100, 'Tax rate must be <= 100').optional(),
});

/**
 * Helper to ensure a StoreSettings singleton row always exists
 */
async function getOrCreateSingletonSettings() {
  let settings = await prisma.storeSettings.findFirst();
  if (!settings) {
    settings = await prisma.storeSettings.create({
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
  return settings;
}

/**
 * GET /api/settings
 * PUBLIC endpoint returning single StoreSettings configuration
 */
export async function getPublicSettings(_req: Request, res: Response) {
  try {
    const settings = await getOrCreateSingletonSettings();
    return res.status(200).json(settings);
  } catch (error: any) {
    console.error('Error fetching store settings:', error);
    return res.status(500).json({ message: 'Failed to fetch store settings' });
  }
}

/**
 * GET /api/settings/db-schema-check
 * Temporary diagnostic endpoint returning direct information_schema query from database
 */
export async function getDbSchemaCheck(_req: Request, res: Response) {
  try {
    const columns: any = await prisma.$queryRaw`
      SELECT column_name, data_type, is_nullable
      FROM information_schema.columns
      WHERE table_name = 'User'
      ORDER BY ordinal_position;
    `;
    return res.status(200).json({
      environment: 'PRODUCTION_NEON_DATABASE',
      columns,
    });
  } catch (error: any) {
    return res.status(500).json({ error: error.message });
  }
}

/**
 * PUT /api/admin/settings
 * ADMIN endpoint to update delivery prices, labels, and tax rate
 */
export async function updateAdminSettings(req: Request, res: Response) {
  try {
    const parseResult = updateSettingsSchema.safeParse(req.body);
    if (!parseResult.success) {
      return res.status(400).json({
        message: 'Invalid settings update payload',
        errors: parseResult.error.flatten().fieldErrors,
      });
    }

    const currentSettings = await getOrCreateSingletonSettings();

    const updated = await prisma.storeSettings.update({
      where: { id: currentSettings.id },
      data: parseResult.data,
    });

    return res.status(200).json(updated);
  } catch (error: any) {
    console.error('Error updating store settings:', error);
    return res.status(500).json({ message: 'Failed to update store settings' });
  }
}
