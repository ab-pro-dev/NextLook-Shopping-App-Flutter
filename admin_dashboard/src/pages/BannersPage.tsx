import React, { useState, useEffect } from 'react';
import {
  type AdminBanner,
  type Category,
  type AdminProduct,
  type BannerPayload,
  fetchAdminBanners,
  fetchAdminCategories,
  fetchAdminProducts,
  createAdminBanner,
  updateAdminBanner,
  deleteAdminBanner,
} from '../services/api';
import { ImageUploadField } from '../components/ImageUploadField';
import {
  Image as ImageIcon,
  Plus,
  Edit2,
  Trash2,
  Loader2,
  AlertCircle,
  CheckCircle2,
  AlertTriangle,
  ArrowUpDown,
  X,
  Tag,
  ShoppingBag,
} from 'lucide-react';

export const BannersPage: React.FC = () => {
  const [banners, setBanners] = useState<AdminBanner[]>([]);
  const [categories, setCategories] = useState<Category[]>([]);
  const [products, setProducts] = useState<AdminProduct[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [successMessage, setSuccessMessage] = useState<string | null>(null);

  // Modal State
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [editingBanner, setEditingBanner] = useState<AdminBanner | null>(null);

  // Form Fields
  const [title, setTitle] = useState('');
  const [subtitle, setSubtitle] = useState('');
  const [buttonText, setButtonText] = useState('');
  const [imageUrl, setImageUrl] = useState('');
  const [targetType, setTargetType] = useState<'none' | 'category' | 'product'>('none');
  const [categorySlug, setCategorySlug] = useState('');
  const [targetProductId, setTargetProductId] = useState('');
  const [sortOrder, setSortOrder] = useState<number>(0);
  const [isActive, setIsActive] = useState(true);
  const [formLoading, setFormLoading] = useState(false);
  const [formError, setFormError] = useState<string | null>(null);

  // Search filter for product selector dropdown
  const [productSearch, setProductSearch] = useState('');

  // Delete State
  const [deletingBanner, setDeletingBanner] = useState<AdminBanner | null>(null);
  const [deleteLoading, setDeleteLoading] = useState(false);

  useEffect(() => {
    loadData();
  }, []);

  const loadData = async () => {
    setLoading(true);
    setError(null);
    try {
      const [bannersData, categoriesData, productsData] = await Promise.all([
        fetchAdminBanners(),
        fetchAdminCategories(),
        fetchAdminProducts(),
      ]);
      setBanners(bannersData);
      setCategories(categoriesData);
      setProducts(productsData);
    } catch (err: any) {
      console.error('Failed to load banners:', err);
      setError(err.response?.data?.message || err.message || 'Failed to load promotional banners');
    } finally {
      setLoading(false);
    }
  };

  const handleOpenCreate = () => {
    setEditingBanner(null);
    setTitle('');
    setSubtitle('');
    setButtonText('Shop Now');
    setImageUrl('');
    setTargetType('none');
    setCategorySlug('');
    setTargetProductId('');
    setSortOrder(banners.length);
    setIsActive(true);
    setFormError(null);
    setProductSearch('');
    setIsModalOpen(true);
  };

  const handleOpenEdit = (banner: AdminBanner) => {
    setEditingBanner(banner);
    setTitle(banner.title);
    setSubtitle(banner.subtitle || '');
    setButtonText(banner.buttonText || '');
    setImageUrl(banner.imageUrl);

    if (banner.targetProductId) {
      setTargetType('product');
      setTargetProductId(banner.targetProductId);
      setCategorySlug('');
    } else if (banner.categorySlug) {
      setTargetType('category');
      setCategorySlug(banner.categorySlug);
      setTargetProductId('');
    } else {
      setTargetType('none');
      setCategorySlug('');
      setTargetProductId('');
    }

    setSortOrder(banner.sortOrder);
    setIsActive(banner.isActive);
    setFormError(null);
    setProductSearch('');
    setIsModalOpen(true);
  };

  const handleToggleActive = async (banner: AdminBanner) => {
    try {
      const updated = await updateAdminBanner(banner.id, { isActive: !banner.isActive });
      setBanners(banners.map((b) => (b.id === banner.id ? updated : b)));
      setSuccessMessage(`Banner "${banner.title}" status updated.`);
      setTimeout(() => setSuccessMessage(null), 3000);
    } catch (err: any) {
      alert(err.response?.data?.message || 'Failed to toggle banner status');
    }
  };

  const handleSubmitForm = async (e: React.FormEvent) => {
    e.preventDefault();
    setFormError(null);

    if (!title.trim()) {
      setFormError('Banner title is required.');
      return;
    }
    if (!imageUrl.trim()) {
      setFormError('Please upload a banner image.');
      return;
    }

    if (targetType === 'category' && !categorySlug.trim()) {
      setFormError('Please select a target category.');
      return;
    }
    if (targetType === 'product' && !targetProductId.trim()) {
      setFormError('Please select a target product.');
      return;
    }

    const payload: BannerPayload = {
      title: title.trim(),
      imageUrl: imageUrl.trim(),
      subtitle: subtitle.trim() || null,
      buttonText: buttonText.trim() || null,
      categorySlug: targetType === 'category' ? categorySlug.trim() || null : null,
      targetProductId: targetType === 'product' ? targetProductId.trim() || null : null,
      sortOrder: Number(sortOrder) || 0,
      isActive,
    };

    setFormLoading(true);
    try {
      if (editingBanner) {
        await updateAdminBanner(editingBanner.id, payload);
        setSuccessMessage(`Banner "${title}" updated successfully!`);
      } else {
        await createAdminBanner(payload);
        setSuccessMessage(`New banner "${title}" created successfully!`);
      }
      await loadData();
      setIsModalOpen(false);
      setTimeout(() => setSuccessMessage(null), 4000);
    } catch (err: any) {
      console.error('Banner form submit error:', err);
      setFormError(err.response?.data?.message || err.message || 'Failed to save banner');
    } finally {
      setFormLoading(false);
    }
  };

  const handleConfirmDelete = async () => {
    if (!deletingBanner) return;

    setDeleteLoading(true);
    try {
      await deleteAdminBanner(deletingBanner.id);
      setSuccessMessage(`Banner "${deletingBanner.title}" deleted successfully.`);
      await loadData();
      setDeletingBanner(null);
      setTimeout(() => setSuccessMessage(null), 4000);
    } catch (err: any) {
      alert(err.response?.data?.message || 'Failed to delete banner');
    } finally {
      setDeleteLoading(false);
    }
  };

  const filteredProducts = products.filter(
    (p) =>
      p.name.toLowerCase().includes(productSearch.toLowerCase()) ||
      p.brand.toLowerCase().includes(productSearch.toLowerCase()) ||
      p.id.toLowerCase().includes(productSearch.toLowerCase())
  );

  const getProductName = (id?: string | null) => {
    if (!id) return '';
    const match = products.find((p) => p.id === id);
    return match ? match.name : id.slice(0, 8);
  };

  if (loading && banners.length === 0) {
    return (
      <div className="min-h-[400px] flex flex-col items-center justify-center p-12 text-center space-y-4">
        <Loader2 className="w-10 h-10 text-[#6C63FF] animate-spin" />
        <p className="text-gray-500 font-medium text-sm">Loading promotional banners...</p>
      </div>
    );
  }

  return (
    <div className="space-y-6 pb-12">
      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
        <div>
          <h1 className="text-2xl font-bold text-gray-900 m-0">Promotional Banners</h1>
          <p className="text-gray-500 text-sm mt-1">
            Manage carousel hero banners displayed on the customer mobile app home screen ({banners.length} total).
          </p>
        </div>

        <button
          onClick={handleOpenCreate}
          className="py-3 px-5 bg-[#6C63FF] hover:bg-[#5a52e0] text-white font-semibold rounded-xl shadow-lg shadow-[#6C63FF]/20 transition-all flex items-center justify-center gap-2 cursor-pointer shrink-0"
        >
          <Plus className="w-5 h-5" />
          Add Banner
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

      {/* Error Alert */}
      {error && (
        <div className="bg-red-50 border border-red-200 text-red-700 p-4 rounded-xl flex items-center justify-between text-sm">
          <span>{error}</span>
          <button onClick={loadData} className="font-semibold text-red-800 underline">
            Retry
          </button>
        </div>
      )}

      {/* Banners Grid List */}
      <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
        {banners.map((banner) => (
          <div
            key={banner.id}
            className={`bg-white rounded-2xl border transition-all overflow-hidden flex flex-col justify-between shadow-xs ${
              banner.isActive ? 'border-gray-200' : 'border-gray-200 opacity-60 bg-gray-50/50'
            }`}
          >
            {/* Banner Image Preview Header */}
            <div className="relative h-44 bg-gray-100 overflow-hidden">
              <img
                src={banner.imageUrl}
                alt={banner.title}
                className="w-full h-full object-cover"
                onError={(e) => {
                  (e.target as HTMLElement).style.display = 'none';
                }}
              />
              <div className="absolute top-3 left-3 flex flex-wrap items-center gap-2 max-w-[70%]">
                <span className="px-2.5 py-1 bg-black/60 backdrop-blur-md text-white text-xs font-semibold rounded-lg flex items-center gap-1">
                  <ArrowUpDown className="w-3 h-3 text-[#6C63FF]" /> Order #{banner.sortOrder}
                </span>
                {banner.targetProductId ? (
                  <span className="px-2.5 py-1 bg-amber-500/90 backdrop-blur-md text-white text-xs font-semibold rounded-lg flex items-center gap-1 truncate max-w-[180px]">
                    <ShoppingBag className="w-3 h-3 shrink-0" /> {getProductName(banner.targetProductId)}
                  </span>
                ) : banner.categorySlug ? (
                  <span className="px-2.5 py-1 bg-[#6C63FF]/90 backdrop-blur-md text-white text-xs font-semibold rounded-lg flex items-center gap-1">
                    <Tag className="w-3 h-3" /> {banner.categorySlug}
                  </span>
                ) : (
                  <span className="px-2.5 py-1 bg-gray-600/70 backdrop-blur-md text-white text-xs font-semibold rounded-lg">
                    No Target Link
                  </span>
                )}
              </div>

              <div className="absolute top-3 right-3">
                <button
                  type="button"
                  onClick={() => handleToggleActive(banner)}
                  className={`px-3 py-1 text-xs font-semibold rounded-full shadow-md transition-all cursor-pointer ${
                    banner.isActive
                      ? 'bg-emerald-500 text-white hover:bg-emerald-600'
                      : 'bg-gray-700 text-gray-200 hover:bg-gray-800'
                  }`}
                >
                  {banner.isActive ? 'Active' : 'Inactive'}
                </button>
              </div>
            </div>

            {/* Banner Body Info */}
            <div className="p-5 space-y-3 flex-1 flex flex-col justify-between">
              <div>
                <h3 className="text-base font-bold text-gray-900 m-0">{banner.title}</h3>
                {banner.subtitle && <p className="text-xs text-gray-500 mt-1 m-0">{banner.subtitle}</p>}
                {banner.buttonText && (
                  <span className="inline-block mt-2 text-xs font-semibold text-[#6C63FF] bg-[#6C63FF]/10 px-2.5 py-1 rounded-lg">
                    Button: {banner.buttonText}
                  </span>
                )}
              </div>

              <div className="pt-3 border-t border-gray-100 flex items-center justify-between">
                <span className="text-[11px] text-gray-400 font-mono">
                  Created {new Date(banner.createdAt).toLocaleDateString()}
                </span>

                <div className="flex items-center gap-2">
                  <button
                    onClick={() => handleOpenEdit(banner)}
                    className="p-2 text-gray-500 hover:text-[#6C63FF] hover:bg-gray-100 rounded-xl transition-all cursor-pointer"
                    title="Edit Banner"
                  >
                    <Edit2 className="w-4 h-4" />
                  </button>
                  <button
                    onClick={() => setDeletingBanner(banner)}
                    className="p-2 text-gray-500 hover:text-red-600 hover:bg-red-50 rounded-xl transition-all cursor-pointer"
                    title="Delete Banner"
                  >
                    <Trash2 className="w-4 h-4" />
                  </button>
                </div>
              </div>
            </div>
          </div>
        ))}

        {banners.length === 0 && !loading && (
          <div className="col-span-full bg-white p-12 rounded-2xl border border-gray-100 text-center space-y-3">
            <ImageIcon className="w-10 h-10 text-gray-300 mx-auto" />
            <h3 className="text-base font-bold text-gray-800 m-0">No Promotional Banners Found</h3>
            <p className="text-xs text-gray-400 max-w-sm mx-auto">
              Create your first promotional hero banner to highlight seasonal discounts or featured collections.
            </p>
            <button
              onClick={handleOpenCreate}
              className="mt-2 py-2 px-4 bg-[#6C63FF] text-white text-xs font-semibold rounded-xl hover:bg-[#5a52e0] transition-all cursor-pointer inline-flex items-center gap-1.5"
            >
              <Plus className="w-4 h-4" /> Add First Banner
            </button>
          </div>
        )}
      </div>

      {/* Delete Confirmation Modal */}
      {deletingBanner && (
        <div className="fixed inset-0 z-50 bg-black/50 backdrop-blur-xs flex items-center justify-center p-4">
          <div className="bg-white rounded-2xl shadow-xl max-w-md w-full p-6 space-y-4 animate-in fade-in zoom-in-95">
            <div className="w-12 h-12 bg-red-100 text-red-600 rounded-2xl flex items-center justify-center mx-auto">
              <AlertTriangle className="w-6 h-6" />
            </div>

            <div className="text-center space-y-2">
              <h3 className="text-lg font-bold text-gray-900 m-0">Delete Banner?</h3>
              <p className="text-sm text-gray-500">
                Are you sure you want to delete <span className="font-bold text-gray-900">"{deletingBanner.title}"</span>?
                Its Cloudinary image asset will also be permanently removed.
              </p>
            </div>

            <div className="flex items-center gap-3 pt-2">
              <button
                type="button"
                disabled={deleteLoading}
                onClick={() => setDeletingBanner(null)}
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
                  'Delete Banner'
                )}
              </button>
            </div>
          </div>
        </div>
      )}

      {/* Add / Edit Banner Modal Slide-Over */}
      {isModalOpen && (
        <div className="fixed inset-y-0 right-0 z-50 w-full max-w-lg bg-white shadow-2xl flex flex-col border-l border-gray-200 overflow-hidden animate-in slide-in-from-right duration-300">
          <div className="h-18 px-6 bg-[#1E1E2D] text-white flex items-center justify-between shrink-0">
            <div>
              <h2 className="text-lg font-bold text-white m-0">
                {editingBanner ? 'Edit Banner' : 'Add New Banner'}
              </h2>
              <p className="text-xs text-gray-400 mt-0.5">
                {editingBanner ? `Updating Banner ID: ${editingBanner.id.slice(0, 8)}...` : 'Configure promotional banner specs'}
              </p>
            </div>
            <button
              onClick={() => setIsModalOpen(false)}
              className="p-2 text-gray-400 hover:text-white rounded-xl hover:bg-gray-800 transition-all cursor-pointer"
            >
              <X className="w-5 h-5" />
            </button>
          </div>

          <form onSubmit={handleSubmitForm} className="flex-1 overflow-y-auto p-6 space-y-5">
            {formError && (
              <div className="bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded-xl flex items-start gap-3 text-sm">
                <AlertCircle className="w-5 h-5 text-red-500 shrink-0 mt-0.5" />
                <span>{formError}</span>
              </div>
            )}

            {/* Image Upload Field */}
            <div>
              <label className="block text-xs font-semibold text-gray-700 uppercase tracking-wider mb-2">
                Banner Image <span className="text-red-500">*</span>
              </label>
              <ImageUploadField
                value={imageUrl}
                folder="banners"
                onChange={(newUrl) => setImageUrl(newUrl)}
                onRemove={() => setImageUrl('')}
              />
            </div>

            <div>
              <label className="block text-xs font-semibold text-gray-700 mb-1">
                Banner Title <span className="text-red-500">*</span>
              </label>
              <input
                type="text"
                required
                value={title}
                onChange={(e) => setTitle(e.target.value)}
                placeholder="e.g. Summer Special Offer 50% Off"
                className="w-full px-3.5 py-2.5 bg-gray-50 border border-gray-200 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-[#6C63FF] focus:bg-white"
              />
            </div>

            <div>
              <label className="block text-xs font-semibold text-gray-700 mb-1">Subtitle (Optional)</label>
              <input
                type="text"
                value={subtitle}
                onChange={(e) => setSubtitle(e.target.value)}
                placeholder="e.g. Discover premium leather jacket arrivals"
                className="w-full px-3.5 py-2.5 bg-gray-50 border border-gray-200 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-[#6C63FF] focus:bg-white"
              />
            </div>

            <div>
              <label className="block text-xs font-semibold text-gray-700 mb-1">Button Action Text</label>
              <input
                type="text"
                value={buttonText}
                onChange={(e) => setButtonText(e.target.value)}
                placeholder="e.g. Shop Now"
                className="w-full px-3.5 py-2.5 bg-gray-50 border border-gray-200 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-[#6C63FF] focus:bg-white"
              />
            </div>

            {/* Target Navigation Selection */}
            <div className="space-y-3 p-4 bg-gray-50 rounded-2xl border border-gray-200">
              <label className="block text-xs font-semibold text-gray-800 uppercase tracking-wider">
                Click Navigation Action
              </label>

              <div className="grid grid-cols-3 gap-2">
                <button
                  type="button"
                  onClick={() => {
                    setTargetType('none');
                    setCategorySlug('');
                    setTargetProductId('');
                  }}
                  className={`py-2 px-3 text-xs font-bold rounded-xl transition-all border cursor-pointer ${
                    targetType === 'none'
                      ? 'bg-[#1E1E2D] text-white border-[#1E1E2D]'
                      : 'bg-white text-gray-700 border-gray-200 hover:bg-gray-100'
                  }`}
                >
                  None
                </button>

                <button
                  type="button"
                  onClick={() => {
                    setTargetType('category');
                    setTargetProductId('');
                  }}
                  className={`py-2 px-3 text-xs font-bold rounded-xl transition-all border cursor-pointer flex items-center justify-center gap-1 ${
                    targetType === 'category'
                      ? 'bg-[#6C63FF] text-white border-[#6C63FF]'
                      : 'bg-white text-gray-700 border-gray-200 hover:bg-gray-100'
                  }`}
                >
                  <Tag className="w-3.5 h-3.5" /> Category
                </button>

                <button
                  type="button"
                  onClick={() => {
                    setTargetType('product');
                    setCategorySlug('');
                  }}
                  className={`py-2 px-3 text-xs font-bold rounded-xl transition-all border cursor-pointer flex items-center justify-center gap-1 ${
                    targetType === 'product'
                      ? 'bg-amber-500 text-white border-amber-500'
                      : 'bg-white text-gray-700 border-gray-200 hover:bg-gray-100'
                  }`}
                >
                  <ShoppingBag className="w-3.5 h-3.5" /> Product
                </button>
              </div>

              {/* Target Category Select */}
              {targetType === 'category' && (
                <div className="pt-2">
                  <label className="block text-xs font-semibold text-gray-700 mb-1">
                    Select Target Category <span className="text-red-500">*</span>
                  </label>
                  <select
                    value={categorySlug}
                    onChange={(e) => setCategorySlug(e.target.value)}
                    className="w-full px-3.5 py-2.5 bg-white border border-gray-200 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-[#6C63FF] cursor-pointer"
                  >
                    <option value="">-- Choose Category --</option>
                    {categories.map((cat) => (
                      <option key={cat.id} value={cat.slug}>
                        {cat.name} ({cat.slug})
                      </option>
                    ))}
                  </select>
                </div>
              )}

              {/* Searchable Target Product Select */}
              {targetType === 'product' && (
                <div className="pt-2 space-y-2">
                  <label className="block text-xs font-semibold text-gray-700">
                    Select Target Product <span className="text-red-500">*</span>
                  </label>
                  <input
                    type="text"
                    value={productSearch}
                    onChange={(e) => setProductSearch(e.target.value)}
                    placeholder="Search product name or brand..."
                    className="w-full px-3.5 py-2 bg-white border border-gray-200 rounded-xl text-xs focus:outline-none focus:ring-2 focus:ring-amber-500"
                  />
                  <select
                    value={targetProductId}
                    onChange={(e) => setTargetProductId(e.target.value)}
                    size={4}
                    className="w-full px-3 py-2 bg-white border border-gray-200 rounded-xl text-xs focus:outline-none focus:ring-2 focus:ring-amber-500 cursor-pointer max-h-36 overflow-y-auto"
                  >
                    {filteredProducts.map((p) => (
                      <option key={p.id} value={p.id} className="py-1">
                        {p.name} — ${p.price} ({p.brand})
                      </option>
                    ))}
                    {filteredProducts.length === 0 && (
                      <option disabled value="">
                        No products match search
                      </option>
                    )}
                  </select>
                  {targetProductId && (
                    <p className="text-[11px] text-amber-700 font-medium m-0">
                      Selected: {getProductName(targetProductId)}
                    </p>
                  )}
                </div>
              )}
            </div>

            <div className="grid grid-cols-2 gap-4">
              <div>
                <label className="block text-xs font-semibold text-gray-700 mb-1">Display Sort Order</label>
                <input
                  type="number"
                  min={0}
                  required
                  value={sortOrder}
                  onChange={(e) => setSortOrder(Number(e.target.value))}
                  placeholder="0"
                  className="w-full px-3.5 py-2.5 bg-gray-50 border border-gray-200 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-[#6C63FF] focus:bg-white"
                />
              </div>

              <div className="flex flex-col justify-end">
                <label className="flex items-center gap-2.5 p-2.5 bg-gray-50 rounded-xl border border-gray-200 cursor-pointer text-xs font-semibold text-gray-800">
                  <input
                    type="checkbox"
                    checked={isActive}
                    onChange={(e) => setIsActive(e.target.checked)}
                    className="w-4 h-4 text-[#6C63FF] rounded focus:ring-[#6C63FF]"
                  />
                  Active & Displayed
                </label>
              </div>
            </div>

            <div className="pt-4 border-t border-gray-200 flex items-center justify-end gap-3 sticky bottom-0 bg-white py-3">
              <button
                type="button"
                onClick={() => setIsModalOpen(false)}
                className="px-5 py-2.5 border border-gray-300 text-gray-700 rounded-xl text-sm font-semibold hover:bg-gray-100 transition-all cursor-pointer"
              >
                Cancel
              </button>

              <button
                type="submit"
                disabled={formLoading}
                className="px-6 py-2.5 bg-[#6C63FF] hover:bg-[#5a52e0] text-white rounded-xl text-sm font-semibold shadow-md shadow-[#6C63FF]/20 transition-all flex items-center gap-2 cursor-pointer disabled:opacity-70"
              >
                {formLoading ? (
                  <>
                    <Loader2 className="w-4 h-4 animate-spin" />
                    Saving Banner...
                  </>
                ) : editingBanner ? (
                  'Update Banner'
                ) : (
                  'Create Banner'
                )}
              </button>
            </div>
          </form>
        </div>
      )}
    </div>
  );
};
