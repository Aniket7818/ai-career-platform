<template>
 <AppShell>
 <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8 animate-fade-in relative">
 
 <!-- Breadcrumbs & Header -->
 <div class="mb-10">
 <nav class="flex text-xs font-bold text-txt-disabled mb-4 uppercase tracking-wider" aria-label="Breadcrumb">
 <ol class="flex flex-wrap items-center gap-2 sm:gap-2.5">
 <li class="flex items-center">
 <RouterLink :to="{ name: 'interview-prep' }" class="hover:text-brand transition-colors flex items-center">
 <svg class="w-4 h-4 mr-1.5 shrink-0" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-6 0a1 1 0 001-1v-4a1 1 0 011-1h2a1 1 0 011 1v4a1 1 0 001 1m-6 0h6" /></svg>
 <span class="leading-none pt-0.5">Library</span>
 </RouterLink>
 </li>
 <li class="flex items-center text-txt-muted">
 <svg class="w-3.5 h-3.5 shrink-0" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="3" d="M9 5l7 7-7 7" /></svg>
 </li>
 <li class="flex items-center">
 <span class="text-txt-primary leading-none pt-0.5">{{ subjectTitle }}</span>
 </li>
 </ol>
 </nav>
 <div class="flex flex-col md:flex-row md:items-end justify-between gap-6">
 <div>
 <h1 class="text-4xl md:text-5xl font-extrabold text-txt-primary tracking-tight">{{ subjectTitle }}</h1>
 <p class="text-lg text-txt-muted mt-2 font-medium">{{ questions.length }} questions available</p>
 </div>
 </div>
 </div>

 <div class="flex flex-col lg:flex-row gap-8">
 <!-- Sticky Sidebar for Filters (Desktop) / Sticky Top (Mobile) -->
 <div class="lg:w-72 shrink-0">
 <div class="sticky top-20 bg-surface/80 backdrop-blur-xl p-6 rounded-3xl border border-border/60 shadow-sm z-20 space-y-6">
 <h3 class="text-xs font-black text-txt-disabled uppercase tracking-widest">Filters</h3>
 
 <div class="space-y-5">
 <div>
 <label class="block text-sm font-bold text-txt-secondary mb-2">Topic</label>
 <div class="relative group">
 <select v-model="selectedTopic" class="appearance-none w-full bg-background border border-border text-txt-primary text-sm font-semibold rounded-xl pl-4 pr-10 py-3.5 focus:ring-4 focus:ring-brand/10 focus:border-brand focus:bg-surface outline-none transition-all shadow-sm cursor-pointer hover:border-border-hover">
 <option value="">All Topics</option>
 <option v-for="topic in uniqueTopics" :key="topic" :value="topic">{{ topic }}</option>
 </select>
 <div class="pointer-events-none absolute inset-y-0 right-0 flex items-center px-4 text-txt-disabled group-hover:text-brand transition-colors">
 <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M19 9l-7 7-7 7"></path></svg>
 </div>
 </div>
 </div>

 <div>
 <label class="block text-sm font-bold text-txt-secondary mb-2">Difficulty</label>
 <div class="relative group">
 <select v-model="selectedDifficulty" class="appearance-none w-full bg-background border border-border text-txt-primary text-sm font-semibold rounded-xl pl-4 pr-10 py-3.5 focus:ring-4 focus:ring-brand/10 focus:border-brand focus:bg-surface outline-none transition-all shadow-sm cursor-pointer hover:border-border-hover">
 <option value="">All Difficulties</option>
 <option v-for="diff in uniqueDifficulties" :key="diff" :value="diff">{{ diff }}</option>
 </select>
 <div class="pointer-events-none absolute inset-y-0 right-0 flex items-center px-4 text-txt-disabled group-hover:text-brand transition-colors">
 <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M19 9l-7 7-7 7"></path></svg>
 </div>
 </div>
 </div>
 </div>
 
 <button v-if="selectedTopic || selectedDifficulty" @click="selectedTopic = ''; selectedDifficulty = ''" class="w-full py-2 text-xs font-bold text-txt-muted hover:text-txt-primary transition-colors">
 Reset Filters
 </button>
 </div>
 </div>

 <!-- Question List -->
 <div class="flex-1 min-w-0 pb-20">
 <div v-if="loading" class="space-y-4">
 <div v-for="i in 5" :key="i" class="h-32 bg-surface-hover animate-pulse rounded-3xl border border-border/50"></div>
 </div>
 
 <div v-else-if="questions.length" class="space-y-4">
 <div v-if="filteredQuestions.length === 0" class="bg-surface rounded-3xl border border-dashed border-border-hover p-16 text-center shadow-sm">
 <div class="w-16 h-16 mx-auto bg-background rounded-full flex items-center justify-center mb-4">
 <svg class="w-8 h-8 text-txt-disabled" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" /></svg>
 </div>
 <p class="text-txt-primary font-bold text-lg mb-1">No matches found</p>
 <p class="text-txt-muted text-sm mb-6">Try adjusting your filters to see more results.</p>
 <button @click="selectedTopic = ''; selectedDifficulty = ''" class="bg-surface text-white px-5 py-2.5 rounded-xl text-sm font-bold shadow-md hover:bg-brand transition-colors">Clear all filters</button>
 </div>
 
 <RouterLink 
 v-for="(q, index) in filteredQuestions" :key="q.id"
 :to="{ name: 'interview-prep-question', params: { subject: route.params.subject, question_id: q.id } }"
 class="group relative block bg-surface rounded-2xl p-5 sm:p-6 shadow-sm border border-border hover:shadow-xl hover:border-border-hover transition-all duration-300 transform hover:-translate-y-1 overflow-hidden"
 >
 <!-- Difficulty Left Border -->
 <div class="absolute left-0 top-0 bottom-0 w-1.5 transition-colors"
 :class="{
 'bg-emerald-500': q.difficulty === 'Easy',
 'bg-amber-500': q.difficulty === 'Intermediate',
 'bg-rose-500': q.difficulty === 'Hard'
 }"
 ></div>

 <div class="flex flex-col sm:flex-row sm:items-center justify-between gap-6 pl-2">
 <div class="flex-1 min-w-0">
 <div class="flex items-center gap-3 mb-3">
 <span class="text-xs font-black text-txt-disabled">#{{ index + 1 }}</span>
 <span 
 class="inline-flex items-center rounded-md px-2 py-0.5 text-[10px] font-black uppercase tracking-wider"
 :class="{
 'bg-emerald-50 text-emerald-700 border border-emerald-200/50': q.difficulty === 'Easy',
 'bg-amber-50 text-amber-700 border border-amber-200/50': q.difficulty === 'Intermediate',
 'bg-rose-50 text-rose-700 border border-rose-200/50': q.difficulty === 'Hard'
 }"
 >
 {{ q.difficulty }}
 </span>
 <span class="inline-flex items-center text-[11px] font-bold text-txt-muted bg-surface-hover rounded-md px-2 py-0.5 border border-border/50">
 {{ q.topic }}
 </span>
 <span class="hidden sm:inline-flex items-center text-[11px] font-bold text-txt-disabled ml-auto">
 <svg class="w-3.5 h-3.5 mr-1" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" /></svg>
 ~3 min read
 </span>
 </div>
 <h3 class="text-xl font-bold text-txt-primary group-hover:text-brand transition-colors line-clamp-2 leading-tight pr-4">
 {{ q.title }}
 </h3>
 </div>
 
 <div class="shrink-0 flex items-center justify-between sm:justify-end border-t sm:border-t-0 border-border pt-4 sm:pt-0">
 <div class="flex items-center sm:hidden text-[11px] font-bold text-txt-disabled">
 <svg class="w-3.5 h-3.5 mr-1" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" /></svg>
 ~3 min
 </div>
 
 <div class="flex items-center gap-4">
 <div v-if="isCompleted(route.params.subject, q.id)" class="flex items-center gap-1 text-emerald-500 text-xs font-bold bg-emerald-50 px-2 py-1 rounded-lg">
 <svg class="w-3.5 h-3.5" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M5 13l4 4L19 7" /></svg>
 Done
 </div>
 <!-- Bookmark Icon -->
 <button class="p-1.5 rounded-lg transition-colors" :class="isBookmarked(route.params.subject, q.id) ? 'text-amber-500 bg-amber-50' : 'text-txt-muted hover:text-amber-500 hover:bg-background'" @click="toggleBookmark($event, q.id)" title="Bookmark">
 <svg class="w-5 h-5" :fill="isBookmarked(route.params.subject, q.id) ? 'currentColor' : 'none'" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 5a2 2 0 012-2h10a2 2 0 012 2v16l-7-3.5L5 21V5z" /></svg>
 </button>
 <div class="flex items-center text-brand font-bold text-sm bg-brand/5 px-4 py-2 rounded-xl group-hover:bg-brand group-hover:text-white transition-all shadow-sm">
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

 <div v-else class="bg-surface rounded-3xl border border-dashed border-border-hover p-16 text-center max-w-2xl mx-auto shadow-sm">
 <div class="w-20 h-20 mx-auto bg-background rounded-full flex items-center justify-center mb-6">
 <svg class="w-10 h-10 text-txt-muted" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M20 7l-8-4-8 4m16 0l-8 4m8-4v10l-8 4m0-10L4 7m8 4v10M4 7v10l8 4" /></svg>
 </div>
 <p class="text-txt-primary font-extrabold text-xl mb-2">No questions available</p>
 <p class="text-txt-muted mb-8">We're currently adding more content for this subject.</p>
 <RouterLink :to="{ name: 'interview-prep' }" class="inline-flex items-center justify-center bg-surface text-white px-6 py-3 rounded-xl text-sm font-bold shadow-md hover:bg-brand transition-colors">
 <svg class="w-4 h-4 mr-2" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M10 19l-7-7m0 0l7-7m-7 7h18" /></svg>
 Explore other subjects
 </RouterLink>
 </div>
 </div>
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
const questions = ref([])
const subjectTitle = ref(route.params.subject)
const loading = ref(true)

