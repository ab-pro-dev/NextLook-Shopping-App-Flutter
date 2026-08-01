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

// Intercept 401 Unauthorized responses to auto-logout and redirect to /login
api.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response && error.response.status === 401) {
      logoutAdmin('Session expired. Please log in again.');
      if (window.location.pathname !== '/login') {
        window.location.href = '/login';
      }
    }
    return Promise.reject(error);
  }
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

export interface DashboardStatsResponse {
  totalRevenue: number;
  totalOrders: number;
  activeProducts: number;
  totalCategories: number;
  totalCustomers: number;
  revenueByMonth: Array<{ month: string; revenue: number }>;
  salesByCategory: Array<{ category: string; unitsSold: number }>;
}

export interface ProductImage {
  id?: string;
  url: string;
  sortOrder: number;
}

export interface ProductColor {
  id?: string;
  name: string;
  hexCode: string;
}

export interface ProductSize {
  id?: string;
  label: string;
  stock: number;
}

export interface AdminProduct {
  id: string;
  name: string;
  description: string;
  brand: string;
  categoryId: string;
  categoryName: string;
  categorySlug?: string;
  price: number;
  discountPrice: number | null;
  stock: number;
  sku: string;
  weight?: number | null;
  rating?: number;
  reviewCount?: number;
  thumbnailUrl: string;
  isFlashSale: boolean;
  isNewArrival: boolean;
  isTrending: boolean;
  isBestSeller: boolean;
  images: ProductImage[];
  colors: ProductColor[];
  sizes: ProductSize[];
  createdAt: string;
  updatedAt: string;
}

export interface Category {
  id: string;
  name: string;
  slug: string;
  iconName: string;
  productCount?: number;
}

export interface ProductPayload {
  name: string;
  description: string;
  brand: string;
  categoryId: string;
  price: number;
  discountPrice?: number | null;
  sku: string;
  weight?: number | null;
  isFlashSale: boolean;
  isNewArrival: boolean;
  isTrending: boolean;
  isBestSeller: boolean;
  images: { url: string; sortOrder: number }[];
  colors: { name: string; hexCode: string }[];
  sizes: { label: string; stock: number }[];
}

export type OrderStatusType =
  | 'PENDING'
  | 'PROCESSING'
  | 'SHIPPED'
  | 'OUT_FOR_DELIVERY'
  | 'DELIVERED'
  | 'CANCELLED';

export interface OrderItem {
  id: string;
  productId: string;
  productName: string;
  productThumbnailUrl: string;
  colorName: string;
  sizeLabel: string;
  quantity: number;
  unitPrice: number;
  lineTotal: number;
}

export interface OrderStatusHistoryItem {
  id: string;
  status: OrderStatusType;
  createdAt: string;
}

export interface AdminOrderListItem {
  id: string;
  orderNumber: string;
  customerName: string;
  customerEmail: string;
  status: OrderStatusType;
  paymentStatus: 'PENDING' | 'PAID' | 'FAILED';
  paymentMethod: string;
  total: number;
  itemCount: number;
  createdAt: string;
}

export interface AdminOrderDetail extends AdminOrderListItem {
  subtotal: number;
  shippingCost: number;
  tax: number;
  deliveryMethodLabel: string;
  shippingFullName: string;
  shippingPhone: string;
  shippingAddressLine1: string;
  shippingAddressLine2?: string | null;
  shippingCity: string;
  shippingRegion: string;
  shippingCountry: string;
  items: OrderItem[];
  statusHistory: OrderStatusHistoryItem[];
  allowedNextStatuses: OrderStatusType[];
}

export interface CustomerAddress {
  id: string;
  fullName: string;
  phone: string;
  addressLine1: string;
  addressLine2?: string | null;
  city: string;
  region: string;
  country: string;
  isDefault: boolean;
}

export interface AdminCustomerListItem {
  id: string;
  name: string;
  email: string;
  avatarUrl?: string | null;
  role: 'CUSTOMER';
  createdAt: string;
  totalOrdersCount: number;
  totalSpent: number;
  lastOrderDate: string | null;
}

export interface AdminCustomerDetail extends AdminCustomerListItem {
  addresses: CustomerAddress[];
  orders: AdminOrderDetail[];
}

