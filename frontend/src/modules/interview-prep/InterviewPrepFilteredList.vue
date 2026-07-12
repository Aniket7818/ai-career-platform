<template>
 <AppShell>
  <div class="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-8 animate-fade-in pb-16 relative">
    <!-- Ambient Background Mesh Glows -->
    <div class="absolute top-0 left-1/4 w-72 h-72 bg-brand/5 rounded-full blur-[100px] pointer-events-none -z-10"></div>
    <div class="absolute top-1/3 right-10 w-72 h-72 bg-indigo-500/5 rounded-full blur-[100px] pointer-events-none -z-10"></div>
    <div class="absolute bottom-10 left-10 w-72 h-72 bg-emerald-500/5 rounded-full blur-[100px] pointer-events-none -z-10"></div>
 
 <!-- Breadcrumbs -->
 <nav class="flex text-xs font-bold text-txt-disabled mb-8 uppercase tracking-wider" aria-label="Breadcrumb">
 <ol class="flex flex-wrap items-center gap-2 sm:gap-2.5">
 <li class="flex items-center">
 <RouterLink :to="{ name: 'interview-prep' }" class="hover:text-brand transition-colors flex items-center">
 <span class="leading-none pt-0.5">Dashboard</span>
 </RouterLink>
 </li>
 <li class="flex items-center text-txt-muted">
 <svg class="w-3.5 h-3.5 shrink-0" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="3" d="M9 5l7 7-7 7" /></svg>
 </li>
 <li class="flex items-center">
 <span class="text-txt-primary leading-none pt-0.5">{{ pageTitle }}</span>
 </li>
 </ol>
 </nav>

 <!-- Header Section -->
 <header class="mb-10">
 <div class="flex items-center gap-4 mb-4">
 <div class="w-12 h-12 rounded-2xl flex items-center justify-center shadow-sm" :class="headerIconBgClass">
 <svg class="w-6 h-6" :class="headerIconTextClass" fill="none" viewBox="0 0 24 24" stroke="currentColor" v-html="headerIconPath"></svg>
 </div>
 <div>
 <h1 class="text-3xl font-extrabold text-txt-primary">{{ pageTitle }}</h1>
 <p class="text-sm font-bold text-txt-muted mt-1">{{ filteredItems.length }} Questions</p>
 </div>
 </div>
 </header>

 <div v-if="loading" class="space-y-4">
 <div v-for="i in 5" :key="i" class="h-24 bg-surface-hover animate-pulse rounded-2xl border border-border/50"></div>
 </div>
 
 <!-- List View -->
 <div v-else-if="filteredItems.length > 0" class="space-y-4">
 <div v-for="item in filteredItems" :key="item.questionId" class="group relative block bg-surface rounded-2xl p-5 sm:p-6 shadow-sm border border-border hover:shadow-xl hover:border-border-hover transition-all duration-300 transform hover:-translate-y-0.5 overflow-hidden">
 <!-- Difficulty Left Border -->
 <div class="absolute left-0 top-0 bottom-0 w-1.5 transition-colors"
 :class="{
 'bg-emerald-500': item.difficulty === 'Easy',
 'bg-amber-500': item.difficulty === 'Intermediate',
 'bg-rose-500': item.difficulty === 'Hard',
 'bg-slate-400': !item.difficulty
 }"
 ></div>

 <RouterLink 
 :to="{ name: 'interview-prep-question', params: { subject: item.subjectSlug, question_id: item.questionId } }" 
 class="block focus:outline-none pl-2"
 >
 <div class="flex flex-col sm:flex-row sm:items-center justify-between gap-6">
 <div class="flex-1 min-w-0">
 <!-- Topic & Difficulty Badges -->
 <div class="flex flex-wrap items-center gap-2 mb-3">
 <span class="inline-flex items-center text-[10px] font-black uppercase tracking-wider text-txt-muted bg-surface-hover px-2.5 py-1 rounded-md border border-border/50">
 {{ item.subjectSlug.replace(/_/g, ' ') }}
 </span>
 <span class="inline-flex items-center text-[10px] font-black uppercase tracking-wider px-2.5 py-1 rounded-md border"
 :class="{
 'bg-emerald-50 text-emerald-700 border-emerald-200/50': item.difficulty === 'Easy',
 'bg-amber-50 text-amber-700 border-amber-200/50': item.difficulty === 'Intermediate',
 'bg-rose-50 text-rose-700 border-rose-200/50': item.difficulty === 'Hard',
 'bg-background text-txt-secondary border-border/50': !item.difficulty
 }"
 >
 {{ item.difficulty || 'Mixed' }}
 </span>
 <span v-if="item.topic" class="inline-flex items-center text-[11px] font-bold text-txt-muted bg-surface-hover rounded-md px-2 py-0.5 border border-border/50">
 {{ item.topic }}
 </span>
 </div>

 <!-- Title -->
 <h3 class="text-lg sm:text-xl font-bold text-txt-primary group-hover:text-brand transition-colors line-clamp-2 leading-tight pr-4">
 {{ item.title }}
 </h3>
 </div>

 <!-- Actions -->
 <div class="shrink-0 flex items-center justify-between sm:justify-end border-t sm:border-t-0 border-border pt-4 sm:pt-0">
 <div class="flex items-center gap-4">
 <div v-if="isCompleted(item.subjectSlug, item.questionId)" class="flex items-center gap-1 text-emerald-500 text-xs font-bold bg-emerald-50 px-2 py-1 rounded-lg">
 <svg class="w-3.5 h-3.5" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M5 13l4 4L19 7" /></svg>
 Done
 </div>
 <button class="p-1.5 rounded-lg transition-colors text-amber-500 bg-amber-50 hover:bg-amber-100 shrink-0" v-if="isBookmarked(item.subjectSlug, item.questionId)" @click.stop.prevent="toggleBookmark($event, item.subjectSlug, item.questionId)" title="Remove Bookmark">
 <svg class="w-5 h-5" fill="currentColor" viewBox="0 0 24 24"><path d="M5 5a2 2 0 012-2h10a2 2 0 012 2v16l-7-3.5L5 21V5z" /></svg>
 </button>
 <div class="flex items-center text-brand font-bold text-sm bg-brand/5 px-4 py-2 rounded-xl group-hover:bg-brand group-hover:text-white transition-all shadow-sm shrink-0">
 Solve
 <svg class="w-4 h-4 ml-1.5 group-hover:translate-x-1 transition-transform" fill="none" viewBox="0 0 24 24" stroke="currentColor">
 <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M14 5l7 7m0 0l-7 7m7-7H3" />
 </svg>
 </div>
 </div>
 </div>
 </div>
 </RouterLink>
 </div>
 </div>

 <!-- Empty State -->
 <div v-else class="text-center py-32 bg-surface rounded-3xl border border-dashed border-border-hover shadow-sm mt-8">
 <div class="w-24 h-24 mx-auto rounded-full flex items-center justify-center mb-6 border" :class="emptyIconBgClass">
 <svg class="w-10 h-10" :class="emptyIconTextClass" fill="none" viewBox="0 0 24 24" stroke="currentColor" v-html="headerIconPath"></svg>
 </div>
 <h3 class="text-2xl font-extrabold text-txt-primary mb-2">{{ emptyTitle }}</h3>
 <p class="text-txt-muted mb-8 max-w-md mx-auto">{{ emptyDesc }}</p>
 <RouterLink :to="{ name: 'interview-prep' }" class="inline-flex rounded-xl bg-brand px-6 py-3 text-sm font-bold text-white shadow-md hover:bg-brand/90 transition-colors">
 Browse Questions
 </RouterLink>
 </div>

 </div>
 </AppShell>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRoute } from 'vue-router'
