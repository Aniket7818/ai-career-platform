import store from '../store'

export const toast = {
 success: (title, message = '') => store.dispatch('toast/show', { type: 'success', title, message }),
 error: (title, message = '') => store.dispatch('toast/show', { type: 'error', title, message }),
 info: (title, message = '') => store.dispatch('toast/show', { type: 'info', title, message })
}
