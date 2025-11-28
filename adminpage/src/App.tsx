import React from 'react';
import { BrowserRouter as Router, Routes, Route, Navigate, useLocation } from 'react-router-dom';
import { AuthProvider, useAuth } from './presentation/hooks/useAuth';
import MainLayout from './presentation/layout/MainLayout';
import Dashboard from './presentation/pages/Dashboard';
import UsersManagement from './presentation/pages/UsersManagement';
import ExerciseManagement from './presentation/pages/ExerciseManagement';
import LoginPage from './presentation/pages/LoginPage';

// Protected route component that checks authentication
const ProtectedRoute: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const { isAuthenticated, loading } = useAuth();
  const location = useLocation();

  if (loading) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-gray-50">
        <div className="text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600 mx-auto"></div>
          <p className="mt-4 text-gray-600">Loading...</p>
        </div>
      </div>
    );
  }

  if (!isAuthenticated) {
    // Redirect to login page with return URL
    return <Navigate to="/login" state={{ from: location }} replace />;
  }

  return <>{children}</>;
};

// Public route component that redirects authenticated users
const PublicRoute: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const { isAuthenticated, loading } = useAuth();
  const location = useLocation();

  if (loading) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-gray-50">
        <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600"></div>
      </div>
    );
  }

  // If user is already authenticated, redirect to the intended page or dashboard
  if (isAuthenticated) {
    const from = location.state?.from?.pathname || '/dashboard';
    return <Navigate to={from} replace />;
  }

  return <>{children}</>;
};

const AppContent: React.FC = () => {
  return (
    <Router>
      <Routes>
        {/* Login route - public but redirects authenticated users */}
        <Route path="/login" element={
          <PublicRoute>
            <LoginPage />
          </PublicRoute>
        } />

        {/* Protected routes */}
        <Route path="/" element={
          <ProtectedRoute>
            <MainLayout />
          </ProtectedRoute>
        }>
          {/* Default redirect */}
          <Route index element={<Navigate to="/dashboard" replace />} />

          {/* Dashboard */}
          <Route path="dashboard" element={<Dashboard />} />

          {/* User Management */}
          <Route path="users" element={<UsersManagement />} />
          <Route path="users/roles" element={<div className="p-6"><h1 className="text-2xl font-bold">Role Management</h1><p className="text-gray-600">Manage user roles and permissions</p></div>} />
          <Route path="users/permissions" element={<div className="p-6"><h1 className="text-2xl font-bold">Permission Management</h1><p className="text-gray-600">Manage system permissions</p></div>} />

          {/* Exercise Management */}
          <Route path="exercises" element={<ExerciseManagement />} />
          <Route path="exercises/equipment" element={<div className="p-6"><h1 className="text-2xl font-bold">Equipment Management</h1><p className="text-gray-600">Manage exercise equipment</p></div>} />
          <Route path="exercises/body-parts" element={<div className="p-6"><h1 className="text-2xl font-bold">Body Parts Management</h1><p className="text-gray-600">Manage exercise body parts</p></div>} />
          <Route path="exercises/muscles" element={<div className="p-6"><h1 className="text-2xl font-bold">Muscles Management</h1><p className="text-gray-600">Manage muscle groups</p></div>} />
          <Route path="exercises/types" element={<div className="p-6"><h1 className="text-2xl font-bold">Exercise Types Management</h1><p className="text-gray-600">Manage exercise types</p></div>} />
          <Route path="exercises/categories" element={<div className="p-6"><h1 className="text-2xl font-bold">Exercise Categories Management</h1><p className="text-gray-600">Manage exercise categories</p></div>} />
          <Route path="exercises/list" element={<div className="p-6"><h1 className="text-2xl font-bold">Exercises Management</h1><p className="text-gray-600">Manage exercises</p></div>} />

          {/* Catch all */}
          <Route path="*" element={<Navigate to="/dashboard" replace />} />
        </Route>

        {/* Root redirect */}
        <Route path="*" element={<Navigate to="/login" replace />} />
      </Routes>
    </Router>
  );
};

const App: React.FC = () => {
  return (
    <AuthProvider>
      <AppContent />
    </AuthProvider>
  );
};

export default App;
