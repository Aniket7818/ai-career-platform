<template>
 <AppShell>
 <!-- Lightweight Toast -->
 <Transition name="fade">
 <div v-if="toastMsg" class="fixed top-4 right-4 z-[100] bg-surface text-white px-4 py-3 rounded-xl shadow-2xl flex items-center gap-3">
 <svg class="w-5 h-5 text-emerald-400" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" /></svg>
 <span class="text-sm font-bold">{{ toastMsg }}</span>
 </div>
 </Transition>

 <div class="max-w-7xl mx-auto space-y-12 animate-fade-in pb-16 px-4 sm:px-6 lg:px-8 mt-8">
 
 <!-- Premium Dashboard Header -->
 <div class="flex flex-col xl:flex-row gap-8 relative z-10">
 
 <!-- Welcome & Global Stats -->
 <div class="flex-1 space-y-8">
 <div>
 <div class="inline-flex items-center gap-2 px-3 py-1.5 rounded-full bg-brand/10 text-brand text-sm font-semibold mb-4 border border-brand/20 shadow-sm">
 <span class="relative flex h-2 w-2">
 <span class="animate-ping absolute inline-flex h-full w-full rounded-full bg-brand opacity-75"></span>
 <span class="relative inline-flex rounded-full h-2 w-2 bg-brand"></span>
 </span>
 Interview Prep 2.0
 </div>
 <h1 class="text-4xl sm:text-5xl font-extrabold text-txt-primary tracking-tight mb-2 leading-tight">
 Welcome back to your <span class="text-transparent bg-clip-text bg-gradient-to-r from-brand via-indigo-500 to-purple-600">Learning Dashboard.</span>
 </h1>
 <p class="text-lg text-txt-muted max-w-xl leading-relaxed">
 Track your progress, revisit recent questions, and master technical interviews step-by-step.
 </p>
 </div>
 
 <!-- Global Statistics Grid -->
 <div class="grid grid-cols-2 md:grid-cols-4 gap-4">
 <button @click="showToast('Total Questions filter coming soon')" class="text-left bg-surface rounded-2xl p-5 border border-border/60 shadow-sm hover:border-brand/30 transition-colors group focus:outline-none focus:ring-4 focus:ring-brand/20">
 <div class="w-10 h-10 rounded-xl bg-background flex items-center justify-center mb-3 group-hover:scale-110 transition-transform">
 <svg class="w-5 h-5 text-txt-secondary group-hover:text-brand" fill="none" viewBox="0 0 24 24" stroke="currentColor" aria-hidden="true"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 11H5m14 0a2 2 0 012 2v6a2 2 0 01-2 2H5a2 2 0 01-2-2v-6a2 2 0 012-2m14 0V9a2 2 0 00-2-2M5 11V9a2 2 0 012-2m0 0V5a2 2 0 012-2h6a2 2 0 012 2v2M7 7h10" /></svg>
 </div>
 <p class="text-[11px] font-bold text-txt-disabled uppercase tracking-wider mb-0.5">Total Questions</p>
 <p class="text-2xl font-black text-txt-primary">{{ totalQuestions }}</p>
 </button>
 <RouterLink :to="{ name: 'interview-prep-completed' }" class="text-left bg-surface rounded-2xl p-5 border border-border/60 shadow-sm hover:border-emerald-300 transition-colors group focus:outline-none focus:ring-4 focus:ring-emerald-200 block">
 <div class="w-10 h-10 rounded-xl bg-emerald-50 flex items-center justify-center mb-3 group-hover:scale-110 transition-transform">
 <svg class="w-5 h-5 text-emerald-600" fill="none" viewBox="0 0 24 24" stroke="currentColor" aria-hidden="true"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M5 13l4 4L19 7" /></svg>
 </div>
 <p class="text-[11px] font-bold text-txt-disabled uppercase tracking-wider mb-0.5">Completed</p>
 <p class="text-2xl font-black text-txt-primary">{{ totalCompletedCount }}</p>
 </RouterLink>
 <RouterLink :to="{ name: 'interview-prep-bookmarks' }" class="text-left bg-surface rounded-2xl p-5 border border-border/60 shadow-sm hover:border-amber-300 transition-colors group focus:outline-none focus:ring-4 focus:ring-amber-200 block">
 <div class="w-10 h-10 rounded-xl bg-amber-50 flex items-center justify-center mb-3 group-hover:scale-110 transition-transform">
 <svg class="w-5 h-5 text-amber-500" fill="currentColor" viewBox="0 0 24 24" aria-hidden="true"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 5a2 2 0 012-2h10a2 2 0 012 2v16l-7-3.5L5 21V5z" /></svg>
 </div>
 <p class="text-[11px] font-bold text-txt-disabled uppercase tracking-wider mb-0.5">Bookmarks</p>
 <p class="text-2xl font-black text-txt-primary">{{ totalBookmarkedCount }}</p>
 </RouterLink>
 <button @click="showToast('Learning Statistics page coming soon')" class="text-left bg-surface rounded-2xl p-5 border border-border/60 shadow-sm hover:border-purple-300 transition-colors group focus:outline-none focus:ring-4 focus:ring-purple-200">
 <div class="w-10 h-10 rounded-xl bg-purple-50 flex items-center justify-center mb-3 group-hover:scale-110 transition-transform">
 <svg class="w-5 h-5 text-purple-600" fill="none" viewBox="0 0 24 24" stroke="currentColor" aria-hidden="true"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" /></svg>
 </div>
 <p class="text-[11px] font-bold text-txt-disabled uppercase tracking-wider mb-0.5">Remaining Time</p>
 <p class="text-2xl font-black text-txt-primary">~{{ remainingEstTime }}h</p>
 </button>
 </div>
 
 <!-- Quick Actions -->
 <div class="flex flex-wrap gap-3 pt-2">
 <RouterLink v-if="continueLearning" :to="{ name: 'interview-prep-question', params: { subject: continueLearning.subjectSlug, question_id: continueLearning.questionId } }" class="inline-flex items-center gap-2 bg-brand text-white px-5 py-2.5 rounded-xl text-sm font-bold shadow-md hover:bg-brand/90 transition-colors">
 <svg class="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M14 5l7 7m0 0l-7 7m7-7H3" /></svg>
 Continue Learning
 </RouterLink>
 <RouterLink :to="{ name: 'interview-prep-bookmarks' }" class="inline-flex items-center gap-2 bg-surface text-txt-secondary border border-border px-5 py-2.5 rounded-xl text-sm font-bold shadow-sm hover:bg-background transition-colors">
 <svg class="w-4 h-4 text-amber-500" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 5a2 2 0 012-2h10a2 2 0 012 2v16l-7-3.5L5 21V5z" /></svg>
 Bookmarks
 </RouterLink>
 <RouterLink :to="{ name: 'interview-prep-completed' }" class="inline-flex items-center gap-2 bg-surface text-txt-secondary border border-border px-5 py-2.5 rounded-xl text-sm font-bold shadow-sm hover:bg-background transition-colors">
 <svg class="w-4 h-4 text-emerald-500" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M5 13l4 4L19 7" /></svg>
 Completed
 </RouterLink>
 <RouterLink :to="{ name: 'interview-prep-history' }" class="inline-flex items-center gap-2 bg-surface text-txt-secondary border border-border px-5 py-2.5 rounded-xl text-sm font-bold shadow-sm hover:bg-background transition-colors">
 <svg class="w-4 h-4 text-txt-disabled" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" /></svg>
 History
 </RouterLink>
 </div>
 </div>

 <!-- Continue Learning & Overall Progress -->
 <div class="xl:w-[420px] shrink-0 space-y-6">
 <!-- Overall Progress Card -->
 <div class="bg-surface rounded-3xl p-6 md:p-8 text-txt-primary relative overflow-hidden shadow-xl border border-border">
 <div class="absolute -right-10 -top-10 w-40 h-40 bg-brand/30 rounded-full blur-3xl"></div>
 <div class="relative z-10">
 <div class="flex items-center justify-between mb-8">
 <h3 class="text-sm font-bold text-txt-disabled uppercase tracking-widest">Overall Progress</h3>
 <span class="bg-surface-elevated/50 border border-border px-3 py-1 rounded-lg text-xs font-bold">{{ globalProgressPercentage }}%</span>
 </div>
 
 <div class="mb-4">
 <div class="w-full h-2 bg-surface-elevated rounded-full overflow-hidden border border-border/50">
 <div class="h-full bg-gradient-to-r from-brand to-indigo-500 rounded-full transition-all duration-1000 ease-out" :style="{ width: `${globalProgressPercentage}%` }"></div>
 </div>
 </div>
 
 <div class="flex items-center justify-between text-sm font-semibold">
 <span class="text-txt-primary">{{ totalCompletedCount }} Solved</span>
 <span class="text-txt-muted">{{ Math.max(0, totalQuestions - totalCompletedCount) }} Left</span>
 </div>
 </div>
 </div>

 <!-- Continue Learning Widget -->
 <div v-if="continueLearning" class="bg-surface rounded-3xl p-6 border border-border/60 shadow-lg relative overflow-hidden group hover:border-brand/40 transition-colors">
 <div class="absolute top-0 left-0 w-1.5 h-full bg-brand"></div>
 <div class="flex items-center gap-2 mb-4">
 <span class="w-8 h-8 rounded-full bg-brand/10 text-brand flex items-center justify-center">
 <svg class="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M14.752 11.168l-3.197-2.132A1 1 0 0010 9.87v4.263a1 1 0 001.555.832l3.197-2.132a1 1 0 000-1.664z" /><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 12a9 9 0 11-18 0 9 9 0 0118 0z" /></svg>
 </span>
 <h3 class="text-sm font-bold text-txt-primary">Continue Learning</h3>
 </div>
 <p class="text-xs font-bold text-txt-disabled uppercase tracking-wider mb-1">{{ continueLearning.subjectName }}</p>
 <h4 class="text-lg font-black text-txt-primary mb-6 truncate" title="Resume last viewed question">Question {{ continueLearning.currentIndex + 1 }} of {{ continueLearning.totalQuestions }}</h4>
 <div class="w-full h-1 bg-surface-hover rounded-full overflow-hidden mb-4">
 <div class="h-full bg-brand transition-all duration-300" :style="{ width: `${((continueLearning.currentIndex + 1) / continueLearning.totalQuestions) * 100}%` }"></div>
 </div>
 <RouterLink 
 :to="{ name: 'interview-prep-question', params: { subject: continueLearning.subjectSlug, question_id: continueLearning.questionId } }"
 class="w-full flex items-center justify-center bg-slate-900 text-white py-3 rounded-xl text-sm font-bold shadow-md hover:bg-slate-800 transition-colors focus:outline-none focus:ring-4 focus:ring-brand/20"
 >
 Resume Learning
 <svg class="w-4 h-4 ml-1.5" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M9 5l7 7-7 7" /></svg>
 </RouterLink>
 </div>
 </div>
 </div>

 <!-- Recently Viewed & Search Controls -->
 <div class="flex flex-col lg:flex-row lg:items-end justify-between gap-8 pt-8 border-t border-border">
 
 <!-- Recently Viewed (Horizontal Scroll) -->
 <div v-if="recentlyViewed.length > 0" class="flex-1 min-w-0">
 <div class="flex items-center justify-between mb-4">
 <h3 class="text-sm font-extrabold text-txt-primary flex items-center gap-2">
 <svg class="w-4 h-4 text-txt-disabled" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" /></svg>
 Recently Viewed
 </h3>
 <RouterLink :to="{ name: 'interview-prep-history' }" class="text-xs font-bold text-brand hover:text-indigo-600 transition-colors">View All &rarr;</RouterLink>
 </div>
 <div class="flex gap-4 overflow-x-auto pb-4 snap-x hide-scrollbar">
 <RouterLink 
 v-for="item in recentlyViewed.slice(0, 5)" :key="item.questionId"
 :to="{ name: 'interview-prep-question', params: { subject: item.subjectSlug, question_id: item.questionId } }"
 class="snap-start shrink-0 w-80 bg-surface border border-border/60 rounded-2xl p-5 hover:border-brand/40 hover:shadow-xl hover:shadow-brand/5 transition-all group focus:outline-none focus:ring-4 focus:ring-brand/20 flex flex-col justify-between"
 >
 <div>
 <div class="flex items-center justify-between gap-2 mb-3">
 <span class="text-[10px] font-black uppercase tracking-wider text-txt-muted bg-surface-hover px-2 py-1 rounded">{{ item.subjectSlug }}</span>
 <span class="text-[10px] font-black uppercase tracking-wider px-2 py-1 rounded" :class="{ 'bg-emerald-50 text-emerald-600': item.difficulty === 'Easy', 'bg-amber-50 text-amber-600': item.difficulty === 'Intermediate', 'bg-rose-50 text-rose-600': item.difficulty === 'Hard' }">{{ item.difficulty || 'Mixed' }}</span>
 </div>
 <p class="text-base font-bold text-txt-primary line-clamp-2 leading-tight group-hover:text-brand transition-colors mb-4">{{ item.title }}</p>
 </div>
 <div class="flex items-center justify-between border-t border-border pt-3 mt-auto">
 <span class="text-[11px] font-bold text-txt-disabled">Active</span>
 <span class="text-[11px] font-bold text-brand group-hover:underline">Continue &rarr;</span>
 </div>
 </RouterLink>
 </div>
 </div>
 
 <!-- Search -->
 <div class="w-full lg:w-80 shrink-0">
 <div class="relative group">
 <div class="absolute inset-y-0 left-0 pl-4 flex items-center pointer-events-none text-txt-disabled group-focus-within:text-brand transition-colors">
 <svg class="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor" aria-hidden="true">
 <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
 </svg>
 </div>
 <input 
 v-model="searchQuery" 
 type="text" 
 class="w-full bg-surface border border-border/80 rounded-2xl pl-11 pr-4 py-4 text-sm font-medium text-txt-primary placeholder-slate-400 focus:outline-none focus:ring-2 focus:ring-brand/20 focus:border-brand shadow-sm hover:border-border-hover transition-all"
 placeholder="Search subjects..."
 aria-label="Search subjects"
 >
 <div class="absolute inset-y-0 right-0 pr-2 flex items-center pointer-events-none">
 <kbd class="hidden sm:inline-flex items-center px-2 py-1 rounded bg-surface-hover border border-border text-[10px] font-bold text-txt-muted">⌘K</kbd>
 </div>
 </div>
 </div>
 </div>

 <!-- Subject Grid -->
 <div v-if="loading" class="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-6 pt-4">
 <div v-for="i in 6" :key="i" class="h-64 bg-surface-hover animate-pulse rounded-3xl border border-border/50"></div>
 </div>
 
 <div v-else-if="filteredSubjects.length" class="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-6 pt-4">
 <div v-for="sub in filteredSubjects" :key="sub.slug" 
 class="group relative bg-surface rounded-3xl p-6 sm:p-8 shadow-sm border border-border/60 hover:shadow-2xl hover:shadow-brand/10 hover:border-brand/40 transition-all duration-300 transform hover:-translate-y-2 overflow-hidden flex flex-col h-full cursor-pointer focus-within:ring-4 focus-within:ring-brand/20 focus-within:border-brand"
 @click="goToSubject(sub.slug)"
 role="article"
 tabindex="0"
 @keydown.enter="goToSubject(sub.slug)">
 
 <!-- Gradient Top Border -->
 <div class="absolute top-0 left-0 right-0 h-1.5 bg-gradient-to-r from-brand via-indigo-500 to-purple-500 opacity-0 group-hover:opacity-100 transition-opacity duration-300"></div>
 
 <!-- Abstract Background Pattern -->
 <div class="absolute -right-16 -top-16 w-64 h-64 bg-brand/5 rounded-full blur-3xl group-hover:bg-brand/15 transition-colors duration-500 pointer-events-none"></div>

 <div class="relative z-10 flex-1">
 <div class="flex justify-between items-start mb-6">
 <div class="w-20 h-20 rounded-2xl bg-gradient-to-br from-slate-50 to-slate-100 border border-border/50 flex items-center justify-center shadow-sm group-hover:scale-110 group-hover:rotate-3 transition-transform duration-300">
 <span class="text-4xl font-black text-transparent bg-clip-text bg-gradient-to-br from-slate-800 to-slate-600 group-hover:from-brand group-hover:to-indigo-600">{{ sub.subject.charAt(0) }}</span>
 </div>
 
 <!-- Reactive Progress Indicator -->
 <div class="flex items-center justify-center w-14 h-14 rounded-full border-[5px] border-slate-50 relative shadow-sm bg-surface" title="Subject Progress">
 <svg class="w-full h-full transform -rotate-90" viewBox="0 0 36 36" aria-hidden="true">
 <path class="text-slate-100" d="M18 2.0845 a 15.9155 15.9155 0 0 1 0 31.831 a 15.9155 15.9155 0 0 1 0 -31.831" fill="none" stroke="currentColor" stroke-width="5" />
 <path class="text-brand transition-all duration-1000 ease-out" 
 :stroke-dasharray="`${getSubjectStats(sub.slug, sub.question_count).progressPercentage}, 100`" 
 d="M18 2.0845 a 15.9155 15.9155 0 0 1 0 31.831 a 15.9155 15.9155 0 0 1 0 -31.831" 
 fill="none" stroke="currentColor" stroke-width="5" stroke-linecap="round" />
 </svg>
 <span v-if="getSubjectStats(sub.slug, sub.question_count).progressPercentage === 100" class="absolute text-brand">
 <svg class="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="3" d="M5 13l4 4L19 7" /></svg>
 </span>
 </div>
 </div>
 
 <h2 class="text-2xl font-extrabold text-txt-primary mb-3 group-hover:text-brand transition-colors">{{ sub.subject }}</h2>
 
 <div class="flex flex-wrap items-center gap-3 text-xs font-semibold text-txt-muted mb-6">
 <span class="flex items-center gap-1.5 bg-surface-hover text-txt-secondary px-2.5 py-1 rounded-md" title="Total Questions">
 <svg class="w-3.5 h-3.5" fill="none" viewBox="0 0 24 24" stroke="currentColor" aria-hidden="true"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 10h16M4 14h16M4 18h16" /></svg>
 {{ sub.question_count }} Total
 </span>
 <span v-if="getSubjectStats(sub.slug, sub.question_count).completed > 0" class="flex items-center gap-1.5 bg-emerald-50 text-emerald-700 px-2.5 py-1 rounded-md">
 <svg class="w-3.5 h-3.5" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M5 13l4 4L19 7" /></svg>
 {{ getSubjectStats(sub.slug, sub.question_count).completed }} Done
 </span>
 <span v-if="getSubjectStats(sub.slug, sub.question_count).bookmarked > 0" class="flex items-center gap-1.5 bg-amber-50 text-amber-700 px-2.5 py-1 rounded-md">
 <svg class="w-3.5 h-3.5" fill="currentColor" viewBox="0 0 24 24"><path d="M5 5a2 2 0 012-2h10a2 2 0 012 2v16l-7-3.5L5 21V5z" /></svg>
 {{ getSubjectStats(sub.slug, sub.question_count).bookmarked }} Saved
 </span>
 <span class="flex items-center gap-1.5 bg-surface-hover text-txt-secondary px-2.5 py-1 rounded-md" title="Estimated Time">
 <svg class="w-3.5 h-3.5" fill="none" viewBox="0 0 24 24" stroke="currentColor" aria-hidden="true"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" /></svg>
 ~{{ Math.max(1, Math.round(getSubjectStats(sub.slug, sub.question_count).remaining * 15 / 60)) }}h left
 </span>
 </div>
 </div>
 
 <div class="mt-auto pt-6 border-t border-border flex items-center justify-between">
 <span class="text-sm font-bold text-txt-disabled group-hover:text-txt-secondary transition-colors">Start Prep</span>
 <button class="inline-flex items-center justify-center bg-surface text-white px-6 py-3.5 rounded-xl text-sm font-bold group-hover:bg-brand transition-all shadow-md group-hover:shadow-brand/30 group-hover:scale-[1.02] active:scale-95" aria-label="Continue learning {{ sub.subject }}">
 {{ getSubjectStats(sub.slug, sub.question_count).completed > 0 ? 'Resume Learning' : 'Continue Learning' }}
 <svg class="w-4 h-4 ml-2 group-hover:translate-x-1.5 transition-transform duration-300" fill="none" viewBox="0 0 24 24" stroke="currentColor" aria-hidden="true">
 <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M14 5l7 7m0 0l-7 7m7-7H3" />
 </svg>
 </button>
 </div>
 </div>
 </div>
 
 <!-- Empty State -->
 <div v-else class="bg-surface rounded-3xl border border-dashed border-border-hover p-16 text-center max-w-2xl mx-auto mt-12 shadow-sm">
 <div class="w-24 h-24 mx-auto bg-background rounded-full flex items-center justify-center mb-6 border border-border">
 <svg class="w-10 h-10 text-txt-muted" fill="none" viewBox="0 0 24 24" stroke="currentColor" aria-hidden="true">
 <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
 </svg>
 </div>
 <h3 class="text-xl font-extrabold text-txt-primary mb-2">No subjects found</h3>
 <p class="text-base text-txt-muted max-w-md mx-auto">We couldn't find any subjects matching your search criteria. Try a different term.</p>
 <button @click="searchQuery = ''" class="mt-6 inline-flex items-center justify-center bg-surface border-2 border-border text-txt-secondary px-6 py-2.5 rounded-xl text-sm font-bold hover:bg-background hover:border-border-hover transition-all focus:outline-none focus:ring-4 focus:ring-slate-100">
 Clear Search
 </button>
 </div>
 </div>
 </AppShell>
