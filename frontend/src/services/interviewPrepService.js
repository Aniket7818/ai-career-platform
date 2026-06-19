import http from './http'

export default {
  getSubjects() {
    return http.get('/interview-prep')
  },
  getSubjectQuestions(subject) {
    return http.get(`/interview-prep/${subject}`)
  },
  getQuestion(subject, questionId) {
    return http.get(`/interview-prep/${subject}/${questionId}`)
  }
}
