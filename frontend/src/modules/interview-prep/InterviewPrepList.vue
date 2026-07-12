<template>
 <AppShell>
 <!-- Lightweight Toast -->
 <Transition name="fade">
 <div v-if="toastMsg" class="fixed top-4 right-4 z-[100] bg-slate-900 text-white px-4 py-3 rounded-xl shadow-2xl flex items-center gap-3">
 <svg class="w-5 h-5 text-emerald-400" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" /></svg>
 <span class="text-sm font-bold">{{ toastMsg }}</span>
 </div>
 </Transition>

 <div class="max-w-7xl mx-auto space-y-12 animate-fade-in pb-16 px-4 sm:px-6 lg:px-8 mt-8 relative">
 <!-- Ambient Background Mesh Glows -->
 <div class="absolute top-0 left-1/4 w-96 h-96 bg-brand/5 rounded-full blur-[120px] pointer-events-none -z-10"></div>
 <div class="absolute top-1/3 right-10 w-96 h-96 bg-indigo-500/5 rounded-full blur-[120px] pointer-events-none -z-10"></div>
 <div class="absolute bottom-10 left-10 w-96 h-96 bg-emerald-500/5 rounded-full blur-[120px] pointer-events-none -z-10"></div>
 
 <!-- Premium Dashboard Header -->
 <div class="flex flex-col xl:flex-row gap-8 relative z-10">
 
 <!-- Welcome & Global Stats -->
 <div class="flex-1 space-y-6">
 <div class="relative overflow-hidden rounded-3xl bg-gradient-to-br from-slate-900 via-[#161224] to-[#0f172a] text-white p-6 sm:p-8 md:p-10 shadow-xl border border-white/10">
 <!-- Decorative ambient lights -->
 <div class="absolute -right-20 -top-20 w-80 h-80 bg-brand/20 rounded-full blur-[100px] pointer-events-none"></div>
 <div class="absolute -left-20 -bottom-20 w-80 h-80 bg-indigo-500/10 rounded-full blur-[100px] pointer-events-none"></div>
 
 <div class="relative z-10 flex flex-col justify-between h-full gap-4">
 <div>
 <div class="inline-flex items-center gap-2 px-3 py-1.5 rounded-full bg-white/10 text-brand text-xs font-black border border-white/10 shadow-sm backdrop-blur-md mb-6 uppercase tracking-wider">
 <span class="relative flex h-2 w-2">
 <span class="animate-ping absolute inline-flex h-full w-full rounded-full bg-brand opacity-75"></span>
 <span class="relative inline-flex rounded-full h-2 w-2 bg-brand"></span>
 </span>
 Interview Prep 2.0
 </div>
 <h1 class="text-3xl sm:text-4xl md:text-5xl font-extrabold tracking-tight mb-3 leading-tight">
 Welcome back to your <br class="hidden md:inline"/><span class="text-transparent bg-clip-text bg-gradient-to-r from-brand via-indigo-400 to-purple-400">Learning Dashboard.</span>
 </h1>
 <p class="text-sm sm:text-base text-slate-300 max-w-xl leading-relaxed">
 Track your progress, revisit recent questions, and master technical coding interviews step-by-step.
 </p>
 </div>
 </div>
 </div>
 
 <!-- Global Statistics Grid -->
 <div class="grid grid-cols-2 md:grid-cols-4 gap-4">
 <div class="text-left bg-surface rounded-2xl p-4 sm:p-5 border border-border/60 shadow-sm transition-colors group">
 <div class="w-10 h-10 rounded-xl bg-background flex items-center justify-center mb-3 group-hover:scale-105 transition-transform">
 <svg class="w-5 h-5 text-txt-secondary" fill="none" viewBox="0 0 24 24" stroke="currentColor" aria-hidden="true"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 11H5m14 0a2 2 0 012 2v6a2 2 0 01-2 2H5a2 2 0 01-2-2v-6a2 2 0 012-2m14 0V9a2 2 0 00-2-2M5 11V9a2 2 0 012-2m0 0V5a2 2 0 012-2h6a2 2 0 012 2v2M7 7h10" /></svg>
 </div>
 <p class="text-[10px] sm:text-[11px] font-bold text-txt-disabled uppercase tracking-wider mb-1">Total Questions</p>
 <p class="text-xl sm:text-2xl font-extrabold sm:font-black text-txt-primary">{{ totalQuestions }}</p>
 </div>
 <RouterLink :to="{ name: 'interview-prep-completed' }" class="text-left bg-surface rounded-2xl p-4 sm:p-5 border border-border/60 shadow-sm hover:border-emerald-300 transition-colors group focus:outline-none focus:ring-4 focus:ring-emerald-200 block">
 <div class="w-10 h-10 rounded-xl bg-emerald-50 flex items-center justify-center mb-3 group-hover:scale-110 transition-transform">
 <svg class="w-5 h-5 text-emerald-600" fill="none" viewBox="0 0 24 24" stroke="currentColor" aria-hidden="true"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M5 13l4 4L19 7" /></svg>
 </div>
 <p class="text-[10px] sm:text-[11px] font-bold text-txt-disabled uppercase tracking-wider mb-1">Completed</p>
 <p class="text-xl sm:text-2xl font-extrabold sm:font-black text-txt-primary">{{ totalCompletedCount }}</p>
 </RouterLink>
 <RouterLink :to="{ name: 'interview-prep-bookmarks' }" class="text-left bg-surface rounded-2xl p-4 sm:p-5 border border-border/60 shadow-sm hover:border-amber-300 transition-colors group focus:outline-none focus:ring-4 focus:ring-amber-200 block">
 <div class="w-10 h-10 rounded-xl bg-amber-50 flex items-center justify-center mb-3 group-hover:scale-110 transition-transform">
 <svg class="w-5 h-5 text-amber-500" fill="currentColor" viewBox="0 0 24 24" aria-hidden="true"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 5a2 2 0 012-2h10a2 2 0 012 2v16l-7-3.5L5 21V5z" /></svg>
 </div>
 <p class="text-[10px] sm:text-[11px] font-bold text-txt-disabled uppercase tracking-wider mb-1">Bookmarks</p>
 <p class="text-xl sm:text-2xl font-extrabold sm:font-black text-txt-primary">{{ totalBookmarkedCount }}</p>
 </RouterLink>
 <div class="text-left bg-surface rounded-2xl p-4 sm:p-5 border border-border/60 shadow-sm transition-colors group">
 <div class="w-10 h-10 rounded-xl bg-purple-50 flex items-center justify-center mb-3 group-hover:scale-105 transition-transform">
 <svg class="w-5 h-5 text-purple-600" fill="none" viewBox="0 0 24 24" stroke="currentColor" aria-hidden="true"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" /></svg>
 </div>
 <p class="text-[10px] sm:text-[11px] font-bold text-txt-disabled uppercase tracking-wider mb-1">Remaining Time</p>
 <p class="text-xl sm:text-2xl font-extrabold sm:font-black text-txt-primary">~{{ remainingEstTime }}h</p>
 </div>
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
 <div class="bg-gradient-to-br from-slate-900 via-indigo-950 to-slate-955 text-white rounded-3xl p-6 md:p-8 relative overflow-hidden shadow-2xl border border-white/5">
 <!-- Ambient Glows -->
 <div class="absolute -right-16 -top-16 w-48 h-48 bg-brand/35 rounded-full blur-[60px] pointer-events-none"></div>
 <div class="absolute -left-16 -bottom-16 w-48 h-48 bg-indigo-500/20 rounded-full blur-[60px] pointer-events-none"></div>
 
 <div class="relative z-10 space-y-6">
 <!-- Top Header Row -->
 <div class="flex items-center justify-between">
 <div class="flex items-center gap-2">
 <span class="relative flex h-2 w-2">
 <span class="animate-ping absolute inline-flex h-full w-full rounded-full bg-emerald-400 opacity-75"></span>
 <span class="relative inline-flex rounded-full h-2 w-2 bg-emerald-500"></span>
 </span>
 <h3 class="text-xs font-black text-slate-400 uppercase tracking-widest">Overall Progress</h3>
 </div>
 <span class="bg-white/10 border border-white/10 px-3 py-1 rounded-xl text-[10px] font-extrabold text-white font-mono shadow-sm">
 {{ globalProgressPercentage }}% Complete
 </span>
 </div>

 <!-- Large Stat & Progress Circle Combo -->
 <div class="flex items-baseline justify-between gap-4">
 <div>
 <span class="text-5xl font-black tracking-tight text-white font-mono leading-none">{{ globalProgressPercentage }}%</span>
 <p class="text-[10px] font-bold text-slate-400 mt-2.5 uppercase tracking-wider">Completion Rate</p>
 </div>
 <div class="text-right">
 <span class="text-2xl font-black tracking-tight text-white font-mono leading-none">{{ totalCompletedCount }}</span>
 <span class="text-[10px] text-slate-400 font-bold uppercase tracking-wider block mt-2.5">Solved Questions</span>
 </div>
 </div>

 <!-- Premium Gradient Progress Bar -->
 <div class="relative">
 <div class="w-full h-2.5 bg-white/10 rounded-full overflow-hidden border border-white/5 relative">
 <div class="h-full bg-gradient-to-r from-brand via-indigo-400 to-purple-500 rounded-full transition-all duration-1000 ease-out" :style="{ width: `${globalProgressPercentage}%` }"></div>
 </div>
 <!-- Tiny background bar glow -->
 <div class="absolute inset-0 h-2.5 rounded-full bg-brand/10 blur-sm pointer-events-none -z-10" :style="{ width: `${globalProgressPercentage}%` }"></div>
 </div>

 <!-- Spacing Divider -->
 <div class="h-px bg-white/5 w-full my-4"></div>

 <!-- Quick Metrics Grid -->
 <div class="grid grid-cols-3 gap-3 text-center">
 <div class="bg-white/5 border border-white/5 rounded-2xl p-3 flex flex-col items-center justify-center">
 <svg class="w-4 h-4 text-emerald-400 mb-1.5" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M5 13l4 4L19 7" /></svg>
 <span class="text-xs font-black text-white leading-none">{{ totalCompletedCount }}</span>
 <span class="text-[9px] font-bold text-slate-400 uppercase tracking-wider mt-1.5">Solved</span>
 </div>
 <div class="bg-white/5 border border-white/5 rounded-2xl p-3 flex flex-col items-center justify-center">
 <svg class="w-4 h-4 text-amber-400 mb-1.5" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" /></svg>
 <span class="text-xs font-black text-white leading-none">{{ Math.max(0, totalQuestions - totalCompletedCount) }}</span>
 <span class="text-[9px] font-bold text-slate-400 uppercase tracking-wider mt-1.5">Remaining</span>
 </div>
 <div class="bg-white/5 border border-white/5 rounded-2xl p-3 flex flex-col items-center justify-center">
 <svg class="w-4 h-4 text-rose-400 mb-1.5" fill="currentColor" viewBox="0 0 24 24"><path d="M17.657 16.657L13.414 20.9a1.998 1.998 0 01-2.827 0l-4.244-4.243a8 8 0 1111.314 0z" /><path d="M15 11a3 3 0 11-6 0 3 3 0 016 0z" /></svg>
 <span class="text-xs font-black text-white leading-none">Active</span>
 <span class="text-[9px] font-bold text-slate-400 uppercase tracking-wider mt-1.5">Status</span>
 </div>
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
 <p class="text-xs font-bold text-txt-disabled uppercase tracking-wider mb-1">{{ continueLearning.subjectName.replace(/_/g, ' ') }}</p>
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

 <!-- Recently Viewed -->
 <div v-if="recentlyViewed.length > 0" class="pt-8 border-t border-border">
 <div class="flex items-center gap-3 mb-4">
 <h3 class="text-sm font-extrabold text-txt-primary flex items-center gap-2 m-0">
 <svg class="w-4 h-4 text-txt-disabled shrink-0" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" /></svg>
 Recently Viewed
 </h3>
 <RouterLink :to="{ name: 'interview-prep-history' }" class="text-xs font-bold text-brand hover:text-indigo-600 transition-colors inline-flex items-center gap-0.5">
 View All
 <svg class="w-3.5 h-3.5" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M9 5l7 7-7 7" /></svg>
 </RouterLink>
 </div>
 <div class="flex gap-4 overflow-x-auto pb-4 snap-x hide-scrollbar">
 <RouterLink 
 v-for="item in recentlyViewed.slice(0, 5)" :key="item.questionId"
 :to="{ name: 'interview-prep-question', params: { subject: item.subjectSlug, question_id: item.questionId } }"
 class="snap-start shrink-0 w-80 bg-surface border border-border/60 rounded-2xl p-5 hover:border-brand/40 hover:shadow-xl hover:shadow-brand/5 transition-all group focus:outline-none focus:ring-4 focus:ring-brand/20 flex flex-col justify-between"
 >
 <div>
 <div class="flex items-center justify-between gap-2 mb-3">
 <span class="text-[10px] font-black uppercase tracking-wider text-txt-muted bg-surface-hover px-2 py-1 rounded">{{ item.subjectSlug.replace(/_/g, ' ') }}</span>
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

 <!-- Subject Grid -->
 <div v-if="loading" class="grid grid-cols-1 gap-6 pt-4">
 <div v-for="i in 4" :key="i" class="h-44 bg-surface-hover animate-pulse rounded-3xl border border-border/50"></div>
 </div>
 
 <template v-else>
   <!-- Subjects Section Header + Separator -->
   <div class="flex items-center gap-3 pt-6 pb-2">
     <div class="h-px flex-1 bg-gradient-to-r from-transparent via-border to-transparent"></div>
     <div class="flex items-center gap-2 shrink-0">
       <svg class="w-4 h-4 text-txt-muted" fill="none" viewBox="0 0 24 24" stroke="currentColor">
         <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 11H5m14 0a2 2 0 012 2v6a2 2 0 01-2 2H5a2 2 0 01-2-2v-6a2 2 0 012-2m14 0V9a2 2 0 00-2-2M5 11V9a2 2 0 012-2m0 0V5a2 2 0 012-2h6a2 2 0 012 2v2M7 7h10" />
       </svg>
       <span class="text-xs font-black uppercase tracking-widest text-txt-muted">
         Subjects<span v-if="searchQuery" class="ml-1.5 text-brand">({{ filteredSubjects.length }} found)</span>
       </span>
     </div>
     <div class="h-px flex-1 bg-gradient-to-r from-border via-border/50 to-transparent"></div>
   </div>

 <div v-if="filteredSubjects.length" class="grid grid-cols-1 gap-6 pb-4 content-start" :style="{ minHeight: '85vh' }">
 <div v-for="sub in filteredSubjects" :key="sub.slug" 
 class="group relative bg-surface rounded-3xl p-6 sm:p-8 shadow-sm border border-border/60 hover:shadow-xl hover:border-brand/30 transition-all duration-300 transform hover:-translate-y-1 overflow-hidden flex flex-col gap-6 cursor-pointer focus-within:ring-4 focus-within:ring-brand/20 focus-within:border-brand"
 @click="goToSubject(sub.slug)"
 role="article"
 tabindex="0"
 @keydown.enter="goToSubject(sub.slug)">
 
 <!-- Ambient background accent -->
 <div class="absolute -right-16 -top-16 w-64 h-64 bg-brand/5 rounded-full blur-3xl group-hover:bg-brand/10 transition-colors duration-500 pointer-events-none"></div>

 <!-- Top Row: Letter, Title, Progress Circle -->
 <div class="flex items-center justify-between gap-4 relative z-10 w-full">
 <!-- Left: Letter block + Title Info -->
 <div class="flex items-center gap-3 sm:gap-4 min-w-0">
 <!-- Letter block -->
 <div class="w-14 h-14 sm:w-20 sm:h-20 rounded-2xl bg-gradient-to-br flex items-center justify-center shadow-md group-hover:scale-105 group-hover:rotate-6 transition-all duration-300 border border-white/5 shrink-0"
 :class="getSubjectGradient(sub.slug)">
 <span class="text-2xl sm:text-4xl font-black">{{ sub.subject.charAt(0).toUpperCase() }}</span>
 </div>
 
 <!-- Title & Subtitle -->
 <div class="min-w-0 space-y-0.5 sm:space-y-1">
 <h2 class="text-lg sm:text-2xl font-extrabold text-txt-primary group-hover:text-brand transition-colors leading-tight truncate">
 {{ sub.subject.replace(/_/g, ' ') }}
 </h2>
 <p class="text-xs sm:text-sm font-semibold text-txt-muted truncate">
 {{ getSubjectSubtitle(sub.slug) }}
 </p>
 </div>
 </div>
 
 <!-- Right: Progress Circle -->
 <div class="flex items-center justify-center w-16 h-16 sm:w-28 sm:h-28 rounded-full border-[4px] sm:border-[8px] border-slate-100 dark:border-slate-800 relative shadow-sm bg-surface shrink-0" title="Subject Progress">
 <svg class="w-full h-full transform -rotate-90 p-0.5 sm:p-1" viewBox="0 0 36 36">
 <path class="text-slate-100 dark:text-slate-800" d="M18 2.0845 a 15.9155 15.9155 0 0 1 0 31.831 a 15.9155 15.9155 0 0 1 0 -31.831" fill="none" stroke="currentColor" stroke-width="4" />
 <path class="text-brand transition-all duration-1000 ease-out" 
 :stroke-dasharray="`${getSubjectStats(sub.slug, sub.question_count).progressPercentage}, 100`" 
 d="M18 2.0845 a 15.9155 15.9155 0 0 1 0 31.831 a 15.9155 15.9155 0 0 1 0 -31.831" 
 fill="none" stroke="currentColor" stroke-width="4" stroke-linecap="round" />
 </svg>
 <div class="absolute flex flex-col items-center justify-center text-center">
 <span class="text-xs sm:text-xl font-black text-txt-primary leading-tight">
 {{ getSubjectStats(sub.slug, sub.question_count).progressPercentage }}%
 </span>
 <span class="hidden sm:inline-block text-[8px] font-extrabold text-txt-muted uppercase tracking-wide mt-1.5 leading-none">Progress</span>
 </div>
 </div>
 </div>

 <!-- Badges Row -->
 <div class="flex flex-wrap items-center gap-2 text-xs font-semibold text-txt-muted relative z-10">
 <span class="flex items-center gap-1.5 bg-surface-hover text-txt-secondary px-2.5 py-1.5 rounded-xl border border-border/40">
 <svg class="w-3.5 h-3.5" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6.253v13m0-13C10.832 5.477 9.246 5 7.5 5S4.168 5.477 3 6.253v13C4.168 18.477 5.754 18 7.5 18s3.332.477 4.5 1.253m0-13C13.168 5.477 14.754 5 16.5 5c1.747 0 3.332.477 4.5 1.253v13C19.832 18.477 18.247 18 16.5 18c-1.746 0-3.332.477-4.5 1.253" /></svg>
 {{ sub.question_count }} Total Questions
 </span>
 <span class="flex items-center gap-1.5 bg-surface-hover text-txt-secondary px-2.5 py-1.5 rounded-xl border border-border/40">
 <svg class="w-3.5 h-3.5" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" /></svg>
 ~{{ Math.max(1, Math.round(getSubjectStats(sub.slug, sub.question_count).remaining * 15 / 60)) }}h left
 </span>
 </div>

 <!-- Divider Line -->
 <div class="w-full h-px bg-border/60 relative z-10 my-3"></div>

 <!-- Bottom Row: Progress bar & CTA button -->
 <div class="flex flex-col md:flex-row md:items-center justify-between gap-6 relative z-10 pt-1">
 
 <!-- Left: Horizontal Progress bar -->
 <div class="flex-1 space-y-2">
 <div class="flex justify-between items-center text-xs font-bold text-txt-secondary">
 <span>
 {{ getSubjectStats(sub.slug, sub.question_count).completed }} / {{ sub.question_count }} Questions Completed
 </span>
 <span class="text-brand">
 {{ getSubjectStats(sub.slug, sub.question_count).progressPercentage }}%
 </span>
 </div>
 <div class="w-full h-2 bg-slate-100 rounded-full overflow-hidden">
 <div class="h-full bg-brand rounded-full transition-all duration-500" :style="{ width: `${getSubjectStats(sub.slug, sub.question_count).progressPercentage}%` }"></div>
 </div>
 </div>

 <!-- Right: Button -->
 <div class="shrink-0">
 <button class="w-full md:w-auto inline-flex items-center justify-center bg-brand/5 text-brand px-6 py-3 rounded-xl text-sm font-extrabold group-hover:bg-brand group-hover:text-white transition-all shadow-sm group-hover:shadow-brand/20 active:scale-[0.98]" :aria-label="getSubjectStats(sub.slug, sub.question_count).completed > 0 ? 'Resume learning ' + sub.subject : 'Start prep ' + sub.subject">
 {{ getSubjectStats(sub.slug, sub.question_count).completed > 0 ? 'Resume Learning' : 'Start Prep' }}
 <svg class="w-4 h-4 ml-2 group-hover:translate-x-1.5 transition-transform duration-300" fill="none" viewBox="0 0 24 24" stroke="currentColor">
 <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M14 5l7 7m0 0l-7 7m7-7H3" />
 </svg>
 </button>
 </div>
 </div>
 </div>

 <!-- Tip Banner -->
 <div class="mt-8 bg-brand/5 border border-brand/10 rounded-2xl p-4 flex items-center gap-3 relative z-10">
 <div class="w-8 h-8 rounded-xl bg-brand/10 flex items-center justify-center shrink-0">
 <svg class="w-4 h-4 text-brand" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M9.663 17h4.673M12 3v1m6.364 1.636l-.707.707M21 12h-1M4 12H3m3.343-5.657l-.707-.707m2.828 9.9a5 5 0 117.072 0l-.548.547A3.374 3.374 0 0014 18.469V19a2 2 0 11-4 0v-.531c0-.895-.356-1.754-.988-2.386l-.548-.547z" /></svg>
 </div>
 <div class="text-xs sm:text-sm font-semibold text-txt-secondary flex flex-col sm:flex-row sm:items-center gap-1">
 <span class="font-extrabold text-brand uppercase tracking-wider">Tip:</span>
 <span>Consistent practice builds confidence. Start preparing now! 🚀</span>
 </div>
 </div>
 </div>
 
  <!-- Empty State -->
  <div v-else class="bg-surface rounded-3xl border border-dashed border-border-hover p-16 text-center max-w-2xl mx-auto mt-12 shadow-sm flex flex-col justify-center items-center" :style="{ minHeight: '60vh' }">
  <div class="w-24 h-24 mx-auto bg-background rounded-full flex items-center justify-center mb-6 border border-border">
  <svg class="w-10 h-10 text-txt-muted" fill="none" viewBox="0 0 24 24" stroke="currentColor" aria-hidden="true">
  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
  </svg>
  </div>
  <h3 class="text-xl font-extrabold text-txt-primary mb-2">No subjects found</h3>
  <p class="text-base text-txt-muted max-w-md mx-auto">We couldn't find any subjects matching your search criteria. Try a different term.</p>
  <button @click="searchQuery = ''" class="mt-6 inline-flex items-center justify-center bg-brand text-white px-6 py-2.5 rounded-xl text-sm font-bold hover:bg-brand/90 transition-all focus:outline-none focus:ring-4 focus:ring-slate-100">
  Clear Search
  </button>
  </div>
 </template>

 <!-- Floating Search Widget -->
 <div 
   class="fixed z-50 flex items-center"
   :class="isDragging ? '' : 'transition-all duration-300 ease-out'"
   :style="floatingStyle"
 >
   <div 
     class="flex items-center bg-surface border rounded-full shadow-2xl transition-all duration-300 ease-out overflow-hidden"
     :class="[
       isSearchExpanded ? 'p-2 border-brand ring-4 ring-brand/10' : 'w-14 h-14 p-0 border-border/60 hover:border-brand/40',
       isSearchExpanded ? 'w-[min(288px,calc(100vw-32px))] sm:w-96' : '',
     ]"
   >
     <!-- Search Icon/Button — order-1 (leftmost) when expanding right, order-3 (rightmost) when expanding left -->
     <button 
       @mousedown="handleDragStart"
       @touchstart="handleDragStart"
       @click="handleBtnClick"
       class="relative flex items-center justify-center shrink-0 rounded-full transition-colors focus:outline-none select-none"
       :class="[
         isSearchExpanded ? 'w-8 h-8 text-brand hover:bg-brand/5' : 'w-14 h-14 bg-brand text-white hover:scale-105 active:scale-95 shadow-lg',
         isSearchExpanded ? '' : (isDragging ? 'cursor-grabbing' : 'cursor-grab'),
         isSearchExpanded && expandsRight  ? 'order-1 ml-2' : '',
         isSearchExpanded && !expandsRight ? 'order-3 mr-2' : '',
       ]"
       aria-label="Search"
     >
       <svg class="w-5 h-5 pointer-events-none" fill="none" viewBox="0 0 24 24" stroke="currentColor">
         <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
       </svg>
       <!-- Active Filter Badge -->
       <span 
         v-if="!isSearchExpanded && searchQuery" 
         class="absolute -top-1 -right-1 flex h-4 w-4 items-center justify-center rounded-full bg-amber-500 text-[9px] font-black text-white ring-2 ring-white animate-pulse pointer-events-none"
       >
         !
       </span>
     </button>

     <!-- Input + Clear — always order-2 (middle) -->
     <div v-show="isSearchExpanded" class="order-2 flex-1 flex items-center min-w-0 mx-3 gap-1.5">
       <input 
         ref="searchInput"
         v-model="searchQuery" 
         type="text" 
         class="w-full bg-transparent border-0 p-0 text-sm font-semibold text-txt-primary placeholder-slate-400 focus:ring-0 focus:outline-none"
         placeholder="Search subjects..."
         @keydown.esc="closeSearch"
       />
       <!-- Clear Button — backspace icon, only when text exists -->
       <button
         v-if="searchQuery"
         @click="searchQuery = ''; searchInput?.focus()"
         class="w-6 h-6 flex items-center justify-center text-txt-muted hover:text-brand transition-colors focus:outline-none shrink-0"
         aria-label="Clear search"
       >
         <svg class="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
           <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
             d="M21 5H9.5a2 2 0 00-1.6.8L3 12l4.9 6.2a2 2 0 001.6.8H21a2 2 0 002-2V7a2 2 0 00-2-2z" />
           <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
             d="M13 9l5 5M18 9l-5 5" />
         </svg>
       </button>
     </div>

     <!-- Close/Collapse Button — order-3 (rightmost) when expanding right, order-1 (leftmost) when expanding left -->
     <button 
       v-show="isSearchExpanded"
       @click="closeSearch" 
       class="w-8 h-8 flex items-center justify-center text-txt-muted hover:text-txt-primary hover:bg-surface-hover rounded-full transition-colors focus:outline-none shrink-0"
       :class="[
         expandsRight  ? 'order-3 mr-1' : 'order-1 ml-1',
       ]"
       aria-label="Close search"
     >
       <svg class="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
         <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M6 18L18 6M6 6l12 12" />
       </svg>
     </button>
   </div>
 </div>
 </div>
 </AppShell>
