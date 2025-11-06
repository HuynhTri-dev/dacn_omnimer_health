import React, { useState } from 'react';
import {
  View,
  Text,
  TouchableOpacity,
  TouchableWithoutFeedback,
  StyleSheet,
  Modal,
  Animated,
} from 'react-native';
import { COLORS } from '@/presentation/theme/colors';

interface GenderSelectorProps {
  value: string;
  onSelect: (value: string) => void;
  error?: string;
}

export const GenderSelector: React.FC<GenderSelectorProps> = ({
  value,
  onSelect,
  error,
}) => {
  const [modalVisible, setModalVisible] = useState(false);
  const [animation] = useState(new Animated.Value(0));

  const genderOptions = [
    { label: 'Nam', value: 'male' },
    { label: 'Nữ', value: 'female' },
    { label: 'Khác', value: 'other' },
  ];

  const selectedLabel =
    genderOptions.find(option => option.value === value)?.label ||
    'Chọn giới tính';

  const handleSelect = (genderValue: string) => {
    onSelect(genderValue);
    setModalVisible(false);
  };

  const showModal = () => {
    setModalVisible(true);
    Animated.spring(animation, {
      toValue: 1,
      useNativeDriver: true,
      tension: 50,
      friction: 7,
    }).start();
  };

  const hideModal = () => {
    Animated.timing(animation, {
      toValue: 0,
      duration: 200,
      useNativeDriver: true,
    }).start(() => setModalVisible(false));
  };

  const translateY = animation.interpolate({
    inputRange: [0, 1],
    outputRange: [300, 0],
  });

  return (
    <View>
      <TouchableOpacity
        style={[styles.selector, error && styles.selectorError]}
        onPress={showModal}
        activeOpacity={0.7}
      >
        <Text
          style={[
            styles.selectorText,
            value ? styles.selectedText : styles.placeholderText,
          ]}
        >
          {selectedLabel}
        </Text>
      </TouchableOpacity>
      {error && <Text style={styles.errorText}>{error}</Text>}

      <Modal
        visible={modalVisible}
        transparent
        animationType="fade"
        onRequestClose={hideModal}
      >
        <View style={styles.modalOverlay}>
          {/* capture background taps only */}
          <TouchableWithoutFeedback onPress={hideModal}>
            <View style={styles.modalBackground} />
          </TouchableWithoutFeedback>

          <Animated.View
            style={[
              styles.modalContent,
              {
                transform: [{ translateY }],
              },
            ]}
          >
            <View style={styles.header}>
              <Text style={styles.headerText}>Chọn giới tính</Text>
            </View>
            {genderOptions.map(option => (
              <TouchableOpacity
                key={option.value}
                style={[
                  styles.option,
                  value === option.value && styles.selectedOption,
                ]}
                onPress={() => handleSelect(option.value)}
              >
                <Text
                  style={[
                    styles.optionText,
                    value === option.value && styles.selectedOptionText,
                  ]}
                >
                  {option.label}
                </Text>
              </TouchableOpacity>
            ))}
          </Animated.View>
        </View>
      </Modal>
    </View>
  );
};

const styles = StyleSheet.create({
  selector: {
    backgroundColor: COLORS.WHITE,
    borderRadius: 8,
    paddingVertical: 14,
    paddingHorizontal: 16,
    marginBottom: 5,
    borderWidth: 1,
    borderColor: '#E5E5E5',
  },
  selectorError: {
    borderWidth: 1,
    borderColor: '#FF3B30',
  },
  selectorText: {
    fontSize: 16,
  },
  selectedText: {
    color: '#000000',
  },
  placeholderText: {
    color: '#A0A0A0',
  },
  errorText: {
    color: '#FF3B30',
    fontSize: 12,
    marginBottom: 10,
    marginLeft: 4,
  },
  modalOverlay: {
    flex: 1,
    backgroundColor: 'rgba(0, 0, 0, 0.5)',
    justifyContent: 'flex-end',
  },
  modalBackground: {
    flex: 1,
    width: '100%',
  },
  modalContent: {
    backgroundColor: COLORS.WHITE,
    borderTopLeftRadius: 16,
    borderTopRightRadius: 16,
    paddingBottom: 20,
    width: '100%',
    elevation: 5,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: -2 },
    shadowOpacity: 0.1,
    shadowRadius: 5,
  },
  header: {
    padding: 16,
    borderBottomWidth: 1,
    borderBottomColor: '#E5E5E5',
    alignItems: 'center',
  },
  headerText: {
    fontSize: 17,
    fontWeight: '600',
    color: '#000000',
  },
  option: {
    paddingVertical: 16,
    paddingHorizontal: 20,
    borderBottomWidth: 1,
    borderBottomColor: '#F0F0F0',
  },
  selectedOption: {
    backgroundColor: '#F8F8F8',
  },
  optionText: {
    fontSize: 17,
    color: '#000000',
  },
  selectedOptionText: {
    color: COLORS.PRIMARY,
    fontWeight: '500',
  },
});
