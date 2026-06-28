<template>
  <div class="intelligence-panel space-y-4">
    <!-- Panel Header (Clean and minimal) -->
    <div class="flex items-center justify-between border-b border-slate-100 dark:border-slate-800/80 pb-3">
      <div class="flex items-center gap-2">
        <div class="flex h-5 w-5 items-center justify-center rounded-lg bg-gradient-to-br from-brand to-purple-600 shadow-sm">
          <svg class="size-3 text-white" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M12 2l2.4 7.2H22l-6.2 4.5 2.4 7.3L12 17l-6.2 4 2.4-7.3L2 9.2h7.6z"/></svg>
        </div>
        <h3 class="text-xs font-bold uppercase tracking-wider text-slate-700 dark:text-slate-300">Resume Intelligence</h3>
      </div>
      <span class="rounded-full bg-emerald-50 text-emerald-700 dark:bg-emerald-500/10 dark:text-emerald-400 px-2 py-0.5 text-[9px] font-bold uppercase tracking-wider">Free</span>
    </div>

    <!-- ═══ 1. Health Score HERO ═══ -->
    <div class="flex flex-col items-center justify-center p-6 text-center bg-white dark:bg-slate-900 rounded-2xl shadow-[0_4px_20px_rgba(15,23,42,0.03)] border border-slate-100/50 dark:border-slate-800/80 relative overflow-hidden group">
      <!-- Glow effect behind the ring -->
      <div class="absolute -inset-10 rounded-full bg-brand/5 dark:bg-brand/10 blur-3xl group-hover:bg-brand/10 dark:group-hover:bg-brand/20 transition-all duration-300 pointer-events-none"></div>
      
      <!-- Large Circular Progress Gauge -->
      <div class="relative flex items-center justify-center size-28 mb-4 cursor-pointer select-none" @click="toggleSection('health')">
        <svg viewBox="0 0 36 36" class="size-full transform -rotate-90 z-10">
          <circle cx="18" cy="18" r="15.5" fill="none" stroke="#f1f5f9" stroke-width="2" />
          <circle cx="18" cy="18" r="15.5" fill="none" :stroke="healthColorHex" stroke-width="2.5" stroke-dasharray="100" :stroke-dashoffset="100 - healthScore" stroke-linecap="round" class="transition-all duration-1000 ease-out" />
        </svg>
        <div class="absolute inset-0 flex flex-col items-center justify-center z-10 leading-none">
          <span class="text-3xl font-black text-slate-900 dark:text-white tracking-tight" :class="{ 'animate-score-pulse': scoreJustChanged }">{{ animatedScore }}</span>
          <span class="text-[9px] font-bold text-slate-400 dark:text-slate-500 uppercase tracking-widest mt-1">Health</span>
        </div>
      </div>

      <div class="space-y-1 z-10">
        <h4 class="text-base font-bold text-slate-900 dark:text-white leading-tight">{{ healthLabel }}</h4>
        <div class="flex items-center justify-center gap-1.5 mt-1">
          <span class="text-[10px] font-semibold px-2 py-0.5 rounded-full bg-slate-50 text-slate-600 border border-slate-100 dark:bg-slate-800 dark:text-slate-300 dark:border-slate-700">{{ experienceLevel.label }}</span>
          <span class="text-[10px] font-semibold px-2 py-0.5 rounded-full" :class="[
            healthScore >= 80 ? 'bg-emerald-50 text-emerald-700 border border-emerald-100/50 dark:bg-emerald-500/10 dark:text-emerald-400 dark:border-emerald-500/20' :
            healthScore >= 50 ? 'bg-amber-50 text-amber-700 border border-amber-100/50 dark:bg-amber-500/10 dark:text-amber-400 dark:border-amber-500/20' : 'bg-rose-50 text-rose-700 border border-rose-100/50 dark:bg-rose-500/10 dark:text-rose-400 dark:border-rose-500/20'
          ]">
            {{ healthScore >= 80 ? 'Top 10%' : healthScore >= 50 ? 'Top 40%' : 'Top 80%' }}
          </span>
        </div>
        <Transition name="fade">
          <p v-if="scoreDelta !== 0" class="text-xs font-bold text-emerald-600 mt-2 flex items-center justify-center gap-1">
            <svg class="size-3" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2.5"><path stroke-linecap="round" stroke-linejoin="round" d="M4.5 10.5L12 3m0 0l7.5 7.5M12 3v18"/></svg>
            <span>+{{ scoreDelta }} points improvement!</span>
          </p>
        </Transition>
      </div>

      <!-- Score breakdown collapsed within the hero -->
      <Transition name="slide">
        <div v-if="activeSection['']" class="w-full mt-4 pt-4 border-t border-slate-100 dark:border-slate-800/80 space-y-3 text-left">
          <p class="text-[10px] font-bold uppercase tracking-wider text-slate-400 dark:text-slate-500 mb-2">Score Breakdown</p>
          <div v-for="s in fullScoreBreakdown" :key="s.name" class="text-[11px] space-y-1">
            <div class="flex justify-between">
              <span class="font-medium text-slate-700 dark:text-slate-300">{{ s.name }}</span>
              <span class="font-semibold" :class="statusClass(s.status)">{{ s.score }}%</span>
            </div>
            <div class="h-1.5 w-full rounded-full bg-slate-100 dark:bg-slate-800 overflow-hidden">
              <div class="h-full rounded-full transition-all duration-500 ease-out" :class="bgStatusClass(s.status)" :style="{ width: `${s.score}%` }"></div>
            </div>
            <p class="text-[9px] text-slate-500 dark:text-slate-400 leading-normal">{{ s.reason }}</p>
          </div>
        </div>
      </Transition>
    </div>

    <!-- ═══ 2. Resume Coach ═══ -->
    <div class="intel-card group" :class="{ 'is-expanded': activeSection[''] }">
      <button type="button" class="w-full text-left focus:outline-none" @click="toggleSection('coach')" :aria-expanded="activeSection['']">
        <div class="flex items-center justify-between">
          <div class="flex items-center gap-2">
            <svg class="size-4 text-slate-400 group-hover:text-brand transition-colors duration-250" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M9.663 17h4.673M12 3v1m6.364 1.636l-.707.707M21 12h-1M4 12H3m3.343-5.657l-.707-.707m2.828 9.9a5 5 0 117.072 0l-.548.547A3.374 3.374 0 0014 18.469V19a2 2 0 11-4 0v-.531c0-.895-.356-1.754-.988-2.386l-.548-.547z"/></svg>
            <span class="text-xs font-bold text-slate-700 dark:text-slate-300">Resume Coach</span>
          </div>
          <svg class="size-4 text-slate-400 transition-transform duration-250 ease-out" :class="activeSection[''] && 'rotate-180'" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M6 9l6 6 6-6"/></svg>
        </div>
      </button>
      <Transition name="slide">
        <div v-if="activeSection['']" class="mt-3 border-t border-slate-100 dark:border-slate-800/80 pt-3 space-y-3">
          <template v-if="canUseResumeCoach">
            <div class="rounded-xl bg-gradient-to-br from-brand/5 to-purple-50 dark:from-brand/10 dark:to-purple-900/20 p-4 border border-brand/10 dark:border-brand/20">
              <p class="text-sm font-semibold text-ink dark:text-slate-200 leading-relaxed">Your resume is stronger than <span class="text-brand font-bold">{{ coachPercentile }}%</span> of {{ experienceLevel.label }} resumes.</p>
              <div class="mt-3 flex items-start gap-2">
                <span class="shrink-0 mt-0.5 text-brand">💡</span>
                <div>
                  <p class="text-[11px] font-bold text-slate-700 dark:text-slate-300">{{ coachRecommendation.title }}</p>
                  <p class="text-[10px] text-slate-500 dark:text-slate-400 mt-0.5">{{ coachRecommendation.detail }}</p>
                  <p class="text-[10px] font-bold text-brand mt-1">Estimated improvement: {{ coachRecommendation.impact }}</p>
                </div>
              </div>
            </div>
            <button type="button" class="w-full rounded-lg bg-slate-50 dark:bg-slate-800/50 border border-slate-100 dark:border-slate-700/50 px-3 py-2 text-[10px] font-semibold text-slate-400 dark:text-slate-500 flex items-center justify-center gap-1.5 cursor-not-allowed" title="AI coaching coming soon">
              <svg class="size-3" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M12 2l2.4 7.2H22l-6.2 4.5 2.4 7.3L12 17l-6.2 4 2.4-7.3L2 9.2h7.6z"/></svg>
              Get AI Coaching
              <span class="rounded bg-slate-100 dark:bg-slate-700 px-1 py-0.5 text-[8px] font-bold text-slate-500 dark:text-slate-400">COMING SOON</span>
            </button>
          </template>
          <template v-else>
            <PremiumFeatureCard
              title="AI Resume Coach"
              description="Unlock personalized recommendations tailored to your career stage and goals."
              requiredPlan="Plus"
              icon="💡"
              :benefits="[
                'Personalized Coach Insights',
                'Estimated Score Improvement Metrics',
                'Dynamic Action Items'
              ]"
              :upgradeAction="goToSettings"
            />
          </template>
        </div>
      </Transition>
    </div>

    <!-- ═══ 3. Resume Checklist ═══ -->
    <div class="intel-card group" :class="{ 'is-expanded': activeSection[''] }">
      <button type="button" class="w-full text-left focus:outline-none" @click="toggleSection('checklist')" :aria-expanded="activeSection['']">
        <div class="flex items-center justify-between">
          <div class="flex items-center gap-2">
            <svg class="size-4 text-slate-400 group-hover:text-brand transition-colors duration-250" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M9 11l3 3L22 4"/><path d="M21 12v7a2 2 0 01-2 2H5a4 2 0 01-2-2V5a2 2 0 012-2h11"/></svg>
            <span class="text-xs font-bold text-slate-700 dark:text-slate-300">Checklist</span>
          </div>
          <div class="flex items-center gap-2">
            <span class="text-[10px] font-semibold text-slate-500 dark:text-slate-400">{{ checklistDone }}/{{ checklist.length }} Completed</span>
            <svg class="size-4 text-slate-400 transition-transform duration-250 ease-out" :class="activeSection[''] && 'rotate-180'" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M6 9l6 6 6-6"/></svg>
          </div>
        </div>
      </button>
      <Transition name="slide">
        <div v-if="activeSection['']" class="mt-3 space-y-2 border-t border-slate-100 dark:border-slate-800/80 pt-3">
          <p class="text-[10px] font-medium text-slate-500 dark:text-slate-400 mb-2">
            {{ checklist.length - checklistDone === 0 ? 'Resume checklist complete!' : `${checklist.length - checklistDone} recommendation${checklist.length - checklistDone > 1 ? 's' : ''} remaining` }}
          </p>
          <div v-for="(item, i) in sortedChecklist" :key="i" class="rounded-lg p-2 text-[11px] transition-colors" :class="item.done ? 'bg-transparent opacity-60' : item.warning ? 'bg-amber-50/50 dark:bg-amber-500/10' : 'bg-red-50/50 dark:bg-red-500/10'">
            <div class="flex items-start gap-2">
              <span class="mt-0.5 shrink-0 text-xs" :class="item.done ? 'text-emerald-500' : item.warning ? 'text-amber-500' : 'text-red-500'">
                {{ item.done ? '✓' : item.warning ? '⚠' : '✖' }}
              </span>
              <div>
                <p class="font-semibold" :class="item.done ? 'text-slate-500 line-through' : 'text-slate-800 dark:text-slate-200'">{{ item.label }}</p>
                <div v-if="!item.done" class="mt-1 space-y-0.5">
                  <p class="text-slate-600 dark:text-slate-400">{{ item.why }}</p>
                  <p class="text-brand font-medium">Fix: {{ item.fix }}</p>
                </div>
              </div>
            </div>
          </div>
        </div>
      </Transition>
    </div>

    <!-- ═══ 4. ATS Analysis ═══ -->
    <div class="intel-card group" :class="{ 'is-expanded': activeSection[''] }">
      <button type="button" class="w-full text-left focus:outline-none" @click="toggleSection('ats')" :aria-expanded="activeSection['']">
        <div class="flex items-center justify-between">
          <div class="flex items-center gap-2">
            <svg class="size-4 text-slate-400 group-hover:text-brand transition-colors duration-250" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z"/></svg>
            <span class="text-xs font-bold text-slate-700 dark:text-slate-300">ATS Score</span>
            <span v-if="canUseATS" class="rounded-full px-1.5 py-0.5 text-[9px] font-bold" :class="atsScoreBadge">{{ atsAnalysis.score }}%</span>
            <span v-else class="rounded-full bg-slate-100 dark:bg-slate-800 px-1.5 py-0.5 text-[9px] font-bold text-slate-500 dark:text-slate-400 flex items-center gap-0.5">
              <svg class="size-2.5" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2.5"><path d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z"/></svg>
              Locked
            </span>
          </div>
          <svg class="size-4 text-slate-400 transition-transform duration-250 ease-out" :class="activeSection[''] && 'rotate-180'" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M6 9l6 6 6-6"/></svg>
        </div>
      </button>
      <Transition name="slide">
        <div v-if="activeSection['']" class="mt-3 border-t border-slate-100 dark:border-slate-800/80 pt-3">
          <template v-if="canUseATS">
            <div class="space-y-2 max-h-[350px] overflow-y-auto custom-scrollbar w-full">
              <div v-for="rule in atsAnalysis.rules" :key="rule.id" class="rounded-lg p-2 text-[11px] cursor-pointer transition-colors" :class="rule.passed ? 'bg-emerald-50/50 hover:bg-emerald-50 dark:bg-emerald-500/10 dark:hover:bg-emerald-500/20' : rule.category === 'critical' ? 'bg-red-50/50 hover:bg-red-50 dark:bg-red-500/10 dark:hover:bg-red-500/20' : 'bg-amber-50/50 hover:bg-amber-50 dark:bg-amber-500/10 dark:hover:bg-amber-500/20'" @click="toggleAtsRule(rule.id)">
                <div class="flex items-start justify-between gap-2">
                  <div class="flex items-start gap-2">
                    <span class="mt-0.5 shrink-0" :class="rule.passed ? 'text-emerald-500' : rule.category === 'critical' ? 'text-red-500' : 'text-amber-500'">
                      {{ rule.passed ? '✓' : rule.category === 'critical' ? '✖' : '⚠' }}
                    </span>
                    <p class="font-semibold text-slate-800 dark:text-slate-200">{{ rule.title }}</p>
                  </div>
                  <svg class="size-3 text-slate-400 transition-transform" :class="expandedAtsRules[rule.id] && 'rotate-180'" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M6 9l6 6 6-6"/></svg>
                </div>
                
                <Transition name="slide-fast">
                  <div v-if="expandedAtsRules[rule.id]" class="mt-2 pl-5 space-y-1">
                    <p class="text-slate-600 dark:text-slate-400"><span class="font-medium text-slate-700 dark:text-slate-300">Why it matters:</span> {{ rule.description }}</p>
                    <p v-if="!rule.passed" class="text-slate-600 dark:text-slate-400"><span class="font-medium text-slate-700 dark:text-slate-300">Impact:</span> {{ rule.impact }}</p>
                    <p v-if="!rule.passed" class="text-brand font-medium mt-1">Fix: {{ rule.fix }}</p>
                  </div>
                </Transition>
              </div>
            </div>
          </template>
          <template v-else>
            <PremiumFeatureCard
              title="ATS Score & Analysis"
              description="Find out how well your resume matches recruiter applicant tracking systems to fix compliance issues."
              requiredPlan="Plus"
              icon="🔒"
              :benefits="[
                'Detailed ATS compatibility score',
                'Keyword Optimization suggestions',
                'Industry comparison & validation',
                'Detailed ATS warnings & compliance checks'
              ]"
              :upgradeAction="goToSettings"
            />
          </template>
        </div>
      </Transition>
    </div>

    <!-- ═══ 5. Keyword Analysis ═══ -->
    <div class="intel-card group" :class="{ 'is-expanded': activeSection[''] }">
      <button type="button" class="w-full text-left focus:outline-none" @click="toggleSection('keywords')" :aria-expanded="activeSection['']">
        <div class="flex items-center justify-between">
          <div class="flex items-center gap-2">
            <svg class="size-4 text-slate-400 group-hover:text-brand transition-colors duration-250" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="11" cy="11" r="8"/><path d="M21 21l-4.35-4.35"/></svg>
            <span class="text-xs font-bold text-slate-700 dark:text-slate-300">Keywords</span>
            <span v-if="targetRole && canUseKeywords" class="rounded-full px-1.5 py-0.5 text-[9px] font-bold" :class="keywordBadge">{{ keywordAnalysis.coverage }}%</span>
            <span v-else-if="!canUseKeywords" class="rounded-full bg-slate-100 dark:bg-slate-800 px-1.5 py-0.5 text-[9px] font-bold text-slate-500 dark:text-slate-400 flex items-center gap-0.5">
              <svg class="size-2.5" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2.5"><path d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z"/></svg>
              Locked
            </span>
          </div>
          <svg class="size-4 text-slate-400 transition-transform duration-250 ease-out" :class="activeSection[''] && 'rotate-180'" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M6 9l6 6 6-6"/></svg>
        </div>
      </button>
      <Transition name="slide">
        <div v-if="activeSection['']" class="mt-3 border-t border-slate-100 dark:border-slate-800/80 pt-3">
          <template v-if="canUseKeywords">
            <div v-if="!targetRole" class="rounded-lg bg-slate-50 dark:bg-slate-800/50 p-3 text-center border border-slate-100 dark:border-slate-700/50">
              <svg class="size-6 text-slate-400 mx-auto mb-2" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5"><circle cx="11" cy="11" r="8"/><path d="M21 21l-4.35-4.35"/></svg>
              <p class="text-xs font-semibold text-slate-700 dark:text-slate-300">No Target Role Selected</p>
              <p class="text-[10px] text-slate-500 dark:text-slate-400 mt-1">Select a target job role in the form above to see ATS keyword match analysis.</p>
            </div>
            <div v-else class="space-y-3">
              <div>
                <p class="text-[10px] text-slate-500 dark:text-slate-400">Analysis based on: <span class="font-bold text-brand">{{ targetRole }}</span></p>
                <p class="text-[9px] text-slate-400 mt-0.5">This role is only used for keyword analysis and is not added to your resume.</p>
              </div>
              
              <div class="text-[11px]">
                <div class="flex justify-between mb-1">
                  <span class="font-medium text-slate-700 dark:text-slate-300">Coverage</span>
                  <span class="font-semibold text-ink dark:text-slate-200">{{ keywordAnalysis.coverage }}%</span>
                </div>
                <div class="h-1.5 w-full rounded-full bg-slate-100 dark:bg-slate-800 overflow-hidden">
                  <div class="h-full rounded-full transition-all duration-500 bg-brand" :style="{ width: `${keywordAnalysis.coverage}%` }"></div>
                </div>
                <p v-if="keywordAnalysis.missing.length > 0" class="text-[9px] text-brand/80 mt-1 font-medium">Add missing keywords to boost your ATS score.</p>
              </div>

              <div>
                <p class="text-[10px] font-bold uppercase tracking-wider text-emerald-600 mb-1">Detected ({{ keywordAnalysis.detected.length }})</p>
                <div class="flex flex-wrap gap-1">
                  <span v-for="kw in keywordAnalysis.detected" :key="kw" class="rounded bg-emerald-50 dark:bg-emerald-500/10 px-1.5 py-0.5 text-[10px] font-medium text-emerald-700 dark:text-emerald-400 border border-emerald-100 dark:border-emerald-500/20">{{ kw }}</span>
                  <span v-if="keywordAnalysis.detected.length === 0" class="text-[10px] text-slate-400 italic">No exact matches yet</span>
                </div>
              </div>
              <div v-if="keywordAnalysis.missing.length">
                <p class="text-[10px] font-bold uppercase tracking-wider text-amber-600 mb-1">Missing ({{ keywordAnalysis.missing.length }})</p>
                <div class="flex flex-wrap gap-1">
                  <span v-for="kw in keywordAnalysis.missing.slice(0, 15)" :key="kw" class="rounded bg-amber-50 dark:bg-amber-500/10 px-1.5 py-0.5 text-[10px] font-medium text-amber-700 dark:text-amber-400 border border-amber-100 dark:border-amber-500/20">{{ kw }}</span>
                  <span v-if="keywordAnalysis.missing.length > 15" class="text-[10px] text-slate-400">+{{ keywordAnalysis.missing.length - 15 }} more</span>
                </div>
              </div>
            </div>
          </template>
          <template v-else>
            <PremiumFeatureCard
              title="Keyword Analysis & Optimization"
              description="Extract and match critical job keywords directly from target role description."
              requiredPlan="Plus"
              icon="🔑"
              :benefits="[
                'Live keyword coverage percentage',
                'Detected & missing keyword identification',
                'Role description relevance feedback'
              ]"
              :upgradeAction="goToSettings"
            />
          </template>
        </div>
      </Transition>
    </div>

    <!-- ═══ 6. Statistics ═══ -->
    <div class="intel-card group" :class="{ 'is-expanded': activeSection[''] }">
      <button type="button" class="w-full text-left focus:outline-none" @click="toggleSection('stats')" :aria-expanded="activeSection['']">
        <div class="flex items-center justify-between">
          <div class="flex items-center gap-2">
            <svg class="size-4 text-slate-400 group-hover:text-brand transition-colors duration-250" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M18 20V10M12 20V4M6 20v-6"/></svg>
            <span class="text-xs font-bold text-slate-700 dark:text-slate-300">Statistics</span>
          </div>
          <svg class="size-4 text-slate-400 transition-transform duration-250 ease-out" :class="activeSection[''] && 'rotate-180'" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M6 9l6 6 6-6"/></svg>
        </div>
      </button>
      <Transition name="slide">
        <div v-if="activeSection['']" class="mt-3 border-t border-slate-100 dark:border-slate-800/80 pt-3">
          <div class="grid grid-cols-2 gap-2">
            <div v-for="(val, key) in statsDisplay" :key="key" class="flex flex-col rounded-xl bg-slate-50/50 dark:bg-slate-800/50 border border-slate-100/60 dark:border-slate-700/50 p-3 relative overflow-hidden group">
              <!-- Decorative subtle background element -->
              <div class="absolute -right-2 -bottom-2 opacity-[0.03] group-hover:opacity-[0.08] transition-opacity text-slate-900 dark:text-slate-200 z-0">
                <svg class="size-12" viewBox="0 0 24 24" fill="currentColor"><path d="M21 21H3v-2h18v2zM3 17V3h2v14H3zm4 0V7h2v10H7zm4 0V9h2v8h-2zm4 0v-4h2v4h-2zm4 0V5h2v12h-2z"/></svg>
              </div>
              <span class="text-[9px] font-bold uppercase tracking-widest text-slate-400 mb-1 z-10">{{ key }}</span>
              <span class="text-xs font-extrabold text-slate-800 dark:text-slate-200 z-10">{{ val }}</span>
            </div>
          </div>
        </div>
      </Transition>
    </div>

    <!-- ═══ 7. Experience Level ═══ -->
    <div class="intel-card group" :class="{ 'is-expanded': activeSection[''] }">
      <button type="button" class="w-full text-left focus:outline-none" @click="toggleSection('level')" :aria-expanded="activeSection['']">
        <div class="flex items-center justify-between">
          <div class="flex items-center gap-2">
            <svg class="size-4 text-slate-400 group-hover:text-brand transition-colors duration-250" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M16 21v-2a4 4 0 00-4-4H5a4 4 0 00-4 4v2"/><circle cx="8.5" cy="7" r="4"/><path d="M20 8v6M23 11h-6"/></svg>
            <span class="text-xs font-bold text-slate-700 dark:text-slate-300">Level Profile</span>
          </div>
          <div class="flex items-center gap-1">
            <span class="rounded-full bg-brand/10 px-2 py-0.5 text-[9px] font-bold uppercase tracking-wider text-brand">{{ experienceLevel.label }}</span>
            <svg class="size-4 text-slate-400 transition-transform duration-250 ease-out" :class="activeSection[''] && 'rotate-180'" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M6 9l6 6 6-6"/></svg>
          </div>
        </div>
      </button>
      <Transition name="slide">
        <div v-if="activeSection['']" class="mt-3 border-t border-slate-100 dark:border-slate-800/80 pt-3 space-y-3">
          <div class="grid grid-cols-2 gap-2 text-[11px]">
            <div>
              <p class="text-slate-400 text-[10px]">Career Level</p>
              <p class="font-bold text-slate-700 dark:text-slate-300">{{ experienceLevel.label }}</p>
            </div>
            <div>
              <p class="text-slate-400 text-[10px]">Experience</p>
              <p class="font-bold text-slate-700 dark:text-slate-300">{{ experienceLevel.years }} Years</p>
            </div>
            <div>
              <p class="text-slate-400 text-[10px]">Rec. Length</p>
              <p class="font-bold text-slate-700 dark:text-slate-300">{{ experienceLevel.pages }} page{{ experienceLevel.pages > 1 ? 's' : '' }}</p>
            </div>
            <div>
              <p class="text-slate-400 text-[10px]">Readiness</p>
              <p class="font-bold text-emerald-600 dark:text-emerald-500">{{ experienceLevel.readiness }}</p>
            </div>
          </div>
          <div>
            <p class="text-[10px] text-slate-500 mb-1.5">Recommended Focus Areas:</p>
            <div class="flex flex-wrap gap-1">
              <span v-for="h in experienceLevel.highlights" :key="h" class="rounded border border-brand/20 bg-brand/5 px-1.5 py-0.5 text-[9px] font-medium text-brand">{{ h }}</span>
            </div>
          </div>
        </div>
      </Transition>
    </div>

  </div>
