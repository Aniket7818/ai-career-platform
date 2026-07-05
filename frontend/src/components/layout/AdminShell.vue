<template>
 <div class="min-h-screen w-full min-w-0 bg-[#0b0f17] text-slate-200 lg:grid lg:h-screen lg:max-h-screen lg:grid-cols-[260px_minmax(0,1fr)] lg:overflow-hidden">
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
 class="fixed inset-0 z-40 bg-black/70 backdrop-blur-sm lg:hidden"
 aria-hidden="true"
 @click="close"
 />
 </Transition>

 <aside
 class="fixed inset-y-0 left-0 z-50 flex w-[min(280px,85vw)] flex-col border-r border-white/5 bg-[#0a0d14] transition-transform duration-300 ease-out lg:relative lg:z-auto lg:flex lg:h-full lg:w-full lg:max-w-none lg:translate-x-0"
 :class="isOpen ? 'translate-x-0' : '-translate-x-full lg:translate-x-0'"
 >
 <div class="flex items-center justify-between gap-3 border-b border-white/5 p-5">
 <RouterLink class="flex min-w-0 items-center gap-3" to="/admin" @click="close">
 <span class="grid size-10 shrink-0 place-items-center rounded-xl bg-gradient-to-br from-brand to-indigo-600 text-lg font-bold text-white shadow-lg shadow-brand/30">C</span>
 <div class="min-w-0">
 <p class="truncate text-base font-bold text-white">{{ t('brand') }}</p>
 <p class="text-[10px] font-bold uppercase tracking-[0.2em] text-brand">Super Admin</p>
 </div>
 </RouterLink>
 <button
 type="button"
 class="grid size-9 shrink-0 place-items-center rounded-lg text-txt-disabled transition hover:bg-surface/10 hover:text-white lg:hidden"
 aria-label="Close menu"
 @click="close"
 >
 <svg class="size-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M18 6L6 18M6 6l12 12" /></svg>
 </button>
 </div>

 <nav class="flex-1 space-y-1 overflow-y-auto p-4">
 <component
 :is="item.route ? 'router-link' : 'a'"
 v-for="item in navItems"
 :key="item.id"
 :to="item.route"
 :href="!item.route ? (item.href.startsWith('#') && $route.path !== '/admin' ? '/admin' + item.href : item.href) : undefined"
 class="flex items-center gap-3 rounded-xl px-3 py-2.5 text-sm font-medium transition"
 :class="(item.route && $route.path === item.route) || (!item.route && activeSection === item.id) ? 'bg-brand/20 text-white ring-1 ring-brand/40' : 'text-txt-disabled hover:bg-surface/5 hover:text-white'"
 @click="item.route ? close() : handleHashClick($event, item)"
 >
 <component :is="item.icon" class="size-4 shrink-0" />
 {{ item.label }}
 </component>
 <RouterLink class="mt-4 flex items-center gap-3 rounded-xl px-3 py-2.5 text-sm font-medium text-txt-disabled transition hover:bg-surface/5 hover:text-white" to="/dashboard" @click="close">
 <svg class="size-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M19 12H5M12 19l-7-7 7-7" /></svg>
 Back to App
 </RouterLink>
 </nav>

 <div class="border-t border-white/5 p-4">
 <div class="flex items-center gap-3 rounded-xl bg-surface/5 p-3">
 <span class="grid size-9 shrink-0 place-items-center overflow-hidden rounded-full bg-brand/30 text-xs font-bold text-white">
 <img v-if="user?.avatar" :src="user.avatar" alt="" class="size-full object-cover" />
 <template v-else>{{ initials }}</template>
 </span>
 <div class="min-w-0 flex-1">
 <p class="truncate text-sm font-semibold text-white">{{ user?.full_name || user?.username }}</p>
 <p class="truncate text-xs text-txt-muted">Super Admin</p>
 </div>
 </div>
 </div>
 </aside>

 <div class="flex min-h-screen w-full min-w-0 flex-col lg:h-full lg:min-h-0 lg:overflow-hidden">
 <header class="sticky top-0 z-30 shrink-0 border-b border-white/5 bg-[#0b0f17]/90 px-4 py-3 backdrop-blur sm:px-5 sm:py-4 lg:static lg:px-8">
 <div class="flex flex-col gap-3 sm:gap-4 lg:flex-row lg:items-center lg:justify-between">
 <div class="flex items-center gap-3">
 <button
 type="button"
 class="grid size-10 shrink-0 place-items-center rounded-xl border border-white/10 bg-surface/5 text-white transition hover:bg-surface/10 lg:hidden"
 aria-label="Open menu"
 @click="open"
 >
 <svg class="size-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M4 6h16M4 12h16M4 18h16" /></svg>
 </button>
 <div class="relative min-w-0 flex-1 lg:max-w-md">
 <svg class="pointer-events-none absolute left-3 top-1/2 size-4 -translate-y-1/2 text-txt-muted" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="11" cy="11" r="8" /><path d="M21 21l-4.35-4.35" /></svg>
 <input
 :value="searchQuery"
 class="w-full rounded-xl border border-white/10 bg-surface/5 py-2.5 pl-10 pr-4 text-sm text-white outline-none transition placeholder:text-txt-muted focus:border-brand/50 focus:ring-2 focus:ring-brand/20"
 placeholder="Search users, emails, roles..."
 @input="$emit('search', $event.target.value)"
 />
 </div>
 </div>
 <div class="flex flex-wrap items-center gap-2">
 <slot name="actions" />
 </div>
 </div>
 </header>
 <main class="min-w-0 flex-1 lg:overflow-y-auto lg:overscroll-contain p-4 sm:p-5 lg:p-8"><slot /></main>
 </div>
 </div>
