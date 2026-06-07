<template>
  <component :is="wrapper">
    <div class="min-h-full w-full max-w-full bg-surface text-white">
      <div v-if="!user" class="w-full border-b border-white/10 bg-surface/90 backdrop-blur">
        <div class="page-container flex items-center justify-between gap-3 py-3 sm:py-4">
          <RouterLink class="flex min-w-0 items-center gap-2 text-lg font-bold text-white sm:text-xl" to="/">
            <span class="grid size-9 shrink-0 place-items-center rounded-md bg-brand text-white">C</span>
            <span class="truncate">{{ t('brand') }}</span>
          </RouterLink>
          <nav class="hidden items-center gap-4 text-sm md:flex">
            <RouterLink class="text-slate-300 hover:text-white" to="/">{{ t('nav.features') }}</RouterLink>
            <RouterLink class="text-slate-300 hover:text-white" to="/coming-soon">{{ t('nav.comingSoon') }}</RouterLink>
            <RouterLink class="rounded-md bg-brand px-4 py-2 font-semibold text-white" to="/login">{{ t('nav.login') }}</RouterLink>
          </nav>
          <button
            type="button"
            class="grid size-10 shrink-0 place-items-center rounded-xl border border-white/10 bg-white/5 text-white transition hover:bg-white/10 md:hidden"
            :aria-expanded="guestMenuOpen"
            aria-label="Toggle menu"
            @click="guestMenuOpen = !guestMenuOpen"
          >
            <svg v-if="!guestMenuOpen" class="size-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M4 6h16M4 12h16M4 18h16" /></svg>
            <svg v-else class="size-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M18 6L6 18M6 6l12 12" /></svg>
          </button>
        </div>
        <div v-if="guestMenuOpen" class="border-t border-white/10 px-4 py-4 md:hidden">
          <nav class="flex flex-col gap-1">
            <RouterLink class="rounded-xl px-4 py-3 text-sm font-medium text-slate-300 transition hover:bg-white/5 hover:text-white" to="/" @click="guestMenuOpen = false">{{ t('nav.features') }}</RouterLink>
            <RouterLink class="rounded-xl px-4 py-3 text-sm font-medium text-slate-300 transition hover:bg-white/5 hover:text-white" to="/coming-soon" @click="guestMenuOpen = false">{{ t('nav.comingSoon') }}</RouterLink>
            <RouterLink class="mt-2 block rounded-xl bg-brand px-4 py-3 text-center text-sm font-semibold text-white" to="/login" @click="guestMenuOpen = false">{{ t('nav.login') }}</RouterLink>
          </nav>
        </div>
      </div>

      <div class="page-container space-y-8 py-6 sm:py-8 lg:py-10">
        <section class="relative overflow-hidden rounded-3xl border border-white/10 bg-gradient-to-br from-ink via-surface-light to-surface p-5 shadow-glow sm:p-8 lg:p-10">
          <div class="absolute -right-20 -top-20 size-72 rounded-full bg-brand/20 blur-3xl" />
          <div class="absolute -bottom-16 -left-16 size-56 rounded-full bg-mint/10 blur-3xl" />
          <div class="relative grid gap-8 lg:grid-cols-[1fr_340px] lg:items-center">
            <div>
              <p class="inline-flex items-center gap-2 rounded-full border border-brand/30 bg-brand/10 px-3 py-1 text-xs font-semibold uppercase tracking-wider text-brand">
                <span class="relative flex size-2"><span class="absolute inline-flex size-full animate-ping rounded-full bg-brand opacity-75" /><span class="relative inline-flex size-2 rounded-full bg-brand" /></span>
                {{ t('comingSoon.liveUpdates') }}
              </p>
              <h1 class="mt-5 text-3xl font-bold leading-tight sm:text-4xl lg:text-5xl">{{ t('comingSoon.title') }}</h1>
              <p class="mt-4 max-w-2xl text-base leading-7 text-slate-300">{{ t('comingSoon.subtitle') }}</p>
              <div class="mt-6 flex flex-wrap gap-3">
                <span class="rounded-full border border-white/10 bg-white/5 px-4 py-2 text-sm text-slate-300">{{ features.length }} {{ t('comingSoon.featuresCount') }}</span>
                <span class="rounded-full border border-emerald-500/20 bg-emerald-500/10 px-4 py-2 text-sm text-emerald-300">{{ launchingCount }} {{ t('comingSoon.launchingLabel') }}</span>
              </div>
            </div>
            <div class="rounded-2xl border border-white/10 bg-surface/60 p-5 backdrop-blur">
              <p class="text-xs font-semibold uppercase tracking-wider text-slate-400">{{ t('comingSoon.trendTitle') }}</p>
              <p class="mt-2 text-3xl font-bold"><AnimatedNumber :value="stats.total_interests || 0" /></p>
              <p class="text-sm text-slate-400">{{ t('comingSoon.trendSubtitle') }}</p>
              <div class="mt-4 h-24">
                <MiniSparkline :values="trend.values || []" color="#35d6b4" :height="96" :width="300" />
              </div>
              <div class="mt-3 flex justify-between text-[10px] uppercase tracking-wider text-slate-500">
                <span v-for="label in trend.labels || []" :key="label">{{ label }}</span>
              </div>
            </div>
          </div>
        </section>

        <LoadingState v-if="loading" />
        <ErrorState v-else-if="error" :message="error" />

        <template v-else>
          <ComingSoonStats :stats="stats" :trend="trend" />

          <section class="grid w-full gap-5 lg:grid-cols-[minmax(0,1fr)_minmax(280px,380px)]">
            <div class="rounded-2xl border border-white/10 bg-surface-light/50 p-6">
              <div class="flex items-center justify-between">
                <h2 class="text-lg font-bold">{{ t('comingSoon.interestChart') }}</h2>
                <span class="text-xs text-slate-400">{{ t('comingSoon.liveUpdates') }}</span>
              </div>
              <div class="mt-6">
                <InterestBarChart :items="chartItems" />
              </div>
            </div>
            <div class="rounded-2xl border border-white/10 bg-surface-light/50 p-6">
              <h2 class="text-lg font-bold">{{ t('comingSoon.pipelineTitle') }}</h2>
              <p class="mt-2 text-sm text-slate-400">{{ t('comingSoon.pipelineSubtitle') }}</p>
              <div class="mt-6 space-y-4">
                <div v-for="pipe in pipeline" :key="pipe.status">
                  <div class="mb-1.5 flex justify-between text-sm">
                    <span class="text-slate-300">{{ pipe.label }}</span>
                    <span class="font-semibold">{{ pipe.count }}</span>
                  </div>
                  <div class="h-2 overflow-hidden rounded-full bg-white/10">
                    <div class="h-full rounded-full" :class="pipe.color" :style="{ width: `${pipe.percent}%` }" />
                  </div>
                </div>
              </div>
              <div class="mt-8 rounded-xl border border-dashed border-white/15 bg-surface/50 p-5 text-center">
                <div class="mx-auto grid size-14 place-items-center rounded-2xl bg-brand/15 text-brand">
                  <svg class="size-7" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.75"><path d="M12 2l3.09 6.26L22 9.27l-5 4.87 1.18 6.88L12 17.77l-6.18 3.25L7 14.14 2 9.27l6.91-1.01L12 2z" /></svg>
                </div>
                <p class="mt-4 text-sm font-semibold text-white">{{ t('comingSoon.emptyState.title') }}</p>
                <p class="mt-2 text-xs leading-5 text-slate-400">{{ t('comingSoon.emptyState.body') }}</p>
              </div>
            </div>
          </section>

          <section>
            <div class="mb-6 flex flex-wrap items-end justify-between gap-4">
              <div>
                <h2 class="text-2xl font-bold">{{ t('comingSoon.featuresTitle') }}</h2>
                <p class="mt-2 text-sm text-slate-400">{{ t('comingSoon.featuresSubtitle') }}</p>
              </div>
              <div class="flex gap-2">
                <button
                  v-for="filter in statusFilters"
                  :key="filter.value"
                  class="rounded-full px-3 py-1.5 text-xs font-semibold transition"
                  :class="activeFilter === filter.value ? 'bg-brand text-white' : 'border border-white/10 text-slate-400 hover:text-white'"
                  @click="activeFilter = filter.value"
                >
                  {{ filter.label }}
                </button>
              </div>
            </div>
            <div v-if="filteredFeatures.length" class="grid gap-5 md:grid-cols-2 xl:grid-cols-3">
              <FeatureCard
                v-for="feature in filteredFeatures"
                :key="feature.key"
                :feature="feature"
                :loading="notifyingKey === feature.key"
                @notify="handleNotify"
                @unnotify="handleUnnotify"
              />
            </div>
            <div v-else class="rounded-2xl border border-dashed border-white/15 bg-surface-light/30 p-12 text-center">
              <p class="text-lg font-semibold">{{ t('comingSoon.noResults') }}</p>
              <p class="mt-2 text-sm text-slate-400">{{ t('comingSoon.noResultsHint') }}</p>
            </div>
          </section>
        </template>
      </div>

      <NotifyMeModal
        :open="modalOpen"
        :feature-key="pendingKey"
        :loading="modalLoading"
        :error="modalError"
        :default-email="user?.email || ''"
        @close="closeModal"
        @submit="submitNotify"
      />
    </div>
  </component>
