import store from '../store'

export const Notification = {
  success({ title, message, duration = 3500 }) {
    return store.dispatch('toast/show', {
      type: 'success',
      title,
      message,
      duration
    })
  },
  error({ title, message, duration = 5000, onRetry = null }) {
    return store.dispatch('toast/show', {
      type: 'error',
      title,
      message,
      duration,
      onRetry
    })
  },
  warning({ title, message, duration = 3500 }) {
    return store.dispatch('toast/show', {
      type: 'warning',
      title,
      message,
      duration
    })
  },
  info({ title, message, duration = 3500 }) {
    return store.dispatch('toast/show', {
      type: 'info',
      title,
      message,
      duration
    })
  }
}

export default Notification