</template>

<script setup>
import { ref, onMounted, onUnmounted, computed } from 'vue'
import { useRouter } from 'vue-router'
import AppShell from '../../components/layout/AppShell.vue'
import interviewPrepService from '../../services/interviewPrepService'
import { useInterviewState } from './composables/useInterviewState'

const router = useRouter()
const subjects = ref([])
const loading = ref(true)
const searchQuery = ref('')
const toastMsg = ref('')
const searchInput = ref(null)
const isMac = ref(false)
const isSearchExpanded = ref(false)
let toastTimer = null

// Draggable Floating Search State
const posX = ref(null)
const posY = ref(null)
const isDragging = ref(false)

// Stores the pre-computed left position and expand direction on open
const expandedLeft = ref(null)
const expandsRight = ref(true) // true = expand right (icon on left), false = expand left (icon on right)

const isLeftHalf = computed(() => {
  if (posX.value === null || typeof window === 'undefined') return false
  return posX.value < window.innerWidth / 2
})

const floatingStyle = computed(() => {
  if (posX.value === null || posY.value === null) return {}
  
  const left = (isSearchExpanded.value && expandedLeft.value !== null)
    ? expandedLeft.value
    : posX.value
  
  return {
    left: `${left}px`,
    top: `${posY.value}px`,
  }
})

