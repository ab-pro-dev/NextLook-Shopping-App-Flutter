import React, { useEffect, useState } from 'react';
import {
  type AdminCustomerDetail,
  fetchAdminCustomerById,
} from '../services/api';
import {
  X,
  User,
  Calendar,
  ShoppingBag,
  CreditCard,
  MapPin,
  Loader2,
  Package,
  Phone,
} from 'lucide-react';

interface CustomerDetailModalProps {
  customerId: string | null;
  isOpen: boolean;
  onClose: () => void;
}

export const CustomerDetailModal: React.FC<CustomerDetailModalProps> = ({
  customerId,
  isOpen,
  onClose,
}) => {
  const [customer, setCustomer] = useState<AdminCustomerDetail | null>(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    if (customerId && isOpen) {
      const loadDetail = async () => {
        try {
          setLoading(true);
          setError(null);
          const data = await fetchAdminCustomerById(customerId);
          setCustomer(data);
        } catch (err: any) {
          console.error('Failed to load customer profile:', err);
          setError(err.response?.data?.message || err.message || 'Failed to load customer profile');
        } finally {
          setLoading(false);
        }
      };
      loadDetail();
    }
  }, [customerId, isOpen]);

  if (!isOpen || !customerId) return null;

  return (
    <div className="fixed inset-0 z-50 bg-black/50 backdrop-blur-xs flex items-center justify-center p-4">
      <div className="bg-white rounded-2xl shadow-2xl max-w-4xl w-full max-h-[90vh] flex flex-col overflow-hidden animate-in fade-in zoom-in-95">
        {/* Modal Header */}
        <div className="h-18 px-6 bg-[#1E1E2D] text-white flex items-center justify-between shrink-0">
          <div className="flex items-center gap-3">
            <div className="w-10 h-10 bg-[#6C63FF] rounded-full flex items-center justify-center text-white font-bold text-base shadow-md shadow-[#6C63FF]/30">
              {customer?.name ? customer.name.charAt(0).toUpperCase() : <User className="w-5 h-5" />}
            </div>
            <div>
              <h2 className="text-lg font-bold text-white m-0 flex items-center gap-2">
                {customer?.name || 'Customer Account Profile'}
                <span className="px-2 py-0.5 bg-emerald-500/20 text-emerald-400 border border-emerald-500/30 text-[10px] uppercase font-bold rounded-md">
                  Read-Only Customer
                </span>
              </h2>
              <p className="text-xs text-gray-400 mt-0.5">{customer?.email || '...'}</p>
            </div>
          </div>
          <button
            onClick={onClose}
            className="p-2 text-gray-400 hover:text-white rounded-xl hover:bg-gray-800 transition-all cursor-pointer"
          >
            <X className="w-5 h-5" />
          </button>
        </div>

        {/* Modal Body */}
        {loading ? (
          <div className="flex-1 flex flex-col items-center justify-center p-12 space-y-3">
            <Loader2 className="w-8 h-8 text-[#6C63FF] animate-spin" />
            <p className="text-sm text-gray-500 font-medium">Loading customer profile & order history...</p>
          </div>
        ) : error && !customer ? (
          <div className="p-8 text-center space-y-4">
            <div className="bg-red-50 text-red-700 p-4 rounded-xl text-sm border border-red-200">
              {error}
            </div>
            <button
              onClick={onClose}
              className="px-4 py-2 bg-gray-100 text-gray-700 rounded-xl text-xs font-semibold"
            >
              Close
            </button>
          </div>
        ) : customer ? (
          <div className="flex-1 overflow-y-auto p-6 space-y-6">
            {/* Overview Stat Cards */}
            <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
              <div className="bg-gray-50 border border-gray-200 p-4 rounded-2xl space-y-1">
                <div className="flex items-center gap-2 text-xs font-bold text-gray-500 uppercase tracking-wider">
                  <ShoppingBag className="w-4 h-4 text-[#6C63FF]" /> Total Orders Placed
                </div>
                <div className="text-2xl font-bold text-gray-900">{customer.totalOrdersCount} orders</div>
              </div>

              <div className="bg-gray-50 border border-gray-200 p-4 rounded-2xl space-y-1">
                <div className="flex items-center gap-2 text-xs font-bold text-gray-500 uppercase tracking-wider">
                  <CreditCard className="w-4 h-4 text-[#6C63FF]" /> Total Lifetime Spent
                </div>
                <div className="text-2xl font-bold text-[#6C63FF]">
                  ETB {customer.totalSpent.toLocaleString()}
                </div>
              </div>

              <div className="bg-gray-50 border border-gray-200 p-4 rounded-2xl space-y-1">
                <div className="flex items-center gap-2 text-xs font-bold text-gray-500 uppercase tracking-wider">
                  <Calendar className="w-4 h-4 text-[#6C63FF]" /> Registered On
                </div>
                <div className="text-sm font-bold text-gray-900">
                  {new Date(customer.createdAt).toLocaleDateString()}
                </div>
                <div className="text-xs text-gray-400">
                  Last order:{' '}
                  {customer.lastOrderDate
                    ? new Date(customer.lastOrderDate).toLocaleDateString()
                    : 'No orders yet'}
                </div>
              </div>
            </div>

            {/* Saved Delivery Addresses */}
            <div className="bg-white rounded-2xl border border-gray-200 p-5 space-y-3">
              <h3 className="text-sm font-bold text-gray-900 flex items-center gap-2 m-0 border-b border-gray-100 pb-3">
                <MapPin className="w-4 h-4 text-[#6C63FF]" /> Saved Shipping Addresses ({customer.addresses.length})
              </h3>
              {customer.addresses.length === 0 ? (
                <p className="text-xs text-gray-400 italic">No saved delivery addresses on file.</p>
              ) : (
                <div className="grid grid-cols-1 md:grid-cols-2 gap-3">
                  {customer.addresses.map((addr) => (
                    <div
                      key={addr.id}
                      className="p-3.5 bg-gray-50 rounded-xl border border-gray-200 text-xs space-y-1 relative"
                    >
                      {addr.isDefault && (
                        <span className="absolute right-3 top-3 px-2 py-0.5 bg-purple-100 text-purple-700 text-[10px] font-bold rounded-md">
                          Default
                        </span>
                      )}
                      <div className="font-bold text-gray-900">{addr.fullName}</div>
                      <div className="text-gray-600 flex items-center gap-1">
                        <Phone className="w-3 h-3 text-gray-400" /> {addr.phone}
                      </div>
                      <div className="text-gray-500 mt-1">
                        {addr.addressLine1}
                        {addr.addressLine2 ? `, ${addr.addressLine2}` : ''}
                      </div>
                      <div className="text-gray-500 font-medium">
                        {addr.city}, {addr.region}, {addr.country}
                      </div>
                    </div>
                  ))}
                </div>
              )}
            </div>

            {/* Complete Customer Order History */}
            <div className="bg-white rounded-2xl border border-gray-200 overflow-hidden space-y-3">
              <div className="p-4 border-b border-gray-100 font-bold text-sm text-gray-900 flex items-center justify-between">
                <div className="flex items-center gap-2">
                  <Package className="w-4 h-4 text-[#6C63FF]" /> Order History ({customer.orders.length})
                </div>
                <span className="text-xs text-gray-400 font-normal">
                  Read-only audit record
                </span>
              </div>
              {customer.orders.length === 0 ? (
                <div className="p-8 text-center text-xs text-gray-400">
                  This customer has not placed any orders yet.
                </div>
              ) : (
                <div className="overflow-x-auto">
                  <table className="w-full text-left text-xs border-collapse">
                    <thead>
                      <tr className="bg-gray-50 text-gray-500 uppercase tracking-wider font-semibold border-b border-gray-200/60">
                        <th className="py-3 px-4">Order Number</th>
                        <th className="py-3 px-4">Date</th>
                        <th className="py-3 px-4">Status</th>
                        <th className="py-3 px-4">Payment</th>
                        <th className="py-3 px-4">Items</th>
                        <th className="py-3 px-4 text-right">Total Amount</th>
                      </tr>
                    </thead>
                    <tbody className="divide-y divide-gray-100">
                      {customer.orders.map((ord) => {
                        const itemCount = ord.items?.reduce((sum, i) => sum + i.quantity, 0) || 0;
                        return (
                          <tr key={ord.id} className="hover:bg-gray-50">
                            <td className="py-3 px-4 font-bold font-mono text-gray-900">
                              #{ord.orderNumber}
                            </td>
                            <td className="py-3 px-4 text-gray-500">
                              {new Date(ord.createdAt).toLocaleDateString()}
                            </td>
                            <td className="py-3 px-4 font-bold text-[#6C63FF]">{ord.status}</td>
                            <td className="py-3 px-4 text-gray-600">{ord.paymentStatus}</td>
                            <td className="py-3 px-4 text-gray-700">{itemCount} items</td>
                            <td className="py-3 px-4 text-right font-bold text-gray-900">
                              ETB {ord.total.toLocaleString()}
                            </td>
                          </tr>
                        );
                      })}
                    </tbody>
                  </table>
                </div>
              )}
            </div>
          </div>
        ) : null}
      </div>
    </div>
  );
};
