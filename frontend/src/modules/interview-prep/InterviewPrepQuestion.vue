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
 <div class="fixed top-0 left-0 right-0 h-1 bg-surface-hover z-50">
 <div class="h-full bg-brand transition-all duration-500 ease-out" :style="{ width: `${((currentIndex + 1) / totalQuestions) * 100}%` }"></div>
 </div>

 <div class="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 pt-4 pb-40 md:py-8 md:pb-12 animate-fade-in relative">
 <!-- Ambient Background Mesh Glows -->
 <div class="absolute top-0 left-1/4 w-72 h-72 bg-brand/5 rounded-full blur-[100px] pointer-events-none -z-10"></div>
 <div class="absolute top-1/3 right-10 w-72 h-72 bg-indigo-500/5 rounded-full blur-[100px] pointer-events-none -z-10"></div>
 <div class="absolute bottom-10 left-10 w-72 h-72 bg-emerald-500/5 rounded-full blur-[100px] pointer-events-none -z-10"></div>
 
 <!-- Breadcrumbs -->
 <nav class="flex text-xs font-bold text-txt-disabled mb-4 md:mb-8 uppercase tracking-wider" aria-label="Breadcrumb">
 <ol class="flex flex-wrap items-center gap-2 sm:gap-2.5">
 <li class="flex items-center">
 <RouterLink :to="{ name: 'interview-prep' }" class="hover:text-brand transition-colors flex items-center">
 <span class="leading-none pt-0.5">Library</span>
 </RouterLink>
 </li>
 <li class="flex items-center text-txt-muted">
 <svg class="w-3.5 h-3.5 shrink-0" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="3" d="M9 5l7 7-7 7" /></svg>
 </li>
 <li class="flex items-center">
 <RouterLink :to="{ name: 'interview-prep-subject', params: { subject: route.params.subject } }" class="hover:text-brand transition-colors capitalize flex items-center">
 <span class="leading-none pt-0.5">{{ String(route.params.subject).replace(/_/g, ' ') }}</span>
 </RouterLink>
 </li>
 <li v-if="question && totalQuestions > 0" class="hidden sm:flex items-center text-txt-muted">
 <svg class="w-3.5 h-3.5 shrink-0" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="3" d="M9 5l7 7-7 7" /></svg>
 </li>
 <li v-if="question && totalQuestions > 0" class="hidden sm:flex items-center">
 <span class="text-txt-primary leading-none pt-0.5">Q{{ currentIndex + 1 }}</span>
 </li>
 </ol>
 </nav>

 <div v-if="loading" class="space-y-6">
 <div class="h-40 bg-surface-hover animate-pulse rounded-3xl"></div>
 <div class="h-96 bg-surface-hover animate-pulse rounded-3xl"></div>
 </div>
 
 <div v-else-if="question" class="space-y-8">
 
 <!-- Header Section -->
 <header class="space-y-6">
 <div class="flex flex-wrap items-center justify-between gap-4">
 <div class="flex flex-wrap items-center gap-3">
 <span 
 class="inline-flex items-center rounded-md px-2.5 py-1 text-xs font-black uppercase tracking-wider"
 :class="{
 'bg-emerald-50 text-emerald-700 border border-emerald-200/50 ': question.difficulty === 'Easy',
 'bg-amber-50 text-amber-700 border border-amber-200/50 ': question.difficulty === 'Intermediate',
 'bg-rose-50 text-rose-700 border border-rose-200/50 ': question.difficulty === 'Hard'
 }"
 >
 {{ question.difficulty }}
 </span>
 <span class="inline-flex items-center text-xs font-bold text-txt-secondary bg-surface-hover rounded-md px-2.5 py-1 border border-border/50 ">
 {{ question.topic }}
 </span>
 <span v-if="question.isHighFrequency" class="inline-flex items-center text-xs font-bold text-amber-600 bg-amber-50 rounded-md px-2.5 py-1 border border-amber-200/50">
 <svg class="w-3.5 h-3.5 mr-1" fill="currentColor" viewBox="0 0 20 20"><path d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 00.95.69h3.462c.969 0 1.371 1.24.588 1.81l-2.8 2.034a1 1 0 00-.364 1.118l1.07 3.292c.3.921-.755 1.688-1.54 1.118l-2.8-2.034a1 1 0 00-1.175 0l-2.8 2.034c-.784.57-1.838-.197-1.539-1.118l1.07-3.292a1 1 0 00-.364-1.118L2.98 8.72c-.783-.57-.38-1.81.588-1.81h3.461a1 1 0 00.951-.69l1.07-3.292z"/></svg>
 High Frequency
 </span>
 </div>
 
 <div class="flex items-center gap-2 hidden md:flex">
 <button @click="shareQuestion" class="p-2 text-txt-disabled hover:text-brand hover:bg-brand/5 rounded-xl transition-all focus:outline-none focus:ring-2 focus:ring-brand/20" title="Share" aria-label="Share Question">
 <svg class="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8.684 13.342C8.886 12.938 9 12.482 9 12c0-.482-.114-.938-.316-1.342m0 2.684a3 3 0 110-5.368m0 5.368l5.662 3.397m-5.662-3.397l5.662-3.397m-.002-3.411a3 3 0 11-5.65 0 3 3 0 015.65 0z" /></svg>
 </button>
 <button @click="toggleBookmark" class="p-2 rounded-xl transition-all focus:outline-none focus:ring-2 focus:ring-amber-200" :class="isBookmarked ? 'text-amber-500 bg-amber-50' : 'text-txt-disabled hover:text-amber-500 hover:bg-amber-50'" title="Bookmark" aria-label="Bookmark Question">
 <svg class="w-5 h-5" :fill="isBookmarked ? 'currentColor' : 'none'" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 5a2 2 0 012-2h10a2 2 0 012 2v16l-7-3.5L5 21V5z" /></svg>
 </button>
 <button @click="toggleComplete" class="flex items-center gap-2 px-3 py-1.5 rounded-xl font-bold text-sm transition-colors focus:outline-none focus:ring-2 focus:ring-emerald-200" :class="isCompleted ? 'bg-emerald-500 text-white hover:bg-emerald-600' : 'bg-surface-hover text-txt-secondary hover:bg-surface-hover'">
 <svg class="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M5 13l4 4L19 7" /></svg>
 {{ isCompleted ? 'Completed' : 'Mark Complete' }}
 </button>
 </div>
 </div>
 
 <h1 class="text-3xl md:text-4xl font-extrabold text-txt-primary leading-tight">{{ question.title }}</h1>
 </header>

 <!-- Question Box -->
 <div class="p-6 md:p-8 bg-surface text-txt-primary rounded-3xl shadow-xl relative overflow-hidden">
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
 <h2 class="text-xl md:text-2xl font-extrabold text-txt-primary mb-4 md:mb-6 flex items-center gap-3">
 <span class="w-8 h-8 md:w-10 md:h-10 rounded-xl bg-indigo-50 text-indigo-600 flex items-center justify-center shadow-sm">
 <svg class="w-4 h-4 md:w-5 md:h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" /></svg>
 </span>
 Solution
 </h2>
 <div class="bg-surface rounded-2xl md:rounded-3xl p-5 md:p-8 shadow-sm border border-border text-txt-secondary space-y-6">
 
 <!-- Parsed Answer Sections -->
 <div v-for="(section, sIdx) in parsedAnswerSections" :key="sIdx" class="space-y-2">
 <h4 v-if="section.title" class="text-base font-bold text-txt-primary">{{ section.title }}</h4>
 <p class="whitespace-pre-wrap">{{ section.content }}</p>
 </div>
 
 <div v-if="question.explanation" class="mt-8 pt-8 border-t border-border">
 <h3 class="text-lg font-bold text-txt-primary mb-4 flex items-center gap-2">
 <svg class="w-5 h-5 text-brand" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M9.663 17h4.673M12 3v1m6.364 1.636l-.707.707M21 12h-1M4 12H3m3.343-5.657l-.707-.707m2.828 9.9a5 5 0 117.072 0l-.548.547A3.374 3.374 0 0014 18.469V19a2 2 0 11-4 0v-.531c0-.895-.356-1.754-.988-2.386l-.548-.547z" /></svg>
 Detailed Explanation
 </h3>
 <p class="whitespace-pre-wrap text-txt-secondary ">{{ question.explanation }}</p>
 </div>
 </div>
 </div>

 <!-- Code Example -->
 <div v-if="question.code_example" class="mb-8 md:mb-10 mt-6 md:mt-0">
 <h2 class="text-xl md:text-2xl font-extrabold text-txt-primary mb-4 md:mb-6 flex items-center gap-3">
 <span class="w-8 h-8 md:w-10 md:h-10 rounded-xl bg-surface-hover text-txt-secondary flex items-center justify-center shadow-sm">
 <svg class="w-4 h-4 md:w-5 md:h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M10 20l4-16m4 4l4 4-4 4M6 16l-4-4 4-4" /></svg>
 </span>
 Implementation
 </h2>
 
 <div class="group relative rounded-2xl md:rounded-3xl overflow-hidden bg-[#0f172a] shadow-2xl border border-white/10">
 <!-- Code Header -->
 <div class="flex items-center justify-between px-4 py-3 bg-surface/5 border-b border-white/10">
 <div class="flex items-center gap-3">
 <div class="flex space-x-2">
 <div class="w-3 h-3 rounded-full bg-rose-500/80"></div>
 <div class="w-3 h-3 rounded-full bg-amber-500/80"></div>
 <div class="w-3 h-3 rounded-full bg-emerald-500/80"></div>
 </div>
 <span class="text-[10px] font-bold tracking-wider text-txt-disabled uppercase bg-surface/10 px-2 py-0.5 rounded">{{ languageBadge }}</span>
 </div>
 <div class="flex items-center gap-3">
 <button @click="copyCode" :disabled="isCopyingCode" class="flex items-center gap-1.5 text-xs font-bold text-txt-disabled hover:text-white transition-colors focus:outline-none" aria-label="Copy code to clipboard">
  <svg v-if="isCopyingCode" class="w-4 h-4 animate-spin" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M21 12a9 9 0 11-18 0 9 9 0 0118 0z" stroke-opacity="0.25"/><path d="M12 3a9 9 0 019 9"/></svg>
  <svg v-else-if="copied" class="w-4 h-4 text-emerald-400" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7" /></svg>
  <svg v-else class="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 16H6a2 2 0 01-2-2V6a2 2 0 012-2h8a2 2 0 012 2v2m-6 12h8a2 2 0 002-2v-8a2 2 0 00-2-2h-8a2 2 0 00-2 2v8a2 2 0 002 2z" /></svg>
  {{ isCopyingCode ? 'Copying...' : copied ? 'Copied!' : 'Copy Code' }}
 </button>
 </div>
 </div>
 <div class="relative" :class="{ 'max-h-[500px] overflow-hidden': !isCodeExpanded }">
 <pre class="p-6 overflow-x-auto text-sm text-txt-muted font-mono leading-relaxed"><code class="block min-w-full">{{ question.code_example }}</code></pre>
 
 <!-- Expand Overlay -->
 <div v-if="!isCodeExpanded" class="absolute bottom-0 left-0 right-0 h-32 bg-gradient-to-t from-[#0f172a] to-transparent flex items-end justify-center pb-4">
 <button @click="isCodeExpanded = true" class="bg-surface/10 hover:bg-surface/20 text-white backdrop-blur-md px-4 py-2 rounded-xl text-xs font-bold transition-colors shadow-lg border border-white/10 focus:outline-none focus:ring-2 focus:ring-white/20">
 Expand Full Code
 </button>
 </div>
 </div>
 <div v-if="isCodeExpanded" class="px-6 pb-4 flex justify-center bg-[#0f172a] border-t border-white/5 pt-4">
 <button @click="isCodeExpanded = false" class="text-txt-disabled hover:text-white text-xs font-bold transition-colors focus:outline-none">
 Collapse Code
 </button>
 </div>
 </div>
 </div>

 <!-- Key Takeaways -->
 <div v-if="question.key_takeaways && question.key_takeaways.length > 0" class="mb-10">
 <h2 class="text-2xl font-extrabold text-txt-primary mb-6 flex items-center gap-3">
 <span class="w-10 h-10 rounded-xl bg-emerald-50 text-emerald-600 flex items-center justify-center shadow-sm">
 <svg class="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" /></svg>
 </span>
 Key Takeaways
 </h2>
 <div class="grid grid-cols-1 gap-4">
 <div v-for="(takeaway, idx) in question.key_takeaways" :key="idx" 
 class="flex gap-4 p-5 rounded-2xl bg-surface-elevated/50 border border-border/60 hover:border-brand/30 hover:bg-brand/5 transition-colors group">
 <div class="mt-0.5 shrink-0 w-6 h-6 rounded-full bg-emerald-100 text-emerald-600 flex items-center justify-center group-hover:bg-brand group-hover:text-white transition-colors">
 <svg class="w-3.5 h-3.5" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="3" d="M5 13l4 4L19 7" /></svg>
 </div>
 <div class="text-txt-secondary leading-relaxed font-medium">
 {{ takeaway }}
 </div>
 </div>
 </div>
 </div>
 </article>
 </div>

 <!-- Empty State -->
 <div v-else class="text-center py-32 bg-surface rounded-3xl border border-dashed border-border-hover shadow-sm">
 <h3 class="text-2xl font-extrabold text-txt-primary mb-2">Question Not Found</h3>
 <p class="text-txt-muted mb-8">This question may have been moved or removed.</p>
 <RouterLink :to="{ name: 'interview-prep' }" class="inline-flex rounded-xl bg-brand px-6 py-3 text-sm font-bold text-white shadow-md hover:bg-brand/90 transition-colors">
 Return to Library
 </RouterLink>
 </div>
 </div>

 <!-- Mobile Sticky Floating Nav -->
 <div class="fixed bottom-0 left-0 right-0 bg-surface/95 backdrop-blur-xl border-t border-border px-4 pt-3.5 pb-[calc(0.5rem+env(safe-area-inset-bottom))] md:hidden z-40 shadow-[0_-10px_45px_-10px_rgba(0,0,0,0.08)] rounded-t-2xl">
   <!-- Progress bar at the absolute top edge of the sticky container -->
   <div class="absolute top-0 left-0 right-0 h-1 bg-surface-hover overflow-hidden rounded-t-2xl">
     <div class="h-full bg-brand transition-all duration-300" :style="{ width: `${((currentIndex + 1) / totalQuestions) * 100}%` }"></div>
   </div>

   <div class="flex items-center justify-between w-full mt-1">
     <!-- Left Slot: Quick Actions (Flex-1 to keep center aligned) -->
     <div class="flex items-center gap-1.5 flex-1">
       <!-- Share -->
       <button 
         @click="shareQuestion" 
         class="w-10 h-10 flex items-center justify-center text-txt-disabled hover:text-brand hover:bg-brand/5 active:bg-brand/10 rounded-xl transition-all"
         title="Share" 
         aria-label="Share Question"
       >
         <svg class="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
           <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8.684 13.342C8.886 12.938 9 12.482 9 12c0-.482-.114-.938-.316-1.342m0 2.684a3 3 0 110-5.368m0 5.368l5.662 3.397m-5.662-3.397l5.662-3.397m-.002-3.411a3 3 0 11-5.65 0 3 3 0 015.65 0z" />
         </svg>
       </button>
       <!-- Bookmark -->
       <button 
         @click="toggleBookmark" 
         class="w-10 h-10 flex items-center justify-center rounded-xl transition-all" 
         :class="isBookmarked ? 'text-amber-500 bg-amber-50 active:bg-amber-100' : 'text-txt-disabled hover:text-amber-500 hover:bg-amber-50 active:bg-amber-100'"
         title="Bookmark" 
         aria-label="Bookmark Question"
       >
         <svg class="w-5 h-5" :fill="isBookmarked ? 'currentColor' : 'none'" viewBox="0 0 24 24" stroke="currentColor">
           <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 5a2 2 0 012-2h10a2 2 0 012 2v16l-7-3.5L5 21V5z" />
         </svg>
       </button>
     </div>

     <!-- Center Slot: Navigation (Fixed size slot for centering) -->
     <div class="flex items-center gap-2 justify-center shrink-0">
       <!-- Prev Button -->
       <RouterLink 
         v-if="hasPrev"
         :to="{ name: 'interview-prep-question', params: { subject: route.params.subject, question_id: prevQuestionId } }"
         class="w-10 h-10 flex items-center justify-center bg-background text-txt-secondary rounded-xl border border-border active:bg-surface-hover transition-colors"
         aria-label="Previous question"
       >
         <svg class="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
           <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M15 19l-7-7 7-7" />
         </svg>
       </RouterLink>
       <button 
         v-else 
         disabled 
         class="w-10 h-10 flex items-center justify-center bg-background text-txt-muted rounded-xl border border-border opacity-40 cursor-not-allowed"
       >
         <svg class="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
           <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M15 19l-7-7 7-7" />
         </svg>
       </button>
       
       <!-- Question Counter -->
       <div class="h-10 px-2.5 flex items-center justify-center bg-background rounded-xl border border-border/80 select-none">
         <span class="text-sm font-bold text-txt-primary">
           {{ currentIndex + 1 }}<span class="text-txt-disabled font-medium text-xs">/{{ totalQuestions }}</span>
         </span>
       </div>

       <!-- Next Button -->
       <RouterLink 
         v-if="hasNext"
         :to="{ name: 'interview-prep-question', params: { subject: route.params.subject, question_id: nextQuestionId } }"
         class="w-10 h-10 flex items-center justify-center bg-brand text-white rounded-xl active:bg-brand/90 transition-colors shadow-sm"
         aria-label="Next question"
       >
         <svg class="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
           <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M9 5l7 7-7 7" />
         </svg>
       </RouterLink>
       <button 
         v-else 
         disabled 
         class="w-10 h-10 flex items-center justify-center bg-background text-txt-muted rounded-xl border border-border opacity-40 cursor-not-allowed"
       >
         <svg class="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
           <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M9 5l7 7-7 7" />
         </svg>
       </button>
     </div>

     <!-- Right Slot: Completion Status (Flex-1 to keep center aligned) -->
     <div class="flex items-center justify-end flex-1">
       <!-- Mark Complete / Completed Toggle -->
       <button 
         @click="toggleComplete" 
         class="w-10 h-10 flex items-center justify-center rounded-xl transition-all" 
         :class="isCompleted ? 'bg-emerald-500 text-white shadow-sm active:bg-emerald-600' : 'bg-surface-hover text-txt-secondary hover:bg-surface-hover active:bg-border border border-border/50'"
         :title="isCompleted ? 'Completed' : 'Mark Complete'"
         aria-label="Mark Complete"
       >
         <svg class="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
           <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M5 13l4 4L19 7" />
         </svg>
       </button>
     </div>
   </div>
 </div>

 <!-- Desktop Footer Nav -->
 <div v-if="question" class="hidden md:block border-t border-border bg-background/50 mt-12 py-8">
 <div class="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 flex items-center justify-between">
 <RouterLink :to="{ name: 'interview-prep-subject', params: { subject: route.params.subject } }" class="inline-flex items-center text-sm font-bold text-txt-muted hover:text-brand transition-colors">
 <svg class="w-4 h-4 mr-2" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M4 6h16M4 10h16M4 14h16M4 18h16" /></svg>
 Subject Overview
 </RouterLink>

 <div class="flex items-center gap-3">
 <RouterLink 
 v-if="hasPrev"
 :to="{ name: 'interview-prep-question', params: { subject: route.params.subject, question_id: prevQuestionId } }"
 class="inline-flex items-center justify-center bg-surface border border-border text-txt-secondary hover:border-border-hover hover:bg-background px-5 py-2.5 rounded-xl text-sm font-bold transition-all shadow-sm focus:outline-none focus:ring-2 focus:ring-slate-200"
 >
 <svg class="w-4 h-4 mr-1.5" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M10 19l-7-7m0 0l7-7m-7 7h18" /></svg>
 Previous
 </RouterLink>
 <button v-else disabled class="inline-flex items-center justify-center bg-transparent border border-border text-txt-muted px-5 py-2.5 rounded-xl text-sm font-bold cursor-not-allowed">
 <svg class="w-4 h-4 mr-1.5" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M10 19l-7-7m0 0l7-7m-7 7h18" /></svg>
 Previous
 </button>

 <!-- Jump Menu -->
 <div class="relative flex items-center group">
 <select 
 class="appearance-none bg-surface border border-border text-txt-secondary text-sm font-bold rounded-xl pl-4 pr-10 py-2.5 shadow-sm focus:outline-none focus:ring-2 focus:ring-brand/20 focus:border-brand cursor-pointer hover:border-border-hover transition-all"
 @change="jumpToQuestion"
 :value="question.id"
 aria-label="Jump to question"
 >
 <option v-for="(q, idx) in allQuestions" :key="q.id" :value="q.id">
 Question {{ idx + 1 }} / {{ totalQuestions }}
 </option>
 </select>
 <div class="pointer-events-none absolute inset-y-0 right-0 flex items-center px-3 text-txt-disabled group-hover:text-brand transition-colors">
 <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M8 9l4-4 4 4m0 6l-4 4-4-4"></path></svg>
 </div>
 </div>

 <RouterLink 
 v-if="hasNext"
 :to="{ name: 'interview-prep-question', params: { subject: route.params.subject, question_id: nextQuestionId } }"
 class="inline-flex items-center justify-center bg-slate-900 text-white hover:bg-slate-800 px-5 py-2.5 rounded-xl text-sm font-bold transition-all shadow-md focus:outline-none focus:ring-2 focus:ring-brand/50"
 >
 Next
 <svg class="w-4 h-4 ml-1.5" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M14 5l7 7m0 0l-7 7m7-7H3" /></svg>
 </RouterLink>
 <button v-else disabled class="inline-flex items-center justify-center bg-surface-hover text-txt-disabled px-5 py-2.5 rounded-xl text-sm font-bold cursor-not-allowed">
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
import ClipboardService from '../../services/clipboard'

const route = useRoute()
const router = useRouter()
const question = ref(null)
const allQuestions = ref([])
const loading = ref(true)

const isCodeExpanded = ref(false)
const copied = ref(false)
const isCopyingCode = ref(false)
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
 await ClipboardService.copy(text, {
  successMessage: msg || 'Content copied successfully.'
 })
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

const copyCode = async () => {
 if (!question.value?.code_example) return
 isCopyingCode.value = true
 await new Promise(resolve => setTimeout(resolve, 150))
 isCopyingCode.value = false
 const success = await ClipboardService.copy(question.value.code_example, {
  successMessage: 'Code copied successfully.'
 })
 if (success) {
  copied.value = true
  setTimeout(() => { copied.value = false }, 2000)
 }
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
