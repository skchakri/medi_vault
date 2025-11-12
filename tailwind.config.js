/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    './public/*.html',
    './app/helpers/**/*.rb',
    './app/views/**/*.{erb,html}',
    './app/components/**/*.{erb,html}',
  ],
  theme: {
    extend: {
      colors: {
        cyan: {
          50: '#ecf7ff',
          100: '#d4edff',
          200: '#b1e1ff',
          300: '#7eceff',
          400: '#45bbff',
          500: '#0ea5e9',
          600: '#0284c7',
          700: '#0369a1',
          800: '#075985',
          900: '#0c3d66',
        }
      },
      fontFamily: {
        sans: ['Inter', '-apple-system', 'BlinkMacSystemFont', 'Segoe UI', 'sans-serif'],
      },
      spacing: {
        '4.5': '1.125rem',
      },
      borderRadius: {
        lg: '0.5rem',
        xl: '0.75rem',
      },
    },
  },
  plugins: [],
}
