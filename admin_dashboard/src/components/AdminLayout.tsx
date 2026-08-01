import React, { useState, useEffect } from 'react';
import { NavLink, Outlet, useLocation, useNavigate } from 'react-router-dom';
import { getStoredAdminUser, logoutAdmin, checkServerHealth } from '../services/api';
import {
  LayoutDashboard,
  Package,
  ShoppingBag,
  FolderTree,
  Users,
  Tag,
  Star,
  BarChart3,
  Settings,
  User,
  LogOut,
  Search,
  Bell,
  ShieldCheck,
  Wifi,
  WifiOff,
} from 'lucide-react';

const navItems = [
  { name: 'Dashboard', path: '/', icon: LayoutDashboard, isBuilt: true },
  { name: 'Products', path: '/products', icon: Package, isBuilt: true },
  { name: 'Orders', path: '/orders', icon: ShoppingBag, isBuilt: true },
  { name: 'Categories', path: '/categories', icon: FolderTree, isBuilt: true },
  { name: 'Customers', path: '/customers', icon: Users, isBuilt: true },
  { name: 'Coupons', path: '/coupons', icon: Tag, isBuilt: false },
  { name: 'Reviews', path: '/reviews', icon: Star, isBuilt: false },
  { name: 'Reports', path: '/reports', icon: BarChart3, isBuilt: false },
  { name: 'Settings', path: '/settings', icon: Settings, isBuilt: true },
  { name: 'Profile', path: '/profile', icon: User, isBuilt: true },
];