</template>

<script setup>
import { ref, reactive, computed, watch, onMounted } from 'vue'
import { useStore } from 'vuex'
import { useRouter } from 'vue-router'
import PremiumFeatureCard from '../../components/ui/PremiumFeatureCard.vue'

const store = useStore()
const router = useRouter()
const user = computed(() => store?.state?.auth?.user)
const canUseResumeCoach = computed(() => user.value ? (user.value.canUseResumeCoach ?? false) : false)
const canUseATS = computed(() => user.value ? (user.value.canUseATS ?? false) : false)
const canUseKeywords = computed(() => user.value ? (user.value.canUseKeywords ?? false) : false)

const goToSettings = () => {
  router.push('/settings')
}

// ─── Animated Score Counter ───
const animatedScore = ref(0)
const scoreDelta = ref(0)
const scoreJustChanged = ref(false)
let prevScore = 0

const props = defineProps({
  healthScore: { type: Number, default: 0 },
  healthLabel: { type: String, default: '' },
  healthColor: { type: String, default: 'slate' },
  sectionHealth: { type: Array, default: () => [] },
  atsAnalysis: { type: Object, default: () => ({ score: 0, rules: [] }) },
  keywordAnalysis: { type: Object, default: () => ({ detected: [], missing: [], coverage: 0, total: 0 }) },
  checklist: { type: Array, default: () => [] },
  statistics: { type: Object, default: () => ({}) },
  tips: { type: Array, default: () => [] },
  experienceLevel: { type: Object, default: () => ({ label: 'Fresher', pages: 1, highlights: [], years: 0, readiness: 'Growing' }) },
  targetRole: { type: String, default: '' }
})

