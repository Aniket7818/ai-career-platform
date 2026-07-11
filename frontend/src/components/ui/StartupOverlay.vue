<template>
  <Transition name="fade">
    <div
      v-if="shouldShowOverlay"
      class="fixed inset-0 z-[9999] flex flex-col items-center justify-center bg-background px-6 text-center select-none"
    >
      <!-- Background Decorative Gradients -->
      <div class="absolute inset-0 overflow-hidden pointer-events-none opacity-40 dark:opacity-20">
        <div
          class="absolute -top-[40%] -left-[30%] w-[80%] aspect-square rounded-full blur-[120px]"
          style="background: radial-gradient(circle, rgba(109, 74, 255, 0.15) 0%, transparent 70%);"
        />
        <div
          class="absolute -bottom-[40%] -right-[30%] w-[80%] aspect-square rounded-full blur-[120px]"
          style="background: radial-gradient(circle, rgba(53, 214, 180, 0.12) 0%, transparent 70%);"
        />
      </div>

      <div class="relative z-10 max-w-md w-full flex flex-col items-center">
        <!-- Logo / Branding -->
        <div class="flex items-center gap-3 mb-10">
          <span class="flex size-11 items-center justify-center rounded-2xl bg-brand text-xl font-black text-white shadow-lg shadow-brand/20 ring-4 ring-brand/10">
            C
          </span>
          <span class="text-2xl font-black tracking-tight text-txt-primary">
            Career<span class="text-brand">AI</span>
          </span>
        </div>

        <!-- 1. Offline Mode -->
        <div v-if="isOffline" class="flex flex-col items-center w-full">
          <div class="relative mb-8 flex items-center justify-center size-24 bg-danger/10 text-danger rounded-full text-4xl shadow-inner animate-pulse-slow">
            📶
            <span class="absolute bottom-0 right-0 text-xl">❌</span>
          </div>
          <h2 class="text-xl font-bold tracking-tight text-txt-primary mb-3">
            No Internet Connection
          </h2>
          <p class="text-sm text-txt-muted leading-relaxed max-w-sm mb-8">
            Please check your network cables, Wi-Fi, or mobile data connection and try again.
          </p>
          <button
            @click="retryWaking"
            class="px-6 py-3 rounded-xl bg-brand hover:bg-brand/90 active:scale-95 text-white font-semibold text-sm shadow-md transition-all"
          >
            Retry Connection
          </button>
        </div>

        <!-- 2. Failed to Start / Startup Error -->
        <div v-else-if="hasFailedToStart" class="flex flex-col items-center w-full">
          <div class="relative mb-8 flex items-center justify-center size-24 bg-danger/10 text-danger rounded-full text-4xl shadow-inner">
            ⚠️
          </div>
          <h2 class="text-xl font-bold tracking-tight text-txt-primary mb-3">
            CareerAI Couldn't Start
          </h2>
          <p class="text-sm text-txt-muted leading-relaxed max-w-sm mb-8">
            We had trouble preparing your workspace. The services might be undergoing maintenance. Please try again in a few moments.
          </p>
          <button
            @click="retryWaking"
            class="px-6 py-3 rounded-xl bg-brand hover:bg-brand/90 active:scale-95 text-white font-semibold text-sm shadow-md transition-all"
          >
            Retry Startup
          </button>
        </div>

        <!-- 3. Sleeping / Waking (Default Startup Screen) -->
        <div v-else class="flex flex-col items-center w-full">
          <!-- Premium Spinner & Rocket Icon Animation -->
          <div class="relative mb-12 flex items-center justify-center size-28">
            <div class="absolute inset-0 rounded-full border-4 border-border" />
            <div class="absolute inset-0 rounded-full border-4 border-brand border-t-transparent animate-spin" />
            <div class="text-4xl animate-bounce-subtle">🚀</div>
          </div>

          <!-- Title -->
          <h2 class="text-xl font-bold tracking-tight text-txt-primary mb-3">
            Starting CareerAI
          </h2>

          <!-- Current Rotating Message -->
          <div class="h-6 mb-6">
            <Transition name="slide" mode="out-in">
              <p :key="currentMessage" class="text-sm font-medium text-brand">
                {{ currentMessage }}
              </p>
            </Transition>
          </div>

          <!-- Explanation Message -->
          <p class="text-sm text-txt-muted leading-relaxed max-w-sm mb-6">
            Preparing secure services and spinning up your workspace. This usually takes less than one minute after periods of inactivity.
          </p>

          <!-- Indeterminate Progress Bar -->
          <div class="progress-bar-container mb-2">
            <div class="progress-bar-indicator" />
          </div>
          <span class="text-xs font-semibold text-txt-muted uppercase tracking-wider">
            Initializing...
          </span>
        </div>
      </div>
    </div>
  </Transition>
