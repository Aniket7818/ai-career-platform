import { createStore } from 'vuex'
import { authService } from '../services/authService'
import { profileService } from '../services/profileService'
import { resumeService } from '../services/resumeService'
import { dashboardService } from '../services/dashboardService'
import { comingSoonService } from '../services/comingSoonService'

const errorText = (error) => {
 const data = error.response?.data
 if (data?.errors?.length) return data.errors.join(', ')
 if (data?.error) return data.error
 if (data?.message) return data.message
 if (error.response?.status === 500) return 'Something went wrong on our end. Please try again.'
 return error.message || 'Request failed.'
}

export default createStore({
 modules: {
 toast: {
 namespaced: true,
 state: () => ({ items: [], nextId: 1 }),
 mutations: {
 push(state, toast) { state.items.push(toast) },
 remove(state, id) { state.items = state.items.filter((item) => item.id !== id) }
 },
 actions: {
 show({ commit, state }, { type = 'success', title, message = '', duration = 4500 }) {
 const id = state.nextId++
 commit('push', { id, type, title, message, duration, startedAt: Date.now() })
 return id
 }
 }
 },
 auth: {
 namespaced: true,
 state: () => ({ user: null, loading: false, error: null, errorTimeout: null }),
 mutations: {
 setLoading: (s, v) => (s.loading = v),
 setError: (s, v) => {
 s.error = v
 if (s.errorTimeout) clearTimeout(s.errorTimeout)
 if (v) {
 s.errorTimeout = setTimeout(() => { s.error = null }, 5000)
 }
 },
 setUser: (s, v) => (s.user = v),
 // Lightweight credit patch — avoids a full fetchMe round-trip after every AI call
 SET_USER_CREDITS: (s, remaining) => {
 if (s.user) {
 s.user = {
 ...s.user,
 ai_credits_remaining: remaining,
 ai_credits_total: s.user.ai_credits_total
 }
 }
 }
 },
  actions: {
    async login({ commit }, payload) {
      commit('setLoading', true)
      commit('setError', null)
      commit('setUser', null)
      try {
        const { data } = await authService.login(payload)
        if (data.token) {
          localStorage.setItem('auth_token', data.token)
        }
        commit('setUser', data.user)
        return data.user
      } catch (e) {
        commit('setError', errorText(e))
        return null
      } finally {
        commit('setLoading', false)
      }
    },
    async signup({ commit }, { turnstileToken, ...formData }) {
      commit('setLoading', true)
      commit('setError', null)
      commit('setUser', null)
      try {
        const { data } = await authService.signup(formData, turnstileToken)
        if (data.token) {
          localStorage.setItem('auth_token', data.token)
        }
        commit('setUser', data.user)
        return data.user
      } catch (e) {
        commit('setError', errorText(e))
        return null
      } finally {
        commit('setLoading', false)
      }
    },
    async forgotPassword({ commit }, { email, turnstileToken }) {
      commit('setLoading', true)
      commit('setError', null)
      try {
        await authService.forgotPassword(email, turnstileToken)
        return true
      } catch (e) {
        commit('setError', errorText(e))
        return false
      } finally {
        commit('setLoading', false)
      }
    },
    async resetPassword({ commit }, payload) {
      commit('setLoading', true)
      commit('setError', null)
      try {
        await authService.resetPassword(payload)
        return true
      } catch (e) {
        commit('setError', errorText(e))
        return false
      } finally {
        commit('setLoading', false)
      }
    },
    async validateResetToken({ commit }, token) {
      commit('setLoading', true)
      commit('setError', null)
      try {
        const { data } = await authService.validateResetToken(token)
        return data.valid
      } catch (e) {
        commit('setError', errorText(e))
        return false
      } finally {
        commit('setLoading', false)
      }
    },
    async fetchMe({ commit }) {
      try {
        const { data } = await authService.me()
        commit('setUser', data.user)
        return data.user
      } catch (e) {
        commit('setUser', null)
        if (e.response && e.response.status === 401) {
          localStorage.removeItem('auth_token')
        }
        return null
      }
    },
    async logout({ commit }) {
      commit('setLoading', true)
      try {
        await authService.logout()
      } catch (e) {
        console.warn('Backend logout failed or was unauthorized:', e)
      } finally {
        localStorage.removeItem('auth_token')
        commit('setUser', null)
        commit('setLoading', false)
      }
    },
 async updateProfile({ commit }, payload) {
 commit('setLoading', true)
 commit('setError', null)
 try {
 const { data } = await profileService.update(payload)
 commit('setUser', data.user)
 return data.user
 } catch (e) {
 commit('setError', errorText(e))
 return null
 } finally {
 commit('setLoading', false)
 }
 }
 }
 },
 dashboard: {
 namespaced: true,
 state: () => ({ user: null, stats: {}, recent: [], loading: false, error: null }),
 mutations: {
 setLoading: (s, v) => (s.loading = v),
 setData: (s, v) => { s.user = v.user; s.stats = v.stats; s.recent = v.recent_resumes },
 setError: (s, v) => (s.error = v)
 },
 actions: { async load({ commit }) { commit('setLoading', true); try { const { data } = await dashboardService.show(); commit('setData', data) } catch (e) { commit('setError', errorText(e)) } finally { commit('setLoading', false) } } }
 },
 comingSoon: {
 namespaced: true,
 state: () => ({ stats: {}, features: [], trend: { labels: [], values: [] }, loading: false, error: null }),
 mutations: {
 setLoading: (s, v) => (s.loading = v),
 setError: (s, v) => (s.error = v),
 setData: (s, data) => {
 s.stats = data.stats
 s.features = data.features
 s.trend = data.trend
 },
 updateFeature: (s, { key, interest_count, notified }) => {
 s.features = s.features.map((f) => (f.key === key ? { ...f, interest_count, notified } : f))
 s.stats = { ...s.stats, total_interests: s.features.reduce((sum, f) => sum + (f.interest_count || 0), 0) }
 }
 },
 actions: {
 async load({ commit }) {
 commit('setLoading', true)
 commit('setError', null)
 try {
 const { data } = await comingSoonService.show()
 commit('setData', data)
 } catch (e) {
 commit('setError', errorText(e))
 } finally {
 commit('setLoading', false)
 }
 },
 async notify({ commit }, payload) {
 commit('setError', null)
 try {
 const { data } = await comingSoonService.notify(payload)
 commit('updateFeature', { key: data.feature_interest.feature_key, interest_count: data.interest_count, notified: true })
 return data
 } catch (e) {
 commit('setError', errorText(e))
 return null
 }
 },
 async unregister({ commit }, payload) {
 commit('setError', null)
 try {
 const { data } = await comingSoonService.unregister(payload)
 commit('updateFeature', { key: data.feature_key, interest_count: data.interest_count, notified: false })
 return data
 } catch (e) {
 commit('setError', errorText(e))
 return null
 }
 }
 }
 },
 resumes: {
 namespaced: true,
 state: () => ({ items: [], loading: false, error: null }),
 mutations: { setLoading: (s, v) => (s.loading = v), setError: (s, v) => (s.error = v), setItems: (s, v) => (s.items = v), remove: (s, id) => (s.items = s.items.filter((item) => item.id !== id)) },
 actions: {
 async load({ commit }) { commit('setLoading', true); commit('setError', null); try { const { data } = await resumeService.list(); commit('setItems', data.resumes) } catch (e) { commit('setError', errorText(e)) } finally { commit('setLoading', false) } },
 async loadOne({ commit }, id) { commit('setLoading', true); commit('setError', null); try { const { data } = await resumeService.show(id); return data.resume } catch (e) { commit('setError', errorText(e)); return null } finally { commit('setLoading', false) } },
 async create({ commit }, resume) { commit('setLoading', true); commit('setError', null); try { const { data } = await resumeService.create(resume); return data.resume } catch (e) { commit('setError', errorText(e)); return null } finally { commit('setLoading', false) } },
 async update({ commit }, resume) { commit('setLoading', true); commit('setError', null); try { if (!resume.id) throw new Error('Missing resume id.'); const { data } = await resumeService.update(resume.id, resume); return data.resume } catch (e) { commit('setError', errorText(e)); return null } finally { commit('setLoading', false) } },
 async recordDownload({ commit }, id) { commit('setError', null); try { const { data } = await resumeService.download(id); commit('auth/setUser', data.user, { root: true }); return data } catch (e) { commit('setError', errorText(e)); return null } },
 async remove({ commit }, id) { try { await resumeService.destroy(id); commit('remove', id) } catch (e) { commit('setError', errorText(e)) } }
 }
 }
 }
})
