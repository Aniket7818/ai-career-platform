import http from './http'

export const authService = {
 login: (payload) => http.post('/auth/login', { user: payload }),
 signup: (payload, turnstileToken) =>
 http.post('/auth/signup', { user: payload, turnstile_token: turnstileToken }),
 logout: () => http.delete('/auth/logout'),
 me: () => http.get('/auth/me'),
 forgotPassword: (email, turnstileToken) =>
 http.post('/auth/forgot_password', { email, turnstile_token: turnstileToken }),
 resetPassword: (payload) => http.post('/auth/reset_password', payload),
 validateResetToken: (token) => http.get(`/auth/validate_reset_token?reset_password_token=${token}`)
}
