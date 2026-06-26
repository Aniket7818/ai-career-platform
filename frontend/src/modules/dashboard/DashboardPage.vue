<template>
  <AppShell>
    <LoadingState v-if="loading" />
    <section v-else class="w-full space-y-8">
      <PageHero
        :badge="t('brand')"
        :title="`${t('dashboard.welcome')}, ${user?.first_name || ''}`"
        :subtitle="t('dashboard.subtitle')"
      >
        <template #actions>
          <RouterLink class="rounded-xl bg-brand px-5 py-2.5 text-sm font-semibold text-white shadow-lg shadow-brand/25" to="/resumes/new">{{ t('dashboard.createResume') }}</RouterLink>
          <RouterLink class="rounded-xl border border-white/20 bg-white/10 px-5 py-2.5 text-sm font-semibold text-white" to="/coming-soon">{{ t('nav.comingSoon') }}</RouterLink>
        </template>
      </PageHero>

      <!-- Verification Banner -->
      <div v-if="user && !user.verified" class="rounded-2xl border-2 border-red-500 bg-red-50 p-6 shadow-lg transition-all duration-500" :class="{ 'ring-4 ring-red-500/50 shadow-[0_0_20px_rgba(239,68,68,0.4)] scale-[1.02] bg-red-100/50': showVerifyBlink }">
        <div class="flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between">
          <div>
            <h3 class="text-lg font-bold text-red-700 flex items-center gap-2">
              <svg class="size-6" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2"><path stroke-linecap="round" stroke-linejoin="round" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z" /></svg>
              Account Verification Required
            </h3>
            <p class="mt-2 text-red-600">You must verify your email address to unlock full access. Creating, editing, or downloading resumes is disabled until verification is complete.</p>
          </div>
          <div class="flex flex-col items-center gap-2 shrink-0">
            <button 
              @click="sendVerificationEmail" 
              :disabled="sendingVerification || retryTimer > 0"
              class="rounded-xl bg-red-600 px-6 py-3 font-bold text-white shadow-lg shadow-red-600/30 transition hover:bg-red-700 disabled:opacity-50 disabled:cursor-not-allowed whitespace-nowrap"
            >
              {{ sendingVerification ? 'Sending...' : retryTimer > 0 ? `Retry in ${formatTimer(retryTimer)}` : 'Send Verification Email' }}
            </button>
            <p v-if="verificationMsg" class="text-sm font-medium" :class="verificationMsg.type === 'error' ? 'text-red-700' : 'text-green-600'">
              {{ verificationMsg.text }}
            </p>
          </div>
        </div>
      </div>

      <div class="grid gap-4 sm:grid-cols-2 xl:grid-cols-4">
        <StatCard
          v-for="card in cards"
          :key="card.label"
          :label="card.label"
          :value="card.value"
          :suffix="card.suffix"
          :progress="card.progress"
          :sparkline="card.sparkline"
          :accent-color="card.color"
          :variant="card.variant"
        >
          <template #icon>
            <svg class="size-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path :d="card.icon" /></svg>
          </template>
        </StatCard>
      </div>

      <div class="grid w-full gap-5 lg:grid-cols-[minmax(0,1fr)_minmax(280px,360px)] xl:grid-cols-[minmax(0,1fr)_380px]">
        <section class="min-w-0 rounded-2xl border border-slate-100 bg-white p-4 shadow-panel sm:p-6">
          <div class="flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between">
            <div class="min-w-0">
              <h2 class="text-lg font-bold text-ink sm:text-xl">{{ t('dashboard.recent') }}</h2>
              <p class="mt-1 text-sm text-slate-500">{{ t('dashboard.recentHint') }}</p>
            </div>
            <RouterLink class="shrink-0 rounded-xl bg-brand px-4 py-2 text-center text-sm font-semibold text-white" to="/resumes/new">{{ t('dashboard.createResume') }}</RouterLink>
          </div>
          <div v-if="recent.length" class="mt-5 grid gap-3">
            <RouterLink
              v-for="resume in recent"
              :key="resume.id"
              class="group flex items-center justify-between rounded-xl border border-slate-100 p-4 transition hover:border-brand/40 hover:bg-brand/5"
              :to="`/resumes/${resume.id}/edit`"
            >
              <div class="flex items-center gap-4">
                <span class="grid size-10 place-items-center rounded-xl bg-brand/10 text-brand">
                  <svg class="size-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.75"><path d="M14 2H6a2 2 0 00-2 2v16a2 2 0 002 2h12a2 2 0 002-2V8z" /><path d="M14 2v6h6" /></svg>
                </span>
                <div>
                  <p class="font-semibold text-ink group-hover:text-brand">{{ resume.title }}</p>
                  <p class="text-xs text-slate-500">{{ formatDate(resume.updated_at) }}</p>
                </div>
              </div>
              <ResumeStatusBadge :status="resume.status" />
            </RouterLink>
          </div>
          <div v-else class="mt-5 rounded-xl border border-dashed border-slate-200 p-8 text-center">
            <p class="text-sm text-slate-500">{{ t('resumes.empty') }}</p>
            <RouterLink class="mt-4 inline-flex rounded-xl bg-brand px-4 py-2 text-sm font-semibold text-white" to="/resumes/new">{{ t('dashboard.createResume') }}</RouterLink>
          </div>
        </section>

        <section class="min-w-0 rounded-2xl border border-slate-100 bg-white p-4 shadow-panel sm:p-6">
          <div class="mb-5 rounded-xl border border-brand/15 bg-brand/5 p-4">
            <div class="flex items-center justify-between gap-3">
              <div class="flex items-center gap-3">
                <span class="flex size-10 items-center justify-center rounded-full bg-brand text-sm font-bold text-white">{{ planIcon }}</span>
                <div>
                  <p class="text-xs font-bold uppercase tracking-wider text-slate-500">Current Plan</p>
                  <p class="text-lg font-bold text-ink">{{ planLabel }}</p>
                </div>
              </div>
              <RouterLink class="rounded-lg bg-brand px-3 py-2 text-xs font-bold text-white shrink-0" to="/settings">Manage</RouterLink>
            </div>
            <p class="mt-3 flex items-center gap-2 text-sm text-slate-500">
              <span class="inline-flex items-center gap-1.5 rounded-full bg-emerald-100 px-2.5 py-0.5 text-xs font-semibold text-emerald-700">
                <span class="size-1.5 rounded-full bg-emerald-500" />
                {{ isPaidPlan ? 'Active' : 'Free' }}
              </span>
              {{ planHint }}
            </p>
          </div>

          <h2 class="text-xl font-bold text-ink">{{ t('dashboard.quickActions') }}</h2>
          <p class="mt-1 text-sm text-slate-500">{{ t('dashboard.quickActionsHint') }}</p>
          <div class="mt-5 grid gap-3">
            <RouterLink class="flex items-center gap-3 rounded-xl bg-brand px-4 py-3 text-sm font-semibold text-white shadow-lg shadow-brand/20" to="/resumes/new">
              <svg class="size-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M12 5v14M5 12h14" /></svg>
              {{ t('dashboard.createResume') }}
            </RouterLink>
            <RouterLink class="flex items-center gap-3 rounded-xl border border-slate-200 px-4 py-3 text-sm font-semibold text-ink" to="/resumes">
              <svg class="size-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M4 6h16M4 12h16M4 18h16" /></svg>
              {{ t('resumes.listing') }}
            </RouterLink>
            <RouterLink class="flex items-center gap-3 rounded-xl border border-slate-200 px-4 py-3 text-sm font-semibold text-ink" to="/profile">
              <svg class="size-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M20 21v-2a4 4 0 00-4-4H8a4 4 0 00-4 4v2" /><circle cx="12" cy="7" r="4" /></svg>
              {{ t('nav.profile') }}
            </RouterLink>
            <RouterLink class="flex items-center gap-3 rounded-xl border border-brand/30 bg-brand/5 px-4 py-3 text-sm font-semibold text-brand" to="/coming-soon">
              <svg class="size-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M12 2l2.4 7.4H22l-6 4.6 2.3 7L12 17.8 5.7 21l2.3-7-6-4.6h7.6L12 2z" /></svg>
              {{ t('nav.comingSoon') }}
            </RouterLink>
          </div>
          <div class="mt-6 rounded-xl border border-slate-100 bg-slate-50 p-4">
            <p class="text-xs font-semibold uppercase tracking-wider text-slate-500">{{ t('dashboard.activity') }}</p>
            <div class="mt-3 h-16">
              <MiniSparkline :values="activityTrend" color="#35d6b4" />
            </div>
          </div>
        </section>
      </div>
    </section>
  </AppShell>
