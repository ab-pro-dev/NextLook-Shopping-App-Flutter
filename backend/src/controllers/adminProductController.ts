import { Request, Response } from 'express';
import { prisma } from '../utils/prisma';
import { z } from 'zod';

// Zod Schema for Product Validation
export const productSchema = z.object({
  name: z.string().min(1, 'Product name is required'),
  description: z.string().min(1, 'Description is required'),
  brand: z.string().trim().nullable().optional(),
  categoryId: z.string().uuid('Valid Category ID is required'),
  price: z.number().positive('Price must be greater than 0'),
  discountPrice: z.number().positive('Discount price must be positive').nullable().optional(),
  sku: z.string().min(1, 'SKU is required'),
  weight: z.number().positive().nullable().optional(),
  isFlashSale: z.boolean().default(false),
  isNewArrival: z.boolean().default(false),
  isTrending: z.boolean().default(false),
  isBestSeller: z.boolean().default(false),
  images: z.array(
    z.object({
      url: z.string().url('Invalid image URL'),
      sortOrder: z.number().int().default(0),
    })
  ).min(1, 'At least one image is required'),
  colors: z.array(
    z.object({
      name: z.string().min(1, 'Color name is required'),
      hexCode: z.string().min(1, 'Hex code is required'),
    })
  ).min(1, 'At least one color is required'),
  sizes: z.array(
    z.object({
      label: z.string().min(1, 'Size label is required'),
      stock: z.number().int().min(0, 'Stock cannot be negative'),
    })
  ).min(1, 'At least one size is required'),
}).refine(
  (data) => {
    if (data.discountPrice !== undefined && data.discountPrice !== null) {
      return data.discountPrice < data.price;
    }
    return true;
  },
  {
    message: 'Discount price must be less than regular price',
    path: ['discountPrice'],
  }
);

/**
 * GET /api/admin/products
 * Returns all products with category names, aggregated stock, thumbnail, and metadata
 */
export async function getAdminProducts(_req: Request, res: Response) {
  try {
    const products = await prisma.product.findMany({
      include: {
        category: { select: { id: true, name: true, slug: true } },
        images: { orderBy: { sortOrder: 'asc' } },
        sizes: true,
        colors: true,
      },
      orderBy: { createdAt: 'desc' },
    });

    const formatted = products.map((p) => {
      const totalStock = p.sizes.reduce((sum, s) => sum + s.stock, 0);
      return {
        id: p.id,
        name: p.name,
        description: p.description,
        brand: p.brand,
        categoryId: p.categoryId,
        categoryName: p.category.name,
        categorySlug: p.category.slug,
        price: Number(p.price),
        discountPrice: p.discountPrice !== null ? Number(p.discountPrice) : null,
        stock: totalStock,
        sku: p.sku,
        weight: p.weight,
        rating: Number(p.rating),
        reviewCount: p.reviewCount,
        thumbnailUrl: p.images[0]?.url || '',
        isFlashSale: p.isFlashSale,
        isNewArrival: p.isNewArrival,
        isTrending: p.isTrending,
        isBestSeller: p.isBestSeller,
        images: p.images,
        colors: p.colors,
        sizes: p.sizes,
        createdAt: p.createdAt,
        updatedAt: p.updatedAt,
      };
    });

    return res.status(200).json(formatted);
  } catch (error: any) {
    console.error('Error fetching admin products:', error);
    return res.status(500).json({ message: 'Failed to fetch products' });
  }
}

/**
 * GET /api/admin/products/:id
 * Full product detail for admin
 */
export async function getAdminProductById(req: Request, res: Response) {
  try {
    const id = req.params.id as string;
    const product = await prisma.product.findUnique({
      where: { id },
      include: {
        category: { select: { id: true, name: true, slug: true } },
        images: { orderBy: { sortOrder: 'asc' } },
        sizes: true,
        colors: true,
      },
    });

    if (!product) {
      return res.status(404).json({ message: 'Product not found' });
    }

    const totalStock = product.sizes.reduce((sum: number, s: { stock: number }) => sum + s.stock, 0);

    return res.status(200).json({
      ...product,
      categoryName: product.category.name,
      price: Number(product.price),
      discountPrice: product.discountPrice !== null ? Number(product.discountPrice) : null,
      stock: totalStock,
      rating: Number(product.rating),
    });
  } catch (error: any) {
    console.error('Error fetching product by ID:', error);
    return res.status(500).json({ message: 'Failed to fetch product details' });
  }
}

