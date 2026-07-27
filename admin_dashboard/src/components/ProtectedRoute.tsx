import React from 'react';
import { Navigate, Outlet } from 'react-router-dom';
import { isAuthenticatedAdmin } from '../services/api';

export const ProtectedRoute: React.FC = () => {
  if (!isAuthenticatedAdmin()) {
    return <Navigate to="/login" replace />;
  }

  return <Outlet />;
};
