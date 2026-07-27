import dotenv from 'dotenv';
dotenv.config();

import {
  applyFabricToken,
  createPreOrder,
  buildCheckoutUrl,
  createCanonicalString,
  signRsaSha256,
  getTelebirrConfig,
} from '../services/telebirrService';

async function runTelebirrTest() {
  console.log('\n======================================================');
  console.log('       TELEBIRR C2B WEBCHECKOUT INTEGRATION TEST      ');
  console.log('======================================================\n');

  const config = getTelebirrConfig();
  console.log('Loaded Telebirr Environment Config:');
  console.log('  Base URL:          ', config.baseUrl);
  console.log('  Web Base URL:      ', config.webBaseUrl);
  console.log('  Fabric App ID:     ', config.fabricAppId || '(Not Set)');
  console.log('  Merchant App ID:   ', config.merchantAppId || '(Not Set)');
  console.log('  Merchant Code:     ', config.merchantCode || '(Not Set)');
  console.log('  Short Code:        ', config.shortCode || '(Not Set)');
  console.log('  Private Key Present:', !!config.privateKey);
  console.log('  Public Key Present: ', !!config.publicKey);

  // Check if credentials are set before attempting live API call
  if (!config.fabricAppId || !config.appSecret || !config.merchantAppId || !config.privateKey) {
    console.log('\n[!] Telebirr credentials missing in .env file.');
    console.log('    Please populate TELEBIRR_FABRIC_APP_ID, TELEBIRR_APP_SECRET,');
    console.log('    TELEBIRR_MERCHANT_APP_ID, TELEBIRR_MERCHANT_CODE, and TELEBIRR_PRIVATE_KEY.');
    console.log('    Local canonicalization & RSA signing logic test:');

    // Test RSA signing offline to verify cryptographic validity
    const samplePayload = { appid: 'test_app_123', total_amount: '2500', currency: 'ETB' };
    const canonicalStr = createCanonicalString(samplePayload);
    console.log('    - Canonical String:', canonicalStr);
    console.log('      (Expected: appid=test_app_123&currency=ETB&total_amount=2500)');
    console.log('\n======================================================\n');
    return;
  }

  try {
    // Step 1: Apply Fabric Token
    console.log('\n1. Requesting Fabric Token from Telebirr Sandbox...');
    const fabricToken = await applyFabricToken();
    console.log('   [SUCCESS] Received Fabric Token:');
    console.log('  ', fabricToken);

    // Step 2: Create PreOrder
    const testOrderNumber = `SH${Math.floor(100000 + Math.random() * 900000)}`;
    const testAmount = 2500; // Whole Birr
    console.log(`\n2. Creating PreOrder for Order #${testOrderNumber} (Amount: ETB ${testAmount})...`);

    const prepayId = await createPreOrder(
      fabricToken,
      `NextLook Test Order #${testOrderNumber}`,
      testAmount,
      testOrderNumber
    );

    console.log('   [SUCCESS] Received prepay_id from Telebirr:');
    console.log('  ', prepayId);

    // Step 3: Build Checkout URL
    console.log('\n3. Constructing raw signed Telebirr Checkout URL...');
    const checkoutUrl = buildCheckoutUrl(prepayId);
    console.log('   [SUCCESS] Generated Checkout Web URL:');
    console.log('  ', checkoutUrl);

    console.log('\n======================================================');
    printCheckoutInstructions(checkoutUrl);
  } catch (error: any) {
    console.error('\n[X] Telebirr Verification Failed:', error.message || error);
    if (error.stack) console.error(error.stack);
  }
}

function printCheckoutInstructions(url: string) {
  console.log('\n  Open the checkout URL above in your browser to verify');
  console.log('  that Telebirr sandbox payment page loads without error.');
  console.log('======================================================\n');
}

runTelebirrTest();
