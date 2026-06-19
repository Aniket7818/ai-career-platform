<template>
  <AppShell>
    <div class="max-w-4xl mx-auto space-y-6 animate-fade-in pb-12">
      <!-- Breadcrumbs -->
      <nav class="flex text-sm text-slate-500 mb-6" aria-label="Breadcrumb">
        <ol class="inline-flex items-center space-x-2">
          <li class="inline-flex items-center">
            <RouterLink :to="{ name: 'interview-prep' }" class="hover:text-brand transition-colors">Interview Prep</RouterLink>
          </li>
          <li>
            <div class="flex items-center">
              <svg class="w-4 h-4 text-slate-400" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7" /></svg>
              <RouterLink :to="{ name: 'interview-prep-subject', params: { subject: route.params.subject } }" class="ml-2 hover:text-brand capitalize transition-colors">
                {{ route.params.subject }}
              </RouterLink>
            </div>
          </li>
          <li v-if="question && totalQuestions > 0">
            <div class="flex items-center">
              <svg class="w-4 h-4 text-slate-400" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7" /></svg>
              <span class="ml-2 text-slate-900 font-medium truncate max-w-[150px] sm:max-w-none">
                Question {{ currentIndex + 1 }} of {{ totalQuestions }}
              </span>
            </div>
          </li>
        </ol>
      </nav>

      <div v-if="loading" class="space-y-4">
        <div class="h-32 bg-slate-100 animate-pulse rounded-2xl"></div>
        <div class="h-64 bg-slate-100 animate-pulse rounded-2xl"></div>
      </div>
      
      <div v-else-if="question" class="bg-white rounded-3xl shadow-panel border border-slate-200 overflow-hidden relative">
        <!-- Accent Top Bar -->
        <div class="absolute top-0 left-0 w-full h-1 bg-gradient-to-r from-brand via-indigo-500 to-mint"></div>
        
        <!-- Header Section -->
        <div class="p-6 md:p-8 border-b border-slate-100 bg-slate-50/50">
          <div class="flex flex-wrap items-center gap-3 mb-4">
            <span 
              class="inline-flex items-center rounded-full px-3 py-1 text-xs font-bold uppercase tracking-wider shadow-sm"
              :class="{
                'bg-green-100 text-green-700': question.difficulty === 'Easy',
                'bg-yellow-100 text-yellow-700': question.difficulty === 'Intermediate',
                'bg-red-100 text-red-700': question.difficulty === 'Hard'
              }"
            >
              {{ question.difficulty }}
            </span>
            <span class="inline-flex items-center text-sm font-semibold text-slate-600 bg-white border border-slate-200 rounded-full px-3 py-1 shadow-sm">
              <svg class="w-4 h-4 mr-1 text-brand" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 7h.01M7 3h5c.512 0 1.024.195 1.414.586l7 7a2 2 0 010 2.828l-7 7a2 2 0 01-2.828 0l-7-7A1.994 1.994 0 013 12V7a4 4 0 014-4z" /></svg>
              {{ question.topic }}
            </span>
          </div>
          <h1 class="text-2xl md:text-3xl font-extrabold text-slate-900 leading-tight">{{ question.title }}</h1>
          <div class="mt-6 p-5 bg-white rounded-2xl border border-slate-200 shadow-sm relative">
            <div class="absolute -top-3 -left-2 text-4xl text-brand/20 select-none font-serif">"</div>
            <p class="text-lg md:text-xl text-slate-800 font-medium relative z-10">{{ question.question }}</p>
          </div>
        </div>
        
        <!-- Content Section -->
        <div class="p-6 md:p-8 space-y-10">
          
          <!-- Answer -->
          <section>
            <h3 class="flex items-center text-lg font-bold text-slate-900 mb-4 pb-2 border-b border-slate-100">
              <span class="w-8 h-8 rounded-lg bg-emerald-100 text-emerald-600 flex items-center justify-center mr-3">
                <svg class="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7" /></svg>
              </span>
              Answer
            </h3>
            <p class="text-slate-700 leading-relaxed whitespace-pre-wrap text-[15px]">{{ question.answer }}</p>
          </section>

          <!-- Explanation -->
          <section v-if="question.explanation">
            <h3 class="flex items-center text-lg font-bold text-slate-900 mb-4 pb-2 border-b border-slate-100">
              <span class="w-8 h-8 rounded-lg bg-blue-100 text-blue-600 flex items-center justify-center mr-3">
                <svg class="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" /></svg>
              </span>
              Explanation
            </h3>
            <p class="text-slate-700 leading-relaxed whitespace-pre-wrap text-[15px]">{{ question.explanation }}</p>
          </section>

          <!-- Code Example -->
          <section v-if="question.code_example">
            <h3 class="flex items-center text-lg font-bold text-slate-900 mb-4">
              <span class="w-8 h-8 rounded-lg bg-purple-100 text-purple-600 flex items-center justify-center mr-3">
                <svg class="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 20l4-16m4 4l4 4-4 4M6 16l-4-4 4-4" /></svg>
              </span>
              Code Example
            </h3>
            <div class="relative group">
              <div class="absolute inset-0 bg-gradient-to-r from-purple-500 to-brand opacity-20 blur-lg rounded-xl group-hover:opacity-30 transition-opacity"></div>
              <div class="relative rounded-xl overflow-hidden bg-[#0f172a] shadow-xl border border-white/10">
                <div class="flex items-center px-4 py-2 bg-white/5 border-b border-white/10">
                  <div class="flex space-x-2">
                    <div class="w-3 h-3 rounded-full bg-red-500"></div>
                    <div class="w-3 h-3 rounded-full bg-yellow-500"></div>
                    <div class="w-3 h-3 rounded-full bg-green-500"></div>
                  </div>
                </div>
                <pre class="p-5 overflow-x-auto text-sm text-slate-300 font-mono leading-relaxed"><code>{{ question.code_example }}</code></pre>
              </div>
            </div>
          </section>

          <!-- Key Takeaways -->
          <section v-if="question.key_takeaways && question.key_takeaways.length > 0">
            <div class="bg-brand/5 rounded-2xl p-6 border border-brand/10">
              <h3 class="flex items-center text-lg font-bold text-slate-900 mb-4">
                <span class="w-8 h-8 rounded-lg bg-amber-100 text-amber-600 flex items-center justify-center mr-3">
                  <svg class="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 10V3L4 14h7v7l9-11h-7z" /></svg>
                </span>
                Key Takeaways
              </h3>
              <ul class="space-y-3">
                <li v-for="(takeaway, idx) in question.key_takeaways" :key="idx" class="flex items-start">
                  <svg class="w-5 h-5 text-brand shrink-0 mr-3 mt-0.5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
                  </svg>
                  <span class="text-slate-700 leading-relaxed">{{ takeaway }}</span>
                </li>
              </ul>
            </div>
          </section>
        </div>
        
        <!-- Footer Pagination Navigation -->
        <div class="p-6 md:p-8 border-t border-slate-100 bg-slate-50 flex flex-col sm:flex-row items-center justify-between gap-5">
          <RouterLink :to="{ name: 'interview-prep-subject', params: { subject: route.params.subject } }" class="inline-flex items-center text-sm font-bold text-slate-600 hover:text-brand transition-colors order-2 sm:order-1 w-full sm:w-auto justify-center">
            <svg class="w-4 h-4 mr-2" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 19l-7-7m0 0l7-7m-7 7h18" /></svg>
            Subject View
          </RouterLink>

          <div class="flex items-center gap-2 order-1 sm:order-2 w-full sm:w-auto justify-between sm:justify-end">
            <!-- Prev Button -->
            <RouterLink 
              v-if="hasPrev"
              :to="{ name: 'interview-prep-question', params: { subject: route.params.subject, question_id: prevQuestionId } }"
              class="inline-flex items-center justify-center bg-white border border-slate-200 text-slate-700 hover:bg-slate-50 hover:text-brand px-3 py-2.5 sm:px-4 rounded-xl text-sm font-semibold transition-all shadow-sm"
            >
              <svg class="w-4 h-4 mr-1.5" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7" /></svg>
              Prev
            </RouterLink>
            <button 
              v-else
              disabled
              class="inline-flex items-center justify-center bg-slate-100 border border-slate-200 text-slate-400 px-3 py-2.5 sm:px-4 rounded-xl text-sm font-semibold cursor-not-allowed opacity-70"
            >
              <svg class="w-4 h-4 mr-1.5" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7" /></svg>
              Prev
            </button>

            <!-- Jump Menu -->
            <div class="relative flex items-center mx-1 flex-1 sm:flex-none">
              <select 
                class="appearance-none w-full bg-white border border-slate-200 text-slate-700 text-sm font-semibold rounded-xl pl-4 pr-10 py-2.5 shadow-sm focus:outline-none focus:ring-2 focus:ring-brand/50 focus:border-brand cursor-pointer hover:bg-slate-50 transition-colors"
                @change="jumpToQuestion"
                :value="question.id"
              >
                <option v-for="(q, idx) in allQuestions" :key="q.id" :value="q.id">
                  {{ idx + 1 }} of {{ totalQuestions }}
                </option>
              </select>
              <div class="pointer-events-none absolute inset-y-0 right-0 flex items-center px-3 text-slate-500">
                <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 9l4-4 4 4m0 6l-4 4-4-4"></path></svg>
              </div>
            </div>

            <!-- Next Button -->
            <RouterLink 
              v-if="hasNext"
              :to="{ name: 'interview-prep-question', params: { subject: route.params.subject, question_id: nextQuestionId } }"
              class="inline-flex items-center justify-center bg-brand text-white hover:bg-indigo-600 px-3 py-2.5 sm:px-4 rounded-xl text-sm font-semibold transition-all shadow-md hover:shadow-lg"
            >
              Next
              <svg class="w-4 h-4 ml-1.5" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7" /></svg>
            </RouterLink>
            <button 
              v-else
              disabled
              class="inline-flex items-center justify-center bg-slate-100 border border-slate-200 text-slate-400 px-3 py-2.5 sm:px-4 rounded-xl text-sm font-semibold cursor-not-allowed opacity-70"
            >
              Next
              <svg class="w-4 h-4 ml-1.5" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7" /></svg>
            </button>
          </div>
        </div>
      </div>
      
      <div v-else class="text-center py-20">
        <h3 class="text-xl font-bold text-slate-900 mb-2">Question not found</h3>
        <p class="text-slate-500">The question you're looking for doesn't exist or has been removed.</p>
        <RouterLink :to="{ name: 'interview-prep' }" class="mt-6 inline-flex rounded-xl bg-brand px-5 py-3 text-sm font-semibold text-white shadow-md">
          Return to Subjects
        </RouterLink>
      </div>
    </div>
  </AppShell>
