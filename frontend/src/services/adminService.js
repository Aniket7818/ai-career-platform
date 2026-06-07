import http from './http'

export const adminService = {
  show: (params = {}) => http.get('/admin', { params }),
  updateUser: (id, user) => http.patch(`/admin/users/${id}`, { user }),
  suspendUser: (id) => http.patch(`/admin/users/${id}/suspend`),
  activateUser: (id) => http.patch(`/admin/users/${id}/activate`),
  promoteUser: (id) => http.patch(`/admin/users/${id}/promote`),
  deleteUser: (id) => http.delete(`/admin/users/${id}`),
  updateSettings: (key, value) => http.patch('/admin/settings', { key, value }),
  exportUrl: (kind) => `/api/v1/admin/export/${kind}`
}
