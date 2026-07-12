<template>
  <header class="sticky top-0 z-20 w-full max-w-full border-b border-border bg-surface/90 backdrop-blur">
    <div class="page-container flex items-center justify-between gap-3 py-3 sm:py-4">
      <RouterLink class="flex min-w-0 items-center gap-2 text-lg font-bold sm:text-xl" to="/">
        <span class="grid size-9 shrink-0 place-items-center rounded-md bg-brand text-white">C</span>
        <span class="truncate">{{ t('brand') }}</span>
      </RouterLink>

      <nav class="hidden items-center gap-5 text-sm md:flex">
        <RouterLink class="text-txt-secondary transition hover:text-txt-primary" to="/features">{{ t('nav.features') }}</RouterLink>
        <RouterLink class="text-txt-secondary transition hover:text-txt-primary" to="/coming-soon">{{ t('nav.comingSoon') }}</RouterLink>
        <template v-if="user">
          <RouterLink class="text-txt-secondary transition hover:text-txt-primary" to="/dashboard">{{ t('nav.dashboard') }}</RouterLink>
          <RouterLink v-if="['admin', 'super_admin'].includes(user.role)" class="inline-flex items-center gap-1.5 rounded-md border border-brand/30 bg-brand/5 px-3 py-2 font-semibold text-brand transition hover:bg-brand/10" to="/admin">
            <svg class="size-3.5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z" /></svg>
            Admin
          </RouterLink>
        </template>
        <RouterLink v-else class="text-txt-secondary transition hover:text-txt-primary" to="/login">{{ t('nav.login') }}</RouterLink>
        <button v-if="user" class="rounded-md bg-slate-900 px-4 py-2 font-semibold text-white transition hover:bg-slate-800" @click="logout">{{ t('nav.logout') }}</button>
        <RouterLink v-else class="rounded-md bg-brand px-4 py-2 font-semibold text-white shadow-lg shadow-brand/20 transition hover:bg-brand/90" to="/signup">{{ t('nav.signup') }}</RouterLink>
      </nav>

      <button
        type="button"
        class="grid size-10 shrink-0 place-items-center rounded-xl border border-border bg-surface text-txt-primary shadow-sm transition hover:bg-background md:hidden"
        :aria-expanded="isOpen"
        aria-label="Toggle menu"
        @click="toggle"
      >
        <svg v-if="!isOpen" class="size-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M4 6h16M4 12h16M4 18h16" /></svg>
        <svg v-else class="size-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M18 6L6 18M6 6l12 12" /></svg>
      </button>
    </div>
  </header>

  <!-- Fixed full-screen mobile menu overlay — always visible regardless of scroll position -->
  <Transition
    enter-active-class="transition-all duration-300 ease-out"
    enter-from-class="opacity-0 -translate-y-3"
    enter-to-class="opacity-100 translate-y-0"
    leave-active-class="transition-all duration-200 ease-in"
    leave-from-class="opacity-100 translate-y-0"
    leave-to-class="opacity-0 -translate-y-3"
  >
    <div v-if="isOpen" class="fixed inset-x-0 top-0 z-50 md:hidden">
      <!-- Backdrop -->
      <div class="fixed inset-0 bg-slate-900/40 backdrop-blur-sm" @click="close" />
      <!-- Menu panel -->
      <div class="relative bg-surface border-b border-border shadow-xl">
        <!-- Header row inside menu panel -->
        <div class="flex items-center justify-between px-5 py-3 border-b border-border">
          <RouterLink class="flex min-w-0 items-center gap-2 text-lg font-bold" to="/" @click="close">
            <span class="grid size-9 shrink-0 place-items-center rounded-md bg-brand text-white">C</span>
            <span class="truncate">{{ t('brand') }}</span>
          </RouterLink>
          <button type="button" class="grid size-10 shrink-0 place-items-center rounded-xl border border-border text-txt-primary transition hover:bg-background" aria-label="Close menu" @click="close">
            <svg class="size-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M18 6L6 18M6 6l12 12" /></svg>
          </button>
        </div>
        <!-- Nav links -->
        <nav class="flex flex-col gap-1 px-4 py-4">
          <RouterLink class="block rounded-xl px-4 py-3 text-sm font-medium text-txt-secondary transition hover:bg-background" to="/features" @click="close">{{ t('nav.features') }}</RouterLink>
          <RouterLink class="block rounded-xl px-4 py-3 text-sm font-medium text-txt-secondary transition hover:bg-background" to="/coming-soon" @click="close">{{ t('nav.comingSoon') }}</RouterLink>
          <template v-if="user">
            <RouterLink class="block rounded-xl px-4 py-3 text-sm font-medium text-txt-secondary transition hover:bg-background" to="/dashboard" @click="close">{{ t('nav.dashboard') }}</RouterLink>
            <RouterLink v-if="['admin', 'super_admin'].includes(user.role)" class="block rounded-xl px-4 py-3 text-sm font-medium text-brand transition hover:bg-brand/5" to="/admin" @click="close">Admin</RouterLink>
            <button class="mt-2 block w-full rounded-xl bg-slate-900 px-4 py-3 text-sm font-semibold text-white" @click="logout">{{ t('nav.logout') }}</button>
          </template>
          <template v-else>
            <RouterLink class="block rounded-xl px-4 py-3 text-sm font-medium text-txt-secondary transition hover:bg-background" to="/login" @click="close">{{ t('nav.login') }}</RouterLink>
            <RouterLink class="mt-2 block rounded-xl bg-brand px-4 py-3 text-center text-sm font-semibold text-white shadow-lg shadow-brand/20" to="/signup" @click="close">{{ t('nav.signup') }}</RouterLink>
          </template>
        </nav>
      </div>
    </div>
  </Transition>
</template>

<script setup>
import { computed } from 'vue'
import { useRouter } from 'vue-router'
import { useStore } from 'vuex'
import { t } from '../../utils/i18n'
import { useMobileNav } from '../../composables/useMobileNav'

const router = useRouter()
const store = useStore()
const user = computed(() => store.state.auth.user)
const { isOpen, close, toggle } = useMobileNav()

const logout = async () => {
 close()
 await store.dispatch('auth/logout')
 router.push('/')
}
</script>
