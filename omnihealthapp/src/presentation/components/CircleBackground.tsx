import React, { useEffect } from 'react';
import { View, StyleSheet, Animated } from 'react-native';

export const CircleBackground = () => {
  const animation1 = new Animated.Value(0);
  const animation2 = new Animated.Value(0);

  useEffect(() => {
    Animated.stagger(200, [
      Animated.spring(animation1, {
        toValue: 1,
        useNativeDriver: true,
        tension: 50,
        friction: 7,
      }),
      Animated.spring(animation2, {
        toValue: 1,
        useNativeDriver: true,
        tension: 50,
        friction: 7,
      }),
    ]).start();
  }, []);

  const translateY1 = animation1.interpolate({
    inputRange: [0, 1],
    outputRange: [-300, 0],
  });

  const translateY2 = animation2.interpolate({
    inputRange: [0, 1],
    outputRange: [-300, 0],
  });

  return (
    <View style={styles.container}>
      <Animated.View
        style={[
          styles.circle,
          styles.circle1,
          {
            transform: [{ translateY: translateY1 }],
          },
        ]}
      />
      <Animated.View
        style={[
          styles.circle,
          styles.circle2,
          {
            transform: [{ translateY: translateY2 }],
          },
        ]}
      />
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    ...StyleSheet.absoluteFillObject,
    overflow: 'hidden',
  },
  circle: {
    position: 'absolute',
    backgroundColor: '#FFFFFF',
    opacity: 0.1,
  },
  circle1: {
    width: 600,
    height: 600,
    borderRadius: 300,
    top: -250,
    left: -150,
  },
  circle2: {
    width: 500,
    height: 500,
    borderRadius: 250,
    top: -200,
    right: -100,
  },
});
