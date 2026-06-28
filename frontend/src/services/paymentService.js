import http from './http'

export const paymentService = {
  create: (plan, billingCycle) => http.post('/payments', { plan, billing_cycle: billingCycle }),
  verify: (payload) => http.post('/payments/verify', payload),
  cancel: () => http.delete('/payments'),
  getHistory: () => http.get('/billing/history'),
  downloadInvoice: (id) => { window.location.href = `/api/v1/billing/invoice/${id}` },
  downloadReceipt: (id) => { window.location.href = `/api/v1/billing/receipt/${id}` },
  getCreditHistory: (page = 1) => http.get(`/credits/history?page=${page}`),
  getPricing: () => http.get('/pricing')
}
