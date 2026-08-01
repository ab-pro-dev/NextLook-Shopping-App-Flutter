import { Request, Response } from 'express';
import { prisma } from '../utils/prisma';
import { createBannerSchema, updateBannerSchema } from '../utils/validation';
import cloudinary from '../config/cloudinary';

/**
 * GET /api/banners
 * Public endpoint — returns active banners only, ordered by sortOrder ascending
 */
export async function getPublicBanners(_req: Request, res: Response) {
  try {
    const banners = await prisma.banner.findMany({
      where: { isActive: true },
      orderBy: { sortOrder: 'asc' },
    });

    return res.status(200).json(banners);
  } catch (error: any) {
    console.error('Error fetching public banners:', error);
    return res.status(500).json({ message: 'Failed to fetch promotional banners' });
  }
}

/**
 * GET /api/admin/banners
 * Admin endpoint — returns ALL banners (active and inactive), ordered by sortOrder ascending
 */
export async function getAdminBanners(_req: Request, res: Response) {
  try {
    const banners = await prisma.banner.findMany({
      orderBy: { sortOrder: 'asc' },
    });

    return res.status(200).json(banners);
  } catch (error: any) {
    console.error('Error fetching admin banners:', error);
    return res.status(500).json({ message: 'Failed to fetch admin banners' });
  }
}

/**
 * POST /api/admin/banners
 * Admin endpoint — creates a new promotional banner
 */
export async function createAdminBanner(req: Request, res: Response) {
  try {
    const parseResult = createBannerSchema.safeParse(req.body);
    if (!parseResult.success) {
      const issue = parseResult.error.issues[0];
      return res.status(400).json({
        message: issue ? `${issue.path.join('.')}: ${issue.message}` : 'Validation error',
        errors: parseResult.error.issues,
      });
    }

    const data = parseResult.data;

    const newBanner = await prisma.banner.create({
      data: {
        title: data.title.trim(),
        imageUrl: data.imageUrl,
        subtitle: data.subtitle ? data.subtitle.trim() : null,
        buttonText: data.buttonText ? data.buttonText.trim() : null,
        categorySlug: data.categorySlug ? data.categorySlug.trim() : null,
        targetProductId: data.targetProductId ? data.targetProductId.trim() : null,
        sortOrder: data.sortOrder,
        isActive: data.isActive,
      },
    });

    return res.status(201).json(newBanner);
  } catch (error: any) {
    console.error('Error creating banner:', error);
    return res.status(500).json({ message: 'Failed to create banner' });
  }
}

/**
 * PUT /api/admin/banners/:id
 * Admin endpoint — updates an existing banner
 */
export async function updateAdminBanner(req: Request, res: Response) {
  try {
    const id = req.params.id as string;

    const existing = await prisma.banner.findUnique({ where: { id } });
    if (!existing) {
      return res.status(404).json({ message: 'Banner not found' });
    }

    const parseResult = updateBannerSchema.safeParse(req.body);
    if (!parseResult.success) {
      const issue = parseResult.error.issues[0];
      return res.status(400).json({
        message: issue ? `${issue.path.join('.')}: ${issue.message}` : 'Validation error',
        errors: parseResult.error.issues,
      });
    }

    const data = parseResult.data;

    const updatedBanner = await prisma.banner.update({
      where: { id },
      data: {
        ...(data.title !== undefined && { title: data.title.trim() }),
        ...(data.imageUrl !== undefined && { imageUrl: data.imageUrl }),
        ...(data.subtitle !== undefined && { subtitle: data.subtitle ? data.subtitle.trim() : null }),
        ...(data.buttonText !== undefined && { buttonText: data.buttonText ? data.buttonText.trim() : null }),
        ...(data.categorySlug !== undefined && { categorySlug: data.categorySlug ? data.categorySlug.trim() : null }),
        ...(data.targetProductId !== undefined && { targetProductId: data.targetProductId ? data.targetProductId.trim() : null }),
        ...(data.sortOrder !== undefined && { sortOrder: data.sortOrder }),
        ...(data.isActive !== undefined && { isActive: data.isActive }),
      },
    });

    return res.status(200).json(updatedBanner);
  } catch (error: any) {
    console.error('Error updating banner:', error);
    return res.status(500).json({ message: 'Failed to update banner' });
  }
}

/**
 * DELETE /api/admin/banners/:id
 * Admin endpoint — deletes a banner and attempts to delete its Cloudinary image asset
 */
export async function deleteAdminBanner(req: Request, res: Response) {
  try {
    const id = req.params.id as string;

    const banner = await prisma.banner.findUnique({ where: { id } });
    if (!banner) {
      return res.status(404).json({ message: 'Banner not found' });
    }

    // Try deleting image asset from Cloudinary if publicId can be extracted
    if (banner.imageUrl && banner.imageUrl.includes('cloudinary.com')) {
      try {
        // Example URL: https://res.cloudinary.com/vgnpcqyo/image/upload/v12345/nextlook/banners/abc.png
        const parts = banner.imageUrl.split('/upload/');
        if (parts[1]) {
          // Remove version string (e.g. v123456/) if present
          const pathWithoutVersion = parts[1].replace(/^v\d+\//, '');
          // Remove extension (.jpg, .png, etc)
          const publicId = pathWithoutVersion.replace(/\.[^/.]+$/, '');
          if (publicId) {
            await cloudinary.uploader.destroy(publicId);
          }
        }
      } catch (cldError) {
        console.warn('Failed to delete banner image from Cloudinary:', cldError);
      }
    }

    await prisma.banner.delete({ where: { id } });

    return res.status(200).json({ message: 'Banner deleted successfully' });
  } catch (error: any) {
    console.error('Error deleting banner:', error);
    return res.status(500).json({ message: 'Failed to delete banner' });
  }
}
