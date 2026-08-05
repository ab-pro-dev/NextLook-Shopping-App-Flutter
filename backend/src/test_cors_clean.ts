const LIVE_URL = 'https://nextlook-shopping-app-flutter.onrender.com';

async function testCorsClean() {
  console.log('--- TESTING CORS CLEAN REJECTION AFTER FIX ---');

  // Test 1: Disallowed Origin
  const disallowedRes = await fetch(`${LIVE_URL}/api/categories`, {
    method: 'OPTIONS',
    headers: {
      'Origin': 'https://evil-example.com',
      'Access-Control-Request-Method': 'GET',
    },
  });

  const disallowedAao = disallowedRes.headers.get('access-control-allow-origin');
  console.log(`Disallowed Origin Status: ${disallowedRes.status}`);
  console.log(`Disallowed Access-Control-Allow-Origin: ${disallowedAao ?? '(NONE / OMITTED)'}`);

  // Test 2: Allowed Origin
  const allowedRes = await fetch(`${LIVE_URL}/api/categories`, {
    method: 'OPTIONS',
    headers: {
      'Origin': 'https://nextlook-admin-dashboard.onrender.com',
      'Access-Control-Request-Method': 'GET',
    },
  });

  const allowedAao = allowedRes.headers.get('access-control-allow-origin');
  console.log(`Allowed Origin Status: ${allowedRes.status}`);
  console.log(`Allowed Access-Control-Allow-Origin: ${allowedAao}`);

  if (disallowedRes.status !== 500 && (!disallowedAao || disallowedAao !== 'https://evil-example.com') && allowedAao === 'https://nextlook-admin-dashboard.onrender.com') {
    console.log('SUCCESS: CORS clean rejection verified! No 500 error, origin cleanly rejected!');
  } else {
    console.log('FAIL or pending deploy');
  }
}

testCorsClean();
