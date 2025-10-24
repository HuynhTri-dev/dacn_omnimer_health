/**
 * Danh sách endpoint API dùng chung trong ứng dụng
 * Giúp tái sử dụng và tránh hardcode URL trong code
 */

export const API_ENDPOINTS = {
  AUTH: {
    REGISTER: '/v1/auth/register',
    LOGIN: '/v1/auth/login',
    LOGOUT: '/v1/auth/logout',
    REFRESH_TOKEN: '/v1/auth/refresh-token',
  },
  USER: {
    UPDATE_PROFILE: '/users/update',
    UPLOAD_AVATAR: '/users/upload-avatar',
    GET_LIST: '/users',
    GET_BY_ID: (id: string) => `/users/${id}`,
  },
};

export type EndpointKeys = keyof typeof API_ENDPOINTS;
