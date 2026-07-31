import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { GoogleLogin, type CredentialResponse } from '@react-oauth/google';
import { loginAdminWithGoogle } from '../services/api';
import { ShieldCheck, AlertCircle, Loader2 } from 'lucide-react';

export const LoginPage: React.FC = () => {
  const navigate = useNavigate();
  const [error, setError] = useState<string | null>(null);
  const [loading, setLoading] = useState(false);

  const handleGoogleSuccess = async (credentialResponse: CredentialResponse) => {
    if (!credentialResponse.credential) {
      setError('Failed to retrieve Google ID token.');
      return;
    }

    setError(null);
    setLoading(true);

    try {
      await loginAdminWithGoogle(credentialResponse.credential);
      navigate('/', { replace: true });
    } catch (err: any) {
      console.error('Google Admin Login error:', err);
      if (err.response?.data?.message) {
        setError(err.response.data.message);
      } else if (err.message) {
        setError(err.message);
      } else {
        setError('Google Sign-In failed. Admin access required.');
      }
    } finally {
      setLoading(false);
    }
  };

  const handleGoogleError = () => {
    setError('Google Sign-In was cancelled or failed to initialize.');
  };

  return (
    <div className="min-h-screen bg-[#F5F6FA] flex items-center justify-center p-4">
      <div className="w-full max-w-md bg-white rounded-2xl shadow-xl border border-gray-100 overflow-hidden">
        {/* Header Banner */}
        <div className="bg-[#1E1E2D] p-8 text-center text-white relative">
          <div className="w-14 h-14 bg-[#6C63FF] rounded-2xl flex items-center justify-center mx-auto mb-3 shadow-lg shadow-[#6C63FF]/30">
            <ShieldCheck className="w-8 h-8 text-white" />
          </div>
          <h1 className="text-2xl font-bold tracking-tight text-white m-0">NextLook Admin</h1>
          <p className="text-gray-400 text-sm mt-1">Management Portal & Dashboard</p>
        </div>

        {/* Login Body */}
        <div className="p-8 space-y-6">
          {error && (
            <div className="bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded-xl flex items-start gap-3 text-sm">
              <AlertCircle className="w-5 h-5 text-red-500 shrink-0 mt-0.5" />
              <span>{error}</span>
            </div>
          )}

          <div className="text-center">
            <p className="text-sm text-gray-600 mb-6">
              Sign in with your Google account to access the NextLook Admin Dashboard.
            </p>

            {loading ? (
              <div className="py-4 flex items-center justify-center gap-2 text-[#6C63FF] font-medium text-sm">
                <Loader2 className="w-5 h-5 animate-spin" />
                <span>Authenticating Admin credentials...</span>
              </div>
            ) : (
              <div className="flex justify-center w-full">
                <GoogleLogin
                  onSuccess={handleGoogleSuccess}
                  onError={handleGoogleError}
                  theme="outline"
                  size="large"
                  shape="rectangular"
                  text="continue_with"
                  logo_alignment="center"
                  width="336"
                />
              </div>
            )}
          </div>

          <div className="pt-2 border-t border-gray-100 text-center text-xs text-gray-400">
            Admin access is restricted to verified administrator accounts only.
          </div>
        </div>
      </div>
    </div>
  );
};
