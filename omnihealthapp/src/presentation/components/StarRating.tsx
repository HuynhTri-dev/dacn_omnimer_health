import React from 'react';
import { View, TouchableOpacity, StyleSheet } from 'react-native';
import Icon from 'react-native-vector-icons/FontAwesome';
import { COLORS } from '@/presentation/theme/colors';

interface StarRatingProps {
  rating: number;
  maxRating?: number;
  size?: number;
  onRatingChange?: (rating: number) => void;
  disabled?: boolean;
}

export const StarRating: React.FC<StarRatingProps> = ({
  rating,
  maxRating = 5,
  size = 24,
  onRatingChange,
  disabled = false,
}) => {
  const handlePress = (selectedRating: number) => {
    if (!disabled && onRatingChange) {
      onRatingChange(selectedRating);
    }
  };

  return (
    <View style={styles.container}>
      {Array.from({ length: maxRating }, (_, index) => {
        const starFilled = index < rating;
        return (
          <TouchableOpacity
            key={index}
            onPress={() => handlePress(index + 1)}
            disabled={disabled}
            style={styles.starContainer}
          >
            <Icon
              name={starFilled ? 'star' : 'star-o'}
              size={size}
              color={starFilled ? '#FFD700' : '#D1D1D1'}
            />
          </TouchableOpacity>
        );
      })}
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  starContainer: {
    padding: 4,
  },
});
