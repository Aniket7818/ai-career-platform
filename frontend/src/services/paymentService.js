import http from './http'

export const paymentService = {
  create: (plan) => http.post('/payments', { plan }),
  verify: (payload) => http.post('/payments/verify', payload)
}
