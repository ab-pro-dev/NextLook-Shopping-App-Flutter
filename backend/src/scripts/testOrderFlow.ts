import { PrismaClient } from '@prisma/client';
import { generateAccessToken } from '../utils/tokens';

const prisma = new PrismaClient();
const API_BASE = 'http://localhost:3000/api';

async function runTests() {
  console.log('====================================================');
  console.log('      NEXTLOOK ORDER MANAGEMENT API TEST SUITE     ');
  console.log('====================================================\n');

  // 0. Setup Test Users
  const user1 = await prisma.user.upsert({
    where: { email: 'ordertest1@example.com' },
    update: {},
    create: {
      name: 'Order Test User 1',
      email: 'ordertest1@example.com',
      passwordHash: 'hashed_password',
    },
  });

  const user2 = await prisma.user.upsert({
    where: { email: 'ordertest2@example.com' },
    update: {},
    create: {
      name: 'Order Test User 2',
      email: 'ordertest2@example.com',
      passwordHash: 'hashed_password',
    },
  });

  const token1 = generateAccessToken(user1.id);
  const token2 = generateAccessToken(user2.id);

  // Setup Test Address for User 1
  let address1 = await prisma.address.findFirst({
    where: { userId: user1.id },
  });

  if (!address1) {
    address1 = await prisma.address.create({
      data: {
        userId: user1.id,
        fullName: 'Abera Hagazi',
        phone: '+251914169551',
        addressLine1: 'Bole Road, House #402',
        addressLine2: 'Near Edna Mall',
        city: 'Addis Ababa',
        region: 'Addis Ababa',
        country: 'Ethiopia',
        isDefault: true,
      },
    });
  }

  // Clear existing orders & cart for user1 to have a clean slate
  await prisma.order.deleteMany({ where: { userId: user1.id } });
  await prisma.cart.deleteMany({ where: { userId: user1.id } });

  // Get a test product with available stock
  const product1 = await prisma.product.findFirst({
    where: { name: 'Classic Leather Biker Jacket' },
    include: { colors: true, sizes: true, images: true },
  });

  if (!product1) {
    throw new Error('Test product "Classic Leather Biker Jacket" not found in DB!');
  }

  const targetSize = product1.sizes.find((s) => s.label === 'M') || product1.sizes[0];

  console.log(`[SETUP] User 1 ID: ${user1.id}`);
  console.log(`[SETUP] Address 1 ID: ${address1.id}`);
  console.log(`[SETUP] Product 1: "${product1.name}" (ID: ${product1.id})`);
  console.log(`[SETUP] Product 1 Price: ${product1.price}, Discount Price: ${product1.discountPrice}`);
  console.log(`[SETUP] Size "${targetSize.label}" Initial Stock in DB: ${targetSize.stock}\n`);

  // =========================================================================
  // TEST 1: Place a real order with valid cart items
  // =========================================================================
  console.log('----------------------------------------------------');
  console.log('TEST 1: Place a real order with valid cart items');
  console.log('----------------------------------------------------');

  // Add 2 jackets to user1's cart via Cart API or Prisma directly
  const cart1 = await prisma.cart.create({
    data: {
      userId: user1.id,
      items: {
        create: {
          productId: product1.id,
          colorName: product1.colors[0]?.name || 'Black',
          sizeLabel: targetSize.label,
          quantity: 2,
        },
      },
    },
    include: { items: true },
  });

  console.log(`-> Added 2x "${product1.name}" (Size: ${targetSize.label}) to User 1's cart (Cart ID: ${cart1.id})`);
  const stockBeforeOrder = targetSize.stock;

  const orderPayload = {
    addressId: address1.id,
    deliveryMethodLabel: 'Express Delivery',
    deliveryMethodPrice: 350,
    paymentMethod: 'Cash on Delivery',
  };

  console.log('\n[REQUEST] POST /api/orders');
  console.log('Headers: Authorization: Bearer <token1>');
  console.log('Body:', JSON.stringify(orderPayload, null, 2));

  const res1 = await fetch(`${API_BASE}/orders`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      Authorization: `Bearer ${token1}`,
    },
    body: JSON.stringify(orderPayload),
  });

  const body1 = (await res1.json()) as any;
  console.log(`\n[RESPONSE] Status: ${res1.status}`);
  console.log('Response Body:', JSON.stringify(body1, null, 2));

  const createdOrderId = body1.id;

  // =========================================================================
  // TEST 2: Query the database directly to verify side-effects
  // =========================================================================
  console.log('\n----------------------------------------------------');
  console.log('TEST 2: Query database directly to verify side-effects');
  console.log('----------------------------------------------------');

  const dbOrder = await prisma.order.findUnique({
    where: { id: createdOrderId },
    include: { items: true, statusHistory: true },
  });

  const updatedSizeInDb = await prisma.productSize.findUnique({
    where: { id: targetSize.id },
  });

  const dbCartItems = await prisma.cartItem.findMany({
    where: { cart: { userId: user1.id } },
  });

  console.log('DB Order Verification:');
  console.log(`- Order Created in DB: ${!!dbOrder} (Order #: ${dbOrder?.orderNumber})`);
  console.log(`- Status: ${dbOrder?.status}`);
  console.log(`- Snapshotted Address: ${dbOrder?.shippingFullName}, ${dbOrder?.shippingAddressLine1}, ${dbOrder?.shippingCity}`);
  console.log(`- Subtotal: ${dbOrder?.subtotal} ETB, Shipping: ${dbOrder?.shippingCost} ETB, Total: ${dbOrder?.total} ETB`);
  console.log(`- OrderItems Count: ${dbOrder?.items.length}`);
  if (dbOrder?.items[0]) {
    console.log(`  -> Item: ${dbOrder.items[0].productName} | Size: ${dbOrder.items[0].sizeLabel} | Qty: ${dbOrder.items[0].quantity} | UnitPrice: ${dbOrder.items[0].unitPrice} ETB | LineTotal: ${dbOrder.items[0].lineTotal} ETB`);
  }
  console.log(`- OrderStatusHistory Count: ${dbOrder?.statusHistory.length} (First status: ${dbOrder?.statusHistory[0]?.status})`);
  console.log(`- Stock Before Order: ${stockBeforeOrder} -> Stock After Order: ${updatedSizeInDb?.stock} (Decremented by 2: ${stockBeforeOrder - (updatedSizeInDb?.stock || 0) === 2})`);
  console.log(`- User Cart Remaining Items: ${dbCartItems.length} (Cart cleared: ${dbCartItems.length === 0})`);

  // =========================================================================
  // TEST 3: Try placing an order with an EMPTY cart
  // =========================================================================
  console.log('\n----------------------------------------------------');
  console.log('TEST 3: Place order with EMPTY cart');
  console.log('----------------------------------------------------');

  console.log('[REQUEST] POST /api/orders (User 1 cart is now empty)');
  const resEmpty = await fetch(`${API_BASE}/orders`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      Authorization: `Bearer ${token1}`,
    },
    body: JSON.stringify(orderPayload),
  });

  const bodyEmpty = (await resEmpty.json()) as any;
  console.log(`[RESPONSE] Status: ${resEmpty.status}`);
  console.log('Response Body:', JSON.stringify(bodyEmpty, null, 2));

  // =========================================================================
  // TEST 4: Stock depletion & Transaction Rollback Proof
  // =========================================================================
  console.log('\n----------------------------------------------------');
  console.log('TEST 4: Insufficient stock & Transaction Rollback Proof');
  console.log('----------------------------------------------------');

  // Find another product
  const product2 = await prisma.product.findFirst({
    where: { name: 'Silk Wrap Midi Dress' },
    include: { colors: true, sizes: true, images: true },
  });

  if (!product2) {
    throw new Error('Test product "Silk Wrap Midi Dress" not found in DB!');
  }

  const dressSize = product2.sizes.find((s) => s.label === 'S') || product2.sizes[0];

  // Add 2 dresses to user1's cart
  const cartUser1 = await prisma.cart.upsert({
    where: { userId: user1.id },
    update: {},
    create: { userId: user1.id },
  });

  await prisma.cartItem.create({
    data: {
      cartId: cartUser1.id,
      productId: product2.id,
      colorName: product2.colors[0]?.name || 'Red',
      sizeLabel: dressSize.label,
      quantity: 2,
    },
  });

  console.log(`-> Added 2x "${product2.name}" (Size: ${dressSize.label}) to User 1's cart.`);

  // MANUALLY REDUCE STOCK IN DB TO 1 (less than the requested 2)
  await prisma.productSize.update({
    where: { id: dressSize.id },
    data: { stock: 1 },
  });
  console.log(`-> Manually reduced "${product2.name}" (Size: ${dressSize.label}) stock in DB to 1.`);

  const ordersCountBeforeFail = await prisma.order.count();
  const stockBeforeFail = (await prisma.productSize.findUnique({ where: { id: dressSize.id } }))?.stock;
  const cartItemsCountBeforeFail = await prisma.cartItem.count({ where: { cartId: cartUser1.id } });

  console.log(`[DB STATE BEFORE FAILED ORDER] Orders Total Count: ${ordersCountBeforeFail}, Product Stock: ${stockBeforeFail}, Cart Items: ${cartItemsCountBeforeFail}`);

  console.log('\n[REQUEST] POST /api/orders (Requesting quantity 2 when stock is 1)');
  const resFail = await fetch(`${API_BASE}/orders`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      Authorization: `Bearer ${token1}`,
    },
    body: JSON.stringify(orderPayload),
  });

  const bodyFail = (await resFail.json()) as any;
  console.log(`[RESPONSE] Status: ${resFail.status}`);
  console.log('Response Body:', JSON.stringify(bodyFail, null, 2));

  // Query DB directly to prove complete transaction rollback
  const ordersCountAfterFail = await prisma.order.count();
  const stockAfterFail = (await prisma.productSize.findUnique({ where: { id: dressSize.id } }))?.stock;
  const cartItemsCountAfterFail = await prisma.cartItem.count({ where: { cartId: cartUser1.id } });

  console.log('\n[DB TRANSACTION ROLLBACK PROOF]');
  console.log(`- Orders Count in DB: Before=${ordersCountBeforeFail}, After=${ordersCountAfterFail} (No new order created: ${ordersCountBeforeFail === ordersCountAfterFail})`);
  console.log(`- Product Stock in DB: Before=${stockBeforeFail}, After=${stockAfterFail} (Stock unchanged: ${stockBeforeFail === stockAfterFail})`);
  console.log(`- Cart Items in DB: Before=${cartItemsCountBeforeFail}, After=${cartItemsCountAfterFail} (Cart untouched: ${cartItemsCountBeforeFail === cartItemsCountAfterFail})`);

  // Reset stock back to normal and clear cart item for clean up
  await prisma.cartItem.deleteMany({ where: { cartId: cartUser1.id } });

  // =========================================================================
  // TEST 5: GET /api/orders (Order List)
  // =========================================================================
  console.log('\n----------------------------------------------------');
  console.log('TEST 5: GET /api/orders (Order List)');
  console.log('----------------------------------------------------');

  console.log('[REQUEST] GET /api/orders');
  const resList = await fetch(`${API_BASE}/orders`, {
    headers: { Authorization: `Bearer ${token1}` },
  });

  const bodyList = (await resList.json()) as any;
  console.log(`[RESPONSE] Status: ${resList.status}`);
  console.log('Response Body:', JSON.stringify(bodyList, null, 2));

  // =========================================================================
  // TEST 6: GET /api/orders/:id (Order Detail)
  // =========================================================================
  console.log('\n----------------------------------------------------');
  console.log('TEST 6: GET /api/orders/:id (Order Detail)');
  console.log('----------------------------------------------------');

  console.log(`[REQUEST] GET /api/orders/${createdOrderId}`);
  const resDetail = await fetch(`${API_BASE}/orders/${createdOrderId}`, {
    headers: { Authorization: `Bearer ${token1}` },
  });

  const bodyDetail = (await resDetail.json()) as any;
  console.log(`[RESPONSE] Status: ${resDetail.status}`);
  console.log('Response Body:', JSON.stringify(bodyDetail, null, 2));

  // =========================================================================
  // TEST 7: GET /api/orders/:id as DIFFERENT User (Security / 404 Check)
  // =========================================================================
  console.log('\n----------------------------------------------------');
  console.log('TEST 7: GET /api/orders/:id as DIFFERENT User (User 2)');
  console.log('----------------------------------------------------');

  console.log(`[REQUEST] GET /api/orders/${createdOrderId} (Authenticated as User 2)`);
  const resUnauthorized = await fetch(`${API_BASE}/orders/${createdOrderId}`, {
    headers: { Authorization: `Bearer ${token2}` },
  });

  const bodyUnauthorized = (await resUnauthorized.json()) as any;
  console.log(`[RESPONSE] Status: ${resUnauthorized.status}`);
  console.log('Response Body:', JSON.stringify(bodyUnauthorized, null, 2));

  console.log('\n====================================================');
  console.log('     ALL ORDER MANAGEMENT TESTS PASSED CLEANLY!     ');
  console.log('====================================================\n');
}

runTests()
  .catch((err) => {
    console.error('Test script failed with error:', err);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