/**
 * Login admin user via Google ID Token and enforce client-side ADMIN role requirement
 */
export async function loginAdminWithGoogle(idToken: string): Promise<AdminUser> {
  const response = await api.post<LoginResponse>('/api/auth/google', {
    idToken,
  });

  const { user, accessToken, refreshToken } = response.data;

  // CRITICAL CLIENT-SIDE ROLE GUARD:
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

/**
 * Login admin user and enforce client-side ADMIN role requirement (legacy)
 */
export async function loginAdmin(email: string, password: string): Promise<AdminUser> {
  const response = await api.post<LoginResponse>('/api/auth/admin-login', {
    email: email.trim(),
    password,
  });

  const { user, accessToken, refreshToken } = response.data;

  // CRITICAL CLIENT-SIDE ROLE GUARD:
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

export function isJwtExpired(token: string): boolean {
  try {
    const parts = token.split('.');
    if (parts.length !== 3) return true;
    const payload = JSON.parse(atob(parts[1]));
    if (!payload.exp) return false;
    return payload.exp * 1000 < Date.now();
  } catch {
    return true;
  }
}

export function logoutAdmin(reason?: string): void {
  localStorage.removeItem('accessToken');
  localStorage.removeItem('refreshToken');
  localStorage.removeItem('adminUser');
  localStorage.removeItem('lastActivityTime');
  if (reason) {
    sessionStorage.setItem('logoutReason', reason);
  }
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
  if (!token || !user || user.role !== 'ADMIN') return false;

  if (isJwtExpired(token)) {
    const refreshToken = localStorage.getItem('refreshToken');
    if (!refreshToken || isJwtExpired(refreshToken)) {
      logoutAdmin('Your session has expired. Please log in again.');
      return false;
    }
  }

  return true;
}

/**
 * Fetch real dashboard stats from backend
 */
export async function fetchDashboardStats(): Promise<DashboardStatsResponse> {
  const response = await api.get<DashboardStatsResponse>('/api/admin/dashboard-stats');
  return response.data;
}

/**
 * Check backend health status
 */
export async function checkServerHealth(): Promise<boolean> {
  try {
    const response = await api.get('/health', { timeout: 4000 });
    return response.status === 200 && response.data?.status === 'ok';
  } catch {
    return false;
  }
}

/**
 * Admin Product API Services
 */
export async function fetchAdminProducts(): Promise<AdminProduct[]> {
  const response = await api.get<AdminProduct[]>('/api/admin/products');
  return response.data;
}

export async function fetchAdminProductById(id: string): Promise<AdminProduct> {
  const response = await api.get<AdminProduct>(`/api/admin/products/${id}`);
  return response.data;
}

export async function createAdminProduct(payload: ProductPayload): Promise<AdminProduct> {
  const response = await api.post<AdminProduct>('/api/admin/products', payload);
  return response.data;
}

export async function updateAdminProduct(id: string, payload: ProductPayload): Promise<AdminProduct> {
  const response = await api.put<AdminProduct>(`/api/admin/products/${id}`, payload);
  return response.data;
}

export async function deleteAdminProduct(id: string): Promise<void> {
  await api.delete(`/api/admin/products/${id}`);
}

export async function updateAdminProductStock(id: string, sizeLabel: string, stock: number): Promise<any> {
  const response = await api.put(`/api/admin/products/${id}/stock`, { sizeLabel, stock });
  return response.data;
}

export async function fetchCategories(): Promise<Category[]> {
  const response = await api.get<Category[]>('/api/categories');
  return response.data;
}

/**
 * Admin Category API Services
 */
export async function fetchAdminCategories(): Promise<Category[]> {
  const response = await api.get<Category[]>('/api/admin/categories');
  return response.data;
}

export async function createAdminCategory(payload: { name: string; slug?: string; iconName?: string }): Promise<Category> {
  const response = await api.post<Category>('/api/admin/categories', payload);
  return response.data;
}

export async function updateAdminCategory(id: string, payload: { name?: string; slug?: string; iconName?: string }): Promise<Category> {
  const response = await api.put<Category>(`/api/admin/categories/${id}`, payload);
  return response.data;
}

export async function deleteAdminCategory(id: string): Promise<void> {
  await api.delete(`/api/admin/categories/${id}`);
}

/**
 * Admin Order API Services
 */
export async function fetchAdminOrders(status?: string, search?: string): Promise<AdminOrderListItem[]> {
  const params: any = {};
  if (status && status !== 'ALL') params.status = status;
  if (search && search.trim() !== '') params.search = search.trim();
  const response = await api.get<AdminOrderListItem[]>('/api/admin/orders', { params });
  return response.data;
}

export async function fetchAdminOrderById(id: string): Promise<AdminOrderDetail> {
  const response = await api.get<AdminOrderDetail>(`/api/admin/orders/${id}`);
  return response.data;
}

export async function updateAdminOrderStatus(id: string, status: OrderStatusType): Promise<AdminOrderDetail> {
  const response = await api.put<AdminOrderDetail>(`/api/admin/orders/${id}/status`, { status });
  return response.data;
}

/**
 * Admin Customer API Services (Read-Only View)
 */
export async function fetchAdminCustomers(search?: string): Promise<AdminCustomerListItem[]> {
  const params: any = {};
  if (search && search.trim() !== '') params.search = search.trim();
  const response = await api.get<AdminCustomerListItem[]>('/api/admin/customers', { params });
  return response.data;
}

export async function fetchAdminCustomerById(id: string): Promise<AdminCustomerDetail> {
  const response = await api.get<AdminCustomerDetail>(`/api/admin/customers/${id}`);
  return response.data;
}

/**
 * Admin Image Upload Services (Cloudinary)
 */
export interface UploadImageResponse {
  url: string;
  publicId: string;
}

export async function uploadAdminImage(file: File, folder: 'avatars' | 'products' | 'banners' = 'products'): Promise<UploadImageResponse> {
  const formData = new FormData();
  formData.append('image', file);
  formData.append('folder', folder);

  const response = await api.post<UploadImageResponse>('/api/admin/upload/image', formData, {
    headers: {
      'Content-Type': 'multipart/form-data',
    },
  });

  return response.data;
}

export async function deleteAdminImage(publicId: string): Promise<void> {
  await api.delete('/api/admin/upload/image', { data: { publicId } });
}

/**
 * Admin Profile & Password API Services
 */
export interface UpdateProfilePayload {
  name?: string;
  avatarUrl?: string;
}

export async function fetchCurrentAdminUser(): Promise<AdminUser> {
  const response = await api.get<{ user: AdminUser }>('/api/auth/me');
  return response.data.user;
}

export async function updateAdminProfile(payload: UpdateProfilePayload): Promise<AdminUser> {
  const response = await api.put<{ user: AdminUser }>('/api/auth/me', payload);
  return response.data.user;
}

export async function changeAdminPassword(payload: { currentPassword: string; newPassword: string }): Promise<void> {
  await api.put('/api/auth/me/password', payload);
}

/**
 * Admin Banner API Services
 */
export interface AdminBanner {
  id: string;
  imageUrl: string;
  title: string;
  subtitle?: string | null;
  buttonText?: string | null;
  categorySlug?: string | null;
  targetProductId?: string | null;
  sortOrder: number;
  isActive: boolean;
  createdAt: string;
  updatedAt: string;
}

export interface BannerPayload {
  title: string;
  imageUrl: string;
  subtitle?: string | null;
  buttonText?: string | null;
  categorySlug?: string | null;
  targetProductId?: string | null;
  sortOrder: number;
  isActive: boolean;
}

export async function fetchAdminBanners(): Promise<AdminBanner[]> {
  const response = await api.get<AdminBanner[]>('/api/admin/banners');
  return response.data;
}

export async function createAdminBanner(payload: BannerPayload): Promise<AdminBanner> {
  const response = await api.post<AdminBanner>('/api/admin/banners', payload);
  return response.data;
}

export async function updateAdminBanner(id: string, payload: Partial<BannerPayload>): Promise<AdminBanner> {
  const response = await api.put<AdminBanner>(`/api/admin/banners/${id}`, payload);
  return response.data;
}

export async function deleteAdminBanner(id: string): Promise<void> {
  await api.delete(`/api/admin/banners/${id}`);
}
