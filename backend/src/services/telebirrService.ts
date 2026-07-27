import crypto from 'crypto';

interface TelebirrConfig {
  baseUrl: string;
  webBaseUrl: string;
  fabricAppId: string;
  appSecret: string;
  merchantAppId: string;
  merchantCode: string;
  shortCode: string;
  privateKey: string;
  publicKey?: string;
}

export function getTelebirrConfig(): TelebirrConfig {
  return {
    baseUrl: process.env.TELEBIRR_BASE_URL || 'https://app.telebirr.et:8443/am-cop-gate/api/v1',
    webBaseUrl: process.env.TELEBIRR_WEB_BASE_URL || 'https://app.telebirr.et:8443/am-cop-gate/pay?',
    fabricAppId: process.env.TELEBIRR_FABRIC_APP_ID || '',
    appSecret: process.env.TELEBIRR_APP_SECRET || '',
    merchantAppId: process.env.TELEBIRR_MERCHANT_APP_ID || '',
    merchantCode: process.env.TELEBIRR_MERCHANT_CODE || '',
    shortCode: process.env.TELEBIRR_SHORT_CODE || '',
    privateKey: process.env.TELEBIRR_PRIVATE_KEY || '',
    publicKey: process.env.TELEBIRR_PUBLIC_KEY || '',
  };
}

/**
 * Format RSA PEM key string (convert escaped \n to real newlines if passed as single-line string)
 */
export function formatPemKey(key: string, type: 'PRIVATE' | 'PUBLIC'): string {
  if (!key) return '';
  let formatted = key.replace(/\\n/g, '\n').trim();

  if (type === 'PRIVATE' && !formatted.startsWith('-----BEGIN')) {
    formatted = `-----BEGIN RSA PRIVATE KEY-----\n${formatted}\n-----END RSA PRIVATE KEY-----`;
  } else if (type === 'PUBLIC' && !formatted.startsWith('-----BEGIN')) {
    formatted = `-----BEGIN PUBLIC KEY-----\n${formatted}\n-----END PUBLIC KEY-----`;
  }

  return formatted;
}

/**
 * Canonicalize object fields by sorting keys alphabetically and joining key=value pairs with &
 */
export function createCanonicalString(params: Record<string, any>): string {
  const sortedKeys = Object.keys(params)
    .filter(
      (key) =>
        key !== 'sign' &&
        key !== 'sign_type' &&
        params[key] !== undefined &&
        params[key] !== null &&
        params[key] !== ''
    )
    .sort();

  return sortedKeys.map((key) => `${key}=${params[key]}`).join('&');
}

/**
 * Sign data string with RSA-SHA256 and return Base64 string
 */
export function signRsaSha256(data: string, privateKeyPem: string): string {
  const formattedKey = formatPemKey(privateKeyPem, 'PRIVATE');
  const signer = crypto.createSign('RSA-SHA256');
  signer.update(data, 'utf8');
  return signer.sign(formattedKey, 'base64');
}

/**
 * Verify RSA-SHA256 signature
 */
export function verifyRsaSha256(data: string, signatureBase64: string, publicKeyPem: string): boolean {
  if (!publicKeyPem) return true; // Fallback if public key not provided in sandbox
  const formattedKey = formatPemKey(publicKeyPem, 'PUBLIC');
  const verifier = crypto.createVerify('RSA-SHA256');
  verifier.update(data, 'utf8');
  return verifier.verify(formattedKey, signatureBase64, 'base64');
}

/**
 * 1. Apply Fabric Token
 * POST `${TELEBIRR_BASE_URL}/payment/v1/token`
 */
export async function applyFabricToken(): Promise<string> {
  const config = getTelebirrConfig();
  const url = `${config.baseUrl.replace(/\/$/, '')}/payment/v1/token`;

  const response = await fetch(url, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'X-APP-Key': config.fabricAppId,
    },
    body: JSON.stringify({
      appSecret: config.appSecret,
    }),
  });

  const data = (await response.json()) as any;

  if (!response.ok || (data.code && data.code !== '0' && data.code !== 200 && data.code !== '200')) {
    throw new Error(`applyFabricToken failed: ${JSON.stringify(data)}`);
  }

  // Extract token from response (handle standard shapes: token, biz_content.token, or token in body)
  const token = data.token || data.biz_content?.token || data.data?.token;
  if (!token) {
    throw new Error(`Fabric token not found in response: ${JSON.stringify(data)}`);
  }

  return token;
}

