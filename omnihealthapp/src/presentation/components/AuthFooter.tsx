import React from 'react';
import { View, Text, TouchableOpacity, StyleSheet } from 'react-native';
import { COLORS } from '@/presentation/theme/colors';

interface AuthFooterProps {
  questionText: string;
  actionText: string;
  onPress: () => void;
}

export const AuthFooter: React.FC<AuthFooterProps> = ({
  questionText,
  actionText,
  onPress,
}) => {
  return (
    <View style={styles.footer}>
      <Text style={styles.footerText}>{questionText} </Text>
      <TouchableOpacity onPress={onPress}>
        <Text style={styles.actionLink}>{actionText}</Text>
      </TouchableOpacity>
    </View>
  );
};

const styles = StyleSheet.create({
  footer: {
    flexDirection: 'row',
    justifyContent: 'center',
    alignItems: 'center',
    marginTop: 20,
  },
  footerText: {
    color: COLORS.TEXT_SECONDARY,
  },
  actionLink: {
    color: COLORS.SECONDARY,
    fontWeight: 'bold',
  },
});