import { Request, Response } from 'express';
import { prisma } from '../utils/prisma';
import { generateAccessToken, generateRefreshToken, verifyAccessToken, verifyRefreshToken } from '../utils/tokens';
import { refreshTokenSchema, updateProfileSchema, changePasswordSchema, adminLoginSchema } from '../utils/validation';
import { comparePassword, hashPassword } from '../utils/password';
import { AuthenticatedRequest } from '../middleware/auth';
import { verifyGoogleToken } from '../services/googleAuthService';
import { Role } from '@prisma/client';

/**
 * POST /api/auth/google
 * Body: { idToken }
 * Authenticates or registers a user via Google ID Token.
 */
export async function googleAuth(req: Request, res: Response) {
  try {
    const { idToken } = req.body;

    if (!idToken || typeof idToken !== 'string') {
      return res.status(400).json({ message: 'idToken is required' });
    }

    const googleUser = await verifyGoogleToken(idToken);
    const normalizedEmail = googleUser.email.toLowerCase();

    // Check runtime ADMIN_EMAIL configuration
    const adminEmail = (process.env.ADMIN_EMAIL || process.env.ADMIN_SEED_EMAIL || '').toLowerCase();
    if (!adminEmail) {
      console.warn('[GoogleAuth] WARNING: ADMIN_EMAIL environment variable is unset!');
    }

    let user = await prisma.user.findUnique({
      where: { email: normalizedEmail },
    });

    if (user) {
      // Existing user found by email -> Link account if googleId is null
      if (!user.googleId || (googleUser.picture && !user.avatarUrl)) {
        user = await prisma.user.update({
          where: { id: user.id },
          data: {
            googleId: user.googleId ?? googleUser.googleId,
            avatarUrl: user.avatarUrl ?? googleUser.picture,
          },
        });
      }
      // PRESERVE existing user.role!
    } else {
      // New user -> Determine role based on ADMIN_EMAIL match
      const isAdminEmailMatch = adminEmail.length > 0 && normalizedEmail === adminEmail;
      const role = isAdminEmailMatch ? Role.ADMIN : Role.CUSTOMER;

      user = await prisma.user.create({
        data: {
          googleId: googleUser.googleId,
          email: normalizedEmail,
          name: googleUser.name,
          avatarUrl: googleUser.picture,
          role,
        },
      });
    }

    const accessToken = generateAccessToken(user.id);
    const refreshToken = generateRefreshToken(user.id);

    const { passwordHash: _, ...userWithoutPassword } = user;

    return res.status(200).json({
      user: userWithoutPassword,
      accessToken,
      refreshToken,
    });
  } catch (error: any) {
    console.error('Error in googleAuth:', error.message || error);
    return res.status(401).json({ message: error.message || 'Google authentication failed' });
  }
}

/**
 * POST /api/auth/refresh
 * Refresh access token using valid refresh token
 */
export async function refresh(req: Request, res: Response) {
  try {
    const parseResult = refreshTokenSchema.safeParse(req.body);
    if (!parseResult.success) {
      return res.status(400).json({
        message: 'Validation failed',
        errors: parseResult.error.issues,
      });
    }

    const { refreshToken } = parseResult.data;

    let payload;
    try {
      payload = verifyRefreshToken(refreshToken);
    } catch (error) {
      return res.status(401).json({ message: 'Invalid or expired refresh token' });
    }

    const user = await prisma.user.findUnique({
      where: { id: payload.userId },
    });

    if (!user) {
      return res.status(401).json({ message: 'Invalid or expired refresh token' });
    }

    const newAccessToken = generateAccessToken(user.id);

    return res.status(200).json({
      accessToken: newAccessToken,
    });
  } catch (error) {
    console.error('Error in refresh:', error);
    return res.status(500).json({ message: 'Internal server error' });
  }
}

/**
 * GET /api/auth/me
 * Return current authenticated user profile
 */
export async function me(req: AuthenticatedRequest, res: Response) {
  try {
    let userId = req.userId;

    if (!userId) {
      const authHeader = req.headers.authorization;
      const token = authHeader && authHeader.split(' ')[1];

      if (!token) {
        return res.status(401).json({ message: 'Access token required' });
      }

      try {
        const payload = verifyAccessToken(token);
        userId = payload.userId;
      } catch (error) {
        return res.status(401).json({ message: 'Invalid or expired access token' });
      }
    }

    const user = await prisma.user.findUnique({
      where: { id: userId },
    });

    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    const { passwordHash: _, ...userWithoutPassword } = user;

    return res.status(200).json({
      user: userWithoutPassword,
    });
  } catch (error) {
    console.error('Error in me:', error);
    return res.status(500).json({ message: 'Internal server error' });
  }
}

