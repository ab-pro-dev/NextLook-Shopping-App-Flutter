import React, { useState, useRef } from 'react';
import { uploadAdminImage } from '../services/api';
import { Upload, X, Loader2, Image as ImageIcon, AlertCircle } from 'lucide-react';

interface ImageUploadFieldProps {
  value?: string;
  onChange: (url: string, publicId?: string) => void;
  onRemove?: () => void;
  onMultipleUpload?: (urls: string[]) => void;
  allowMultiple?: boolean;
  folder?: 'avatars' | 'products' | 'banners';
  label?: string;
  className?: string;
}

export const ImageUploadField: React.FC<ImageUploadFieldProps> = ({
  value,
  onChange,
  onRemove,
  onMultipleUpload,
  allowMultiple = false,
  folder = 'products',
  label,
  className = '',
}) => {
  const [loading, setLoading] = useState(false);
  const [loadingText, setLoadingText] = useState('Uploading image to Cloudinary...');
  const [error, setError] = useState<string | null>(null);
  const fileInputRef = useRef<HTMLInputElement>(null);

  const handleFileChange = async (e: React.ChangeEvent<HTMLInputElement>) => {
    const fileList = e.target.files;
    if (!fileList || fileList.length === 0) return;

    setError(null);
    const files = Array.from(fileList);

    const allowedTypes = ['image/jpeg', 'image/png', 'image/webp', 'image/jpg'];
    for (const file of files) {
      if (file.size > 5 * 1024 * 1024) {
        setError(`File '${file.name}' exceeds 5MB limit. Please choose smaller images.`);
        if (fileInputRef.current) fileInputRef.current.value = '';
        return;
      }
      if (!allowedTypes.includes(file.type)) {
        setError(`File '${file.name}' has invalid type. Only JPEG, PNG, and WebP images are allowed.`);
        if (fileInputRef.current) fileInputRef.current.value = '';
        return;
      }
    }

    setLoading(true);

    try {
      if (files.length === 1 || !onMultipleUpload) {
        setLoadingText('Uploading image to Cloudinary...');
        const res = await uploadAdminImage(files[0], folder);
        onChange(res.url, res.publicId);
      } else {
        setLoadingText(`Uploading 1 of ${files.length} images...`);
        const firstRes = await uploadAdminImage(files[0], folder);
        onChange(firstRes.url, firstRes.publicId);

        const remainingUrls: string[] = [];
        for (let i = 1; i < files.length; i++) {
          setLoadingText(`Uploading ${i + 1} of ${files.length} images...`);
          const res = await uploadAdminImage(files[i], folder);
          remainingUrls.push(res.url);
        }
        onMultipleUpload(remainingUrls);
      }
    } catch (err: any) {
      console.error('Image upload error:', err);
      const serverMessage = err.response?.data?.message || err.message || 'Failed to upload image. Please try again.';
      setError(serverMessage);
    } finally {
      setLoading(false);
      setLoadingText('Uploading image to Cloudinary...');
      if (fileInputRef.current) fileInputRef.current.value = '';
    }
  };

  const handleClear = () => {
    setError(null);
    if (onRemove) {
      onRemove();
    } else {
      onChange('');
    }
    if (fileInputRef.current) fileInputRef.current.value = '';
  };

  return (
    <div className={`space-y-2 ${className}`}>
      {label && <label className="block text-xs font-semibold text-gray-700 uppercase tracking-wider">{label}</label>}

      {error && (
        <div className="bg-red-50 border border-red-200 text-red-700 px-3 py-2 rounded-xl text-xs flex items-center gap-2">
          <AlertCircle className="w-4 h-4 text-red-500 shrink-0" />
          <span>{error}</span>
        </div>
      )}

      {value ? (
        /* Image Preview Box */
        <div className="relative group w-full h-40 bg-gray-50 border border-gray-200 rounded-xl overflow-hidden flex items-center justify-center">
          <img
            src={value}
            alt="Uploaded preview"
            className="w-full h-full object-cover transition-transform group-hover:scale-105"
            onError={(e) => {
              (e.target as HTMLElement).style.display = 'none';
            }}
          />
          <div className="absolute inset-0 bg-black/40 opacity-0 group-hover:opacity-100 transition-opacity flex items-center justify-center gap-3">
            <button
              type="button"
              onClick={() => fileInputRef.current?.click()}
              disabled={loading}
              className="p-2 bg-white text-gray-800 rounded-lg hover:bg-gray-100 shadow-md transition-all text-xs font-medium flex items-center gap-1.5 cursor-pointer"
            >
              <Upload className="w-4 h-4 text-[#6C63FF]" />
              <span>Replace</span>
            </button>
            <button
              type="button"
              onClick={handleClear}
              disabled={loading}
              className="p-2 bg-red-600 text-white rounded-lg hover:bg-red-700 shadow-md transition-all text-xs font-medium flex items-center gap-1.5 cursor-pointer"
            >
              <X className="w-4 h-4" />
              <span>Remove</span>
            </button>
          </div>
        </div>
      ) : (
        /* Dropzone / Upload Trigger Box */
        <div
          onClick={() => !loading && fileInputRef.current?.click()}
          className={`w-full h-36 border-2 border-dashed rounded-xl flex flex-col items-center justify-center p-4 text-center transition-all cursor-pointer ${
            loading
              ? 'bg-gray-50 border-gray-300 pointer-events-none'
              : 'border-gray-300 hover:border-[#6C63FF] hover:bg-[#6C63FF]/5'
          }`}
        >
          {loading ? (
            <div className="flex flex-col items-center gap-2 text-[#6C63FF]">
              <Loader2 className="w-6 h-6 animate-spin" />
              <span className="text-xs font-semibold">{loadingText}</span>
            </div>
          ) : (
            <div className="flex flex-col items-center gap-1.5 text-gray-500">
              <div className="w-10 h-10 bg-gray-100 rounded-full flex items-center justify-center text-gray-400 group-hover:text-[#6C63FF]">
                <ImageIcon className="w-5 h-5" />
              </div>
              <div className="text-xs font-medium text-gray-700">
                <span className="text-[#6C63FF] font-semibold">Click to upload</span> or drag and drop
              </div>
              <p className="text-[11px] text-gray-400">
                {allowMultiple ? 'Select one or more PNG, JPG, or WEBP (MAX. 5MB)' : 'PNG, JPG, or WEBP (MAX. 5MB)'}
              </p>
            </div>
          )}
        </div>
      )}

      {/* Hidden File Input */}
      <input
        type="file"
        ref={fileInputRef}
        multiple={allowMultiple}
        onChange={handleFileChange}
        accept="image/jpeg,image/png,image/webp,image/jpg"
        className="hidden"
      />
    </div>
  );
};
