<template>
  <AuthLayout>
    <form class="w-full max-w-md space-y-4" @submit.prevent="submit">
      <h1 class="text-3xl font-bold">{{ t('auth.forgotTitle') }}</h1>
      <p class="text-sm text-slate-500">{{ t('auth.forgotSubtitle') }}</p>
      <ErrorState v-if="error" :message="error" />
      <div v-if="sent" class="rounded-2xl border border-emerald-200 bg-emerald-50 p-4 text-sm text-emerald-700">{{ t('auth.forgotSent') }}</div>
      <div><label>{{ t('auth.email') }}</label><input v-model="email" type="email" required /></div>
      <AppButton class="w-full" :loading="loading">{{ t('auth.submitForgot') }}</AppButton>
      <RouterLink class="block text-sm font-semibold text-brand" to="/login">{{ t('auth.hasAccount') }}</RouterLink>
    </form>
  </AuthLayout>
</template>

<script setup>
import { ref, computed } from 'vue'
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

const submit = async () => {
  sent.value = false
  const ok = await store.dispatch('auth/forgotPassword', email.value)
  if (ok) {
    sent.value = true
    toast.success(t('toast.forgotSuccess'), t('toast.forgotSuccessBody'))
  }
}
</script>
