import http from './http'

export const dashboardService = {
  show: () => http.get('/dashboard')
}
