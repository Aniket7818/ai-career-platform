import http from './http'

export const resumeService = {
  list: () => http.get('/resumes'),
  show: (id) => http.get(`/resumes/${id}`),
  create: (resume) => http.post('/resumes', { resume }),
  update: (id, resume) => http.put(`/resumes/${id}`, { resume }),
  download: (id) => http.post(`/resumes/${id}/download`),
  destroy: (id) => http.delete(`/resumes/${id}`)
}
