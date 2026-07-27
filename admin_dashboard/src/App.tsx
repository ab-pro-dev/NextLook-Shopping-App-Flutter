import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';
import { LoginPage } from './pages/LoginPage';
import { AdminLayout } from './components/AdminLayout';
import { ProtectedRoute } from './components/ProtectedRoute';
import { DashboardPage } from './pages/DashboardPage';
import { PlaceholderPage } from './pages/PlaceholderPage';

export function App() {
  return (
    <BrowserRouter>
      <Routes>
        {/* Public Login Route */}
        <Route path="/login" element={<LoginPage />} />

        {/* Protected Admin Routes */}
        <Route element={<ProtectedRoute />}>
          <Route element={<AdminLayout />}>
            <Route path="/" element={<DashboardPage />} />
            <Route path="/products" element={<PlaceholderPage title="Products" description="Manage clothing catalog, stock levels, sizes, and colors." />} />
            <Route path="/orders" element={<PlaceholderPage title="Orders" description="Track, filter, and update customer order statuses." />} />
            <Route path="/categories" element={<PlaceholderPage title="Categories" description="Manage apparel categories and icons." />} />
            <Route path="/customers" element={<PlaceholderPage title="Customers" description="View registered customer accounts and order history." />} />
            <Route path="/coupons" element={<PlaceholderPage title="Coupons" description="Create and manage promotional discount codes." />} />
            <Route path="/reviews" element={<PlaceholderPage title="Reviews" description="Moderate customer product ratings and reviews." />} />
            <Route path="/reports" element={<PlaceholderPage title="Reports" description="Export sales reports and financial summaries." />} />
            <Route path="/settings" element={<PlaceholderPage title="Settings" description="Configure store settings and admin preferences." />} />
          </Route>
        </Route>

        {/* Fallback Redirect */}
        <Route path="*" element={<Navigate to="/" replace />} />
      </Routes>
    </BrowserRouter>
  );
}

export default App;