// Accordion logic
const activeSection = reactive({})

onMounted(() => {
  const saved = localStorage.getItem('careerai_intel_accordion')
  if (saved) activeSection[saved] = true
  animatedScore.value = props.healthScore
  prevScore = props.healthScore
})

const healthColorHex = computed(() => {
  if (props.healthScore >= 80) return '#10b981' // emerald
  if (props.healthScore >= 50) return '#f59e0b' // amber
  return '#ef4444' // red
})

// Watch health score for animated counter
watch(() => props.healthScore, (newVal) => {
  const delta = newVal - prevScore
  if (delta !== 0) {
    scoreDelta.value = delta
    scoreJustChanged.value = true
    // Animate count
    const start = animatedScore.value
    const duration = 600
    const startTime = performance.now()
    const animate = (now) => {
      const elapsed = now - startTime
      const progress = Math.min(elapsed / duration, 1)
      const eased = 1 - Math.pow(1 - progress, 3)
      animatedScore.value = Math.round(start + (newVal - start) * eased)
      if (progress < 1) requestAnimationFrame(animate)
    }
    requestAnimationFrame(animate)
    prevScore = newVal
    setTimeout(() => { scoreDelta.value = 0; scoreJustChanged.value = false }, 2500)
  }
})

const toggleSection = (section) => {
  activeSection[section] = !activeSection[section]
}

