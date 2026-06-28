import http from './http'

export const paymentService = {
  create: (plan, billingCycle) => http.post('/payments', { plan, billing_cycle: billingCycle }),
  verify: (payload) => http.post('/payments/verify', payload),
  cancel: () => http.delete('/payments'),
  getHistory: () => http.get('/billing/history'),
  downloadInvoice: async (id) => {
    const response = await http.get(`/billing/invoice/${id}`, { responseType: 'blob' })
    const url = window.URL.createObjectURL(new Blob([response.data]))
    const link = document.createElement('a')
    link.href = url
    link.setAttribute('download', `invoice_${id}.pdf`)
    document.body.appendChild(link)
    link.click()
    link.remove()
    window.URL.revokeObjectURL(url)
  },
  downloadReceipt: async (id) => {
    const response = await http.get(`/billing/receipt/${id}`, { responseType: 'blob' })
    const url = window.URL.createObjectURL(new Blob([response.data]))
    const link = document.createElement('a')
    link.href = url
    link.setAttribute('download', `receipt_${id}.pdf`)
    document.body.appendChild(link)
    link.click()
    link.remove()
    window.URL.revokeObjectURL(url)
  },
  getCreditHistory: (page = 1) => http.get(`/credits/history?page=${page}`),
  getPricing: () => http.get('/pricing')
}
