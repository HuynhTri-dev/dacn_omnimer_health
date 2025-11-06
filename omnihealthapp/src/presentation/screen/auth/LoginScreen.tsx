import React, { useState } from 'react';
import {
  View,
  Text,
  TouchableOpacity,
  StyleSheet,
  SafeAreaView,
  KeyboardAvoidingView,
  Platform,
  Image,
} from 'react-native';
import { useDispatch } from 'react-redux';
import { loginUser } from '@/app/store/authSlice';
import { AppDispatch } from '@/app/store';
import { useNavigation } from '@react-navigation/native';
import { COLORS } from '@/presentation/theme/colors';
import { CircleBackground } from '@/presentation/components/CircleBackground';
import { Input } from '@/presentation/components/Input';
import { Button } from '@/presentation/components/Button';

export const LoginScreen = () => {
  const dispatch = useDispatch<AppDispatch>();
  const navigation = useNavigation();

  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');

  const handleLogin = () => {
    dispatch(loginUser({ email, password }));
  };

  const navigateToRegister = () => {
    navigation.navigate('Register' as never);
  };

  return (
    <SafeAreaView style={styles.container}>
      <CircleBackground />
      <KeyboardAvoidingView
        behavior={Platform.OS === 'ios' ? 'padding' : 'height'}
        style={styles.keyboardAvoidingView}
      >
        <View style={styles.content}>
          <View style={styles.logoContainer}>
            <View style={styles.logoWrapper}>
              <Image
                source={require('../../../assets/images/whiteH.jpg')}
                style={styles.logo}
                resizeMode="cover"
              />
            </View>
            <Text style={styles.appName}>OmniMer Health</Text>
            <Text style={styles.appSlogan}>
              Cảm hứng sống khỏe, mỗi ngày một tốt hơn.
            </Text>
          </View>

          <View style={styles.formContainer}>
            <Input
              placeholder="Tài khoản"
              placeholderTextColor="rgba(22, 20, 20, 0.232)"
              value={email}
              onChangeText={setEmail}
              keyboardType="email-address"
              autoCapitalize="none"
              containerStyle={styles.inputContainer}
            />

            <Input
              placeholder="Mật khẩu"
              placeholderTextColor="rgba(22, 20, 20, 0.232)"
              value={password}
              onChangeText={setPassword}
              secureTextEntry
              containerStyle={styles.inputContainer}
            />

            <TouchableOpacity onPress={() => {}}>
              <Text style={styles.forgotPassword}>Quên mật khẩu</Text>
            </TouchableOpacity>

            <Button
              title="Đăng nhập"
              onPress={handleLogin}
              style={styles.loginButton}
              textStyle={styles.loginButtonText}
            />

            <Button
              title="Google"
              variant="google"
              icon={
                <Image
                  source={require('../../../assets/images/google.png')}
                  style={styles.googleIcon}
                />
              }
              style={styles.googleButton}
              textStyle={styles.googleButtonText}
              onPress={() => {}}
            />
          </View>

          <View style={styles.footer}>
            <Text style={styles.footerText}>Chưa có tài khoản? </Text>
            <TouchableOpacity onPress={navigateToRegister}>
              <Text style={styles.registerLink}>Đăng ký ngay</Text>
            </TouchableOpacity>
          </View>
        </View>
      </KeyboardAvoidingView>
    </SafeAreaView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: COLORS.PRIMARY,
  },
  keyboardAvoidingView: {
    flex: 1,
  },
  content: {
    flex: 1,
    paddingHorizontal: 24,
    justifyContent: 'space-between',
  },
  logoContainer: {
    alignItems: 'center',
    marginTop: 60,
  },
  logoWrapper: {
    width: 120,
    height: 120,
    backgroundColor: 'rgba(255, 255, 255, 0.2)',
    borderRadius: 60,
    justifyContent: 'center',
    alignItems: 'center',
    marginBottom: 16,
    overflow: 'hidden',
  },
  logo: {
    width: 100,
    height: 100,
    borderRadius: 100,
    alignSelf: 'center',
  },
  appName: {
    fontSize: 28,
    fontWeight: 'bold',
    color: COLORS.WHITE,
    marginBottom: 8,
  },
  appSlogan: {
    fontSize: 16,
    color: COLORS.WHITE,
    opacity: 0.8,
    textAlign: 'center',
  },
  formContainer: {
    width: '100%',
    marginVertical: 30,
  },
  inputContainer: {
    marginBottom: 16,
  },
  input: {
    backgroundColor: 'rgba(255, 255, 255, 0.1)',
    borderRadius: 12,
    paddingHorizontal: 16,
    paddingVertical: 12,
    color: COLORS.WHITE,
    fontSize: 16,
  },
  forgotPassword: {
    color: COLORS.WHITE,
    textDecorationLine: 'underline',
    textAlign: 'right',
    marginTop: 8,
    marginBottom: 24,
    fontSize: 14,
  },
  loginButton: {
    backgroundColor: COLORS.WHITE,
    borderRadius: 15,
    paddingVertical: 10,
    alignItems: 'center',
    marginBottom: 16,
  },
  loginButtonText: {
    color: COLORS.PRIMARY,
    fontSize: 16,
    fontWeight: 'bold',
  },
  googleButton: {
    backgroundColor: 'rgba(255, 255, 255, 0.1)',
    borderRadius: 15,
    paddingVertical: 10,

    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
  },
  googleIcon: {
    width: 24,
    height: 24,
    marginRight: 8,
  },
  googleButtonText: {
    color: COLORS.WHITE,
    fontSize: 16,
    fontWeight: '500',
  },
  footer: {
    flexDirection: 'row',
    justifyContent: 'center',
    alignItems: 'center',
    marginBottom: 32,
  },
  footerText: {
    color: COLORS.WHITE,
    opacity: 0.9,
    fontSize: 14,
  },
  registerLink: {
    color: COLORS.WHITE,
    fontSize: 14,
    fontWeight: 'bold',
  },
});
