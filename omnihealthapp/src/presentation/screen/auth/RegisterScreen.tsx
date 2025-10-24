import React, { useState } from 'react';
import { View, TextInput, Button, Image, Text } from 'react-native';
import { useDispatch, useSelector } from 'react-redux';
import { registerUser } from '@/app/store/authSlice';
import { RootState, AppDispatch } from '@/app/store';

export const RegisterScreen = () => {
  const dispatch = useDispatch<AppDispatch>();
  const auth = useSelector((state: RootState) => state.auth);

  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [fullname, setFullname] = useState('');
  const [avatar, setAvatar] = useState<any>(null);

  const handleRegister = () => {
    dispatch(registerUser({ email, password, fullname, avatar }));
  };

  return (
    <View>
      <TextInput
        placeholder="Fullname"
        value={fullname}
        onChangeText={setFullname}
      />
      <TextInput
        placeholder="Email"
        value={email}
        onChangeText={setEmail}
        keyboardType="email-address"
      />
      <TextInput
        placeholder="Password"
        value={password}
        onChangeText={setPassword}
        secureTextEntry
      />
      <Button
        title="Chọn ảnh"
        onPress={() => {
          /* ImagePicker */
        }}
      />
      {avatar && (
        <Image
          source={{ uri: avatar.uri }}
          style={{ width: 100, height: 100 }}
        />
      )}
      <Button title="Đăng ký" onPress={handleRegister} />
      {auth.loading && <Text>Loading...</Text>}
      {auth.error && <Text style={{ color: 'red' }}>{auth.error}</Text>}
    </View>
  );
};
