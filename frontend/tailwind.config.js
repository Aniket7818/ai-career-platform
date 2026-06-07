export default {
  content: ['./index.html', './src/**/*.{vue,js}'],
  theme: {
    extend: {
      colors: {
        ink: '#0f172a',
        brand: '#6d4aff',
        mint: '#35d6b4',
        skyglass: '#eef7ff',
        surface: '#111827',
        'surface-light': '#1e293b',
        'surface-card': '#0b1220'
      },
      boxShadow: {
        panel: '0 18px 60px rgba(15, 23, 42, 0.08)',
        glow: '0 0 40px rgba(109, 74, 255, 0.15)',
        'glow-mint': '0 0 30px rgba(53, 214, 180, 0.12)'
      },
      animation: {
        'pulse-slow': 'pulse 3s cubic-bezier(0.4, 0, 0.6, 1) infinite',
        'fade-up': 'fadeUp 0.6s ease-out forwards'
      },
      keyframes: {
        fadeUp: {
          '0%': { opacity: '0', transform: 'translateY(12px)' },
          '100%': { opacity: '1', transform: 'translateY(0)' }
        }
      }
    }
  },
  plugins: []
}
