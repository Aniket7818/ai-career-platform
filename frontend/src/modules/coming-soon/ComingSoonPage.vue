<template>
  <component :is="wrapper">
    <div class="min-h-full w-full max-w-full bg-background text-txt-primary pb-20">
      <!-- Guest Header -->
      <div v-if="!user" class="w-full border-b border-border bg-surface/90 backdrop-blur sticky top-0 z-50">
        <div class="page-container flex items-center justify-between gap-3 py-3 sm:py-4 px-4 max-w-6xl mx-auto">
          <RouterLink class="flex min-w-0 items-center gap-2 text-lg font-bold text-txt-primary sm:text-xl" to="/">
            <span class="grid size-9 shrink-0 place-items-center rounded-md bg-brand text-white">C</span>
            <span class="truncate">{{ t('brand') }}</span>
          </RouterLink>
          <nav class="hidden items-center gap-4 text-sm md:flex">
            <RouterLink class="text-txt-muted hover:text-txt-primary transition-colors" to="/">{{ t('nav.features') }}</RouterLink>
            <RouterLink class="text-txt-muted hover:text-txt-primary transition-colors" to="/coming-soon">{{ t('nav.comingSoon') }}</RouterLink>
            <RouterLink class="rounded-md bg-brand px-4 py-2 font-semibold text-white hover:bg-brand/90 transition-colors" to="/login">{{ t('nav.login') }}</RouterLink>
          </nav>
          <button type="button" class="grid size-10 shrink-0 place-items-center rounded-xl border border-border text-txt-primary transition hover:bg-surface-hover md:hidden" :aria-expanded="guestMenuOpen" @click="guestMenuOpen = !guestMenuOpen">
            <svg v-if="!guestMenuOpen" class="size-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M4 6h16M4 12h16M4 18h16" /></svg>
            <svg v-else class="size-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M18 6L6 18M6 6l12 12" /></svg>
          </button>
        </div>
        <div v-if="guestMenuOpen" class="border-t border-border px-4 py-4 md:hidden">
          <nav class="flex flex-col gap-1">
            <RouterLink class="rounded-xl px-4 py-3 text-sm font-medium text-txt-muted transition hover:bg-surface-hover hover:text-txt-primary" to="/" @click="guestMenuOpen = false">{{ t('nav.features') }}</RouterLink>
            <RouterLink class="rounded-xl px-4 py-3 text-sm font-medium text-txt-muted transition hover:bg-surface-hover hover:text-txt-primary" to="/coming-soon" @click="guestMenuOpen = false">{{ t('nav.comingSoon') }}</RouterLink>
            <RouterLink class="mt-2 block rounded-xl bg-brand px-4 py-3 text-center text-sm font-semibold text-white" to="/login" @click="guestMenuOpen = false">{{ t('nav.login') }}</RouterLink>
          </nav>
        </div>
      </div>

      <div class="space-y-16 py-10 sm:py-16 lg:py-20 px-4 max-w-6xl mx-auto">

        <!-- HERO -->
        <section class="text-center max-w-3xl mx-auto">
          <p class="inline-flex items-center gap-2 rounded-full border border-brand/30 bg-brand/10 px-3 py-1 text-xs font-semibold uppercase tracking-wider text-brand mb-6">
            <span class="relative flex size-2">
              <span class="absolute inline-flex size-full animate-ping rounded-full bg-brand opacity-75" />
              <span class="relative inline-flex size-2 rounded-full bg-brand" />
            </span>
            Product Roadmap
          </p>
          <h1 class="text-4xl font-extrabold tracking-tight sm:text-5xl lg:text-6xl text-txt-primary leading-tight">
            Building the Future of Careers
          </h1>
          <p class="mt-6 text-base sm:text-lg text-txt-muted leading-relaxed">
            See what's live today, what's actively being built, and what's coming next on our journey to create the ultimate AI career platform.
          </p>
        </section>

        <!-- SECTION 1: Live & Available -->
        <section>
          <div class="flex items-center gap-3 mb-6">
            <div class="flex size-10 items-center justify-center rounded-xl bg-emerald-50 text-emerald-600 border border-emerald-100">
              <svg class="size-5" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2"><path stroke-linecap="round" stroke-linejoin="round" d="M5 13l4 4L19 7" /></svg>
            </div>
            <div>
              <h2 class="text-xl sm:text-2xl font-bold text-txt-primary">Live & Available Now</h2>
              <p class="text-xs text-txt-muted mt-0.5">All features below are fully built and usable today</p>
            </div>
          </div>
          <div class="grid gap-3 grid-cols-1 sm:grid-cols-2 lg:grid-cols-3">
            <div v-for="feature in liveFeatures" :key="feature.label" class="flex items-start gap-3.5 rounded-2xl border border-border/85 bg-surface p-4 transition-all hover:bg-surface-hover hover:border-border hover:shadow-xs">
              <div class="grid size-9 shrink-0 place-items-center rounded-xl bg-emerald-50 text-emerald-600 mt-0.5">
                <span class="text-base">{{ feature.icon }}</span>
              </div>
              <div class="min-w-0">
                <p class="font-bold text-txt-primary text-sm">{{ feature.label }}</p>
                <p class="text-[11px] text-txt-muted mt-0.5 leading-relaxed">{{ feature.desc }}</p>
              </div>
            </div>
          </div>
        </section>

        <!-- SECTION 2: Coming Next (AI features in active development) -->
        <section>
          <div class="flex items-center gap-3 mb-6">
            <div class="flex size-10 items-center justify-center rounded-xl bg-brand/10 text-brand border border-brand/20">
              <svg class="size-5" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2"><path stroke-linecap="round" stroke-linejoin="round" d="M13 10V3L4 14h7v7l9-11h-7z" /></svg>
            </div>
            <div>
              <h2 class="text-xl sm:text-2xl font-bold text-txt-primary">In Active Development</h2>
              <p class="text-xs text-txt-muted mt-0.5">Currently being built — launching very soon</p>
            </div>
          </div>
          <div class="grid gap-5 grid-cols-1 md:grid-cols-3">
            <div v-for="feature in inDevelopment" :key="feature.title" class="group relative overflow-hidden rounded-2xl border border-border/80 bg-surface p-5 sm:p-6 transition-all hover:-translate-y-1 hover:border-brand/30 hover:shadow-sm">
              <div class="absolute right-0 top-0 h-28 w-28 translate-x-8 -translate-y-8 rounded-full bg-brand/5 blur-3xl group-hover:bg-brand/10 transition-all" />
              <div class="relative">
                <div class="flex items-center gap-2 mb-3">
                  <span class="text-xl">{{ feature.icon }}</span>
                  <span class="rounded-full bg-brand/10 text-brand text-[10px] font-bold px-2 py-0.5 uppercase tracking-wider">In Dev</span>
                </div>
                <h3 class="text-base sm:text-lg font-extrabold text-txt-primary">{{ feature.title }}</h3>
                <p class="mt-2 text-xs sm:text-sm leading-relaxed text-txt-muted">{{ feature.description }}</p>
              </div>
            </div>
          </div>
        </section>

        <!-- SECTION 3: Planned -->
        <section>
          <div class="flex items-center gap-3 mb-6">
            <div class="flex size-10 items-center justify-center rounded-xl bg-purple-50 text-purple-600 border border-purple-100">
              <svg class="size-5" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2"><path stroke-linecap="round" stroke-linejoin="round" d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z" /></svg>
            </div>
            <div>
              <h2 class="text-xl sm:text-2xl font-bold text-txt-primary">Planned & Coming Later</h2>
              <p class="text-xs text-txt-muted mt-0.5">On our roadmap for future phases</p>
            </div>
          </div>
          <div class="grid gap-3 grid-cols-1 sm:grid-cols-2 lg:grid-cols-3">
            <div v-for="feature in planned" :key="feature.label" class="flex items-start gap-3.5 rounded-2xl border border-border/60 bg-surface/60 p-4 opacity-80 hover:opacity-100 transition-all">
              <div class="grid size-9 shrink-0 place-items-center rounded-xl bg-slate-50 text-slate-400 mt-0.5">
                <span class="text-base">{{ feature.icon }}</span>
              </div>
              <div class="min-w-0">
                <p class="font-bold text-txt-secondary text-sm">{{ feature.label }}</p>
                <p class="text-[11px] text-txt-muted mt-0.5 leading-relaxed">{{ feature.desc }}</p>
              </div>
            </div>
          </div>
        </section>

        <!-- SECTION 4: Roadmap Timeline -->
        <section>
          <div class="flex items-center gap-3 mb-6">
            <div class="flex size-10 items-center justify-center rounded-xl bg-slate-100 text-slate-600 border border-slate-200">
              <svg class="size-5" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2"><path stroke-linecap="round" stroke-linejoin="round" d="M9 20l-5.447-2.724A1 1 0 013 16.382V5.618a1 1 0 011.447-.894L9 7m0 13l6-3m-6 3V7m6 10l4.553 2.276A1 1 0 0021 18.382V7.618a1 1 0 00-.553-.894L15 4m0 13V4m0 0L9 7" /></svg>
            </div>
            <h2 class="text-xl sm:text-2xl font-bold text-txt-primary">Roadmap</h2>
          </div>
          <div class="relative ml-5 border-l-2 border-border space-y-10 pb-6 pt-2">
            <div v-for="phase in roadmap" :key="phase.name" class="relative pl-8">
              <div class="absolute -left-[9px] top-1.5 size-4 rounded-full border-4 border-background" :class="phase.color"></div>
              <div class="flex flex-wrap items-center gap-3 mb-2">
                <h3 class="text-base sm:text-lg font-bold text-txt-primary">{{ phase.name }}</h3>
                <span class="rounded-full border px-2.5 py-0.5 text-xs font-semibold" :class="phase.badgeColor">{{ phase.status }}</span>
              </div>
              <p class="text-txt-muted text-xs sm:text-sm max-w-2xl leading-relaxed">{{ phase.description }}</p>
            </div>
          </div>
        </section>

        <!-- SECTION 5: Join Waitlist -->
        <section class="relative overflow-hidden rounded-[2rem] border border-border/80 bg-gradient-to-br from-brand/5 via-brand/10 to-transparent p-8 sm:p-14 text-center">
          <div class="absolute -right-20 -top-20 size-64 rounded-full bg-brand/5 blur-3xl" />
          <div class="absolute -bottom-12 -left-12 size-48 rounded-full bg-mint/5 blur-3xl" />
          <div class="relative z-10 mx-auto max-w-xl">
            <h2 class="text-2xl sm:text-3xl font-extrabold text-txt-primary">Be the first to know</h2>
            <p class="mt-3 text-sm sm:text-base text-txt-muted leading-relaxed">Join our waitlist and get notified the moment new AI features go live. No spam — just product updates.</p>
            <div class="mt-7">
              <button type="button" class="inline-flex h-12 sm:h-14 items-center justify-center rounded-xl bg-brand px-8 text-sm sm:text-base font-semibold text-white transition-all hover:bg-brand/90 hover:shadow-lg hover:shadow-brand/20 active:scale-95" @click="openWaitlistModal">
                Join Waitlist
              </button>
            </div>
          </div>
        </section>
      </div>

      <NotifyMeModal :open="modalOpen" feature-key="general_waitlist" :loading="modalLoading" :error="modalError" :default-email="user?.email || ''" @close="closeModal" @submit="submitNotify" />
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

