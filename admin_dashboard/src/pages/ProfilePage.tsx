import React, { useState, useEffect } from 'react';
import {
  type AdminUser,
  fetchCurrentAdminUser,
  updateAdminProfile,
  changeAdminPassword,
} from '../services/api';
import { ImageUploadField } from '../components/ImageUploadField';
import {
  User,
  Mail,
  Lock,
  Eye,
  EyeOff,
  CheckCircle2,
  AlertCircle,
  Loader2,
  Save,
  KeyRound,
  ShieldCheck,
} from 'lucide-react';

export const ProfilePage: React.FC = () => {
  const [user, setUser] = useState<AdminUser | null>(null);
  const [name, setName] = useState('');
  const [email, setEmail] = useState('');
  const [avatarUrl, setAvatarUrl] = useState('');

  // Password state
  const [currentPassword, setCurrentPassword] = useState('');
  const [newPassword, setNewPassword] = useState('');
  const [confirmPassword, setConfirmPassword] = useState('');

  // Toggles
  const [showCurrentPassword, setShowCurrentPassword] = useState(false);
  const [showNewPassword, setShowNewPassword] = useState(false);

  // Independent Loading States
  const [loadingUser, setLoadingUser] = useState(true);
  const [nameLoading, setNameLoading] = useState(false);
  const [avatarLoading, setAvatarLoading] = useState(false);
  const [passwordLoading, setPasswordLoading] = useState(false);

  // Independent Notifications
  const [nameSuccess, setNameSuccess] = useState<string | null>(null);
  const [nameError, setNameError] = useState<string | null>(null);

  const [avatarSuccess, setAvatarSuccess] = useState<string | null>(null);
  const [avatarError, setAvatarError] = useState<string | null>(null);

  const [passwordSuccess, setPasswordSuccess] = useState<string | null>(null);
  const [passwordError, setPasswordError] = useState<string | null>(null);

  useEffect(() => {
    loadProfile();
  }, []);

  const loadProfile = async () => {
    setLoadingUser(true);
    try {
      const currentUser = await fetchCurrentAdminUser();
      setUser(currentUser);
      setName(currentUser.name || '');
      setEmail(currentUser.email || '');
      setAvatarUrl(currentUser.avatarUrl || '');

      // Keep localStorage in sync
      localStorage.setItem('adminUser', JSON.stringify(currentUser));
    } catch (err: any) {
      console.error('Failed to load profile:', err);
      // Fallback from localStorage
      const stored = localStorage.getItem('adminUser');
      if (stored) {
        try {
          const parsed = JSON.parse(stored);
          setUser(parsed);
          setName(parsed.name || '');
          setEmail(parsed.email || '');
          setAvatarUrl(parsed.avatarUrl || '');
        } catch (_) {}
      }
    } finally {
      setLoadingUser(false);
    }
  };

  const notifyHeaderUpdate = (updatedUser: AdminUser) => {
    localStorage.setItem('adminUser', JSON.stringify(updatedUser));
    // Dispatch custom event to notify AdminLayout immediately
    window.dispatchEvent(new Event('adminUserUpdated'));
  };

  // 1. Handle Avatar Change
  const handleAvatarChange = async (newUrl: string) => {
    setAvatarError(null);
    setAvatarSuccess(null);
    setAvatarLoading(true);

    try {
      const updatedUser = await updateAdminProfile({ avatarUrl: newUrl });
      setUser(updatedUser);
      setAvatarUrl(updatedUser.avatarUrl || '');
      notifyHeaderUpdate(updatedUser);
      setAvatarSuccess('Profile photo updated successfully!');
      setTimeout(() => setAvatarSuccess(null), 4000);
    } catch (err: any) {
      console.error('Avatar update failed:', err);
      setAvatarError(err.response?.data?.message || err.message || 'Failed to update profile photo');
    } finally {
      setAvatarLoading(false);
    }
  };

  // 2. Handle Name Change
  const handleSaveName = async (e: React.FormEvent) => {
    e.preventDefault();
    setNameError(null);
    setNameSuccess(null);

    if (!name.trim()) {
      setNameError('Name cannot be empty.');
      return;
    }

    setNameLoading(true);
    try {
      const updatedUser = await updateAdminProfile({ name: name.trim() });
      setUser(updatedUser);
      setName(updatedUser.name);
      notifyHeaderUpdate(updatedUser);
      setNameSuccess('Display name updated successfully!');
      setTimeout(() => setNameSuccess(null), 4000);
    } catch (err: any) {
      console.error('Name update failed:', err);
      setNameError(err.response?.data?.message || err.message || 'Failed to update display name');
    } finally {
      setNameLoading(false);
    }
  };

  // 3. Handle Password Change
  const handleChangePassword = async (e: React.FormEvent) => {
    e.preventDefault();
    setPasswordError(null);
    setPasswordSuccess(null);

    if (!currentPassword) {
      setPasswordError('Current password is required.');
      return;
    }

    if (newPassword.length < 8) {
      setPasswordError('New password must be at least 8 characters long.');
      return;
    }

    if (newPassword !== confirmPassword) {
      setPasswordError('New passwords do not match. Please re-enter.');
      return;
    }

    setPasswordLoading(true);
    try {
      await changeAdminPassword({ currentPassword, newPassword });
      setPasswordSuccess('Password changed successfully! Next time you log in, please use your new password.');
      setCurrentPassword('');
      setNewPassword('');
      setConfirmPassword('');
      setTimeout(() => setPasswordSuccess(null), 5000);
    } catch (err: any) {
      console.error('Password change failed:', err);
      setPasswordError(err.response?.data?.message || err.message || 'Failed to change password');
    } finally {
      setPasswordLoading(false);
    }
  };

  if (loadingUser) {
    return (
      <div className="min-h-[400px] flex flex-col items-center justify-center p-12 text-center space-y-4">
        <Loader2 className="w-10 h-10 text-[#6C63FF] animate-spin" />
        <p className="text-gray-500 font-medium text-sm">Loading admin profile...</p>
      </div>
    );
  }

  return (
    <div className="max-w-4xl mx-auto space-y-8 pb-12">
      {/* Header Banner */}
      <div>
        <h1 className="text-2xl font-bold text-gray-900 m-0">My Profile</h1>
        <p className="text-gray-500 text-sm mt-1">
          Manage your administrator details, avatar photo, and account security preferences.
        </p>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
        {/* Left Column: Avatar & Account Summary */}
        <div className="md:col-span-1 space-y-6">
          <div className="bg-white p-6 rounded-2xl border border-gray-100 shadow-xs text-center space-y-4">
            <div className="relative inline-block mx-auto">
              {avatarUrl ? (
                <img
                  src={avatarUrl}
                  alt={user?.name || 'Admin'}
                  className="w-28 h-28 rounded-full object-cover border-4 border-[#6C63FF]/20 shadow-md"
                />
              ) : (
                <div className="w-28 h-28 rounded-full bg-[#6C63FF]/10 text-[#6C63FF] flex items-center justify-center text-3xl font-bold border-4 border-[#6C63FF]/20 shadow-md">
                  {user?.name ? user.name.charAt(0).toUpperCase() : 'A'}
                </div>
              )}
            </div>

            <div>
              <h3 className="text-base font-bold text-gray-900 m-0">{user?.name || 'System Admin'}</h3>
              <p className="text-xs text-gray-400 mt-0.5 font-mono">{user?.email}</p>
              <span className="inline-flex items-center gap-1 mt-2.5 px-3 py-1 bg-[#6C63FF]/10 text-[#6C63FF] font-semibold text-xs rounded-full">
                <ShieldCheck className="w-3.5 h-3.5" /> Super Admin
              </span>
            </div>

            {/* Avatar Upload Widget */}
            <div className="pt-4 border-t border-gray-100 text-left">
              <label className="block text-xs font-semibold text-gray-700 mb-2">Update Profile Photo</label>
              
              {avatarLoading && (
                <div className="mb-3 bg-indigo-50 border border-indigo-100 text-[#6C63FF] px-3 py-2 rounded-xl text-xs flex items-center gap-2 font-medium">
                  <Loader2 className="w-4 h-4 animate-spin shrink-0" />
                  <span>Saving avatar to profile...</span>
                </div>
              )}

              {avatarSuccess && (
                <div className="mb-3 bg-emerald-50 border border-emerald-200 text-emerald-800 px-3 py-2 rounded-xl text-xs flex items-center gap-2">
                  <CheckCircle2 className="w-4 h-4 text-emerald-600 shrink-0" />
                  <span>{avatarSuccess}</span>
                </div>
              )}

              {avatarError && (
                <div className="mb-3 bg-red-50 border border-red-200 text-red-700 px-3 py-2 rounded-xl text-xs flex items-center gap-2">
                  <AlertCircle className="w-4 h-4 text-red-500 shrink-0" />
                  <span>{avatarError}</span>
                </div>
              )}

              <ImageUploadField
                value={avatarUrl}
                folder="avatars"
                onChange={(newUrl) => handleAvatarChange(newUrl)}
                onRemove={() => handleAvatarChange('')}
              />
            </div>
          </div>
        </div>

        {/* Right Column: Name Edit & Change Password */}
        <div className="md:col-span-2 space-y-6">
          {/* General Information Card */}
          <div className="bg-white p-6 rounded-2xl border border-gray-100 shadow-xs space-y-5">
            <h3 className="text-sm font-bold text-gray-900 flex items-center gap-2 m-0 pb-3 border-b border-gray-100">
              <User className="w-4 h-4 text-[#6C63FF]" /> Account Details
            </h3>

            {/* Display Name Form */}
            <form onSubmit={handleSaveName} className="space-y-4">
              {nameSuccess && (
                <div className="bg-emerald-50 border border-emerald-200 text-emerald-800 px-3.5 py-2.5 rounded-xl text-xs flex items-center gap-2">
                  <CheckCircle2 className="w-4 h-4 text-emerald-600 shrink-0" />
                  <span>{nameSuccess}</span>
                </div>
              )}

              {nameError && (
                <div className="bg-red-50 border border-red-200 text-red-700 px-3.5 py-2.5 rounded-xl text-xs flex items-center gap-2">
                  <AlertCircle className="w-4 h-4 text-red-500 shrink-0" />
                  <span>{nameError}</span>
                </div>
              )}

              <div>
                <label className="block text-xs font-semibold text-gray-700 mb-1.5">Display Name</label>
                <div className="relative">
                  <User className="w-4 h-4 text-gray-400 absolute left-3.5 top-1/2 -translate-y-1/2" />
                  <input
                    type="text"
                    required
                    value={name}
                    onChange={(e) => setName(e.target.value)}
                    placeholder="Administrator Name"
                    className="w-full pl-10 pr-4 py-2.5 bg-gray-50 border border-gray-200 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-[#6C63FF] focus:bg-white"
                  />
                </div>
              </div>

              <div>
                <label className="block text-xs font-semibold text-gray-700 mb-1.5">
                  Email Address <span className="text-gray-400 font-normal">(Read-only)</span>
                </label>
                <div className="relative">
                  <Mail className="w-4 h-4 text-gray-400 absolute left-3.5 top-1/2 -translate-y-1/2" />
                  <input
                    type="email"
                    disabled
                    value={email}
                    className="w-full pl-10 pr-4 py-2.5 bg-gray-100 border border-gray-200 rounded-xl text-sm text-gray-500 cursor-not-allowed font-mono"
                  />
                </div>
              </div>

              <div className="pt-2 flex justify-end">
                <button
                  type="submit"
                  disabled={nameLoading || name.trim() === user?.name}
                  className="px-5 py-2.5 bg-[#6C63FF] hover:bg-[#5a52e0] text-white font-semibold rounded-xl shadow-md shadow-[#6C63FF]/20 transition-all flex items-center gap-2 text-xs cursor-pointer disabled:opacity-50"
                >
                  {nameLoading ? (
                    <>
                      <Loader2 className="w-4 h-4 animate-spin" />
                      Saving...
                    </>
                  ) : (
                    <>
                      <Save className="w-4 h-4" />
                      Save Name
                    </>
                  )}
                </button>
              </div>
            </form>
          </div>

          {/* Change Password Card */}
          <div className="bg-white p-6 rounded-2xl border border-gray-100 shadow-xs space-y-5">
            <h3 className="text-sm font-bold text-gray-900 flex items-center gap-2 m-0 pb-3 border-b border-gray-100">
              <KeyRound className="w-4 h-4 text-[#6C63FF]" /> Security & Change Password
            </h3>

            <form onSubmit={handleChangePassword} className="space-y-4">
              {passwordSuccess && (
                <div className="bg-emerald-50 border border-emerald-200 text-emerald-800 px-3.5 py-2.5 rounded-xl text-xs flex items-center gap-2">
                  <CheckCircle2 className="w-4 h-4 text-emerald-600 shrink-0" />
                  <span>{passwordSuccess}</span>
                </div>
              )}

              {passwordError && (
                <div className="bg-red-50 border border-red-200 text-red-700 px-3.5 py-2.5 rounded-xl text-xs flex items-center gap-2">
                  <AlertCircle className="w-4 h-4 text-red-500 shrink-0" />
                  <span>{passwordError}</span>
                </div>
              )}

              <div>
                <label className="block text-xs font-semibold text-gray-700 mb-1.5">Current Password</label>
                <div className="relative">
                  <Lock className="w-4 h-4 text-gray-400 absolute left-3.5 top-1/2 -translate-y-1/2" />
                  <input
                    type={showCurrentPassword ? 'text' : 'password'}
                    required
                    value={currentPassword}
                    onChange={(e) => setCurrentPassword(e.target.value)}
                    placeholder="Enter current password"
                    className="w-full pl-10 pr-10 py-2.5 bg-gray-50 border border-gray-200 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-[#6C63FF] focus:bg-white"
                  />
                  <button
                    type="button"
                    onClick={() => setShowCurrentPassword(!showCurrentPassword)}
                    className="absolute right-3.5 top-1/2 -translate-y-1/2 text-gray-400 hover:text-gray-600"
                  >
                    {showCurrentPassword ? <EyeOff className="w-4 h-4" /> : <Eye className="w-4 h-4" />}
                  </button>
                </div>
              </div>

              <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                <div>
                  <label className="block text-xs font-semibold text-gray-700 mb-1.5">New Password</label>
                  <div className="relative">
                    <Lock className="w-4 h-4 text-gray-400 absolute left-3.5 top-1/2 -translate-y-1/2" />
                    <input
                      type={showNewPassword ? 'text' : 'password'}
                      required
                      minLength={8}
                      value={newPassword}
                      onChange={(e) => setNewPassword(e.target.value)}
                      placeholder="Min. 8 characters"
                      className="w-full pl-10 pr-10 py-2.5 bg-gray-50 border border-gray-200 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-[#6C63FF] focus:bg-white"
                    />
                    <button
                      type="button"
                      onClick={() => setShowNewPassword(!showNewPassword)}
                      className="absolute right-3.5 top-1/2 -translate-y-1/2 text-gray-400 hover:text-gray-600"
                    >
                      {showNewPassword ? <EyeOff className="w-4 h-4" /> : <Eye className="w-4 h-4" />}
                    </button>
                  </div>
                </div>

                <div>
                  <label className="block text-xs font-semibold text-gray-700 mb-1.5">Confirm New Password</label>
                  <div className="relative">
                    <Lock className="w-4 h-4 text-gray-400 absolute left-3.5 top-1/2 -translate-y-1/2" />
                    <input
                      type={showNewPassword ? 'text' : 'password'}
                      required
                      minLength={8}
                      value={confirmPassword}
                      onChange={(e) => setConfirmPassword(e.target.value)}
                      placeholder="Re-enter new password"
                      className="w-full pl-10 pr-10 py-2.5 bg-gray-50 border border-gray-200 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-[#6C63FF] focus:bg-white"
                    />
                  </div>
                </div>
              </div>

              <div className="pt-2 flex justify-end">
                <button
                  type="submit"
                  disabled={passwordLoading}
                  className="px-5 py-2.5 bg-[#6C63FF] hover:bg-[#5a52e0] text-white font-semibold rounded-xl shadow-md shadow-[#6C63FF]/20 transition-all flex items-center gap-2 text-xs cursor-pointer disabled:opacity-50"
                >
                  {passwordLoading ? (
                    <>
                      <Loader2 className="w-4 h-4 animate-spin" />
                      Updating Password...
                    </>
                  ) : (
                    'Change Password'
                  )}
                </button>
              </div>
            </form>
          </div>
        </div>
      </div>
    </div>
  );
};