// Computes an expanded left position that guarantees the bar fits on screen
const computeExpandedPosition = () => {
  const pad = 16
  const btnSize = 56
  // On small screens (< 640px) clamp to 288px, larger screens use 384px
  const expandedWidth = window.innerWidth < 640
    ? Math.min(288, window.innerWidth - pad * 2)
    : 384

  if (isLeftHalf.value) {
    // Expand to the right: anchor left edge at posX
    expandsRight.value = true
    let left = posX.value
    // Clamp so right edge stays on screen
    if (left + expandedWidth > window.innerWidth - pad) {
      left = window.innerWidth - pad - expandedWidth
    }
    expandedLeft.value = Math.max(pad, left)
  } else {
    // Expand to the left: anchor right edge near button's right
    expandsRight.value = false
    let left = posX.value - (expandedWidth - btnSize)
    // Clamp so left edge stays on screen
    if (left < pad) {
      left = pad
    }
    expandedLeft.value = left
  }
}

const toggleSearch = () => {
  computeExpandedPosition()
  isSearchExpanded.value = true
  setTimeout(() => {
   searchInput.value?.focus()
  }, 100)
}

const closeSearch = () => {
  isSearchExpanded.value = false
  expandedLeft.value = null
}

// Dragging Handlers
let startX = 0
let startY = 0
let initialPosX = 0
let initialPosY = 0
let hasMoved = false