const selectedTopic = ref('')
const selectedDifficulty = ref('')

const { isBookmarked, isCompleted, toggleBookmark: _toggleBookmark } = useInterviewState()

const uniqueTopics = computed(() => {
 const topics = new Set(questions.value.map(q => q.topic).filter(Boolean))
 return Array.from(topics).sort()
})

const uniqueDifficulties = computed(() => {
 const diffs = new Set(questions.value.map(q => q.difficulty).filter(Boolean))
 return Array.from(diffs).sort()
})

const filteredQuestions = computed(() => {
 return questions.value.filter(q => {
 const matchTopic = !selectedTopic.value || q.topic === selectedTopic.value
 const matchDiff = !selectedDifficulty.value || q.difficulty === selectedDifficulty.value
 return matchTopic && matchDiff
 })
})

const toggleBookmark = (e, questionId) => {
 e.preventDefault()
 e.stopPropagation()
 _toggleBookmark(route.params.subject, questionId)
}

onMounted(async () => {
 try {
 const { data } = await interviewPrepService.getSubjectQuestions(route.params.subject)
 questions.value = data.questions || []
 if (data.subject) subjectTitle.value = data.subject
 } catch (error) {
 console.error('Failed to load questions', error)
 } finally {
 loading.value = false
 }
})
</script>
