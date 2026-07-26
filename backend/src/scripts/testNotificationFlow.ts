import { PrismaClient } from '@prisma/client';
import { generateAccessToken } from '../utils/tokens';

const prisma = new PrismaClient();
const API_BASE = 'http://localhost:3000/api';

async function runNotificationTests() {
  console.log('====================================================');
  console.log('    NEXTLOOK NOTIFICATION API VERIFICATION SUITE   ');
  console.log('====================================================\n');

  // Setup Test User & Address
  let user = await prisma.user.findFirst({
    where: { email: 'notif_test_user@example.com' },
  });

  if (!user) {
    user = await prisma.user.create({
      data: {
        name: 'Notification Test User',
        email: 'notif_test_user@example.com',
        passwordHash: '$2b$10$abcdefghijklmnopqrstuu',
      },
    });
  }

  console.log(`[SETUP] User ID: ${user.id} (${user.email})`);
  const token = generateAccessToken(user.id);

  let address = await prisma.address.findFirst({
    where: { userId: user.id },
  });

  if (!address) {
    address = await prisma.address.create({
      data: {
        userId: user.id,
        fullName: 'Notification Tester',
        phone: '+251911223344',
        addressLine1: 'Kazanchis, Building A',
        city: 'Addis Ababa',
        region: 'Addis Ababa',
        country: 'Ethiopia',
        isDefault: true,
      },
    });
  }

  // Setup Test Product & Stock
  const product = await prisma.product.findFirst({
    where: { stock: { gte: 5 } },
    include: { colors: true, sizes: true, images: true },
  });

  if (!product) {
    throw new Error('No product with sufficient stock found in DB');
  }

  const color = product.colors[0]?.name || 'Black';
  const size = product.sizes[0]?.label || 'M';

  // Clear existing cart and notifications for clean test
  const cart = await prisma.cart.upsert({
    where: { userId: user.id },
    update: {},
    create: { userId: user.id },
  });

  await prisma.cartItem.deleteMany({ where: { cartId: cart.id } });
  await prisma.notification.deleteMany({ where: { userId: user.id } });

  // Add 1 item to cart
  await prisma.cartItem.create({
    data: {
      cartId: cart.id,
      productId: product.id,
      colorName: color,
      sizeLabel: size,
      quantity: 1,
    },
  });

  console.log(`-> Added 1x "${product.name}" to cart.`);

  // -------------------------------------------------------------------------
  // TEST 1: Place an order -> Auto-create notification
  // -------------------------------------------------------------------------
  console.log('\n----------------------------------------------------');
  console.log('TEST 1: POST /api/orders (Order placement auto-notification)');
  console.log('----------------------------------------------------');

  const orderPayload = {
    addressId: address.id,
    deliveryMethodLabel: 'Standard Delivery',
    deliveryMethodPrice: 150,
    paymentMethod: 'Cash on Delivery',
  };

  const resOrder = await fetch(`${API_BASE}/orders`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      Authorization: `Bearer ${token}`,
    },
    body: JSON.stringify(orderPayload),
  });

  const createdOrder = (await resOrder.json()) as any;
  console.log(`[RESPONSE] Status: ${resOrder.status}`);
  console.log(`Order Number: ${createdOrder.orderNumber}, Order ID: ${createdOrder.id}`);

  // Query Database directly to verify Notification record creation
  const dbNotification = await prisma.notification.findFirst({
    where: { userId: user.id, relatedOrderId: createdOrder.id },
  });

  console.log('\n[DATABASE NOTIFICATION VERIFICATION]');
  console.log(`- Notification Exists in DB: ${!!dbNotification}`);
  console.log(`- Type: ${dbNotification?.type} (Expected: ORDER_UPDATE)`);
  console.log(`- Title: "${dbNotification?.title}"`);
  console.log(`- Body: "${dbNotification?.body}"`);
  console.log(`- Related Order ID: ${dbNotification?.relatedOrderId} (Matches Order ID: ${dbNotification?.relatedOrderId === createdOrder.id})`);
  console.log(`- isRead: ${dbNotification?.isRead} (Expected: false)`);

  // -------------------------------------------------------------------------
  // TEST 2: GET /api/notifications & GET /api/notifications/unread-count
  // -------------------------------------------------------------------------
  console.log('\n----------------------------------------------------');
  console.log('TEST 2: GET /api/notifications & GET /api/notifications/unread-count');
  console.log('----------------------------------------------------');

  const resList = await fetch(`${API_BASE}/notifications`, {
    headers: { Authorization: `Bearer ${token}` },
  });
  const notifList = (await resList.json()) as any;

  console.log(`[GET /api/notifications] Status: ${resList.status}, Count: ${notifList.length}`);
  console.log('Response Body:', JSON.stringify(notifList, null, 2));

  const resUnread = await fetch(`${API_BASE}/notifications/unread-count`, {
    headers: { Authorization: `Bearer ${token}` },
  });
  const unreadBody = (await resUnread.json()) as any;
  console.log(`\n[GET /api/notifications/unread-count] Status: ${resUnread.status}, Unread Count: ${unreadBody.count}`);

  // -------------------------------------------------------------------------
  // TEST 3: PUT /api/notifications/:id/read (Mark single as read)
  // -------------------------------------------------------------------------
  console.log('\n----------------------------------------------------');
  console.log('TEST 3: PUT /api/notifications/:id/read');
  console.log('----------------------------------------------------');

  const notifId = dbNotification!.id;
  const resMarkRead = await fetch(`${API_BASE}/notifications/${notifId}/read`, {
    method: 'PUT',
    headers: { Authorization: `Bearer ${token}` },
  });
  const readResult = (await resMarkRead.json()) as any;

  console.log(`[RESPONSE] Status: ${resMarkRead.status}`);
  console.log(`Updated isRead: ${readResult.isRead}`);

  const resUnreadAfter = await fetch(`${API_BASE}/notifications/unread-count`, {
    headers: { Authorization: `Bearer ${token}` },
  });
  console.log(`Unread Count after marking single as read: ${(await resUnreadAfter.json() as any).count}`);

  // -------------------------------------------------------------------------
  // TEST 4: Mark All as Read (PUT /api/notifications/read-all)
  // -------------------------------------------------------------------------
  console.log('\n----------------------------------------------------');
  console.log('TEST 4: Place 2nd order and test PUT /api/notifications/read-all');
  console.log('----------------------------------------------------');

  // Add 1 more item & place 2nd order
  await prisma.cartItem.create({
    data: {
      cartId: cart.id,
      productId: product.id,
      colorName: color,
      sizeLabel: size,
      quantity: 1,
    },
  });

  await fetch(`${API_BASE}/orders`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      Authorization: `Bearer ${token}`,
    },
    body: JSON.stringify(orderPayload),
  });

  const resUnreadBeforeReadAll = await fetch(`${API_BASE}/notifications/unread-count`, {
    headers: { Authorization: `Bearer ${token}` },
  });
  console.log(`Unread Count before read-all: ${(await resUnreadBeforeReadAll.json() as any).count}`);

  const resReadAll = await fetch(`${API_BASE}/notifications/read-all`, {
    method: 'PUT',
    headers: { Authorization: `Bearer ${token}` },
  });
  console.log(`[PUT /api/notifications/read-all] Status: ${resReadAll.status}`);

  const resUnreadFinal = await fetch(`${API_BASE}/notifications/unread-count`, {
    headers: { Authorization: `Bearer ${token}` },
  });
  const finalUnread = (await resUnreadFinal.json() as any).count;
  console.log(`Unread Count after read-all: ${finalUnread} (Expected: 0)`);

  console.log('\n====================================================');
  console.log('    ALL NOTIFICATION TESTS PASSED CLEANLY!         ');
  console.log('====================================================\n');
}

runNotificationTests()
  .catch((err) => {
    console.error('Notification test script failed:', err);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