</template>

<script setup>
import { computed, onMounted, ref, watch } from 'vue'
import { useStore } from 'vuex'
import { useRoute, useRouter } from 'vue-router'
import http from '../../services/http'
import AppShell from '../../components/layout/AppShell.vue'
import LoadingState from '../../components/ui/LoadingState.vue'
import PageHero from '../../components/ui/PageHero.vue'
import StatCard from '../../components/ui/StatCard.vue'
import ResumeStatusBadge from '../../components/ui/ResumeStatusBadge.vue'
import MiniSparkline from '../../components/coming-soon/MiniSparkline.vue'
import { t } from '../../utils/i18n'

const store = useStore()
const route = useRoute()
const router = useRouter()

const showVerifyBlink = ref(false)
const sendingVerification = ref(false)
const verificationMsg = ref(null)
const retryTimer = ref(0)
let timerInterval = null

onMounted(() => {
  store.dispatch('dashboard/load')
  if (route.query.verify_required) {
    showVerifyBlink.value = true
    setTimeout(() => { showVerifyBlink.value = false }, 3000)
    // Clean up URL
    router.replace({ query: {} })
  }
})

const sendVerificationEmail = async () => {
  sendingVerification.value = true
  verificationMsg.value = null
  try {
    const res = await http.post('/verifications')
    verificationMsg.value = { type: 'success', text: 'Verification email sent! Check your inbox.' }
    startTimer(300) // 5 minutes
  } catch (err) {
    const data = err.response?.data
    verificationMsg.value = { type: 'error', text: data?.error || 'Failed to send email.' }
    if (data?.retry_after) {
      startTimer(data.retry_after)
    }
  } finally {
    sendingVerification.value = false
  }
}

