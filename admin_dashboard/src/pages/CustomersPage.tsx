import React, { useEffect, useState } from 'react';
import {
  type AdminCustomerListItem,
  fetchAdminCustomers,
} from '../services/api';
import { CustomerDetailModal } from '../components/CustomerDetailModal';
import {
  Search,
  Users,
  Loader2,
  Eye,
} from 'lucide-react';

export const CustomersPage: React.FC = () => {
  const [customers, setCustomers] = useState<AdminCustomerListItem[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  // Search State
  const [searchTerm, setSearchTerm] = useState('');

  // Detail Modal State
  const [selectedCustomerId, setSelectedCustomerId] = useState<string | null>(null);
  const [isModalOpen, setIsModalOpen] = useState(false);

  const loadCustomers = async () => {
    try {
      setLoading(true);
      setError(null);
      const data = await fetchAdminCustomers(searchTerm);
      setCustomers(data);
    } catch (err: any) {
      console.error('Failed to load admin customers:', err);
      setError(err.response?.data?.message || err.message || 'Failed to load customer list');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    loadCustomers();
  }, []);

  const handleSearchSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    loadCustomers();
  };

  const handleOpenDetail = (id: string) => {
    setSelectedCustomerId(id);
    setIsModalOpen(true);
  };

  return (
    <div className="space-y-6">
      {/* Header Banner */}
      <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
        <div>
          <h1 className="text-2xl font-bold text-gray-900 m-0">Registered Customers</h1>
          <p className="text-gray-500 text-sm mt-1">
            Read-only registry of customer accounts, order frequency, and total lifetime spend ({customers.length} total registered).
          </p>
        </div>
      </div>

      {/* Search Header */}
      <div className="bg-white p-4 rounded-2xl border border-gray-100 shadow-xs">
        <form onSubmit={handleSearchSubmit} className="flex items-center gap-3">
          <div className="relative flex-1 max-w-md">
            <Search className="w-4 h-4 text-gray-400 absolute left-3.5 top-1/2 -translate-y-1/2" />
            <input
              type="text"
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
              placeholder="Search customer by name or email..."
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
          <button onClick={loadCustomers} className="font-semibold underline">
            Retry
          </button>
        </div>
      )}

      {/* Customers Table */}
      <div className="bg-white rounded-2xl border border-gray-100 shadow-xs overflow-hidden">
        {loading && customers.length === 0 ? (
          <div className="p-12 text-center flex flex-col items-center justify-center space-y-3">
            <Loader2 className="w-8 h-8 text-[#6C63FF] animate-spin" />
            <p className="text-sm text-gray-500 font-medium">Fetching customer directory...</p>
          </div>
        ) : (
          <div className="overflow-x-auto">
            <table className="w-full text-left border-collapse">
              <thead>
                <tr className="bg-gray-50 border-b border-gray-200/80 text-xs font-semibold uppercase tracking-wider text-gray-500">
                  <th className="py-4 px-6">Customer</th>
                  <th className="py-4 px-4">Registered Date</th>
                  <th className="py-4 px-4">Orders Placed</th>
                  <th className="py-4 px-4">Lifetime Spent</th>
                  <th className="py-4 px-4">Last Order</th>
                  <th className="py-4 px-6 text-right">Action</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-gray-100 text-sm">
                {customers.map((cust) => (
                  <tr
                    key={cust.id}
                    onClick={() => handleOpenDetail(cust.id)}
                    className="hover:bg-gray-50/70 transition-all cursor-pointer"
                  >
                    {/* Customer Cell */}
                    <td className="py-4 px-6">
                      <div className="flex items-center gap-3">
                        <div className="w-10 h-10 bg-[#6C63FF]/10 text-[#6C63FF] rounded-full flex items-center justify-center font-bold text-sm shrink-0 border border-[#6C63FF]/20">
                          {cust.name.charAt(0).toUpperCase()}
                        </div>
                        <div>
                          <div className="font-bold text-gray-900 leading-tight">{cust.name}</div>
                          <div className="text-xs text-gray-400 font-mono mt-0.5">{cust.email}</div>
                        </div>
                      </div>
                    </td>

                    {/* Registered Date */}
                    <td className="py-4 px-4 text-xs text-gray-600">
                      {new Date(cust.createdAt).toLocaleDateString()}
                    </td>

                    {/* Orders Placed */}
                    <td className="py-4 px-4">
                      <span className="px-2.5 py-1 bg-purple-50 text-purple-700 font-bold text-xs rounded-lg border border-purple-200">
                        {cust.totalOrdersCount} orders
                      </span>
                    </td>

                    {/* Lifetime Spent */}
                    <td className="py-4 px-4 font-bold text-[#6C63FF]">
                      ETB {cust.totalSpent.toLocaleString()}
                    </td>

                    {/* Last Order Date */}
                    <td className="py-4 px-4 text-xs text-gray-500">
                      {cust.lastOrderDate
                        ? new Date(cust.lastOrderDate).toLocaleDateString()
                        : 'No orders'}
                    </td>

                    {/* Action */}
                    <td className="py-4 px-6 text-right">
                      <button
                        onClick={(e) => {
                          e.stopPropagation();
                          handleOpenDetail(cust.id);
                        }}
                        className="px-3.5 py-1.5 bg-[#6C63FF]/10 hover:bg-[#6C63FF] text-[#6C63FF] hover:text-white rounded-xl text-xs font-semibold transition-all flex items-center gap-1.5 ml-auto cursor-pointer"
                      >
                        <Eye className="w-3.5 h-3.5" />
                        View Profile
                      </button>
                    </td>
                  </tr>
                ))}

                {customers.length === 0 && (
                  <tr>
                    <td colSpan={6} className="py-12 text-center text-gray-500">
                      <Users className="w-8 h-8 text-gray-300 mx-auto mb-2" />
                      <p className="font-semibold text-sm m-0">No customers found</p>
                      <p className="text-xs text-gray-400 mt-1">
                        Try adjusting your search name or email.
                      </p>
                    </td>
                  </tr>
                )}
              </tbody>
            </table>
          </div>
        )}
      </div>

      {/* Customer Detail Modal */}
      <CustomerDetailModal
        customerId={selectedCustomerId}
        isOpen={isModalOpen}
        onClose={() => {
          setIsModalOpen(false);
          setSelectedCustomerId(null);
        }}
      />
    </div>
  );
};
