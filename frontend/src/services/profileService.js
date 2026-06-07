import http from './http'

export const profileService = {
  show: () => http.get('/profile'),
  update: (user) => http.patch('/profile', { user })
}