</template>

<script setup>
import { ref, onMounted, computed } from 'vue'
import { useRouter } from 'vue-router'
import AppShell from '../../components/layout/AppShell.vue'
import interviewPrepService from '../../services/interviewPrepService'
import { useInterviewState } from './composables/useInterviewState'

const router = useRouter()
const subjects = ref([])
const loading = ref(true)
const searchQuery = ref('')
const toastMsg = ref('')
let toastTimer = null

const showToast = (msg) => {
 toastMsg.value = msg
 clearTimeout(toastTimer)
 toastTimer = setTimeout(() => { toastMsg.value = '' }, 3000)
}

const { getSubjectStats, totalBookmarkedCount, totalCompletedCount, continueLearning, recentlyViewed } = useInterviewState()

const totalQuestions = computed(() => {
 return subjects.value.reduce((acc, sub) => acc + (sub.question_count || 0), 0)
})

const remainingEstTime = computed(() => {
 const remainingQuestions = Math.max(0, totalQuestions.value - totalCompletedCount.value)
 return Math.max(1, Math.round(remainingQuestions * 15 / 60))
})

const globalProgressPercentage = computed(() => {
 if (totalQuestions.value === 0) return 0
 return Math.round((totalCompletedCount.value / totalQuestions.value) * 100)
})

const filteredSubjects = computed(() => {
 if (!searchQuery.value) return subjects.value
 const query = searchQuery.value.toLowerCase()
 return subjects.value.filter(sub => sub.subject.toLowerCase().includes(query))
})

const goToSubject = (slug) => {
 router.push({ name: 'interview-prep-subject', params: { subject: slug } })
}

onMounted(async () => {
 try {
 const { data } = await interviewPrepService.getSubjects()
 subjects.value = data.subjects || []
 } catch (error) {
 console.error('Failed to load subjects', error)
 } finally {
 loading.value = false
 }
})
</script>

<style scoped>
.hide-scrollbar::-webkit-scrollbar {
 display: none;
}
.hide-scrollbar {
 -ms-overflow-style: none;
 scrollbar-width: none;
}
</style>
