<template>
  <component :is="wrapper">
    <div class="min-h-full w-full max-w-full bg-surface text-white pb-20">
      <div v-if="!user" class="w-full border-b border-white/10 bg-surface/90 backdrop-blur sticky top-0 z-50">
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

      <div class="page-container space-y-16 py-10 sm:py-16 lg:py-20">
        
        <!-- HERO -->
        <section class="text-center max-w-3xl mx-auto">
          <p class="inline-flex items-center gap-2 rounded-full border border-brand/30 bg-brand/10 px-3 py-1 text-xs font-semibold uppercase tracking-wider text-brand mb-6">
            <span class="relative flex size-2"><span class="absolute inline-flex size-full animate-ping rounded-full bg-brand opacity-75" /><span class="relative inline-flex size-2 rounded-full bg-brand" /></span>
            Product Roadmap
          </p>
          <h1 class="text-4xl font-extrabold tracking-tight sm:text-5xl lg:text-6xl text-transparent bg-clip-text bg-gradient-to-r from-white to-slate-400">
            Building the Future of Careers
          </h1>
          <p class="mt-6 text-lg text-slate-400 leading-relaxed">
            Explore what we've already delivered and see what's coming next on our journey to create the ultimate career toolkit.
          </p>
        </section>

        <!-- SECTION 1: Available Today -->
        <section>
          <div class="flex items-center gap-3 mb-8">
            <div class="flex size-10 items-center justify-center rounded-xl bg-emerald-500/20 text-emerald-400 border border-emerald-500/20">
              <svg class="size-5" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7" /></svg>
            </div>
            <h2 class="text-2xl font-bold">Available Today</h2>
          </div>
          <div class="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
            <div v-for="feature in availableToday" :key="feature" class="flex items-center gap-4 rounded-2xl border border-white/5 bg-surface-light/30 p-5 transition hover:bg-surface-light/50 hover:border-white/10">
              <div class="grid size-10 shrink-0 place-items-center rounded-full bg-white/5 text-slate-300">
                <svg class="size-5" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" /></svg>
              </div>
              <span class="font-medium text-slate-200">{{ feature }}</span>
            </div>
          </div>
        </section>

        <!-- SECTION 2: Coming Next -->
        <section>
          <div class="flex items-center gap-3 mb-8">
            <div class="flex size-10 items-center justify-center rounded-xl bg-brand/20 text-brand border border-brand/20">
              <svg class="size-5" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 10V3L4 14h7v7l9-11h-7z" /></svg>
            </div>
            <h2 class="text-2xl font-bold">Coming Next</h2>
          </div>
          <div class="grid gap-6 md:grid-cols-3">
            <div v-for="feature in comingNext" :key="feature.title" class="group relative overflow-hidden rounded-3xl border border-white/10 bg-surface-light/40 p-6 sm:p-8 transition-all hover:-translate-y-1 hover:border-brand/30 hover:bg-surface-light/60 hover:shadow-[0_8px_30px_rgb(0,0,0,0.12)]">
              <div class="absolute right-0 top-0 h-32 w-32 translate-x-8 -translate-y-8 rounded-full bg-brand/10 blur-3xl transition-all group-hover:bg-brand/20" />
              <div class="relative">
                <h3 class="text-xl font-bold text-white">{{ feature.title }}</h3>
                <p class="mt-3 text-sm leading-relaxed text-slate-400">{{ feature.description }}</p>
              </div>
            </div>
          </div>
        </section>

        <!-- SECTION 3: Product Roadmap -->
        <section>
          <div class="flex items-center gap-3 mb-8">
            <div class="flex size-10 items-center justify-center rounded-xl bg-purple-500/20 text-purple-400 border border-purple-500/20">
              <svg class="size-5" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 20l-5.447-2.724A1 1 0 013 16.382V5.618a1 1 0 011.447-.894L9 7m0 13l6-3m-6 3V7m6 10l4.553 2.276A1 1 0 0021 18.382V7.618a1 1 0 00-.553-.894L15 4m0 13V4m0 0L9 7" /></svg>
            </div>
            <h2 class="text-2xl font-bold">Roadmap</h2>
          </div>
          
          <div class="relative ml-5 border-l-2 border-white/10 space-y-10 pb-6 pt-2">
             <div v-for="(phase, index) in roadmap" :key="phase.name" class="relative pl-8">
               <div class="absolute -left-[9px] top-1.5 size-4 rounded-full border-4 border-surface" :class="phase.color"></div>
               <div class="flex flex-wrap items-center gap-3 mb-2">
                 <h3 class="text-lg font-bold text-white">{{ phase.name }}</h3>
                 <span class="rounded-full border border-white/10 px-2.5 py-0.5 text-xs font-medium" :class="phase.badgeColor">{{ phase.status }}</span>
               </div>
               <p class="text-slate-400 text-sm max-w-2xl">{{ phase.description }}</p>
             </div>
          </div>
        </section>

        <!-- SECTION 4: Join Waitlist -->
        <section class="relative overflow-hidden rounded-[2.5rem] border border-white/10 bg-gradient-to-br from-ink via-surface-light to-surface p-10 sm:p-16 text-center shadow-glow">
          <div class="absolute -right-20 -top-20 size-72 rounded-full bg-brand/20 blur-3xl" />
          <div class="absolute -bottom-16 -left-16 size-56 rounded-full bg-mint/10 blur-3xl" />
          
          <div class="relative z-10 mx-auto max-w-2xl">
            <h2 class="text-3xl font-bold sm:text-4xl">Be the first to know</h2>
            <p class="mt-4 text-lg text-slate-300">Join our waitlist to get notified the moment our new AI features launch. No spam, just product updates.</p>
            <div class="mt-8">
              <button
                type="button"
                class="inline-flex h-12 sm:h-14 items-center justify-center rounded-xl bg-brand px-8 text-base font-semibold text-white transition-all hover:bg-brand-light hover:shadow-[0_0_20px_rgba(53,214,180,0.4)] active:scale-95"
                @click="openWaitlistModal"
              >
                Join Waitlist
              </button>
            </div>
          </div>
        </section>
      </div>

      <NotifyMeModal
        :open="modalOpen"
        feature-key="general_waitlist"
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
import { computed, onMounted, ref } from 'vue'
import { useStore } from 'vuex'
import AppShell from '../../components/layout/AppShell.vue'
import NotifyMeModal from '../../components/coming-soon/NotifyMeModal.vue'
import { toast } from '../../utils/toast'
import { t } from '../../utils/i18n'

