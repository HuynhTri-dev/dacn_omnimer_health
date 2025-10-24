import { auth } from '@/config/firebase.config';

export class FirebaseAuthService {
  // Đăng ký user trên Firebase
  static async register(email: string, password: string): Promise<string> {
    const userCredential = await auth().createUserWithEmailAndPassword(
      email,
      password,
    );
    return userCredential.user.uid; // Trả về uid để gửi backend
  }

  // Login
  static async login(email: string, password: string): Promise<string> {
    const userCredential = await auth().signInWithEmailAndPassword(
      email,
      password,
    );
    return userCredential.user.uid;
  }

  // Logout
  static async logout(): Promise<void> {
    await auth().signOut();
  }

  // Lấy user hiện tại
  static getCurrentUser() {
    return auth().currentUser;
  }
}