// ── LIVE FEATURES ─────────────────────────────────────────────────────
const liveFeatures = [
  { icon: '📝', label: 'Resume Builder', desc: 'Multi-section resume editor with real-time preview and form validation.' },
  { icon: '🎨', label: '5 ATS Templates', desc: 'Modern, Minimal, Professional, Executive, and Fresher templates.' },
  { icon: '📄', label: 'Smart Pagination', desc: 'Auto page-break detection and multi-page resume layout support.' },
  { icon: '⬇️', label: 'PDF Export', desc: 'High-fidelity PDF download with pixel-perfect print rendering.' },
  { icon: '👁️', label: 'Live Preview', desc: 'Side-by-side live preview that updates as you type.' },
  { icon: '🎯', label: 'Resume Customization', desc: 'Custom fonts, colors, spacing, and section ordering.' },
  { icon: '🤖', label: 'AI Resume Analysis', desc: 'Deep AI scoring of ATS, content quality, keywords, and completeness.' },
  { icon: '💯', label: 'Resume Health Score', desc: 'Animated health score with breakdown by section quality.' },
  { icon: '✅', label: 'Resume Checklist', desc: 'Real-time actionable checklist of missing and weak resume elements.' },
  { icon: '🔑', label: 'Keyword Analysis', desc: 'Target-role keyword detection with coverage % and missing keyword list.' },
  { icon: '🛡️', label: 'ATS Score & Rules', desc: 'Detailed ATS rule-by-rule pass/fail analysis with fix recommendations.' },
  { icon: '✍️', label: 'AI Professional Summary', desc: 'One-click AI generation of a targeted professional summary.' },
  { icon: '💼', label: 'AI Experience Rewriter', desc: 'AI-powered bullet point rewriter for impactful work experience.' },
  { icon: '⚡', label: 'AI Skills Optimizer', desc: 'Suggests missing industry keywords and skill categories via AI.' },
  { icon: '🚀', label: 'AI Project Optimizer', desc: 'AI rewrites project descriptions with stronger impact statements.' },
  { icon: '📋', label: 'AI Cover Letter', desc: 'Generates a personalized, job-specific cover letter from your resume.' },
  { icon: '🔗', label: 'LinkedIn Optimizer', desc: 'AI-crafted LinkedIn "About" section and professional headline.' },
  { icon: '🎯', label: 'Tailor to Job Description', desc: 'Paste any JD and AI rewrites your resume to match it perfectly.' },
  { icon: '🕐', label: 'Version History', desc: 'Full version history with snapshot restore and diff comparison.' },
  { icon: '🎤', label: 'Interview Preparation', desc: 'AI-curated Q&A library by subject, difficulty, and role.' },
  { icon: '📊', label: 'Dashboard & Analytics', desc: 'Overview of resumes, credits, AI usage, and account activity.' },
  { icon: '💳', label: 'Subscription & Credits', desc: 'Tiered subscription plans (Free, Plus, Pro) with AI credit system.' },
  { icon: '👤', label: 'Profile & Settings', desc: 'Full account management with categorized profile and notification prefs.' },
  { icon: '🔒', label: 'Security & Auth', desc: 'Email verification, password reset, and secure session management.' },
]

