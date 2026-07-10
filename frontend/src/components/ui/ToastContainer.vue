<template>
  <div class="toast-container" aria-live="assertive" aria-atomic="true">
    <TransitionGroup name="premium-toast">
      <div
        v-for="toast in toasts"
        :key="toast.id"
        class="toast-item"
        :class="['toast-' + toast.type]"
        role="alert"
      >
        <div class="toast-inner">
          <!-- Icon -->
          <div class="toast-icon-wrap">
            <!-- Success Icon -->
            <svg v-if="toast.type === 'success'" class="toast-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5">
              <path stroke-linecap="round" stroke-linejoin="round" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
            </svg>
            <!-- Error Icon -->
            <svg v-else-if="toast.type === 'error'" class="toast-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5">
              <path stroke-linecap="round" stroke-linejoin="round" d="M10 14l2-2m0 0l2-2m-2 2l-2-2m2 2l2 2m7-2a9 9 0 11-18 0 9 9 0 0118 0z" />
            </svg>
            <!-- Warning Icon -->
            <svg v-else-if="toast.type === 'warning'" class="toast-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5">
              <path stroke-linecap="round" stroke-linejoin="round" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z" />
            </svg>
            <!-- Info Icon -->
            <svg v-else class="toast-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5">
              <path stroke-linecap="round" stroke-linejoin="round" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
            </svg>
          </div>

          <!-- Content -->
          <div class="toast-content">
            <h4 class="toast-title">{{ toast.title }}</h4>
            <p v-if="toast.message" class="toast-message">{{ toast.message }}</p>
            
            <!-- Actions (e.g. Retry) -->
            <div v-if="toast.type === 'error' && toast.onRetry" class="toast-actions">
              <button class="btn-retry" @click="handleRetry(toast)">
                Retry
              </button>
              <button class="btn-cancel-toast" @click="remove(toast.id)">
                Cancel
              </button>
            </div>
          </div>

          <!-- Close Button -->
          <button class="toast-close-btn" @click="remove(toast.id)" aria-label="Close notification">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" class="size-4">
              <path stroke-linecap="round" stroke-linejoin="round" d="M6 18L18 6M6 6l12 12" />
            </svg>
          </button>
        </div>

        <!-- Progress bar -->
        <div class="toast-progress-bar">
          <div class="toast-progress-fill" :style="barStyle(toast)" />
        </div>
      </div>
    </TransitionGroup>
  </div>
</template>

<script setup>
import { computed, onMounted, onUnmounted, ref, watch } from 'vue'
import { useStore } from 'vuex'

const store = useStore()
const toasts = computed(() => store.state.toast.items)
const now = ref(Date.now())
let timer = null

onMounted(() => {
  timer = setInterval(() => {
    now.value = Date.now()
  }, 50)
})

onUnmounted(() => {
  if (timer) clearInterval(timer)
})

const remove = (id) => {
  store.commit('toast/remove', id)
}

const handleRetry = (toast) => {
  if (toast.onRetry) {
    try {
      toast.onRetry()
    } catch (e) {
      console.error('Error during toast retry:', e)
    }
  }
  remove(toast.id)
}

const barStyle = (toast) => {
  const elapsed = now.value - toast.startedAt
  const remaining = Math.max(0, 1 - elapsed / toast.duration)
  return {
    transform: `scaleX(${remaining})`
  }
}

const scheduledIds = new Set()

watch(toasts, (items) => {
  items.forEach((toast) => {
    if (!scheduledIds.has(toast.id)) {
      scheduledIds.add(toast.id)
      setTimeout(() => {
        remove(toast.id)
        scheduledIds.delete(toast.id)
      }, toast.duration)
    }
  })
}, { deep: true })
</script>

<style scoped>
.toast-container {
  position: fixed;
  top: 1.5rem;
  right: 1.5rem;
  z-index: 9999;
  display: flex;
  flex-direction: column;
  gap: 0.75rem;
  width: 100%;
  max-width: 420px;
  pointer-events: none;
}

@media (max-width: 640px) {
  .toast-container {
    top: 1rem;
    right: 1rem;
    left: 1rem;
    width: auto;
    max-width: none;
  }
  .toast-inner {
    padding: 0.5rem 0.75rem;
    gap: 0.5rem;
  }
  .toast-icon-wrap {
    width: 1.5rem;
    height: 1.5rem;
    flex-shrink: 0;
  }
  .toast-icon {
    width: 0.875rem;
    height: 0.875rem;
  }
  .toast-title {
    font-size: 0.8125rem;
  }
  .toast-message {
    font-size: 0.75rem;
    margin-top: 0.125rem;
  }
}

