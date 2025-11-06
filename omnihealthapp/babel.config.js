module.exports = {
  presets: ['module:@react-native/babel-preset'],
  plugins: [
    [
      'module-resolver',
      {
        root: ['./'],
        extensions: ['.ts', '.tsx', '.js', '.jsx', '.json'],
        alias: {
          '@': './src',
          '@app': './src/app',
          '@data': './src/data',
          '@domain': './src/domain',
          '@presentation': './src/presentation',
          '@services': './src/services',
          '@utils': './src/utils',
          '@types': './src/app/types',
        },
      },
    ],
  ],
};
