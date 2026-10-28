import { Request, Response } from 'express';
import { PrismaClient, Prisma } from '@prisma/client';
import { z } from 'zod';

const prisma = new PrismaClient();

const productQuerySchema = z.object({
  category: z.string().optional(),
  search: z.string().optional(),
  minPrice: z.coerce.number().min(0, 'minPrice must be greater than or equal to 0').optional(),
  maxPrice: z.coerce.number().min(0, 'maxPrice must be greater than or equal to 0').optional(),
  color: z.string().optional(),
  size: z.string().optional(),
  minRating: z.coerce.number().min(0).max(5).optional(),
  sort: z.enum(['newest', 'price_asc', 'price_desc', 'rating', 'popularity']).optional().default('newest'),
  page: z.coerce.number().int().min(1, 'page must be a positive integer').optional().default(1),
  limit: z.coerce.number().int().min(1, 'limit must be a positive integer').max(100).optional().default(20),
  isFlashSale: z.preprocess((val) => val === 'true' || val === true, z.boolean()).optional(),
  isNewArrival: z.preprocess((val) => val === 'true' || val === true, z.boolean()).optional(),
  isTrending: z.preprocess((val) => val === 'true' || val === true, z.boolean()).optional(),
  isBestSeller: z.preprocess((val) => val === 'true' || val === true, z.boolean()).optional(),
});

export function resolveImageUrl(url: string | null | undefined, req?: Request): string | null {
  if (!url) return null;
  if (url.startsWith('http://') || url.startsWith('https://')) return url;
  if (req) {
    const protocol = req.headers['x-forwarded-proto'] || req.protocol || 'https';
    const host = req.headers['x-forwarded-host'] || req.get('host') || 'nextlook-shopping-app-flutter.onrender.com';
    return `${protocol}://${host}${url.startsWith('/') ? '' : '/'}${url}`;
  }
  return `https://nextlook-shopping-app-flutter.onrender.com${url.startsWith('/') ? '' : '/'}${url}`;
}

export function formatProductCard(p: any, req?: Request) {
  const rawUrl = p.images && p.images.length > 0 ? p.images[0].url : null;
  return {
    id: p.id,
    name: p.name,
    brand: p.brand,
    price: Number(p.price),
    discountPrice: p.discountPrice !== null ? Number(p.discountPrice) : null,
    rating: p.rating,
    reviewCount: p.reviewCount,
    thumbnailUrl: resolveImageUrl(rawUrl, req),
    isFlashSale: p.isFlashSale,
  };
}

export const getProducts = async (req: Request, res: Response): Promise<void> => {
  try {
    const parseResult = productQuerySchema.safeParse(req.query);
    if (!parseResult.success) {
      res.status(400).json({
        message: 'Invalid query parameters',
        errors: parseResult.error.flatten().fieldErrors,
      });
      return;
    }

    const {
      category,
      search,
      minPrice,
      maxPrice,
      color,
      size,
      minRating,
      sort,
      page,
      limit,
      isFlashSale,
      isNewArrival,
      isTrending,
      isBestSeller,
    } = parseResult.data;

    const where: Prisma.ProductWhereInput = {};

    if (category) {
      where.category = {
        slug: category,
      };
    }

    if (isFlashSale) {
      where.isFlashSale = true;
    }
    if (isNewArrival) {
      where.isNewArrival = true;
    }
    if (isTrending) {
      where.isTrending = true;
    }
    if (isBestSeller) {
      where.isBestSeller = true;
    }

    if (search && search.trim().length > 0) {
      const q = search.trim();
      where.OR = [
        { name: { contains: q, mode: 'insensitive' } },
        { brand: { contains: q, mode: 'insensitive' } },
        { description: { contains: q, mode: 'insensitive' } },
      ];
    }

    if (minPrice !== undefined || maxPrice !== undefined) {
      where.price = {};
      if (minPrice !== undefined) {
        where.price.gte = minPrice;
      }
      if (maxPrice !== undefined) {
        where.price.lte = maxPrice;
      }
    }

    if (minRating !== undefined) {
      where.rating = {
        gte: minRating,
      };
    }

    if (color) {
      where.colors = {
        some: {
          name: {
            equals: color,
            mode: 'insensitive',
          },
        },
      };
    }

    if (size) {
      where.sizes = {
        some: {
          label: {
            equals: size,
            mode: 'insensitive',
          },
          stock: {
            gt: 0,
          },
        },
      };
    }

    let orderBy: Prisma.ProductOrderByWithRelationInput = { createdAt: 'desc' };
    switch (sort) {
      case 'price_asc':
        orderBy = { price: 'asc' };
        break;
      case 'price_desc':
        orderBy = { price: 'desc' };
        break;
      case 'rating':
        orderBy = { rating: 'desc' };
        break;
      case 'popularity':
        orderBy = { reviewCount: 'desc' };
        break;
      case 'newest':
      default:
        orderBy = { createdAt: 'desc' };
        break;
    }

    const skip = (page - 1) * limit;

    const [total, items] = await Promise.all([
      prisma.product.count({ where }),
      prisma.product.findMany({
        where,
        orderBy,
        skip,
        take: limit,
        include: {
          images: {
            orderBy: { sortOrder: 'asc' },
            take: 1,
          },
        },
      }),
    ]);

    const totalPages = Math.ceil(total / limit);

    res.json({
      products: items.map((item) => formatProductCard(item, req)),
      total,
      page,
      totalPages,
    });
  } catch (error) {
    console.error('Error fetching products:', error);
    res.status(500).json({ message: 'Internal server error' });
  }
};