const handleDragStart = (e) => {
  if (isSearchExpanded.value) return
  
  isDragging.value = true
  hasMoved = false
  
  const clientX = e.type.startsWith('touch') ? e.touches[0].clientX : e.clientX
  const clientY = e.type.startsWith('touch') ? e.touches[0].clientY : e.clientY
  
  startX = clientX
  startY = clientY
  initialPosX = posX.value
  initialPosY = posY.value
  
  document.addEventListener('mousemove', handleDragMove)
  document.addEventListener('mouseup', handleDragEnd)
  document.addEventListener('touchmove', handleDragMove, { passive: false })
  document.addEventListener('touchend', handleDragEnd)
}

const handleDragMove = (e) => {
  if (!isDragging.value) return
  if (e.cancelable) e.preventDefault()
  
  const clientX = e.type.startsWith('touch') ? e.touches[0].clientX : e.clientX
  const clientY = e.type.startsWith('touch') ? e.touches[0].clientY : e.clientY
  
  const deltaX = clientX - startX
  const deltaY = clientY - startY
  
  if (Math.abs(deltaX) > 5 || Math.abs(deltaY) > 5) {
    hasMoved = true
  }
  
  const newX = initialPosX + deltaX
  const newY = initialPosY + deltaY
  
  const padding = 20
  const btnSize = 56
  
  posX.value = Math.max(padding, Math.min(window.innerWidth - btnSize - padding, newX))
  posY.value = Math.max(padding, Math.min(window.innerHeight - btnSize - padding, newY))
}

