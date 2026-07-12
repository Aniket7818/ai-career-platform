import Notification from './notification'

/**
 * Reusable Clipboard Service to copy text content.
 * Dispatches global notifications and manages success/error states.
 */
export const ClipboardService = {
  /**
   * Copies the provided text to the clipboard and shows a toast.
   * @param {string} text - The text to copy
   * @param {Object} [options] - Custom notification options
   * @returns {Promise<boolean>} Resolves to true if copy succeeded, false otherwise
   */
  async copy(text, options = {}) {
    if (!text) {
      Notification.error({
        title: options.errorTitle || 'Copy Failed',
        message: 'No content available to copy.'
      })
      return false
    }

    try {
      if (navigator.clipboard && navigator.clipboard.writeText) {
        await navigator.clipboard.writeText(text)
      } else {
        // Fallback for older browsers or non-secure contexts
        const textarea = document.createElement('textarea')
        textarea.value = text
        textarea.style.position = 'fixed'
        textarea.style.opacity = '0'
        document.body.appendChild(textarea)
        textarea.select()
        const success = document.execCommand('copy')
        document.body.removeChild(textarea)
        if (!success) throw new Error('execCommand copy failed')
      }

      Notification.success({
        title: options.successTitle || 'Copied to Clipboard',
        message: options.successMessage || 'AI-generated content copied successfully.',
        duration: options.duration || 2500
      })
      return true
    } catch (err) {
      console.error('Clipboard copy failed:', err)
      Notification.error({
        title: options.errorTitle || 'Copy Failed',
        message: options.errorMessage || 'Unable to copy the content. Please try again.'
      })
      return false
    }
  }
}

export default ClipboardService
