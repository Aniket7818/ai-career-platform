<template>
  <header class="sticky top-0 z-20 w-full max-w-full border-b border-slate-100 bg-white/90 backdrop-blur">
    <div class="page-container flex items-center justify-between gap-3 py-3 sm:py-4">
      <RouterLink class="flex min-w-0 items-center gap-2 text-lg font-bold sm:text-xl" to="/">
        <span class="grid size-9 shrink-0 place-items-center rounded-md bg-brand text-white">C</span>
        <span class="truncate">{{ t('brand') }}</span>
      </RouterLink>

      <nav class="hidden items-center gap-5 text-sm md:flex">
        <a class="text-slate-600 transition hover:text-ink" href="/#features">{{ t('nav.features') }}</a>
        <RouterLink class="text-slate-600 transition hover:text-ink" to="/coming-soon">{{ t('nav.comingSoon') }}</RouterLink>
        <template v-if="user">
          <RouterLink class="text-slate-700 transition hover:text-ink" to="/dashboard">{{ t('nav.dashboard') }}</RouterLink>
          <RouterLink v-if="['admin', 'super_admin'].includes(user.role)" class="inline-flex items-center gap-1.5 rounded-md border border-brand/30 bg-brand/5 px-3 py-2 font-semibold text-brand transition hover:bg-brand/10" to="/admin">
            <svg class="size-3.5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z" /></svg>
            Admin
          </RouterLink>
        </template>
        <RouterLink v-else class="text-slate-700 transition hover:text-ink" to="/login">{{ t('nav.login') }}</RouterLink>
        <button v-if="user" class="rounded-md bg-ink px-4 py-2 font-semibold text-white transition hover:bg-slate-800" @click="logout">{{ t('nav.logout') }}</button>
        <RouterLink v-else class="rounded-md bg-brand px-4 py-2 font-semibold text-white shadow-lg shadow-brand/20 transition hover:bg-brand/90" to="/signup">{{ t('nav.signup') }}</RouterLink>
      </nav>

      <button
        type="button"
        class="grid size-10 shrink-0 place-items-center rounded-xl border border-slate-200 bg-white text-ink shadow-sm transition hover:bg-slate-50 md:hidden"
        :aria-expanded="isOpen"
        aria-label="Toggle menu"
        @click="toggle"
      >
        <svg v-if="!isOpen" class="size-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M4 6h16M4 12h16M4 18h16" /></svg>
        <svg v-else class="size-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M18 6L6 18M6 6l12 12" /></svg>
      </button>
    </div>

    <Transition
      enter-active-class="transition-all duration-300 ease-out"
      enter-from-class="opacity-0 -translate-y-2"
      enter-to-class="opacity-100 translate-y-0"
      leave-active-class="transition-all duration-200 ease-in"
      leave-from-class="opacity-100 translate-y-0"
      leave-to-class="opacity-0 -translate-y-2"
    >
      <div v-if="isOpen" class="border-t border-slate-100 bg-white px-5 py-4 shadow-lg md:hidden">
        <nav class="flex flex-col gap-1">
          <a class="block rounded-xl px-4 py-3 text-sm font-medium text-slate-700 transition hover:bg-slate-50" href="/#features" @click="close">{{ t('nav.features') }}</a>
          <RouterLink class="block rounded-xl px-4 py-3 text-sm font-medium text-slate-700 transition hover:bg-slate-50" to="/coming-soon" @click="close">{{ t('nav.comingSoon') }}</RouterLink>
          <template v-if="user">
            <RouterLink class="block rounded-xl px-4 py-3 text-sm font-medium text-slate-700 transition hover:bg-slate-50" to="/dashboard" @click="close">{{ t('nav.dashboard') }}</RouterLink>
            <RouterLink v-if="['admin', 'super_admin'].includes(user.role)" class="block rounded-xl px-4 py-3 text-sm font-medium text-brand transition hover:bg-brand/5" to="/admin" @click="close">Admin</RouterLink>
            <button class="mt-2 block w-full rounded-xl bg-ink px-4 py-3 text-sm font-semibold text-white" @click="logout">{{ t('nav.logout') }}</button>
          </template>
          <template v-else>
            <RouterLink class="block rounded-xl px-4 py-3 text-sm font-medium text-slate-700 transition hover:bg-slate-50" to="/login" @click="close">{{ t('nav.login') }}</RouterLink>
            <RouterLink class="mt-2 block rounded-xl bg-brand px-4 py-3 text-center text-sm font-semibold text-white shadow-lg shadow-brand/20" to="/signup" @click="close">{{ t('nav.signup') }}</RouterLink>
          </template>
        </nav>
      </div>
    </Transition>
  </header>
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