// ── IN ACTIVE DEVELOPMENT ─────────────────────────────────────────────
const inDevelopment = [
  {
    icon: '🗂️',
    title: 'AI Content Review',
    description: 'Per-section deep content review with specific rewrite suggestions, redundancy detection, and grammar improvements.'
  },
  {
    icon: '🧩',
    title: 'Job Match Score',
    description: 'Paste a job description and get a live match % score that highlights gaps between your profile and the role requirements.'
  },
  {
    icon: '🎙️',
    title: 'AI Mock Interviews',
    description: 'Real-time interview simulation with AI-generated role-specific questions and instant answer feedback.'
  },
]

// ── PLANNED FEATURES ─────────────────────────────────────────────────
const planned = [
  { icon: '🗺️', label: 'Career Roadmap Generator', desc: 'AI-driven skill gap analysis and personalized career path planning.' },
  { icon: '🌐', label: 'Portfolio Website Builder', desc: 'Auto-generate a hosted personal portfolio from your resume data.' },
  { icon: '📌', label: 'Job Application Tracker', desc: 'Track every job you apply to — status, contacts, notes, and follow-ups.' },
  { icon: '🔍', label: 'LinkedIn Profile Review', desc: 'Full audit of your LinkedIn profile with rewrite suggestions and keywords.' },
  { icon: '🏆', label: 'Advanced Placement Hub', desc: 'Placement resources, mock assessments, and company-specific prep guides.' },
  { icon: '📧', label: 'Cold Email Generator', desc: 'AI-generated outreach emails for recruiters and hiring managers.' },
]

