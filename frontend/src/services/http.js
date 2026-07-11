import axios from 'axios'
import { getIsReady, waitForBackendReady, isColdStartError, markBackendSleeping, isIdempotent } from './backendAvailability'

const http = axios.create({
  baseURL: import.meta.env.VITE_API_URL ? `${import.meta.env.VITE_API_URL}/api/v1` : '/api/v1',
  withCredentials: true,
  headers: {
    'Content-Type': 'application/json',
    Accept: 'application/json'
  }
})

http.interceptors.request.use(async (config) => {
  // If the backend is not ready, we queue the request by waiting for it to become ready.
  // This is safe for ALL requests because the request has not been sent to the network yet.
  if (!getIsReady() && !config.bypassAvailabilityCheck) {
    try {
      await waitForBackendReady()
    } catch (e) {
      throw e
    }
  }

  const token = localStorage.getItem('auth_token')
  if (token) {
    config.headers.Authorization = `Bearer ${token}`
  }

  // Attach a unique request ID (idempotency key) to all mutating requests (POST, PUT, PATCH, DELETE)
  const method = config.method ? config.method.toLowerCase() : 'get'
  if (method !== 'get' && method !== 'head' && method !== 'options') {
    if (!config.headers['X-Idempotency-Key']) {
      config.headers['X-Idempotency-Key'] = `req_${Date.now()}_${Math.random().toString(36).substring(2, 11)}`
    }
  }

  return config
})

http.interceptors.response.use(
  (response) => response,
  async (error) => {
    const config = error.config
    
    if (error.isSafetyCancellation || error.config?.isSafetyCancellation) {
      return Promise.reject(error)
    }

    if (config && !config.bypassAvailabilityCheck && isColdStartError(error)) {
      // If the request was already sent to the network and failed:
      // - If it is idempotent (GET, Login), we can safely auto-retry it.
      // - If it is non-idempotent (like payments or resume saves), we do not retry it automatically
      //   to avoid duplicate operations on the server side.
      if (!isIdempotent(config)) {
        const safetyError = new Error('Connection lost. Please verify if your request completed successfully before retrying.')
        safetyError.isSafetyCancellation = true
        return Promise.reject(safetyError)
      }

      markBackendSleeping()
      await waitForBackendReady()

      const token = localStorage.getItem('auth_token')
      if (token) {
        config.headers.Authorization = `Bearer ${token}`
      }
      return http(config)
    }
    return Promise.reject(error)
  }
)

export default http