import http from './http'

export const profileService = {
 show: () => http.get('/profile'),
 update: (user) => http.patch('/profile', { user }),
 changePassword: (passwordData) => http.put('/profile/change_password', { user: passwordData }),
 deleteAccount: () => http.delete('/profile')
}
