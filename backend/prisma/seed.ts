import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

async function main() {
  console.log('Seeding database...');

  // Clean existing product data
  await prisma.productSize.deleteMany({});
  await prisma.productColor.deleteMany({});
  await prisma.productImage.deleteMany({});
  await prisma.product.deleteMany({});
  await prisma.category.deleteMany({});

  // 1. Create 5 Categories
  const menCategory = await prisma.category.create({
    data: {
      name: 'Men',
      slug: 'men',
      iconName: 'male',
    },
  });

  const womenCategory = await prisma.category.create({
    data: {
      name: 'Women',
      slug: 'women',
      iconName: 'female',
    },
  });

  const kidsCategory = await prisma.category.create({
    data: {
      name: 'Kids',
      slug: 'kids',
      iconName: 'child',
    },
  });

  const shoesCategory = await prisma.category.create({
    data: {
      name: 'Shoes',
      slug: 'shoes',
      iconName: 'shoe',
    },
  });

  const accessoriesCategory = await prisma.category.create({
    data: {
      name: 'Accessories',
      slug: 'accessories',
      iconName: 'accessories',
    },
  });

  console.log('Created 5 categories.');

  // 2. Create 12 Products spread across categories
  const productsData = [
    // --- MEN ---
    {
      name: 'Classic Leather Biker Jacket',
      description: 'Premium genuine lambskin leather jacket with asymmetrical zip closure and quilted shoulder detail.',
      brand: 'UrbanEdge',
      categoryId: menCategory.id,
      price: 199.99,
      discountPrice: 149.99,
      stock: 45,
      sku: 'MEN-JKT-001',
      weight: 1250,
      rating: 4.8,
      reviewCount: 124,
      isFlashSale: true,
      isNewArrival: false,
      isTrending: true,
      isBestSeller: true,
      images: [
        { url: 'https://picsum.photos/seed/biker-jacket-1/800/800', sortOrder: 0 },
        { url: 'https://picsum.photos/seed/biker-jacket-2/800/800', sortOrder: 1 },
        { url: 'https://picsum.photos/seed/biker-jacket-3/800/800', sortOrder: 2 },
      ],
      colors: [
        { name: 'Black', hexCode: '#000000' },
        { name: 'Dark Brown', hexCode: '#3E2723' },
      ],
      sizes: [
        { label: 'S', stock: 10 },
        { label: 'M', stock: 15 },
        { label: 'L', stock: 20 },
        { label: 'XL', stock: 0 }, // Out of stock size test
      ],
    },
    {
      name: 'Heavyweight Oversized Hoodie',
      description: 'Ultra-soft 450gsm organic cotton fleece hoodie with drop shoulders and double-lined hood.',
      brand: 'StreetFit',
      categoryId: menCategory.id,
      price: 79.99,
      discountPrice: null,
      stock: 60,
      sku: 'MEN-HD-002',
      weight: 850,
      rating: 4.6,
      reviewCount: 88,
      isFlashSale: false,
      isNewArrival: true,
      isTrending: true,
      isBestSeller: false,
      images: [
        { url: 'https://picsum.photos/seed/oversized-hoodie-1/800/800', sortOrder: 0 },
        { url: 'https://picsum.photos/seed/oversized-hoodie-2/800/800', sortOrder: 1 },
      ],
      colors: [
        { name: 'Navy', hexCode: '#1E1E2D' },
        { name: 'Heather Gray', hexCode: '#9E9E9E' },
        { name: 'Sage Green', hexCode: '#87A96B' },
      ],
      sizes: [
        { label: 'S', stock: 15 },
        { label: 'M', stock: 20 },
        { label: 'L', stock: 15 },
        { label: 'XL', stock: 10 },
      ],
    },
    {
      name: 'Slim Tapered Raw Denim Jeans',
      description: '14oz Japanese selvage raw denim tailored with a slim tapered fit and brass hardware.',
      brand: 'DenimCo',
      categoryId: menCategory.id,
      price: 119.99,
      discountPrice: null,
      stock: 35,
      sku: 'MEN-JNS-003',
      weight: 700,
      rating: 4.7,
      reviewCount: 65,
      isFlashSale: false,
      isNewArrival: false,
      isTrending: false,
      isBestSeller: true,
      images: [
        { url: 'https://picsum.photos/seed/slim-jeans-1/800/800', sortOrder: 0 },
        { url: 'https://picsum.photos/seed/slim-jeans-2/800/800', sortOrder: 1 },
      ],
      colors: [
        { name: 'Indigo Blue', hexCode: '#1A237E' },
        { name: 'Washed Black', hexCode: '#212121' },
      ],
      sizes: [
        { label: 'S', stock: 5 },
        { label: 'M', stock: 15 },
        { label: 'L', stock: 10 },
        { label: 'XL', stock: 5 },
      ],
    },

    // --- WOMEN ---
    {
      name: 'Elegance Trench Coat',
      description: 'Double-breasted classic beige trench coat crafted from water-resistant cotton gabardine.',
      brand: 'NextLook Studio',
      categoryId: womenCategory.id,
      price: 249.99,
      discountPrice: 179.99,
      stock: 30,
      sku: 'WMN-TRN-004',
      weight: 1100,
      rating: 4.9,
      reviewCount: 210,
      isFlashSale: true,
      isNewArrival: false,
      isTrending: true,
      isBestSeller: true,
      images: [
        { url: 'https://picsum.photos/seed/trench-coat-1/800/800', sortOrder: 0 },
        { url: 'https://picsum.photos/seed/trench-coat-2/800/800', sortOrder: 1 },
        { url: 'https://picsum.photos/seed/trench-coat-3/800/800', sortOrder: 2 },
      ],
      colors: [
        { name: 'Camel', hexCode: '#C19A6B' },
        { name: 'Black', hexCode: '#000000' },
      ],
      sizes: [
        { label: 'S', stock: 8 },
        { label: 'M', stock: 12 },
        { label: 'L', stock: 10 },
        { label: 'XL', stock: 0 },
      ],
    },
    {
      name: 'Silk Wrap Midi Dress',
      description: 'Flowing 100% mulberry silk wrap dress with a V-neckline and tie waist ribbon detail.',
      brand: 'Maison Luxe',
      categoryId: womenCategory.id,
      price: 159.99,
      discountPrice: null,
      stock: 40,
      sku: 'WMN-DRS-005',
      weight: 350,
      rating: 4.8,
      reviewCount: 92,
      isFlashSale: false,
      isNewArrival: true,
      isTrending: true,
      isBestSeller: false,
      images: [
        { url: 'https://picsum.photos/seed/silk-dress-1/800/800', sortOrder: 0 },
        { url: 'https://picsum.photos/seed/silk-dress-2/800/800', sortOrder: 1 },
      ],
      colors: [
        { name: 'Emerald Green', hexCode: '#004D40' },
        { name: 'Dusty Rose', hexCode: '#D81B60' },
        { name: 'Midnight Navy', hexCode: '#0D47A1' },
      ],
      sizes: [
        { label: 'S', stock: 10 },
        { label: 'M', stock: 15 },
        { label: 'L', stock: 15 },
        { label: 'XL', stock: 0 },
      ],
    },
    {
      name: 'Ribbed Knit Cashmere Sweater',
      description: 'Luxurious Mongolian cashmere crewneck sweater featuring fine ribbed trim and relaxed silhouette.',
      brand: 'Aura',
      categoryId: womenCategory.id,
      price: 139.99,
      discountPrice: 99.99,
      stock: 50,
      sku: 'WMN-SWT-006',
      weight: 450,
      rating: 4.7,
      reviewCount: 78,
      isFlashSale: true,
      isNewArrival: true,
      isTrending: false,
      isBestSeller: true,
      images: [
        { url: 'https://picsum.photos/seed/cashmere-sweater-1/800/800', sortOrder: 0 },
        { url: 'https://picsum.photos/seed/cashmere-sweater-2/800/800', sortOrder: 1 },
      ],
      colors: [
        { name: 'Cream', hexCode: '#FFFDD0' },
        { name: 'Soft Pink', hexCode: '#F8BBD0' },
        { name: 'Charcoal', hexCode: '#37474F' },
      ],
      sizes: [
        { label: 'S', stock: 15 },
        { label: 'M', stock: 20 },
        { label: 'L', stock: 10 },
        { label: 'XL', stock: 5 },
      ],
    },

    // --- KIDS ---
    {
      name: 'Colorful Puffer Winter Jacket',
      description: 'Windproof, water-resistant insulated toddler puffer jacket with cozy fleece lining.',
      brand: 'LittleExplorers',
      categoryId: kidsCategory.id,
      price: 59.99,
      discountPrice: null,
      stock: 80,
      sku: 'KDS-JKT-007',
      weight: 550,
      rating: 4.9,
      reviewCount: 140,
      isFlashSale: false,
      isNewArrival: true,
      isTrending: true,
      isBestSeller: true,
      images: [
        { url: 'https://picsum.photos/seed/kids-puffer-1/800/800', sortOrder: 0 },
        { url: 'https://picsum.photos/seed/kids-puffer-2/800/800', sortOrder: 1 },
      ],
      colors: [
        { name: 'Sunshine Yellow', hexCode: '#FBC02D' },
        { name: 'Sky Blue', hexCode: '#0288D1' },
      ],
      sizes: [
        { label: 'S', stock: 25 },
        { label: 'M', stock: 30 },
        { label: 'L', stock: 25 },
      ],
    },
    {
      name: 'Organic Cotton Graphic Tee Set',
      description: 'Pack of 3 breathable cotton short-sleeve graphic tees with playful animal prints.',
      brand: 'TinyThreads',
      categoryId: kidsCategory.id,
      price: 29.99,
      discountPrice: null,
      stock: 100,
      sku: 'KDS-TEE-008',
      weight: 250,
      rating: 4.6,
      reviewCount: 52,
      isFlashSale: false,
      isNewArrival: false,
      isTrending: false,
      isBestSeller: true,
      images: [
        { url: 'https://picsum.photos/seed/kids-tee-1/800/800', sortOrder: 0 },
        { url: 'https://picsum.photos/seed/kids-tee-2/800/800', sortOrder: 1 },
      ],
      colors: [
        { name: 'Multi-Color', hexCode: '#FF7043' },
        { name: 'Pastel Blue', hexCode: '#B2EBF2' },
      ],
      sizes: [
        { label: 'S', stock: 30 },
        { label: 'M', stock: 40 },
        { label: 'L', stock: 30 },
      ],
    },

    // --- SHOES ---
    {
      name: 'Retro High-Top Leather Sneakers',
      description: 'Iconic streetwise high-top sneakers with cushioned ankle collar and durable rubber sole.',
      brand: 'KicksNation',
      categoryId: shoesCategory.id,
      price: 129.99,
      discountPrice: 89.99,
      stock: 50,
      sku: 'SHS-SNK-009',
      weight: 950,
      rating: 4.8,
      reviewCount: 310,
      isFlashSale: true,
      isNewArrival: false,
      isTrending: true,
      isBestSeller: true,
      images: [
        { url: 'https://picsum.photos/seed/retro-sneaker-1/800/800', sortOrder: 0 },
        { url: 'https://picsum.photos/seed/retro-sneaker-2/800/800', sortOrder: 1 },
        { url: 'https://picsum.photos/seed/retro-sneaker-3/800/800', sortOrder: 2 },
      ],
      colors: [
        { name: 'White & Red', hexCode: '#E53935' },
        { name: 'Black & White', hexCode: '#212121' },
      ],
      sizes: [
        { label: 'S', stock: 10 },
        { label: 'M', stock: 20 },
        { label: 'L', stock: 15 },
        { label: 'XL', stock: 5 },
      ],
    },
    {
      name: 'Performance Mesh Running Shoes',
      description: 'Lightweight breathable mesh running shoes engineered with high-rebound responsive midsole cushioning.',
      brand: 'StridePro',
      categoryId: shoesCategory.id,
      price: 109.99,
      discountPrice: null,
      stock: 75,
      sku: 'SHS-RUN-010',
      weight: 650,
      rating: 4.7,
      reviewCount: 165,
      isFlashSale: false,
      isNewArrival: true,
      isTrending: true,
      isBestSeller: false,
      images: [
        { url: 'https://picsum.photos/seed/running-shoe-1/800/800', sortOrder: 0 },
        { url: 'https://picsum.photos/seed/running-shoe-2/800/800', sortOrder: 1 },
      ],
      colors: [
        { name: 'Neon Orange', hexCode: '#FF6D00' },
        { name: 'Cool Gray', hexCode: '#607D8B' },
      ],
      sizes: [
        { label: 'S', stock: 15 },
        { label: 'M', stock: 25 },
        { label: 'L', stock: 25 },
        { label: 'XL', stock: 10 },
      ],
    },

    // --- ACCESSORIES ---
    {
      name: 'Minimalist Stainless Steel Chronograph Watch',
      description: 'Waterproof 40mm quartz movement watch featuring sapphire crystal glass and genuine leather strap.',
      brand: 'Tempo',
      categoryId: accessoriesCategory.id,
      price: 189.99,
      discountPrice: null,
      stock: 40,
      sku: 'ACC-WTC-011',
      weight: 180,
      rating: 4.9,
      reviewCount: 195,
      isFlashSale: false,
      isNewArrival: true,
      isTrending: true,
      isBestSeller: true,
      images: [
        { url: 'https://picsum.photos/seed/chrono-watch-1/800/800', sortOrder: 0 },
        { url: 'https://picsum.photos/seed/chrono-watch-2/800/800', sortOrder: 1 },
      ],
      colors: [
        { name: 'Silver & Navy', hexCode: '#1A237E' },
        { name: 'Rose Gold & Black', hexCode: '#B71C1C' },
      ],
      sizes: [
        { label: 'One Size', stock: 40 },
      ],
    },
    {
      name: 'Polarized Aviator Sunglasses',
      description: 'UV400 protection polarized sunglasses with lightweight titanium metal frame.',
      brand: 'SolShades',
      categoryId: accessoriesCategory.id,
      price: 69.99,
      discountPrice: 49.99,
      stock: 65,
      sku: 'ACC-SGL-012',
      weight: 90,
      rating: 4.6,
      reviewCount: 110,
      isFlashSale: true,
      isNewArrival: false,
      isTrending: false,
      isBestSeller: true,
      images: [
        { url: 'https://picsum.photos/seed/aviator-sunglasses-1/800/800', sortOrder: 0 },
        { url: 'https://picsum.photos/seed/aviator-sunglasses-2/800/800', sortOrder: 1 },
      ],
      colors: [
        { name: 'Gold & Dark Green', hexCode: '#2E7D32' },
        { name: 'Gunmetal Gray', hexCode: '#424242' },
      ],
      sizes: [
        { label: 'One Size', stock: 65 },
      ],
    },
  ];

  for (const product of productsData) {
    const { images, colors, sizes, ...productCore } = product;
    await prisma.product.create({
      data: {
        ...productCore,
        images: {
          create: images,
        },
        colors: {
          create: colors,
        },
        sizes: {
          create: sizes,
        },
      },
    });
  }

  console.log(`Successfully seeded ${productsData.length} products across 5 categories.`);
}

main()
  .catch((e) => {
    console.error('Error seeding database:', e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
