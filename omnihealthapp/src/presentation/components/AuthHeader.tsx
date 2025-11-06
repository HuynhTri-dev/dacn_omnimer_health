import React from 'react';
import { View, Text, StyleSheet, Image } from 'react-native';
import { COLORS } from '@/presentation/theme/colors';

interface AuthHeaderProps {
  title: string;
  subtitle?: string;
}

export const AuthHeader: React.FC<AuthHeaderProps> = ({
  title,
  subtitle,
}) => {
  return (
    <View style={styles.headerContainer}>
      <View style={styles.logoWrapper}>
        <Image source={require('@/assets/images/whiteH.jpg')} style={styles.logo} />
      </View>
      <Text style={styles.headerTitle}>{title}</Text>
      {subtitle && <Text style={styles.headerSubtitle}>{subtitle}</Text>}
    </View>
  );
};

const styles = StyleSheet.create({
  headerContainer: {
    alignItems: 'center',
    marginVertical: 20,
  },
  logo: {
    width: 80,
    height: 80,
    marginBottom: 10,
    backgroundColor: COLORS.WHITE,
    borderRadius: 40,
  },
  logoWrapper: {
    width: 80,
    height: 80,
    marginBottom: 10,
    backgroundColor: COLORS.WHITE,
    borderRadius: 40,
    alignItems: 'center',
    justifyContent: 'center',
    overflow: 'hidden',
  },
  headerTitle: {
    fontSize: 24,
    fontWeight: 'bold',
    color: COLORS.WHITE,
    marginBottom: 5,
  },
  headerSubtitle: {
    fontSize: 14,
    color: COLORS.WHITE,
    textAlign: 'center',
  },
});