import AsyncStorage from '@react-native-async-storage/async-storage';
import EncryptedStorage from 'react-native-encrypted-storage';

/**
 * Danh sách key dùng chung trong ứng dụng.
 * Giúp tránh lỗi đánh máy và dễ dàng tái sử dụng.
 */
export const STORAGE_KEYS = {
  ACCESS_TOKEN: 'access_token',
  REFRESH_TOKEN: 'refresh_token',
  USER_PROFILE: 'user_profile',
  THEME: 'app_theme',
  LANGUAGE: 'app_language',
} as const;

/* ============================================================
 * STORAGE THƯỜNG - AsyncStorage (Dùng cho dữ liệu không nhạy cảm)
 * ============================================================ */
export const asyncStorage = {
  /**
   * Lưu dữ liệu vào AsyncStorage.
   * @param key - Khóa định danh dữ liệu.
   * @param value - Dữ liệu cần lưu (tự động stringify nếu không phải string).
   */
  async set(key: string, value: any): Promise<void> {
    try {
      const data = typeof value === 'string' ? value : JSON.stringify(value);
      await AsyncStorage.setItem(key, data);
    } catch (error) {
      console.error(`[normalStorage.set] Lỗi lưu key ${key}:`, error);
    }
  },

  /**
   * Lấy dữ liệu từ AsyncStorage.
   * @returns Dữ liệu (tự động parse JSON) hoặc null nếu không có.
   */
  async get<T = any>(key: string): Promise<T | null> {
    try {
      const data = await AsyncStorage.getItem(key);
      return data ? (JSON.parse(data) as T) : null;
    } catch (error) {
      console.error(`[normalStorage.get] Lỗi lấy key ${key}:`, error);
      return null;
    }
  },

  /**
   * Xóa 1 mục dữ liệu trong AsyncStorage.
   */
  async remove(key: string): Promise<void> {
    try {
      await AsyncStorage.removeItem(key);
    } catch (error) {
      console.error(`[normalStorage.remove] Lỗi xóa key ${key}:`, error);
    }
  },

  /**
   * Xóa toàn bộ dữ liệu của AsyncStorage.
   */
  async clear(): Promise<void> {
    try {
      await AsyncStorage.clear();
    } catch (error) {
      console.error('[normalStorage.clear] Lỗi khi clear AsyncStorage:', error);
    }
  },
};

/* ============================================================
 * STORAGE BẢO MẬT - EncryptedStorage (Dùng cho dữ liệu nhạy cảm)
 * ============================================================ */
export const encryptedStorage = {
  /**
   * Lưu dữ liệu vào EncryptedStorage (mã hóa AES 256-bit).
   */
  async set(key: string, value: any): Promise<void> {
    try {
      const data = typeof value === 'string' ? value : JSON.stringify(value);
      await EncryptedStorage.setItem(key, data);
    } catch (error) {
      console.error(`[secureStorage.set] Lỗi lưu key ${key}:`, error);
    }
  },

  /**
   * Lấy dữ liệu từ EncryptedStorage (đã mã hóa).
   */
  async get<T = any>(key: string): Promise<T | null> {
    try {
      const data = await EncryptedStorage.getItem(key);
      return data ? (JSON.parse(data) as T) : null;
    } catch (error) {
      console.error(`[secureStorage.get] Lỗi lấy key ${key}:`, error);
      return null;
    }
  },

  /**
   * Xóa 1 mục dữ liệu trong EncryptedStorage.
   */
  async remove(key: string): Promise<void> {
    try {
      await EncryptedStorage.removeItem(key);
    } catch (error) {
      console.error(`[secureStorage.remove] Lỗi xóa key ${key}:`, error);
    }
  },

  /**
   * Xóa toàn bộ dữ liệu của EncryptedStorage.
   */
  async clear(): Promise<void> {
    try {
      await EncryptedStorage.clear();
    } catch (error) {
      console.error(
        '[secureStorage.clear] Lỗi khi clear EncryptedStorage:',
        error,
      );
    }
  },
};

/* ============================================================
 * HÀM TIỆN ÍCH CHUNG
 * ============================================================ */

/**
 * Xóa toàn bộ dữ liệu của cả 2 storage.
 * Dùng trong trường hợp logout hoặc reset toàn bộ ứng dụng.
 */
export async function clearAllStorages(): Promise<void> {
  try {
    await Promise.all([asyncStorage.clear(), encryptedStorage.clear()]);
  } catch (error) {
    console.error('[clearAllStorages] Lỗi khi xóa toàn bộ dữ liệu:', error);
  }
}