export const getHomeSections = async (req: Request, res: Response): Promise<void> => {
  try {
    const cardInclude = {
      images: {
        orderBy: { sortOrder: 'asc' as const },
        take: 1,
      },
    };

    const [flashSaleItems, newArrivalItems, trendingItems, bestSellerItems] = await Promise.all([
      prisma.product.findMany({
        where: { isFlashSale: true },
        take: 6,
        orderBy: { createdAt: 'desc' },
        include: cardInclude,
      }),
      prisma.product.findMany({
        where: { isNewArrival: true },
        take: 6,
        orderBy: { createdAt: 'desc' },
        include: cardInclude,
      }),
      prisma.product.findMany({
        where: { isTrending: true },
        take: 6,
        orderBy: { createdAt: 'desc' },
        include: cardInclude,
      }),
      prisma.product.findMany({
        where: { isBestSeller: true },
        take: 6,
        orderBy: { createdAt: 'desc' },
        include: cardInclude,
      }),
    ]);

    res.json({
      flashSale: flashSaleItems.map((item) => formatProductCard(item, req)),
      newArrivals: newArrivalItems.map((item) => formatProductCard(item, req)),
      trending: trendingItems.map((item) => formatProductCard(item, req)),
      bestSellers: bestSellerItems.map((item) => formatProductCard(item, req)),
    });
  } catch (error) {
    console.error('Error fetching home sections:', error);
    res.status(500).json({ message: 'Internal server error' });
  }
};

export const getProductById = async (req: Request, res: Response): Promise<void> => {
  try {
    const productId = req.params.id;

    if (typeof productId !== 'string') {
      res.status(404).json({ message: 'Product not found' });
      return;
    }

    const product = await prisma.product.findUnique({
      where: { id: productId },
      include: {
        category: {
          select: {
            name: true,
            slug: true,
          },
        },
        images: {
          orderBy: { sortOrder: 'asc' },
        },
        colors: {
          select: {
            id: true,
            name: true,
            hexCode: true,
          },
        },
        sizes: {
          select: {
            id: true,
            label: true,
            stock: true,
          },
        },
      },
    });

    if (!product) {
      res.status(404).json({ message: 'Product not found' });
      return;
    }

    res.json({
      id: product.id,
      name: product.name,
      description: product.description,
      brand: product.brand,
      category: {
        name: product.category.name,
        slug: product.category.slug,
      },
      price: Number(product.price),
      discountPrice: product.discountPrice !== null ? Number(product.discountPrice) : null,
      rating: product.rating,
      reviewCount: product.reviewCount,
      images: product.images.map((img: { id: string; url: string; sortOrder: number }) => ({
        id: img.id,
        url: resolveImageUrl(img.url, req),
        sortOrder: img.sortOrder,
      })),
      colors: product.colors,
      sizes: product.sizes,
      sku: product.sku,
      isFlashSale: product.isFlashSale,
      isNewArrival: product.isNewArrival,
      isTrending: product.isTrending,
      isBestSeller: product.isBestSeller,
    });
  } catch (error) {
    console.error('Error fetching product by ID:', error);
    res.status(500).json({ message: 'Internal server error' });
  }
};