</template>

<script setup>
import { computed, onMounted, onUnmounted, ref } from 'vue'
import { useStore } from 'vuex'
import AppShell from '../../components/layout/AppShell.vue'
import LoadingState from '../../components/ui/LoadingState.vue'
import ErrorState from '../../components/ui/ErrorState.vue'
import ComingSoonStats from '../../components/coming-soon/ComingSoonStats.vue'
import FeatureCard from '../../components/coming-soon/FeatureCard.vue'
import InterestBarChart from '../../components/coming-soon/InterestBarChart.vue'
import MiniSparkline from '../../components/coming-soon/MiniSparkline.vue'
import AnimatedNumber from '../../components/coming-soon/AnimatedNumber.vue'
import NotifyMeModal from '../../components/coming-soon/NotifyMeModal.vue'
import { FEATURE_STATUS } from '../../constants/features'
import { toast } from '../../utils/toast'
import { t } from '../../utils/i18n'

const store = useStore()
const guestMenuOpen = ref(false)
const activeFilter = ref('all')
const notifyingKey = ref('')
const modalOpen = ref(false)
const modalLoading = ref(false)
const modalError = ref('')
const pendingKey = ref('')
let pollTimer = null

const user = computed(() => store.state.auth.user)
const wrapper = computed(() => (user.value ? AppShell : 'div'))
const loading = computed(() => store.state.comingSoon.loading)
const error = computed(() => store.state.comingSoon.error)
const stats = computed(() => store.state.comingSoon.stats)
const trend = computed(() => store.state.comingSoon.trend)
const features = computed(() => store.state.comingSoon.features)