</template>

<script setup>
import { ref, onMounted, onUnmounted, watch, computed } from 'vue'
import { useRoute } from 'vue-router'
import { isWaking, isOffline, hasFailedToStart, retryWaking } from '../../services/backendAvailability'

const route = useRoute()

const staticPaths = [
  '/',
  '/about',
  '/careers',
  '/blog',
  '/contact',
  '/help',
  '/faq',
  '/support',
  '/status',
  '/privacy',
  '/terms',
  '/cookies',
  '/refund-policy',
  '/shipping-policy',
  '/coming-soon'
]

const shouldShowOverlay = computed(() => {
  const currentPath = route ? route.path : '/'
  const isStatic = staticPaths.includes(currentPath)
  const isUnavailable = isWaking.value || isOffline.value || hasFailedToStart.value
  
  return isUnavailable && !isStatic
})

const messages = [
  'Preparing AI services...',
  'Connecting securely...',
  'Starting Resume Engine...',
  'Loading CareerAI...',
  'Almost ready...',
  'Configuring secure channels...',
  'Waking databases...',
  'Optimizing performance...'
]

const currentMessage = ref(messages[0])
let messageInterval = null

const startLoadingEffects = () => {
  if (messageInterval) return
  let msgIdx = 0
  messageInterval = setInterval(() => {
    msgIdx = (msgIdx + 1) % messages.length
    currentMessage.value = messages[msgIdx]
  }, 3000)
}

const stopLoadingEffects = () => {
  if (messageInterval) {
    clearInterval(messageInterval)
    messageInterval = null
  }
}

watch(shouldShowOverlay, (show) => {
  if (show && !isOffline.value && !hasFailedToStart.value) {
    startLoadingEffects()
  } else {
    stopLoadingEffects()
  }
})

onMounted(() => {
  if (shouldShowOverlay.value && !isOffline.value && !hasFailedToStart.value) {
    startLoadingEffects()
  }
})

onUnmounted(() => {
  stopLoadingEffects()
})
</script>

<style scoped>
.progress-bar-container {
  width: 100%;
  height: 6px;
  background-color: rgb(var(--color-border));
  border-radius: var(--radius-full);
  overflow: hidden;
  position: relative;
}

.progress-bar-indicator {
  height: 100%;
  background-color: rgb(var(--color-primary));
  border-radius: var(--radius-full);
  position: absolute;
  left: 0;
  width: 40%;
  animation: loading-infinite 1.6s infinite linear;
}

@keyframes loading-infinite {
  0% {
    left: -40%;
  }
  100% {
    left: 100%;
  }
}

/* Fade transitions */
.fade-enter-active,
.fade-leave-active {
  transition: opacity 0.5s ease;
}
.fade-enter-from,
.fade-leave-to {
  opacity: 0;
}

/* Slide message transitions */
.slide-enter-active,
.slide-leave-active {
  transition: all 0.3s ease;
}
.slide-enter-from {
  opacity: 0;
  transform: translateY(8px);
}
.slide-leave-to {
  opacity: 0;
  transform: translateY(-8px);
}

/* Custom bounce for rocket */
@keyframes bounce-subtle {
  0%, 100% {
    transform: translateY(0);
  }
  50% {
    transform: translateY(-6px);
  }
}
.animate-bounce-subtle {
  animation: bounce-subtle 2s infinite ease-in-out;
}
</style>