.toast-item {
  pointer-events: auto;
  position: relative;
  background: var(--toast-bg);
  border: 1px solid var(--toast-border-color);
  border-radius: 0.75rem;
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.08), 0 4px 12px rgba(0, 0, 0, 0.03);
  overflow: hidden;
  display: flex;
  flex-direction: column;
  transition: all 0.3s ease;
  width: 100%;
  backdrop-filter: blur(12px);
  -webkit-backdrop-filter: blur(12px);
}

.toast-inner {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  padding: 0.625rem 0.875rem;
}

.toast-icon-wrap {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 1.75rem;
  height: 1.75rem;
  border-radius: 50%;
  background: var(--toast-icon-bg);
  color: var(--toast-icon-color);
  flex-shrink: 0;
}

.toast-icon {
  width: 1rem;
  height: 1rem;
}

.toast-content {
  flex: 1;
  min-width: 0;
  display: flex;
  flex-direction: column;
  justify-content: center;
}

.toast-title {
  margin: 0;
  font-size: 0.875rem;
  font-weight: 600;
  color: var(--toast-title-color);
  line-height: 1.3;
}

.toast-message {
  margin: 0.125rem 0 0 0;
  font-size: 0.75rem;
  font-weight: 450;
  color: var(--toast-message-color);
  line-height: 1.3;
}

.toast-actions {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  margin-top: 0.5rem;
}

.btn-retry {
  padding: 0.25rem 0.75rem;
  background: var(--toast-btn-primary-bg);
  color: var(--toast-btn-primary-color);
  border: none;
  border-radius: 0.375rem;
  font-size: 0.7rem;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.2s ease;
}

.btn-retry:hover {
  background: var(--toast-btn-primary-hover-bg);
}

.btn-cancel-toast {
  padding: 0.25rem 0.75rem;
  background: transparent;
  color: var(--toast-btn-secondary-color);
  border: 1px solid var(--toast-btn-secondary-border);
  border-radius: 0.375rem;
  font-size: 0.7rem;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.2s ease;
}

.btn-cancel-toast:hover {
  background: var(--toast-btn-secondary-hover-bg);
}

.toast-close-btn {
  background: none;
  border: none;
  color: var(--toast-close-color);
  cursor: pointer;
  padding: 0.25rem;
  border-radius: 0.375rem;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: all 0.2s;
  flex-shrink: 0;
}

.toast-close-btn:hover {
  color: var(--toast-close-hover-color);
  background: rgba(0, 0, 0, 0.05);
}

.size-4 {
  width: 0.875rem;
  height: 0.875rem;
}

.toast-progress-bar {
  width: 100%;
  height: 2px;
  background: var(--toast-progress-bg);
}

.toast-progress-fill {
  width: 100%;
  height: 100%;
  background: var(--toast-progress-fill-color);
  transform-origin: left;
  transform: scaleX(1);
}

/* Color Variables per Type */
.toast-success {
  --toast-bg: rgba(240, 253, 244, 0.8);
  --toast-border-color: rgba(74, 222, 128, 0.3);
  --toast-icon-bg: rgba(220, 252, 231, 0.9);
  --toast-icon-color: #16a34a;
  --toast-title-color: #14532d;
  --toast-message-color: #166534;
  --toast-close-color: #166534;
  --toast-close-hover-color: #14532d;
  --toast-progress-bg: rgba(220, 252, 231, 0.5);
  --toast-progress-fill-color: #16a34a;
}

.toast-error {
  --toast-bg: rgba(254, 242, 242, 0.8);
  --toast-border-color: rgba(248, 113, 113, 0.3);
  --toast-icon-bg: rgba(254, 226, 226, 0.9);
  --toast-icon-color: #dc2626;
  --toast-title-color: #7f1d1d;
  --toast-message-color: #991b1b;
  --toast-close-color: #991b1b;
  --toast-close-hover-color: #7f1d1d;
  --toast-btn-primary-bg: #dc2626;
  --toast-btn-primary-color: #ffffff;
  --toast-btn-primary-hover-bg: #b91c1c;
  --toast-btn-secondary-color: #991b1b;
  --toast-btn-secondary-border: rgba(248, 113, 113, 0.3);
  --toast-btn-secondary-hover-bg: rgba(254, 226, 226, 0.5);
  --toast-progress-bg: rgba(254, 226, 226, 0.5);
  --toast-progress-fill-color: #dc2626;
}

