import React, { useEffect, useState } from "react";
import type { User, Exercise } from "../../shared/types";
import { UserUseCase } from "../../domain/usecases/user.usecase";
import { UserRepositoryImpl } from "../../data/models/user.repository.impl";
import { ExerciseUseCase } from "../../domain/usecases/exercise.usecase";
import { ExerciseRepositoryImpl } from "../../data/models/exercise.repository.impl";

interface DashboardStats {
  totalUsers: number;
  totalEquipment: number;
  totalBodyParts: number;
  totalMuscles: number;
  totalExerciseTypes: number;
  totalExerciseCategories: number;
  totalExercises: number;
  recentUsers: User[];
  recentExercises: Exercise[];
}

const Dashboard: React.FC = () => {
  const [stats, setStats] = useState<DashboardStats>({
    totalUsers: 0,
    totalEquipment: 0,
    totalBodyParts: 0,
    totalMuscles: 0,
    totalExerciseTypes: 0,
    totalExerciseCategories: 0,
    totalExercises: 0,
    recentUsers: [],
    recentExercises: [],
  });
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const fetchDashboardData = async () => {
      try {
        const userUseCase = new UserUseCase(new UserRepositoryImpl());
        const exerciseUseCase = new ExerciseUseCase(
          new ExerciseRepositoryImpl()
        );

        // Fetch data in parallel
        const [
          usersResponse,
          equipmentResponse,
          bodyPartsResponse,
          musclesResponse,
          exerciseTypesResponse,
          exerciseCategoriesResponse,
          exercisesResponse,
        ] = await Promise.all([
          userUseCase.getUsers({ page: 1, limit: 100 }),
          exerciseUseCase.getEquipment({ page: 1, limit: 100 }),
          exerciseUseCase.getBodyParts({ page: 1, limit: 100 }),
          exerciseUseCase.getMuscles({ page: 1, limit: 100 }),
          exerciseUseCase.getExerciseTypes({ page: 1, limit: 100 }),
          exerciseUseCase.getExerciseCategories({ page: 1, limit: 100 }),
          exerciseUseCase.getExercises({ page: 1, limit: 100 }),
        ]);

        // Get recent items (last 5)
        const recentUsers = usersResponse.data.slice(0, 5);
        const recentExercises = exercisesResponse.data.slice(0, 5);

        setStats({
          totalUsers: usersResponse.total,
          totalEquipment: equipmentResponse.total,
          totalBodyParts: bodyPartsResponse.total,
          totalMuscles: musclesResponse.total,
          totalExerciseTypes: exerciseTypesResponse.total,
          totalExerciseCategories: exerciseCategoriesResponse.total,
          totalExercises: exercisesResponse.total,
          recentUsers,
          recentExercises,
        });
      } catch (error) {
        console.error("Failed to fetch dashboard data:", error);
      } finally {
        setLoading(false);
      }
    };

    fetchDashboardData();
  }, []);

  const StatCard = ({
    title,
    value,
    icon,
    color,
  }: {
    title: string;
    value: number;
    icon: string;
    color: string;
  }) => (
    <div className="bg-white rounded-lg shadow p-6 border-l-4 border-blue-500">
      <div className="flex items-center justify-between">
        <div>
          <p className="text-sm font-medium text-gray-600">{title}</p>
          <p className="text-2xl font-semibold text-gray-900">
            {value.toLocaleString()}
          </p>
        </div>
        <div className={`p-3 rounded-full ${color}`}>
          <svg
            className="w-6 h-6 text-white"
            fill="none"
            stroke="currentColor"
            viewBox="0 0 24 24"
          >
            <path
              strokeLinecap="round"
              strokeLinejoin="round"
              strokeWidth={2}
              d="M12 4.354a4 4 0 110 5.292M15 21H3v-1a6 6 0 0112 0v1zm0 0h6v-1a6 6 0 00-9-5.197M13 7a4 4 0 11-8 0 4 4 0 018 0z"
            />
          </svg>
        </div>
      </div>
    </div>
  );

  if (loading) {
    return (
      <div className="space-y-6">
        <div className="animate-pulse">
          <div className="h-8 bg-gray-200 rounded w-1/4 mb-6"></div>
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
            {[...Array(8)].map((_, i) => (
              <div key={i} className="bg-gray-200 h-32 rounded-lg"></div>
            ))}
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      {/* Header */}
      <div>
        <h1 className="text-3xl font-bold text-gray-900">Dashboard</h1>
        <p className="mt-2 text-gray-600">
          Welcome to the OmniMer Health Admin Panel
        </p>
      </div>

      {/* Stats Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        <StatCard
          title="Total Users"
          value={stats.totalUsers}
          icon="users"
          color="bg-blue-500"
        />
        <StatCard
          title="Total Equipment"
          value={stats.totalEquipment}
          icon="equipment"
          color="bg-green-500"
        />
        <StatCard
          title="Body Parts"
          value={stats.totalBodyParts}
          icon="body-parts"
          color="bg-purple-500"
        />
        <StatCard
          title="Muscles"
          value={stats.totalMuscles}
          icon="muscles"
          color="bg-yellow-500"
        />
        <StatCard
          title="Exercise Types"
          value={stats.totalExerciseTypes}
          icon="types"
          color="bg-red-500"
        />
        <StatCard
          title="Exercise Categories"
          value={stats.totalExerciseCategories}
          icon="categories"
          color="bg-indigo-500"
        />
        <StatCard
          title="Total Exercises"
          value={stats.totalExercises}
          icon="exercises"
          color="bg-pink-500"
        />
        <StatCard
          title="System Health"
          value={100}
          icon="health"
          color="bg-green-500"
        />
      </div>

      {/* Recent Data */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* Recent Users */}
        <div className="bg-white rounded-lg shadow">
          <div className="p-6 border-b border-gray-200">
            <h2 className="text-lg font-semibold text-gray-900">
              Recent Users
            </h2>
          </div>
          <div className="divide-y divide-gray-200">
            {stats.recentUsers.length === 0 ? (
              <div className="p-6 text-center text-gray-500">
                No users found
              </div>
            ) : (
              stats.recentUsers.map((user) => (
                <div
                  key={user._id}
                  className="p-4 flex items-center justify-between"
                >
                  <div className="flex items-center space-x-3">
                    <div className="w-10 h-10 bg-blue-500 rounded-full flex items-center justify-center text-white font-medium">
                      {user.firstName.charAt(0)}
                      {user.lastName.charAt(0)}
                    </div>
                    <div>
                      <p className="font-medium text-gray-900">
                        {user.firstName} {user.lastName}
                      </p>
                      <p className="text-sm text-gray-500">{user.email}</p>
                    </div>
                  </div>
                  <div className="text-sm text-gray-500">
                    {new Date(user.createdAt).toLocaleDateString()}
                  </div>
                </div>
              ))
            )}
          </div>
        </div>

        {/* Recent Exercises */}
        <div className="bg-white rounded-lg shadow">
          <div className="p-6 border-b border-gray-200">
            <h2 className="text-lg font-semibold text-gray-900">
              Recent Exercises
            </h2>
          </div>
          <div className="divide-y divide-gray-200">
            {stats.recentExercises.length === 0 ? (
              <div className="p-6 text-center text-gray-500">
                No exercises found
              </div>
            ) : (
              stats.recentExercises.map((exercise) => (
                <div
                  key={exercise._id}
                  className="p-4 flex items-center justify-between"
                >
                  <div className="flex items-center space-x-3">
                    <div className="w-10 h-10 bg-green-500 rounded-lg flex items-center justify-center text-white font-medium">
                      💪
                    </div>
                    <div>
                      <p className="font-medium text-gray-900">
                        {exercise.name}
                      </p>
                      <p className="text-sm text-gray-500">
                        {exercise.category?.name} • {exercise.type?.name}
                      </p>
                    </div>
                  </div>
                  <div className="text-sm text-gray-500">
                    {new Date(exercise.createdAt).toLocaleDateString()}
                  </div>
                </div>
              ))
            )}
          </div>
        </div>
      </div>

      {/* Quick Actions */}
      <div className="bg-white rounded-lg shadow p-6">
        <h2 className="text-lg font-semibold text-gray-900 mb-4">
          Quick Actions
        </h2>
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
          <a
            href="/users"
            className="flex items-center justify-center p-4 border-2 border-dashed border-gray-300 rounded-lg hover:border-blue-500 hover:bg-blue-50 transition-colors"
          >
            <div className="text-center">
              <svg
                className="w-8 h-8 text-gray-400 mx-auto mb-2"
                fill="none"
                stroke="currentColor"
                viewBox="0 0 24 24"
              >
                <path
                  strokeLinecap="round"
                  strokeLinejoin="round"
                  strokeWidth={2}
                  d="M18 9v3m0 0v3m0-3h3m-3 0h-3m-2-5a4 4 0 11-8 0 4 4 0 018 0zM3 20a6 6 0 0112 0v1H3v-1z"
                />
              </svg>
              <span className="text-sm font-medium text-gray-700">
                Add User
              </span>
            </div>
          </a>
          <a
            href="/exercises/list"
            className="flex items-center justify-center p-4 border-2 border-dashed border-gray-300 rounded-lg hover:border-green-500 hover:bg-green-50 transition-colors"
          >
            <div className="text-center">
              <svg
                className="w-8 h-8 text-gray-400 mx-auto mb-2"
                fill="none"
                stroke="currentColor"
                viewBox="0 0 24 24"
              >
                <path
                  strokeLinecap="round"
                  strokeLinejoin="round"
                  strokeWidth={2}
                  d="M12 6v6m0 0v6m0-6h6m-6 0H6"
                />
              </svg>
              <span className="text-sm font-medium text-gray-700">
                Add Exercise
              </span>
            </div>
          </a>
          <a
            href="/exercises/equipment"
            className="flex items-center justify-center p-4 border-2 border-dashed border-gray-300 rounded-lg hover:border-purple-500 hover:bg-purple-50 transition-colors"
          >
            <div className="text-center">
              <svg
                className="w-8 h-8 text-gray-400 mx-auto mb-2"
                fill="none"
                stroke="currentColor"
                viewBox="0 0 24 24"
              >
                <path
                  strokeLinecap="round"
                  strokeLinejoin="round"
                  strokeWidth={2}
                  d="M12 6v6m0 0v6m0-6h6m-6 0H6"
                />
              </svg>
              <span className="text-sm font-medium text-gray-700">
                Add Equipment
              </span>
            </div>
          </a>
          <a
            href="/users/roles"
            className="flex items-center justify-center p-4 border-2 border-dashed border-gray-300 rounded-lg hover:border-indigo-500 hover:bg-indigo-50 transition-colors"
          >
            <div className="text-center">
              <svg
                className="w-8 h-8 text-gray-400 mx-auto mb-2"
                fill="none"
                stroke="currentColor"
                viewBox="0 0 24 24"
              >
                <path
                  strokeLinecap="round"
                  strokeLinejoin="round"
                  strokeWidth={2}
                  d="M12 6v6m0 0v6m0-6h6m-6 0H6"
                />
              </svg>
              <span className="text-sm font-medium text-gray-700">
                Manage Roles
              </span>
            </div>
          </a>
        </div>
      </div>
    </div>
  );
};

export default Dashboard;
