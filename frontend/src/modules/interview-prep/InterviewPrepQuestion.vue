<template>
  <AppShell>
    <!-- Lightweight Toast -->
    <Transition name="fade">
      <div v-if="toastMsg" class="fixed top-4 right-4 z-[100] bg-slate-900 text-white px-4 py-3 rounded-xl shadow-2xl flex items-center gap-3">
        <svg class="w-5 h-5 text-emerald-400" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" /></svg>
        <span class="text-sm font-bold">{{ toastMsg }}</span>
      </div>
    </Transition>

    <!-- Top Progress Bar (Visual Only) -->
    <div class="fixed top-0 left-0 right-0 h-1 bg-slate-100 dark:bg-slate-800 z-50">
      <div class="h-full bg-brand transition-all duration-500 ease-out" :style="{ width: `${((currentIndex + 1) / totalQuestions) * 100}%` }"></div>
    </div>

    <div class="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 pt-4 pb-40 md:py-8 md:pb-12 animate-fade-in">
      
      <!-- Breadcrumbs -->
      <nav class="flex text-xs font-bold text-slate-400 mb-4 md:mb-8 uppercase tracking-wider" aria-label="Breadcrumb">
        <ol class="flex flex-wrap items-center gap-2 sm:gap-2.5">
          <li class="flex items-center">
            <RouterLink :to="{ name: 'interview-prep' }" class="hover:text-brand transition-colors flex items-center">
              <span class="leading-none pt-0.5">Library</span>
            </RouterLink>
          </li>
          <li class="flex items-center text-slate-300">
            <svg class="w-3.5 h-3.5 shrink-0" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="3" d="M9 5l7 7-7 7" /></svg>
          </li>
          <li class="flex items-center">
            <RouterLink :to="{ name: 'interview-prep-subject', params: { subject: route.params.subject } }" class="hover:text-brand transition-colors capitalize flex items-center">
              <span class="leading-none pt-0.5">{{ route.params.subject }}</span>
            </RouterLink>
          </li>
          <li v-if="question && totalQuestions > 0" class="hidden sm:flex items-center text-slate-300">
            <svg class="w-3.5 h-3.5 shrink-0" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="3" d="M9 5l7 7-7 7" /></svg>
          </li>
          <li v-if="question && totalQuestions > 0" class="hidden sm:flex items-center">
            <span class="text-slate-800 leading-none pt-0.5">Q{{ currentIndex + 1 }}</span>
          </li>
        </ol>
      </nav>

      <div v-if="loading" class="space-y-6">
        <div class="h-40 bg-slate-100 animate-pulse rounded-3xl"></div>
        <div class="h-96 bg-slate-100 animate-pulse rounded-3xl"></div>
      </div>
      
      <div v-else-if="question" class="space-y-8">
        
        <!-- Header Section -->
        <header class="space-y-6">
          <div class="flex flex-wrap items-center justify-between gap-4">
            <div class="flex flex-wrap items-center gap-3">
              <span 
                class="inline-flex items-center rounded-md px-2.5 py-1 text-xs font-black uppercase tracking-wider"
                :class="{
                  'bg-emerald-50 text-emerald-700 border border-emerald-200/50 dark:bg-emerald-500/10 dark:text-emerald-400 dark:border-emerald-500/20': question.difficulty === 'Easy',
                  'bg-amber-50 text-amber-700 border border-amber-200/50 dark:bg-amber-500/10 dark:text-amber-400 dark:border-amber-500/20': question.difficulty === 'Intermediate',
                  'bg-rose-50 text-rose-700 border border-rose-200/50 dark:bg-rose-500/10 dark:text-rose-400 dark:border-rose-500/20': question.difficulty === 'Hard'
                }"
              >
                {{ question.difficulty }}
              </span>
              <span class="inline-flex items-center text-xs font-bold text-slate-600 dark:text-slate-400 bg-slate-100 dark:bg-slate-800 rounded-md px-2.5 py-1 border border-slate-200/50 dark:border-slate-700/50">
                {{ question.topic }}
              </span>
              <span v-if="question.isHighFrequency" class="inline-flex items-center text-xs font-bold text-amber-600 bg-amber-50 rounded-md px-2.5 py-1 border border-amber-200/50">
                <svg class="w-3.5 h-3.5 mr-1" fill="currentColor" viewBox="0 0 20 20"><path d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 00.95.69h3.462c.969 0 1.371 1.24.588 1.81l-2.8 2.034a1 1 0 00-.364 1.118l1.07 3.292c.3.921-.755 1.688-1.54 1.118l-2.8-2.034a1 1 0 00-1.175 0l-2.8 2.034c-.784.57-1.838-.197-1.539-1.118l1.07-3.292a1 1 0 00-.364-1.118L2.98 8.72c-.783-.57-.38-1.81.588-1.81h3.461a1 1 0 00.951-.69l1.07-3.292z"/></svg>
                High Frequency
              </span>
            </div>
            
            <div class="flex items-center gap-2 hidden md:flex">
              <button @click="shareQuestion" class="p-2 text-slate-400 hover:text-brand hover:bg-brand/5 rounded-xl transition-all focus:outline-none focus:ring-2 focus:ring-brand/20" title="Share" aria-label="Share Question">
                <svg class="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8.684 13.342C8.886 12.938 9 12.482 9 12c0-.482-.114-.938-.316-1.342m0 2.684a3 3 0 110-5.368m0 5.368l5.662 3.397m-5.662-3.397l5.662-3.397m-.002-3.411a3 3 0 11-5.65 0 3 3 0 015.65 0z" /></svg>
              </button>
              <button @click="toggleBookmark" class="p-2 rounded-xl transition-all focus:outline-none focus:ring-2 focus:ring-amber-200" :class="isBookmarked ? 'text-amber-500 bg-amber-50' : 'text-slate-400 hover:text-amber-500 hover:bg-amber-50'" title="Bookmark" aria-label="Bookmark Question">
                <svg class="w-5 h-5" :fill="isBookmarked ? 'currentColor' : 'none'" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 5a2 2 0 012-2h10a2 2 0 012 2v16l-7-3.5L5 21V5z" /></svg>
              </button>
              <button @click="toggleComplete" class="flex items-center gap-2 px-3 py-1.5 rounded-xl font-bold text-sm transition-colors focus:outline-none focus:ring-2 focus:ring-emerald-200" :class="isCompleted ? 'bg-emerald-500 text-white hover:bg-emerald-600' : 'bg-slate-100 text-slate-600 hover:bg-slate-200'">
                <svg class="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M5 13l4 4L19 7" /></svg>
                {{ isCompleted ? 'Completed' : 'Mark Complete' }}
              </button>
            </div>
          </div>
          
          <h1 class="text-3xl md:text-4xl font-extrabold text-slate-900 dark:text-white leading-tight">{{ question.title }}</h1>
        </header>

        <!-- Question Box -->
        <div class="p-6 md:p-8 bg-slate-900 text-white rounded-3xl shadow-xl relative overflow-hidden">
          <div class="absolute -right-10 -top-10 w-40 h-40 bg-brand/30 rounded-full blur-3xl"></div>
          <div class="relative z-10 flex gap-4">
            <div class="shrink-0 text-brand/80 hidden sm:block">
              <svg class="w-8 h-8" fill="currentColor" viewBox="0 0 24 24"><path d="M14.017 21v-7.391c0-5.704 3.731-9.57 8.983-10.609l.995 2.151c-2.432.917-3.995 3.638-3.995 5.849h4v10h-9.983zm-14.017 0v-7.391c0-5.704 3.748-9.57 9-10.609l.996 2.151c-2.433.917-3.996 3.638-3.996 5.849h3.983v10h-9.983z" /></svg>
            </div>
            <p class="text-lg md:text-xl font-medium leading-relaxed md:leading-loose">{{ question.question }}</p>
          </div>
        </div>
        
        <article class="prose prose-slate max-w-none prose-p:leading-relaxed prose-headings:font-extrabold prose-a:text-brand prose-a:no-underline hover:prose-a:underline">
          <!-- Answer Section -->
          <div class="mb-8 mt-4 md:mt-8">
            <h2 class="text-xl md:text-2xl font-extrabold text-slate-900 dark:text-white mb-4 md:mb-6 flex items-center gap-3">
              <span class="w-8 h-8 md:w-10 md:h-10 rounded-xl bg-indigo-50 dark:bg-indigo-500/10 text-indigo-600 dark:text-indigo-400 flex items-center justify-center shadow-sm">
                <svg class="w-4 h-4 md:w-5 md:h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" /></svg>
              </span>
              Solution
            </h2>
            <div class="bg-white dark:bg-slate-900 rounded-2xl md:rounded-3xl p-5 md:p-8 shadow-sm border border-slate-200/60 dark:border-slate-800/60 text-slate-700 dark:text-slate-300 space-y-6">
              
              <!-- Parsed Answer Sections -->
              <div v-for="(section, sIdx) in parsedAnswerSections" :key="sIdx" class="space-y-2">
                <h4 v-if="section.title" class="text-base font-bold text-slate-900 dark:text-white">{{ section.title }}</h4>
                <p class="whitespace-pre-wrap">{{ section.content }}</p>
              </div>
              
              <div v-if="question.explanation" class="mt-8 pt-8 border-t border-slate-100 dark:border-slate-800">
                <h3 class="text-lg font-bold text-slate-900 dark:text-white mb-4 flex items-center gap-2">
                  <svg class="w-5 h-5 text-brand" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M9.663 17h4.673M12 3v1m6.364 1.636l-.707.707M21 12h-1M4 12H3m3.343-5.657l-.707-.707m2.828 9.9a5 5 0 117.072 0l-.548.547A3.374 3.374 0 0014 18.469V19a2 2 0 11-4 0v-.531c0-.895-.356-1.754-.988-2.386l-.548-.547z" /></svg>
                  Detailed Explanation
                </h3>
                <p class="whitespace-pre-wrap text-slate-600 dark:text-slate-400">{{ question.explanation }}</p>
              </div>
            </div>
          </div>

          <!-- Code Example -->
          <div v-if="question.code_example" class="mb-8 md:mb-10 mt-6 md:mt-0">
            <h2 class="text-xl md:text-2xl font-extrabold text-slate-900 dark:text-white mb-4 md:mb-6 flex items-center gap-3">
              <span class="w-8 h-8 md:w-10 md:h-10 rounded-xl bg-slate-900 text-white flex items-center justify-center shadow-sm">
                <svg class="w-4 h-4 md:w-5 md:h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M10 20l4-16m4 4l4 4-4 4M6 16l-4-4 4-4" /></svg>
              </span>
              Implementation
            </h2>
            
            <div class="group relative rounded-2xl md:rounded-3xl overflow-hidden bg-[#0f172a] shadow-2xl border border-white/10">
              <!-- Code Header -->
              <div class="flex items-center justify-between px-4 py-3 bg-white/5 border-b border-white/10">
                <div class="flex items-center gap-3">
                  <div class="flex space-x-2">
                    <div class="w-3 h-3 rounded-full bg-rose-500/80"></div>
                    <div class="w-3 h-3 rounded-full bg-amber-500/80"></div>
                    <div class="w-3 h-3 rounded-full bg-emerald-500/80"></div>
                  </div>
                  <span class="text-[10px] font-bold tracking-wider text-slate-400 uppercase bg-white/10 px-2 py-0.5 rounded">{{ languageBadge }}</span>
                </div>
                <div class="flex items-center gap-3">
                  <button @click="copyCode" class="flex items-center gap-1.5 text-xs font-bold text-slate-400 hover:text-white transition-colors focus:outline-none" aria-label="Copy code to clipboard">
                    <svg v-if="copied" class="w-4 h-4 text-emerald-400" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7" /></svg>
                    <svg v-else class="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 16H6a2 2 0 01-2-2V6a2 2 0 012-2h8a2 2 0 012 2v2m-6 12h8a2 2 0 002-2v-8a2 2 0 00-2-2h-8a2 2 0 00-2 2v8a2 2 0 002 2z" /></svg>
                    {{ copied ? 'Copied!' : 'Copy Code' }}
                  </button>
                </div>
              </div>
              <div class="relative" :class="{ 'max-h-[500px] overflow-hidden': !isCodeExpanded }">
                <pre class="p-6 overflow-x-auto text-sm text-slate-300 font-mono leading-relaxed"><code class="block min-w-full">{{ question.code_example }}</code></pre>
                
                <!-- Expand Overlay -->
                <div v-if="!isCodeExpanded" class="absolute bottom-0 left-0 right-0 h-32 bg-gradient-to-t from-[#0f172a] to-transparent flex items-end justify-center pb-4">
                  <button @click="isCodeExpanded = true" class="bg-white/10 hover:bg-white/20 text-white backdrop-blur-md px-4 py-2 rounded-xl text-xs font-bold transition-colors shadow-lg border border-white/10 focus:outline-none focus:ring-2 focus:ring-white/20">
                    Expand Full Code
                  </button>
                </div>
              </div>
              <div v-if="isCodeExpanded" class="px-6 pb-4 flex justify-center bg-[#0f172a] border-t border-white/5 pt-4">
                <button @click="isCodeExpanded = false" class="text-slate-400 hover:text-white text-xs font-bold transition-colors focus:outline-none">
                  Collapse Code
                </button>
              </div>
            </div>
          </div>

          <!-- Key Takeaways -->
          <div v-if="question.key_takeaways && question.key_takeaways.length > 0" class="mb-10">
            <h2 class="text-2xl font-extrabold text-slate-900 dark:text-white mb-6 flex items-center gap-3">
              <span class="w-10 h-10 rounded-xl bg-emerald-50 text-emerald-600 flex items-center justify-center shadow-sm">
                <svg class="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" /></svg>
              </span>
              Key Takeaways
            </h2>
            <div class="grid grid-cols-1 gap-4">
              <div v-for="(takeaway, idx) in question.key_takeaways" :key="idx" 
                   class="flex gap-4 p-5 rounded-2xl bg-slate-50 dark:bg-slate-800/50 border border-slate-200/60 dark:border-slate-700/50 hover:border-brand/30 dark:hover:border-brand/30 hover:bg-brand/5 dark:hover:bg-brand/10 transition-colors group">
                <div class="mt-0.5 shrink-0 w-6 h-6 rounded-full bg-emerald-100 text-emerald-600 flex items-center justify-center group-hover:bg-brand group-hover:text-white transition-colors">
                  <svg class="w-3.5 h-3.5" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="3" d="M5 13l4 4L19 7" /></svg>
                </div>
                <div class="text-slate-700 dark:text-slate-300 leading-relaxed font-medium">
                  {{ takeaway }}
                </div>
              </div>
            </div>
          </div>
        </article>
      </div>

      <!-- Empty State -->
      <div v-else class="text-center py-32 bg-white dark:bg-slate-900 rounded-3xl border border-dashed border-slate-300 dark:border-slate-700 shadow-sm">
        <h3 class="text-2xl font-extrabold text-slate-900 dark:text-white mb-2">Question Not Found</h3>
        <p class="text-slate-500 dark:text-slate-400 mb-8">This question may have been moved or removed.</p>
        <RouterLink :to="{ name: 'interview-prep' }" class="inline-flex rounded-xl bg-slate-900 px-6 py-3 text-sm font-bold text-white shadow-md hover:bg-brand transition-colors">
          Return to Library
        </RouterLink>
      </div>
    </div>

    <!-- Mobile Sticky Floating Nav -->
    <div class="fixed bottom-0 left-0 right-0 bg-white/95 dark:bg-slate-900/95 backdrop-blur-xl border-t border-slate-200/80 dark:border-slate-800/80 p-4 pb-[calc(1rem+env(safe-area-inset-bottom))] md:hidden z-40 shadow-[0_-10px_40px_-15px_rgba(0,0,0,0.1)] rounded-t-3xl flex flex-col gap-3">
      <!-- Mini Progress bar -->
      <div class="w-full h-1.5 bg-slate-100 rounded-full overflow-hidden">
        <div class="h-full bg-brand transition-all duration-300" :style="{ width: `${((currentIndex + 1) / totalQuestions) * 100}%` }"></div>
      </div>
      <div class="flex items-center justify-between text-[11px] font-extrabold text-slate-400 px-1 uppercase tracking-wider">
        <span>{{ completedCount }} Done</span>
        <span>{{ totalQuestions - currentIndex - 1 }} Left</span>
      </div>

      <div class="flex items-center justify-between gap-3 mt-1">
        <RouterLink 
          v-if="hasPrev"
          :to="{ name: 'interview-prep-question', params: { subject: route.params.subject, question_id: prevQuestionId } }"
          class="flex-1 flex justify-center items-center h-12 bg-slate-50 text-slate-700 rounded-xl font-bold text-sm border border-slate-200 active:bg-slate-100 transition-colors"
        >
          <svg class="w-5 h-5 mr-1" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M15 19l-7-7 7-7" /></svg>
          Prev
        </RouterLink>
        <button v-else disabled class="flex-1 flex justify-center items-center h-12 bg-slate-50 text-slate-300 rounded-xl font-bold text-sm border border-slate-100 opacity-50">
          <svg class="w-5 h-5 mr-1" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M15 19l-7-7 7-7" /></svg>
          Prev
        </button>
        
        <div class="flex-none w-16 flex justify-center items-center bg-slate-50 h-12 rounded-xl border border-slate-100">
          <span class="text-sm font-black text-slate-800">{{ currentIndex + 1 }}<span class="text-slate-400 font-bold text-xs">/{{ totalQuestions }}</span></span>
        </div>

        <RouterLink 
          v-if="hasNext"
          :to="{ name: 'interview-prep-question', params: { subject: route.params.subject, question_id: nextQuestionId } }"
          class="flex-1 flex justify-center items-center h-12 bg-slate-900 text-white rounded-xl font-bold text-sm active:bg-brand transition-colors shadow-md"
        >
          Next
          <svg class="w-5 h-5 ml-1" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M9 5l7 7-7 7" /></svg>
        </RouterLink>
        <button v-else disabled class="flex-1 flex justify-center items-center h-12 bg-slate-50 text-slate-300 rounded-xl font-bold text-sm border border-slate-100 opacity-50">
          Next
          <svg class="w-5 h-5 ml-1" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M9 5l7 7-7 7" /></svg>
        </button>
      </div>
      <!-- Mobile Quick Actions -->
      <div class="flex items-center justify-between border-t border-slate-100 mt-2 pt-3 px-2">
         <button @click="shareQuestion" class="p-2 text-slate-400 hover:text-brand rounded-lg transition-colors">
            <svg class="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8.684 13.342C8.886 12.938 9 12.482 9 12c0-.482-.114-.938-.316-1.342m0 2.684a3 3 0 110-5.368m0 5.368l5.662 3.397m-5.662-3.397l5.662-3.397m-.002-3.411a3 3 0 11-5.65 0 3 3 0 015.65 0z" /></svg>
          </button>
          <button @click="toggleBookmark" class="p-2 rounded-lg transition-colors" :class="isBookmarked ? 'text-amber-500' : 'text-slate-400 hover:text-amber-500'">
            <svg class="w-5 h-5" :fill="isBookmarked ? 'currentColor' : 'none'" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 5a2 2 0 012-2h10a2 2 0 012 2v16l-7-3.5L5 21V5z" /></svg>
          </button>
          <button @click="toggleComplete" class="p-2 rounded-lg transition-colors" :class="isCompleted ? 'text-emerald-500' : 'text-slate-400 hover:text-emerald-500'">
            <svg class="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M5 13l4 4L19 7" /></svg>
          </button>
      </div>
    </div>

    <!-- Desktop Footer Nav -->
    <div v-if="question" class="hidden md:block border-t border-slate-200/80 dark:border-slate-800/80 bg-slate-50/50 dark:bg-slate-900/50 mt-12 py-8">
      <div class="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 flex items-center justify-between">
        <RouterLink :to="{ name: 'interview-prep-subject', params: { subject: route.params.subject } }" class="inline-flex items-center text-sm font-bold text-slate-500 hover:text-brand transition-colors">
          <svg class="w-4 h-4 mr-2" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M4 6h16M4 10h16M4 14h16M4 18h16" /></svg>
          Subject Overview
        </RouterLink>

        <div class="flex items-center gap-3">
          <RouterLink 
            v-if="hasPrev"
            :to="{ name: 'interview-prep-question', params: { subject: route.params.subject, question_id: prevQuestionId } }"
            class="inline-flex items-center justify-center bg-white border border-slate-200 text-slate-700 hover:border-slate-300 hover:bg-slate-50 px-5 py-2.5 rounded-xl text-sm font-bold transition-all shadow-sm focus:outline-none focus:ring-2 focus:ring-slate-200"
          >
            <svg class="w-4 h-4 mr-1.5" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M10 19l-7-7m0 0l7-7m-7 7h18" /></svg>
            Previous
          </RouterLink>
          <button v-else disabled class="inline-flex items-center justify-center bg-transparent border border-slate-200 text-slate-300 px-5 py-2.5 rounded-xl text-sm font-bold cursor-not-allowed">
            <svg class="w-4 h-4 mr-1.5" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M10 19l-7-7m0 0l7-7m-7 7h18" /></svg>
            Previous
          </button>

          <!-- Jump Menu -->
          <div class="relative flex items-center group">
            <select 
              class="appearance-none bg-white border border-slate-200 text-slate-700 text-sm font-bold rounded-xl pl-4 pr-10 py-2.5 shadow-sm focus:outline-none focus:ring-2 focus:ring-brand/20 focus:border-brand cursor-pointer hover:border-slate-300 transition-all"
              @change="jumpToQuestion"
              :value="question.id"
              aria-label="Jump to question"
            >
              <option v-for="(q, idx) in allQuestions" :key="q.id" :value="q.id">
                Question {{ idx + 1 }} / {{ totalQuestions }}
              </option>
            </select>
            <div class="pointer-events-none absolute inset-y-0 right-0 flex items-center px-3 text-slate-400 group-hover:text-brand transition-colors">
              <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M8 9l4-4 4 4m0 6l-4 4-4-4"></path></svg>
            </div>
          </div>

          <RouterLink 
            v-if="hasNext"
            :to="{ name: 'interview-prep-question', params: { subject: route.params.subject, question_id: nextQuestionId } }"
            class="inline-flex items-center justify-center bg-slate-900 text-white hover:bg-brand px-5 py-2.5 rounded-xl text-sm font-bold transition-all shadow-md focus:outline-none focus:ring-2 focus:ring-brand/50"
          >
            Next
            <svg class="w-4 h-4 ml-1.5" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M14 5l7 7m0 0l-7 7m7-7H3" /></svg>
          </RouterLink>
          <button v-else disabled class="inline-flex items-center justify-center bg-slate-100 text-slate-400 px-5 py-2.5 rounded-xl text-sm font-bold cursor-not-allowed">
            Next
            <svg class="w-4 h-4 ml-1.5" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M14 5l7 7m0 0l-7 7m7-7H3" /></svg>
          </button>
        </div>
      </div>
    </div>
  </AppShell>