/**
 * PUT /api/auth/me
 * Update current authenticated user profile (name, avatarUrl)
 */
export async function updateProfile(req: AuthenticatedRequest, res: Response) {
  try {
    const userId = req.userId;
    if (!userId) {
      return res.status(401).json({ message: 'Authentication required' });
    }

    const parseResult = updateProfileSchema.safeParse(req.body);
    if (!parseResult.success) {
      const errorMessage = parseResult.error.issues.map((i) => i.message).join(', ');
      return res.status(400).json({
        message: errorMessage || 'Validation failed',
        errors: parseResult.error.issues,
      });
    }

    const { name, avatarUrl } = parseResult.data;

    const updateData: { name?: string; avatarUrl?: string } = {};
    if (name !== undefined) updateData.name = name;
    if (avatarUrl !== undefined) updateData.avatarUrl = avatarUrl;

    const updatedUser = await prisma.user.update({
      where: { id: userId },
      data: updateData,
    });

    const { passwordHash: _, ...userWithoutPassword } = updatedUser;

    return res.status(200).json({
      user: userWithoutPassword,
    });
  } catch (error: any) {
    console.error('Error in updateProfile:', error);
    return res.status(500).json({ message: 'Internal server error' });
  }
}

/**
 * PUT /api/auth/me/password
 * Change password for authenticated user
 */
export async function changePassword(req: AuthenticatedRequest, res: Response) {
  try {
    const userId = req.userId;
    if (!userId) {
      return res.status(401).json({ message: 'Authentication required' });
    }

    const parseResult = changePasswordSchema.safeParse(req.body);
    if (!parseResult.success) {
      const errorMessage = parseResult.error.issues.map((i) => i.message).join(', ');
      return res.status(400).json({
        message: errorMessage || 'Validation failed',
        errors: parseResult.error.issues,
      });
    }

    const { currentPassword, newPassword } = parseResult.data;

    const user = await prisma.user.findUnique({
      where: { id: userId },
    });

    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    if (!user.passwordHash) {
      return res.status(400).json({ message: 'Password login is not enabled for this account' });
    }

    const isMatch = await comparePassword(currentPassword, user.passwordHash);
    if (!isMatch) {
      return res.status(401).json({ message: 'Current password is incorrect' });
    }

    const newHashedPassword = await hashPassword(newPassword);

    await prisma.user.update({
      where: { id: userId },
      data: { passwordHash: newHashedPassword },
    });

    return res.status(200).json({ message: 'Password changed successfully' });
  } catch (error: any) {
    console.error('Error in changePassword:', error);
    return res.status(500).json({ message: 'Internal server error' });
  }
}

/**
 * POST /api/auth/admin-login
 * Body: { email, password }
 * Authenticates an Admin user using email and password.
 * Returns generic "Invalid credentials" error for any failure.
 */
export async function adminLogin(req: Request, res: Response) {
  try {
    const parseResult = adminLoginSchema.safeParse(req.body);
    if (!parseResult.success) {
      return res.status(401).json({ message: 'Invalid credentials' });
    }

    const { email, password } = parseResult.data;
    const normalizedEmail = email.toLowerCase().trim();

    const user = await prisma.user.findUnique({
      where: { email: normalizedEmail },
    });

    // Check: user exists, is ADMIN, has passwordHash, and password matches
    if (!user || user.role !== Role.ADMIN || !user.passwordHash) {
      return res.status(401).json({ message: 'Invalid credentials' });
    }

    const isMatch = await comparePassword(password, user.passwordHash);
    if (!isMatch) {
      return res.status(401).json({ message: 'Invalid credentials' });
    }

    const accessToken = generateAccessToken(user.id);
    const refreshToken = generateRefreshToken(user.id);

    const { passwordHash: _, ...userWithoutPassword } = user;

    return res.status(200).json({
      user: userWithoutPassword,
      accessToken,
      refreshToken,
    });
  } catch (error: any) {
    console.error('Error in adminLogin:', error);
    return res.status(401).json({ message: 'Invalid credentials' });
  }
}

