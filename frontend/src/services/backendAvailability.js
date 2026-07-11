import { ref } from 'vue'
import axios from 'axios'

// Reactive states for the UI
export const isWaking = ref(false)
export const isOffline = ref(false)
export const hasFailedToStart = ref(false)

// Internal state
let isReady = false
let initialCheckStarted = false
let initialCheckPromise = null
let pollingTimeoutId = null
let maxTimeoutId = null
let wakingStartedAt = null
const readyCallbacks = []

// Dedicated Axios instance for health checks
const availabilityClient = axios.create({
  baseURL: import.meta.env.VITE_API_URL ? `${import.meta.env.VITE_API_URL}/api/v1` : '/api/v1',
  withCredentials: true,
  timeout: 5000,
  headers: {
    'Accept': 'application/json',
    'Content-Type': 'application/json'
  }
})

// Telemetry Logger for production monitoring
function logTelemetry(event, data = {}) {
  console.info(`[CareerAI Telemetry] Event: ${event}`, {
    timestamp: new Date().toISOString(),
    ...data
  })
}

// Listen to browser network changes
if (typeof window !== 'undefined') {
  isOffline.value = !navigator.onLine
  
  window.addEventListener('online', () => {
    isOffline.value = false
    logTelemetry('Offline Status Changed', { isOffline: false })
    if (isWaking.value || hasFailedToStart.value) {
      retryWaking()
    }
  })
  window.addEventListener('offline', () => {
    isOffline.value = true
    logTelemetry('Offline Status Changed', { isOffline: true })
  })

  // Tab Visibility optimization: Pause polling when hidden, resume when visible
  document.addEventListener('visibilitychange', () => {
    if (document.hidden) {
      logTelemetry('Tab Hidden - Pausing Polling')
      clearPollTimer()
    } else {
      if (isWaking.value || hasFailedToStart.value) {
        logTelemetry('Tab Visible - Resuming Polling')
        startPolling()
      }
    }
  })
}

export function getIsReady() {
  return isReady
}

export function isIdempotent(config) {
  if (!config) return false
  const method = config.method ? config.method.toLowerCase() : 'get'
  if (method === 'get' || method === 'head' || method === 'options') {
    return true
  }
  
  // For safety, only login is allowed to auto-retry when in-flight fails.
  // Other mutations (sign up, payments, resume updates) must NOT auto-retry if they touched the network.
  const safePaths = [
    '/auth/login'
  ]
  return safePaths.some(path => config.url && config.url.includes(path))
}

export function waitForBackendReady() {
  if (isReady) return Promise.resolve()
  if (hasFailedToStart.value) {
    return Promise.reject(new Error('Backend failed to start. Please try again.'))
  }
  
  return new Promise((resolve, reject) => {
    readyCallbacks.push({ resolve, reject })
  })
}

export function initiateWakeUp() {
  if (initialCheckStarted) {
    return initialCheckPromise
  }
  initialCheckStarted = true
  logTelemetry('Initial Background Wake-up Initiated')

  initialCheckPromise = new Promise(async (resolve) => {
    if (typeof navigator !== 'undefined' && !navigator.onLine) {
      isOffline.value = true
      isReady = false
      resolve(false)
      return
    }

    let checkTimeoutFired = false

    const checkTimeout = setTimeout(() => {
      checkTimeoutFired = true
      if (!isReady) {
        logTelemetry('Cold Start Detected via Initial Check Timeout')
        isWaking.value = true
        startPolling()
      }
    }, 4000)

    try {
      await availabilityClient.get('/health')
      clearTimeout(checkTimeout)
      isReady = true
      isWaking.value = false
      hasFailedToStart.value = false
      logTelemetry('Initial Check Succeeded - Backend Awake')
      resolve(true)
      resolveReadyCallbacks()
    } catch (err) {
      clearTimeout(checkTimeout)
      isReady = false
      
      if (isColdStartError(err)) {
        logTelemetry('Cold Start Detected via Initial Check Error')
        isWaking.value = true
        startPolling()
      } else {
        logTelemetry('Backend Boot Failure', { error: err.message })
        hasFailedToStart.value = true
      }
      resolve(false)
    }
  })

  return initialCheckPromise
}

