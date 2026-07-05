import en from '../locales/en'

export const t = (path, vars = {}) => {
 const value = path.split('.').reduce((v, key) => v?.[key], en)
 if (value === undefined) return path
 if (typeof value === 'string' && Object.keys(vars).length) {
 return Object.entries(vars).reduce((result, [key, val]) => result.replaceAll(`{${key}}`, String(val)), value)
 }
 return value
}
