<template>
  <main class="grid min-h-screen bg-white lg:grid-cols-[1.1fr_1fr]">
    <section class="relative hidden overflow-hidden bg-gradient-to-br from-ink via-[#111827] to-[#0b1220] p-12 text-white lg:flex lg:flex-col">
      <div class="pointer-events-none absolute -left-16 top-10 size-64 rounded-full bg-brand/25 blur-3xl" />
      <div class="pointer-events-none absolute -right-10 bottom-20 size-56 rounded-full bg-mint/15 blur-3xl" />
      <RouterLink class="relative text-xl font-bold" to="/">{{ t('brand') }}</RouterLink>

      <div class="relative my-auto max-w-xl">
        <p class="inline-flex rounded-full border border-brand/30 bg-brand/10 px-3 py-1 text-xs font-semibold uppercase tracking-wider text-brand">{{ t('landing.badge') }}</p>
        <h1 class="mt-6 text-5xl font-bold leading-tight">{{ t('auth.heroTitle') }}</h1>
        <p class="mt-5 text-lg leading-8 text-slate-300">{{ t('auth.heroSubtitle') }}</p>

        <div class="mt-10 grid gap-4 sm:grid-cols-2">
          <div v-for="item in highlights" :key="item.title" class="rounded-2xl border border-white/10 bg-white/5 p-4 backdrop-blur">
            <p class="text-sm font-bold text-mint">{{ item.stat }}</p>
            <p class="mt-1 font-semibold">{{ item.title }}</p>
            <p class="mt-1 text-xs text-slate-400">{{ item.body }}</p>
          </div>
        </div>

        <div class="mt-8 rounded-2xl border border-white/10 bg-white/5 p-5">
          <p class="text-sm italic text-slate-300">"{{ t('landing.testimonial') }}"</p>
          <p class="mt-3 text-xs font-semibold uppercase tracking-wider text-slate-500">{{ t('auth.trustedBy') }}</p>
        </div>
      </div>

      <div class="relative mt-8 grid grid-cols-3 gap-3">
        <div v-for="stat in stats" :key="stat.label" class="rounded-xl border border-white/10 bg-white/5 p-3 text-center">
          <p class="text-xl font-bold text-brand">{{ stat.value }}</p>
          <p class="mt-1 text-[10px] uppercase tracking-wider text-slate-400">{{ stat.label }}</p>
        </div>
      </div>
    </section>

    <section class="relative flex items-center justify-center overflow-hidden p-6 sm:p-10">
      <div class="absolute right-6 top-6 lg:hidden">
        <RouterLink class="text-sm font-semibold text-brand" to="/">{{ t('brand') }}</RouterLink>
      </div>

      <div class="w-full max-w-md overflow-hidden">
        <div class="flex transition-transform duration-500 ease-in-out" :style="{ transform: isSignup ? 'translateX(-100%)' : 'translateX(0)' }">
          <form class="w-full shrink-0 space-y-4 px-1" @submit.prevent="submitLogin">
            <h1 class="text-3xl font-bold text-ink">{{ t('auth.loginTitle') }}</h1>
            <p class="text-sm text-slate-500">{{ t('auth.loginSubtitle') }}</p>
            <ErrorState v-if="!isSignup && error" :message="error" />
            <div><label>{{ t('auth.loginField') }}</label><input v-model="loginForm.login" type="text" required autocomplete="username" /></div>
            <div>
              <label>{{ t('auth.password') }}</label>
              <div class="relative flex items-center">
                <input v-model="loginForm.password" :type="showLoginPassword ? 'text' : 'password'" required class="w-full pr-10" />
                <button type="button" class="absolute right-3 text-slate-400 hover:text-slate-600 focus:outline-none" @click="showLoginPassword = !showLoginPassword">
                  <svg v-if="!showLoginPassword" xmlns="http://www.w3.org/2000/svg" class="size-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M2 12s3-7 10-7 10 7 10 7-3 7-10 7-10-7-10-7Z"/><circle cx="12" cy="12" r="3"/></svg>
                  <svg v-else xmlns="http://www.w3.org/2000/svg" class="size-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M9.88 9.88a3 3 0 1 0 4.24 4.24"/><path d="M10.73 5.08A10.43 10.43 0 0 1 12 5c7 0 10 7 10 7a13.16 13.16 0 0 1-1.67 2.68"/><path d="M6.61 6.61A13.526 13.526 0 0 0 2 12s3 7 10 7a9.74 9.74 0 0 0 5.39-1.61"/><line x1="2" x2="22" y1="2" y2="22"/></svg>
                </button>
              </div>
            </div>
            <AppButton class="w-full" :loading="loading && !isSignup">{{ t('auth.submitLogin') }}</AppButton>
            <RouterLink
              v-if="currentUser?.role === 'super_admin'"
              class="flex w-full items-center justify-center gap-2 rounded-xl border border-brand/30 bg-brand/5 px-4 py-3 text-sm font-semibold text-brand transition hover:bg-brand/10"
              to="/admin"
            >
              <svg class="size-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z" /></svg>
              Super Admin Dashboard
            </RouterLink>
            <div class="flex items-center justify-between text-sm">
              <RouterLink class="text-brand" to="/forgot-password">{{ t('auth.forgot') }}</RouterLink>
              <button type="button" class="font-semibold text-brand" @click="goSignup">{{ t('auth.noAccount') }}</button>
            </div>
          </form>

          <form class="w-full shrink-0 space-y-4 px-1" @submit.prevent="submitSignup">
            <h1 class="text-3xl font-bold text-ink">{{ t('auth.signupTitle') }}</h1>
            <p class="text-sm text-slate-500">{{ t('auth.signupSubtitle') }}</p>
            <ErrorState v-if="isSignup && error" :message="error" />
            <div class="grid gap-4 sm:grid-cols-2">
              <div><label>{{ t('auth.firstName') }}</label><input v-model="signupForm.first_name" required /></div>
              <div><label>{{ t('auth.lastName') }} <span class="normal-case text-slate-400">({{ t('auth.optional') }})</span></label><input v-model="signupForm.last_name" /></div>
            </div>
            <div><label>{{ t('auth.username') }}</label><input v-model="signupForm.username" required /></div>
            <div><label>{{ t('auth.email') }}</label><input v-model="signupForm.email" type="email" required /></div>
            <div>
              <label>{{ t('auth.password') }}</label>
              <div class="relative flex items-center">
                <input v-model="signupForm.password" :type="showSignupPassword ? 'text' : 'password'" required minlength="6" class="w-full pr-10" />
                <button type="button" class="absolute right-3 text-slate-400 hover:text-slate-600 focus:outline-none" @click="showSignupPassword = !showSignupPassword">
                  <svg v-if="!showSignupPassword" xmlns="http://www.w3.org/2000/svg" class="size-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M2 12s3-7 10-7 10 7 10 7-3 7-10 7-10-7-10-7Z"/><circle cx="12" cy="12" r="3"/></svg>
                  <svg v-else xmlns="http://www.w3.org/2000/svg" class="size-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M9.88 9.88a3 3 0 1 0 4.24 4.24"/><path d="M10.73 5.08A10.43 10.43 0 0 1 12 5c7 0 10 7 10 7a13.16 13.16 0 0 1-1.67 2.68"/><path d="M6.61 6.61A13.526 13.526 0 0 0 2 12s3 7 10 7a9.74 9.74 0 0 0 5.39-1.61"/><line x1="2" x2="22" y1="2" y2="22"/></svg>
                </button>
              </div>
            </div>
            <AppButton class="w-full" :loading="loading && isSignup">{{ t('auth.submitSignup') }}</AppButton>
            <button type="button" class="text-sm font-semibold text-brand" @click="goLogin">{{ t('auth.hasAccount') }}</button>
          </form>
        </div>
      </div>
    </section>
  </main>
