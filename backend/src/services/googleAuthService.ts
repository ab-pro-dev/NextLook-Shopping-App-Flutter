import { OAuth2Client } from 'google-auth-library';

const client = new OAuth2Client();

export interface VerifiedGoogleUser {
  googleId: string;
  email: string;
  name: string;
  picture?: string;
}

/**
 * Verifies a Google ID Token signature and audience.
 * Returns verified user information extracted from token payload.
 */
export async function verifyGoogleToken(idToken: string): Promise<VerifiedGoogleUser> {
  const clientId = process.env.GOOGLE_WEB_CLIENT_ID;

  if (!clientId) {
    console.warn('[GoogleAuthService] WARNING: GOOGLE_WEB_CLIENT_ID environment variable is missing!');
  }

  try {
    const ticket = await client.verifyIdToken({
      idToken,
      audience: clientId,
    });

    const payload = ticket.getPayload();
    if (!payload) {
      throw new Error('Invalid Google ID token payload');
    }

    if (!payload.sub || !payload.email) {
      throw new Error('Google token payload missing required fields (sub, email)');
    }

    return {
      googleId: payload.sub,
      email: payload.email.toLowerCase(),
      name: payload.name || payload.email.split('@')[0],
      picture: payload.picture,
    };
  } catch (error: any) {
    console.error('[GoogleAuthService] Token verification failed:', error.message || error);
    throw new Error(`Google token verification failed: ${error.message || 'Invalid or expired token'}`);
  }
}