const handleDragEnd = () => {
  isDragging.value = false
  document.removeEventListener('mousemove', handleDragMove)
  document.removeEventListener('mouseup', handleDragEnd)
  document.removeEventListener('touchmove', handleDragMove)
  document.removeEventListener('touchend', handleDragEnd)
}

const handleBtnClick = () => {
  if (hasMoved) return
  if (isSearchExpanded.value) {
    searchInput.value?.focus()
    return
  }
  toggleSearch()
}

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
 if (totalQuestions.value === 0) return '0'
 const pct = (totalCompletedCount.value / totalQuestions.value) * 100
 if (pct > 0 && pct < 1) {
  return pct.toFixed(2)
 }
 return pct % 1 === 0 ? pct.toFixed(0) : pct.toFixed(1)
})

const filteredSubjects = computed(() => {
 if (!searchQuery.value) return subjects.value
 const query = searchQuery.value.toLowerCase()
 return subjects.value.filter(sub => sub.subject.toLowerCase().includes(query))
})

const getSubjectGradient = (slug) => {
 const gradients = {
 dbms: 'from-blue-500 to-indigo-600 text-white',
 dsa: 'from-purple-500 to-fuchsia-600 text-white',
 java: 'from-amber-500 to-orange-600 text-white',
 os: 'from-teal-500 to-emerald-600 text-white',
 python: 'from-cyan-500 to-blue-600 text-white',
 system_design: 'from-rose-500 to-pink-600 text-white'
 }
 return gradients[slug] || 'from-slate-500 to-slate-600 text-white'
}