</template>

<script setup>
import { computed, onMounted, reactive, ref, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useStore } from 'vuex'
import AppButton from '../../components/ui/AppButton.vue'
import ErrorState from '../../components/ui/ErrorState.vue'
import { toast } from '../../utils/toast'
import { t } from '../../utils/i18n'

const props = defineProps({ mode: { type: String, default: 'login' } })

const store = useStore()
const route = useRoute()
const router = useRouter()

const loginForm = reactive({ login: '', password: '' })
const signupForm = reactive({ first_name: '', last_name: '', username: '', email: '', password: '' })
const showLoginPassword = ref(false)
const showSignupPassword = ref(false)

const isSignup = computed(() => route.path === '/signup' || props.mode === 'signup')
const loading = computed(() => store.state.auth.loading)
const error = computed(() => store.state.auth.error)
const currentUser = computed(() => store.state.auth.user)

onMounted(() => store.dispatch('auth/fetchMe'))

const highlights = [
  { stat: '10+', title: t('auth.highlightFeatures'), body: t('auth.highlightFeaturesBody') },
  { stat: 'Live', title: t('auth.highlightPreview'), body: t('auth.highlightPreviewBody') }
]

const stats = [
  { value: '1-click', label: t('auth.statDownload') },
  { value: 'AI', label: t('auth.statAi') },
  { value: '24/7', label: t('auth.statAccess') }
]

const goSignup = () => router.push('/signup')
const goLogin = () => router.push('/login')

watch(() => route.path, () => store.commit('auth/setError', null))

const submitLogin = async () => {
  const user = await store.dispatch('auth/login', loginForm)
  if (user) {
    toast.success(t('toast.loginSuccess'), t('toast.loginSuccessBody'))
    router.push(user.role === 'super_admin' ? '/admin' : '/dashboard')
  }
}

const submitSignup = async () => {
  const user = await store.dispatch('auth/signup', signupForm)
  if (user) {
    toast.success(t('toast.signupSuccess'), t('toast.signupSuccessBody'))
    router.push('/dashboard')
  }
}
</script>