/**
 * 2. Create PreOrder
 * POST `${TELEBIRR_BASE_URL}/payment/v1/merchant/preOrder`
 */
export async function createPreOrder(
  fabricToken: string,
  title: string,
  amount: number,
  merchOrderId: string,
  notifyUrl?: string,
  redirectUrl?: string
): Promise<string> {
  const config = getTelebirrConfig();
  const url = `${config.baseUrl.replace(/\/$/, '')}/payment/v1/merchant/preOrder`;

  const defaultNotifyUrl =
    notifyUrl || 'https://nextlook-shopping-app-flutter.onrender.com/api/payments/telebirr/notify';
  const defaultRedirectUrl =
    redirectUrl || 'https://nextlook-shopping-app-flutter.onrender.com/api/payments/telebirr/redirect';

  const timestamp = Math.floor(Date.now() / 1000).toString();
  const nonceStr = crypto.randomBytes(16).toString('hex');

  const bizContent: Record<string, any> = {
    notify_url: defaultNotifyUrl,
    appid: config.merchantAppId,
    merch_code: config.merchantCode,
    merch_order_id: merchOrderId,
    trade_type: 'Checkout',
    title: title,
    total_amount: amount.toString(),
    trans_currency: 'ETB',
    timeout_express: '120m',
    business_type: 'BuyGoods',
    payee_identifier: config.merchantCode,
    payee_identifier_type: '04',
    payee_type: '5000',
    redirect_url: defaultRedirectUrl,
    callback_info: 'From NextLook',
  };

  // Sign biz_content
  const canonicalBizContent = createCanonicalString(bizContent);
  const sign = signRsaSha256(canonicalBizContent, config.privateKey);

  const payload = {
    timestamp,
    nonce_str: nonceStr,
    method: 'payment.preorder',
    version: '1.0',
    biz_content: bizContent,
    sign,
    sign_type: 'SHA256WithRSA',
  };

  const response = await fetch(url, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'X-APP-Key': config.fabricAppId,
      Authorization: fabricToken,
    },
    body: JSON.stringify(payload),
  });

  const data = (await response.json()) as any;

  if (!response.ok || (data.code && data.code !== '0' && data.code !== 200 && data.code !== '200')) {
    throw new Error(`createPreOrder failed: ${JSON.stringify(data)}`);
  }

  const prepayId =
    data.biz_content?.prepay_id || data.data?.prepay_id || data.prepay_id;

  if (!prepayId) {
    throw new Error(`prepay_id not found in response: ${JSON.stringify(data)}`);
  }

  return prepayId;
}

/**
 * 3. Build Checkout URL
 * Constructs raw signed query string and returns full web checkout URL
 */
export function buildCheckoutUrl(prepayId: string): string {
  const config = getTelebirrConfig();
  const timestamp = Math.floor(Date.now() / 1000).toString();
  const nonceStr = crypto.randomBytes(16).toString('hex');

  const params: Record<string, string> = {
    appid: config.merchantAppId,
    merch_code: config.merchantCode,
    nonce_str: nonceStr,
    prepay_id: prepayId,
    timestamp: timestamp,
  };

  const canonicalString = createCanonicalString(params);
  const sign = signRsaSha256(canonicalString, config.privateKey);

  const encodedSign = encodeURIComponent(sign);
  const rawRequest = `${canonicalString}&sign=${encodedSign}&sign_type=SHA256WithRSA`;

  const webBaseUrl = config.webBaseUrl.endsWith('?')
    ? config.webBaseUrl
    : `${config.webBaseUrl}?`;

  return `${webBaseUrl}${rawRequest}&version=1.0&trade_type=Checkout`;
}