</template>

<script setup>
import { ref, onMounted, computed, watch, nextTick } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import AppShell from '../../components/layout/AppShell.vue'
import interviewPrepService from '../../services/interviewPrepService'
import { useInterviewState } from './composables/useInterviewState'

const route = useRoute()
const router = useRouter()
const question = ref(null)
const allQuestions = ref([])
const loading = ref(true)

const isCodeExpanded = ref(false)
const copied = ref(false)
const toastMsg = ref('')
let toastTimer = null

const { 
  toggleBookmark: _toggleBookmark, 
  isBookmarked: _isBookmarked,
  toggleCompleted: _toggleCompleted,
  isCompleted: _isCompleted,
  addRecentlyViewed,
  setContinueLearning,
  getSubjectStats
} = useInterviewState()

// Reactive State via Computed
const isBookmarked = computed(() => {
  if (!question.value) return false
  return _isBookmarked(route.params.subject, route.params.question_id)
})

const isCompleted = computed(() => {
  if (!question.value) return false
  return _isCompleted(route.params.subject, route.params.question_id)
})

const completedCount = computed(() => {
  return getSubjectStats(route.params.subject, totalQuestions.value).completed
})

const remainingCount = computed(() => {
  return getSubjectStats(route.params.subject, totalQuestions.value).remaining
})

