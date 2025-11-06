import { createSlice, createAsyncThunk, PayloadAction } from '@reduxjs/toolkit';
import { encryptedStorage, STORAGE_KEYS } from '@/config/storageManager';
import { RegisterUserService } from '@/domain/services/registerUserService';
import { UserRepository } from '@/data/repositories/userRepository';
import { ApiResponse } from '@/app/types/ApiResponse';
import { IAuthResponse } from '@/data/entities/AuthResponse';

// State

// Khởi tạo service
const registerService = new RegisterUserService(new UserRepository());

interface AuthState {
  authRes: IAuthResponse | null;
  loading: boolean;
  error: string | null;
}

const initialState: AuthState = {
  authRes: null,
  loading: false,
  error: null,
};

// Async thunk đăng ký
export const registerUser = createAsyncThunk(
  'auth/registerUser',
  async (
    payload: {
      email: string;
      password: string;
      fullname: string;
      avatar?: any;
    },
    thunkAPI,
  ) => {
    try {
      const res = await registerService.execute(
        { email: payload.email, fullname: payload.fullname },
        payload.password,
        payload.avatar,
      );
      return res;
    } catch (err: any) {
      return thunkAPI.rejectWithValue(err.message);
    }
  },
);

export const authSlice = createSlice({
  name: 'auth',
  initialState,
  reducers: {
    logout(state) {
      state.authRes = null;
      encryptedStorage.set(STORAGE_KEYS.ACCESS_TOKEN, '');
    },
  },
  extraReducers: builder => {
    builder
      .addCase(registerUser.pending, state => {
        state.loading = true;
        state.error = null;
      })
      .addCase(
        registerUser.fulfilled,
        (state, action: PayloadAction<ApiResponse<IAuthResponse>>) => {
          state.loading = false;
          state.authRes = action.payload.data ?? null;
        },
      )
      .addCase(registerUser.rejected, (state, action) => {
        state.loading = false;
        state.error = action.error ?? 'Đăng ký thất bại';
      })
      .addCase(loginUser.pending, state => {
        state.loading = true;
        state.error = null;
      })
      .addCase(
        loginUser.fulfilled,
        (state, action: PayloadAction<ApiResponse<IAuthResponse>>) => {
          state.loading = false;
          state.authRes = action.payload.data ?? null;
        },
      )
      .addCase(loginUser.rejected, (state, action) => {
        state.loading = false;
        state.error = action.error ?? 'Đăng nhập thất bại';
      });
  },
});

export const { logout } = authSlice.actions;
export default authSlice.reducer;

// Async thunk đăng nhập
export const loginUser = createAsyncThunk(
  'auth/loginUser',
  async (payload: { email: string; password: string }, thunkAPI) => {
    try {
      const repo = new UserRepository();
      const res = await repo.login(payload.email, payload.password);
      return res;
    } catch (err: any) {
      return thunkAPI.rejectWithValue(err.message ?? 'Đăng nhập thất bại');
    }
  },
);