export const AdminLayout: React.FC = () => {
  const navigate = useNavigate();
  const [adminUser, setAdminUser] = useState(getStoredAdminUser());
  const location = useLocation();

  const handleLogout = () => {
    logoutAdmin();
    navigate('/login', { replace: true });
  };
  const [isServerLive, setIsServerLive] = useState<boolean | null>(null);

  useEffect(() => {
    let isMounted = true;
    const verifyHealth = async () => {
      const live = await checkServerHealth();
      if (isMounted) {
        setIsServerLive(live);
      }
    };

    verifyHealth();
    const interval = setInterval(verifyHealth, 15000);

    const handleUserUpdate = () => {
      setAdminUser(getStoredAdminUser());
    };
    window.addEventListener('adminUserUpdated', handleUserUpdate);
    window.addEventListener('storage', handleUserUpdate);

    return () => {
      isMounted = false;
      clearInterval(interval);
      window.removeEventListener('adminUserUpdated', handleUserUpdate);
      window.removeEventListener('storage', handleUserUpdate);
    };
  }, []);

  return (
    <div className="flex min-h-screen bg-[#F5F6FA]">
      {/* Sidebar - Dark Navy #1E1E2D */}
      <aside className="w-64 bg-[#1E1E2D] text-gray-300 flex flex-col fixed inset-y-0 left-0 z-30 shadow-xl border-r border-gray-800">
        {/* Brand Header */}
        <div className="h-18 flex items-center gap-3 px-6 border-b border-gray-800/80">
          <div className="w-10 h-10 bg-[#6C63FF] rounded-xl flex items-center justify-center shadow-lg shadow-[#6C63FF]/30">
            <ShieldCheck className="w-6 h-6 text-white" />
          </div>
          <div>
            <h2 className="text-lg font-bold text-white tracking-tight m-0 leading-tight">NextLook</h2>
            <span className="text-[11px] font-medium text-[#6C63FF] uppercase tracking-wider">Admin Portal</span>
          </div>
        </div>

        {/* Nav Links */}
        <nav className="flex-1 px-3 py-4 space-y-1 overflow-y-auto">
          {navItems.map((item) => {
            const Icon = item.icon;
            const isActive =
              item.path === '/'
                ? location.pathname === '/'
                : location.pathname.startsWith(item.path);

            return (
              <NavLink
                key={item.name}
                to={item.path}
                className={`flex items-center gap-3 px-4 py-3 rounded-xl font-medium text-sm transition-all relative ${
                  isActive
                    ? 'bg-[#6C63FF] text-white shadow-lg shadow-[#6C63FF]/25 font-semibold'
                    : 'text-gray-400 hover:text-white hover:bg-gray-800/60'
                }`}
              >
                <Icon className={`w-5 h-5 ${isActive ? 'text-white' : 'text-gray-400'}`} />
                <span className="flex-1">{item.name}</span>
                {!item.isBuilt && (
                  <span className="text-[10px] bg-gray-800 text-gray-400 px-2 py-0.5 rounded-full border border-gray-700">
                    Soon
                  </span>
                )}
              </NavLink>
            );
          })}
        </nav>

        {/* Logout Button */}
        <div className="p-4 border-t border-gray-800">
          <button
            onClick={handleLogout}
            className="w-full flex items-center gap-3 px-4 py-3 rounded-xl text-sm font-medium text-red-400 hover:text-white hover:bg-red-500/20 transition-all cursor-pointer"
          >
            <LogOut className="w-5 h-5 text-red-400" />
            <span>Log Out</span>
          </button>
        </div>
      </aside>

      {/* Main Content Area */}
      <div className="flex-1 pl-64 flex flex-col min-w-0">
        {/* Top Navigation Bar */}
        <header className="h-18 bg-white border-b border-gray-200/80 px-8 flex items-center justify-between sticky top-0 z-20 shadow-xs">
          {/* Search Placeholder */}
          <div className="relative w-80">
            <Search className="w-4 h-4 text-gray-400 absolute left-3.5 top-1/2 -translate-y-1/2" />
            <input
              type="text"
              placeholder="Search products, orders, customers..."
              className="w-full pl-10 pr-4 py-2 bg-gray-50 border border-gray-200 rounded-xl text-sm text-gray-700 focus:outline-none focus:ring-2 focus:ring-[#6C63FF] focus:bg-white transition-all"
            />
          </div>

          {/* Admin Header Right Section */}
          <div className="flex items-center gap-5">
            {/* Real Server Health Indicator Badge */}
            <div className="hidden md:flex items-center gap-2">
              {isServerLive === true && (
                <span className="px-3 py-1 bg-emerald-50 text-[#22C55E] border border-emerald-200 rounded-full text-xs font-semibold flex items-center gap-1.5 shadow-xs">
                  <Wifi className="w-3.5 h-3.5" />
                  Live Server Active
                </span>
              )}
              {isServerLive === false && (
                <span className="px-3 py-1 bg-red-50 text-red-600 border border-red-200 rounded-full text-xs font-semibold flex items-center gap-1.5 shadow-xs animate-pulse">
                  <WifiOff className="w-3.5 h-3.5" />
                  Server Offline
                </span>
              )}
              {isServerLive === null && (
                <span className="px-3 py-1 bg-gray-100 text-gray-500 border border-gray-200 rounded-full text-xs font-semibold flex items-center gap-1.5">
                  Checking Server...
                </span>
              )}
            </div>

            <button className="relative p-2 text-gray-400 hover:text-gray-600 rounded-xl hover:bg-gray-100 transition-all cursor-pointer">
              <Bell className="w-5 h-5" />
              <span className="w-2 h-2 bg-[#FF6584] rounded-full absolute top-2 right-2 ring-2 ring-white" />
            </button>

            <div className="h-8 w-px bg-gray-200" />

            <div className="flex items-center gap-3">
              {adminUser?.avatarUrl ? (
                <img
                  src={adminUser.avatarUrl}
                  alt={adminUser.name || 'Admin'}
                  className="w-10 h-10 rounded-full object-cover border border-[#6C63FF]/30 shadow-md"
                />
              ) : (
                <div className="w-10 h-10 bg-gradient-to-tr from-[#6C63FF] to-[#8B85FF] rounded-full flex items-center justify-center text-white font-bold shadow-md shadow-[#6C63FF]/20">
                  {adminUser?.name ? adminUser.name.charAt(0).toUpperCase() : 'A'}
                </div>
              )}
              <div className="hidden sm:block text-left">
                <div className="text-sm font-semibold text-gray-900 leading-tight">
                  {adminUser?.name || 'System Admin'}
                </div>
                <div className="text-xs font-medium text-[#6C63FF] flex items-center gap-1 mt-0.5">
                  <span className="w-1.5 h-1.5 bg-[#22C55E] rounded-full inline-block" />
                  {adminUser?.role || 'ADMIN'}
                </div>
              </div>
            </div>
          </div>
        </header>

        {/* Page Content Outlet */}
        <main className="flex-1 p-8">
          <Outlet />
        </main>
      </div>
    </div>
  );
};
