<template>
  <AppShell>
    <div class="max-w-6xl mx-auto space-y-8 animate-fade-in">
      <div class="flex flex-col md:flex-row md:items-center justify-between gap-4">
        <div>
          <h1 class="text-3xl md:text-4xl font-extrabold text-transparent bg-clip-text bg-gradient-to-r from-brand to-indigo-600">
            Interview Preparation
          </h1>
          <p class="mt-2 text-base text-slate-500">Master your technical interviews with our curated subject guides.</p>
        </div>
      </div>

      <div v-if="loading" class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        <div v-for="i in 3" :key="i" class="h-48 bg-slate-200 animate-pulse rounded-2xl"></div>
      </div>
      
      <div v-else-if="subjects.length" class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        <div v-for="sub in subjects" :key="sub.slug" 
             class="group relative bg-white rounded-3xl p-6 shadow-sm border border-slate-100 hover:shadow-xl hover:border-brand/30 transition-all duration-300 transform hover:-translate-y-1 overflow-hidden">
          <div class="absolute inset-0 bg-gradient-to-br from-brand/5 to-transparent opacity-0 group-hover:opacity-100 transition-opacity pointer-events-none"></div>
          
          <div class="relative z-10">
            <div class="w-14 h-14 rounded-2xl bg-brand/10 flex items-center justify-center mb-6 group-hover:scale-110 transition-transform duration-300">
              <span class="text-2xl font-bold text-brand">{{ sub.subject.charAt(0) }}</span>
            </div>
            
            <h2 class="text-xl font-bold text-slate-900 mb-2">{{ sub.subject }}</h2>
            <p class="text-sm font-medium text-slate-500 flex items-center gap-2">
              <span class="w-2 h-2 rounded-full bg-mint"></span>
              {{ sub.question_count }} Questions Available
            </p>
            
            <div class="mt-8">
              <RouterLink :to="{ name: 'interview-prep-subject', params: { subject: sub.slug } }" 
                          class="inline-flex items-center justify-center w-full bg-slate-900 text-white px-5 py-3 rounded-xl text-sm font-semibold group-hover:bg-brand transition-colors shadow-md">
                Start Learning
                <svg class="w-4 h-4 ml-2 group-hover:translate-x-1 transition-transform" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M14 5l7 7m0 0l-7 7m7-7H3" />
                </svg>
              </RouterLink>
            </div>
          </div>
        </div>
      </div>
      
      <div v-else class="bg-white rounded-3xl border border-dashed border-slate-300 p-12 text-center">
        <div class="w-20 h-20 mx-auto bg-slate-100 rounded-full flex items-center justify-center mb-4">
          <svg class="w-10 h-10 text-slate-400" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6.253v13m0-13C10.832 5.477 9.246 5 7.5 5S4.168 5.477 3 6.253v13C4.168 18.477 5.754 18 7.5 18s3.332.477 4.5 1.253m0-13C13.168 5.477 14.754 5 16.5 5c1.747 0 3.332.477 4.5 1.253v13C19.832 18.477 18.247 18 16.5 18c-1.746 0-3.332.477-4.5 1.253" />
          </svg>
        </div>
        <h3 class="text-lg font-bold text-slate-900">No Subjects Available</h3>
        <p class="text-sm text-slate-500 mt-2 max-w-md mx-auto">We are currently preparing more interview materials. Check back soon!</p>
      </div>
    </div>
  </AppShell>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import AppShell from '../../components/layout/AppShell.vue'
import interviewPrepService from '../../services/interviewPrepService'

const subjects = ref([])
const loading = ref(true)

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