// ATS rules expansion logic
const expandedAtsRules = reactive({})
const toggleAtsRule = (id) => {
  expandedAtsRules[id] = !expandedAtsRules[id]
}

// Computed helpers
const fullScoreBreakdown = computed(() => {
  const breakdown = [...props.sectionHealth]
  
  if (canUseATS.value) {
    // Add ATS score
    breakdown.push({
      name: 'ATS Compatibility',
      score: props.atsAnalysis.score,
      status: props.atsAnalysis.score >= 80 ? 'good' : props.atsAnalysis.score >= 60 ? 'warning' : 'missing',
      reason: `Based on ${props.atsAnalysis.passedCount} passing ATS rules`
    })
  }
  
  if (canUseKeywords.value && props.targetRole) {
    // Add Keyword Coverage
    breakdown.push({
      name: 'Keyword Match',
      score: props.keywordAnalysis.coverage,
      status: props.keywordAnalysis.coverage >= 60 ? 'good' : props.keywordAnalysis.coverage >= 30 ? 'warning' : 'missing',
      reason: `Matched against '${props.targetRole}' keywords`
    })
  }

  return breakdown
})

const sortedChecklist = computed(() => {
  // Sort missing first, then warning, then done
  return [...props.checklist].sort((a, b) => {
    if (a.done !== b.done) return a.done ? 1 : -1
    if (a.warning !== b.warning) return a.warning ? -1 : 1
    return 0
  })
})