</template>

<script setup>
import { computed, h } from 'vue'
import { useStore } from 'vuex'
import { useRoute, useRouter } from 'vue-router'
import { t } from '../../utils/i18n'
import { useMobileNav } from '../../composables/useMobileNav'

defineProps({
 searchQuery: { type: String, default: '' },
 activeSection: { type: String, default: 'overview' }
})
defineEmits(['search'])

const store = useStore()
const route = useRoute()
const router = useRouter()
const user = computed(() => store.state.auth.user)
const { isOpen, open, close } = useMobileNav()

const icon = (paths) => ({
 render: () => h('svg', { class: 'size-4', viewBox: '0 0 24 24', fill: 'none', stroke: 'currentColor', 'stroke-width': '2' }, paths.map((d) => h('path', { d })))
})

const navItems = [
 { id: 'overview', label: 'Overview', href: '#overview', icon: icon(['M3 3h7v7H3zM14 3h7v7h-7zM3 14h7v7H3zM14 14h7v7h-7z']) },
 { id: 'users', label: 'User Management', href: '#users', icon: icon(['M17 21v-2a4 4 0 00-4-4H5a4 4 0 00-4 4v2', 'M9 11a4 4 0 100-8 4 4 0 000 8z', 'M23 21v-2a4 4 0 00-3-3.87', 'M16 3.13a4 4 0 010 7.75']) },
 { id: 'analytics', label: 'Analytics', href: '#analytics', icon: icon(['M3 3v18h18', 'M7 16l4-8 4 5 5-7']) },
 { id: 'settings', label: 'Settings', href: '#settings', icon: icon(['M12.22 2h-.44a2 2 0 00-2 2v.18a2 2 0 01-1 1.73l-.43.25a2 2 0 01-2 0l-.15-.08a2 2 0 00-2.73.73l-.22.38a2 2 0 00.73 2.73l.15.1a2 2 0 011 1.72v.51a2 2 0 01-1 1.74l-.15.09a2 2 0 00-.73 2.73l.22.38a2 2 0 002.73.73l.15-.08a2 2 0 012 0l.43.25a2 2 0 011 1.73V20a2 2 0 002 2h.44a2 2 0 002-2v-.18a2 2 0 011-1.73l.43-.25a2 2 0 012 0l.15.08a2 2 0 002.73-.73l.22-.39a2 2 0 00-.73-2.73l-.15-.08a2 2 0 01-1-1.74v-.5a2 2 0 011-1.74l.15-.09a2 2 0 00.73-2.73l-.22-.38a2 2 0 00-2.73-.73l-.15.08a2 2 0 01-2 0l-.43-.25a2 2 0 01-1-1.73V4a2 2 0 00-2-2z', 'M12 8a4 4 0 100 8 4 4 0 000-8z']) },
 { id: 'ai-analytics', label: 'AI Analytics', route: '/admin/ai-analytics', icon: icon(['M12 2v4M12 18v4M4.93 4.93l2.83 2.83M16.24 16.24l2.83 2.83M2 12h4M18 12h4M4.93 19.07l2.83-2.83M16.24 7.76l2.83-2.83']) },
 { id: 'audit', label: 'Audit Logs', href: '#audit', icon: icon(['M14 2H6a2 2 0 00-2 2v16a2 2 0 002 2h12a2 2 0 002-2V8z', 'M14 2v6h6', 'M16 13H8', 'M16 17H8']) }
]

const initials = computed(() => {
 const name = user.value?.full_name || user.value?.username || 'A'
 return name.split(' ').map((p) => p[0]).join('').slice(0, 2).toUpperCase()
})

const handleHashClick = (e, item) => {
  if (route.path !== '/admin') {
    e.preventDefault()
    close()
    router.push({ path: '/admin', hash: item.href })
  } else {
    e.preventDefault()
    scrollTo(item.id)
  }
}

const scrollTo = (id) => {
 close()
 document.getElementById(id)?.scrollIntoView({ behavior: 'smooth', block: 'start' })
}
</script>
