import React from 'react';
import {
  DollarSign,
  ShoppingBag,
  Package,
  Users,
  FolderTree,
  TrendingUp,
  ArrowUpRight,
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

const revenueData = [
  { month: 'Jan', revenue: 45000, orders: 120 },
  { month: 'Feb', revenue: 52000, orders: 145 },
  { month: 'Mar', revenue: 61000, orders: 170 },
  { month: 'Apr', revenue: 58000, orders: 160 },
  { month: 'May', revenue: 74000, orders: 210 },
  { month: 'Jun', revenue: 89000, orders: 250 },
  { month: 'Jul', revenue: 95000, orders: 280 },
];

const categoryData = [
  { name: 'Men', sales: 45 },
  { name: 'Women', sales: 65 },
  { name: 'Shoes', sales: 38 },
  { name: 'Kids', sales: 24 },
  { name: 'Accessories', sales: 30 },
];

export const DashboardPage: React.FC = () => {
  return (
    <div className="space-y-8">
      {/* Welcome Banner */}
      <div className="flex flex-col md:flex-row md:items-center md:justify-between gap-4 bg-gradient-to-r from-[#1E1E2D] to-[#2D2D44] p-6 rounded-2xl text-white shadow-lg">
        <div>
          <h1 className="text-2xl font-bold text-white m-0">Welcome back, Admin 👋</h1>
          <p className="text-gray-400 text-sm mt-1">Here is what's happening with NextLook store today.</p>
        </div>
        <div className="flex items-center gap-3">
          <span className="text-xs bg-[#22C55E]/20 text-[#22C55E] px-3 py-1.5 rounded-full font-semibold border border-[#22C55E]/30 flex items-center gap-1.5">
            <span className="w-2 h-2 bg-[#22C55E] rounded-full animate-pulse" />
            Live Render Server Active
          </span>
        </div>
      </div>

      {/* Metric Cards Grid */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6">
        <div className="bg-white p-6 rounded-2xl border border-gray-100 shadow-xs flex items-center justify-between">
          <div>
            <span className="text-xs font-semibold text-gray-500 uppercase tracking-wider">Total Revenue</span>
            <div className="text-2xl font-bold text-gray-900 mt-2">ETB 473,000</div>
            <div className="flex items-center gap-1 text-xs font-semibold text-[#22C55E] mt-2">
              <TrendingUp className="w-3.5 h-3.5" />
              <span>+18.4% vs last month</span>
            </div>
          </div>
          <div className="w-12 h-12 bg-[#6C63FF]/10 text-[#6C63FF] rounded-2xl flex items-center justify-center">
            <DollarSign className="w-6 h-6" />
          </div>
        </div>

        <div className="bg-white p-6 rounded-2xl border border-gray-100 shadow-xs flex items-center justify-between">
          <div>
            <span className="text-xs font-semibold text-gray-500 uppercase tracking-wider">Total Orders</span>
            <div className="text-2xl font-bold text-gray-900 mt-2">1,335</div>
            <div className="flex items-center gap-1 text-xs font-semibold text-[#22C55E] mt-2">
              <TrendingUp className="w-3.5 h-3.5" />
              <span>+12.1% vs last month</span>
            </div>
          </div>
          <div className="w-12 h-12 bg-blue-50 text-blue-600 rounded-2xl flex items-center justify-center">
            <ShoppingBag className="w-6 h-6" />
          </div>
        </div>

        <div className="bg-white p-6 rounded-2xl border border-gray-100 shadow-xs flex items-center justify-between">
          <div>
            <span className="text-xs font-semibold text-gray-500 uppercase tracking-wider">Active Products</span>
            <div className="text-2xl font-bold text-gray-900 mt-2">12 Products</div>
            <div className="text-xs text-gray-400 mt-2">Across 5 Categories</div>
          </div>
          <div className="w-12 h-12 bg-[#FF6584]/10 text-[#FF6584] rounded-2xl flex items-center justify-center">
            <Package className="w-6 h-6" />
          </div>
        </div>

        <div className="bg-white p-6 rounded-2xl border border-gray-100 shadow-xs flex items-center justify-between">
          <div>
            <span className="text-xs font-semibold text-gray-500 uppercase tracking-wider">Total Customers</span>
            <div className="text-2xl font-bold text-gray-900 mt-2">482</div>
            <div className="flex items-center gap-1 text-xs font-semibold text-[#22C55E] mt-2">
              <TrendingUp className="w-3.5 h-3.5" />
              <span>+8.6% new users</span>
            </div>
          </div>
          <div className="w-12 h-12 bg-emerald-50 text-[#22C55E] rounded-2xl flex items-center justify-center">
            <Users className="w-6 h-6" />
          </div>
        </div>
      </div>

      {/* Analytics Charts */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* Revenue Overview Chart */}
        <div className="lg:col-span-2 bg-white p-6 rounded-2xl border border-gray-100 shadow-xs">
          <div className="flex items-center justify-between mb-6">
            <div>
              <h2 className="text-lg font-bold text-gray-900 m-0">Revenue Analytics</h2>
              <p className="text-xs text-gray-400 mt-0.5">Monthly revenue in Ethiopian Birr (ETB)</p>
            </div>
            <span className="text-xs font-semibold bg-gray-100 text-gray-600 px-3 py-1 rounded-lg">
              2026 YTD
            </span>
          </div>

          <div className="h-72 w-full">
            <ResponsiveContainer width="100%" height="100%">
              <AreaChart data={revenueData} margin={{ top: 10, right: 10, left: 0, bottom: 0 }}>
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
                />
                <Area type="monotone" dataKey="revenue" stroke="#6C63FF" strokeWidth={3} fillOpacity={1} fill="url(#colorRevenue)" />
              </AreaChart>
            </ResponsiveContainer>
          </div>
        </div>

        {/* Category Breakdown Bar Chart */}
        <div className="bg-white p-6 rounded-2xl border border-gray-100 shadow-xs">
          <div className="flex items-center justify-between mb-6">
            <div>
              <h2 className="text-lg font-bold text-gray-900 m-0">Category Sales</h2>
              <p className="text-xs text-gray-400 mt-0.5">Distribution by category</p>
            </div>
          </div>

          <div className="h-72 w-full">
            <ResponsiveContainer width="100%" height="100%">
              <BarChart data={categoryData} layout="vertical" margin={{ top: 0, right: 10, left: 10, bottom: 0 }}>
                <CartesianGrid strokeDasharray="3 3" horizontal={false} stroke="#F1F5F9" />
                <XAxis type="number" hide />
                <YAxis dataKey="name" type="category" axisLine={false} tickLine={false} tick={{ fill: '#475569', fontSize: 12, fontWeight: 500 }} />
                <Tooltip contentStyle={{ backgroundColor: '#1E1E2D', borderRadius: '12px', color: '#fff' }} />
                <Bar dataKey="sales" fill="#6C63FF" radius={[0, 8, 8, 0]} barSize={20} />
              </BarChart>
            </ResponsiveContainer>
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