const getSubjectSubtitle = (slug) => {
 const subtitles = {
 dbms: 'Database Management Systems',
 dsa: 'Data Structures & Algorithms',
 java: 'Java Programming Language',
 os: 'Operating Systems',
 python: 'Python Programming Language',
 system_design: 'System Design & Architecture'
 }
 return subtitles[slug] || 'Master key concepts and practice questions'
}

const goToSubject = (slug) => {
 router.push({ name: 'interview-prep-subject', params: { subject: slug } })
}

onMounted(async () => {
 isMac.value = typeof navigator !== 'undefined' && /Mac|iPhone|iPod|iPad/i.test(navigator.userAgent)
 
 const handleResize = () => {
  if (posX.value !== null && posY.value !== null) {
   const padding = 20
   const btnSize = 56
   posX.value = Math.max(padding, Math.min(window.innerWidth - btnSize - padding, posX.value))
   posY.value = Math.max(padding, Math.min(window.innerHeight - btnSize - padding, posY.value))
  }
 }

 if (typeof window !== 'undefined') {
  posX.value = window.innerWidth - 80
  posY.value = window.innerHeight - 80
  window.addEventListener('resize', handleResize)
 }
 
 const handleKeyDown = (e) => {
 if ((e.metaKey || e.ctrlKey) && e.key.toLowerCase() === 'k') {
 e.preventDefault()
 isSearchExpanded.value = true
 setTimeout(() => {
  searchInput.value?.focus()
 }, 100)
 }
 }
 window.addEventListener('keydown', handleKeyDown)
 
 onUnmounted(() => {
 window.removeEventListener('keydown', handleKeyDown)
 window.removeEventListener('resize', handleResize)
 })

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
