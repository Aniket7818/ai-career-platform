import http from './http'

export const paymentService = {
  create: (plan, billingCycle) => http.post('/payments', { plan, billing_cycle: billingCycle }),
  verify: (payload) => http.post('/payments/verify', payload),
  cancel: () => http.delete('/payments')
}