const checklistDone = computed(() => props.checklist.filter(c => c.done).length)

const statusClass = (status) => ({
  'text-emerald-600': status === 'good',
  'text-amber-600': status === 'warning',
  'text-red-500': status === 'missing'
})

const bgStatusClass = (status) => ({
  'bg-emerald-500': status === 'good',
  'bg-amber-500': status === 'warning',
  'bg-red-500': status === 'missing'
})

const atsScoreBadge = computed(() => {
  if (props.atsAnalysis.score >= 80) return 'bg-emerald-50 text-emerald-700'
  if (props.atsAnalysis.score >= 60) return 'bg-amber-50 text-amber-700'
  return 'bg-red-50 text-red-600'
})

const keywordBadge = computed(() => {
  if (props.keywordAnalysis.coverage >= 60) return 'bg-emerald-50 text-emerald-700'
  if (props.keywordAnalysis.coverage >= 30) return 'bg-amber-50 text-amber-700'
  return 'bg-red-50 text-red-600'
})

const statsDisplay = computed(() => {
  const s = props.statistics
  return {
    'Word Count': s.words ?? 0,
    'Reading Time': s.readingTime ?? '—',
    'ATS Parse Time': s.atsParsingTime ?? '—',
    'Resume Length': s.resumeLength ?? '—',
    'Density': s.density ?? '—',
    'Sections': s.sections ?? 0,
    'Skills': s.skills ?? 0,
    'Projects': s.projects ?? 0,
  }
})

