import http from './http'

export const comingSoonService = {
 show: () => http.get('/coming_soon'),
 notify: (payload) => http.post('/feature_interests', { feature_interest: payload }),
 unregister: (payload) => http.delete('/feature_interests', { data: { feature_interest: payload } })
}
