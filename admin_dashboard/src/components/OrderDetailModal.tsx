import React, { useEffect, useState } from 'react';
import {
  type AdminOrderDetail,
  type OrderStatusType,
  fetchAdminOrderById,
  updateAdminOrderStatus,
} from '../services/api';
import {
  X,
  MapPin,
  User,
  CreditCard,
  Truck,
  CheckCircle2,
  AlertCircle,
  Loader2,
  ArrowRight,
  Package,
} from 'lucide-react';

interface OrderDetailModalProps {
  orderId: string | null;
  isOpen: boolean;
  onClose: () => void;
  onOrderUpdated: () => void;
}

const statusBadgeStyles: Record<OrderStatusType, { bg: string; text: string; label: string }> = {
  PENDING: { bg: 'bg-amber-50 border-amber-200', text: 'text-amber-700', label: 'Pending' },
  PROCESSING: { bg: 'bg-blue-50 border-blue-200', text: 'text-blue-700', label: 'Processing' },
  SHIPPED: { bg: 'bg-purple-50 border-purple-200', text: 'text-purple-700', label: 'Shipped' },
  OUT_FOR_DELIVERY: { bg: 'bg-indigo-50 border-indigo-200', text: 'text-indigo-700', label: 'Out for Delivery' },
  DELIVERED: { bg: 'bg-emerald-50 border-emerald-200', text: 'text-emerald-700', label: 'Delivered' },
  CANCELLED: { bg: 'bg-red-50 border-red-200', text: 'text-red-700', label: 'Cancelled' },
};

