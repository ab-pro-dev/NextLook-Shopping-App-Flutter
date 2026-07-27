import { Request, Response } from 'express';
import { prisma } from '../utils/prisma';
import { AuthenticatedRequest } from '../middleware/auth';
import {
  applyFabricToken,
  createPreOrder,
  buildCheckoutUrl,
  verifyRsaSha256,
  createCanonicalString,
  getTelebirrConfig,
} from '../services/telebirrService';

/**
 * POST /api/payments/telebirr/create-checkout
 * Generates Telebirr signed checkout URL for an existing Order
 */
export async function createTelebirrCheckout(req: AuthenticatedRequest, res: Response) {
  try {
    const userId = req.userId;
    const { orderId } = req.body;

    if (!orderId) {
      return res.status(400).json({ message: 'orderId is required' });
    }

    const order = await prisma.order.findFirst({
      where: { id: orderId, userId },
      include: { items: true },
    });

    if (!order) {
      return res.status(404).json({ message: 'Order not found' });
    }

    // 1. Get Fabric Token
    const fabricToken = await applyFabricToken();

    // 2. Create PreOrder
    const prepayId = await createPreOrder(
      fabricToken,
      `NextLook Order #${order.orderNumber}`,
      order.total,
      order.orderNumber
    );

    // 3. Build Checkout URL
    const checkoutUrl = buildCheckoutUrl(prepayId);

    return res.status(200).json({
      orderId: order.id,
      orderNumber: order.orderNumber,
      total: order.total,
      prepayId,
      checkoutUrl,
    });
  } catch (error: any) {
    console.error('Telebirr createCheckout error:', error);
    return res.status(500).json({
      message: 'Failed to create Telebirr payment checkout session',
      error: error.message || String(error),
    });
  }
}

/**
 * POST /api/payments/telebirr/notify
 * Webhook endpoint called by Telebirr after payment execution
 */
export async function handleTelebirrNotify(req: Request, res: Response) {
  try {
    const payload = req.body || {};
    console.log('Telebirr Notify Webhook received:', JSON.stringify(payload));

    const bizContent = payload.biz_content || payload;
    const merchOrderId = bizContent.merch_order_id || payload.merch_order_id;
    const tradeStatus = bizContent.trade_status || payload.trade_status || payload.status;
    const sign = payload.sign || bizContent.sign;

    // Optional signature verification
    const config = getTelebirrConfig();
    if (sign && config.publicKey) {
      const canonicalData = createCanonicalString(bizContent);
      const isValid = verifyRsaSha256(canonicalData, sign, config.publicKey);
      if (!isValid) {
        console.warn('Telebirr Notify signature verification failed');
      }
    }

    if (merchOrderId) {
      // Find order by orderNumber
      const order = await prisma.order.findUnique({
        where: { orderNumber: merchOrderId },
      });

      if (order) {
        await prisma.order.update({
          where: { id: order.id },
          data: {
            paymentStatus: 'PAID',
            status: order.status === 'PENDING' ? 'PROCESSING' : order.status,
            statusHistory: {
              create: {
                status: 'PROCESSING',
              },
            },
          },
        });
        console.log(`Order #${merchOrderId} payment status updated to PAID.`);
      } else {
        console.warn(`Order #${merchOrderId} not found for Telebirr notification.`);
      }
    }

    // Standard Telebirr Webhook Acknowledgment response
    return res.status(200).json({
      code: 0,
      message: 'success',
    });
  } catch (error: any) {
    console.error('Telebirr Notify Webhook error:', error);
    return res.status(500).json({
      code: 500,
      message: 'Internal server error',
    });
  }
}

/**
 * GET /api/payments/telebirr/redirect
 * Post-payment landing page redirect for user's browser
 */
export async function handleTelebirrRedirect(req: Request, res: Response) {
  const html = `
    <!DOCTYPE html>
    <html lang="en">
    <head>
      <meta charset="UTF-8">
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
      <title>NextLook - Payment Complete</title>
      <style>
        body {
          font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
          background-color: #0f172a;
          color: #f8fafc;
          display: flex;
          align-items: center;
          justify-content: center;
          height: 100vh;
          margin: 0;
          padding: 20px;
          text-align: center;
        }
        .card {
          background-color: #1e293b;
          border-radius: 16px;
          padding: 40px 30px;
          box-shadow: 0 10px 25px rgba(0,0,0,0.5);
          max-width: 400px;
          width: 100%;
        }
        .icon {
          width: 64px;
          height: 64px;
          background-color: #10b981;
          color: #ffffff;
          border-radius: 50%;
          display: flex;
          align-items: center;
          justify-content: center;
          font-size: 32px;
          margin: 0 auto 20px auto;
        }
        h1 { font-size: 24px; margin-bottom: 12px; }
        p { color: #94a3b8; font-size: 16px; line-height: 1.5; margin-bottom: 24px; }
        .btn {
          display: inline-block;
          background-color: #3b82f6;
          color: white;
          padding: 12px 24px;
          border-radius: 8px;
          text-decoration: none;
          font-weight: 600;
        }
      </style>
    </head>
    <body>
      <div class="card">
        <div class="icon">✓</div>
        <h1>Payment Complete</h1>
        <p>Thank you for your payment! You can now safely return to the <strong>NextLook</strong> app to track your order.</p>
      </div>
    </body>
    </html>
  `;
  return res.status(200).send(html);
}
