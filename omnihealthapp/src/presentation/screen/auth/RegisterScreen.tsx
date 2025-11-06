import React, { useState } from 'react';
import {
  View,
  Text,
  TouchableOpacity,
  StyleSheet,
  SafeAreaView,
  KeyboardAvoidingView,
  Platform,
  ScrollView,
} from 'react-native';
import { useDispatch, useSelector } from 'react-redux';
import { registerUser } from '@/app/store/authSlice';
import { RootState, AppDispatch } from '@/app/store';
import { useNavigation } from '@react-navigation/native';
import { COLORS } from '@/presentation/theme/colors';
import { Input } from '@/presentation/components/Input';
import { Button } from '@/presentation/components/Button';
import { AuthFooter } from '@/presentation/components/AuthFooter';
import { GenderSelector } from '@/presentation/components/GenderSelector';

export const RegisterScreen = () => {
  const dispatch = useDispatch<AppDispatch>();
  const auth = useSelector((state: RootState) => state.auth);
  const navigation = useNavigation();

  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [fullname, setFullname] = useState('');
  const [birthday, setBirthday] = useState('');
  const [gender, setGender] = useState('');

  const handleRegister = () => {
    // Note: current registerUser thunk expects { email, password, fullname, avatar? }
    // birthday and gender are collected locally but not sent to the current service.
    dispatch(registerUser({ email, password, fullname }));
  };

  const navigateToLogin = () => {
    navigation.navigate('Login' as never);
  };

  return (
    <SafeAreaView style={styles.container}>
      <KeyboardAvoidingView
        behavior={Platform.OS === 'ios' ? 'padding' : 'height'}
        style={styles.keyboardAvoidingView}
      >
        <ScrollView
          contentContainerStyle={styles.scrollView}
          showsVerticalScrollIndicator={false}
        >
          <View style={styles.headerContainer}>
            <TouchableOpacity
              style={styles.addPhotoButton}
              accessibilityLabel="Thêm ảnh"
            >
              <Text style={styles.addPhotoIcon}>+</Text>
            </TouchableOpacity>
            <Text style={styles.headerTitle}>Tạo tài khoản mới</Text>
          </View>

          <View style={styles.formContainer}>
            <View style={styles.inputContainer}>
              <Text style={styles.inputLabel}>Email</Text>
              <Input
                placeholder="Nhập email của bạn"
                value={email}
                onChangeText={setEmail}
                keyboardType="email-address"
                autoCapitalize="none"
                containerStyle={styles.customInput}
              />
            </View>

            <View style={styles.inputContainer}>
              <Text style={styles.inputLabel}>Mật khẩu</Text>
              <Input
                placeholder="Tạo mật khẩu"
                value={password}
                onChangeText={setPassword}
                secureTextEntry
                containerStyle={styles.customInput}
              />
            </View>

            <View style={styles.inputContainer}>
              <Text style={styles.inputLabel}>Họ và tên</Text>
              <Input
                placeholder="Nhập họ và tên của bạn"
                value={fullname}
                onChangeText={setFullname}
                containerStyle={styles.customInput}
              />
            </View>

            <View style={styles.inputContainer}>
              <Text style={styles.inputLabel}>Ngày sinh</Text>
              <Input
                placeholder="DD/MM/YYYY"
                value={birthday}
                onChangeText={setBirthday}
                keyboardType="numbers-and-punctuation"
                containerStyle={styles.customInput}
              />
            </View>

            <View style={styles.inputContainer}>
              <Text style={styles.inputLabel}>Giới tính</Text>
              <GenderSelector value={gender} onSelect={setGender} />
            </View>

            <Button
              title="Tạo tài khoản"
              onPress={handleRegister}
              style={styles.registerButton}
            />

            {auth.loading && (
              <Text style={styles.loadingText}>Đang xử lý...</Text>
            )}
            {auth.error && <Text style={styles.errorText}>{auth.error}</Text>}
          </View>

          <AuthFooter
            questionText="Đã có tài khoản?"
            actionText="Đăng nhập"
            onPress={navigateToLogin}
          />
        </ScrollView>
      </KeyboardAvoidingView>
    </SafeAreaView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: COLORS.WHITE,
  },
  keyboardAvoidingView: {
    flex: 1,
  },
  scrollView: {
    flexGrow: 1,
    padding: 20,
  },
  headerContainer: {
    alignItems: 'center',
    marginVertical: 20,
  },
  headerTitle: {
    fontSize: 24,
    fontWeight: 'bold',
    marginBottom: 20,
    color: COLORS.TEXT_PRIMARY,
  },
  addPhotoButton: {
    width: 70,
    height: 70,
    borderRadius: 35,
    backgroundColor: COLORS.GRAY_500,
    justifyContent: 'center',
    alignItems: 'center',
  },
  addPhotoIcon: {
    fontSize: 30,
    color: COLORS.TEXT_SECONDARY,
  },
  formContainer: {
    width: '100%',
    marginBottom: 30,
  },
  inputContainer: {
    marginBottom: 15,
  },
  inputLabel: {
    fontSize: 14,
    color: COLORS.TEXT_SECONDARY,
    marginBottom: 5,
  },
  customInput: {
    marginBottom: 0,
  },

  registerButton: {
    marginTop: 20,
  },
  loadingText: {
    textAlign: 'center',
    marginTop: 10,
  },
  errorText: {
    color: COLORS.VERY_HARD,
    textAlign: 'center',
    marginTop: 10,
  },
});
