import React, { useEffect, useState } from 'react';
import {
  type AdminOrderListItem,
  type OrderStatusType,
  fetchAdminOrders,
} from '../services/api';
import { OrderDetailModal } from '../components/OrderDetailModal';
import {
  Search,
  ShoppingBag,
  Loader2,
  Eye,
} from 'lucide-react';

const statusTabs: Array<{ id: string; label: string }> = [
  { id: 'ALL', label: 'All Orders' },
  { id: 'PENDING', label: 'Pending' },
  { id: 'PROCESSING', label: 'Processing' },
  { id: 'SHIPPED', label: 'Shipped' },
  { id: 'OUT_FOR_DELIVERY', label: 'Out for Delivery' },
  { id: 'DELIVERED', label: 'Delivered' },
  { id: 'CANCELLED', label: 'Cancelled' },
];

const statusStyles: Record<OrderStatusType, { bg: string; text: string }> = {
  PENDING: { bg: 'bg-amber-50 border-amber-200', text: 'text-amber-700' },
  PROCESSING: { bg: 'bg-blue-50 border-blue-200', text: 'text-blue-700' },
  SHIPPED: { bg: 'bg-purple-50 border-purple-200', text: 'text-purple-700' },
  OUT_FOR_DELIVERY: { bg: 'bg-indigo-50 border-indigo-200', text: 'text-indigo-700' },
  DELIVERED: { bg: 'bg-emerald-50 border-emerald-200', text: 'text-emerald-700' },
  CANCELLED: { bg: 'bg-red-50 border-red-200', text: 'text-red-700' },
};

