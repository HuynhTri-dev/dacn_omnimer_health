import React, { useState, useEffect } from "react";
import { Outlet } from "react-router-dom";
import { useAuth } from "../hooks/useAuth";
import Sidebar from "./Sidebar";
import Header from "./Header";
import type { NavigationItem } from "../../shared/types";

const MainLayout: React.FC = () => {
  const [sidebarOpen, setSidebarOpen] = useState(false);
  const { user, loading, isAuthenticated } = useAuth();

  // Close sidebar when clicking outside on mobile
  useEffect(() => {
    const handleResize = () => {
      if (window.innerWidth >= 1024) {
        setSidebarOpen(false);
      }
    };

    window.addEventListener("resize", handleResize);
    return () => window.removeEventListener("resize", handleResize);
  }, []);

  // Navigation items - you can customize this based on user roles
  const navigation: NavigationItem[] = [
    {
      key: "dashboard",
      label: "Dashboard",
      path: "/dashboard",
    },
    {
      key: "users",
      label: "User Management",
      path: "/users",
      children: [
        {
          key: "users-list",
          label: "Users",
          path: "/users",
        },
        {
          key: "roles",
          label: "Roles",
          path: "/users/roles",
        },
        {
          key: "permissions",
          label: "Permissions",
          path: "/users/permissions",
        },
      ],
    },
    {
      key: "exercises",
      label: "Exercise Management",
      path: "/exercises",
      children: [
        {
          key: "equipment",
          label: "Equipment",
          path: "/exercises/equipment",
        },
        {
          key: "body-parts",
          label: "Body Parts",
          path: "/exercises/body-parts",
        },
        {
          key: "muscles",
          label: "Muscles",
          path: "/exercises/muscles",
        },
        {
          key: "exercise-types",
          label: "Exercise Types",
          path: "/exercises/types",
        },
        {
          key: "exercise-categories",
          label: "Exercise Categories",
          path: "/exercises/categories",
        },
        {
          key: "exercises-list",
          label: "Exercises",
          path: "/exercises/list",
        },
      ],
    },
  ];

  // Show loading state
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

  // Show auth error or redirect to login
  if (!isAuthenticated || !user) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-gray-50">
        <div className="text-center">
          <div className="text-red-500 text-lg">Authentication required</div>
          <p className="mt-2 text-gray-600">
            Please login to access the admin panel.
          </p>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gray-50 flex">
      <Sidebar
        navigation={navigation}
        isOpen={sidebarOpen}
        onToggle={() => setSidebarOpen(!sidebarOpen)}
      />

      {/* Main content */}
      <div className="flex-1 flex flex-col lg:ml-0">
        <Header onToggleSidebar={() => setSidebarOpen(!sidebarOpen)} />
        <main className="flex-1 overflow-y-auto">
          <div className="p-4 lg:p-6">
            <Outlet />
          </div>
        </main>
      </div>
    </div>
  );
};

export default MainLayout;
