<template>
  <div class="min-h-screen w-full bg-slate-50 lg:grid lg:h-screen lg:max-h-screen lg:grid-cols-[272px_minmax(0,1fr)] lg:overflow-hidden">
    <Transition
      enter-active-class="transition-opacity duration-300"
      enter-from-class="opacity-0"
      enter-to-class="opacity-100"
      leave-active-class="transition-opacity duration-200"
      leave-from-class="opacity-100"
      leave-to-class="opacity-0"
    >
      <div
        v-if="isOpen"
        class="fixed inset-0 z-40 bg-ink/60 backdrop-blur-sm lg:hidden"
        aria-hidden="true"
        @click="close"
      />
    </Transition>

    <aside
      class="fixed inset-y-0 left-0 z-50 flex w-[min(280px,85vw)] flex-col border-r border-white/5 bg-gradient-to-b from-ink via-[#111827] to-[#0b1220] text-white transition-transform duration-300 ease-out lg:relative lg:z-auto lg:flex lg:h-full lg:w-full lg:max-w-none lg:translate-x-0"
      :class="isOpen ? 'translate-x-0' : '-translate-x-full lg:translate-x-0'"
      :aria-hidden="!isOpen ? 'true' : undefined"
    >
      <div class="pointer-events-none absolute -left-10 top-20 size-40 rounded-full bg-brand/20 blur-3xl" />

      <div class="relative shrink-0 border-b border-white/5 p-5">
        <div class="flex items-center justify-between gap-3">
          <RouterLink class="flex min-w-0 items-center gap-3" to="/" @click="close">
            <span class="grid size-10 shrink-0 place-items-center rounded-xl bg-brand text-lg font-bold text-white shadow-lg shadow-brand/30">C</span>
            <div class="min-w-0">
              <p class="truncate text-lg font-bold leading-tight">{{ t('brand') }}</p>
              <p class="text-[10px] font-semibold uppercase tracking-widest text-slate-400">{{ t('nav.workspace') }}</p>
            </div>
          </RouterLink>
          <button
            type="button"
            class="grid size-9 shrink-0 place-items-center rounded-lg text-slate-400 transition hover:bg-white/10 hover:text-white lg:hidden"
            aria-label="Close menu"
            @click="close"
          >
            <svg class="size-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M18 6L6 18M6 6l12 12" /></svg>
          </button>
        </div>
      </div>

      <nav class="relative flex-1 overflow-y-auto overscroll-contain p-5">
        <p class="text-[10px] font-bold uppercase tracking-widest text-slate-500">{{ t('nav.menu') }}</p>
        <div class="mt-3 grid gap-1.5">
          <RouterLink
            v-for="item in navItems"
            :key="item.to"
            :to="item.to"
            class="group flex items-center gap-3 rounded-xl px-3 py-2.5 text-sm font-medium transition"
            :class="isActive(item.to) ? 'bg-brand/20 text-white ring-1 ring-brand/30 shadow-glow' : 'text-slate-400 hover:bg-white/5 hover:text-white'"
            @click="close"
          >
            <NavIcon :name="item.icon" />
            <span>{{ item.label }}</span>
            <span v-if="isActive(item.to)" class="ml-auto size-1.5 rounded-full bg-mint" />
          </RouterLink>
        </div>
      </nav>

      <div class="relative shrink-0 space-y-3 border-t border-white/10 p-5">
        <RouterLink class="block overflow-hidden rounded-2xl border border-brand/25 bg-gradient-to-br from-brand/20 to-brand/5 p-4 transition hover:border-brand/40" to="/coming-soon" @click="close">
          <p class="text-xs font-bold uppercase tracking-wider text-brand">{{ t('nav.comingSoon') }}</p>
          <p class="mt-1 text-sm text-slate-300">{{ t('dashboard.upgradeTeaser') }}</p>
          <span class="mt-3 inline-flex text-xs font-semibold text-mint">{{ t('dashboard.exploreRoadmap') }} →</span>
        </RouterLink>

        <div class="flex items-center gap-3">
          <span class="grid size-10 shrink-0 place-items-center overflow-hidden rounded-full bg-gradient-to-br from-brand to-indigo-600 text-sm font-bold">
            <img v-if="user?.avatar" :src="user.avatar" alt="" class="size-full object-cover" />
            <template v-else>{{ initials }}</template>
          </span>
          <div class="min-w-0 flex-1">
            <div class="flex items-center gap-2">
              <p class="truncate text-sm font-semibold">{{ user?.full_name || user?.username || user?.email }}</p>
              <div v-if="user?.verified" class="size-2 shrink-0 rounded-full bg-green-500" title="Verified" />
              <div v-else class="size-2 shrink-0 rounded-full bg-red-500" title="Pending / Not Verified" />
            </div>
            <p class="truncate text-xs text-slate-400">{{ user?.email }}</p>
          </div>
        </div>
        <button class="w-full rounded-xl bg-white px-3 py-2.5 text-sm font-semibold text-ink transition hover:bg-slate-100" @click="logout">{{ t('nav.logout') }}</button>
      </div>
    </aside>

    <div class="flex min-h-screen w-full min-w-0 flex-col lg:h-full lg:min-h-0 lg:overflow-hidden" :class="isComingSoon ? 'bg-surface' : ''">
      <header v-if="!isComingSoon" class="sticky top-0 z-30 shrink-0 border-b border-slate-200 bg-white/90 px-4 py-3 backdrop-blur sm:px-5 lg:static lg:px-8">
        <div class="flex items-center gap-3">
          <button
            type="button"
            class="grid size-10 shrink-0 place-items-center rounded-xl border border-slate-200 bg-white text-ink shadow-sm transition hover:bg-slate-50 lg:hidden"
            aria-label="Open menu"
            @click="open"
          >
            <svg class="size-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M4 6h16M4 12h16M4 18h16" /></svg>
          </button>
          <p class="min-w-0 truncate text-sm font-semibold text-ink sm:text-base">{{ pageTitle }}</p>
        </div>
      </header>

      <header v-else class="sticky top-0 z-30 shrink-0 border-b border-white/10 bg-surface/95 px-4 py-3 backdrop-blur sm:px-5 lg:static lg:px-8">
        <div class="flex items-center gap-3">
          <button
            type="button"
            class="grid size-10 shrink-0 place-items-center rounded-xl border border-white/10 bg-white/5 text-white transition hover:bg-white/10 lg:hidden"
            aria-label="Open menu"
            @click="open"
          >
            <svg class="size-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M4 6h16M4 12h16M4 18h16" /></svg>
          </button>
          <p class="min-w-0 truncate text-sm font-semibold text-white sm:text-base">{{ pageTitle }}</p>
        </div>
      </header>

      <main
        class="min-w-0 flex-1 lg:overflow-y-auto lg:overscroll-contain"
        :class="isComingSoon ? 'w-full p-0' : 'w-full p-4 sm:p-5 lg:p-8'"
      >
        <slot />
      </main>
    </div>
  </div>