const showToast = (msg) => {
  toastMsg.value = msg
  clearTimeout(toastTimer)
  toastTimer = setTimeout(() => { toastMsg.value = '' }, 3000)
}

const toggleBookmark = () => {
  const added = _toggleBookmark(route.params.subject, route.params.question_id)
  showToast(added ? 'Added to Bookmarks' : 'Removed from Bookmarks')
}

const toggleComplete = () => {
  const completed = _toggleCompleted(route.params.subject, route.params.question_id)
  showToast(completed ? 'Marked as complete' : 'Removed from completed')
}

const shareQuestion = async () => {
  const url = window.location.href
  if (navigator.share) {
    try {
      await navigator.share({
        title: question.value?.title || 'Interview Preparation',
        url: url
      })
    } catch (e) {
      if (e.name !== 'AbortError') copyToClipboard(url, 'Link copied to clipboard')
    }
  } else {
    copyToClipboard(url, 'Link copied to clipboard')
  }
}

const copyToClipboard = async (text, msg) => {
  try {
    await navigator.clipboard.writeText(text)
    showToast(msg)
  } catch (e) {
    console.error('Copy failed')
  }
}

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
  isCodeExpanded.value = false
  copied.value = false
  try {
    const { data } = await interviewPrepService.getQuestion(route.params.subject, route.params.question_id)
    question.value = data.question
    
    // Add to recently viewed
    addRecentlyViewed(route.params.subject, route.params.question_id, question.value)
    // Update continue learning
    setContinueLearning(route.params.subject, route.params.subject, route.params.question_id, currentIndex.value, totalQuestions.value)
    
    if (question.value.code_example && question.value.code_example.split('\n').length < 15) {
      isCodeExpanded.value = true
    }
  } catch (error) {
    console.error('Failed to load question details', error)
  } finally {
    loading.value = false
  }
}