const store = useStore()
const guestMenuOpen = ref(false)
const modalOpen = ref(false)
const modalLoading = ref(false)
const modalError = ref('')

const user = computed(() => store.state.auth.user)
const wrapper = computed(() => (user.value ? AppShell : 'div'))

const availableToday = [
  'Resume Builder',
  'ATS Templates',
  'Smart Pagination',
  'PDF Export',
  'Resume Preview',
  'Resume Customization'
]

const comingNext = [
  {
    title: 'ATS Score',
    description: 'Instantly score your resume against ATS systems with advanced keyword analysis and optimization suggestions.'
  },
  {
    title: 'Resume Health Dashboard',
    description: 'Get actionable insights on your resume\'s strengths and weaknesses, including readability and impact.'
  },
  {
    title: 'AI Cover Letter Generator',
    description: 'Generate tailored, compelling cover letters for any job posting with just one click.'
  }
]

const roadmap = [
  {
    name: 'Phase 1',
    status: 'Completed',
    color: 'bg-emerald-400',
    badgeColor: 'bg-emerald-500/10 text-emerald-300 border-emerald-500/20',
    description: 'Core resume builder, smart pagination, basic templates, and PDF export functionality.'
  },
  {
    name: 'Phase 2',
    status: 'In Progress',
    color: 'bg-brand',
    badgeColor: 'bg-brand/10 text-brand border-brand/20',
    description: 'ATS scoring, resume health analytics, and AI-powered cover letter generation.'
  },
  {
    name: 'Phase 3',
    status: 'Planned',
    color: 'bg-slate-500',
    badgeColor: 'bg-slate-500/10 text-slate-300 border-slate-500/20',
    description: 'AI mock interviews, LinkedIn profile review, and automated portfolio website generation.'
  },
  {
    name: 'Phase 4',
    status: 'Future',
    color: 'bg-slate-700',
    badgeColor: 'bg-slate-700/30 text-slate-400 border-slate-700/50',
    description: 'Job application tracking, career roadmap generator, and advanced placement preparation hub.'
  }
]

const openWaitlistModal = async () => {
  if (user.value) {
    const result = await store.dispatch('comingSoon/notify', { feature_key: 'general_waitlist' })
    if (result) toast.success(t('toast.notifySuccess'), t('toast.notifySuccessBody'))
    return
  }
  modalError.value = ''
  modalOpen.value = true
}

const closeModal = () => {
  modalOpen.value = false
  modalError.value = ''
}

const submitNotify = async (payload) => {
  modalLoading.value = true
  modalError.value = ''
  const requestPayload = { ...payload, feature_key: 'general_waitlist' }
  const result = await store.dispatch('comingSoon/notify', requestPayload)
  modalLoading.value = false
  if (result) {
    closeModal()
    toast.success(t('toast.notifySuccess'), t('toast.notifySuccessBody'))
  } else {
    modalError.value = store.state.comingSoon.error || 'Something went wrong.'
  }
}

onMounted(async () => {
  await store.dispatch('auth/fetchMe')
})
</script>