import AppShell from '../../components/layout/AppShell.vue'
import interviewPrepService from '../../services/interviewPrepService'
import { useInterviewState } from './composables/useInterviewState'

const route = useRoute()
const loading = ref(true)
const allQuestionsMap = ref({}) // Cache of downloaded questions

const { bookmarks, completed, recentlyViewed, isCompleted, isBookmarked, toggleBookmark: _toggleBookmark } = useInterviewState()

const pageType = computed(() => route.meta.listType || 'bookmarks')

const pageTitle = computed(() => {
 if (pageType.value === 'bookmarks') return 'Bookmarked Questions'
 if (pageType.value === 'completed') return 'Completed Questions'
 if (pageType.value === 'history') return 'Recently Viewed'
 return 'Questions'
})

const headerIconBgClass = computed(() => {
 if (pageType.value === 'bookmarks') return 'bg-amber-50 border-amber-100'
 if (pageType.value === 'completed') return 'bg-emerald-50 border-emerald-100'
 return 'bg-surface-hover border-border'
})

const headerIconTextClass = computed(() => {
 if (pageType.value === 'bookmarks') return 'text-amber-500'
 if (pageType.value === 'completed') return 'text-emerald-500'
 return 'text-txt-muted'
})

const emptyIconBgClass = computed(() => {
 if (pageType.value === 'bookmarks') return 'bg-amber-50 border-amber-100'
 if (pageType.value === 'completed') return 'bg-emerald-50 border-emerald-100'
 return 'bg-background border-border'
})

