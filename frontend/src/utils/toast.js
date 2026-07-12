import store from '../store'
import Notification from '../services/notification'

export const toast = {
  success: (title, message = '') => {
    if (typeof title === 'object') {
      return Notification.success(title)
    }
    return Notification.success({ title, message })
  },
  error: (title, message = '', onRetry = null) => {
    if (typeof title === 'object') {
      return Notification.error(title)
    }
    return Notification.error({ title, message, onRetry })
  },
  warning: (title, message = '') => {
    if (typeof title === 'object') {
      return Notification.warning(title)
    }
    return Notification.warning({ title, message })
  },
  info: (title, message = '') => {
    if (typeof title === 'object') {
      return Notification.info(title)
    }
    return Notification.info({ title, message })
  }
}

export { Notification }
export default toast