const launchingCount = computed(() => features.value.filter((f) => f.status === FEATURE_STATUS.LAUNCHING_SOON).length)

const statusFilters = computed(() => [
  { value: 'all', label: t('comingSoon.filters.all') },
  { value: FEATURE_STATUS.LAUNCHING_SOON, label: t('comingSoon.status.launching_soon') },
  { value: FEATURE_STATUS.IN_DEVELOPMENT, label: t('comingSoon.status.in_development') },
  { value: FEATURE_STATUS.PLANNED, label: t('comingSoon.status.planned') }
])

const filteredFeatures = computed(() => {
  if (activeFilter.value === 'all') return features.value
  return features.value.filter((f) => f.status === activeFilter.value)
})

const chartItems = computed(() =>
  features.value.map((f) => ({
    key: f.key,
    count: f.interest_count || 0,
    label: t(`comingSoon.features.${f.key}.title`),
    shortLabel: t(`comingSoon.features.${f.key}.short`)
  }))
)

const pipeline = computed(() => {
  const total = features.value.length || 1
  const counts = {
    [FEATURE_STATUS.PLANNED]: features.value.filter((f) => f.status === FEATURE_STATUS.PLANNED).length,
    [FEATURE_STATUS.IN_DEVELOPMENT]: features.value.filter((f) => f.status === FEATURE_STATUS.IN_DEVELOPMENT).length,
    [FEATURE_STATUS.LAUNCHING_SOON]: features.value.filter((f) => f.status === FEATURE_STATUS.LAUNCHING_SOON).length
  }
  return [
    { status: FEATURE_STATUS.LAUNCHING_SOON, label: t('comingSoon.status.launching_soon'), count: counts[FEATURE_STATUS.LAUNCHING_SOON], percent: (counts[FEATURE_STATUS.LAUNCHING_SOON] / total) * 100, color: 'bg-emerald-400' },
    { status: FEATURE_STATUS.IN_DEVELOPMENT, label: t('comingSoon.status.in_development'), count: counts[FEATURE_STATUS.IN_DEVELOPMENT], percent: (counts[FEATURE_STATUS.IN_DEVELOPMENT] / total) * 100, color: 'bg-amber-400' },
    { status: FEATURE_STATUS.PLANNED, label: t('comingSoon.status.planned'), count: counts[FEATURE_STATUS.PLANNED], percent: (counts[FEATURE_STATUS.PLANNED] / total) * 100, color: 'bg-sky-400' }
  ]
})

const load = () => store.dispatch('comingSoon/load')

const handleNotify = async (key) => {
  if (user.value) {
    notifyingKey.value = key
    const result = await store.dispatch('comingSoon/notify', { feature_key: key })
    notifyingKey.value = ''
    if (result) toast.success(t('toast.notifySuccess'), t('toast.notifySuccessBody'))
    return
  }
  pendingKey.value = key
  modalError.value = ''
  modalOpen.value = true
}

const handleUnnotify = async (key) => {
  notifyingKey.value = key
  const result = await store.dispatch('comingSoon/unregister', { feature_key: key })
  notifyingKey.value = ''
  if (result) toast.info(t('toast.notifyRemoved'), t('toast.notifyRemovedBody'))
}

const closeModal = () => {
  modalOpen.value = false
  pendingKey.value = ''
  modalError.value = ''
}

const submitNotify = async (payload) => {
  modalLoading.value = true
  modalError.value = ''
  const result = await store.dispatch('comingSoon/notify', payload)
  modalLoading.value = false
  if (result) {
    closeModal()
    toast.success(t('toast.notifySuccess'), t('toast.notifySuccessBody'))
  } else {
    modalError.value = store.state.comingSoon.error
  }
}

onMounted(async () => {
  await store.dispatch('auth/fetchMe')
  load()
  pollTimer = setInterval(load, 30000)
})

onUnmounted(() => {
  if (pollTimer) clearInterval(pollTimer)
})
</script>
