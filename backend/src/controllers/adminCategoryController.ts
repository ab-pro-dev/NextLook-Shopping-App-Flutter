import { Request, Response } from 'express';
import { prisma } from '../utils/prisma';
import { z } from 'zod';

function slugify(text: string): string {
  return text
    .toLowerCase()
    .trim()
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/^-+|-+$/g, '');
}

const createCategorySchema = z.object({
  name: z.string().trim().min(1, 'Category name is required'),
  slug: z.string().trim().optional(),
  iconName: z.string().trim().default('tag'),
});

const updateCategorySchema = z.object({
  name: z.string().trim().min(1, 'Category name is required').optional(),
  slug: z.string().trim().optional(),
  iconName: z.string().trim().optional(),
});

/**
 * GET /api/admin/categories
 * Returns all categories with product counts
 */
export async function getAdminCategories(req: Request, res: Response) {
  try {
    const categories = await prisma.category.findMany({
      include: {
        _count: {
          select: { products: true },
        },
      },
      orderBy: { name: 'asc' },
    });

    const formatted = categories.map((c) => ({
      id: c.id,
      name: c.name,
      slug: c.slug,
      iconName: c.iconName,
      productCount: c._count.products,
      createdAt: c.createdAt,
      updatedAt: c.updatedAt,
    }));

    return res.status(200).json(formatted);
  } catch (error: any) {
    console.error('Error fetching admin categories:', error);
    return res.status(500).json({ message: 'Failed to fetch categories' });
  }
}

/**
 * POST /api/admin/categories
 * Create a new category with slug uniqueness validation
 */
export async function createAdminCategory(req: Request, res: Response) {
  try {
    const parseResult = createCategorySchema.safeParse(req.body);
    if (!parseResult.success) {
      return res.status(400).json({
        message: 'Invalid category payload',
        errors: parseResult.error.flatten().fieldErrors,
      });
    }

    const { name, iconName } = parseResult.data;
    let slug = parseResult.data.slug ? slugify(parseResult.data.slug) : slugify(name);

    if (!slug) {
      slug = slugify(name);
    }

    if (!slug) {
      return res.status(400).json({ message: 'A valid URL-safe slug is required' });
    }

    // Check slug uniqueness
    const existing = await prisma.category.findUnique({
      where: { slug },
    });

    if (existing) {
      return res.status(409).json({
        message: `Category slug '${slug}' is already taken. Please choose a unique slug.`,
      });
    }

    const newCategory = await prisma.category.create({
      data: {
        name,
        slug,
        iconName: iconName || 'tag',
      },
    });

    return res.status(201).json({
      ...newCategory,
      productCount: 0,
    });
  } catch (error: any) {
    console.error('Error creating admin category:', error);
    return res.status(500).json({ message: 'Failed to create category' });
  }
}

/**
 * PUT /api/admin/categories/:id
 * Update category details with slug uniqueness check
 */
export async function updateAdminCategory(req: Request, res: Response) {
  try {
    const id = req.params.id as string;

    const parseResult = updateCategorySchema.safeParse(req.body);
    if (!parseResult.success) {
      return res.status(400).json({
        message: 'Invalid category update payload',
        errors: parseResult.error.flatten().fieldErrors,
      });
    }

    const existingCategory = await prisma.category.findUnique({ where: { id } });
    if (!existingCategory) {
      return res.status(404).json({ message: 'Category not found' });
    }

    const { name, iconName } = parseResult.data;
    let targetSlug = existingCategory.slug;

    if (parseResult.data.slug) {
      targetSlug = slugify(parseResult.data.slug);
    } else if (name && name !== existingCategory.name) {
      targetSlug = slugify(name);
    }

    // Check slug uniqueness against other categories
    const duplicate = await prisma.category.findFirst({
      where: {
        slug: targetSlug,
        id: { not: id },
      },
    });

    if (duplicate) {
      return res.status(409).json({
        message: `Category slug '${targetSlug}' is already taken by another category.`,
      });
    }

    const updated = await prisma.category.update({
      where: { id },
      data: {
        name: name !== undefined ? name : existingCategory.name,
        slug: targetSlug,
        iconName: iconName !== undefined ? iconName : existingCategory.iconName,
      },
      include: {
        _count: {
          select: { products: true },
        },
      },
    });

    return res.status(200).json({
      id: updated.id,
      name: updated.name,
      slug: updated.slug,
      iconName: updated.iconName,
      productCount: updated._count.products,
      createdAt: updated.createdAt,
      updatedAt: updated.updatedAt,
    });
  } catch (error: any) {
    console.error('Error updating admin category:', error);
    return res.status(500).json({ message: 'Failed to update category' });
  }
}

/**
 * DELETE /api/admin/categories/:id
 * Delete empty category, or return 409 Conflict if products are still assigned
 */
export async function deleteAdminCategory(req: Request, res: Response) {
  try {
    const id = req.params.id as string;

    const category = await prisma.category.findUnique({
      where: { id },
      include: {
        _count: {
          select: { products: true },
        },
      },
    });

    if (!category) {
      return res.status(404).json({ message: 'Category not found' });
    }

    const productCount = category._count.products;

    if (productCount > 0) {
      return res.status(409).json({
        message: 'Cannot delete a category with existing products. Reassign or delete those products first.',
        productCount,
      });
    }

    await prisma.category.delete({
      where: { id },
    });

    return res.status(200).json({
      message: `Category '${category.name}' deleted successfully`,
      id,
    });
  } catch (error: any) {
    console.error('Error deleting admin category:', error);
    return res.status(500).json({ message: 'Failed to delete category' });
  }
}
