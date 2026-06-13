<template>
  <div class="min-h-screen grid place-items-center bg-slate-50 p-4">
    <div class="w-full max-w-md rounded-2xl bg-white p-8 text-center shadow-xl shadow-slate-200/50">
      <div v-if="loading" class="flex flex-col items-center">
        <div class="size-12 animate-spin rounded-full border-4 border-slate-100 border-t-brand"></div>
        <p class="mt-4 text-slate-600 font-medium">Verifying your email...</p>
      </div>
      <div v-else-if="success" class="flex flex-col items-center">
        <div class="grid size-16 place-items-center rounded-full bg-emerald-100 text-emerald-600 mb-4">
          <svg class="size-8" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
            <path stroke-linecap="round" stroke-linejoin="round" d="M5 13l4 4L19 7" />
          </svg>
        </div>
        <h2 class="text-2xl font-bold text-ink">Email Verified!</h2>
        <p class="mt-2 text-slate-500">Thank you for verifying your email address. You can now access all features of CareerAI.</p>
        <RouterLink class="mt-6 inline-flex rounded-xl bg-brand px-6 py-3 font-semibold text-white transition hover:bg-brand/90" to="/dashboard">Go to Dashboard</RouterLink>
      </div>
      <div v-else class="flex flex-col items-center">
        <div class="grid size-16 place-items-center rounded-full bg-red-100 text-red-600 mb-4">
          <svg class="size-8" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
            <path stroke-linecap="round" stroke-linejoin="round" d="M6 18L18 6M6 6l12 12" />
          </svg>
        </div>
        <h2 class="text-2xl font-bold text-ink">Verification Failed</h2>
        <p class="mt-2 text-slate-500">{{ error || 'The link may have expired or is invalid.' }}</p>
        <RouterLink class="mt-6 inline-flex rounded-xl bg-brand px-6 py-3 font-semibold text-white transition hover:bg-brand/90" to="/dashboard">Go to Dashboard</RouterLink>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRoute } from 'vue-router'
import http from '../../services/http'
import { useStore } from 'vuex'

const route = useRoute()
const store = useStore()
const loading = ref(true)
const success = ref(false)
const error = ref('')

onMounted(async () => {
  const token = route.query.confirmation_token
  if (!token) {
    loading.value = false
    error.value = 'No confirmation token provided.'
    return
  }

  try {
    await http.post('/verifications/verify', { confirmation_token: token })
    success.value = true
    // refresh user state
    if (store.state.auth.user) {
      await store.dispatch('auth/fetchMe')
    }
  } catch (err) {
    error.value = err.response?.data?.error || 'Verification failed.'
  } finally {
    loading.value = false
  }
})
</script>