export const OrdersPage: React.FC = () => {
  const [orders, setOrders] = useState<AdminOrderListItem[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  // Filters
  const [activeTab, setActiveTab] = useState<string>('ALL');
  const [searchTerm, setSearchTerm] = useState<string>('');

  // Selected Order Modal
  const [selectedOrderId, setSelectedOrderId] = useState<string | null>(null);
  const [isModalOpen, setIsModalOpen] = useState<boolean>(false);

  const loadOrders = async () => {
    try {
      setLoading(true);
      setError(null);
      const data = await fetchAdminOrders(activeTab, searchTerm);
      setOrders(data);
    } catch (err: any) {
      console.error('Failed to fetch admin orders:', err);
      setError(err.response?.data?.message || err.message || 'Failed to load orders');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    loadOrders();
  }, [activeTab]);

  const handleSearchSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    loadOrders();
  };

  const handleOpenDetail = (id: string) => {
    setSelectedOrderId(id);
    setIsModalOpen(true);
  };

  return (
    <div className="space-y-6">
      {/* Header Banner */}
      <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
        <div>
          <h1 className="text-2xl font-bold text-gray-900 m-0">Order Management</h1>
          <p className="text-gray-500 text-sm mt-1">
            Track customer orders, verify payments, and advance shipping timelines in real-time.
          </p>
        </div>
      </div>

      {/* Filter Tabs & Search Header */}
      <div className="bg-white p-4 rounded-2xl border border-gray-100 shadow-xs space-y-4">
        {/* Status Tabs */}
        <div className="flex items-center gap-2 overflow-x-auto pb-1 border-b border-gray-100 scrollbar-none">
          {statusTabs.map((tab) => {
            const isActive = activeTab === tab.id;
            return (
              <button
                key={tab.id}
                onClick={() => setActiveTab(tab.id)}
                className={`px-4 py-2 rounded-xl text-xs font-bold transition-all whitespace-nowrap cursor-pointer ${
                  isActive
                    ? 'bg-[#6C63FF] text-white shadow-md shadow-[#6C63FF]/20'
                    : 'bg-gray-50 text-gray-600 hover:bg-gray-100 hover:text-gray-900'
                }`}
              >
                {tab.label}
              </button>
            );
          })}
        </div>

        {/* Search Bar */}
        <form onSubmit={handleSearchSubmit} className="flex items-center gap-3">
          <div className="relative flex-1 max-w-md">
            <Search className="w-4 h-4 text-gray-400 absolute left-3.5 top-1/2 -translate-y-1/2" />
            <input
              type="text"
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
              placeholder="Search order #, customer name or email..."
              className="w-full pl-10 pr-4 py-2.5 bg-gray-50 border border-gray-200 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-[#6C63FF] focus:bg-white"
            />
          </div>
          <button
            type="submit"
            className="px-4 py-2.5 bg-gray-100 hover:bg-gray-200 text-gray-700 font-semibold rounded-xl text-xs transition-all cursor-pointer"
          >
            Search
          </button>
        </form>
      </div>

      {/* Error Message */}
      {error && (
        <div className="bg-red-50 border border-red-200 text-red-700 p-4 rounded-xl text-sm flex items-center justify-between">
          <span>{error}</span>
          <button onClick={loadOrders} className="font-semibold underline">
            Retry
          </button>
        </div>
      )}

      {/* Orders Table */}
      <div className="bg-white rounded-2xl border border-gray-100 shadow-xs overflow-hidden">
        {loading && orders.length === 0 ? (
          <div className="p-12 text-center flex flex-col items-center justify-center space-y-3">
            <Loader2 className="w-8 h-8 text-[#6C63FF] animate-spin" />
            <p className="text-sm text-gray-500 font-medium">Fetching orders from database...</p>
          </div>
        ) : (
          <div className="overflow-x-auto">
            <table className="w-full text-left border-collapse">
              <thead>
                <tr className="bg-gray-50 border-b border-gray-200/80 text-xs font-semibold uppercase tracking-wider text-gray-500">
                  <th className="py-4 px-6">Order Number</th>
                  <th className="py-4 px-4">Customer</th>
                  <th className="py-4 px-4">Date</th>
                  <th className="py-4 px-4">Items</th>
                  <th className="py-4 px-4">Total</th>
                  <th className="py-4 px-4">Status</th>
                  <th className="py-4 px-4">Payment</th>
                  <th className="py-4 px-6 text-right">Action</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-gray-100 text-sm">
                {orders.map((order) => (
                  <tr
                    key={order.id}
                    onClick={() => handleOpenDetail(order.id)}
                    className="hover:bg-gray-50/70 transition-all cursor-pointer"
                  >
                    {/* Order Number */}
                    <td className="py-4 px-6 font-bold text-gray-900 font-mono">
                      #{order.orderNumber}
                    </td>

                    {/* Customer */}
                    <td className="py-4 px-4">
                      <div>
                        <div className="font-bold text-gray-900">{order.customerName}</div>
                        <div className="text-xs text-gray-400 font-mono">{order.customerEmail}</div>
                      </div>
                    </td>

                    {/* Date */}
                    <td className="py-4 px-4 text-xs text-gray-500">
                      {new Date(order.createdAt).toLocaleDateString()}{' '}
                      <span className="text-gray-400 block text-[11px]">
                        {new Date(order.createdAt).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}
                      </span>
                    </td>

                    {/* Items */}
                    <td className="py-4 px-4 font-semibold text-gray-700">
                      {order.itemCount} {order.itemCount === 1 ? 'item' : 'items'}
                    </td>

                    {/* Total */}
                    <td className="py-4 px-4 font-bold text-[#6C63FF]">
                      ETB {order.total.toLocaleString()}
                    </td>

                    {/* Status Badge */}
                    <td className="py-4 px-4">
                      <span
                        className={`px-3 py-1 rounded-full font-bold text-xs border ${
                          statusStyles[order.status]?.bg || 'bg-gray-50 border-gray-200'
                        } ${statusStyles[order.status]?.text || 'text-gray-700'}`}
                      >
                        {order.status}
                      </span>
                    </td>

                    {/* Payment Status Badge */}
                    <td className="py-4 px-4">
                      <span
                        className={`px-2.5 py-0.5 rounded-md font-semibold text-xs border ${
                          order.paymentStatus === 'PAID'
                            ? 'bg-emerald-50 text-[#22C55E] border-emerald-200'
                            : 'bg-amber-50 text-amber-700 border-amber-200'
                        }`}
                      >
                        {order.paymentStatus}
                      </span>
                    </td>

                    {/* Action */}
                    <td className="py-4 px-6 text-right">
                      <button
                        onClick={(e) => {
                          e.stopPropagation();
                          handleOpenDetail(order.id);
                        }}
                        className="px-3.5 py-1.5 bg-[#6C63FF]/10 hover:bg-[#6C63FF] text-[#6C63FF] hover:text-white rounded-xl text-xs font-semibold transition-all flex items-center gap-1.5 ml-auto cursor-pointer"
                      >
                        <Eye className="w-3.5 h-3.5" />
                        View Order
                      </button>
                    </td>
                  </tr>
                ))}

                {orders.length === 0 && (
                  <tr>
                    <td colSpan={8} className="py-12 text-center text-gray-500">
                      <ShoppingBag className="w-8 h-8 text-gray-300 mx-auto mb-2" />
                      <p className="font-semibold text-sm m-0">No orders found</p>
                      <p className="text-xs text-gray-400 mt-1">
                        There are currently no orders matching the selected status or filter.
                      </p>
                    </td>
                  </tr>
                )}
              </tbody>
            </table>
          </div>
        )}
      </div>

      {/* Order Detail Modal */}
      <OrderDetailModal
        orderId={selectedOrderId}
        isOpen={isModalOpen}
        onClose={() => {
          setIsModalOpen(false);
          setSelectedOrderId(null);
        }}
        onOrderUpdated={loadOrders}
      />
    </div>
  );
};