watch(() => route.params.question_id, () => {
  if (route.name === 'interview-prep-question') {
    fetchCurrentQuestionDetails()
    // Explicitly scroll to top on param changes because Vue Router scrollBehavior
    // does not trigger when staying on the same route component
    nextTick(() => {
      window.scrollTo({ top: 0, behavior: 'instant' })
      const appContent = document.querySelector('main') || document.querySelector('.overflow-y-auto')
      if (appContent) {
        appContent.scrollTo({ top: 0, behavior: 'instant' })
      }
    })
  }
})

onMounted(() => {
  loadData()
})

const copyCode = () => {
  if (!question.value?.code_example) return
  copyToClipboard(question.value.code_example, 'Code copied to clipboard')
  copied.value = true
  setTimeout(() => { copied.value = false }, 2000)
}

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

const languageBadge = computed(() => {
  if (!question.value?.topic) return 'Code'
  if (question.value.topic.toLowerCase().includes('sql')) return 'SQL'
  if (question.value.topic.toLowerCase().includes('java')) return 'Java'
  if (question.value.topic.toLowerCase().includes('python')) return 'Python'
  if (question.value.topic.toLowerCase().includes('react')) return 'React/JSX'
  return 'Code'
})

// Split long answers into structural components based on regex/newlines.
const parsedAnswerSections = computed(() => {
  if (!question.value?.answer) return []
  const text = question.value.answer
  
  // A simplistic approach to split content if it contains known headings like "Advantages:", "Definition:", etc.
  const regex = /(Advantages:|Disadvantages:|Example:|Definition:|Explanation:|Interview Tip:|Common Mistakes:)/gi
  const parts = text.split(regex).filter(Boolean)
  
  if (parts.length <= 1) {
    return [{ title: null, content: text.trim() }]
  }

  const sections = []
  let i = 0
  
  // If the text didn't start with a matched keyword, the first chunk is general text
  if (!parts[0].match(regex)) {
    sections.push({ title: null, content: parts[0].trim() })
    i++
  }

  while (i < parts.length) {
    const title = parts[i].trim().replace(':', '')
    const content = parts[i + 1] ? parts[i + 1].trim() : ''
    sections.push({ title, content })
    i += 2
  }
  return sections
})

</script>

<style scoped>
.fade-enter-active,
.fade-leave-active {
  transition: opacity 0.3s ease, transform 0.3s ease;
}
.fade-enter-from,
.fade-leave-to {
  opacity: 0;
  transform: translateY(-10px);
}
</style>
