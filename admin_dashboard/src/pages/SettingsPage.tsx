import React, { useEffect, useState } from 'react';
import { api } from '../services/api';
import {
  Save,
  Loader2,
  CheckCircle2,
  AlertCircle,
  Truck,
  Percent,
  DollarSign,
  Clock,
  SlidersHorizontal,
} from 'lucide-react';

export interface StoreSettings {
  id: string;
  standardDeliveryLabel: string;
  standardDeliveryDays: string;
  standardDeliveryPrice: number;
  expressDeliveryLabel: string;
  expressDeliveryDays: string;
  expressDeliveryPrice: number;
  taxRatePercent: number;
  updatedAt: string;
}

export const SettingsPage: React.FC = () => {
  const [settings, setSettings] = useState<StoreSettings | null>(null);
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [successMessage, setSuccessMessage] = useState<string | null>(null);

  // Form State
  const [standardLabel, setStandardLabel] = useState('');
  const [standardDays, setStandardDays] = useState('');
  const [standardPrice, setStandardPrice] = useState<number>(150);

  const [expressLabel, setExpressLabel] = useState('');
  const [expressDays, setExpressDays] = useState('');
  const [expressPrice, setExpressPrice] = useState<number>(300);

  const [taxRatePercent, setTaxRatePercent] = useState<number>(0);

  const loadSettings = async () => {
    try {
      setLoading(true);
      setError(null);
      const response = await api.get<StoreSettings>('/api/settings');
      const data = response.data;
      setSettings(data);

      setStandardLabel(data.standardDeliveryLabel);
      setStandardDays(data.standardDeliveryDays);
      setStandardPrice(data.standardDeliveryPrice);

      setExpressLabel(data.expressDeliveryLabel);
      setExpressDays(data.expressDeliveryDays);
      setExpressPrice(data.expressDeliveryPrice);

      setTaxRatePercent(data.taxRatePercent);
    } catch (err: any) {
      console.error('Failed to load store settings:', err);
      setError(err.response?.data?.message || err.message || 'Failed to load store settings');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    loadSettings();
  }, []);

  const handleSaveSettings = async (e: React.FormEvent) => {
    e.preventDefault();
    setError(null);
    setSuccessMessage(null);

    // Client-side validation
    if (standardPrice < 0 || expressPrice < 0) {
      setError('Delivery prices must be non-negative numbers');
      return;
    }

    if (taxRatePercent < 0 || taxRatePercent > 100) {
      setError('Tax rate percentage must be between 0 and 100');
      return;
    }

    setSaving(true);

    try {
      const payload = {
        standardDeliveryLabel: standardLabel,
        standardDeliveryDays: standardDays,
        standardDeliveryPrice: Number(standardPrice),
        expressDeliveryLabel: expressLabel,
        expressDeliveryDays: expressDays,
        expressDeliveryPrice: Number(expressPrice),
        taxRatePercent: Number(taxRatePercent),
      };

      const response = await api.put<StoreSettings>('/api/admin/settings', payload);
      setSettings(response.data);
      setSuccessMessage('Store settings & delivery pricing saved successfully!');
      setTimeout(() => setSuccessMessage(null), 4000);
    } catch (err: any) {
      console.error('Failed to save store settings:', err);
      setError(err.response?.data?.message || err.message || 'Failed to save store settings');
    } finally {
      setSaving(false);
    }
  };

  if (loading && !settings) {
    return (
      <div className="min-h-[400px] flex flex-col items-center justify-center p-12 text-center space-y-4">
        <Loader2 className="w-10 h-10 text-[#6C63FF] animate-spin" />
        <p className="text-gray-500 font-medium text-sm">Loading store configuration...</p>
      </div>
    );
  }

  return (
    <div className="space-y-6 max-w-5xl">
      {/* Header Banner */}
      <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
        <div>
          <h1 className="text-2xl font-bold text-gray-900 m-0">Store & Delivery Settings</h1>
          <p className="text-gray-500 text-sm mt-1">
            Configure server-side delivery pricing tiers, estimated delivery timelines, and sales tax rate.
          </p>
        </div>

        <button
          onClick={handleSaveSettings}
          disabled={saving}
          className="py-3 px-6 bg-[#6C63FF] hover:bg-[#5a52e0] text-white font-semibold rounded-xl shadow-lg shadow-[#6C63FF]/20 transition-all flex items-center justify-center gap-2 cursor-pointer shrink-0 disabled:opacity-70"
        >
          {saving ? <Loader2 className="w-5 h-5 animate-spin" /> : <Save className="w-5 h-5" />}
          Save Configuration
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
          <div className="flex items-center gap-2">
            <AlertCircle className="w-5 h-5 text-red-500 shrink-0" />
            <span>{error}</span>
          </div>
          <button onClick={loadSettings} className="font-semibold text-red-800 underline">
            Retry
          </button>
        </div>
      )}

      <form onSubmit={handleSaveSettings} className="space-y-6">
        {/* Delivery Options Card */}
        <div className="bg-white rounded-2xl border border-gray-100 shadow-xs p-6 space-y-6">
          <div className="flex items-center gap-2.5 border-b border-gray-100 pb-4">
            <Truck className="w-5 h-5 text-[#6C63FF]" />
            <h2 className="text-base font-bold text-gray-900 m-0">Delivery Method Pricing & Timelines</h2>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            {/* Standard Delivery Box */}
            <div className="bg-gray-50 border border-gray-200/80 rounded-2xl p-5 space-y-4">
              <div className="flex items-center justify-between">
                <span className="text-sm font-bold text-gray-900 flex items-center gap-2">
                  <SlidersHorizontal className="w-4 h-4 text-[#6C63FF]" /> Standard Delivery Option
                </span>
                <span className="text-[11px] font-mono bg-purple-100 text-purple-700 font-bold px-2 py-0.5 rounded">
                  standard
                </span>
              </div>

              <div>
                <label className="block text-xs font-bold uppercase tracking-wider text-gray-600 mb-1">
                  Display Label
                </label>
                <input
                  type="text"
                  required
                  value={standardLabel}
                  onChange={(e) => setStandardLabel(e.target.value)}
                  className="w-full px-3.5 py-2.5 bg-white border border-gray-200 rounded-xl text-sm font-medium focus:outline-none focus:ring-2 focus:ring-[#6C63FF]"
                />
              </div>

              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="block text-xs font-bold uppercase tracking-wider text-gray-600 mb-1">
                    Timeline
                  </label>
                  <div className="relative">
                    <Clock className="w-4 h-4 text-gray-400 absolute left-3 top-1/2 -translate-y-1/2" />
                    <input
                      type="text"
                      required
                      value={standardDays}
                      onChange={(e) => setStandardDays(e.target.value)}
                      className="w-full pl-9 pr-3 py-2 bg-white border border-gray-200 rounded-xl text-sm font-medium focus:outline-none focus:ring-2 focus:ring-[#6C63FF]"
                    />
                  </div>
                </div>

                <div>
                  <label className="block text-xs font-bold uppercase tracking-wider text-gray-600 mb-1">
                    Price (ETB)
                  </label>
                  <div className="relative">
                    <DollarSign className="w-4 h-4 text-gray-400 absolute left-3 top-1/2 -translate-y-1/2" />
                    <input
                      type="number"
                      min="0"
                      required
                      value={standardPrice}
                      onChange={(e) => setStandardPrice(Number(e.target.value))}
                      className="w-full pl-9 pr-3 py-2 bg-white border border-gray-200 rounded-xl text-sm font-bold text-gray-900 focus:outline-none focus:ring-2 focus:ring-[#6C63FF]"
                    />
                  </div>
                </div>
              </div>
            </div>

            {/* Express Delivery Box */}
            <div className="bg-gray-50 border border-gray-200/80 rounded-2xl p-5 space-y-4">
              <div className="flex items-center justify-between">
                <span className="text-sm font-bold text-gray-900 flex items-center gap-2">
                  <SlidersHorizontal className="w-4 h-4 text-[#6C63FF]" /> Express Delivery Option
                </span>
                <span className="text-[11px] font-mono bg-purple-100 text-purple-700 font-bold px-2 py-0.5 rounded">
                  express
                </span>
              </div>

              <div>
                <label className="block text-xs font-bold uppercase tracking-wider text-gray-600 mb-1">
                  Display Label
                </label>
                <input
                  type="text"
                  required
                  value={expressLabel}
                  onChange={(e) => setExpressLabel(e.target.value)}
                  className="w-full px-3.5 py-2.5 bg-white border border-gray-200 rounded-xl text-sm font-medium focus:outline-none focus:ring-2 focus:ring-[#6C63FF]"
                />
              </div>

              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="block text-xs font-bold uppercase tracking-wider text-gray-600 mb-1">
                    Timeline
                  </label>
                  <div className="relative">
                    <Clock className="w-4 h-4 text-gray-400 absolute left-3 top-1/2 -translate-y-1/2" />
                    <input
                      type="text"
                      required
                      value={expressDays}
                      onChange={(e) => setExpressDays(e.target.value)}
                      className="w-full pl-9 pr-3 py-2 bg-white border border-gray-200 rounded-xl text-sm font-medium focus:outline-none focus:ring-2 focus:ring-[#6C63FF]"
                    />
                  </div>
                </div>

                <div>
                  <label className="block text-xs font-bold uppercase tracking-wider text-gray-600 mb-1">
                    Price (ETB)
                  </label>
                  <div className="relative">
                    <DollarSign className="w-4 h-4 text-gray-400 absolute left-3 top-1/2 -translate-y-1/2" />
                    <input
                      type="number"
                      min="0"
                      required
                      value={expressPrice}
                      onChange={(e) => setExpressPrice(Number(e.target.value))}
                      className="w-full pl-9 pr-3 py-2 bg-white border border-gray-200 rounded-xl text-sm font-bold text-gray-900 focus:outline-none focus:ring-2 focus:ring-[#6C63FF]"
                    />
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>

        {/* Tax Rate Percentage Card */}
        <div className="bg-white rounded-2xl border border-gray-100 shadow-xs p-6 space-y-4">
          <div className="flex items-center gap-2.5 border-b border-gray-100 pb-4">
            <Percent className="w-5 h-5 text-[#6C63FF]" />
            <h2 className="text-base font-bold text-gray-900 m-0">Sales Tax Rate (%)</h2>
          </div>

          <div className="max-w-md space-y-2">
            <label className="block text-xs font-bold uppercase tracking-wider text-gray-600">
              Tax Percentage Rate (%)
            </label>
            <div className="relative">
              <input
                type="number"
                step="0.1"
                min="0"
                max="100"
                required
                value={taxRatePercent}
                onChange={(e) => setTaxRatePercent(Number(e.target.value))}
                placeholder="e.g. 15.0"
                className="w-full pl-4 pr-10 py-2.5 bg-gray-50 border border-gray-200 rounded-xl text-sm font-bold text-gray-900 focus:outline-none focus:ring-2 focus:ring-[#6C63FF] focus:bg-white"
              />
              <span className="absolute right-3.5 top-1/2 -translate-y-1/2 text-gray-500 font-bold text-sm">
                %
              </span>
            </div>
            <p className="text-xs text-gray-400 mt-1">
              Applied automatically during order creation server-side: <code>tax = Math.round(subtotal * (taxRatePercent / 100))</code>
            </p>
          </div>
        </div>
      </form>
    </div>
  );
};