.toast-warning {
  --toast-bg: rgba(255, 251, 235, 0.8);
  --toast-border-color: rgba(253, 224, 71, 0.4);
  --toast-icon-bg: rgba(254, 243, 199, 0.9);
  --toast-icon-color: #d97706;
  --toast-title-color: #78350f;
  --toast-message-color: #92400e;
  --toast-close-color: #92400e;
  --toast-close-hover-color: #78350f;
  --toast-progress-bg: rgba(254, 243, 199, 0.5);
  --toast-progress-fill-color: #d97706;
}

.toast-info {
  --toast-bg: rgba(239, 246, 255, 0.8);
  --toast-border-color: rgba(147, 197, 253, 0.4);
  --toast-icon-bg: rgba(219, 234, 254, 0.9);
  --toast-icon-color: #2563eb;
  --toast-title-color: #1e3a8a;
  --toast-message-color: #1e40af;
  --toast-close-color: #1e40af;
  --toast-close-hover-color: #1e3a8a;
  --toast-progress-bg: rgba(219, 234, 254, 0.5);
  --toast-progress-fill-color: #2563eb;
}

/* Dark Mode Overrides */
@media (prefers-color-scheme: dark) {
  .toast-success {
    --toast-bg: rgba(11, 26, 19, 0.8);
    --toast-border-color: rgba(34, 197, 94, 0.3);
    --toast-icon-bg: rgba(20, 83, 45, 0.9);
    --toast-icon-color: #4ade80;
    --toast-title-color: #f0fdf4;
    --toast-message-color: #bbf7d0;
    --toast-close-color: #86efac;
    --toast-close-hover-color: #f0fdf4;
    --toast-progress-bg: rgba(20, 83, 45, 0.5);
    --toast-progress-fill-color: #4ade80;
  }
  .toast-error {
    --toast-bg: rgba(28, 15, 15, 0.8);
    --toast-border-color: rgba(239, 68, 68, 0.3);
    --toast-icon-bg: rgba(127, 29, 29, 0.9);
    --toast-icon-color: #f87171;
    --toast-title-color: #fef2f2;
    --toast-message-color: #fca5a5;
    --toast-close-color: #fca5a5;
    --toast-close-hover-color: #fef2f2;
    --toast-btn-secondary-color: #fca5a5;
    --toast-btn-secondary-border: rgba(239, 68, 68, 0.3);
    --toast-btn-secondary-hover-bg: rgba(127, 29, 29, 0.5);
    --toast-progress-bg: rgba(127, 29, 29, 0.5);
    --toast-progress-fill-color: #f87171;
  }
  .toast-warning {
    --toast-bg: rgba(26, 22, 11, 0.8);
    --toast-border-color: rgba(234, 179, 8, 0.3);
    --toast-icon-bg: rgba(120, 53, 4, 0.9);
    --toast-icon-color: #facc15;
    --toast-title-color: #fffbeb;
    --toast-message-color: #fde047;
    --toast-close-color: #fde047;
    --toast-close-hover-color: #fffbeb;
    --toast-progress-bg: rgba(120, 53, 4, 0.5);
    --toast-progress-fill-color: #facc15;
  }
  .toast-info {
    --toast-bg: rgba(11, 19, 43, 0.8);
    --toast-border-color: rgba(59, 130, 246, 0.3);
    --toast-icon-bg: rgba(30, 58, 138, 0.9);
    --toast-icon-color: #60a5fa;
    --toast-title-color: #eff6ff;
    --toast-message-color: #bfdbfe;
    --toast-close-color: #93c5fd;
    --toast-close-hover-color: #eff6ff;
    --toast-progress-bg: rgba(30, 58, 138, 0.5);
    --toast-progress-fill-color: #60a5fa;
  }
}

/* Animations */
.premium-toast-enter-active {
  animation: premium-toast-in 0.250s cubic-bezier(0.34, 1.56, 0.64, 1);
}
.premium-toast-leave-active {
  animation: premium-toast-out 0.250s cubic-bezier(0.16, 1, 0.3, 1) forwards;
}

@keyframes premium-toast-in {
  0% {
    opacity: 0;
    transform: translateX(100px) scale(0.9);
  }
  70% {
    transform: translateX(-5px) scale(1.02);
  }
  100% {
    opacity: 1;
    transform: translateX(0) scale(1);
  }
}

@keyframes premium-toast-out {
  0% {
    opacity: 1;
    transform: translateX(0) scale(1);
  }
  100% {
    opacity: 0;
    transform: translateX(50px) scale(0.9);
  }
}
</style>
