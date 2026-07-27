import React, { useEffect, useState } from 'react';
import { fetchDashboardStats, type DashboardStatsResponse } from '../services/api';
import {
  DollarSign,
  ShoppingBag,
  Package,
  Users,
  FolderTree,
  ArrowUpRight,
  Loader2,
  AlertCircle,
} from 'lucide-react';
import {
  AreaChart,
  Area,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  ResponsiveContainer,
  BarChart,
  Bar,
} from 'recharts';

export const DashboardPage: React.FC = () => {
  const [stats, setStats] = useState<DashboardStatsResponse | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    let isMounted = true;
    const loadStats = async () => {
      try {
        setLoading(true);
        setError(null);
        const data = await fetchDashboardStats();
        if (isMounted) {
          setStats(data);
        }
      } catch (err: any) {
        console.error('Failed to fetch dashboard stats:', err);
        if (isMounted) {
          setError(err.response?.data?.message || err.message || 'Failed to load dashboard metrics');
        }
      } finally {
        if (isMounted) {
          setLoading(false);
        }
      }
    };

    loadStats();
    return () => {
      isMounted = false;
    };
  }, []);

  if (loading) {
    return (
      <div className="min-h-[400px] flex flex-col items-center justify-center p-12 text-center space-y-4">
        <Loader2 className="w-10 h-10 text-[#6C63FF] animate-spin" />
        <p className="text-gray-500 font-medium text-sm">Querying real database metrics...</p>
      </div>
    );
  }

  if (error || !stats) {
    return (
      <div className="bg-red-50 border border-red-200 p-6 rounded-2xl text-red-700 flex items-start gap-4 max-w-2xl mx-auto my-8">
        <AlertCircle className="w-6 h-6 text-red-500 shrink-0 mt-0.5" />
        <div>
          <h3 className="font-bold text-base m-0">Failed to Load Dashboard Stats</h3>
          <p className="text-sm mt-1">{error || 'Unable to connect to the backend stats service.'}</p>
          <button
            onClick={() => window.location.reload()}
            className="mt-4 px-4 py-2 bg-red-600 text-white font-semibold rounded-xl text-xs hover:bg-red-700 transition-all cursor-pointer"
          >
            Retry Loading
          </button>
        </div>
      </div>
    );
  }

  return (
    <div className="space-y-8">
      {/* Welcome Banner */}
      <div className="flex flex-col md:flex-row md:items-center md:justify-between gap-4 bg-gradient-to-r from-[#1E1E2D] to-[#2D2D44] p-6 rounded-2xl text-white shadow-lg">
        <div>
          <h1 className="text-2xl font-bold text-white m-0">Welcome back, Admin 👋</h1>
          <p className="text-gray-400 text-sm mt-1">Real-time database metrics for NextLook store.</p>
        </div>
        <div className="flex items-center gap-3">
          <span className="text-xs bg-[#6C63FF]/20 text-white px-3.5 py-1.5 rounded-full font-medium border border-[#6C63FF]/40">
            {stats.totalCategories} Active Categories
          </span>
        </div>
      </div>

      {/* Real Metric Cards Grid */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6">
        {/* Card 1: Total Revenue */}
        <div className="bg-white p-6 rounded-2xl border border-gray-100 shadow-xs flex items-center justify-between">
          <div>
            <span className="text-xs font-semibold text-gray-500 uppercase tracking-wider">Total Revenue</span>
            <div className="text-2xl font-bold text-gray-900 mt-2">
              ETB {stats.totalRevenue.toLocaleString()}
            </div>
            <div className="text-xs text-gray-400 mt-2">Non-cancelled orders sum</div>
          </div>
          <div className="w-12 h-12 bg-[#6C63FF]/10 text-[#6C63FF] rounded-2xl flex items-center justify-center">
            <DollarSign className="w-6 h-6" />
          </div>
        </div>

        {/* Card 2: Total Orders */}
        <div className="bg-white p-6 rounded-2xl border border-gray-100 shadow-xs flex items-center justify-between">
          <div>
            <span className="text-xs font-semibold text-gray-500 uppercase tracking-wider">Total Orders</span>
            <div className="text-2xl font-bold text-gray-900 mt-2">
              {stats.totalOrders}
            </div>
            <div className="text-xs text-gray-400 mt-2">All time customer orders</div>
          </div>
          <div className="w-12 h-12 bg-blue-50 text-blue-600 rounded-2xl flex items-center justify-center">
            <ShoppingBag className="w-6 h-6" />
          </div>
        </div>

        {/* Card 3: Active Products */}
        <div className="bg-white p-6 rounded-2xl border border-gray-100 shadow-xs flex items-center justify-between">
          <div>
            <span className="text-xs font-semibold text-gray-500 uppercase tracking-wider">Active Products</span>
            <div className="text-2xl font-bold text-gray-900 mt-2">
              {stats.activeProducts}
            </div>
            <div className="text-xs text-gray-400 mt-2">In catalog database</div>
          </div>
          <div className="w-12 h-12 bg-[#FF6584]/10 text-[#FF6584] rounded-2xl flex items-center justify-center">
            <Package className="w-6 h-6" />
          </div>
        </div>

        {/* Card 4: Total Customers */}
        <div className="bg-white p-6 rounded-2xl border border-gray-100 shadow-xs flex items-center justify-between">
          <div>
            <span className="text-xs font-semibold text-gray-500 uppercase tracking-wider">Total Customers</span>
            <div className="text-2xl font-bold text-gray-900 mt-2">
              {stats.totalCustomers}
            </div>
            <div className="text-xs text-gray-400 mt-2">Registered customer accounts</div>
          </div>
          <div className="w-12 h-12 bg-emerald-50 text-[#22C55E] rounded-2xl flex items-center justify-center">
            <Users className="w-6 h-6" />
          </div>
        </div>
      </div>

      {/* Analytics Charts */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* Real Revenue Overview Chart */}
        <div className="lg:col-span-2 bg-white p-6 rounded-2xl border border-gray-100 shadow-xs">
          <div className="flex items-center justify-between mb-6">
            <div>
              <h2 className="text-lg font-bold text-gray-900 m-0">Revenue Analytics</h2>
              <p className="text-xs text-gray-400 mt-0.5">Real monthly revenue in Ethiopian Birr (ETB)</p>
            </div>
            <span className="text-xs font-semibold bg-gray-100 text-gray-600 px-3 py-1 rounded-lg">
              Live Database Data
            </span>
          </div>

          <div className="h-72 w-full">
            {stats.revenueByMonth.length > 0 ? (
              <ResponsiveContainer width="100%" height="100%">
                <AreaChart data={stats.revenueByMonth} margin={{ top: 10, right: 10, left: 0, bottom: 0 }}>
                  <defs>
                    <linearGradient id="colorRevenue" x1="0" y1="0" x2="0" y2="1">
                      <stop offset="5%" stopColor="#6C63FF" stopOpacity={0.4} />
                      <stop offset="95%" stopColor="#6C63FF" stopOpacity={0} />
                    </linearGradient>
                  </defs>
                  <CartesianGrid strokeDasharray="3 3" vertical={false} stroke="#F1F5F9" />
                  <XAxis dataKey="month" axisLine={false} tickLine={false} tick={{ fill: '#94A3B8', fontSize: 12 }} />
                  <YAxis axisLine={false} tickLine={false} tick={{ fill: '#94A3B8', fontSize: 12 }} />
                  <Tooltip
                    contentStyle={{ backgroundColor: '#1E1E2D', borderRadius: '12px', border: 'none', color: '#fff' }}
                    itemStyle={{ color: '#6C63FF' }}
                    formatter={(value: any) => [`ETB ${Number(value).toLocaleString()}`, 'Revenue']}
                  />
                  <Area type="monotone" dataKey="revenue" stroke="#6C63FF" strokeWidth={3} fillOpacity={1} fill="url(#colorRevenue)" />
                </AreaChart>
              </ResponsiveContainer>
            ) : (
              <div className="h-full flex items-center justify-center text-gray-400 text-sm">
                No paid/active orders recorded yet.
              </div>
            )}
          </div>
        </div>

        {/* Real Category Breakdown Bar Chart */}
        <div className="bg-white p-6 rounded-2xl border border-gray-100 shadow-xs">
          <div className="flex items-center justify-between mb-6">
            <div>
              <h2 className="text-lg font-bold text-gray-900 m-0">Category Sales</h2>
              <p className="text-xs text-gray-400 mt-0.5">Units sold per category</p>
            </div>
          </div>

          <div className="h-72 w-full">
            {stats.salesByCategory.length > 0 ? (
              <ResponsiveContainer width="100%" height="100%">
                <BarChart data={stats.salesByCategory} layout="vertical" margin={{ top: 0, right: 10, left: 10, bottom: 0 }}>
                  <CartesianGrid strokeDasharray="3 3" horizontal={false} stroke="#F1F5F9" />
                  <XAxis type="number" hide />
                  <YAxis dataKey="category" type="category" axisLine={false} tickLine={false} tick={{ fill: '#475569', fontSize: 12, fontWeight: 500 }} />
                  <Tooltip
                    contentStyle={{ backgroundColor: '#1E1E2D', borderRadius: '12px', color: '#fff' }}
                    formatter={(value: any) => [`${value} units`, 'Units Sold']}
                  />
                  <Bar dataKey="unitsSold" fill="#6C63FF" radius={[0, 8, 8, 0]} barSize={20} />
                </BarChart>
              </ResponsiveContainer>
            ) : (
              <div className="h-full flex items-center justify-center text-gray-400 text-sm">
                No items sold yet.
              </div>
            )}
          </div>
        </div>
      </div>

      {/* Quick Action Links */}
      <div className="bg-white p-6 rounded-2xl border border-gray-100 shadow-xs">
        <h2 className="text-lg font-bold text-gray-900 mb-4">Quick Management Actions</h2>
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
          <a
            href="/products"
            className="p-4 bg-gray-50 hover:bg-[#6C63FF]/5 border border-gray-200 rounded-xl flex items-center justify-between group transition-all"
          >
            <div className="flex items-center gap-3">
              <Package className="w-5 h-5 text-[#6C63FF]" />
              <span className="font-semibold text-sm text-gray-800">Manage Products</span>
            </div>
            <ArrowUpRight className="w-4 h-4 text-gray-400 group-hover:text-[#6C63FF] transition-all" />
          </a>

          <a
            href="/orders"
            className="p-4 bg-gray-50 hover:bg-blue-50 border border-gray-200 rounded-xl flex items-center justify-between group transition-all"
          >
            <div className="flex items-center gap-3">
              <ShoppingBag className="w-5 h-5 text-blue-600" />
              <span className="font-semibold text-sm text-gray-800">View Orders</span>
            </div>
            <ArrowUpRight className="w-4 h-4 text-gray-400 group-hover:text-blue-600 transition-all" />
          </a>

          <a
            href="/categories"
            className="p-4 bg-gray-50 hover:bg-purple-50 border border-gray-200 rounded-xl flex items-center justify-between group transition-all"
          >
            <div className="flex items-center gap-3">
              <FolderTree className="w-5 h-5 text-purple-600" />
              <span className="font-semibold text-sm text-gray-800">Categories</span>
            </div>
            <ArrowUpRight className="w-4 h-4 text-gray-400 group-hover:text-purple-600 transition-all" />
          </a>

          <a
            href="/customers"
            className="p-4 bg-gray-50 hover:bg-emerald-50 border border-gray-200 rounded-xl flex items-center justify-between group transition-all"
          >
            <div className="flex items-center gap-3">
              <Users className="w-5 h-5 text-[#22C55E]" />
              <span className="font-semibold text-sm text-gray-800">Customers</span>
            </div>
            <ArrowUpRight className="w-4 h-4 text-gray-400 group-hover:text-[#22C55E] transition-all" />
          </a>
        </div>
      </div>
    </div>
  );
};
