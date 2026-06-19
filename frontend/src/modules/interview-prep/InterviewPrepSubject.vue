<template>
  <AppShell>
    <div class="max-w-5xl mx-auto space-y-8 animate-fade-in">
      
      <!-- Breadcrumbs & Header -->
      <div class="flex flex-col md:flex-row md:items-end justify-between gap-4 border-b border-slate-200 pb-6">
        <div>
          <nav class="flex text-sm text-slate-500 mb-3" aria-label="Breadcrumb">
            <ol class="inline-flex items-center space-x-2">
              <li class="inline-flex items-center">
                <RouterLink :to="{ name: 'interview-prep' }" class="hover:text-brand transition-colors flex items-center">
                  <svg class="w-4 h-4 mr-2" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-6 0a1 1 0 001-1v-4a1 1 0 011-1h2a1 1 0 011 1v4a1 1 0 001 1m-6 0h6" /></svg>
                  Interview Prep
                </RouterLink>
              </li>
              <li>
                <div class="flex items-center">
                  <svg class="w-4 h-4 text-slate-400" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7" /></svg>
                  <span class="ml-2 text-slate-900 font-medium capitalize">{{ subjectTitle }}</span>
                </div>
              </li>
            </ol>
          </nav>
          <h1 class="text-3xl md:text-4xl font-extrabold text-slate-900">{{ subjectTitle }} Questions</h1>
        </div>
      </div>

      <!-- Filters -->
      <div v-if="questions.length > 0" class="flex flex-col sm:flex-row gap-4">
        <div class="flex-1">
          <label class="block text-xs font-bold text-slate-500 uppercase tracking-wider mb-1.5 ml-1">Filter by Topic</label>
          <div class="relative">
            <select v-model="selectedTopic" class="appearance-none w-full bg-white border border-slate-200 text-slate-700 text-sm font-medium rounded-xl pl-4 pr-10 py-3 focus:ring-2 focus:ring-brand/50 focus:border-brand outline-none transition-all shadow-sm cursor-pointer hover:border-brand/30">
              <option value="">All Topics</option>
              <option v-for="topic in uniqueTopics" :key="topic" :value="topic">{{ topic }}</option>
            </select>
            <div class="pointer-events-none absolute inset-y-0 right-0 flex items-center px-4 text-slate-400">
              <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7"></path></svg>
            </div>
          </div>
        </div>
        <div class="flex-1">
          <label class="block text-xs font-bold text-slate-500 uppercase tracking-wider mb-1.5 ml-1">Filter by Difficulty</label>
          <div class="relative">
            <select v-model="selectedDifficulty" class="appearance-none w-full bg-white border border-slate-200 text-slate-700 text-sm font-medium rounded-xl pl-4 pr-10 py-3 focus:ring-2 focus:ring-brand/50 focus:border-brand outline-none transition-all shadow-sm cursor-pointer hover:border-brand/30">
              <option value="">All Difficulties</option>
              <option v-for="diff in uniqueDifficulties" :key="diff" :value="diff">{{ diff }}</option>
            </select>
            <div class="pointer-events-none absolute inset-y-0 right-0 flex items-center px-4 text-slate-400">
              <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7"></path></svg>
            </div>
          </div>
        </div>
      </div>

      <!-- Content -->
      <div v-if="loading" class="space-y-4">
        <div v-for="i in 4" :key="i" class="h-24 bg-slate-100 animate-pulse rounded-2xl"></div>
      </div>
      
      <div v-else-if="questions.length" class="space-y-4">
        <div v-if="filteredQuestions.length === 0" class="bg-slate-50 rounded-2xl border border-slate-200 p-10 text-center">
          <p class="text-slate-500 font-medium">No questions match your selected filters.</p>
          <button @click="selectedTopic = ''; selectedDifficulty = ''" class="mt-3 text-brand hover:underline font-semibold text-sm">Clear filters</button>
        </div>
        <RouterLink 
          v-for="q in filteredQuestions" :key="q.id"
          :to="{ name: 'interview-prep-question', params: { subject: route.params.subject, question_id: q.id } }"
          class="group block bg-white rounded-2xl p-5 shadow-sm border border-slate-200 hover:shadow-lg hover:border-brand/40 transition-all duration-300 transform hover:-translate-y-1"
        >
          <div class="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
            <div class="flex-1 min-w-0">
              <h3 class="text-lg font-bold text-slate-900 group-hover:text-brand transition-colors truncate">{{ q.title }}</h3>
              <div class="mt-2 flex items-center gap-3 text-sm text-slate-500">
                <span 
                  class="inline-flex items-center rounded-full px-2.5 py-0.5 text-xs font-semibold"
                  :class="{
                    'bg-green-100 text-green-700': q.difficulty === 'Easy',
                    'bg-yellow-100 text-yellow-700': q.difficulty === 'Intermediate',
                    'bg-red-100 text-red-700': q.difficulty === 'Hard'
                  }"
                >
                  {{ q.difficulty }}
                </span>
                <span class="flex items-center gap-1">
                  <svg class="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 7h.01M7 3h5c.512 0 1.024.195 1.414.586l7 7a2 2 0 010 2.828l-7 7a2 2 0 01-2.828 0l-7-7A1.994 1.994 0 013 12V7a4 4 0 014-4z" /></svg>
                  {{ q.topic }}
                </span>
              </div>
            </div>
            <div class="shrink-0 flex items-center">
              <span class="text-brand font-semibold text-sm group-hover:mr-2 transition-all">View Answer</span>
              <svg class="w-5 h-5 text-brand opacity-0 group-hover:opacity-100 transition-opacity" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7" />
              </svg>
            </div>
          </div>
        </RouterLink>
      </div>

      <div v-else class="bg-white rounded-3xl border border-dashed border-slate-300 p-12 text-center">
        <p class="text-slate-500 text-lg">No questions available for this subject yet.</p>
        <RouterLink :to="{ name: 'interview-prep' }" class="mt-4 inline-block text-brand hover:underline font-semibold">
          ← Back to Subjects
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

const route = useRoute()
const questions = ref([])
const subjectTitle = ref(route.params.subject)
const loading = ref(true)

const selectedTopic = ref('')
const selectedDifficulty = ref('')

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