export function markBackendSleeping() {
  if (isOffline.value) return 
  if (!isReady && isWaking.value) return 
  
  isReady = false
  isWaking.value = true
  logTelemetry('Backend Marked Waking / Outage Detected')
  startPolling()
}

function startPolling() {
  if (pollingTimeoutId) return

  if (!wakingStartedAt) {
    wakingStartedAt = Date.now()
  }

  // Start 90 seconds maximum wait timer
  if (!maxTimeoutId) {
    maxTimeoutId = setTimeout(() => {
      handleWakingTimeout()
    }, 90000)
  }

  let delay = 2000
  let attempt = 0

  const poll = async () => {
    if (typeof document !== 'undefined' && document.hidden) {
      // Keep waiting but do not send request while hidden
      pollingTimeoutId = setTimeout(poll, 3000)
      return
    }

    if (typeof navigator !== 'undefined' && !navigator.onLine) {
      isOffline.value = true
      pollingTimeoutId = setTimeout(poll, 3000)
      return
    }

    try {
      await availabilityClient.get('/health', { timeout: 4000 })
      const durationMs = Date.now() - (wakingStartedAt || Date.now())
      
      isReady = true
      isWaking.value = false
      hasFailedToStart.value = false
      
      logTelemetry('Wake-up Succeeded', { 
        durationMs, 
        queuedCount: readyCallbacks.length 
      })
      
      clearTimers()
      resolveReadyCallbacks()
    } catch (err) {
      attempt++
      let baseDelay = attempt === 1 ? 3000 : 5000
      // Add random jitter (-500ms to +500ms) to prevent synchronized burst polling
      const jitter = Math.random() * 1000 - 500
      const actualDelay = Math.max(1500, baseDelay + jitter)
      
      pollingTimeoutId = setTimeout(poll, actualDelay)
    }
  }

  pollingTimeoutId = setTimeout(poll, delay)
}

function handleWakingTimeout() {
  logTelemetry('Waking Timeout Occurred (90s limit reached)')
  clearTimers()
  isWaking.value = false
  hasFailedToStart.value = true
  
  const error = new Error('CareerAI failed to start. Please check your connection or try again in a moment.')
  error.isStartupFailure = true
  rejectReadyCallbacks(error)
}

function clearPollTimer() {
  if (pollingTimeoutId) {
    clearTimeout(pollingTimeoutId)
    pollingTimeoutId = null
  }
}

function clearTimers() {
  clearPollTimer()
  if (maxTimeoutId) {
    clearTimeout(maxTimeoutId)
    maxTimeoutId = null
  }
  wakingStartedAt = null
}

function resolveReadyCallbacks() {
  const callbacks = [...readyCallbacks]
  readyCallbacks.length = 0
  callbacks.forEach(({ resolve }) => resolve())
}

function rejectReadyCallbacks(error) {
  const callbacks = [...readyCallbacks]
  readyCallbacks.length = 0
  callbacks.forEach(({ reject }) => reject(error))
}

export function cancelPolling() {
  clearTimers()
}

export function retryWaking() {
  logTelemetry('Manual Retry Requested')
  isOffline.value = false
  hasFailedToStart.value = false
  isWaking.value = true
  startPolling()
}

export function isColdStartError(error) {
  if (typeof navigator !== 'undefined' && !navigator.onLine) {
    return false
  }

  // AI generation requests can take a long time, so we must never treat them as cold starts
  if (error.config && error.config.url && error.config.url.includes('/ai/generate')) {
    return false
  }

  if (!error.response) {
    return true
  }
  
  const status = error.response.status
  return status === 502 || status === 503 || status === 504
}
