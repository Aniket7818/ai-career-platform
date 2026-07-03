<template>
  <AuthLayout>
    <form class="w-full max-w-md space-y-4" @submit.prevent="submit">
      <h1 class="text-3xl font-bold">{{ t('auth.forgotTitle') }}</h1>
      <p class="text-sm text-slate-500">{{ t('auth.forgotSubtitle') }}</p>
      <ErrorState v-if="error" :message="error" />
      <div v-if="sent" class="rounded-2xl border border-emerald-200 bg-emerald-50 p-4 text-sm text-emerald-700">{{ t('auth.forgotSent') }}</div>
      <div><label>{{ t('auth.email') }}</label><input v-model="email" type="email" required /></div>

      <!-- Cloudflare Turnstile CAPTCHA -->
      <div>
        <div
          id="forgot-turnstile"
          class="cf-turnstile"
          :data-sitekey="turnstileSiteKey"
          data-callback="onForgotTurnstileSuccess"
          data-expired-callback="onForgotTurnstileExpired"
          data-theme="light"
        />
        <p v-if="captchaError" class="mt-1 text-xs text-red-500">{{ captchaError }}</p>
      </div>

      <AppButton class="w-full" :loading="loading" :disabled="!turnstileToken">{{ t('auth.submitForgot') }}</AppButton>
      <RouterLink class="block text-sm font-semibold text-brand" to="/login">{{ t('auth.hasAccount') }}</RouterLink>
    </form>
  </AuthLayout>
</template>

<script setup>
import { ref, computed, onMounted, onBeforeUnmount } from 'vue'
import { useStore } from 'vuex'
import AuthLayout from '../../components/layout/AuthLayout.vue'
import AppButton from '../../components/ui/AppButton.vue'
import ErrorState from '../../components/ui/ErrorState.vue'
import { toast } from '../../utils/toast'
import { t } from '../../utils/i18n'

const store = useStore()
const email = ref('')
const sent = ref(false)
const loading = computed(() => store.state.auth.loading)
const error = computed(() => store.state.auth.error)

// ── Turnstile ────────────────────────────────────────────────────────────────
const turnstileSiteKey = import.meta.env.VITE_TURNSTILE_SITE_KEY || ''
const turnstileToken   = ref('')
const captchaError     = ref('')

// Expose callbacks on window so Turnstile script can call them.
window.onForgotTurnstileSuccess = (token) => {
  turnstileToken.value = token
  captchaError.value   = ''
}
window.onForgotTurnstileExpired = () => {
  turnstileToken.value = ''
  captchaError.value   = 'CAPTCHA expired — please solve it again.'
}

// Inject the Turnstile script once if it isn't already present.
onMounted(() => {
  if (!document.getElementById('cf-turnstile-script')) {
    const script = document.createElement('script')
    script.id  = 'cf-turnstile-script'
    script.src = 'https://challenges.cloudflare.com/turnstile/v0/api.js'
    script.async = true
    script.defer = true
    document.head.appendChild(script)
  }
})

// Clean up window callbacks when component unmounts.
onBeforeUnmount(() => {
  delete window.onForgotTurnstileSuccess
  delete window.onForgotTurnstileExpired
})

// ── Submit ───────────────────────────────────────────────────────────────────
const submit = async () => {
  if (!turnstileToken.value && turnstileSiteKey) {
    captchaError.value = 'Please complete the CAPTCHA first.'
    return
  }

  sent.value = false
  const ok = await store.dispatch('auth/forgotPassword', {
    email: email.value,
    turnstileToken: turnstileToken.value,
  })

  if (ok) {
    sent.value = true
    toast.success(t('toast.forgotSuccess'), t('toast.forgotSuccessBody'))
  }

  // Always reset CAPTCHA after an attempt so the next request needs a fresh solve.
  turnstileToken.value = ''
  if (window.turnstile) window.turnstile.reset('#forgot-turnstile')
}
</script>