</template>

<script setup>
import { ref, onMounted, computed, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import AppShell from '../../components/layout/AppShell.vue'
import interviewPrepService from '../../services/interviewPrepService'

const route = useRoute()
const router = useRouter()
const question = ref(null)
const allQuestions = ref([])
const loading = ref(true)

const loadData = async () => {
  loading.value = true
  try {
    const { data } = await interviewPrepService.getSubjectQuestions(route.params.subject)
    allQuestions.value = data.questions || []
    await fetchCurrentQuestionDetails()
  } catch (error) {
    console.error('Failed to load questions context', error)
    loading.value = false
  }
}

const fetchCurrentQuestionDetails = async () => {
  if (allQuestions.value.length === 0) {
    loading.value = false
    return
  }
  loading.value = true
  try {
    const { data } = await interviewPrepService.getQuestion(route.params.subject, route.params.question_id)
    question.value = data.question
  } catch (error) {
    console.error('Failed to load question details', error)
  } finally {
    loading.value = false
  }
}

watch(() => route.params.question_id, () => {
  if (route.name === 'interview-prep-question') {
    fetchCurrentQuestionDetails()
  }
})

onMounted(() => {
  loadData()
})

const currentIndex = computed(() => {
  if (!question.value || allQuestions.value.length === 0) return -1
  const currentId = String(question.value.id)
  return allQuestions.value.findIndex(q => String(q.id) === currentId)
})

const totalQuestions = computed(() => allQuestions.value.length)
const hasPrev = computed(() => currentIndex.value > 0)
const hasNext = computed(() => currentIndex.value >= 0 && currentIndex.value < totalQuestions.value - 1)

const prevQuestionId = computed(() => {
  if (hasPrev.value) return allQuestions.value[currentIndex.value - 1].id
  return null
})

const nextQuestionId = computed(() => {
  if (hasNext.value) return allQuestions.value[currentIndex.value + 1].id
  return null
})

const jumpToQuestion = (event) => {
  const id = event.target.value
  if (id) {
    router.push({ name: 'interview-prep-question', params: { subject: route.params.subject, question_id: id } })
  }
}
</script>