</template>

<script setup>
import { computed } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ROUTE_NAMES } from '../../constants/routes'
import { useStore } from 'vuex'
import NavIcon from '../ui/NavIcon.vue'
import { toast } from '../../utils/toast'
import { t } from '../../utils/i18n'
import { useMobileNav } from '../../composables/useMobileNav'

const route = useRoute()
const router = useRouter()
const store = useStore()
const { isOpen, open, close } = useMobileNav()
const user = computed(() => store.state.auth.user)
const isComingSoon = computed(() => route.name === ROUTE_NAMES.COMING_SOON)

const navItems = computed(() => [
  { to: '/', icon: 'dashboard', label: 'Home' },
  { to: '/dashboard', icon: 'dashboard', label: t('nav.dashboard') },
  ...(['admin', 'super_admin'].includes(user.value?.role) ? [{ to: '/admin', icon: 'admin', label: 'Admin' }] : []),
  { to: '/resumes', icon: 'resumes', label: t('nav.resumes') },
  { to: '/profile', icon: 'profile', label: t('nav.profile') },
  { to: '/settings', icon: 'settings', label: t('nav.settings') },
  { to: '/coming-soon', icon: 'coming-soon', label: t('nav.comingSoon') }
])

const pageTitle = computed(() => ({
  [ROUTE_NAMES.DASHBOARD]: t('nav.dashboard'),
  [ROUTE_NAMES.ADMIN]: 'Super Admin',
  [ROUTE_NAMES.RESUMES]: t('resumes.title'),
  [ROUTE_NAMES.RESUME_NEW]: t('resumes.new'),
  [ROUTE_NAMES.RESUME_EDIT]: t('resumes.edit'),
  [ROUTE_NAMES.COMING_SOON]: t('nav.comingSoon'),
  [ROUTE_NAMES.PROFILE]: t('nav.profile'),
  [ROUTE_NAMES.SETTINGS]: t('nav.settings')
}[route.name] || t('brand')))

const initials = computed(() => {
  const name = user.value?.full_name || user.value?.username || user.value?.email || 'U'
  return name.split(' ').map((p) => p[0]).join('').slice(0, 2).toUpperCase()
})

const isActive = (path) => route.path === path || route.path.startsWith(`${path}/`)

const logout = async () => {
  close()
  await store.dispatch('auth/logout')
  toast.info(t('toast.logout'), t('toast.logoutBody'))
  router.push('/')
}
</script>
