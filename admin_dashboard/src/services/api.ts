import axios from 'axios';

const API_BASE_URL = import.meta.env.VITE_API_BASE_URL || 'https://nextlook-shopping-app-flutter.onrender.com';

export const api = axios.create({
  baseURL: API_BASE_URL,
  headers: {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  },
});

// Attach Authorization Bearer token to every outgoing request
api.interceptors.request.use(
  (config) => {
    const token = localStorage.getItem('accessToken');
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  },
  (error) => Promise.reject(error)
);

export interface AdminUser {
  id: string;
  name: string;
  email: string;
  avatarUrl?: string | null;
  role: 'CUSTOMER' | 'ADMIN';
}

export interface LoginResponse {
  user: AdminUser;
  accessToken: string;
  refreshToken: string;
}

/**
 * Login admin user and enforce client-side ADMIN role requirement
 */
export async function loginAdmin(email: string, password: string): Promise<AdminUser> {
  const response = await api.post<LoginResponse>('/api/auth/login', {
    email: email.trim(),
    password,
  });

  const { user, accessToken, refreshToken } = response.data;

  // CRITICAL CLIENT-SIDE ROLE GUARD:
  // Immediately reject regular customer accounts
  if (!user || user.role !== 'ADMIN') {
    localStorage.removeItem('accessToken');
    localStorage.removeItem('refreshToken');
    localStorage.removeItem('adminUser');
    throw new Error('Admin access required. Customer accounts cannot access the admin dashboard.');
  }

  // Store auth tokens and user payload
  localStorage.setItem('accessToken', accessToken);
  localStorage.setItem('refreshToken', refreshToken);
  localStorage.setItem('adminUser', JSON.stringify(user));

  return user;
}

export function logoutAdmin(): void {
  localStorage.removeItem('accessToken');
  localStorage.removeItem('refreshToken');
  localStorage.removeItem('adminUser');
  window.location.href = '/login';
}

export function getStoredAdminUser(): AdminUser | null {
  const userJson = localStorage.getItem('adminUser');
  if (!userJson) return null;
  try {
    return JSON.parse(userJson) as AdminUser;
  } catch {
    return null;
  }
}

export function isAuthenticatedAdmin(): boolean {
  const token = localStorage.getItem('accessToken');
  const user = getStoredAdminUser();
  return Boolean(token && user && user.role === 'ADMIN');
}
