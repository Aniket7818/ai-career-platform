import http from './http'

export const authService = {
  login: (payload) => http.post('/auth/login', { user: payload }),
  signup: (payload) => http.post('/auth/signup', { user: payload }),
  logout: () => http.delete('/auth/logout'),
  me: () => http.get('/auth/me'),
  forgotPassword: (email) => http.post('/auth/password', { user: { email } })
}