/**
 * POST /api/admin/products
 * Create a new product with images, colors, and sizes in a transaction
 */
export async function createAdminProduct(req: Request, res: Response) {
  try {
    const parseResult = productSchema.safeParse(req.body);
    if (!parseResult.success) {
      const issue = parseResult.error.issues[0];
      return res.status(400).json({
        message: issue ? `${issue.path.join('.')}: ${issue.message}` : 'Validation error',
        errors: parseResult.error.format(),
      });
    }

    const data = parseResult.data;

    // Check SKU uniqueness
    const existingSku = await prisma.product.findUnique({
      where: { sku: data.sku },
    });
    if (existingSku) {
      return res.status(400).json({ message: `SKU '${data.sku}' is already in use by another product` });
    }

    const totalStock = data.sizes.reduce((sum, s) => sum + s.stock, 0);

    const newProduct = await prisma.$transaction(async (tx) => {
      return tx.product.create({
        data: {
          name: data.name,
          description: data.description,
          brand: data.brand ? data.brand.trim() : null,
          categoryId: data.categoryId,
          price: data.price,
          discountPrice: data.discountPrice ?? null,
          sku: data.sku,
          weight: data.weight ?? null,
          stock: totalStock,
          isFlashSale: data.isFlashSale,
          isNewArrival: data.isNewArrival,
          isTrending: data.isTrending,
          isBestSeller: data.isBestSeller,
          images: {
            create: data.images,
          },
          colors: {
            create: data.colors,
          },
          sizes: {
            create: data.sizes,
          },
        },
        include: {
          category: { select: { id: true, name: true } },
          images: { orderBy: { sortOrder: 'asc' } },
          colors: true,
          sizes: true,
        },
      });
    });

    return res.status(201).json({
      ...newProduct,
      categoryName: newProduct.category.name,
      price: Number(newProduct.price),
      discountPrice: newProduct.discountPrice !== null ? Number(newProduct.discountPrice) : null,
      stock: totalStock,
      thumbnailUrl: newProduct.images[0]?.url || '',
    });
  } catch (error: any) {
    console.error('Error creating product:', error);
    return res.status(500).json({ message: 'Failed to create product' });
  }
}

/**
 * PUT /api/admin/products/:id
 * Update existing product and replace all images/colors/sizes in a transaction
 */
