import http from './http'

const baseUrl = import.meta.env.VITE_API_URL ? `${import.meta.env.VITE_API_URL}/api/v1` : '/api/v1'

export const adminService = {
 show: (params = {}) => http.get('/admin', { params }),
 updateUser: (id, user) => http.patch(`/admin/users/${id}`, { user }),
 suspendUser: (id) => http.patch(`/admin/users/${id}/suspend`),
 activateUser: (id) => http.patch(`/admin/users/${id}/activate`),
 promoteUser: (id) => http.patch(`/admin/users/${id}/promote`),
 deleteUser: (id) => http.delete(`/admin/users/${id}`),
 updateSettings: (key, value) => http.patch('/admin/settings', { key, value }),
 getSettings: () => http.get('/admin/settings'),
 exportUrl: (kind) => `${baseUrl}/admin/export/${kind}`
}
