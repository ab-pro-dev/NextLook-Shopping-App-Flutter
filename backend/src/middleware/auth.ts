import { Request, Response, NextFunction } from 'express';
import { verifyAccessToken } from '../utils/tokens';

export interface AuthenticatedRequest extends Request {
  userId?: string;
}

export function authenticateToken(req: AuthenticatedRequest, res: Response, next: NextFunction) {
  const authHeader = req.headers.authorization;
  const token = authHeader && authHeader.split(' ')[1];

  if (!token) {
    return res.status(401).json({ message: 'Access token required' });
  }

  try {
    const payload = verifyAccessToken(token);
    req.userId = payload.userId;
    next();
  } catch (error) {
    return res.status(401).json({ message: 'Invalid or expired access token' });
  }
}