// ── ROADMAP PHASES ─────────────────────────────────────────────────────
const roadmap = [
  {
    name: 'Phase 1 — Foundation',
    status: 'Completed',
    color: 'bg-emerald-500',
    badgeColor: 'bg-emerald-50 text-emerald-700 border-emerald-200',
    description: 'Core resume builder, 5 ATS templates, smart pagination, PDF export, live preview, and full account + subscription system.'
  },
  {
    name: 'Phase 2 — AI Intelligence',
    status: 'Completed',
    color: 'bg-emerald-500',
    badgeColor: 'bg-emerald-50 text-emerald-700 border-emerald-200',
    description: 'Full AI toolkit: resume health scoring, ATS analysis, keyword engine, AI rewriter for summary, experience, skills, projects, cover letter, and LinkedIn optimizer.'
  },
  {
    name: 'Phase 3 — Deep Insights',
    status: 'In Progress',
    color: 'bg-brand',
    badgeColor: 'bg-brand/10 text-brand border-brand/20',
    description: 'AI content review per section, job description match scoring, and AI mock interview simulation with real-time feedback.'
  },
  {
    name: 'Phase 4 — Career Ecosystem',
    status: 'Planned',
    color: 'bg-slate-400',
    badgeColor: 'bg-slate-50 text-slate-600 border-slate-200',
    description: 'LinkedIn profile review, portfolio website generation, career roadmap planner, and automated placement preparation hub.'
  },
  {
    name: 'Phase 5 — Full Platform',
    status: 'Future',
    color: 'bg-slate-300',
    badgeColor: 'bg-slate-100 text-slate-500 border-slate-200',
    description: 'Job application tracking, cold email generator, company-specific prep guides, and advanced career intelligence analytics.'
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
