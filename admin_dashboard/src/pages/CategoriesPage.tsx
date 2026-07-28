import React, { useEffect, useState } from 'react';
import {
  type Category,
  fetchAdminCategories,
  deleteAdminCategory,
} from '../services/api';
import { CategoryFormModal } from '../components/CategoryFormModal';
import { useNavigate } from 'react-router-dom';
import {
  Plus,
  Search,
  Edit2,
  Trash2,
  Loader2,
  Tag,
  AlertTriangle,
  AlertCircle,
  CheckCircle2,
  ArrowRight,
  Shirt,
  User,
  Smile,
  Footprints,
  Watch,
  ShoppingBag,
  Zap,
} from 'lucide-react';

const ICON_MAP: Record<string, React.ElementType> = {
  shirt: Shirt,
  user: User,
  smile: Smile,
  footprints: Footprints,
  watch: Watch,
  'shopping-bag': ShoppingBag,
  tag: Tag,
  zap: Zap,
};

export const CategoriesPage: React.FC = () => {
  const navigate = useNavigate();
  const [categories, setCategories] = useState<Category[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const [searchTerm, setSearchTerm] = useState('');

  // Modal State
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [editingCategory, setEditingCategory] = useState<Category | null>(null);

  // Delete State
  const [deletingCategory, setDeletingCategory] = useState<Category | null>(null);
  const [deleteLoading, setDeleteLoading] = useState(false);
  const [deleteError, setDeleteError] = useState<string | null>(null);
  const [successMessage, setSuccessMessage] = useState<string | null>(null);

  const loadCategories = async () => {
    try {
      setLoading(true);
      setError(null);
      const data = await fetchAdminCategories();
      setCategories(data);
    } catch (err: any) {
      console.error('Failed to load admin categories:', err);
      setError(err.response?.data?.message || err.message || 'Failed to load categories');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    loadCategories();
  }, []);

  const filteredCategories = categories.filter(
    (c) =>
      c.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
      c.slug.toLowerCase().includes(searchTerm.toLowerCase())
  );

  const handleOpenCreate = () => {
    setEditingCategory(null);
    setIsModalOpen(true);
  };

  const handleOpenEdit = (cat: Category) => {
    setEditingCategory(cat);
    setIsModalOpen(true);
  };

  const handleConfirmDelete = async () => {
    if (!deletingCategory) return;
    setDeleteLoading(true);
    setDeleteError(null);

    try {
      await deleteAdminCategory(deletingCategory.id);
      setSuccessMessage(`Category "${deletingCategory.name}" deleted successfully.`);
      setDeletingCategory(null);
      await loadCategories();
      setTimeout(() => setSuccessMessage(null), 4000);
    } catch (err: any) {
      console.error('Failed to delete category:', err);
      const msg =
        err.response?.status === 409
          ? err.response?.data?.message ||
            'Cannot delete a category with existing products. Reassign or delete those products first.'
          : err.response?.data?.message || 'Failed to delete category';
      setDeleteError(msg);
    } finally {
      setDeleteLoading(false);
    }
  };

  if (loading && categories.length === 0) {
    return (
      <div className="min-h-[400px] flex flex-col items-center justify-center p-12 text-center space-y-4">
        <Loader2 className="w-10 h-10 text-[#6C63FF] animate-spin" />
        <p className="text-gray-500 font-medium text-sm">Loading categories...</p>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      {/* Header Banner */}
      <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
        <div>
          <h1 className="text-2xl font-bold text-gray-900 m-0">Apparel Categories</h1>
          <p className="text-gray-500 text-sm mt-1">
            Manage clothing categories, icon assignments, and product counts ({categories.length} total).
          </p>
        </div>

        <button
          onClick={handleOpenCreate}
          className="py-3 px-5 bg-[#6C63FF] hover:bg-[#5a52e0] text-white font-semibold rounded-xl shadow-lg shadow-[#6C63FF]/20 transition-all flex items-center justify-center gap-2 cursor-pointer shrink-0"
        >
          <Plus className="w-5 h-5" />
          Add Category
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
          <button onClick={loadCategories} className="font-semibold text-red-800 underline">
            Retry
          </button>
        </div>
      )}

      {/* Search Header */}
      <div className="bg-white p-4 rounded-2xl border border-gray-100 shadow-xs flex items-center justify-between">
        <div className="relative flex-1 max-w-md">
          <Search className="w-4 h-4 text-gray-400 absolute left-3.5 top-1/2 -translate-y-1/2" />
          <input
            type="text"
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
            placeholder="Search by category name or slug..."
            className="w-full pl-10 pr-4 py-2.5 bg-gray-50 border border-gray-200 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-[#6C63FF] focus:bg-white"
          />
        </div>
      </div>

      {/* Categories Table */}
      <div className="bg-white rounded-2xl border border-gray-100 shadow-xs overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full text-left border-collapse">
            <thead>
              <tr className="bg-gray-50 border-b border-gray-200/80 text-xs font-semibold uppercase tracking-wider text-gray-500">
                <th className="py-4 px-6">Category</th>
                <th className="py-4 px-4">URL Slug</th>
                <th className="py-4 px-4">Icon Token</th>
                <th className="py-4 px-4">Assigned Products</th>
                <th className="py-4 px-6 text-right">Actions</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-gray-100 text-sm">
              {filteredCategories.map((category) => {
                const IconComp = ICON_MAP[category.iconName?.toLowerCase()] || Tag;
                const prodCount = category.productCount || 0;
                return (
                  <tr key={category.id} className="hover:bg-gray-50/70 transition-all">
                    {/* Name Cell */}
                    <td className="py-4 px-6">
                      <div className="flex items-center gap-3">
                        <div className="w-10 h-10 bg-purple-50 text-[#6C63FF] border border-purple-200 rounded-xl flex items-center justify-center shrink-0">
                          <IconComp className="w-5 h-5" />
                        </div>
                        <div className="font-bold text-gray-900">{category.name}</div>
                      </div>
                    </td>

                    {/* Slug Cell */}
                    <td className="py-4 px-4">
                      <code className="text-xs font-mono bg-gray-100 px-2.5 py-1 rounded-lg border border-gray-200 text-gray-700">
                        {category.slug}
                      </code>
                    </td>

                    {/* Icon Token Cell */}
                    <td className="py-4 px-4 text-xs font-mono text-gray-500">
                      {category.iconName}
                    </td>

                    {/* Product Count Cell (links to Products page with slug query param) */}
                    <td className="py-4 px-4">
                      <button
                        onClick={() => navigate(`/products?category=${category.slug}`)}
                        className="px-3 py-1 bg-gray-100 hover:bg-[#6C63FF]/10 hover:text-[#6C63FF] rounded-lg text-xs font-semibold text-gray-700 border border-gray-200 transition-all flex items-center gap-1.5 cursor-pointer"
                        title={`View ${category.name} products`}
                      >
                        <span>{prodCount} products</span>
                        <ArrowRight className="w-3 h-3 text-gray-400" />
                      </button>
                    </td>

                    {/* Actions */}
                    <td className="py-4 px-6 text-right">
                      <div className="flex items-center justify-end gap-2">
                        <button
                          onClick={() => handleOpenEdit(category)}
                          className="p-2 text-gray-500 hover:text-[#6C63FF] hover:bg-gray-100 rounded-xl transition-all cursor-pointer"
                          title="Edit Category"
                        >
                          <Edit2 className="w-4 h-4" />
                        </button>
                        <button
                          onClick={() => {
                            setDeleteError(null);
                            setDeletingCategory(category);
                          }}
                          className="p-2 text-gray-500 hover:text-red-600 hover:bg-red-50 rounded-xl transition-all cursor-pointer"
                          title="Delete Category"
                        >
                          <Trash2 className="w-4 h-4" />
                        </button>
                      </div>
                    </td>
                  </tr>
                );
              })}

              {filteredCategories.length === 0 && (
                <tr>
                  <td colSpan={5} className="py-12 text-center text-gray-500">
                    <Tag className="w-8 h-8 text-gray-300 mx-auto mb-2" />
                    <p className="font-semibold text-sm m-0">No categories found</p>
                  </td>
                </tr>
              )}
            </tbody>
          </table>
        </div>
      </div>

      {/* Delete Confirmation Modal */}
      {deletingCategory && (
        <div className="fixed inset-0 z-50 bg-black/50 backdrop-blur-xs flex items-center justify-center p-4">
          <div className="bg-white rounded-2xl shadow-xl max-w-md w-full p-6 space-y-4 animate-in fade-in zoom-in-95">
            <div className="w-12 h-12 bg-red-100 text-red-600 rounded-2xl flex items-center justify-center mx-auto">
              <AlertTriangle className="w-6 h-6" />
            </div>

            <div className="text-center space-y-2">
              <h3 className="text-lg font-bold text-gray-900 m-0">Delete Category?</h3>
              <p className="text-sm text-gray-500">
                Are you sure you want to delete category{' '}
                <span className="font-bold text-gray-900">"{deletingCategory.name}"</span> (slug:{' '}
                {deletingCategory.slug})?
              </p>
            </div>

            {/* 409 Conflict Error Alert */}
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
                  setDeletingCategory(null);
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
                  'Delete Category'
                )}
              </button>
            </div>
          </div>
        </div>
      )}

      {/* Category Form Modal (Create / Edit) */}
      <CategoryFormModal
        isOpen={isModalOpen}
        category={editingCategory}
        onClose={() => setIsModalOpen(false)}
        onSuccess={loadCategories}
      />
    </div>
  );
};
