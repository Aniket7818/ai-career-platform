<template>
  <AppShell>
    <div class="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-8 animate-fade-in pb-16">
      
      <!-- Breadcrumbs -->
      <nav class="flex text-xs font-bold text-slate-400 mb-8 uppercase tracking-wider" aria-label="Breadcrumb">
        <ol class="flex flex-wrap items-center gap-2 sm:gap-2.5">
          <li class="flex items-center">
            <RouterLink :to="{ name: 'interview-prep' }" class="hover:text-brand transition-colors flex items-center">
              <span class="leading-none pt-0.5">Dashboard</span>
            </RouterLink>
          </li>
          <li class="flex items-center text-slate-300">
            <svg class="w-3.5 h-3.5 shrink-0" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="3" d="M9 5l7 7-7 7" /></svg>
          </li>
          <li class="flex items-center">
            <span class="text-slate-800 leading-none pt-0.5">{{ pageTitle }}</span>
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
            <h1 class="text-3xl font-extrabold text-slate-900 dark:text-white">{{ pageTitle }}</h1>
            <p class="text-sm font-bold text-slate-500 dark:text-slate-400 mt-1">{{ filteredItems.length }} Questions</p>
          </div>
        </div>
      </header>

      <div v-if="loading" class="space-y-4">
        <div v-for="i in 5" :key="i" class="h-24 bg-slate-100 animate-pulse rounded-2xl border border-slate-200/50"></div>
      </div>
      
      <!-- List View -->
      <div v-else-if="filteredItems.length > 0" class="bg-white dark:bg-slate-900 rounded-3xl border border-slate-200/60 dark:border-slate-800/60 shadow-sm overflow-hidden">
        <div class="divide-y divide-slate-100 dark:divide-slate-800/80">
          <div v-for="item in filteredItems" :key="item.questionId" class="group transition-colors hover:bg-slate-50 dark:hover:bg-slate-800/50 relative">
            <RouterLink 
              :to="{ name: 'interview-prep-question', params: { subject: item.subjectSlug, question_id: item.questionId } }" 
              class="block p-4 sm:p-6 focus:outline-none focus:bg-slate-50 dark:focus:bg-slate-800/50"
            >
              <div class="flex flex-col sm:flex-row sm:items-center gap-4">
                
                <!-- Topic & Difficulty Badges -->
                <div class="shrink-0 w-full sm:w-32 flex flex-row sm:flex-col gap-2">
                  <span class="inline-flex items-center text-[10px] font-black uppercase tracking-wider text-slate-500 dark:text-slate-400 bg-slate-100 dark:bg-slate-800 px-2.5 py-1 rounded-md border border-slate-200/50 dark:border-slate-700/50 w-fit">
                    {{ item.subjectSlug }}
                  </span>
                  <span class="inline-flex items-center text-[10px] font-black uppercase tracking-wider px-2.5 py-1 rounded-md border w-fit"
                    :class="{
                      'bg-emerald-50 text-emerald-700 border-emerald-200/50 dark:bg-emerald-500/10 dark:text-emerald-400 dark:border-emerald-500/20': item.difficulty === 'Easy',
                      'bg-amber-50 text-amber-700 border-amber-200/50 dark:bg-amber-500/10 dark:text-amber-400 dark:border-amber-500/20': item.difficulty === 'Intermediate',
                      'bg-rose-50 text-rose-700 border-rose-200/50 dark:bg-rose-500/10 dark:text-rose-400 dark:border-rose-500/20': item.difficulty === 'Hard',
                      'bg-slate-50 text-slate-600 border-slate-200/50 dark:bg-slate-800 dark:text-slate-400 dark:border-slate-700': !item.difficulty
                    }">
                    {{ item.difficulty || 'Mixed' }}
                  </span>
                </div>
                
                <!-- Title -->
                <div class="flex-1 min-w-0 pr-4">
                  <h3 class="text-base sm:text-lg font-bold text-slate-900 dark:text-slate-100 group-hover:text-brand dark:group-hover:text-brand transition-colors mb-1 truncate">{{ item.title }}</h3>
                  <div class="flex items-center gap-3">
                    <span v-if="item.topic" class="text-xs font-semibold text-slate-500 dark:text-slate-400">{{ item.topic }}</span>
                  </div>
                </div>

                <!-- Actions -->
                <div class="shrink-0 flex items-center justify-between sm:justify-end border-t sm:border-t-0 border-slate-100 dark:border-slate-800/80 pt-4 sm:pt-0">
                  <div class="flex items-center gap-4">
                    <div v-if="isCompleted(item.subjectSlug, item.questionId)" class="flex items-center gap-1 text-emerald-500 text-xs font-bold bg-emerald-50 dark:bg-emerald-500/10 px-2 py-1 rounded-lg">
                      <svg class="w-3.5 h-3.5" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M5 13l4 4L19 7" /></svg>
                      Done
                    </div>
                    <button class="p-1.5 rounded-lg transition-colors text-amber-500 bg-amber-50 dark:bg-amber-500/10 hover:bg-amber-100 dark:hover:bg-amber-500/20" v-if="isBookmarked(item.subjectSlug, item.questionId)" @click="toggleBookmark($event, item.subjectSlug, item.questionId)" title="Remove Bookmark">
                      <svg class="w-5 h-5" fill="currentColor" viewBox="0 0 24 24"><path d="M5 5a2 2 0 012-2h10a2 2 0 012 2v16l-7-3.5L5 21V5z" /></svg>
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
        </div>
      </div>

      <!-- Empty State -->
      <div v-else class="text-center py-32 bg-white dark:bg-slate-900 rounded-3xl border border-dashed border-slate-300 dark:border-slate-700 shadow-sm mt-8">
        <div class="w-24 h-24 mx-auto rounded-full flex items-center justify-center mb-6 border" :class="emptyIconBgClass">
          <svg class="w-10 h-10" :class="emptyIconTextClass" fill="none" viewBox="0 0 24 24" stroke="currentColor" v-html="headerIconPath"></svg>
        </div>
        <h3 class="text-2xl font-extrabold text-slate-900 dark:text-white mb-2">{{ emptyTitle }}</h3>
        <p class="text-slate-500 dark:text-slate-400 mb-8 max-w-md mx-auto">{{ emptyDesc }}</p>
        <RouterLink :to="{ name: 'interview-prep' }" class="inline-flex rounded-xl bg-slate-900 px-6 py-3 text-sm font-bold text-white shadow-md hover:bg-brand transition-colors">
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
  return 'bg-slate-100 border-slate-200'
})

const headerIconTextClass = computed(() => {
  if (pageType.value === 'bookmarks') return 'text-amber-500'
  if (pageType.value === 'completed') return 'text-emerald-500'
  return 'text-slate-500'
})

const emptyIconBgClass = computed(() => {
  if (pageType.value === 'bookmarks') return 'bg-amber-50 border-amber-100'
  if (pageType.value === 'completed') return 'bg-emerald-50 border-emerald-100'
  return 'bg-slate-50 border-slate-200'
})

const emptyIconTextClass = computed(() => {
  if (pageType.value === 'bookmarks') return 'text-amber-300'
  if (pageType.value === 'completed') return 'text-emerald-300'
  return 'text-slate-300'
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
