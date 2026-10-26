import React, { useEffect, useState } from 'react';
import { useSearchParams } from 'react-router-dom';
import {
  type AdminProduct,
  type Category,
  fetchAdminProducts,
  fetchCategories,
  deleteAdminProduct,
  updateAdminProductStock,
} from '../services/api';
import { ProductFormModal } from '../components/ProductFormModal';
import {
  Plus,
  Search,
  Edit2,
  Trash2,
  Loader2,
  AlertTriangle,
  Package,
  AlertCircle,
  CheckCircle2,
} from 'lucide-react';

export const ProductsPage: React.FC = () => {
  const [searchParams, setSearchParams] = useSearchParams();
  const [products, setProducts] = useState<AdminProduct[]>([]);
  const [categories, setCategories] = useState<Category[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  // Search & Filter State
  const [searchTerm, setSearchTerm] = useState('');
  const [selectedCategory, setSelectedCategory] = useState<string>('ALL');

  // Modal & Form State
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [editingProduct, setEditingProduct] = useState<AdminProduct | null>(null);

  // Delete Dialog State
  const [deletingProduct, setDeletingProduct] = useState<AdminProduct | null>(null);
  const [deleteLoading, setDeleteLoading] = useState(false);
  const [deleteError, setDeleteError] = useState<string | null>(null);
  const [successMessage, setSuccessMessage] = useState<string | null>(null);

  const loadData = async () => {
    try {
      setLoading(true);
      setError(null);
      const [prodsData, catsData] = await Promise.all([
        fetchAdminProducts(),
        fetchCategories(),
      ]);
      setProducts(prodsData);
      setCategories(catsData);
    } catch (err: any) {
      console.error('Failed to load products page data:', err);
      setError(err.response?.data?.message || err.message || 'Failed to load product catalog');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    loadData();
  }, []);

  // Sync selectedCategory with URL query param `category`
  useEffect(() => {
    const catParam = searchParams.get('category');
    if (catParam && categories.length > 0) {
      const found = categories.find(
        (c) => c.slug.toLowerCase() === catParam.toLowerCase() || c.id === catParam
      );
      if (found) {
        setSelectedCategory(found.id);
      } else {
        setSelectedCategory('ALL');
      }
    } else if (!catParam) {
      setSelectedCategory('ALL');
    }
  }, [searchParams, categories]);

  const handleCategorySelectChange = (newCatId: string) => {
    setSelectedCategory(newCatId);
    if (newCatId === 'ALL') {
      searchParams.delete('category');
    } else {
      const foundCat = categories.find((c) => c.id === newCatId);
      if (foundCat) {
        searchParams.set('category', foundCat.slug);
      }
    }
    setSearchParams(searchParams, { replace: true });
  };

  // Filtered Products
  const filteredProducts = products.filter((p) => {
    const matchesSearch =
      p.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
      (p.brand ? p.brand.toLowerCase().includes(searchTerm.toLowerCase()) : false) ||
      p.sku.toLowerCase().includes(searchTerm.toLowerCase());

    const matchesCategory =
      selectedCategory === 'ALL' || p.categoryId === selectedCategory;

    return matchesSearch && matchesCategory;
  });

  const handleOpenCreate = () => {
    setEditingProduct(null);
    setIsModalOpen(true);
  };

  const handleOpenEdit = (product: AdminProduct) => {
    setEditingProduct(product);
    setIsModalOpen(true);
  };

  const handleConfirmDelete = async () => {
    if (!deletingProduct) return;
    setDeleteLoading(true);
    setDeleteError(null);

    try {
      await deleteAdminProduct(deletingProduct.id);
      setSuccessMessage(`Product "${deletingProduct.name}" deleted successfully.`);
      setDeletingProduct(null);
      await loadData();
      setTimeout(() => setSuccessMessage(null), 4000);
    } catch (err: any) {
      console.error('Failed to delete product:', err);
      const msg =
        err.response?.status === 409
          ? err.response?.data?.message ||
            'Cannot delete a product with existing orders. Consider marking it out of stock instead.'
          : err.response?.data?.message || 'Failed to delete product';
      setDeleteError(msg);
    } finally {
      setDeleteLoading(false);
    }
  };

  const handleQuickStockUpdate = async (product: AdminProduct, sizeLabel: string, currentStock: number) => {
    const newStockStr = prompt(
      `Update stock quantity for SKU ${product.sku} (Size ${sizeLabel}):`,
      currentStock.toString()
    );
    if (newStockStr === null) return;
    const newStock = parseInt(newStockStr, 10);
    if (isNaN(newStock) || newStock < 0) {
      alert('Please enter a valid non-negative integer for stock.');
      return;
    }

    try {
      await updateAdminProductStock(product.id, sizeLabel, newStock);
      setSuccessMessage(`Stock updated for ${product.name} (${sizeLabel}: ${newStock})`);
      await loadData();
      setTimeout(() => setSuccessMessage(null), 3000);
    } catch (err: any) {
      alert(err.response?.data?.message || 'Failed to update stock');
    }
  };

  if (loading && products.length === 0) {
    return (
      <div className="min-h-[400px] flex flex-col items-center justify-center p-12 text-center space-y-4">
        <Loader2 className="w-10 h-10 text-[#6C63FF] animate-spin" />
        <p className="text-gray-500 font-medium text-sm">Loading product catalog...</p>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      {/* Header Banner */}
      <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
        <div>
          <h1 className="text-2xl font-bold text-gray-900 m-0">Product Catalog</h1>
          <p className="text-gray-500 text-sm mt-1">
            Manage clothing items, sizes, colors, pricing, and stock levels ({products.length} total items).
          </p>
        </div>

        <button
          onClick={handleOpenCreate}
          className="py-3 px-5 bg-[#6C63FF] hover:bg-[#5a52e0] text-white font-semibold rounded-xl shadow-lg shadow-[#6C63FF]/20 transition-all flex items-center justify-center gap-2 cursor-pointer shrink-0"
        >
          <Plus className="w-5 h-5" />
          Add Product
        </button>
      </div>

      {/* Success Notification Alert */}
      {successMessage && (
        <div className="bg-emerald-50 border border-emerald-200 text-emerald-800 px-4 py-3 rounded-xl flex items-center justify-between text-sm shadow-xs animate-in fade-in">
          <div className="flex items-center gap-2">
            <CheckCircle2 className="w-5 h-5 text-[#22C55E]" />
            <span className="font-semibold">{successMessage}</span>
          </div>
          <button onClick={() => setSuccessMessage(null)} className="text-emerald-600 hover:text-emerald-900">
            ×
          </button>
        </div>
      )}

      {/* Error State */}
      {error && (
        <div className="bg-red-50 border border-red-200 text-red-700 p-4 rounded-xl flex items-center justify-between text-sm">
          <span>{error}</span>
          <button onClick={loadData} className="font-semibold text-red-800 underline">
            Retry
          </button>
        </div>
      )}

      {/* Filters & Search Header */}
      <div className="bg-white p-4 rounded-2xl border border-gray-100 shadow-xs flex flex-col md:flex-row md:items-center md:justify-between gap-4">
        <div className="relative flex-1 max-w-md">
          <Search className="w-4 h-4 text-gray-400 absolute left-3.5 top-1/2 -translate-y-1/2" />
          <input
            type="text"
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
            placeholder="Search by title, brand, or SKU..."
            className="w-full pl-10 pr-4 py-2.5 bg-gray-50 border border-gray-200 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-[#6C63FF] focus:bg-white"
          />
        </div>

        <div className="flex items-center gap-3">
          <select
            value={selectedCategory}
            onChange={(e) => handleCategorySelectChange(e.target.value)}
            className="px-4 py-2.5 bg-gray-50 border border-gray-200 rounded-xl text-sm text-gray-700 focus:outline-none focus:ring-2 focus:ring-[#6C63FF] cursor-pointer"
          >
            <option value="ALL">All Categories ({categories.length})</option>
            {categories.map((cat) => (
              <option key={cat.id} value={cat.id}>
                {cat.name}
              </option>
            ))}
          </select>
        </div>
      </div>

      {/* Products Table */}
      <div className="bg-white rounded-2xl border border-gray-100 shadow-xs overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full text-left border-collapse">
            <thead>
              <tr className="bg-gray-50 border-b border-gray-200/80 text-xs font-semibold uppercase tracking-wider text-gray-500">
                <th className="py-4 px-6">Product</th>
                <th className="py-4 px-4">Category</th>
                <th className="py-4 px-4">Price (ETB)</th>
                <th className="py-4 px-4">Total Stock</th>
                <th className="py-4 px-4">SKU</th>
                <th className="py-4 px-4">Badges</th>
                <th className="py-4 px-6 text-right">Actions</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-gray-100 text-sm">
              {filteredProducts.map((product) => {
                const isLowStock = product.stock < 5;
                return (
                  <tr key={product.id} className="hover:bg-gray-50/60 transition-all">
                    {/* Product Cell */}
                    <td className="py-4 px-6">
                      <div className="flex items-center gap-3.5">
                        <img
                          src={product.thumbnailUrl || 'https://picsum.photos/seed/placeholder/200/200'}
                          alt={product.name}
                          className="w-12 h-12 rounded-xl object-cover border border-gray-200 shrink-0 bg-gray-100"
                        />
                        <div>
                          <div className="font-bold text-gray-900 leading-tight">{product.name}</div>
                          {product.brand ? (
                            <div className="text-xs text-gray-400 mt-0.5">{product.brand}</div>
                          ) : (
                            <div className="text-xs text-gray-400 italic mt-0.5">No brand</div>
                          )}
                        </div>
                      </div>
                    </td>

                    {/* Category Cell */}
                    <td className="py-4 px-4">
                      <span className="px-3 py-1 bg-purple-50 text-purple-700 font-medium text-xs rounded-full border border-purple-200">
                        {product.categoryName}
                      </span>
                    </td>

                    {/* Price Cell */}
                    <td className="py-4 px-4">
                      {product.discountPrice ? (
                        <div>
                          <span className="font-bold text-[#6C63FF]">
                            ETB {product.discountPrice.toLocaleString()}
                          </span>
                          <span className="text-xs text-gray-400 line-through block">
                            ETB {product.price.toLocaleString()}
                          </span>
                        </div>
                      ) : (
                        <span className="font-bold text-gray-900">
                          ETB {product.price.toLocaleString()}
                        </span>
                      )}
                    </td>

                    {/* Stock Cell with Low-Stock Alert */}
                    <td className="py-4 px-4">
                      <div className="flex flex-col items-start gap-1">
                        {isLowStock ? (
                          <span className="px-2.5 py-1 bg-red-50 text-red-700 font-bold text-xs rounded-lg border border-red-200 flex items-center gap-1 shadow-2xs">
                            <AlertTriangle className="w-3.5 h-3.5 text-red-500" />
                            Low Stock: {product.stock}
                          </span>
                        ) : (
                          <span className="font-semibold text-gray-800">{product.stock} units</span>
                        )}

                        <div className="flex items-center gap-1 flex-wrap text-[11px] text-gray-500">
                          {product.sizes.map((sz) => (
                            <button
                              key={sz.label}
                              onClick={() => handleQuickStockUpdate(product, sz.label, sz.stock)}
                              title="Click to quickly update stock"
                              className="px-1.5 py-0.5 bg-gray-100 hover:bg-[#6C63FF]/10 hover:text-[#6C63FF] rounded border border-gray-200 transition-all cursor-pointer"
                            >
                              {sz.label}: {sz.stock}
                            </button>
                          ))}
                        </div>
                      </div>
                    </td>

                    {/* SKU Cell */}
                    <td className="py-4 px-4">
                      <code className="text-xs font-mono bg-gray-100 px-2 py-1 rounded border border-gray-200 text-gray-700">
                        {product.sku}
                      </code>
                    </td>

                    {/* Badges Cell */}
                    <td className="py-4 px-4">
                      <div className="flex items-center gap-1 flex-wrap">
                        {product.isFlashSale && <span title="Flash Sale">⚡</span>}
                        {product.isNewArrival && <span title="New Arrival">✨</span>}
                        {product.isTrending && <span title="Trending">🔥</span>}
                        {product.isBestSeller && <span title="Best Seller">🏆</span>}
                      </div>
                    </td>

                    {/* Action Buttons */}
                    <td className="py-4 px-6 text-right">
                      <div className="flex items-center justify-end gap-2">
                        <button
                          onClick={() => handleOpenEdit(product)}
                          className="p-2 text-gray-500 hover:text-[#6C63FF] hover:bg-gray-100 rounded-xl transition-all cursor-pointer"
                          title="Edit Product"
                        >
                          <Edit2 className="w-4 h-4" />
                        </button>
                        <button
                          onClick={() => {
                            setDeleteError(null);
                            setDeletingProduct(product);
                          }}
                          className="p-2 text-gray-500 hover:text-red-600 hover:bg-red-50 rounded-xl transition-all cursor-pointer"
                          title="Delete Product"
                        >
                          <Trash2 className="w-4 h-4" />
                        </button>
                      </div>
                    </td>
                  </tr>
                );
              })}

              {filteredProducts.length === 0 && (
                <tr>
                  <td colSpan={7} className="py-12 text-center text-gray-500">
                    <Package className="w-8 h-8 text-gray-300 mx-auto mb-2" />
                    <p className="font-semibold text-sm m-0">No products found</p>
                    <p className="text-xs text-gray-400 mt-1">
                      Try adjusting your search criteria or category filter.
                    </p>
                  </td>
                </tr>
              )}
            </tbody>
          </table>
        </div>
      </div>

      {/* Delete Confirmation Modal */}
      {deletingProduct && (
        <div className="fixed inset-0 z-50 bg-black/50 backdrop-blur-xs flex items-center justify-center p-4">
          <div className="bg-white rounded-2xl shadow-xl max-w-md w-full p-6 space-y-4 animate-in fade-in zoom-in-95">
            <div className="w-12 h-12 bg-red-100 text-red-600 rounded-2xl flex items-center justify-center mx-auto">
              <AlertTriangle className="w-6 h-6" />
            </div>

            <div className="text-center space-y-2">
              <h3 className="text-lg font-bold text-gray-900 m-0">Delete Product?</h3>
              <p className="text-sm text-gray-500">
                Are you sure you want to delete{' '}
                <span className="font-bold text-gray-900">"{deletingProduct.name}"</span> (SKU:{' '}
                {deletingProduct.sku})? This action cannot be undone.
              </p>
            </div>

            {/* 409 Conflict / Order Error Alert */}
            {deleteError && (
              <div className="bg-red-50 border border-red-200 text-red-700 p-3 rounded-xl text-xs flex items-start gap-2 text-left">
                <AlertCircle className="w-4 h-4 text-red-500 shrink-0 mt-0.5" />
                <span>{deleteError}</span>
              </div>
            )}

            <div className="flex items-center gap-3 pt-2">
              <button
                type="button"
                disabled={deleteLoading}
                onClick={() => {
                  setDeletingProduct(null);
                  setDeleteError(null);
                }}
                className="flex-1 py-2.5 border border-gray-300 text-gray-700 rounded-xl text-sm font-semibold hover:bg-gray-100 transition-all cursor-pointer"
              >
                Cancel
              </button>

              <button
                type="button"
                disabled={deleteLoading}
                onClick={handleConfirmDelete}
                className="flex-1 py-2.5 bg-red-600 hover:bg-red-700 text-white rounded-xl text-sm font-semibold transition-all flex items-center justify-center gap-2 cursor-pointer disabled:opacity-70"
              >
                {deleteLoading ? (
                  <>
                    <Loader2 className="w-4 h-4 animate-spin" />
                    Deleting...
                  </>
                ) : (
                  'Delete Product'
                )}
              </button>
            </div>
          </div>
        </div>
      )}

      {/* Product Form Modal (Create / Edit) */}
      <ProductFormModal
        isOpen={isModalOpen}
        product={editingProduct}
        categories={categories}
        onClose={() => setIsModalOpen(false)}
        onSuccess={loadData}
      />
    </div>
  );
};
