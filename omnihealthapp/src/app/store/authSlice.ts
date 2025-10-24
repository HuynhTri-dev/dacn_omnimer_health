import { createSlice, createAsyncThunk, PayloadAction } from '@reduxjs/toolkit';
import { IUser } from '@/data/models/User.model';
import { encryptedStorage, STORAGE_KEYS } from '@/config/storageManager';
import { RegisterUserService } from '@/domain/services/registerUserService';
import { UserRepository } from '@/data/repositories/userRepository';
import { ApiResponse } from '@/app/types/ApiResponse';

// Khởi tạo service
const registerService = new RegisterUserService(new UserRepository());

interface AuthState {
  user: IUser | null;
  accessToken: string | null;
  loading: boolean;
  error: string | null;
}

const initialState: AuthState = {
  user: null,
  accessToken: null,
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
      state.user = null;
      state.accessToken = null;
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
        (state, action: PayloadAction<ApiResponse<IUser>>) => {
          state.loading = false;
          state.user = action.payload.data ?? null;
          // AccessToken lưu nếu backend trả về
          state.accessToken = (action.payload.data as any)?.accessToken ?? null;
        },
      )
      .addCase(registerUser.rejected, (state, action) => {
        state.loading = false;
        state.error = action.payload ?? 'Đăng ký thất bại';
      });
  },
});

export const { logout } = authSlice.actions;
export default authSlice.reducer;
