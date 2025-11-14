import * as bcrypt from "bcryptjs";

// Độ phức tạp (Cost Factor) mặc định cho việc băm.
// Giá trị 10 là mức độ bảo mật tốt và tốc độ chấp nhận được.
// Giá trị cao hơn (ví dụ 12) sẽ chậm hơn nhưng bảo mật hơn.
const SALT_ROUNDS = 10;

/**
 * Băm mật khẩu sử dụng thuật toán bcryptjs.
 * * @param password Mật khẩu ở dạng văn bản thuần cần được băm.
 * @returns Promise<string> Giá trị băm (hash) của mật khẩu.
 */
export async function hashPassword(password: string): Promise<string> {
  try {
    // 1. Tạo salt (chuỗi ngẫu nhiên) với độ phức tạp đã định
    const salt = await bcrypt.genSalt(SALT_ROUNDS);

    // 2. Băm mật khẩu kết hợp với salt
    const hash = await bcrypt.hash(password, salt);

    return hash;
  } catch (error) {
    console.error("Lỗi khi băm mật khẩu:", error);
    // Tùy chọn: ném lỗi hoặc trả về một chuỗi lỗi/giá trị không hợp lệ
    throw new Error("Không thể mã hóa mật khẩu.");
  }
}

/**
 * So sánh mật khẩu ở dạng văn bản thuần với giá trị băm đã lưu.
 * * @param password Mật khẩu người dùng nhập vào (plain text).
 * @param hash Giá trị băm (hash) đã được lưu trữ trong cơ sở dữ liệu.
 * @returns Promise<boolean> Trả về true nếu khớp, ngược lại là false.
 */
export async function comparePassword(
  password: string,
  hash: string
): Promise<boolean> {
  try {
    // Hàm compare sẽ tự động trích xuất salt từ hash và thực hiện so sánh
    const isMatch = await bcrypt.compare(password, hash);
    return isMatch;
  } catch (error) {
    console.error("Lỗi khi so sánh mật khẩu:", error);
    // Trong trường hợp lỗi, luôn trả về false để tránh rò rỉ bảo mật
    return false;
  }
}
