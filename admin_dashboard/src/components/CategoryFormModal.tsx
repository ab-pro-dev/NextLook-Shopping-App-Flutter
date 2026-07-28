import React, { useState, useEffect } from 'react';
import {
  type Category,
  createAdminCategory,
  updateAdminCategory,
} from '../services/api';
import { X, Loader2, AlertCircle, Tag, Sparkles } from 'lucide-react';

interface CategoryFormModalProps {
  isOpen: boolean;
  category?: Category | null;
  onClose: () => void;
  onSuccess: () => void;
}

const AVAILABLE_ICONS = [
  { id: 'shirt', label: 'Shirt / Tops' },
  { id: 'user', label: 'Men / Apparel' },
  { id: 'smile', label: 'Women / Fashion' },
  { id: 'footprints', label: 'Shoes / Footwear' },
  { id: 'watch', label: 'Accessories' },
  { id: 'shopping-bag', label: 'Bags / Travel' },
  { id: 'tag', label: 'General Apparel' },
  { id: 'zap', label: 'Sportswear' },
];

function slugify(text: string): string {
  return text
    .toLowerCase()
    .trim()
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/^-+|-+$/g, '');
}

export const CategoryFormModal: React.FC<CategoryFormModalProps> = ({
  isOpen,
  category,
  onClose,
  onSuccess,
}) => {
  const [name, setName] = useState('');
  const [slug, setSlug] = useState('');
  const [iconName, setIconName] = useState('tag');
  const [isManualSlug, setIsManualSlug] = useState(false);

  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    if (category) {
      setName(category.name);
      setSlug(category.slug);
      setIconName(category.iconName || 'tag');
      setIsManualSlug(true);
    } else {
      setName('');
      setSlug('');
      setIconName('tag');
      setIsManualSlug(false);
    }
    setError(null);
  }, [category, isOpen]);

  const handleNameChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const val = e.target.value;
    setName(val);
    if (!isManualSlug) {
      setSlug(slugify(val));
    }
  };

  const handleSlugChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    setIsManualSlug(true);
    setSlug(slugify(e.target.value));
  };

  if (!isOpen) return null;

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    setError(null);

    try {
      if (category) {
        await updateAdminCategory(category.id, { name, slug, iconName });
      } else {
        await createAdminCategory({ name, slug, iconName });
      }
      onSuccess();
      onClose();
    } catch (err: any) {
      console.error('Category form error:', err);
      const msg = err.response?.data?.message || err.message || 'Failed to save category';
      setError(msg);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="fixed inset-0 z-50 bg-black/50 backdrop-blur-xs flex items-center justify-center p-4">
      <div className="bg-white rounded-2xl shadow-2xl max-w-md w-full overflow-hidden animate-in fade-in zoom-in-95">
        {/* Modal Header */}
        <div className="h-16 px-6 bg-[#1E1E2D] text-white flex items-center justify-between">
          <div className="flex items-center gap-2.5">
            <Tag className="w-5 h-5 text-[#6C63FF]" />
            <h2 className="text-base font-bold text-white m-0">
              {category ? 'Edit Category' : 'Add New Category'}
            </h2>
          </div>
          <button
            onClick={onClose}
            className="p-1.5 text-gray-400 hover:text-white rounded-xl hover:bg-gray-800 transition-all cursor-pointer"
          >
            <X className="w-5 h-5" />
          </button>
        </div>

        {/* Modal Form */}
        <form onSubmit={handleSubmit} className="p-6 space-y-4">
          {error && (
            <div className="bg-red-50 border border-red-200 text-red-700 p-3.5 rounded-xl text-xs flex items-start gap-2">
              <AlertCircle className="w-4 h-4 text-red-500 shrink-0 mt-0.5" />
              <span>{error}</span>
            </div>
          )}

          {/* Name Field */}
          <div>
            <label className="block text-xs font-bold uppercase tracking-wider text-gray-700 mb-1">
              Category Name *
            </label>
            <input
              type="text"
              required
              value={name}
              onChange={handleNameChange}
              placeholder="e.g. Sportswear, Kids, Shoes"
              className="w-full px-3.5 py-2.5 bg-gray-50 border border-gray-200 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-[#6C63FF] focus:bg-white"
            />
          </div>

          {/* Slug Field */}
          <div>
            <div className="flex items-center justify-between mb-1">
              <label className="block text-xs font-bold uppercase tracking-wider text-gray-700">
                URL Slug *
              </label>
              {!isManualSlug && name && (
                <span className="text-[11px] text-[#6C63FF] font-medium flex items-center gap-1">
                  <Sparkles className="w-3 h-3" /> Auto-suggested
                </span>
              )}
            </div>
            <input
              type="text"
              required
              value={slug}
              onChange={handleSlugChange}
              placeholder="e.g. sportswear"
              className="w-full px-3.5 py-2.5 bg-gray-50 border border-gray-200 rounded-xl text-sm font-mono focus:outline-none focus:ring-2 focus:ring-[#6C63FF] focus:bg-white"
            />
          </div>

          {/* Icon Selector */}
          <div>
            <label className="block text-xs font-bold uppercase tracking-wider text-gray-700 mb-1">
              Category Icon
            </label>
            <select
              value={iconName}
              onChange={(e) => setIconName(e.target.value)}
              className="w-full px-3.5 py-2.5 bg-gray-50 border border-gray-200 rounded-xl text-sm text-gray-700 focus:outline-none focus:ring-2 focus:ring-[#6C63FF] cursor-pointer"
            >
              {AVAILABLE_ICONS.map((ic) => (
                <option key={ic.id} value={ic.id}>
                  {ic.label} ({ic.id})
                </option>
              ))}
            </select>
          </div>

          {/* Footer Buttons */}
          <div className="flex items-center gap-3 pt-4 border-t border-gray-100">
            <button
              type="button"
              disabled={loading}
              onClick={onClose}
              className="flex-1 py-2.5 border border-gray-300 text-gray-700 rounded-xl text-sm font-semibold hover:bg-gray-50 transition-all cursor-pointer"
            >
              Cancel
            </button>

            <button
              type="submit"
              disabled={loading}
              className="flex-1 py-2.5 bg-[#6C63FF] hover:bg-[#5a52e0] text-white rounded-xl text-sm font-semibold transition-all shadow-md shadow-[#6C63FF]/20 flex items-center justify-center gap-2 cursor-pointer disabled:opacity-70"
            >
              {loading ? (
                <>
                  <Loader2 className="w-4 h-4 animate-spin" />
                  Saving...
                </>
              ) : category ? (
                'Update Category'
              ) : (
                'Create Category'
              )}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
};
