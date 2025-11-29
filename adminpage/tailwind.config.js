/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {
      colors: {
        // Use CSS variables from Flutter app colors
        primary: 'var(--primary)',
        secondary: 'var(--secondary)',
        white: 'var(--white)',
        black: 'var(--black)',

        // UI Colors
        background: 'var(--background)',
        surface: 'var(--surface)',
        error: 'var(--error)',
        success: 'var(--success)',
        warning: 'var(--warning)',
        info: 'var(--info)',
        danger: 'var(--danger)',
        'danger-hover': 'var(--danger-hover)',

        // Gray Scale
        gray: {
          100: 'var(--gray-100)',
          200: 'var(--gray-200)',
          300: 'var(--gray-300)',
          400: 'var(--gray-400)',
          500: 'var(--gray-500)',
          600: 'var(--gray-600)',
          700: 'var(--gray-700)',
          800: 'var(--gray-800)',
          900: 'var(--gray-900)',
        },

        // Text Colors
        'text-primary': 'var(--text-primary)',
        'text-secondary': 'var(--text-secondary)',
        'text-light': 'var(--text-light)',
        'text-muted': 'var(--text-muted)',

        // Difficulty Level Colors
        easy: 'var(--easy)',
        medium: 'var(--medium)',
        hard: 'var(--hard)',
        'very-hard': 'var(--very-hard)',

        // Additional UI
        border: 'var(--border)',
        divider: 'var(--divider)',
        overlay: 'var(--overlay)',
        shadow: 'var(--shadow)',
      },
    },
  },
  plugins: [],
}