const startTimer = (seconds) => {
  retryTimer.value = seconds
  clearInterval(timerInterval)
  timerInterval = setInterval(() => {
    retryTimer.value--
    if (retryTimer.value <= 0) clearInterval(timerInterval)
  }, 1000)
}

const formatTimer = (totalSeconds) => {
  const m = Math.floor(totalSeconds / 60)
  const s = totalSeconds % 60
  return `${m}:${s.toString().padStart(2, '0')}`
}

const user = computed(() => store.state.dashboard.user || store.state.auth.user)
const loading = computed(() => store.state.dashboard.loading)
const recent = computed(() => store.state.dashboard.recent)
const stats = computed(() => store.state.dashboard.stats)
const planLabel = computed(() => {
  const plan = user.value?.subscription_plan || 'free'
  if (plan === 'team') return 'Team (Legacy)'
  if (plan === 'pro') return 'CareerAI Pro'
  if (plan === 'plus') return 'CareerAI Plus'
  return 'Free'
})
const planIcon = computed(() => {
  const plan = user.value?.subscription_plan || 'free'
  if (plan === 'team') return 'T'
  if (plan === 'pro') return 'P'
  if (plan === 'plus') return '+'
  return 'F'
})
const isPaidPlan = computed(() => {
  const plan = user.value?.subscription_plan || 'free'
  return plan !== 'free' && user.value?.subscription_expires_at
})
const planHint = computed(() => {
  if (user.value?.subscription_expires_at) return `Expires in ${formatRemaining(user.value.subscription_seconds_remaining)}`
  return `${user.value?.free_downloads_remaining ?? 3} free PDF downloads remaining`
})

const activityTrend = computed(() => {
  const total = stats.value.total_resumes || 0
  return [Math.max(total - 3, 0), Math.max(total - 2, 0), Math.max(total - 1, 0), total, total, total + 1, total + 1]
})

const cards = computed(() => [
  {
    label: t('dashboard.total'),
    value: stats.value.total_resumes || 0,
    suffix: '',
    progress: '100%',
    sparkline: activityTrend.value,
    color: '#6d4aff',
    variant: 'brand',
    icon: 'M14 2H6a2 2 0 00-2 2v16a2 2 0 002 2h12a2 2 0 002-2V8z M14 2v6h6'
  },
  {
    label: t('dashboard.drafts'),
    value: stats.value.draft_resumes || 0,
    suffix: '',
    progress: `${Math.min((stats.value.draft_resumes || 0) * 25, 100)}%`,
    sparkline: activityTrend.value.map((v) => Math.round(v * 0.5)),
    color: '#fbbf24',
    variant: 'amber',
    icon: 'M11 4H4a2 2 0 00-2 2v14a2 2 0 002 2h14a2 2 0 002-2v-7 M18.5 2.5a2.12 2.12 0 013 3L12 15l-4 1 1-4 9.5-9.5z'
  },
  {
    label: t('dashboard.published'),
    value: stats.value.published_resumes || 0,
    suffix: '',
    progress: `${Math.min((stats.value.published_resumes || 0) * 25, 100)}%`,
    sparkline: activityTrend.value.map((v) => Math.round(v * 0.35)),
    color: '#34d399',
    variant: 'emerald',
    icon: 'M22 11.08V12a10 10 0 11-5.93-9.14 M22 4L12 14.01l-3-3'
  },
  {
    label: t('dashboard.strength'),
    value: stats.value.profile_strength || 0,
    suffix: '%',
    progress: `${stats.value.profile_strength || 0}%`,
    sparkline: [20, 30, 40, 50, 55, 60, stats.value.profile_strength || 0],
    color: '#35d6b4',
    variant: 'mint',
    icon: 'M22 12h-4l-3 9L9 3l-3 9H2'
  }
])

const formatDate = (value) => {
  if (!value) return ''
  return new Date(value).toLocaleDateString(undefined, { month: 'short', day: 'numeric', year: 'numeric' })
}

const formatRemaining = (seconds = 0) => {
  const days = Math.floor(seconds / 86400)
  const hours = Math.floor((seconds % 86400) / 3600)
  const minutes = Math.floor((seconds % 3600) / 60)
  return `${days}d ${hours}h ${minutes}m`
}
</script>