// ─── Resume Coach Logic ───
const coachPercentile = computed(() => {
  const score = props.healthScore
  if (score >= 90) return 95
  if (score >= 80) return 82
  if (score >= 70) return 68
  if (score >= 60) return 52
  if (score >= 50) return 38
  return Math.max(10, Math.round(score * 0.6))
})

const coachRecommendation = computed(() => {
  const score = props.healthScore
  const level = props.experienceLevel?.label || 'Fresher'
  
  if (score < 40) return { title: 'Complete your core sections', detail: `${level} resumes need at least personal info, experience or projects, education, and skills to be competitive.`, impact: '+15-25 points' }
  if (score < 60) return { title: 'Add measurable achievements', detail: 'Include numbers, percentages, and metrics in your experience descriptions to stand out.', impact: '+8-12 points' }
  if (score < 75) return { title: 'Optimize for ATS systems', detail: 'Add relevant keywords and ensure your resume uses standard section headings that applicant tracking systems recognize.', impact: '+5-10 points' }
  if (score < 85) return { title: 'Strengthen your professional summary', detail: 'A compelling 3-4 sentence summary can significantly improve recruiter engagement.', impact: '+3-6 points' }
  return { title: 'Fine-tune and polish', detail: 'Your resume is in great shape. Focus on tailoring it for each specific role you apply to.', impact: '+1-3 points' }
})
</script>