export const OrderDetailModal: React.FC<OrderDetailModalProps> = ({
  orderId,
  isOpen,
  onClose,
  onOrderUpdated,
}) => {
  const [order, setOrder] = useState<AdminOrderDetail | null>(null);
  const [loading, setLoading] = useState(false);
  const [updating, setUpdating] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [successMsg, setSuccessMsg] = useState<string | null>(null);

  const loadOrderDetail = async (id: string) => {
    try {
      setLoading(true);
      setError(null);
      const data = await fetchAdminOrderById(id);
      setOrder(data);
    } catch (err: any) {
      console.error('Failed to load order detail:', err);
      setError(err.response?.data?.message || err.message || 'Failed to load order details');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    if (orderId && isOpen) {
      loadOrderDetail(orderId);
      setSuccessMsg(null);
    }
  }, [orderId, isOpen]);

  if (!isOpen || !orderId) return null;

  const handleUpdateStatus = async (targetStatus: OrderStatusType) => {
    if (!order) return;
    setUpdating(true);
    setError(null);
    setSuccessMsg(null);

    try {
      const updated = await updateAdminOrderStatus(order.id, targetStatus);
      setOrder(updated);
      setSuccessMsg(`Order status successfully updated to '${targetStatus}'!`);
      onOrderUpdated();
      setTimeout(() => setSuccessMsg(null), 4000);
    } catch (err: any) {
      console.error('Failed to update order status:', err);
      setError(err.response?.data?.message || err.message || 'Failed to update order status');
    } finally {
      setUpdating(false);
    }
  };

  return (
    <div className="fixed inset-0 z-50 bg-black/50 backdrop-blur-xs flex items-center justify-center p-4">
      <div className="bg-white rounded-2xl shadow-2xl max-w-4xl w-full max-h-[90vh] flex flex-col overflow-hidden animate-in fade-in zoom-in-95">
        {/* Modal Header */}
        <div className="h-18 px-6 bg-[#1E1E2D] text-white flex items-center justify-between shrink-0">
          <div className="flex items-center gap-3">
            <div className="w-10 h-10 bg-[#6C63FF] rounded-xl flex items-center justify-center font-mono font-bold text-sm shadow-md shadow-[#6C63FF]/30">
              #
            </div>
            <div>
              <h2 className="text-lg font-bold text-white m-0">Order #{order?.orderNumber || '...'}</h2>
              <p className="text-xs text-gray-400 mt-0.5">
                Placed on {order ? new Date(order.createdAt).toLocaleString() : '...'}
              </p>
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
            <p className="text-sm text-gray-500 font-medium">Fetching complete order details...</p>
          </div>
        ) : error && !order ? (
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
        ) : order ? (
          <div className="flex-1 overflow-y-auto p-6 space-y-6">
            {/* Success & Error Notifications */}
            {successMsg && (
              <div className="bg-emerald-50 border border-emerald-200 text-emerald-800 px-4 py-3 rounded-xl flex items-center gap-2 text-sm font-semibold shadow-2xs">
                <CheckCircle2 className="w-5 h-5 text-[#22C55E]" />
                <span>{successMsg}</span>
              </div>
            )}
            {error && (
              <div className="bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded-xl flex items-center gap-2 text-sm">
                <AlertCircle className="w-5 h-5 text-red-500 shrink-0" />
                <span>{error}</span>
              </div>
            )}

            {/* Status & Transition Header Card */}
            <div className="bg-gray-50 border border-gray-200 rounded-2xl p-5 flex flex-col md:flex-row md:items-center md:justify-between gap-4">
              <div className="space-y-1">
                <span className="text-xs font-bold uppercase tracking-wider text-gray-500">
                  Current Order Status
                </span>
                <div className="flex items-center gap-3">
                  <span
                    className={`px-3.5 py-1.5 rounded-full font-bold text-xs border ${
                      statusBadgeStyles[order.status]?.bg
                    } ${statusBadgeStyles[order.status]?.text}`}
                  >
                    {statusBadgeStyles[order.status]?.label || order.status}
                  </span>
                  <span className="text-xs font-semibold text-gray-500">
                    Payment Status:{' '}
                    <span
                      className={
                        order.paymentStatus === 'PAID' ? 'text-[#22C55E] font-bold' : 'text-amber-600'
                      }
                    >
                      {order.paymentStatus}
                    </span>
                  </span>
                </div>
              </div>

              {/* Status Advancement Actions */}
              <div className="flex items-center gap-2 flex-wrap">
                {order.allowedNextStatuses.length > 0 ? (
                  <>
                    <span className="text-xs font-semibold text-gray-600 mr-1">Advance Status:</span>
                    {order.allowedNextStatuses.map((nextSt) => (
                      <button
                        key={nextSt}
                        disabled={updating}
                        onClick={() => handleUpdateStatus(nextSt)}
                        className={`px-4 py-2 rounded-xl text-xs font-bold shadow-xs transition-all flex items-center gap-1.5 cursor-pointer disabled:opacity-50 ${
                          nextSt === 'CANCELLED'
                            ? 'bg-red-50 hover:bg-red-100 text-red-700 border border-red-200'
                            : 'bg-[#6C63FF] hover:bg-[#5a52e0] text-white shadow-[#6C63FF]/20'
                        }`}
                      >
                        {updating ? (
                          <Loader2 className="w-3.5 h-3.5 animate-spin" />
                        ) : (
                          <ArrowRight className="w-3.5 h-3.5" />
                        )}
                        Mark as {statusBadgeStyles[nextSt]?.label || nextSt}
                      </button>
                    ))}
                  </>
                ) : (
                  <span className="text-xs font-semibold text-gray-400 bg-gray-200 px-3 py-1.5 rounded-xl">
                    Status is Terminal ({order.status})
                  </span>
                )}
              </div>
            </div>

            {/* Customer & Address Details */}
            <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
              <div className="bg-white p-4 rounded-xl border border-gray-200 space-y-2">
                <div className="flex items-center gap-2 text-xs font-bold uppercase tracking-wider text-[#6C63FF]">
                  <User className="w-4 h-4" /> Customer Contact
                </div>
                <div className="text-sm font-bold text-gray-900">{order.customerName}</div>
                <div className="text-xs text-gray-600 font-mono">{order.customerEmail}</div>
                <div className="text-xs text-gray-500">{order.shippingPhone}</div>
              </div>

              <div className="bg-white p-4 rounded-xl border border-gray-200 space-y-2">
                <div className="flex items-center gap-2 text-xs font-bold uppercase tracking-wider text-[#6C63FF]">
                  <MapPin className="w-4 h-4" /> Shipping Address
                </div>
                <div className="text-sm font-semibold text-gray-800">{order.shippingFullName}</div>
                <div className="text-xs text-gray-600">
                  {order.shippingAddressLine1}
                  {order.shippingAddressLine2 ? `, ${order.shippingAddressLine2}` : ''}
                </div>
                <div className="text-xs text-gray-600">
                  {order.shippingCity}, {order.shippingRegion}, {order.shippingCountry}
                </div>
              </div>

              <div className="bg-white p-4 rounded-xl border border-gray-200 space-y-2">
                <div className="flex items-center gap-2 text-xs font-bold uppercase tracking-wider text-[#6C63FF]">
                  <CreditCard className="w-4 h-4" /> Payment & Shipping
                </div>
                <div className="text-xs text-gray-700">
                  <span className="font-semibold">Payment Method:</span> {order.paymentMethod}
                </div>
                <div className="text-xs text-gray-700">
                  <span className="font-semibold">Method Label:</span> {order.deliveryMethodLabel}
                </div>
                <div className="text-xs text-gray-700">
                  <span className="font-semibold">Shipping Cost:</span> ETB{' '}
                  {order.shippingCost.toLocaleString()}
                </div>
              </div>
            </div>

            {/* Order Items Table */}
            <div className="bg-white rounded-xl border border-gray-200 overflow-hidden">
              <div className="p-4 border-b border-gray-100 font-bold text-sm text-gray-900 flex items-center gap-2">
                <Package className="w-4 h-4 text-[#6C63FF]" /> Line Items ({order.items.length})
              </div>
              <div className="overflow-x-auto">
                <table className="w-full text-left text-xs border-collapse">
                  <thead>
                    <tr className="bg-gray-50 text-gray-500 uppercase tracking-wider font-semibold border-b border-gray-200/60">
                      <th className="py-3 px-4">Item</th>
                      <th className="py-3 px-4">Color</th>
                      <th className="py-3 px-4">Size</th>
                      <th className="py-3 px-4">Qty</th>
                      <th className="py-3 px-4">Unit Price</th>
                      <th className="py-3 px-4 text-right">Line Total</th>
                    </tr>
                  </thead>
                  <tbody className="divide-y divide-gray-100">
                    {order.items.map((item) => (
                      <tr key={item.id} className="hover:bg-gray-50">
                        <td className="py-3 px-4">
                          <div className="flex items-center gap-3">
                            <img
                              src={item.productThumbnailUrl || 'https://picsum.photos/seed/placeholder/100/100'}
                              alt={item.productName}
                              className="w-9 h-9 rounded-lg object-cover border border-gray-200"
                            />
                            <span className="font-bold text-gray-900">{item.productName}</span>
                          </div>
                        </td>
                        <td className="py-3 px-4 font-medium text-gray-700">{item.colorName}</td>
                        <td className="py-3 px-4 font-semibold text-gray-800">{item.sizeLabel}</td>
                        <td className="py-3 px-4 font-bold text-gray-900">{item.quantity}</td>
                        <td className="py-3 px-4 text-gray-700">ETB {item.unitPrice.toLocaleString()}</td>
                        <td className="py-3 px-4 text-right font-bold text-[#6C63FF]">
                          ETB {item.lineTotal.toLocaleString()}
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>

              {/* Price Breakdown Footer */}
              <div className="p-4 bg-gray-50 border-t border-gray-200 flex flex-col items-end space-y-1 text-xs">
                <div className="flex items-center justify-between w-64 text-gray-600">
                  <span>Subtotal:</span>
                  <span className="font-semibold">ETB {order.subtotal.toLocaleString()}</span>
                </div>
                <div className="flex items-center justify-between w-64 text-gray-600">
                  <span>Shipping:</span>
                  <span className="font-semibold">ETB {order.shippingCost.toLocaleString()}</span>
                </div>
                <div className="flex items-center justify-between w-64 text-gray-600">
                  <span>Tax:</span>
                  <span className="font-semibold">ETB {order.tax.toLocaleString()}</span>
                </div>
                <div className="flex items-center justify-between w-64 text-sm font-bold text-gray-900 pt-2 border-t border-gray-200">
                  <span>Total Amount:</span>
                  <span className="text-[#6C63FF] text-base">ETB {order.total.toLocaleString()}</span>
                </div>
              </div>
            </div>

            {/* Status History Tracking Timeline (matching mobile app Order Tracking) */}
            <div className="bg-white p-5 rounded-2xl border border-gray-200 space-y-4">
              <div className="flex items-center justify-between border-b border-gray-100 pb-3">
                <h3 className="text-sm font-bold text-gray-900 flex items-center gap-2 m-0">
                  <Truck className="w-4 h-4 text-[#6C63FF]" /> Order Status History Timeline
                </h3>
                <span className="text-xs text-gray-400 font-medium">
                  {order.statusHistory.length} recorded milestone events
                </span>
              </div>

              <div className="relative pl-6 space-y-6 before:absolute before:left-2.5 before:top-2 before:bottom-2 before:w-0.5 before:bg-gray-200">
                {order.statusHistory.map((hist, index) => {
                  const isLatest = index === order.statusHistory.length - 1;
                  return (
                    <div key={hist.id} className="relative flex items-start gap-4 group">
                      {/* Circle indicator on line */}
                      <div
                        className={`absolute -left-6 top-1 w-5 h-5 rounded-full border-2 flex items-center justify-center bg-white ${
                          isLatest
                            ? 'border-[#6C63FF] text-[#6C63FF] shadow-xs ring-4 ring-[#6C63FF]/10'
                            : 'border-emerald-500 text-emerald-500'
                        }`}
                      >
                        <span
                          className={`w-2 h-2 rounded-full ${
                            isLatest ? 'bg-[#6C63FF]' : 'bg-emerald-500'
                          }`}
                        />
                      </div>

                      <div className="flex-1">
                        <div className="flex items-center justify-between">
                          <span
                            className={`font-bold text-xs ${
                              isLatest ? 'text-[#6C63FF]' : 'text-gray-900'
                            }`}
                          >
                            {statusBadgeStyles[hist.status]?.label || hist.status}
                          </span>
                          <span className="text-[11px] text-gray-400 font-mono">
                            {new Date(hist.createdAt).toLocaleString()}
                          </span>
                        </div>
                        <p className="text-xs text-gray-500 mt-0.5">
                          {hist.status === 'PENDING' && 'Order placed and pending confirmation.'}
                          {hist.status === 'PROCESSING' && 'Order is being prepared and packed.'}
                          {hist.status === 'SHIPPED' && 'Order handed over to courier for shipping.'}
                          {hist.status === 'OUT_FOR_DELIVERY' && 'Courier is on the way to recipient address.'}
                          {hist.status === 'DELIVERED' && 'Order delivered successfully to customer.'}
                          {hist.status === 'CANCELLED' && 'Order cancelled and stock restored.'}
                        </p>
                      </div>
                    </div>
                  );
                })}
              </div>
            </div>
          </div>
        ) : null}
      </div>
    </div>
  );
};
