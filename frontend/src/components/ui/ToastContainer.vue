<template>
  <div class="pointer-events-none fixed left-4 right-4 top-4 z-[100] flex flex-col gap-3 sm:left-auto sm:right-5 sm:top-5 sm:max-w-sm">
    <TransitionGroup name="toast">
      <div
        v-for="toast in toasts"
        :key="toast.id"
        class="pointer-events-auto overflow-hidden rounded-2xl border bg-white shadow-panel"
        :class="borderClass(toast.type)"
      >
        <div class="flex items-start gap-3 p-4">
          <span class="mt-0.5 grid size-8 shrink-0 place-items-center rounded-xl" :class="iconWrapClass(toast.type)">
            <svg class="size-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
              <path v-if="toast.type === 'success'" d="M20 6L9 17l-5-5" />
              <path v-else-if="toast.type === 'error'" d="M18 6L6 18M6 6l12 12" />
              <path v-else d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
            </svg>
          </span>
          <div class="min-w-0 flex-1">
            <p class="text-sm font-semibold text-ink">{{ toast.title }}</p>
            <p v-if="toast.message" class="mt-0.5 text-sm text-slate-500">{{ toast.message }}</p>
          </div>
          <button class="text-slate-400 hover:text-ink" @click="remove(toast.id)">×</button>
        </div>
        <div class="h-1 bg-slate-100">
          <div class="h-full origin-left" :class="barClass(toast.type)" :style="barStyle(toast)" />
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

onMounted(() => { timer = setInterval(() => { now.value = Date.now() }, 50) })
onUnmounted(() => { if (timer) clearInterval(timer) })

const remove = (id) => store.commit('toast/remove', id)

const borderClass = (type) => ({
  success: 'border-emerald-200',
  error: 'border-red-200',
  info: 'border-brand/30'
}[type] || 'border-slate-200')

const iconWrapClass = (type) => ({
  success: 'bg-emerald-500/15 text-emerald-600',
  error: 'bg-red-500/15 text-red-600',
  info: 'bg-brand/15 text-brand'
}[type] || 'bg-slate-100 text-slate-600')

const barClass = (type) => ({
  success: 'bg-emerald-500',
  error: 'bg-red-500',
  info: 'bg-brand'
}[type] || 'bg-brand')

const barStyle = (toast) => {
  const elapsed = now.value - toast.startedAt
  const remaining = Math.max(0, 1 - elapsed / toast.duration)
  return { transform: `scaleX(${remaining})`, transition: 'transform 50ms linear' }
}

watch(toasts, (items) => {
  items.forEach((toast) => {
    if (!toast._scheduled) {
      toast._scheduled = true
      setTimeout(() => store.commit('toast/remove', toast.id), toast.duration)
    }
  })
}, { deep: true })
</script>

<style scoped>
.toast-enter-active, .toast-leave-active { transition: all 0.35s ease; }
.toast-enter-from { opacity: 0; transform: translateX(24px); }
.toast-leave-to { opacity: 0; transform: translateX(24px) scale(0.95); }
</style>
