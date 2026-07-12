<template>
 <AppShell>
  <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8 animate-fade-in relative">
   <!-- Ambient Background Mesh Glows -->
   <div class="absolute top-0 left-1/4 w-96 h-96 bg-brand/5 rounded-full blur-[120px] pointer-events-none -z-10"></div>
   <div class="absolute top-1/3 right-10 w-96 h-96 bg-indigo-500/5 rounded-full blur-[120px] pointer-events-none -z-10"></div>
   <div class="absolute bottom-10 left-10 w-96 h-96 bg-emerald-500/5 rounded-full blur-[120px] pointer-events-none -z-10"></div>

   <!-- Breadcrumbs & Header -->
   <div class="mb-8">
    <nav class="flex text-xs font-bold text-txt-disabled mb-5 uppercase tracking-wider" aria-label="Breadcrumb">
     <ol class="flex flex-wrap items-center gap-2">
      <li>
       <RouterLink :to="{ name: 'interview-prep' }" class="hover:text-brand transition-colors flex items-center gap-1.5">
        <svg class="w-3.5 h-3.5" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-6 0a1 1 0 001-1v-4a1 1 0 011-1h2a1 1 0 011 1v4a1 1 0 001 1m-6 0h6" /></svg>
        Library
       </RouterLink>
      </li>
      <li class="text-txt-muted"><svg class="w-3 h-3" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="3" d="M9 5l7 7-7 7" /></svg></li>
      <li class="text-txt-primary font-extrabold">{{ String(subjectTitle).replace(/_/g, ' ') }}</li>
     </ol>
    </nav>

    <div class="flex flex-col sm:flex-row sm:items-end justify-between gap-4">
     <div>
      <h1 class="text-3xl sm:text-4xl md:text-5xl font-extrabold text-txt-primary tracking-tight capitalize">
       {{ String(subjectTitle).replace(/_/g, ' ') }}
      </h1>
      <p class="text-base text-txt-muted mt-1.5 font-medium">
       <span class="text-brand font-bold">{{ questions.length }}</span> questions available
      </p>
     </div>
     <!-- Stats Pills -->
     <div class="flex items-center gap-2 flex-wrap">
      <span class="inline-flex items-center gap-1.5 px-3 py-1.5 rounded-full bg-emerald-50 text-emerald-700 text-xs font-bold border border-emerald-200/60">
       <span class="w-1.5 h-1.5 rounded-full bg-emerald-500"></span>
       {{ questions.filter(q => q.difficulty === 'Easy').length }} Easy
      </span>
      <span class="inline-flex items-center gap-1.5 px-3 py-1.5 rounded-full bg-amber-50 text-amber-700 text-xs font-bold border border-amber-200/60">
       <span class="w-1.5 h-1.5 rounded-full bg-amber-500"></span>
       {{ questions.filter(q => q.difficulty === 'Medium').length }} Medium
      </span>
      <span class="inline-flex items-center gap-1.5 px-3 py-1.5 rounded-full bg-rose-50 text-rose-700 text-xs font-bold border border-rose-200/60">
       <span class="w-1.5 h-1.5 rounded-full bg-rose-500"></span>
       {{ questions.filter(q => q.difficulty === 'Hard').length }} Hard
      </span>
     </div>
    </div>
   </div>

   <!-- ── Filter Bar ─────────────────────────────────────────── -->
   <div class="mb-6 space-y-4">
    <!-- Difficulty Pills -->
    <div class="flex items-center gap-2 overflow-x-auto pb-1 hide-scrollbar">
     <span class="text-[11px] font-black uppercase tracking-widest text-txt-disabled mr-1 shrink-0">Difficulty</span>
     <button
      @click="selectedDifficulty = ''"
      class="px-3.5 py-1.5 rounded-full text-xs font-bold border transition-all"
      :class="!selectedDifficulty
       ? 'bg-txt-primary text-surface border-txt-primary shadow-sm'
       : 'bg-surface text-txt-muted border-border hover:border-border-hover hover:text-txt-secondary'"
     >All</button>
     <button
      v-for="diff in uniqueDifficulties" :key="diff"
      @click="selectedDifficulty = selectedDifficulty === diff ? '' : diff"
      class="px-3.5 py-1.5 rounded-full text-xs font-bold border transition-all"
      :class="{
       'bg-emerald-500 text-white border-emerald-500 shadow-sm': selectedDifficulty === diff && diff === 'Easy',
       'bg-amber-500 text-white border-amber-500 shadow-sm':   selectedDifficulty === diff && diff === 'Medium',
       'bg-rose-500 text-white border-rose-500 shadow-sm':    selectedDifficulty === diff && diff === 'Hard',
       'bg-emerald-50 text-emerald-700 border-emerald-200/60 hover:bg-emerald-100': selectedDifficulty !== diff && diff === 'Easy',
       'bg-amber-50 text-amber-700 border-amber-200/60 hover:bg-amber-100':   selectedDifficulty !== diff && diff === 'Medium',
       'bg-rose-50 text-rose-700 border-rose-200/60 hover:bg-rose-100':    selectedDifficulty !== diff && diff === 'Hard',
      }"
     >{{ diff }}</button>
    </div>

    <!-- Topic Pills — single row, horizontally scrollable -->
    <div class="flex items-center gap-2">
     <span class="text-[11px] font-black uppercase tracking-widest text-txt-disabled shrink-0">Topic</span>
     <div class="flex items-center gap-2 overflow-x-auto pb-1 hide-scrollbar" style="min-width:0">
      <button
       @click="selectedTopic = ''"
       class="px-3.5 py-1.5 rounded-full text-xs font-bold border transition-all shrink-0 whitespace-nowrap"
       :class="!selectedTopic
        ? 'bg-brand text-white border-brand shadow-sm'
        : 'bg-surface text-txt-muted border-border hover:border-brand/40 hover:text-brand'"
      >All Topics</button>
      <button
       v-for="topic in uniqueTopics" :key="topic"
       @click="selectedTopic = selectedTopic === topic ? '' : topic"
       class="px-3.5 py-1.5 rounded-full text-xs font-bold border transition-all shrink-0 whitespace-nowrap"
       :class="selectedTopic === topic
        ? 'bg-brand/10 text-brand border-brand/40 shadow-sm'
        : 'bg-surface text-txt-muted border-border hover:border-brand/40 hover:text-brand'"
      >{{ topic }}</button>
     </div>
    </div>

    <!-- Active filters + clear -->
    <div v-if="selectedTopic || selectedDifficulty" class="flex items-center gap-2 pt-1">
     <span class="text-xs text-txt-muted font-semibold">
      Showing <span class="text-brand font-bold">{{ filteredQuestions.length }}</span> of {{ questions.length }} questions
     </span>
     <button @click="selectedTopic = ''; selectedDifficulty = ''" class="text-xs font-bold text-txt-muted hover:text-rose-500 transition-colors underline underline-offset-2 ml-1">
      Clear all
     </button>
    </div>

    <!-- Separator -->
    <div class="h-px bg-gradient-to-r from-transparent via-border to-transparent"></div>
   </div>

   <!-- ── Question List ────────────────────────────────────────── -->
   <div class="pb-20">
    <!-- Loading skeletons -->
    <div v-if="loading" class="space-y-3">
     <div v-for="i in 5" :key="i" class="h-28 bg-surface-hover animate-pulse rounded-2xl border border-border/50"></div>
    </div>

    <!-- Empty result -->
    <div v-else-if="filteredQuestions.length === 0" class="bg-surface rounded-3xl border border-dashed border-border-hover p-16 text-center shadow-sm mt-4">
     <div class="w-16 h-16 mx-auto bg-background rounded-full flex items-center justify-center mb-4">
      <svg class="w-8 h-8 text-txt-disabled" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" /></svg>
     </div>
     <p class="text-txt-primary font-bold text-lg mb-1">No matches found</p>
     <p class="text-txt-muted text-sm mb-6">Try adjusting your filters to see more results.</p>
     <button @click="selectedTopic = ''; selectedDifficulty = ''" class="bg-brand text-white px-5 py-2.5 rounded-xl text-sm font-bold shadow-md hover:bg-brand/90 transition-colors">Clear all filters</button>
    </div>

    <!-- Question cards -->
    <div v-else class="space-y-2.5">
     <RouterLink
      v-for="(q, index) in filteredQuestions" :key="q.id"
      :to="{ name: 'interview-prep-question', params: { subject: route.params.subject, question_id: q.id } }"
      class="group relative flex items-center gap-4 bg-surface rounded-2xl px-5 py-4 border border-border hover:border-brand/30 hover:shadow-lg hover:shadow-brand/5 transition-all duration-200 overflow-hidden"
     >
      <!-- Difficulty accent bar -->
      <div class="absolute left-0 top-0 bottom-0 w-[3px] rounded-r-full transition-all"
       :class="{
        'bg-emerald-400 group-hover:bg-emerald-500': q.difficulty === 'Easy',
        'bg-amber-400 group-hover:bg-amber-500': q.difficulty === 'Medium',
        'bg-rose-400 group-hover:bg-rose-500': q.difficulty === 'Hard',
       }"
      ></div>

      <!-- Index number -->
      <span class="text-sm font-black text-txt-disabled shrink-0 w-7 text-right tabular-nums">{{ index + 1 }}</span>

      <!-- Content -->
      <div class="flex-1 min-w-0">
       <div class="flex items-center gap-2 mb-1.5 flex-wrap">
        <!-- Difficulty badge -->
        <span class="text-[10px] font-black uppercase tracking-wider px-2 py-0.5 rounded-full border"
         :class="{
          'bg-emerald-50 text-emerald-700 border-emerald-200/60': q.difficulty === 'Easy',
          'bg-amber-50 text-amber-700 border-amber-200/60': q.difficulty === 'Medium',
          'bg-rose-50 text-rose-700 border-rose-200/60': q.difficulty === 'Hard',
         }"
        >{{ q.difficulty }}</span>
        <!-- Topic badge -->
        <span class="text-[10px] font-bold text-txt-muted bg-surface-hover px-2 py-0.5 rounded-full border border-border/50">{{ q.topic }}</span>
        <!-- Read time -->
        <span class="hidden sm:inline-flex items-center gap-1 text-[10px] text-txt-disabled font-semibold ml-auto">
         <svg class="w-3 h-3" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" /></svg>
         ~3 min
        </span>
       </div>
       <h3 class="text-sm sm:text-base font-bold text-txt-primary group-hover:text-brand transition-colors line-clamp-2 leading-snug">{{ q.title }}</h3>
      </div>

      <!-- Right actions -->
      <div class="shrink-0 flex items-center gap-2 ml-2">
       <!-- Completed badge -->
       <span v-if="isCompleted(route.params.subject, q.id)"
        class="hidden sm:inline-flex items-center gap-1 text-emerald-600 text-[10px] font-black bg-emerald-50 px-2 py-1 rounded-full border border-emerald-200/60">
        <svg class="w-3 h-3" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M5 13l4 4L19 7" /></svg>
        Done
       </span>
       <!-- Bookmark -->
       <button
        class="p-1.5 rounded-xl transition-colors"
        :class="isBookmarked(route.params.subject, q.id) ? 'text-amber-500 bg-amber-50' : 'text-txt-muted hover:text-amber-500 hover:bg-amber-50/50'"
        @click.prevent="toggleBookmark($event, q.id)"
        title="Bookmark"
       >
        <svg class="w-4 h-4" :fill="isBookmarked(route.params.subject, q.id) ? 'currentColor' : 'none'" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 5a2 2 0 012-2h10a2 2 0 012 2v16l-7-3.5L5 21V5z" /></svg>
       </button>
       <!-- Solve CTA -->
       <div class="hidden sm:flex items-center gap-1.5 text-brand text-xs font-bold bg-brand/5 px-3 py-2 rounded-xl group-hover:bg-brand group-hover:text-white transition-all">
        Solve
        <svg class="w-3.5 h-3.5 group-hover:translate-x-0.5 transition-transform" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M14 5l7 7m0 0l-7 7m7-7H3" /></svg>
       </div>
       <svg class="sm:hidden w-4 h-4 text-txt-muted group-hover:text-brand transition-colors" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M9 5l7 7-7 7" /></svg>
      </div>
     </RouterLink>
    </div>

    <!-- No questions at all -->
    <div v-if="!loading && questions.length === 0" class="bg-surface rounded-3xl border border-dashed border-border-hover p-16 text-center max-w-2xl mx-auto shadow-sm">
     <div class="w-20 h-20 mx-auto bg-background rounded-full flex items-center justify-center mb-6">
      <svg class="w-10 h-10 text-txt-muted" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M20 7l-8-4-8 4m16 0l-8 4m8-4v10l-8 4m0-10L4 7m8 4v10M4 7v10l8 4" /></svg>
     </div>
     <p class="text-txt-primary font-extrabold text-xl mb-2">No questions available</p>
     <p class="text-txt-muted mb-8">We're currently adding more content for this subject.</p>
     <RouterLink :to="{ name: 'interview-prep' }" class="inline-flex items-center justify-center bg-brand text-white px-6 py-3 rounded-xl text-sm font-bold shadow-md hover:bg-brand/90 transition-colors">
      <svg class="w-4 h-4 mr-2" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M10 19l-7-7m0 0l7-7m-7 7h18" /></svg>
      Explore other subjects
     </RouterLink>
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
