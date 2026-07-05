<template>
 <AuthLayout>
 <div v-if="loadingToken" class="flex min-h-[400px] w-full items-center justify-center">
 <div class="h-8 w-8 animate-spin rounded-full border-4 border-brand border-t-transparent"></div>
 </div>
 
 <div v-else-if="invalidToken" class="w-full max-w-md space-y-6 text-center">
 <div class="mx-auto flex h-16 w-16 items-center justify-center rounded-full bg-red-100 text-red-500">
 <svg class="h-8 w-8" fill="none" viewBox="0 0 24 24" stroke="currentColor">
 <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z" />
 </svg>
 </div>
 <h1 class="text-2xl font-bold text-txt-primary">{{ t('auth.resetErrorInvalidToken') }}</h1>
 <RouterLink to="/forgot-password" class="inline-flex items-center justify-center rounded-lg bg-brand px-6 py-3 font-semibold text-white transition hover:bg-brand/90">
 {{ t('auth.forgot') }}
 </RouterLink>
 </div>

 <form v-else class="w-full max-w-md space-y-4" @submit.prevent="submit">
 <h1 class="text-3xl font-bold">{{ t('auth.resetTitle') }}</h1>
 <p class="text-sm text-txt-muted">{{ t('auth.resetSubtitle') }}</p>
 
 <ErrorState v-if="error" :message="error" />
 
 <div>
 <label>{{ t('auth.resetPassword') }}</label>
 <input v-model="password" type="password" required minlength="8" />
 </div>
 <div>
 <label>{{ t('auth.resetConfirm') }}</label>
 <input v-model="passwordConfirmation" type="password" required minlength="8" />
 </div>
 
 <AppButton class="w-full" :loading="loading">{{ t('auth.submitReset') }}</AppButton>
 <RouterLink class="block text-center text-sm font-semibold text-txt-muted hover:text-txt-primary" to="/login">
 {{ t('auth.hasAccount') }}
 </RouterLink>
 </form>
 </AuthLayout>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useStore } from 'vuex'
import { useRoute, useRouter } from 'vue-router'
import AuthLayout from '../../components/layout/AuthLayout.vue'
import AppButton from '../../components/ui/AppButton.vue'
import ErrorState from '../../components/ui/ErrorState.vue'
import { toast } from '../../utils/toast'
import { t } from '../../utils/i18n'

const store = useStore()
const route = useRoute()
const router = useRouter()

const token = ref(route.query.token || '')
const password = ref('')
const passwordConfirmation = ref('')

const loadingToken = ref(true)
const invalidToken = ref(false)

const loading = computed(() => store.state.auth.loading)
const error = computed(() => store.state.auth.error)

onMounted(async () => {
 if (!token.value) {
 invalidToken.value = true
 loadingToken.value = false
 return
 }
 
 const isValid = await store.dispatch('auth/validateResetToken', token.value)
 if (!isValid) {
 invalidToken.value = true
 toast.error(t('common.error'), t('auth.resetErrorInvalidToken'))
 }
 
 loadingToken.value = false
})

const submit = async () => {
 if (password.value !== passwordConfirmation.value) {
 store.commit('auth/setError', "Passwords don't match")
 return
 }
 
 const ok = await store.dispatch('auth/resetPassword', {
 token: token.value,
 password: password.value,
 password_confirmation: passwordConfirmation.value
 })
 
 if (ok) {
 toast.success(t('auth.resetSuccess'), t('auth.resetSuccessBody'))
 router.push('/login')
 }
}
</script>
