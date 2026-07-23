import jwt from 'jsonwebtoken';

export interface TokenPayload {
  userId: string;
}

const getAccessTokenSecret = (): string => {
  return process.env.ACCESS_TOKEN_SECRET || 'default_access_secret';
};

const getRefreshTokenSecret = (): string => {
  return process.env.REFRESH_TOKEN_SECRET || 'default_refresh_secret';
};

export function generateAccessToken(userId: string): string {
  return jwt.sign({ userId }, getAccessTokenSecret(), { expiresIn: '15m' });
}

export function generateRefreshToken(userId: string): string {
  return jwt.sign({ userId }, getRefreshTokenSecret(), { expiresIn: '30d' });
}

export function verifyAccessToken(token: string): TokenPayload {
  return jwt.verify(token, getAccessTokenSecret()) as TokenPayload;
}

export function verifyRefreshToken(token: string): TokenPayload {
  return jwt.verify(token, getRefreshTokenSecret()) as TokenPayload;
}
