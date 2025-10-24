import axios, {
  AxiosInstance,
  InternalAxiosRequestConfig,
  AxiosRequestHeaders,
} from 'axios';
import { encryptedStorage, STORAGE_KEYS } from '@/config/storageManager';

// Base instance
export const api: AxiosInstance = axios.create({
  baseURL: 'https://your-backend.com/api',
  timeout: 10000,
});

// Helper lấy accessToken từ EncryptedStorage
async function getAuthHeaders(customHeaders?: Record<string, string>) {
  const token = await encryptedStorage.get(STORAGE_KEYS.ACCESS_TOKEN);
  return {
    ...(customHeaders ?? {}),
    Authorization: token ? `Bearer ${token}` : '',
  };
}

// Request interceptor
api.interceptors.request.use(
  async (
    config: InternalAxiosRequestConfig,
  ): Promise<InternalAxiosRequestConfig> => {
    const headers = (await getAuthHeaders(
      config.headers as Record<string, string>,
    )) as AxiosRequestHeaders;
    config.headers = headers;
    return config;
  },
  error => Promise.reject(error),
);

// Không transform response ở đây nữa!
// Chỉ xử lý lỗi toàn cục
api.interceptors.response.use(
  response => response,
  error => Promise.reject(error),
);
