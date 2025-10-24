import { api } from '@/config/axiosInstance';
import { ApiResponse } from '@/app/types/ApiResponse';

export type RequestOptions = {
  query?: Record<string, any>;
  body?: Record<string, any>;
  headers?: Record<string, string>;
  isFormData?: boolean;
};

// ------------------------
// Helper chuyển body → FormData nếu cần
// ------------------------
function prepareData(
  body?: Record<string, any>,
  isFormData?: boolean,
  customHeaders?: Record<string, string>,
): { data: any; headers: Record<string, string> } {
  const headers: Record<string, string> = { ...(customHeaders ?? {}) };
  let data = body ?? {};

  if (isFormData) {
    const formData = new FormData();
    Object.keys(data).forEach(key => {
      const value = data[key];
      if (value !== undefined && value !== null) {
        // React Native: nếu object có uri (ImagePicker/File), append trực tiếp
        formData.append(key, value?.uri ? value : String(value));
      }
    });
    data = formData;
    headers['Content-Type'] = 'multipart/form-data';
  }

  return { data, headers };
}

// ------------------------
// Helper chuẩn hóa response
// ------------------------
async function handleResponse<T>(
  promise: Promise<any>,
): Promise<ApiResponse<T>> {
  try {
    const res = await promise;
    return {
      success: res.data?.success ?? true,
      message: res.data?.message ?? '',
      data: res.data?.data ?? res.data,
    };
  } catch (err: any) {
    return Promise.reject({
      success: false,
      message: err.response?.data?.message ?? err.message,
      data: null,
    } as ApiResponse<null>);
  }
}

// ------------------------
// HTTP methods
// ------------------------
export async function get<T>(
  url: string,
  options?: RequestOptions,
): Promise<ApiResponse<T>> {
  return handleResponse(
    api.get(url, { params: options?.query, headers: options?.headers }),
  );
}

export async function post<T>(
  url: string,
  options?: RequestOptions,
): Promise<ApiResponse<T>> {
  const { data, headers } = prepareData(
    options?.body,
    options?.isFormData,
    options?.headers,
  );
  return handleResponse(
    api.post(url, data, { headers, params: options?.query }),
  );
}

export async function put<T>(
  url: string,
  options?: RequestOptions,
): Promise<ApiResponse<T>> {
  const { data, headers } = prepareData(
    options?.body,
    options?.isFormData,
    options?.headers,
  );
  return handleResponse(
    api.put(url, data, { headers, params: options?.query }),
  );
}

export async function patch<T>(
  url: string,
  options?: RequestOptions,
): Promise<ApiResponse<T>> {
  const { data, headers } = prepareData(
    options?.body,
    options?.isFormData,
    options?.headers,
  );
  return handleResponse(
    api.patch(url, data, { headers, params: options?.query }),
  );
}

export async function del<T>(
  url: string,
  options?: RequestOptions,
): Promise<ApiResponse<T>> {
  return handleResponse(
    api.delete(url, { headers: options?.headers, params: options?.query }),
  );
}