export async function updateAdminProduct(req: Request, res: Response) {
  try {
    const id = req.params.id as string;

    const existing = await prisma.product.findUnique({ where: { id } });
    if (!existing) {
      return res.status(404).json({ message: 'Product not found' });
    }

    const parseResult = productSchema.safeParse(req.body);
    if (!parseResult.success) {
      const issue = parseResult.error.issues[0];
      return res.status(400).json({
        message: issue ? `${issue.path.join('.')}: ${issue.message}` : 'Validation error',
        errors: parseResult.error.format(),
      });
    }

    const data = parseResult.data;

    // Check SKU uniqueness if changed
    if (data.sku !== existing.sku) {
      const otherProductWithSku = await prisma.product.findUnique({
        where: { sku: data.sku },
      });
      if (otherProductWithSku && otherProductWithSku.id !== id) {
        return res.status(400).json({ message: `SKU '${data.sku}' is already in use by another product` });
      }
    }

    const totalStock = data.sizes.reduce((sum, s) => sum + s.stock, 0);

    const updatedProduct = await prisma.$transaction(async (tx) => {
      // 1. Delete existing relations
      await tx.productImage.deleteMany({ where: { productId: id } });
      await tx.productColor.deleteMany({ where: { productId: id } });
      await tx.productSize.deleteMany({ where: { productId: id } });

      // 2. Update product and recreate relations
      return tx.product.update({
        where: { id },
        data: {
          name: data.name,
          description: data.description,
          brand: data.brand ? data.brand.trim() : null,
          categoryId: data.categoryId,
          price: data.price,
          discountPrice: data.discountPrice ?? null,
          sku: data.sku,
          weight: data.weight ?? null,
          stock: totalStock,
          isFlashSale: data.isFlashSale,
          isNewArrival: data.isNewArrival,
          isTrending: data.isTrending,
          isBestSeller: data.isBestSeller,
          images: {
            create: data.images,
          },
          colors: {
            create: data.colors,
          },
          sizes: {
            create: data.sizes,
          },
        },
        include: {
          category: { select: { id: true, name: true } },
          images: { orderBy: { sortOrder: 'asc' } },
          colors: true,
          sizes: true,
        },
      });
    });

    return res.status(200).json({
      ...updatedProduct,
      categoryName: updatedProduct.category.name,
      price: Number(updatedProduct.price),
      discountPrice: updatedProduct.discountPrice !== null ? Number(updatedProduct.discountPrice) : null,
      stock: totalStock,
      thumbnailUrl: updatedProduct.images[0]?.url || '',
    });
  } catch (error: any) {
    console.error('Error updating product:', error);
    return res.status(500).json({ message: 'Failed to update product' });
  }
}

/**
 * DELETE /api/admin/products/:id
 * Delete a product. Blocks deletion with 409 if any OrderItem references it.
 */
export async function deleteAdminProduct(req: Request, res: Response) {
  try {
    const id = req.params.id as string;

    const existing = await prisma.product.findUnique({ where: { id } });
    if (!existing) {
      return res.status(404).json({ message: 'Product not found' });
    }

    // Check if OrderItem references this product
    const orderItemCount = await prisma.orderItem.count({
      where: { productId: id },
    });

    if (orderItemCount > 0) {
      return res.status(409).json({
        message: 'Cannot delete a product with existing orders. Consider marking it out of stock instead.',
      });
    }

    // Safe to delete product (cascade deletes images, colors, sizes, cartItems, wishlists)
    await prisma.product.delete({
      where: { id },
    });

    return res.status(200).json({ message: 'Product deleted successfully', id });
  } catch (error: any) {
    console.error('Error deleting product:', error);
    return res.status(500).json({ message: 'Failed to delete product' });
  }
}

/**
 * PUT /api/admin/products/:id/stock
 * Update stock for a specific size label and recalculate total product stock
 */
export async function updateAdminProductStock(req: Request, res: Response) {
  try {
    const id = req.params.id as string;
    const { sizeLabel, stock } = req.body;

    if (!sizeLabel || typeof stock !== 'number' || stock < 0) {
      return res.status(400).json({ message: 'Valid sizeLabel and non-negative stock are required' });
    }

    const product = await prisma.product.findUnique({ where: { id } });
    if (!product) {
      return res.status(404).json({ message: 'Product not found' });
    }

    const existingSize = await prisma.productSize.findFirst({
      where: { productId: id, label: sizeLabel },
    });

    if (!existingSize) {
      return res.status(404).json({ message: `Size '${sizeLabel}' not found for this product` });
    }

    // Update size stock
    await prisma.productSize.update({
      where: { id: existingSize.id },
      data: { stock },
    });

    // Recalculate total product stock across all sizes
    const allSizes = await prisma.productSize.findMany({
      where: { productId: id },
    });
    const totalStock = allSizes.reduce((sum, s) => sum + s.stock, 0);

    await prisma.product.update({
      where: { id },
      data: { stock: totalStock },
    });

    return res.status(200).json({
      message: 'Stock updated successfully',
      productId: id,
      sizeLabel,
      sizeStock: stock,
      totalProductStock: totalStock,
    });
  } catch (error: any) {
    console.error('Error updating product stock:', error);
    return res.status(500).json({ message: 'Failed to update stock' });
  }
}