const emptyIconTextClass = computed(() => {
 if (pageType.value === 'bookmarks') return 'text-amber-300'
 if (pageType.value === 'completed') return 'text-emerald-300'
 return 'text-txt-muted'
})

const headerIconPath = computed(() => {
 if (pageType.value === 'bookmarks') return '<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 5a2 2 0 012-2h10a2 2 0 012 2v16l-7-3.5L5 21V5z" />'
 if (pageType.value === 'completed') return '<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M5 13l4 4L19 7" />'
 return '<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />'
})

const emptyTitle = computed(() => {
 if (pageType.value === 'bookmarks') return 'No bookmarked questions yet'
 if (pageType.value === 'completed') return 'No completed questions'
 return 'No recent history'
})

const emptyDesc = computed(() => {
 if (pageType.value === 'bookmarks') return 'Bookmark important interview questions to quickly revisit them later.'
 if (pageType.value === 'completed') return 'Start practicing! Questions you mark as complete will appear here.'
 return 'Questions you view will appear here so you can easily return to them.'
})

// Extract the required keys to load based on active view
const requiredKeys = computed(() => {
 if (pageType.value === 'bookmarks') {
 return Array.from(bookmarks.value)
 }
 if (pageType.value === 'completed') {
 return Array.from(completed.value)
 }
 if (pageType.value === 'history') {
 return recentlyViewed.value.map(item => `${item.subjectSlug}::${item.questionId}`)
 }
 return []
})

// Rebuild the final list items
const filteredItems = computed(() => {
 if (pageType.value === 'history') {
 // Use cached metadata from recentlyViewed instead of fetching full questions
 return recentlyViewed.value
 }
 
 const items = []
 requiredKeys.value.forEach(key => {
 const [sub, id] = key.split('::')
 // Find the question locally if we fetched it
 const q = allQuestionsMap.value[key]
 if (q) {
 items.push({
 subjectSlug: sub,
 questionId: id,
 title: q.title || q.question, // Fallback if missing
 difficulty: q.difficulty,
 topic: q.topic
 })
 }
 })
 return items
})

const toggleBookmark = (e, subjectSlug, questionId) => {
 e.preventDefault()
 e.stopPropagation()
 _toggleBookmark(subjectSlug, questionId)
}

onMounted(async () => {
 try {
 loading.value = true
 
 // We only need to fetch data if we are in bookmarks or completed mode, 
 // because history stores its own metadata!
 if (pageType.value !== 'history') {
 const keysToLoad = requiredKeys.value
 
 // Determine unique subjects we need to query
 const subjectsToLoad = new Set(keysToLoad.map(k => k.split('::')[0]))
 
 // Load them
 const promises = Array.from(subjectsToLoad).map(sub => interviewPrepService.getSubjectQuestions(sub).catch(() => null))
 const results = await Promise.all(promises)
 
 // Populate our map
 results.forEach((res, idx) => {
 if (res && res.data && res.data.questions) {
 const sub = Array.from(subjectsToLoad)[idx]
 res.data.questions.forEach(q => {
 allQuestionsMap.value[`${sub}::${q.id}`] = q
 })
 }
 })
 }
 } catch (error) {
 console.error('Failed to load items', error)
 } finally {
 loading.value = false
 }
})
</script>
