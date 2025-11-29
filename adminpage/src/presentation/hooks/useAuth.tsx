import React, {
  createContext,
  useContext,
  useReducer,
  useEffect,
  type ReactNode,
} from "react";
import type { User } from "../../shared/types";
import { AuthRepositoryImpl } from "../../data/models/auth.repository.impl";
import { AuthUseCase } from "../../domain/usecases/auth.usecase";

// Auth State
interface AuthState {
  user: User | null;
  loading: boolean;
  isAuthenticated: boolean;
  error: string | null;
}

// Auth Action Types
type AuthAction =
  | { type: "AUTH_START" }
  | { type: "AUTH_SUCCESS"; payload: User }
  | { type: "AUTH_FAILURE"; payload: string }
  | { type: "LOGOUT" }
  | { type: "CLEAR_ERROR" };

// Initial State
const initialState: AuthState = {
  user: null,
  loading: true,
  isAuthenticated: false,
  error: null,
};

// Reducer
const authReducer = (state: AuthState, action: AuthAction): AuthState => {
  switch (action.type) {
    case "AUTH_START":
      return {
        ...state,
        loading: true,
        error: null,
      };
    case "AUTH_SUCCESS":
      return {
        ...state,
        loading: false,
        isAuthenticated: true,
        user: action.payload,
        error: null,
      };
    case "AUTH_FAILURE":
      return {
        ...state,
        loading: false,
        isAuthenticated: false,
        user: null,
        error: action.payload,
      };
    case "LOGOUT":
      return {
        ...state,
        loading: false,
        isAuthenticated: false,
        user: null,
        error: null,
      };
    case "CLEAR_ERROR":
      return {
        ...state,
        error: null,
      };
    default:
      return state;
  }
};

// Context
const AuthContext = createContext<{
  state: AuthState;
  login: (email: string, password: string) => Promise<void>;
  register: (userData: any) => Promise<void>;
  logout: () => Promise<void>;
  refreshToken: () => Promise<void>;
  clearError: () => void;
} | null>(null);

// Provider Props
interface AuthProviderProps {
  children: ReactNode;
}

// Create instances
const authRepository = new AuthRepositoryImpl();
const authUseCase = new AuthUseCase(authRepository);

// Provider
export const AuthProvider: React.FC<AuthProviderProps> = ({ children }) => {
  const [state, dispatch] = useReducer(authReducer, initialState);

  // Check if user is authenticated on mount
  useEffect(() => {
    const checkAuth = async () => {
      if (authUseCase.isAuthenticated()) {
        try {
          const user = await authUseCase.getCurrentUser();
          dispatch({ type: "AUTH_SUCCESS", payload: user });
        } catch (error) {
          // If getCurrentUser fails, clear tokens
          await authUseCase.logout();
          dispatch({
            type: "AUTH_FAILURE",
            payload: "Session expired. Please login again.",
          });
        }
      } else {
        dispatch({ type: "LOGOUT" }); // Set to not authenticated without error
      }
    };

    checkAuth();
  }, []);

  const login = async (email: string, password: string): Promise<void> => {
    try {
      dispatch({ type: "AUTH_START" });
      const response = await authUseCase.login(email, password);
      dispatch({ type: "AUTH_SUCCESS", payload: response.user });
    } catch (error: any) {
      dispatch({
        type: "AUTH_FAILURE",
        payload: error.error || "Login failed",
      });
      throw error;
    }
  };

  const register = async (userData: any): Promise<void> => {
    try {
      dispatch({ type: "AUTH_START" });
      const response = await authUseCase.register(userData);
      dispatch({ type: "AUTH_SUCCESS", payload: response.user });
    } catch (error: any) {
      dispatch({
        type: "AUTH_FAILURE",
        payload: error.error || "Registration failed",
      });
      throw error;
    }
  };

  const logout = async (): Promise<void> => {
    try {
      await authUseCase.logout();
    } catch (error) {
      console.error("Logout error:", error);
    } finally {
      dispatch({ type: "LOGOUT" });
    }
  };

  const refreshToken = async (): Promise<void> => {
    try {
      await authUseCase.refreshToken();
      // Token is automatically updated in the usecase
      console.log("Token refreshed");
    } catch (error: any) {
      dispatch({
        type: "AUTH_FAILURE",
        payload: error.error || "Token refresh failed",
      });
      throw error;
    }
  };

  const clearError = (): void => {
    dispatch({ type: "CLEAR_ERROR" });
  };

  return (
    <AuthContext.Provider
      value={{
        state,
        login,
        register,
        logout,
        refreshToken,
        clearError,
      }}
    >
      {children}
    </AuthContext.Provider>
  );
};

// Hook to use auth context
export const useAuth = () => {
  const context = useContext(AuthContext);
  if (!context) {
    throw new Error("useAuth must be used within an AuthProvider");
  }

  return {
    user: context.state.user,
    loading: context.state.loading,
    isAuthenticated: context.state.isAuthenticated,
    error: context.state.error,
    login: context.login,
    register: context.register,
    logout: context.logout,
    refreshToken: context.refreshToken,
    clearError: context.clearError,
  };
};
