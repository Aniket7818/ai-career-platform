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

watch(toasts, (items) => {
  items.forEach((toast) => {
    if (!toast._scheduled) {
      toast._scheduled = true
      setTimeout(() => {
        remove(toast.id)
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
  max-width: 400px;
  pointer-events: none;
}

@media (max-width: 640px) {
  .toast-container {
    top: 0.75rem;
    right: 0.75rem;
    left: auto;
    max-width: 220px;
    width: auto;
  }
  .toast-inner {
    padding: 0.5rem 0.75rem;
    gap: 0.5rem;
  }
  .toast-icon-wrap {
    width: 1.75rem;
    height: 1.75rem;
    border-radius: 0.5rem;
    flex-shrink: 0;
  }
  .toast-icon {
    width: 1rem;
    height: 1rem;
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
  border-radius: 1rem;
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.06), 0 4px 12px rgba(0, 0, 0, 0.02);
  overflow: hidden;
  display: flex;
  flex-direction: column;
  transition: all 0.3s ease;
  width: 100%;
}

.toast-inner {
  display: flex;
  align-items: flex-start;
  gap: 0.875rem;
  padding: 1rem;
}

.toast-icon-wrap {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 2.25rem;
  height: 2.25rem;
  border-radius: 0.75rem;
  background: var(--toast-icon-bg);
  color: var(--toast-icon-color);
  flex-shrink: 0;
}

.toast-icon {
  width: 1.25rem;
  height: 1.25rem;
}

.toast-content {
  flex: 1;
  min-width: 0;
  padding-top: 0.125rem;
}

.toast-title {
  margin: 0;
  font-size: 0.925rem;
  font-weight: 600;
  color: var(--toast-title-color);
  line-height: 1.4;
}

.toast-message {
  margin: 0.25rem 0 0 0;
  font-size: 0.825rem;
  font-weight: 450;
  color: var(--toast-message-color);
  line-height: 1.4;
}

.toast-actions {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  margin-top: 0.75rem;
}

.btn-retry {
  padding: 0.375rem 0.875rem;
  background: var(--toast-btn-primary-bg);
  color: var(--toast-btn-primary-color);
  border: none;
  border-radius: 0.5rem;
  font-size: 0.75rem;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.2s ease;
}

.btn-retry:hover {
  background: var(--toast-btn-primary-hover-bg);
}

.btn-cancel-toast {
  padding: 0.375rem 0.875rem;
  background: transparent;
  color: var(--toast-btn-secondary-color);
  border: 1px solid var(--toast-btn-secondary-border);
  border-radius: 0.5rem;
  font-size: 0.75rem;
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
  width: 1rem;
  height: 1rem;
}

.toast-progress-bar {
  width: 100%;
  height: 3px;
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
  --toast-bg: #f2fbf6;
  --toast-border-color: #d1f2e1;
  --toast-icon-bg: #e1f7ec;
  --toast-icon-color: #10b981;
  --toast-title-color: #0f172a;
  --toast-message-color: #475569;
  --toast-close-color: #94a3b8;
  --toast-close-hover-color: #475569;
  --toast-progress-bg: #e1f7ec;
  --toast-progress-fill-color: #10b981;
}

.toast-error {
  --toast-bg: #fdf2f2;
  --toast-border-color: #fde8e8;
  --toast-icon-bg: #fde8e8;
  --toast-icon-color: #ef4444;
  --toast-title-color: #0f172a;
  --toast-message-color: #475569;
  --toast-close-color: #94a3b8;
  --toast-close-hover-color: #475569;
  --toast-btn-primary-bg: #ef4444;
  --toast-btn-primary-color: #ffffff;
  --toast-btn-primary-hover-bg: #dc2626;
  --toast-btn-secondary-color: #475569;
  --toast-btn-secondary-border: #e2e8f0;
  --toast-btn-secondary-hover-bg: #f1f5f9;
  --toast-progress-bg: #fde8e8;
  --toast-progress-fill-color: #ef4444;
}

.toast-warning {
  --toast-bg: #fffbeb;
  --toast-border-color: #fde68a;
  --toast-icon-bg: #fef3c7;
  --toast-icon-color: #f59e0b;
  --toast-title-color: #0f172a;
  --toast-message-color: #475569;
  --toast-close-color: #94a3b8;
  --toast-close-hover-color: #475569;
  --toast-progress-bg: #fef3c7;
  --toast-progress-fill-color: #f59e0b;
}

.toast-info {
  --toast-bg: #eff6ff;
  --toast-border-color: #bfdbfe;
  --toast-icon-bg: #dbeafe;
  --toast-icon-color: #3b82f6;
  --toast-title-color: #0f172a;
  --toast-message-color: #475569;
  --toast-close-color: #94a3b8;
  --toast-close-hover-color: #475569;
  --toast-progress-bg: #dbeafe;
  --toast-progress-fill-color: #3b82f6;
}

/* Dark Mode Overrides */
@media (prefers-color-scheme: dark) {
  .toast-success {
    --toast-bg: #0b1a13;
    --toast-border-color: #123d24;
    --toast-icon-bg: #123d24;
    --toast-title-color: #f8fafc;
    --toast-message-color: #cbd5e1;
    --toast-close-color: #64748b;
    --toast-close-hover-color: #cbd5e1;
    --toast-progress-bg: #123d24;
  }
  .toast-error {
    --toast-bg: #1c0f0f;
    --toast-border-color: #4a1d1d;
    --toast-icon-bg: #4a1d1d;
    --toast-title-color: #f8fafc;
    --toast-message-color: #cbd5e1;
    --toast-close-color: #64748b;
    --toast-close-hover-color: #cbd5e1;
    --toast-btn-secondary-color: #cbd5e1;
    --toast-btn-secondary-border: #334155;
    --toast-btn-secondary-hover-bg: #1e293b;
    --toast-progress-bg: #4a1d1d;
  }
  .toast-warning {
    --toast-bg: #1a160b;
    --toast-border-color: #3d3012;
    --toast-icon-bg: #3d3012;
    --toast-title-color: #f8fafc;
    --toast-message-color: #cbd5e1;
    --toast-close-color: #64748b;
    --toast-close-hover-color: #cbd5e1;
    --toast-progress-bg: #3d3012;
  }
  .toast-info {
    --toast-bg: #0b132b;
    --toast-border-color: #1e295d;
    --toast-icon-bg: #1e295d;
    --toast-title-color: #f8fafc;
    --toast-message-color: #cbd5e1;
    --toast-close-color: #64748b;
    --toast-close-hover-color: #cbd5e1;
    --toast-progress-bg: #1e295d;
  }
}

/* Animations */
.premium-toast-enter-active {
  animation: premium-toast-in 0.250s cubic-bezier(0.34, 1.56, 0.64, 1);
}
.premium-toast-leave-active {
  animation: premium-toast-out 0.250s cubic-bezier(0.16, 1, 0.3, 1);
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