<style scoped>
.intel-card {
  @apply rounded-xl border border-slate-100 dark:border-slate-800/80 bg-white dark:bg-slate-900 p-4 shadow-[0_1px_3px_rgba(0,0,0,0.01),0_1px_2px_rgba(0,0,0,0.02)] transition-all duration-200;
}
.intel-card.is-expanded {
  @apply shadow-[0_10px_30px_rgba(15,23,42,0.04)] border-brand/10 dark:border-brand/20;
}
.intel-card:hover:not(.is-expanded) {
  @apply border-slate-200/80 dark:border-slate-700 shadow-[0_2px_8px_rgba(0,0,0,0.02)] -translate-y-[0.5px];
}

/* Base accordion slide transition */
.slide-enter-active, .slide-leave-active {
  transition: max-height 0.25s cubic-bezier(0.16, 1, 0.3, 1), opacity 0.2s ease;
  overflow: hidden;
}
.slide-enter-from, .slide-leave-to {
  max-height: 0;
  opacity: 0;
}
.slide-enter-to, .slide-leave-from {
  max-height: 1200px;
  opacity: 1;
}

/* Faster slide for internal elements like ATS rules */
.slide-fast-enter-active, .slide-fast-leave-active {
  transition: max-height 0.2s cubic-bezier(0.16, 1, 0.3, 1), opacity 0.15s ease;
  overflow: hidden;
}
.slide-fast-enter-from, .slide-fast-leave-to {
  max-height: 0;
  opacity: 0;
}
.slide-fast-enter-to, .slide-fast-leave-from {
  max-height: 200px;
  opacity: 1;
}

/* Fade transition for score delta */
.fade-enter-active, .fade-leave-active {
  transition: opacity 0.3s ease, transform 0.3s ease;
}
.fade-enter-from {
  opacity: 0;
  transform: translateY(4px);
}
.fade-leave-to {
  opacity: 0;
  transform: translateY(-8px);
}

/* Mobile: more breathing room */
@media (max-width: 768px) {
  .intel-card {
    padding: 16px;
  }
}
</style>
