import React, { useState, useEffect } from 'react';
import {
  type AdminProduct,
  type Category,
  type ProductPayload,
  createAdminProduct,
  updateAdminProduct,
} from '../services/api';
import { ImageUploadField } from './ImageUploadField';
import { X, Plus, Trash2, Loader2, AlertCircle, Image as ImageIcon, Palette, Ruler } from 'lucide-react';

interface ProductFormModalProps {
  product?: AdminProduct | null;
  categories: Category[];
  isOpen: boolean;
  onClose: () => void;
  onSuccess: () => void;
}

export const ProductFormModal: React.FC<ProductFormModalProps> = ({
  product,
  categories,
  isOpen,
  onClose,
  onSuccess,
}) => {
  const isEditing = Boolean(product);

  const [name, setName] = useState('');
  const [description, setDescription] = useState('');
  const [brand, setBrand] = useState('');
  const [categoryId, setCategoryId] = useState('');
  const [price, setPrice] = useState<number | ''>('');
  const [discountPrice, setDiscountPrice] = useState<number | ''>('');
  const [sku, setSku] = useState('');
  const [weight, setWeight] = useState<number | ''>('');

  const [isFlashSale, setIsFlashSale] = useState(false);
  const [isNewArrival, setIsNewArrival] = useState(false);
  const [isTrending, setIsTrending] = useState(false);
  const [isBestSeller, setIsBestSeller] = useState(false);

  const [images, setImages] = useState<{ url: string; sortOrder: number }[]>([
    { url: '', sortOrder: 0 },
  ]);
  const [colors, setColors] = useState<{ name: string; hexCode: string }[]>([
    { name: 'Black', hexCode: '#000000' },
  ]);
  const [sizes, setSizes] = useState<{ label: string; stock: number }[]>([
    { label: 'S', stock: 10 },
    { label: 'M', stock: 15 },
    { label: 'L', stock: 10 },
  ]);

  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    if (product) {
      setName(product.name);
      setDescription(product.description);
      setBrand(product.brand);
      setCategoryId(product.categoryId);
      setPrice(product.price);
      setDiscountPrice(product.discountPrice ?? '');
      setSku(product.sku);
      setWeight(product.weight ?? '');
      setIsFlashSale(product.isFlashSale);
      setIsNewArrival(product.isNewArrival);
      setIsTrending(product.isTrending);
      setIsBestSeller(product.isBestSeller);

      setImages(
        product.images.length > 0
          ? product.images.map((img, idx) => ({ url: img.url, sortOrder: img.sortOrder ?? idx }))
          : [{ url: '', sortOrder: 0 }]
      );
      setColors(
        product.colors.length > 0
          ? product.colors.map((c) => ({ name: c.name, hexCode: c.hexCode }))
          : [{ name: 'Black', hexCode: '#000000' }]
      );
      setSizes(
        product.sizes.length > 0
          ? product.sizes.map((s) => ({ label: s.label, stock: s.stock }))
          : [{ label: 'M', stock: 10 }]
      );
    } else {
      // Reset defaults for Create mode
      setName('');
      setDescription('');
      setBrand('');
      setCategoryId(categories[0]?.id || '');
      setPrice('');
      setDiscountPrice('');
      setSku(`SKU-${Date.now().toString().slice(-6)}`);
      setWeight(500);
      setIsFlashSale(false);
      setIsNewArrival(true);
      setIsTrending(false);
      setIsBestSeller(false);
      setImages([{ url: '', sortOrder: 0 }]);
      setColors([
        { name: 'Black', hexCode: '#000000' },
        { name: 'White', hexCode: '#FFFFFF' },
      ]);
      setSizes([
        { label: 'S', stock: 10 },
        { label: 'M', stock: 15 },
        { label: 'L', stock: 10 },
      ]);
    }
    setError(null);
  }, [product, categories, isOpen]);

  if (!isOpen) return null;

  // Dynamic Item Helpers
  const addImageRow = () => {
    setImages([...images, { url: '', sortOrder: images.length }]);
  };
  const removeImageRow = (index: number) => {
    if (images.length === 1) return;
    setImages(images.filter((_, i) => i !== index));
  };

  const addColorRow = () => {
    setColors([...colors, { name: 'Blue', hexCode: '#0000FF' }]);
  };
  const removeColorRow = (index: number) => {
    if (colors.length === 1) return;
    setColors(colors.filter((_, i) => i !== index));
  };

  const addSizeRow = () => {
    setSizes([...sizes, { label: 'XL', stock: 5 }]);
  };
  const removeSizeRow = (index: number) => {
    if (sizes.length === 1) return;
    setSizes(sizes.filter((_, i) => i !== index));
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError(null);

    // Basic Validations
    if (!name.trim()) return setError('Product name is required');
    if (!description.trim()) return setError('Description is required');
    if (!brand.trim()) return setError('Brand is required');
    if (!categoryId) return setError('Please select a category');
    if (typeof price !== 'number' || price <= 0) return setError('Price must be greater than 0');
    if (discountPrice !== '' && typeof discountPrice === 'number' && discountPrice >= price) {
      return setError('Discount price must be less than regular price');
    }
    if (!sku.trim()) return setError('SKU is required');
    if (images.some((img) => !img.url.trim())) return setError('All image URL fields must be filled');
    if (colors.some((c) => !c.name.trim() || !c.hexCode.trim()))
      return setError('All color fields must be filled');
    if (sizes.some((s) => !s.label.trim() || s.stock < 0))
      return setError('All size labels must be filled and stock cannot be negative');

    const payload: ProductPayload = {
      name: name.trim(),
      description: description.trim(),
      brand: brand.trim(),
      categoryId,
      price: Number(price),
      discountPrice: discountPrice !== '' ? Number(discountPrice) : null,
      sku: sku.trim(),
      weight: weight !== '' ? Number(weight) : null,
      isFlashSale,
      isNewArrival,
      isTrending,
      isBestSeller,
      images,
      colors,
      sizes: sizes.map((s) => ({ label: s.label.trim(), stock: Number(s.stock) })),
    };

    setLoading(true);
    try {
      if (isEditing && product) {
        await updateAdminProduct(product.id, payload);
      } else {
        await createAdminProduct(payload);
      }
      onSuccess();
      onClose();
    } catch (err: any) {
      console.error('Failed to save product:', err);
      setError(err.response?.data?.message || err.message || 'Failed to save product');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="fixed inset-y-0 right-0 z-50 w-full max-w-2xl bg-white shadow-2xl flex flex-col border-l border-gray-200 overflow-hidden animate-in slide-in-from-right duration-300">
      {/* Header */}
      <div className="h-18 px-6 bg-[#1E1E2D] text-white flex items-center justify-between shrink-0">
        <div>
          <h2 className="text-lg font-bold text-white m-0">
            {isEditing ? 'Edit Product' : 'Add New Product'}
          </h2>
          <p className="text-xs text-gray-400 mt-0.5">
            {isEditing ? `Updating SKU: ${product?.sku}` : 'Fill in clothing item specifications'}
          </p>
        </div>
        <button
          onClick={onClose}
          className="p-2 text-gray-400 hover:text-white rounded-xl hover:bg-gray-800 transition-all cursor-pointer"
        >
          <X className="w-5 h-5" />
        </button>
      </div>

      {/* Form Content */}
      <form onSubmit={handleSubmit} className="flex-1 overflow-y-auto p-6 space-y-6">
        {error && (
          <div className="bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded-xl flex items-start gap-3 text-sm">
            <AlertCircle className="w-5 h-5 text-red-500 shrink-0 mt-0.5" />
            <span>{error}</span>
          </div>
        )}

        {/* Basic Info Group */}
        <div className="space-y-4">
          <h3 className="text-xs font-bold uppercase tracking-wider text-[#6C63FF] m-0">
            General Information
          </h3>

          <div>
            <label className="block text-xs font-semibold text-gray-700 mb-1">Product Title</label>
            <input
              type="text"
              required
              value={name}
              onChange={(e) => setName(e.target.value)}
              placeholder="e.g. Classic Leather Biker Jacket"
              className="w-full px-3.5 py-2.5 bg-gray-50 border border-gray-200 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-[#6C63FF] focus:bg-white"
            />
          </div>

          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="block text-xs font-semibold text-gray-700 mb-1">Brand</label>
              <input
                type="text"
                required
                value={brand}
                onChange={(e) => setBrand(e.target.value)}
                placeholder="e.g. UrbanEdge"
                className="w-full px-3.5 py-2.5 bg-gray-50 border border-gray-200 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-[#6C63FF] focus:bg-white"
              />
            </div>

            <div>
              <label className="block text-xs font-semibold text-gray-700 mb-1">Category</label>
              <select
                required
                value={categoryId}
                onChange={(e) => setCategoryId(e.target.value)}
                className="w-full px-3.5 py-2.5 bg-gray-50 border border-gray-200 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-[#6C63FF] focus:bg-white"
              >
                <option value="" disabled>
                  Select Category
                </option>
                {categories.map((cat) => (
                  <option key={cat.id} value={cat.id}>
                    {cat.name}
                  </option>
                ))}
              </select>
            </div>
          </div>

          <div>
            <label className="block text-xs font-semibold text-gray-700 mb-1">Description</label>
            <textarea
              rows={3}
              required
              value={description}
              onChange={(e) => setDescription(e.target.value)}
              placeholder="Detailed description of materials, fit, and style..."
              className="w-full px-3.5 py-2.5 bg-gray-50 border border-gray-200 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-[#6C63FF] focus:bg-white resize-none"
            />
          </div>
        </div>

        {/* Pricing & Stock Group */}
        <div className="space-y-4 pt-2 border-t border-gray-100">
          <h3 className="text-xs font-bold uppercase tracking-wider text-[#6C63FF] m-0">
            Pricing & Identifiers
          </h3>

          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="block text-xs font-semibold text-gray-700 mb-1">
                Regular Price (ETB)
              </label>
              <input
                type="number"
                required
                min={1}
                value={price}
                onChange={(e) => setPrice(e.target.value === '' ? '' : Number(e.target.value))}
                placeholder="10000"
                className="w-full px-3.5 py-2.5 bg-gray-50 border border-gray-200 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-[#6C63FF] focus:bg-white"
              />
            </div>

            <div>
              <label className="block text-xs font-semibold text-gray-700 mb-1">
                Discount Price (Optional)
              </label>
              <input
                type="number"
                min={1}
                value={discountPrice}
                onChange={(e) =>
                  setDiscountPrice(e.target.value === '' ? '' : Number(e.target.value))
                }
                placeholder="7500"
                className="w-full px-3.5 py-2.5 bg-gray-50 border border-gray-200 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-[#6C63FF] focus:bg-white"
              />
            </div>
          </div>

          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="block text-xs font-semibold text-gray-700 mb-1">SKU Code</label>
              <input
                type="text"
                required
                value={sku}
                onChange={(e) => setSku(e.target.value)}
                placeholder="MEN-JKT-001"
                className="w-full px-3.5 py-2.5 bg-gray-50 border border-gray-200 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-[#6C63FF] focus:bg-white font-mono"
              />
            </div>

            <div>
              <label className="block text-xs font-semibold text-gray-700 mb-1">Weight (grams)</label>
              <input
                type="number"
                min={1}
                value={weight}
                onChange={(e) => setWeight(e.target.value === '' ? '' : Number(e.target.value))}
                placeholder="1250"
                className="w-full px-3.5 py-2.5 bg-gray-50 border border-gray-200 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-[#6C63FF] focus:bg-white"
              />
            </div>
          </div>
        </div>

        {/* Feature Flags Checkboxes */}
        <div className="space-y-3 pt-2 border-t border-gray-100">
          <h3 className="text-xs font-bold uppercase tracking-wider text-[#6C63FF] m-0">
            Badges & Promotional Status
          </h3>
          <div className="grid grid-cols-2 gap-3">
            <label className="flex items-center gap-2.5 p-3 bg-gray-50 rounded-xl border border-gray-200 cursor-pointer text-xs font-semibold text-gray-800">
              <input
                type="checkbox"
                checked={isFlashSale}
                onChange={(e) => setIsFlashSale(e.target.checked)}
                className="w-4 h-4 text-[#6C63FF] rounded focus:ring-[#6C63FF]"
              />
              ⚡ Flash Sale
            </label>

            <label className="flex items-center gap-2.5 p-3 bg-gray-50 rounded-xl border border-gray-200 cursor-pointer text-xs font-semibold text-gray-800">
              <input
                type="checkbox"
                checked={isNewArrival}
                onChange={(e) => setIsNewArrival(e.target.checked)}
                className="w-4 h-4 text-[#6C63FF] rounded focus:ring-[#6C63FF]"
              />
              ✨ New Arrival
            </label>

            <label className="flex items-center gap-2.5 p-3 bg-gray-50 rounded-xl border border-gray-200 cursor-pointer text-xs font-semibold text-gray-800">
              <input
                type="checkbox"
                checked={isTrending}
                onChange={(e) => setIsTrending(e.target.checked)}
                className="w-4 h-4 text-[#6C63FF] rounded focus:ring-[#6C63FF]"
              />
              🔥 Trending
            </label>

            <label className="flex items-center gap-2.5 p-3 bg-gray-50 rounded-xl border border-gray-200 cursor-pointer text-xs font-semibold text-gray-800">
              <input
                type="checkbox"
                checked={isBestSeller}
                onChange={(e) => setIsBestSeller(e.target.checked)}
                className="w-4 h-4 text-[#6C63FF] rounded focus:ring-[#6C63FF]"
              />
              🏆 Best Seller
            </label>
          </div>
        </div>

        {/* Dynamic Images */}
        <div className="space-y-3 pt-2 border-t border-gray-100">
          <div className="flex items-center justify-between">
            <h3 className="text-xs font-bold uppercase tracking-wider text-[#6C63FF] flex items-center gap-1.5 m-0">
              <ImageIcon className="w-4 h-4" /> Product Images ({images.length})
            </h3>
            <button
              type="button"
              onClick={addImageRow}
              className="text-xs font-semibold text-[#6C63FF] hover:underline flex items-center gap-1 cursor-pointer"
            >
              <Plus className="w-3.5 h-3.5" /> Add Image Slot
            </button>
          </div>

          <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
            {images.map((img, idx) => (
              <div key={idx} className="relative bg-gray-50 p-3 rounded-xl border border-gray-200 space-y-2">
                <div className="flex items-center justify-between">
                  <span className="text-xs font-semibold text-gray-500">Image #{idx + 1}</span>
                  {images.length > 1 && (
                    <button
                      type="button"
                      onClick={() => removeImageRow(idx)}
                      className="text-gray-400 hover:text-red-600 transition-colors p-1 cursor-pointer"
                      title="Remove image slot"
                    >
                      <Trash2 className="w-4 h-4" />
                    </button>
                  )}
                </div>
                <ImageUploadField
                  value={img.url}
                  folder="products"
                  onChange={(newUrl) => {
                    const newImgs = [...images];
                    newImgs[idx].url = newUrl;
                    setImages(newImgs);
                  }}
                  onRemove={() => removeImageRow(idx)}
                />
              </div>
            ))}
          </div>
        </div>

        {/* Dynamic Colors */}
        <div className="space-y-3 pt-2 border-t border-gray-100">
          <div className="flex items-center justify-between">
            <h3 className="text-xs font-bold uppercase tracking-wider text-[#6C63FF] flex items-center gap-1.5 m-0">
              <Palette className="w-4 h-4" /> Colors ({colors.length})
            </h3>
            <button
              type="button"
              onClick={addColorRow}
              className="text-xs font-semibold text-[#6C63FF] hover:underline flex items-center gap-1 cursor-pointer"
            >
              <Plus className="w-3.5 h-3.5" /> Add Color
            </button>
          </div>

          <div className="space-y-2">
            {colors.map((col, idx) => (
              <div key={idx} className="flex items-center gap-2">
                <input
                  type="text"
                  required
                  value={col.name}
                  onChange={(e) => {
                    const newCols = [...colors];
                    newCols[idx].name = e.target.value;
                    setColors(newCols);
                  }}
                  placeholder="Color Name (e.g. Navy)"
                  className="w-1/2 px-3 py-2 bg-gray-50 border border-gray-200 rounded-xl text-xs focus:outline-none focus:ring-2 focus:ring-[#6C63FF]"
                />
                <div className="flex items-center gap-2 w-1/2">
                  <input
                    type="color"
                    value={col.hexCode}
                    onChange={(e) => {
                      const newCols = [...colors];
                      newCols[idx].hexCode = e.target.value;
                      setColors(newCols);
                    }}
                    className="w-8 h-8 rounded-lg cursor-pointer border border-gray-200"
                  />
                  <input
                    type="text"
                    required
                    value={col.hexCode}
                    onChange={(e) => {
                      const newCols = [...colors];
                      newCols[idx].hexCode = e.target.value;
                      setColors(newCols);
                    }}
                    placeholder="#1E1E2D"
                    className="flex-1 px-3 py-2 bg-gray-50 border border-gray-200 rounded-xl text-xs font-mono"
                  />
                  <button
                    type="button"
                    onClick={() => removeColorRow(idx)}
                    disabled={colors.length === 1}
                    className="p-2 text-gray-400 hover:text-red-600 disabled:opacity-30 cursor-pointer"
                  >
                    <Trash2 className="w-4 h-4" />
                  </button>
                </div>
              </div>
            ))}
          </div>
        </div>

        {/* Dynamic Sizes & Stock */}
        <div className="space-y-3 pt-2 border-t border-gray-100">
          <div className="flex items-center justify-between">
            <h3 className="text-xs font-bold uppercase tracking-wider text-[#6C63FF] flex items-center gap-1.5 m-0">
              <Ruler className="w-4 h-4" /> Sizes & Per-Size Stock ({sizes.length})
            </h3>
            <button
              type="button"
              onClick={addSizeRow}
              className="text-xs font-semibold text-[#6C63FF] hover:underline flex items-center gap-1 cursor-pointer"
            >
              <Plus className="w-3.5 h-3.5" /> Add Size
            </button>
          </div>

          <div className="space-y-2">
            {sizes.map((sz, idx) => (
              <div key={idx} className="flex items-center gap-2">
                <input
                  type="text"
                  required
                  value={sz.label}
                  onChange={(e) => {
                    const newSizes = [...sizes];
                    newSizes[idx].label = e.target.value;
                    setSizes(newSizes);
                  }}
                  placeholder="Size (e.g. S, M, 42)"
                  className="w-1/2 px-3 py-2 bg-gray-50 border border-gray-200 rounded-xl text-xs focus:outline-none focus:ring-2 focus:ring-[#6C63FF]"
                />
                <input
                  type="number"
                  required
                  min={0}
                  value={sz.stock}
                  onChange={(e) => {
                    const newSizes = [...sizes];
                    newSizes[idx].stock = Number(e.target.value);
                    setSizes(newSizes);
                  }}
                  placeholder="Stock Quantity"
                  className="w-1/2 px-3 py-2 bg-gray-50 border border-gray-200 rounded-xl text-xs focus:outline-none focus:ring-2 focus:ring-[#6C63FF]"
                />
                <button
                  type="button"
                  onClick={() => removeSizeRow(idx)}
                  disabled={sizes.length === 1}
                  className="p-2 text-gray-400 hover:text-red-600 disabled:opacity-30 cursor-pointer"
                >
                  <Trash2 className="w-4 h-4" />
                </button>
              </div>
            ))}
          </div>
        </div>

        {/* Footer Actions */}
        <div className="pt-4 border-t border-gray-200 flex items-center justify-end gap-3 sticky bottom-0 bg-white py-3">
          <button
            type="button"
            onClick={onClose}
            className="px-5 py-2.5 border border-gray-300 text-gray-700 rounded-xl text-sm font-semibold hover:bg-gray-100 transition-all cursor-pointer"
          >
            Cancel
          </button>

          <button
            type="submit"
            disabled={loading}
            className="px-6 py-2.5 bg-[#6C63FF] hover:bg-[#5a52e0] text-white rounded-xl text-sm font-semibold shadow-md shadow-[#6C63FF]/20 transition-all flex items-center gap-2 cursor-pointer disabled:opacity-70"
          >
            {loading ? (
              <>
                <Loader2 className="w-4 h-4 animate-spin" />
                Saving Product...
              </>
            ) : isEditing ? (
              'Update Product'
            ) : (
              'Create Product'
            )}
          </button>
        </div>
      </form>
    </div>
  );
};
