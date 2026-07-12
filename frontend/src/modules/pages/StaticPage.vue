<template>
  <PublicLayout>
    <!-- Modern Header Banner with glowing blur gradients -->
    <div class="relative overflow-hidden border-b border-border bg-slate-900 text-white px-5 py-20 lg:py-24">
      <div class="pointer-events-none absolute -right-24 top-0 size-96 rounded-full bg-brand/10 blur-[100px]" />
      <div class="pointer-events-none absolute -left-20 bottom-0 size-80 rounded-full bg-emerald-500/5 blur-[100px]" />
      
      <div class="relative mx-auto max-w-4xl text-center">
        <!-- Badge -->
        <span 
          v-if="page.badge" 
          class="inline-flex items-center gap-1.5 rounded-full bg-brand/20 px-4 py-1.5 text-xs font-bold uppercase tracking-wider text-brand ring-1 ring-brand/30"
        >
          {{ page.badge }}
        </span>
        
        <!-- Main Title -->
        <h1 class="mt-6 text-4xl font-extrabold tracking-tight sm:text-5xl lg:text-6xl text-white animate-fade-in">
          {{ page.title }}
        </h1>
        
        <!-- Subtitle -->
        <p v-if="page.subtitle" class="mx-auto mt-6 max-w-2xl text-base sm:text-lg leading-8 text-slate-300">
          {{ page.subtitle }}
        </p>
        
        <!-- Last Updated -->
        <p v-if="page.updated" class="mt-6 text-xs sm:text-sm text-slate-400">
          {{ t('pages.lastUpdated', { date: page.updated }) }}
        </p>
      </div>
    </div>

    <!-- Main Content Body -->
    <div class="bg-background pb-12">
      <!-- COMING SOON VIEW (e.g. Blog) -->
      <section v-if="page.comingSoon" class="mx-auto max-w-6xl px-5 py-20">
        <div class="relative rounded-3xl border border-border/80 bg-surface/50 p-6 sm:p-10 md:p-16 text-center shadow-panel backdrop-blur-sm overflow-hidden">
          <!-- Background decoration -->
          <div class="absolute inset-0 opacity-10 bg-[radial-gradient(ellipse_80%_80%_at_50%_-20%,rgba(109,74,255,0.3),rgba(255,255,255,0))]" />
          
          <!-- Mock Blog Cards blurred in background -->
          <div class="grid grid-cols-1 md:grid-cols-3 gap-6 opacity-30 blur-[4px] pointer-events-none mb-10">
            <div v-for="i in 3" :key="i" class="rounded-2xl border border-border p-6 bg-surface text-left shadow-sm">
              <div class="h-40 w-full rounded-xl bg-slate-200 mb-4" />
              <div class="h-6 w-3/4 bg-slate-300 rounded mb-2" />
              <div class="h-4 w-1/2 bg-slate-200 rounded" />
            </div>
          </div>

          <!-- Glass overlay content -->
          <div class="relative z-10 mx-auto max-w-md">
            <div class="mx-auto mb-6 grid size-16 place-items-center rounded-2xl bg-brand/10 text-brand">
              <svg class="size-8 animate-pulse" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="1.75">
                <path stroke-linecap="round" stroke-linejoin="round" d="M19.5 14.25v-2.625a3.375 3.375 0 00-3.375-3.375h-1.5A1.125 1.125 0 0113.5 7.125v-1.5a3.375 3.375 0 00-3.375-3.375H8.25m0 12.75h7.5m-7.5 3H12M10.5 2.25H5.625c-.621 0-1.125.504-1.125 1.125v17.25c0 .621.504 1.125 1.125 1.125h12.75c.621 0 1.125-.504 1.125-1.125V11.25a9 9 0 00-9-9z" />
              </svg>
            </div>
            <h2 class="text-2xl font-extrabold text-txt-primary sm:text-3xl">Blog launching soon</h2>
            <p class="mt-4 text-sm sm:text-base text-txt-secondary leading-7">
              We are preparing career insights, resume templates guides, and interviews hacks to boost your applications.
            </p>
            <div class="mt-8 flex flex-col sm:flex-row gap-3 justify-center">
              <input type="email" placeholder="you@email.com" class="rounded-xl border border-border bg-surface px-4 py-2.5 text-sm text-txt-primary focus:outline-none focus:border-brand focus:ring-1 focus:ring-brand w-full sm:w-64 shadow-sm" />
              <button 
                type="button" 
                class="rounded-xl bg-brand px-6 py-2.5 text-sm font-bold text-white transition-all shadow-md shadow-brand/20 hover:bg-brand/90"
                @click="openComingSoonModal('Blog')"
              >
                Notify me
              </button>
            </div>
          </div>
        </div>
      </section>

      <!-- GENERAL CONTENT VIEW -->
      <section v-else class="mx-auto max-w-6xl px-5 py-16">
        
        <!-- INTERACTIVE FEATURES SHOWCASE (ONLY FOR FEATURES PAGE) -->
        <div v-if="pageKey === 'features'" class="space-y-16">
          
          <!-- Interactive Widget Title -->
          <div class="text-center max-w-2xl mx-auto mb-10">
            <span class="text-xs font-extrabold uppercase tracking-wider text-brand bg-brand/5 px-3 py-1 rounded-full">Interactive Demo</span>
            <h2 class="mt-3 text-3xl font-extrabold text-txt-primary">Experience the Platform Live</h2>
            <p class="mt-2 text-sm text-txt-secondary">Click the tabs below to test-drive our core features right on this page.</p>
          </div>

          <!-- Tabs navigation -->
          <div class="flex flex-wrap items-center justify-center gap-2 p-1.5 bg-slate-100 dark:bg-slate-800/80 rounded-2xl max-w-3xl mx-auto border border-border">
            <button 
              v-for="tab in featureTabs" 
              :key="tab.id"
              type="button"
              class="flex items-center gap-2 px-4 py-2.5 rounded-xl text-xs sm:text-sm font-bold transition-all"
              :class="activeFeatureTab === tab.id ? 'bg-white dark:bg-slate-900 text-brand shadow-sm border border-border/40' : 'text-txt-secondary hover:text-txt-primary hover:bg-white/50 dark:hover:bg-slate-900/30'"
              @click="activeFeatureTab = tab.id"
            >
              <component :is="tab.icon" class="size-4 shrink-0" />
              {{ tab.label }}
            </button>
          </div>

          <!-- Interactive Content Panel -->
          <div class="rounded-3xl border border-border/80 bg-surface p-6 sm:p-8 md:p-10 shadow-lg min-h-[420px] relative overflow-hidden transition-all duration-300">
            
            <!-- 1. RESUME BUILDER INTERACTIVE DEMO -->
            <div v-if="activeFeatureTab === 'builder'" class="grid grid-cols-1 lg:grid-cols-[280px_1fr] gap-8">
              <!-- Controls Sidebar -->
              <div class="space-y-6 bg-slate-50/50 dark:bg-slate-800/20 border border-border/60 rounded-2xl p-5">
                <h4 class="text-sm font-extrabold text-txt-primary uppercase tracking-wide border-b border-border pb-2">Customizer Panel</h4>
                
                <!-- Accent Colors -->
                <div class="space-y-2">
                  <label class="text-xs font-bold text-txt-secondary">Theme Color</label>
                  <div class="flex items-center gap-2">
                    <button 
                      v-for="color in themeColors" 
                      :key="color.value"
                      type="button"
                      class="size-7 rounded-full border-2 transition-transform hover:scale-110 flex items-center justify-center"
                      :style="{ backgroundColor: color.colorCode }"
                      :class="builderColor === color.value ? 'border-txt-primary' : 'border-transparent'"
                      @click="builderColor = color.value"
                    >
                      <svg v-if="builderColor === color.value" class="size-3.5 text-white" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="3">
                        <path stroke-linecap="round" stroke-linejoin="round" d="M5 13l4 4L19 7" />
                      </svg>
                    </button>
                  </div>
                </div>

                <!-- Font Selection -->
                <div class="space-y-2">
                  <label class="text-xs font-bold text-txt-secondary">Typography</label>
                  <div class="grid grid-cols-3 gap-1 bg-slate-100 dark:bg-slate-800 p-1 rounded-lg">
                    <button 
                      v-for="font in typographyFonts" 
                      :key="font.value"
                      type="button"
                      class="py-1 rounded text-[10px] font-bold transition-all"
                      :class="builderFont === font.value ? 'bg-white dark:bg-slate-900 text-brand shadow-xs' : 'text-txt-secondary hover:text-txt-primary'"
                      @click="builderFont = font.value"
                    >
                      {{ font.label }}
                    </button>
                  </div>
                </div>

                <!-- Section Toggles -->
                <div class="space-y-3 pt-2 border-t border-border/40">
                  <label class="text-xs font-bold text-txt-secondary">Section Visibility</label>
                  
                  <div class="flex items-center justify-between text-xs font-medium text-txt-primary">
                    <span>Education Section</span>
                    <button 
                      type="button"
                      class="relative inline-flex h-5 w-9 shrink-0 cursor-pointer rounded-full border-2 border-transparent transition-colors duration-200 ease-in-out focus:outline-none"
                      :class="builderShowEducation ? 'bg-brand' : 'bg-slate-200 dark:bg-slate-700'"
                      @click="builderShowEducation = !builderShowEducation"
                    >
                      <span 
                        class="pointer-events-none inline-block size-4 transform rounded-full bg-white shadow-sm ring-0 transition duration-200 ease-in-out"
                        :class="builderShowEducation ? 'translate-x-4' : 'translate-x-0'"
                      />
                    </button>
                  </div>

                  <div class="flex items-center justify-between text-xs font-medium text-txt-primary">
                    <span>Projects Section</span>
                    <button 
                      type="button"
                      class="relative inline-flex h-5 w-9 shrink-0 cursor-pointer rounded-full border-2 border-transparent transition-colors duration-200 ease-in-out focus:outline-none"
                      :class="builderShowProjects ? 'bg-brand' : 'bg-slate-200 dark:bg-slate-700'"
                      @click="builderShowProjects = !builderShowProjects"
                    >
                      <span 
                        class="pointer-events-none inline-block size-4 transform rounded-full bg-white shadow-sm ring-0 transition duration-200 ease-in-out"
                        :class="builderShowProjects ? 'translate-x-4' : 'translate-x-0'"
                      />
                    </button>
                  </div>

                  <div class="flex items-center justify-between text-xs font-medium text-txt-primary">
                    <span>Skills List</span>
                    <button 
                      type="button"
                      class="relative inline-flex h-5 w-9 shrink-0 cursor-pointer rounded-full border-2 border-transparent transition-colors duration-200 ease-in-out focus:outline-none"
                      :class="builderShowSkills ? 'bg-brand' : 'bg-slate-200 dark:bg-slate-700'"
                      @click="builderShowSkills = !builderShowSkills"
                    >
                      <span 
                        class="pointer-events-none inline-block size-4 transform rounded-full bg-white shadow-sm ring-0 transition duration-200 ease-in-out"
                        :class="builderShowSkills ? 'translate-x-4' : 'translate-x-0'"
                      />
                    </button>
                  </div>
                </div>
              </div>

              <!-- Interactive Live Preview Mockup -->
              <div class="border border-border/80 rounded-2xl p-6 sm:p-8 bg-white shadow-inner flex flex-col justify-between select-none relative max-w-xl mx-auto w-full min-h-[360px]" :class="builderFont">
                
                <!-- Resume Header -->
                <div>
                  <div class="flex items-center justify-between">
                    <h5 class="text-xl font-bold tracking-tight text-slate-800 transition-colors duration-300" :style="{ color: activeColorCode }">
                      Aniket Yadav
                    </h5>
                    <span class="text-[10px] text-slate-400 font-mono">LIVE PREVIEW</span>
                  </div>
                  <p class="text-xs text-slate-500 font-medium mt-0.5">Frontend Developer • Bengaluru, IN • aniket@github.io</p>
                  <div class="h-1.5 w-full rounded-full bg-slate-100 mt-3 overflow-hidden">
                    <div class="h-full transition-all duration-300" :style="{ width: '100%', backgroundColor: activeColorCode }" />
                  </div>
                </div>

                <!-- Professional Summary -->
                <div class="mt-4">
                  <h6 class="text-[11px] font-bold uppercase tracking-wider transition-colors duration-300" :style="{ color: activeColorCode }">
                    Professional Summary
                  </h6>
                  <p class="text-[11px] leading-relaxed text-slate-600 mt-1">
                    Focused frontend developer with experience building interactive web features, modern animations, and responsive dashboard applications using modern Javascript libraries.
                  </p>
                </div>

                <!-- Toggleable Education -->
                <Transition 
                  enter-active-class="transition duration-200 ease-out" 
                  enter-from-class="opacity-0 -translate-y-2" 
                  enter-to-class="opacity-100 translate-y-0"
                  leave-active-class="transition duration-150 ease-in"
                  leave-from-class="opacity-100 translate-y-0"
                  leave-to-class="opacity-0 -translate-y-2"
                >
                  <div v-if="builderShowEducation" class="mt-4">
                    <h6 class="text-[11px] font-bold uppercase tracking-wider transition-colors duration-300" :style="{ color: activeColorCode }">
                      Education
                    </h6>
                    <div class="flex justify-between items-start mt-1">
                      <div>
                        <p class="text-[11px] font-bold text-slate-800">Bachelor of Technology in CS</p>
                        <p class="text-[10px] text-slate-500">Universal Technical University</p>
                      </div>
                      <span class="text-[10px] text-slate-500 font-medium">2020 – 2024</span>
                    </div>
                  </div>
                </Transition>

                <!-- Toggleable Projects -->
                <Transition 
                  enter-active-class="transition duration-200 ease-out" 
                  enter-from-class="opacity-0 -translate-y-2" 
                  enter-to-class="opacity-100 translate-y-0"
                  leave-active-class="transition duration-150 ease-in"
                  leave-from-class="opacity-100 translate-y-0"
                  leave-to-class="opacity-0 -translate-y-2"
                >
                  <div v-if="builderShowProjects" class="mt-4">
                    <h6 class="text-[11px] font-bold uppercase tracking-wider transition-colors duration-300" :style="{ color: activeColorCode }">
                      Key Projects
                    </h6>
                    <div class="mt-1">
                      <p class="text-[11px] font-bold text-slate-800">CareerAI Portfolio Platform</p>
                      <p class="text-[10px] leading-relaxed text-slate-500">Built automated resume builder with live layout engines.</p>
                    </div>
                  </div>
                </Transition>

                <!-- Toggleable Skills -->
                <Transition 
                  enter-active-class="transition duration-200 ease-out" 
                  enter-from-class="opacity-0 -translate-y-2" 
                  enter-to-class="opacity-100 translate-y-0"
                  leave-active-class="transition duration-150 ease-in"
                  leave-from-class="opacity-100 translate-y-0"
                  leave-to-class="opacity-0 -translate-y-2"
                >
                  <div v-if="builderShowSkills" class="mt-4">
                    <h6 class="text-[11px] font-bold uppercase tracking-wider transition-colors duration-300" :style="{ color: activeColorCode }">
                      Skills
                    </h6>
                    <div class="flex flex-wrap gap-1.5 mt-1.5">
                      <span 
                        v-for="skill in ['Vue.js', 'Vite', 'TailwindCSS', 'JavaScript', 'REST APIs']" 
                        :key="skill"
                        class="text-[9px] font-bold px-2 py-0.5 rounded transition-all"
                        :style="{ backgroundColor: activeColorBg, color: activeColorCode }"
                      >
                        {{ skill }}
                      </span>
                    </div>
                  </div>
                </Transition>
              </div>
            </div>

            <!-- 2. AI ATS SCANNER INTERACTIVE DEMO -->
            <div v-else-if="activeFeatureTab === 'ai'" class="mx-auto max-w-xl text-center py-6">
              <div class="relative size-24 mx-auto mb-6 flex items-center justify-center">
                <!-- Circular pulse effect -->
                <span class="absolute inset-0 rounded-full bg-brand/10 transition-transform duration-1000 scale-100" :class="{ 'animate-ping': atsScanning }" />
                <div class="relative size-20 rounded-full border border-border bg-slate-50 dark:bg-slate-800 grid place-items-center shadow-md">
                  <svg class="size-8 text-brand" :class="{ 'animate-bounce': atsScanning }" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="1.75">
                    <path stroke-linecap="round" stroke-linejoin="round" d="M9 12.75L11.25 15 15 9.75m-3-7.036A11.959 11.959 0 013.598 6 11.99 11.99 0 003 9.749c0 5.592 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.31-.21-2.57-.598-3.751h-.152c-3.196 0-6.1-1.248-8.25-3.285z" />
                  </svg>
                </div>
              </div>

              <h4 class="text-lg font-extrabold text-txt-primary">AI-Powered ATS Match Checker</h4>
              <p class="mt-2 text-sm text-txt-secondary leading-relaxed max-w-sm mx-auto">
                Scan your resume against job keywords. Optimize structure, verify formatting, and secure recruitment passes.
              </p>

              <!-- Progress bar simulator -->
              <div v-if="atsScanning" class="mt-8 max-w-xs mx-auto space-y-2">
                <div class="h-2 w-full rounded-full bg-slate-100 dark:bg-slate-800 overflow-hidden">
                  <div class="h-full bg-brand transition-all duration-75" :style="{ width: `${atsProgress}%` }" />
                </div>
                <div class="flex items-center justify-between text-xs text-txt-muted font-mono">
                  <span>Parsing sections...</span>
                  <span>{{ atsProgress }}%</span>
                </div>
              </div>

              <!-- Scanner Results -->
              <div v-else-if="atsScore !== null" class="mt-8 p-5 rounded-2xl border border-emerald-500/20 bg-emerald-500/5 max-w-sm mx-auto transition-all animate-fade-in">
                <div class="flex items-center justify-between">
                  <span class="text-sm font-bold text-emerald-800 dark:text-emerald-300">Scan Complete</span>
                  <span class="text-xs font-mono font-extrabold text-emerald-500">SCORE: {{ atsScore }}%</span>
                </div>
                
                <div class="mt-3.5 space-y-2 text-left text-xs font-medium text-emerald-900/80 dark:text-emerald-300/80">
                  <div class="flex items-center gap-2">
                    <span class="size-1.5 rounded-full bg-emerald-500" />
                    <span>Keyword Density: Strong</span>
                  </div>
                  <div class="flex items-center gap-2">
                    <span class="size-1.5 rounded-full bg-emerald-500" />
                    <span>Formatting Validation: Passed</span>
                  </div>
                  <div class="flex items-center gap-2">
                    <span class="size-1.5 rounded-full bg-emerald-500" />
                    <span>Action Verbs optimization: +18%</span>
                  </div>
                </div>
              </div>

              <!-- Action button -->
              <div class="mt-8">
                <button 
                  type="button" 
                  class="rounded-xl bg-brand px-6 py-3 text-sm font-bold text-white shadow-md shadow-brand/20 hover:bg-brand/90 transition-all"
                  :disabled="atsScanning"
                  @click="runAtsScanner"
                >
                  {{ atsScanning ? 'Scanning...' : 'Scan Sample Resume' }}
                </button>
              </div>
            </div>

            <!-- 3. INTERVIEW PREP INTERACTIVE DEMO -->
            <div v-else-if="activeFeatureTab === 'interview'" class="grid grid-cols-1 lg:grid-cols-[300px_1fr] gap-8">
              <!-- Question selection list -->
              <div class="space-y-2.5">
                <h4 class="text-xs font-extrabold text-txt-primary uppercase tracking-wide border-b border-border pb-2">Select Interview Question</h4>
                <div class="space-y-1.5">
                  <button 
                    v-for="(q, index) in mockQuestions"
                    :key="index"
                    type="button"
                    class="w-full text-left p-3 rounded-xl border text-xs font-bold transition-all"
                    :class="selectedQuestion === index ? 'bg-brand/5 border-brand/40 text-brand shadow-xs' : 'bg-slate-50 dark:bg-slate-800/40 border-border/60 text-txt-secondary hover:bg-slate-100'"
                    @click="changeQuestion(index)"
                  >
                    {{ q.title }}
                  </button>
                </div>
              </div>

              <!-- Question details and feedback area -->
              <div class="border border-border/60 rounded-2xl p-5 bg-slate-50/50 dark:bg-slate-800/10 flex flex-col justify-between min-h-[300px]">
                <div>
                  <div class="flex items-center justify-between border-b border-border pb-3">
                    <span class="text-xs font-extrabold uppercase tracking-wider text-txt-muted">AI Interview Mockup</span>
                    <span class="inline-flex items-center gap-1 text-[10px] font-bold text-brand bg-brand/10 px-2 py-0.5 rounded-full">
                      Difficulty: {{ mockQuestions[selectedQuestion].difficulty }}
                    </span>
                  </div>

                  <p class="mt-4 text-xs font-bold text-slate-800 dark:text-slate-200">
                    Q: {{ mockQuestions[selectedQuestion].question }}
                  </p>

                  <div class="mt-3">
                    <label class="text-[10px] font-extrabold text-txt-muted uppercase">Your Answer</label>
                    <textarea 
                      v-model="mockQuestions[selectedQuestion].userAnswer" 
                      rows="3" 
                      class="mt-1 w-full rounded-xl border border-border p-3 text-xs bg-white text-txt-primary focus:outline-none focus:border-brand"
                      placeholder="Write your explanation..."
                    />
                  </div>
                </div>

                <!-- Simulation results -->
                <div v-if="interviewAILoading" class="mt-4 flex items-center justify-center gap-2 text-xs text-txt-muted py-2 font-medium">
                  <svg class="size-4 animate-spin text-brand" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                    <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                    <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4z"></path>
                  </svg>
                  <span>AI generating assessment report...</span>
                </div>

                <div v-else-if="mockQuestions[selectedQuestion].aiFeedback" class="mt-4 p-4 rounded-xl bg-slate-900 text-slate-100 border border-slate-800 animate-fade-in">
                  <div class="flex items-center justify-between border-b border-slate-800 pb-2">
                    <span class="text-xs font-bold text-slate-400">AI FeedBack Report</span>
                    <span class="text-xs font-bold font-mono text-emerald-400">SCORE: {{ mockQuestions[selectedQuestion].aiScore }}/100</span>
                  </div>
                  <p class="text-[11px] text-slate-300 leading-relaxed mt-2.5">
                    {{ mockQuestions[selectedQuestion].aiFeedback }}
                  </p>
                </div>

                <div class="mt-4 flex justify-end">
                  <button 
                    type="button" 
                    class="rounded-xl bg-slate-900 text-white px-5 py-2.5 text-xs font-bold transition-all hover:bg-slate-800 shadow-sm"
                    :disabled="interviewAILoading"
                    @click="runInterviewAI"
                  >
                    Get AI Feedback
                  </button>
                </div>
              </div>
            </div>

            <!-- 4. PROFILE AUTO-FILL INTERACTIVE DEMO -->
            <div v-else-if="activeFeatureTab === 'sync'" class="mx-auto max-w-2xl py-4">
              <div class="grid grid-cols-1 md:grid-cols-[1fr_50px_1fr] gap-4 items-center">
                
                <!-- Left side: Centralized Profile Card -->
                <div class="border border-border/80 rounded-2xl p-5 bg-white shadow-sm flex flex-col justify-between min-h-[220px]">
                  <div>
                    <h5 class="text-xs font-extrabold uppercase tracking-wide text-brand border-b border-border pb-1.5">Profile Hub</h5>
                    <div class="mt-3.5 space-y-2">
                      <div>
                        <label class="text-[9px] font-bold text-slate-400 block">FULL NAME</label>
                        <p class="text-xs font-bold text-slate-800">Ajit Aniket</p>
                      </div>
                      <div>
                        <label class="text-[9px] font-bold text-slate-400 block">KEY TECHNOLOGIES</label>
                        <p class="text-xs font-medium text-slate-700">Vue.js, Rails, PostgreSQL</p>
                      </div>
                      <div>
                        <label class="text-[9px] font-bold text-slate-400 block">LATEST EXPERIENCE</label>
                        <p class="text-xs font-medium text-slate-700">Senior Engineer @ Infinvo</p>
                      </div>
                    </div>
                  </div>
                  <span class="text-[9px] font-mono text-emerald-500 font-bold bg-emerald-500/10 px-2 py-0.5 rounded-md self-start">Source of Truth</span>
                </div>

                <!-- Sync Animation Arrow -->
                <div class="flex md:flex-col justify-center items-center gap-1.5 py-2">
                  <svg 
                    class="size-6 text-brand"
                    :class="{ 'animate-spin': syncActive }"
                    fill="none" 
                    viewBox="0 0 24 24" 
                    stroke="currentColor" 
                    stroke-width="2.5"
                  >
                    <path stroke-linecap="round" stroke-linejoin="round" d="M19.5 12c0-1.232-.046-2.453-.138-3.662a4.006 4.006 0 00-3.7-3.7 48.656 48.656 0 00-7.324 0 4.006 4.006 0 00-3.7 3.7c-.017.22-.032.441-.046.662M19.5 12l3-3m-3 3l-3-3m-12 3c0 1.232.046 2.453.138 3.662a4.006 4.006 0 003.7 3.7 48.656 48.656 0 007.324 0 4.006 4.006 0 003.7-3.7c.017-.22.032-.441.046-.662M4.5 12l3 3m-3-3l-3 3" />
                  </svg>
                  <span class="text-[9px] font-bold text-txt-muted uppercase font-mono tracking-wider hidden md:block">Sync</span>
                </div>

                <!-- Right side: Target Resume -->
                <div class="border border-border/80 rounded-2xl p-5 bg-white shadow-sm flex flex-col justify-between min-h-[220px]">
                  <div>
                    <h5 class="text-xs font-extrabold uppercase tracking-wide text-slate-800 border-b border-border pb-1.5">Target Resume</h5>
                    <div class="mt-3.5 space-y-2">
                      <div>
                        <label class="text-[9px] font-bold text-slate-400 block">FULL NAME</label>
                        <p class="text-xs font-bold" :class="syncActive ? 'text-brand scale-105 duration-200' : 'text-slate-300'">
                          {{ syncActive ? 'Ajit Aniket' : '— Empty —' }}
                        </p>
                      </div>
                      <div>
                        <label class="text-[9px] font-bold text-slate-400 block">KEY TECHNOLOGIES</label>
                        <p class="text-xs font-medium" :class="syncActive ? 'text-slate-700 scale-105 duration-200' : 'text-slate-300'">
                          {{ syncActive ? 'Vue.js, Rails, PostgreSQL' : '— Empty —' }}
                        </p>
                      </div>
                      <div>
                        <label class="text-[9px] font-bold text-slate-400 block">LATEST EXPERIENCE</label>
                        <p class="text-xs font-medium" :class="syncActive ? 'text-slate-700 scale-105 duration-200' : 'text-slate-300'">
                          {{ syncActive ? 'Senior Engineer @ Infinvo' : '— Empty —' }}
                        </p>
                      </div>
                    </div>
                  </div>
                  <span 
                    class="text-[9px] font-bold px-2 py-0.5 rounded-md self-start"
                    :class="syncActive ? 'text-emerald-500 bg-emerald-500/10 font-bold' : 'text-slate-400 bg-slate-100'"
                  >
                    {{ syncActive ? 'Synced' : 'Not Synced' }}
                  </span>
                </div>

              </div>

              <!-- Control buttons -->
              <div class="mt-8 flex justify-center gap-3">
                <button 
                  type="button" 
                  class="rounded-xl border border-border px-5 py-2.5 text-xs font-bold text-txt-secondary hover:bg-slate-50 transition-all"
                  @click="syncActive = false"
                >
                  Reset
                </button>
                <button 
                  type="button" 
                  class="rounded-xl bg-brand px-5 py-2.5 text-xs font-bold text-white shadow-md shadow-brand/20 hover:bg-brand/90 transition-all"
                  @click="runAutofillSync"
                >
                  Auto-fill Resume
                </button>
              </div>
            </div>

          </div>

          <!-- ADVANCED PLATFORM CAPABILITIES GRID -->
          <div class="space-y-8 pt-10">
            <div class="text-center max-w-2xl mx-auto">
              <h3 class="text-2xl font-extrabold text-txt-primary">Complete Feature Set</h3>
              <p class="mt-2 text-sm text-txt-secondary">Every tool is built from the ground up to accelerate your application cycles.</p>
            </div>

            <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
              <div 
                v-for="(feat, index) in advancedFeatures" 
                :key="index"
                class="rounded-3xl border border-border bg-surface p-6 shadow-sm flex flex-col justify-between transition-all duration-300 hover:-translate-y-1 hover:shadow-md hover:border-brand/20"
              >
                <div>
                  <div class="mb-4 grid size-11 place-items-center rounded-xl bg-brand/10 text-brand">
                    <component :is="feat.icon" class="size-5" />
                  </div>
                  <h4 class="text-sm font-extrabold text-txt-primary">{{ feat.title }}</h4>
                  <p class="mt-2 text-xs leading-relaxed text-txt-secondary">{{ feat.description }}</p>
                </div>
                
                <div class="mt-5 border-t border-border/40 pt-3.5 flex items-center justify-between">
                  <span class="text-[10px] font-extrabold uppercase tracking-wide text-brand/80">{{ feat.badge }}</span>
                  <span class="text-[10px] font-bold text-txt-muted">{{ feat.status }}</span>
                </div>
              </div>
            </div>
          </div>

          <!-- Bottom CTA -->
          <div class="rounded-3xl border border-brand/20 bg-brand/5 p-8 text-center sm:p-10">
            <h3 class="text-lg font-bold text-txt-primary">Get complete access to the features workspace</h3>
            <p class="mt-2 text-sm text-txt-secondary">Create a free account and start compiling professional resume drafts in minutes.</p>
            <button 
              type="button"
              class="mt-5 inline-flex rounded-xl bg-brand px-6 py-2.5 text-sm font-bold text-white shadow-md shadow-brand/10 transition-all hover:bg-brand/90"
              @click="handleCtaClick('/signup')"
            >
              Create free account
            </button>
          </div>

        </div>

        <!-- FAQ Accordion Layout -->
        <div v-else-if="pageKey === 'faq'" class="mx-auto max-w-3xl space-y-6">
          
          <!-- Interactive Search & Filtering Header -->
          <div class="rounded-3xl border border-border bg-surface p-6 sm:p-8 shadow-sm relative overflow-hidden">
            <div class="absolute inset-0 opacity-[0.02] bg-[radial-gradient(circle_at_top_right,rgba(109,74,255,0.25),transparent)] pointer-events-none" />
            <div class="relative z-10 text-center space-y-4">
              <!-- Search Box -->
              <div class="relative max-w-lg mx-auto">
                <input 
                  type="text" 
                  v-model="faqSearchQuery" 
                  placeholder="Search FAQ keywords..." 
                  class="w-full rounded-2xl border border-border bg-white dark:bg-slate-900 pl-11 pr-4 py-3.5 text-sm text-txt-primary focus:outline-none focus:border-brand focus:ring-2 focus:ring-brand/10 transition-all shadow-sm"
                />
                <!-- Search Icon -->
                <svg class="size-5 text-txt-muted absolute left-4 top-1/2 -translate-y-1/2 pointer-events-none" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                  <path stroke-linecap="round" stroke-linejoin="round" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
                </svg>
                <!-- Clear Button -->
                <button 
                  v-if="faqSearchQuery" 
                  type="button" 
                  @click="faqSearchQuery = ''" 
                  class="absolute right-4 top-1/2 -translate-y-1/2 text-txt-muted hover:text-txt-primary text-xs font-bold transition-all"
                >
                  Clear
                </button>
              </div>

              <!-- Quick Links Category Tabs -->
              <div class="flex flex-wrap items-center justify-center gap-1.5 pt-1">
                <button 
                  v-for="cat in faqCategories" 
                  :key="cat"
                  type="button"
                  class="px-3.5 py-1.5 rounded-xl text-xs font-bold transition-all border"
                  :class="faqSelectedCategory === cat ? 'bg-brand border-brand text-white shadow-sm shadow-brand/10' : 'bg-white dark:bg-slate-900 border-border text-txt-secondary hover:text-txt-primary hover:bg-slate-50'"
                  @click="faqSelectedCategory = cat"
                >
                  {{ cat }}
                </button>
              </div>
            </div>
          </div>

          <!-- Empty State -->
          <div v-if="filteredFaqs.length === 0" class="rounded-3xl border border-dashed border-border p-12 text-center bg-surface">
            <div class="mx-auto mb-4 grid size-12 place-items-center rounded-xl bg-slate-100 text-slate-400">
              <svg class="size-6" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                <path stroke-linecap="round" stroke-linejoin="round" d="M9.172 16.172a4 4 0 015.656 0M9 10h.01M15 10h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
              </svg>
            </div>
            <h3 class="text-sm font-bold text-txt-primary">No FAQs found</h3>
            <p class="text-xs text-txt-secondary mt-1">Try refining your search keyword or selecting a different category tab.</p>
          </div>

          <!-- Accordion Cards -->
          <div v-else class="space-y-4">
            <div 
              v-for="faq in filteredFaqs" 
              :key="faq.index"
              class="rounded-2xl border border-border/80 bg-surface shadow-sm overflow-hidden transition-all hover:border-brand/25"
            >
              <button 
                type="button"
                class="w-full flex items-center justify-between p-5 text-left font-bold text-txt-primary transition hover:bg-slate-50/50"
                @click="toggleFaq(faq.index)"
              >
                <div class="flex flex-col gap-1.5 pr-4">
                  <span class="text-txt-primary text-sm font-extrabold text-left">{{ faq.heading }}</span>
                  <span class="text-[9px] font-bold text-brand uppercase tracking-wider bg-brand/5 px-2 py-0.5 rounded-md self-start">
                    {{ faq.category }}
                  </span>
                </div>
                <svg 
                  class="size-5 shrink-0 text-txt-muted transition-transform duration-200"
                  :class="{ 'rotate-180 text-brand': openFaqs.includes(faq.index) }"
                  fill="none" 
                  viewBox="0 0 24 24" 
                  stroke="currentColor" 
                  stroke-width="2"
                >
                  <path stroke-linecap="round" stroke-linejoin="round" d="M19 9l-7 7-7-7" />
                </svg>
              </button>
              
              <Transition
                enter-active-class="transition-all duration-200 ease-out"
                enter-from-class="max-h-0 opacity-0"
                enter-to-class="max-h-[500px] opacity-100"
                leave-active-class="transition-all duration-150 ease-in"
                leave-from-class="max-h-[500px] opacity-100"
                leave-to-class="max-h-0 opacity-0"
              >
                <div v-if="openFaqs.includes(faq.index)" class="border-t border-border/60 bg-slate-50/20 px-5 py-4">
                  <p class="text-sm leading-7 text-txt-secondary">{{ faq.body }}</p>
                </div>
              </Transition>
            </div>
          </div>
          
          <!-- CTA -->
          <div v-if="page.cta" class="mt-12 rounded-3xl border border-brand/20 bg-brand/5 p-8 text-center sm:p-10">
            <h3 class="text-lg font-bold text-txt-primary">{{ page.cta.title }}</h3>
            <p v-if="page.cta.body" class="mt-2 text-sm text-txt-secondary">{{ page.cta.body }}</p>
            <button 
              type="button"
              class="mt-5 inline-flex rounded-xl bg-brand px-6 py-2.5 text-sm font-bold text-white shadow-md shadow-brand/10 transition-all hover:bg-brand/90"
              @click="handleCtaClick(page.cta.to)"
            >
              {{ page.cta.label }}
            </button>
          </div>
        </div>


        <!-- System Status Health Layout -->
        <div v-else-if="pageKey === 'status'" class="mx-auto max-w-3xl space-y-8">
          <!-- Pulse Health Banner -->
          <div class="rounded-2xl border border-emerald-500/20 bg-emerald-500/5 p-6 flex items-center gap-4 shadow-sm">
            <span class="relative flex size-3">
              <span class="animate-ping absolute inline-flex h-full w-full rounded-full bg-emerald-400 opacity-75"></span>
              <span class="relative inline-flex rounded-full size-3 bg-emerald-500"></span>
            </span>
            <div>
              <h3 class="font-bold text-emerald-800 dark:text-emerald-300">All Systems Operational</h3>
              <p class="text-xs text-emerald-600 dark:text-emerald-400/80 mt-0.5">As of today, we are experiencing no outages.</p>
            </div>
          </div>
          
          <!-- Sections Grid -->
          <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div 
              v-for="(section, index) in page.sections" 
              :key="index"
              class="rounded-3xl border border-border/80 bg-surface p-6 sm:p-8 shadow-sm flex flex-col justify-between transition-all hover:border-brand/25"
            >
              <div>
                <h3 class="text-lg font-bold text-txt-primary flex items-center gap-2">
                  <span class="size-2 rounded-full bg-brand" />
                  {{ section.heading }}
                </h3>
                <p v-if="section.body" class="mt-4 text-sm leading-7 text-txt-secondary">{{ section.body }}</p>
                
                <ul v-if="section.items?.length" class="mt-5 space-y-3.5">
                  <li v-for="(item, i) in section.items" :key="i" class="flex items-center justify-between text-sm text-txt-secondary bg-slate-50/50 rounded-xl p-3 border border-border/40">
                    <span class="font-medium">{{ item.split(' — ')[0] }}</span>
                    <span class="inline-flex items-center gap-1 text-xs font-bold text-emerald-500 bg-emerald-500/10 px-2.5 py-1 rounded-full">
                      <span class="size-1.5 rounded-full bg-emerald-500 animate-pulse" />
                      {{ item.split(' — ')[1] || 'Operational' }}
                    </span>
                  </li>
                </ul>
              </div>

              <!-- Report issue action for Incident History -->
              <div v-if="section.heading === 'Incident history'" class="mt-6 pt-4 border-t border-border/40">
                <RouterLink 
                  to="/support" 
                  class="inline-flex items-center gap-2 rounded-xl bg-slate-900 hover:bg-slate-800 text-white px-4 py-2.5 text-xs font-bold transition-all shadow-sm"
                >
                  <span>Report an Issue</span>
                  <svg class="size-3.5" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                    <path stroke-linecap="round" stroke-linejoin="round" d="M14 5l7 7m0 0l-7 7m7-7H3" />
                  </svg>
                </RouterLink>
              </div>
            </div>
          </div>
        </div>

        <!-- Legal/Document Table-of-Contents Sidebar Layout -->
        <div v-else-if="['privacy', 'terms', 'cookies', 'refund', 'shipping'].includes(pageKey)" class="space-y-6">
          
          <!-- Legal Document Interactive Search Header -->
          <div class="rounded-3xl border border-border bg-surface p-5 shadow-sm relative overflow-hidden">
            <div class="absolute inset-0 opacity-[0.01] bg-[radial-gradient(circle_at_top_right,rgba(109,74,255,0.25),transparent)] pointer-events-none" />
            <div class="relative z-10 flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
              <div>
                <h4 class="text-sm font-extrabold text-txt-primary">Search policy contents</h4>
                <p class="text-[10px] text-txt-secondary mt-0.5">Quickly find specific terms, clauses, or declarations.</p>
              </div>
              <div class="relative w-full sm:max-w-xs">
                <input 
                  type="text" 
                  v-model="legalSearchQuery" 
                  placeholder="Type to search (e.g. data)..." 
                  class="w-full rounded-xl border border-border bg-white dark:bg-slate-900 pl-9 pr-8 py-2 text-xs text-txt-primary focus:outline-none focus:border-brand focus:ring-2 focus:ring-brand/10 transition-all shadow-sm"
                />
                <svg class="size-4 text-txt-muted absolute left-3 top-1/2 -translate-y-1/2 pointer-events-none" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                  <path stroke-linecap="round" stroke-linejoin="round" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
                </svg>
                <button 
                  v-if="legalSearchQuery" 
                  type="button" 
                  @click="legalSearchQuery = ''" 
                  class="absolute right-3 top-1/2 -translate-y-1/2 text-txt-muted hover:text-txt-primary text-[10px] font-bold"
                >
                  Clear
                </button>
              </div>
            </div>
          </div>

          <div class="lg:grid lg:grid-cols-[260px_1fr] lg:gap-12 items-start">
            <!-- Sidebar Navigation -->
            <aside class="hidden lg:block sticky top-28 bg-surface border border-border/80 rounded-3xl p-5 shadow-sm">
              <p class="text-xs font-bold uppercase tracking-wider text-txt-muted mb-4 px-2">On this page</p>
              <ul class="space-y-1">
                <li v-for="section in filteredLegalSections" :key="section.originalIndex">
                  <a 
                    :href="`#sec-${section.originalIndex}`"
                    class="block text-sm py-2 px-3 rounded-xl transition-all"
                    :class="activeSectionIndex === section.originalIndex ? 'bg-brand/5 text-brand font-bold' : 'text-txt-secondary hover:bg-slate-50 hover:text-txt-primary'"
                    @click="activeSectionIndex = section.originalIndex"
                  >
                    {{ section.heading }}
                  </a>
                </li>
              </ul>
            </aside>

            <!-- Main Document Content -->
            <div class="space-y-10">
              <!-- Empty Search State -->
              <div v-if="filteredLegalSections.length === 0" class="rounded-3xl border border-dashed border-border p-12 text-center bg-surface">
                <div class="mx-auto mb-4 grid size-12 place-items-center rounded-xl bg-slate-100 text-slate-400">
                  <svg class="size-6" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                    <path stroke-linecap="round" stroke-linejoin="round" d="M9.172 16.172a4 4 0 015.656 0M9 10h.01M15 10h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
                  </svg>
                </div>
                <h3 class="text-sm font-bold text-txt-primary">No sections matched your search</h3>
                <p class="text-xs text-txt-secondary mt-1">Try searching for other keywords like "data", "use", or "cookies".</p>
              </div>

              <div 
                v-else
                v-for="section in filteredLegalSections" 
                :key="section.originalIndex"
                :id="`sec-${section.originalIndex}`"
                class="scroll-mt-28 rounded-3xl border border-border/60 bg-surface p-6 sm:p-8 shadow-sm transition-all hover:shadow-md"
              >
                <h2 class="text-xl font-bold text-txt-primary flex items-center gap-2.5">
                  <span class="grid size-7 place-items-center rounded-lg bg-brand/10 text-brand text-xs font-bold">{{ section.originalIndex + 1 }}</span>
                  {{ section.heading }}
                </h2>
                <p v-if="section.body" class="mt-4 text-sm leading-7 text-txt-secondary">{{ section.body }}</p>
                
                <ul v-if="section.items?.length" class="mt-5 space-y-3">
                  <li v-for="(item, i) in section.items" :key="i" class="flex gap-3 text-sm text-txt-secondary leading-6">
                    <svg class="size-4 text-brand shrink-0 mt-1" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2.5">
                      <path stroke-linecap="round" stroke-linejoin="round" d="M9 12l2 2 4-4" />
                    </svg>
                    <span>{{ item }}</span>
                  </li>
                </ul>
              </div>
            </div>
          </div>
        </div>

        <!-- INTERACTIVE ABOUT PAGE SHOWCASE -->
        <div v-else-if="pageKey === 'about'" class="space-y-20">
          
          <!-- 1. The Story Timeline -->
          <div class="space-y-10">
            <div class="text-center max-w-2xl mx-auto">
              <span class="text-xs font-extrabold uppercase tracking-wider text-brand bg-brand/5 px-3 py-1 rounded-full">Our Story</span>
              <h2 class="mt-3 text-3xl font-extrabold text-txt-primary">How CareerAI Was Formed</h2>
              <p class="mt-2 text-sm text-txt-secondary">Follow our journey from a simple idea to a modern career ecosystem.</p>
            </div>

            <!-- Timeline Navigation Buttons -->
            <div class="relative max-w-2xl mx-auto px-4">
              <!-- Connector line -->
              <div class="absolute top-1/2 left-0 right-0 h-0.5 bg-slate-200 dark:bg-slate-800 -translate-y-1/2 z-0 hidden md:block" />
              
              <div class="relative z-10 grid grid-cols-2 gap-4 md:gap-8">
                <button 
                  v-for="ms in milestones" 
                  :key="ms.key"
                  type="button"
                  class="flex flex-col items-center p-4 rounded-2xl border text-center transition-all bg-surface"
                  :class="selectedMilestone === ms.key ? 'border-brand ring-2 ring-brand/20 shadow-md translate-y-[-2px]' : 'border-border hover:border-slate-300 dark:hover:border-slate-700'"
                  @click="selectedMilestone = ms.key"
                >
                  <span class="text-xl font-black text-brand tracking-tight">{{ ms.year }}</span>
                  <span class="text-xs font-extrabold text-txt-primary mt-1">{{ ms.title }}</span>
                  <span class="text-[10px] text-txt-muted uppercase tracking-wider mt-0.5">{{ ms.tag }}</span>
                </button>
              </div>
            </div>

            <!-- Milestone details card -->
            <div class="max-w-4xl mx-auto rounded-3xl border border-border/80 bg-surface p-6 sm:p-8 md:p-10 shadow-lg relative overflow-hidden transition-all duration-300">
              <div class="absolute inset-0 opacity-[0.03] dark:opacity-[0.05] bg-[radial-gradient(ellipse_60%_60%_at_50%_120%,rgba(109,74,255,0.4),rgba(255,255,255,0))]" />
              
              <div class="relative z-10 grid grid-cols-1 lg:grid-cols-[1fr_320px] gap-8 items-center">
                <!-- Milestone description -->
                <div class="space-y-4">
                  <div class="flex items-center gap-2">
                    <span class="text-xs font-bold text-brand bg-brand/10 px-2.5 py-1 rounded-md">
                      {{ milestones.find(m => m.key === selectedMilestone).year }}
                    </span>
                    <span class="text-xs font-bold text-txt-muted uppercase tracking-wide">
                      {{ milestones.find(m => m.key === selectedMilestone).tag }}
                    </span>
                  </div>
                  <h3 class="text-2xl font-extrabold text-txt-primary">
                    {{ milestones.find(m => m.key === selectedMilestone).title }}
                  </h3>
                  <p class="text-sm leading-7 text-txt-secondary">
                    {{ milestones.find(m => m.key === selectedMilestone).desc }}
                  </p>
                </div>

                <!-- Milestone statistics (Glassmorphic cards) -->
                <div class="space-y-3 bg-slate-50/50 dark:bg-slate-800/20 border border-border/60 rounded-2xl p-5">
                  <h4 class="text-xs font-extrabold text-txt-primary uppercase tracking-wider border-b border-border pb-2">Milestone Stats</h4>
                  <div class="space-y-3">
                    <div 
                      v-for="(stat, idx) in milestoneStats" 
                      :key="idx" 
                      class="flex items-center justify-between text-xs"
                    >
                      <span class="font-medium text-txt-secondary">{{ stat.label }}</span>
                      <span class="font-extrabold text-brand font-mono text-sm bg-brand/5 px-2 py-0.5 rounded-md">
                        {{ stat.val }}
                      </span>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>

          <!-- 2. Core Beliefs / Values Showcase -->
          <div class="space-y-10 pt-8">
            <div class="text-center max-w-2xl mx-auto">
              <span class="text-xs font-extrabold uppercase tracking-wider text-brand bg-brand/5 px-3 py-1 rounded-full">Core Principles</span>
              <h2 class="mt-3 text-3xl font-extrabold text-txt-primary">Our Core Values</h2>
              <p class="mt-2 text-sm text-txt-secondary">How we prioritize product decisions and user experience.</p>
            </div>

            <!-- Value Selection Tabs -->
            <div class="flex flex-col sm:flex-row items-center justify-center gap-3 p-1.5 bg-slate-100 dark:bg-slate-800/80 rounded-2xl max-w-2xl mx-auto border border-border">
              <button 
                v-for="val in values" 
                :key="val.key"
                type="button"
                class="w-full sm:w-auto flex items-center justify-center gap-2 px-5 py-3 rounded-xl text-xs sm:text-sm font-extrabold transition-all"
                :class="selectedValue === val.key ? 'bg-white dark:bg-slate-900 text-brand shadow-sm border border-border/40' : 'text-txt-secondary hover:text-txt-primary hover:bg-white/50 dark:hover:bg-slate-900/30'"
                @click="selectedValue = val.key"
              >
                <span class="text-base">{{ val.icon }}</span>
                {{ val.title }}
              </button>
            </div>

            <!-- Interactive Value Panel -->
            <div class="rounded-3xl border border-border/80 bg-surface p-6 sm:p-8 md:p-10 shadow-lg min-h-[400px] relative overflow-hidden transition-all duration-300">
              
              <!-- VALUE 1: CLARITY FIRST (Before/After Resume Demo) -->
              <div v-if="selectedValue === 'clarity'" class="grid grid-cols-1 lg:grid-cols-[300px_1fr] gap-8 items-center">
                <div class="space-y-4">
                  <h3 class="text-xl font-extrabold text-txt-primary">Clarity Over Clutter</h3>
                  <p class="text-sm leading-relaxed text-txt-secondary">
                    Standard layouts should emphasize details clearly, avoiding unnecessary decorations, progress bars, and mismatched styles that turn recruiters away.
                  </p>
                  
                  <!-- Before/After Selector Toggle -->
                  <div class="inline-flex rounded-xl bg-slate-100 dark:bg-slate-800 p-1 border border-border">
                    <button 
                      type="button"
                      class="px-4 py-2 rounded-lg text-xs font-extrabold transition-all"
                      :class="clarityToggle === 'before' ? 'bg-red-500 text-white shadow-sm' : 'text-txt-secondary hover:text-txt-primary'"
                      @click="clarityToggle = 'before'"
                    >
                      Legacy Layout
                    </button>
                    <button 
                      type="button"
                      class="px-4 py-2 rounded-lg text-xs font-extrabold transition-all"
                      :class="clarityToggle === 'after' ? 'bg-emerald-500 text-white shadow-sm' : 'text-txt-secondary hover:text-txt-primary'"
                      @click="clarityToggle = 'after'"
                    >
                      CareerAI Layout
                    </button>
                  </div>
                </div>

                <!-- Interactive Resume Preview Box -->
                <div class="border border-border/80 rounded-2xl p-6 bg-white shadow-inner min-h-[280px] flex flex-col justify-between select-none relative max-w-lg mx-auto w-full transition-all duration-300">
                  <div v-if="clarityToggle === 'before'" class="space-y-4 font-sans text-slate-800 animate-fade-in">
                    <!-- Cluttered Header -->
                    <div class="grid grid-cols-3 gap-2 border-b-2 border-red-500 pb-3">
                      <div class="col-span-2">
                        <h4 class="text-lg font-black text-red-600 tracking-wider">ANIKET YADAV</h4>
                        <p class="text-[10px] text-slate-500 italic">"I build stuff, solve problems, write CSS, and code Rails."</p>
                      </div>
                      <div class="bg-red-50 border border-red-200 p-1 rounded text-center">
                        <div class="text-[9px] font-bold text-red-700">CREATIVE DEV</div>
                        <div class="text-[8px] text-slate-400">ID: 98154</div>
                      </div>
                    </div>

                    <!-- Cluttered Grid Content -->
                    <div class="grid grid-cols-3 gap-4 text-[10px]">
                      <!-- Left side: random visual progress bars -->
                      <div class="col-span-1 border-r border-slate-200 pr-2 space-y-2">
                        <span class="font-bold text-red-600 block border-b border-red-200 pb-0.5">SKILL PERCENTAGE</span>
                        <div class="space-y-1">
                          <div class="flex justify-between text-[8px] font-medium text-slate-600"><span>Vue.js</span><span>80%</span></div>
                          <div class="w-full bg-slate-100 h-1.5 rounded-full overflow-hidden"><div class="bg-red-500 h-full w-[80%]" /></div>
                        </div>
                        <div class="space-y-1">
                          <div class="flex justify-between text-[8px] font-medium text-slate-600"><span>CSS</span><span>95%</span></div>
                          <div class="w-full bg-slate-100 h-1.5 rounded-full overflow-hidden"><div class="bg-red-500 h-full w-[95%]" /></div>
                        </div>
                      </div>
                      
                      <!-- Right side: messy descriptions -->
                      <div class="col-span-2 space-y-2">
                        <span class="font-bold text-red-600 block border-b border-red-200 pb-0.5">WORK & PROJECTS</span>
                        <div class="space-y-1">
                          <p class="font-bold">Software Developer — UTU Tech</p>
                          <p class="text-[9px] text-slate-500 leading-tight">
                            Did various tasks, customized user styles, deployed the server several times, resolved front-end conflicts with multiple CSS properties.
                          </p>
                        </div>
                      </div>
                    </div>
                  </div>

                  <div v-else class="space-y-4 font-sans text-slate-800 animate-fade-in">
                    <!-- Clean, focused header -->
                    <div class="flex justify-between items-start border-b border-slate-100 pb-3">
                      <div>
                        <h4 class="text-xl font-bold tracking-tight text-brand">Aniket Yadav</h4>
                        <p class="text-xs font-semibold text-slate-500 mt-0.5">Frontend Developer • Bengaluru, IN</p>
                      </div>
                      <span class="text-[9px] font-mono bg-emerald-50 text-emerald-600 px-2 py-0.5 rounded border border-emerald-100 font-extrabold uppercase">Clean Layout</span>
                    </div>

                    <!-- Clean Content -->
                    <div class="space-y-3 text-[11px]">
                      <div>
                        <h5 class="text-[10px] font-extrabold uppercase tracking-wider text-brand">Key Experience</h5>
                        <div class="mt-1">
                          <div class="flex justify-between font-bold">
                            <span>Frontend Engineer @ CareerAI</span>
                            <span class="text-slate-500 font-normal">2024 – Present</span>
                          </div>
                          <p class="text-slate-600 leading-relaxed mt-0.5">
                            Built and optimized modular resume engines. Developed custom builder options, reducing PDF render latency and improving client-side responsiveness.
                          </p>
                        </div>
                      </div>

                      <div>
                        <h5 class="text-[10px] font-extrabold uppercase tracking-wider text-brand">Core Technologies</h5>
                        <div class="flex flex-wrap gap-1 mt-1">
                          <span v-for="s in ['Vue.js', 'Vite', 'TailwindCSS', 'JavaScript']" :key="s" class="bg-slate-50 border border-slate-200/60 text-slate-700 px-2 py-0.5 rounded text-[9px] font-medium">
                            {{ s }}
                          </span>
                        </div>
                      </div>
                    </div>
                  </div>
                </div>
              </div>

              <!-- VALUE 2: RESPECT YOUR TIME (Time Saved Calculator) -->
              <div v-else-if="selectedValue === 'time'" class="grid grid-cols-1 lg:grid-cols-[300px_1fr] gap-8 items-center">
                <div class="space-y-4">
                  <h3 class="text-xl font-extrabold text-txt-primary">Respect Your Time</h3>
                  <p class="text-sm leading-relaxed text-txt-secondary">
                    Creating bespoke resumes shouldn't take hours of manual copy-pasting. CareerAI lets you spin up new tailored versions of your resume instantly.
                  </p>
                  
                  <!-- Interactive Controls -->
                  <div class="space-y-3 bg-slate-50/50 dark:bg-slate-800/20 border border-border/60 rounded-2xl p-5">
                    <label class="text-xs font-bold text-txt-secondary block">Resumes Tailored / Month</label>
                    <div class="flex items-center gap-3">
                      <input 
                        type="range" 
                        min="1" 
                        max="10" 
                        v-model.number="tailoredCount"
                        class="w-full h-1.5 bg-slate-200 rounded-lg appearance-none cursor-pointer accent-brand"
                      />
                      <span class="text-xs font-extrabold text-brand font-mono">{{ tailoredCount }}</span>
                    </div>
                  </div>
                </div>

                <!-- Calculator Dashboard Card -->
                <div class="border border-border/80 rounded-2xl p-6 bg-slate-50 dark:bg-slate-800/10 shadow-sm flex flex-col justify-between max-w-lg mx-auto w-full min-h-[260px]">
                  <div>
                    <h4 class="text-xs font-extrabold uppercase tracking-wide text-txt-muted border-b border-border pb-2">TIME CONVERSION REPORT</h4>
                    <div class="grid grid-cols-2 gap-4 mt-6 items-center">
                      <div class="text-center p-4 bg-white dark:bg-slate-900 border border-border rounded-xl">
                        <span class="text-3xl font-black text-brand font-mono block">{{ hoursSaved }}h</span>
                        <span class="text-[10px] font-bold text-txt-muted uppercase mt-1 block">Total Hours Saved</span>
                      </div>
                      <div class="text-center p-4 bg-white dark:bg-slate-900 border border-border rounded-xl">
                        <span class="text-3xl font-black text-emerald-500 font-mono block">{{ tailoredCount }}</span>
                        <span class="text-[10px] font-bold text-txt-muted uppercase mt-1 block">Draft Versions</span>
                      </div>
                    </div>
                  </div>

                  <div class="bg-brand/5 border border-brand/10 p-3 rounded-xl flex items-center gap-3 mt-4">
                    <span class="text-xl">💡</span>
                    <p class="text-xs font-medium text-txt-secondary">
                      You've reclaimed <strong class="text-brand">{{ hoursSaved }} hours</strong> of your life. That's enough time to run <strong class="text-brand">{{ Math.round(hoursSaved * 1.5) }} mock interviews</strong> or submit several applications.
                    </p>
                  </div>
                </div>
              </div>

              <!-- VALUE 3: DATA-DRIVEN CONFIDENCE (AI Bullet Point Enhancer) -->
              <div v-else-if="selectedValue === 'data'" class="grid grid-cols-1 lg:grid-cols-[300px_1fr] gap-8">
                <div class="space-y-4">
                  <h3 class="text-xl font-extrabold text-txt-primary">Data-Driven Confidence</h3>
                  <p class="text-sm leading-relaxed text-txt-secondary">
                    Recruiters scan resumes looking for impact. Our AI helper helps you translate ordinary lists of duties into quantifiable achievements.
                  </p>

                  <!-- Tone Selector Control -->
                  <div class="space-y-3 bg-slate-50/50 dark:bg-slate-800/20 border border-border/60 rounded-2xl p-5">
                    <div>
                      <label class="text-[10px] font-extrabold text-txt-secondary block uppercase tracking-wider mb-1.5">AI Engine Tone</label>
                      <select 
                        v-model="engineTone" 
                        class="w-full rounded-xl border border-border bg-surface px-3 py-2 text-xs font-bold text-txt-primary focus:outline-none focus:border-brand shadow-sm"
                      >
                        <option value="executive">Executive (Action & Metrics)</option>
                        <option value="technical">Technical (Tech Stack & Architecture)</option>
                        <option value="creative">Creative (Innovation & Narrative)</option>
                      </select>
                    </div>

                    <div>
                      <label class="text-[10px] font-extrabold text-txt-secondary block uppercase tracking-wider mb-1.5">Keyword Match Rate</label>
                      <div class="flex items-center gap-2">
                        <input 
                          type="range" 
                          min="30" 
                          max="100" 
                          v-model.number="engineKeywords"
                          class="w-full h-1.5 bg-slate-200 rounded-lg appearance-none cursor-pointer accent-brand"
                        />
                        <span class="text-xs font-extrabold text-brand font-mono">{{ engineKeywords }}%</span>
                      </div>
                    </div>
                  </div>
                </div>

                <!-- AI Enhancer Sandbox -->
                <div class="border border-border/80 rounded-2xl p-5 bg-slate-50 dark:bg-slate-800/10 flex flex-col justify-between max-w-lg mx-auto w-full min-h-[300px]">
                  <div>
                    <div class="flex items-center justify-between border-b border-border pb-3">
                      <span class="text-xs font-extrabold uppercase tracking-wider text-txt-muted">AI Enhancer Simulator</span>
                      <span class="inline-flex items-center gap-1 text-[10px] font-bold text-brand bg-brand/10 px-2 py-0.5 rounded-full">
                        Status: Ready
                      </span>
                    </div>

                    <div class="mt-4">
                      <label class="text-[10px] font-extrabold text-txt-muted uppercase">Original Input</label>
                      <textarea 
                        v-model="inputBullet" 
                        rows="2" 
                        class="mt-1 w-full rounded-xl border border-border p-3 text-xs bg-white text-txt-primary focus:outline-none focus:border-brand"
                        placeholder="Write a basic job responsibility..."
                      />
                    </div>
                  </div>

                  <!-- Rewrite Processing -->
                  <div v-if="isRewriting" class="mt-4 flex items-center justify-center gap-2 text-xs text-txt-muted py-2 font-medium">
                    <svg class="size-4 animate-spin text-brand" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                      <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                      <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4z"></path>
                    </svg>
                    <span>Optimizing with AI Engine...</span>
                  </div>

                  <!-- Result Content -->
                  <div v-else-if="outputBullet" class="mt-4 p-4 rounded-xl bg-slate-900 text-slate-100 border border-slate-800 animate-fade-in space-y-4">
                    <div class="flex items-center justify-between border-b border-slate-800 pb-2">
                      <span class="text-xs font-bold text-slate-400">Quantifiable Output</span>
                      <span class="text-xs font-bold font-mono text-emerald-400">Tone: {{ engineTone }}</span>
                    </div>
                    <p class="text-[11px] text-slate-300 leading-relaxed font-medium">
                      {{ outputBullet }}
                    </p>

                    <!-- Dynamic AI Score Gauges -->
                    <div class="grid grid-cols-3 gap-2.5 pt-2 border-t border-slate-800 text-center">
                      <div class="p-1.5 rounded bg-slate-800/40">
                        <span class="text-xs font-black text-emerald-400 font-mono block">{{ engineAtsScore }}%</span>
                        <span class="text-[8px] font-bold text-slate-500 uppercase mt-0.5 block">ATS Match</span>
                      </div>
                      <div class="p-1.5 rounded bg-slate-800/40">
                        <span class="text-xs font-black text-emerald-400 font-mono block">{{ engineImpactScore }}%</span>
                        <span class="text-[8px] font-bold text-slate-500 uppercase mt-0.5 block">Impact</span>
                      </div>
                      <div class="p-1.5 rounded bg-slate-800/40">
                        <span class="text-xs font-black text-emerald-400 font-mono block">{{ engineReadabilityScore }}%</span>
                        <span class="text-[8px] font-bold text-slate-500 uppercase mt-0.5 block">Readability</span>
                      </div>
                    </div>
                  </div>

                  <div class="mt-4 flex justify-end gap-2">
                    <button 
                      v-if="outputBullet"
                      type="button" 
                      class="rounded-xl border border-border px-4 py-2.5 text-xs font-bold text-txt-secondary hover:bg-slate-100 transition-all"
                      @click="resetBullet"
                    >
                      Reset
                    </button>
                    <button 
                      type="button" 
                      class="rounded-xl bg-slate-900 text-white px-5 py-2.5 text-xs font-bold transition-all hover:bg-slate-800 shadow-sm"
                      :disabled="isRewriting"
                      @click="rewriteBullet"
                    >
                      {{ outputBullet ? 'Rewrite Again' : 'Get AI Enhancement' }}
                    </button>
                  </div>
                </div>
              </div>

            </div>
          </div>

          <!-- Bottom CTA -->
          <div v-if="page.cta" class="rounded-3xl border border-brand/20 bg-brand/5 p-8 text-center sm:p-10">
            <h3 class="text-lg font-bold text-txt-primary">{{ page.cta.title }}</h3>
            <p v-if="page.cta.body" class="mt-2 text-sm text-txt-secondary">{{ page.cta.body }}</p>
            <button 
              type="button"
              class="mt-5 inline-flex rounded-xl bg-brand px-6 py-2.5 text-sm font-bold text-white shadow-md shadow-brand/10 transition-all hover:bg-brand/90"
              @click="handleCtaClick(page.cta.to)"
            >
              {{ page.cta.label }}
            </button>
          </div>
        </div>

        <!-- CUSTOM INTERACTIVE CONTACT PAGE -->
        <div v-else-if="pageKey === 'contact'" class="space-y-12">
          <div class="grid grid-cols-1 md:grid-cols-2 gap-8 max-w-4xl mx-auto">
            
            <!-- WhatsApp Card -->
            <div class="rounded-3xl border border-emerald-500/20 bg-emerald-500/[0.02] dark:bg-emerald-500/[0.01] p-8 shadow-sm flex flex-col justify-between transition-all hover:border-emerald-500/40 relative overflow-hidden group">
              <div class="absolute inset-0 opacity-[0.03] bg-[radial-gradient(circle_at_top_right,rgba(16,185,129,0.3),transparent)] pointer-events-none" />
              <div class="relative z-10 flex flex-col justify-between h-full w-full">
                <div>
                  <!-- Icon Header -->
                  <div class="mb-6 grid size-12 place-items-center rounded-xl bg-emerald-500/10 text-emerald-500">
                    <!-- WhatsApp SVG Icon -->
                    <svg class="size-6" fill="currentColor" viewBox="0 0 24 24">
                      <path d="M17.472 14.382c-.297-.149-1.758-.867-2.03-.967-.273-.099-.471-.148-.67.15-.197.297-.767.966-.94 1.164-.173.199-.347.223-.644.075-.297-.15-1.255-.463-2.39-1.475-.883-.788-1.48-1.761-1.653-2.059-.173-.297-.018-.458.13-.606.134-.133.298-.347.446-.52.149-.174.198-.298.298-.497.099-.198.05-.371-.025-.52-.075-.149-.669-1.612-.916-2.207-.242-.579-.487-.5-.669-.51-.173-.008-.371-.01-.57-.01-.198 0-.52.074-.792.372-.272.297-1.04 1.016-1.04 2.479 0 1.462 1.065 2.875 1.213 3.074.149.198 2.096 3.2 5.077 4.487.709.306 1.262.489 1.694.625.712.227 1.36.195 1.871.118.571-.085 1.758-.719 2.006-1.413.248-.694.248-1.289.173-1.413-.074-.124-.272-.198-.57-.347m-5.421 7.403h-.004a9.87 9.87 0 01-5.031-1.378l-.361-.214-3.741.982.998-3.648-.235-.374a9.86 9.86 0 01-1.51-5.26c.001-5.45 4.436-9.884 9.888-9.884 2.64 0 5.122 1.03 6.988 2.898a9.825 9.825 0 012.893 6.994c-.003 5.45-4.437 9.884-9.885 9.884m8.413-18.297A11.815 11.815 0 0012.05 0C5.495 0 .16 5.335.157 11.892c0 2.096.547 4.142 1.588 5.945L0 24l6.335-1.662c1.746.953 3.71 1.456 5.705 1.458h.005c6.554 0 11.89-5.335 11.893-11.893a11.821 11.821 0 00-3.48-8.413z" />
                    </svg>
                  </div>
                  
                  <h3 class="text-xl font-extrabold text-txt-primary">WhatsApp Support</h3>
                  <p class="mt-3 text-sm leading-relaxed text-txt-secondary">
                    Connect directly with our support team on WhatsApp for real-time inquiries, feedback, or quick account assistance.
                  </p>
                  <div class="mt-4 text-xs font-bold text-emerald-600 dark:text-emerald-400 font-mono">
                    Active • Typically replies in minutes
                  </div>
                </div>
                
                <div class="mt-8">
                  <a 
                    href="https://wa.me/916284424697" 
                    target="_blank" 
                    rel="noopener noreferrer" 
                    class="w-full inline-flex items-center justify-center gap-2 rounded-xl bg-emerald-500 hover:bg-emerald-600 px-5 py-3 text-sm font-bold text-white shadow-md shadow-emerald-500/10 transition-all hover:-translate-y-0.5"
                  >
                    Chat on WhatsApp
                  </a>
                </div>
              </div>
            </div>

            <!-- Email Card -->
            <div class="rounded-3xl border border-brand/20 bg-brand/[0.02] dark:bg-brand/[0.01] p-8 shadow-sm flex flex-col justify-between transition-all hover:border-brand/40 relative overflow-hidden group">
              <div class="absolute inset-0 opacity-[0.03] bg-[radial-gradient(circle_at_top_right,rgba(109,74,255,0.3),transparent)] pointer-events-none" />
              <div class="relative z-10 flex flex-col justify-between h-full w-full">
                <div>
                  <!-- Icon Header -->
                  <div class="mb-6 grid size-12 place-items-center rounded-xl bg-brand/10 text-brand">
                    <!-- Mail SVG Icon -->
                    <svg class="size-6" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                      <path stroke-linecap="round" stroke-linejoin="round" d="M3 8l7.89 5.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z" />
                    </svg>
                  </div>
                  
                  <h3 class="text-xl font-extrabold text-txt-primary">Email Support</h3>
                  <p class="mt-3 text-sm leading-relaxed text-txt-secondary">
                    Send us an email for general inquiries, corporate partnerships, billing concerns, or deletion requests.
                  </p>
                  <div class="mt-4 text-xs font-bold text-brand font-mono">
                    ajitaniket956556@gmail.com
                  </div>
                </div>
                
                <div class="mt-8">
                  <a 
                    href="mailto:ajitaniket956556@gmail.com" 
                    class="w-full inline-flex items-center justify-center gap-2 rounded-xl bg-slate-900 hover:bg-slate-800 text-white px-5 py-3 text-sm font-bold shadow-md transition-all hover:-translate-y-0.5"
                  >
                    Send an Email
                  </a>
                </div>
              </div>
            </div>

          </div>

          <!-- Bottom CTA -->
          <div v-if="page.cta" class="rounded-3xl border border-border/80 bg-surface p-8 text-center sm:p-10 max-w-4xl mx-auto">
            <h3 class="text-lg font-bold text-txt-primary">{{ page.cta.title }}</h3>
            <p v-if="page.cta.body" class="mt-2 text-sm text-txt-secondary">{{ page.cta.body }}</p>
            <button 
              type="button"
              class="mt-5 inline-flex rounded-xl bg-brand px-6 py-2.5 text-sm font-bold text-white shadow-md shadow-brand/10 transition-all hover:bg-brand/90"
              @click="handleCtaClick(page.cta.to)"
            >
              {{ page.cta.label }}
            </button>
          </div>
        </div>

        <!-- CUSTOM INTERACTIVE SUPPORT TICKET PAGE -->
        <div v-else-if="pageKey === 'support'" class="space-y-10">
          <div class="grid grid-cols-1 lg:grid-cols-12 gap-8 items-start">
            
            <!-- Sidebar Quick Information and Checklist (4 cols) -->
            <div class="lg:col-span-4 space-y-6">
              <!-- Checklist Info Card -->
              <div 
                v-for="(section, index) in page.sections" 
                :key="index"
                class="rounded-3xl border border-border/80 bg-surface p-6 shadow-sm space-y-4"
              >
                <div class="flex items-center gap-3">
                  <div class="grid size-10 place-items-center rounded-xl bg-brand/10 text-brand">
                    <component :is="getIconComponent(section.heading)" class="size-5" />
                  </div>
                  <h4 class="text-sm font-extrabold text-txt-primary">{{ section.heading }}</h4>
                </div>
                
                <p v-if="section.body" class="text-xs leading-5 text-txt-secondary">{{ section.body }}</p>
                
                <ul v-if="section.items?.length" class="space-y-2.5">
                  <li v-for="(item, i) in section.items" :key="i" class="flex gap-2.5 text-xs text-txt-secondary leading-5">
                    <svg class="size-3.5 text-emerald-500 shrink-0 mt-0.5" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2.5">
                      <path stroke-linecap="round" stroke-linejoin="round" d="M5 13l4 4L19 7" />
                    </svg>
                    <span>{{ item }}</span>
                  </li>
                </ul>
              </div>
            </div>

            <!-- Composer Ticket Panel (8 cols) -->
            <div class="lg:col-span-8 rounded-3xl border border-border bg-surface p-6 sm:p-8 md:p-10 shadow-sm relative overflow-hidden">
              <div class="absolute inset-0 opacity-[0.01] bg-[radial-gradient(circle_at_top_right,rgba(109,74,255,0.25),transparent)] pointer-events-none" />
              
              <div class="relative z-10 space-y-6">
                <div>
                  <span class="text-[10px] font-extrabold uppercase tracking-wider text-brand bg-brand/5 px-2.5 py-1 rounded-full">Interactive Composer</span>
                  <h3 class="text-xl font-extrabold text-txt-primary mt-3">Generate Support Ticket</h3>
                  <p class="text-xs text-txt-secondary mt-1">Compose your inquiry details below. We'll automatically generate a prefilled message channel.</p>
                </div>

                <form @submit.prevent="submitSupportTicket" class="space-y-5">
                  <!-- Category Choice -->
                  <div>
                    <label class="block text-xs font-bold text-txt-primary mb-2">Select Issue Category</label>
                    <div class="grid grid-cols-2 sm:grid-cols-4 gap-2">
                      <button 
                        v-for="cat in supportCategories" 
                        :key="cat.value"
                        type="button"
                        class="px-3 py-2.5 rounded-xl text-xs font-bold text-center border transition-all"
                        :class="supportCategory === cat.value ? 'bg-brand border-brand text-white shadow-sm shadow-brand/10' : 'bg-white dark:bg-slate-900 border-border text-txt-secondary hover:bg-slate-50'"
                        @click="supportCategory = cat.value"
                      >
                        {{ cat.label }}
                      </button>
                    </div>
                  </div>

                  <!-- Subject Field -->
                  <div>
                    <label class="block text-xs font-bold text-txt-primary mb-2">Subject / Summary</label>
                    <input 
                      type="text" 
                      v-model="supportSubject" 
                      placeholder="e.g. Credit balance update issue" 
                      required
                      class="w-full rounded-xl border border-border bg-white dark:bg-slate-900 px-4 py-3 text-xs text-txt-primary focus:outline-none focus:border-brand focus:ring-2 focus:ring-brand/10 transition-all shadow-sm"
                    />
                  </div>

                  <!-- Message Textarea -->
                  <div>
                    <label class="block text-xs font-bold text-txt-primary mb-2">Detailed Message</label>
                    <textarea 
                      v-model="supportMessage" 
                      rows="4" 
                      placeholder="Describe your question or issue in detail. If applicable, mention the specific steps taken..." 
                      required
                      class="w-full rounded-xl border border-border bg-white dark:bg-slate-900 px-4 py-3 text-xs text-txt-primary focus:outline-none focus:border-brand focus:ring-2 focus:ring-brand/10 transition-all shadow-sm resize-none"
                    />
                  </div>

                  <!-- Support Delivery Method -->
                  <div>
                    <label class="block text-xs font-bold text-txt-primary mb-2">Select Preferred Channel</label>
                    <div class="grid grid-cols-1 sm:grid-cols-2 gap-3">
                      <!-- Email support method button -->
                      <button 
                        type="button"
                        class="flex items-center justify-between p-4 rounded-xl border transition-all text-left"
                        :class="supportMethod === 'email' ? 'border-brand bg-brand/5 ring-1 ring-brand/10' : 'border-border bg-white dark:bg-slate-900'"
                        @click="supportMethod = 'email'"
                      >
                        <div class="flex items-center gap-3">
                          <span class="grid size-9 place-items-center rounded-lg bg-blue-500/10 text-blue-500 text-lg">✉️</span>
                          <div>
                            <p class="text-xs font-extrabold text-txt-primary">Email Support</p>
                            <p class="text-[10px] text-txt-secondary">Fast responses within 24h</p>
                          </div>
                        </div>
                        <input type="radio" :checked="supportMethod === 'email'" class="size-4 shrink-0 text-brand focus:ring-brand" />
                      </button>

                      <!-- WhatsApp support method button -->
                      <button 
                        type="button"
                        class="flex items-center justify-between p-4 rounded-xl border transition-all text-left"
                        :class="supportMethod === 'whatsapp' ? 'border-emerald-500 bg-emerald-500/5 ring-1 ring-emerald-500/10' : 'border-border bg-white dark:bg-slate-900'"
                        @click="supportMethod = 'whatsapp'"
                      >
                        <div class="flex items-center gap-3">
                          <span class="grid size-9 place-items-center rounded-lg bg-emerald-500/10 text-emerald-500 text-lg">💬</span>
                          <div>
                            <p class="text-xs font-extrabold text-txt-primary">WhatsApp Chat</p>
                            <p class="text-[10px] text-txt-secondary">Instant agent connection</p>
                          </div>
                        </div>
                        <input type="radio" :checked="supportMethod === 'whatsapp'" class="size-4 shrink-0 text-emerald-500 focus:ring-emerald-500" />
                      </button>
                    </div>
                  </div>

                  <!-- Submit Ticket Button -->
                  <div class="pt-2">
                    <button 
                      type="submit"
                      class="w-full flex items-center justify-center gap-2 rounded-xl py-3.5 text-xs font-extrabold text-white shadow-md transition-all"
                      :class="supportMethod === 'whatsapp' ? 'bg-emerald-600 hover:bg-emerald-700 shadow-emerald-600/10' : 'bg-brand hover:bg-brand/90 shadow-brand/10'"
                    >
                      <span>{{ supportMethod === 'whatsapp' ? 'Launch WhatsApp Chat' : 'Compose Support Email' }}</span>
                      <svg class="size-4" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                        <path stroke-linecap="round" stroke-linejoin="round" d="M14 5l7 7m0 0l-7 7m7-7H3" />
                      </svg>
                    </button>
                  </div>
                </form>
              </div>
            </div>

          </div>
        </div>

        <!-- CUSTOM INTERACTIVE HELP CENTER PAGE -->
        <div v-else-if="pageKey === 'help'" class="space-y-10">
          
          <!-- Interactive Search & Filtering Header -->
          <div class="rounded-3xl border border-border bg-surface p-6 sm:p-8 md:p-10 shadow-sm relative overflow-hidden">
            <div class="absolute inset-0 opacity-[0.02] bg-[radial-gradient(circle_at_top_right,rgba(109,74,255,0.25),transparent)] pointer-events-none" />
            <div class="relative z-10 max-w-2xl mx-auto text-center space-y-5">
              <span class="text-xs font-extrabold uppercase tracking-wider text-brand bg-brand/5 px-3 py-1 rounded-full">Interactive Support Hub</span>
              <h2 class="text-2xl font-extrabold text-txt-primary">Find answers instantly</h2>
              <p class="text-sm text-txt-secondary">Search our dynamic database for account guides, AI tools instructions, and workspace controls.</p>
              
              <!-- Search Box -->
              <div class="relative max-w-lg mx-auto">
                <input 
                  type="text" 
                  v-model="helpSearchQuery" 
                  placeholder="Type keywords (e.g. 'pdf', 'password', 'ai')..." 
                  class="w-full rounded-2xl border border-border bg-white dark:bg-slate-900 pl-11 pr-4 py-3.5 text-sm text-txt-primary focus:outline-none focus:border-brand focus:ring-2 focus:ring-brand/10 transition-all shadow-sm"
                />
                <!-- Search Icon -->
                <svg class="size-5 text-txt-muted absolute left-4 top-1/2 -translate-y-1/2 pointer-events-none" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                  <path stroke-linecap="round" stroke-linejoin="round" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
                </svg>
                <!-- Clear Button -->
                <button 
                  v-if="helpSearchQuery" 
                  type="button" 
                  @click="helpSearchQuery = ''" 
                  class="absolute right-4 top-1/2 -translate-y-1/2 text-txt-muted hover:text-txt-primary text-xs font-bold transition-all"
                >
                  Clear
                </button>
              </div>

              <!-- Quick Links Category Tabs -->
              <div class="flex flex-wrap items-center justify-center gap-2 pt-2">
                <button 
                  v-for="cat in helpCategories" 
                  :key="cat"
                  type="button"
                  class="px-4 py-2 rounded-xl text-xs font-bold transition-all border"
                  :class="helpSelectedCategory === cat ? 'bg-brand border-brand text-white shadow-sm shadow-brand/10' : 'bg-white dark:bg-slate-900 border-border text-txt-secondary hover:text-txt-primary hover:bg-slate-50'"
                  @click="helpSelectedCategory = cat"
                >
                  {{ cat }}
                </button>
              </div>
            </div>
          </div>

          <!-- Dynamic Articles Results Accordion Grid -->
          <div class="space-y-4 max-w-4xl mx-auto">
            <div class="flex items-center justify-between px-2 mb-2">
              <h3 class="text-sm font-bold uppercase tracking-wider text-txt-muted">
                {{ filteredHelpArticles.length }} {{ filteredHelpArticles.length === 1 ? 'Article' : 'Articles' }} Found
              </h3>
              <button 
                v-if="helpSearchQuery || helpSelectedCategory !== 'All'" 
                type="button" 
                @click="helpSearchQuery = ''; helpSelectedCategory = 'All'" 
                class="text-xs text-brand font-bold hover:underline"
              >
                Reset Filters
              </button>
            </div>

            <!-- Empty State -->
            <div v-if="filteredHelpArticles.length === 0" class="rounded-3xl border border-dashed border-border p-12 text-center">
              <div class="mx-auto mb-4 grid size-12 place-items-center rounded-xl bg-slate-100 text-slate-400">
                <svg class="size-6" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                  <path stroke-linecap="round" stroke-linejoin="round" d="M9.172 16.172a4 4 0 015.656 0M9 10h.01M15 10h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
                </svg>
              </div>
              <h3 class="text-sm font-bold text-txt-primary">No articles found</h3>
              <p class="text-xs text-txt-secondary mt-1">Try resetting the search terms or browsing another category.</p>
            </div>

            <!-- Articles List -->
            <div 
              v-for="art in filteredHelpArticles" 
              :key="art.title"
              class="rounded-2xl border border-border bg-surface shadow-sm overflow-hidden transition-all hover:border-brand/25"
            >
              <button 
                type="button"
                class="w-full flex items-center justify-between p-5 text-left font-bold text-txt-primary transition hover:bg-slate-50/50"
                @click="toggleHelpArticle(art.title)"
              >
                <div class="flex items-center gap-3.5">
                  <span class="grid size-9 place-items-center rounded-xl bg-slate-100 dark:bg-slate-800 text-lg">{{ art.icon }}</span>
                  <div>
                    <h4 class="text-sm font-extrabold text-txt-primary text-left">{{ art.title }}</h4>
                    <span class="text-[10px] font-bold text-txt-muted uppercase tracking-wide bg-slate-100 dark:bg-slate-800 px-2 py-0.5 rounded-md mt-1 inline-block">
                      {{ art.category }}
                    </span>
                  </div>
                </div>
                <svg 
                  class="size-5 shrink-0 text-txt-muted transition-transform duration-200"
                  :class="{ 'rotate-180 text-brand': expandedHelpArticles.includes(art.title) }"
                  fill="none" 
                  viewBox="0 0 24 24" 
                  stroke="currentColor" 
                  stroke-width="2"
                >
                  <path stroke-linecap="round" stroke-linejoin="round" d="M19 9l-7 7-7-7" />
                </svg>
              </button>
              
              <Transition
                enter-active-class="transition-all duration-200 ease-out"
                enter-from-class="max-h-0 opacity-0"
                enter-to-class="max-h-[500px] opacity-100"
                leave-active-class="transition-all duration-150 ease-in"
                leave-from-class="max-h-[500px] opacity-100"
                leave-to-class="max-h-0 opacity-0"
              >
                <div v-if="expandedHelpArticles.includes(art.title)" class="border-t border-border/60 bg-slate-50/20 px-5 py-4">
                  <p class="text-sm leading-7 text-txt-secondary">{{ art.content }}</p>
                </div>
              </Transition>
            </div>
          </div>

          <!-- Bottom CTA -->
          <div v-if="page.cta" class="rounded-3xl border border-border/80 bg-surface p-8 text-center sm:p-10 max-w-4xl mx-auto">
            <h3 class="text-lg font-bold text-txt-primary">{{ page.cta.title }}</h3>
            <p v-if="page.cta.body" class="mt-2 text-sm text-txt-secondary">{{ page.cta.body }}</p>
            <button 
              type="button"
              class="mt-5 inline-flex rounded-xl bg-brand px-6 py-2.5 text-sm font-bold text-white shadow-md shadow-brand/10 transition-all hover:bg-brand/90"
              @click="handleCtaClick(page.cta.to)"
            >
              {{ page.cta.label }}
            </button>
          </div>
        </div>

        <!-- General Grid/Cards Layout (Careers, Support, Help) -->
        <div v-else class="space-y-12">
          <!-- Grids of sections -->
          <div class="grid grid-cols-1 md:grid-cols-2 gap-8">
            <div 
              v-for="(section, index) in page.sections" 
              :key="index"
              class="rounded-3xl border border-border/80 bg-surface p-6 sm:p-8 shadow-sm flex flex-col justify-between transition-all hover:border-brand/20"
            >
              <div>
                <!-- Icon Header -->
                <div class="mb-5 grid size-12 place-items-center rounded-xl bg-brand/10 text-brand">
                  <component :is="getIconComponent(section.heading)" class="size-6" />
                </div>
                
                <h3 class="text-lg font-bold text-txt-primary">{{ section.heading }}</h3>
                <p v-if="section.body" class="mt-4 text-sm leading-7 text-txt-secondary">{{ section.body }}</p>
                
                <ul v-if="section.items?.length" class="mt-5 space-y-3">
                  <li v-for="(item, i) in section.items" :key="i" class="flex gap-3 text-sm text-txt-secondary leading-6">
                    <svg class="size-4 text-emerald-500 shrink-0 mt-1" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2.5">
                      <path stroke-linecap="round" stroke-linejoin="round" d="M5 13l4 4L19 7" />
                    </svg>
                    <span>{{ item }}</span>
                  </li>
                </ul>
              </div>
            </div>
          </div>

          <!-- Bottom CTA -->
          <div v-if="page.cta" class="rounded-3xl border border-brand/20 bg-brand/5 p-8 text-center sm:p-10">
            <h3 class="text-lg font-bold text-txt-primary">{{ page.cta.title }}</h3>
            <p v-if="page.cta.body" class="mt-2 text-sm text-txt-secondary">{{ page.cta.body }}</p>
            <button 
              type="button"
              class="mt-5 inline-flex rounded-xl bg-brand px-6 py-2.5 text-sm font-bold text-white shadow-md shadow-brand/10 transition-all hover:bg-brand/90"
              @click="handleCtaClick(page.cta.to)"
            >
              {{ page.cta.label }}
            </button>
          </div>
        </div>

      </section>
    </div>

    <!-- Teleport Coming Soon Modal -->
    <Teleport to="body">
      <Transition
        enter-active-class="transition-all duration-300 ease-out"
        enter-from-class="opacity-0"
        enter-to-class="opacity-100"
        leave-active-class="transition-all duration-200 ease-in"
        leave-from-class="opacity-100"
        leave-to-class="opacity-0"
      >
        <div 
          v-if="modalOpen" 
          class="fixed inset-0 z-[9999] flex items-center justify-center p-4 bg-slate-950/70 backdrop-blur-md"
          @click.self="modalOpen = false"
        >
          <div class="relative w-full max-w-sm transform overflow-hidden rounded-3xl border border-white/10 bg-slate-900 p-8 text-center shadow-2xl transition-all">
            <div class="mx-auto mb-5 grid size-16 place-items-center rounded-2xl bg-brand/10 text-brand">
              <svg class="size-8 animate-pulse" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="1.75">
                <path stroke-linecap="round" stroke-linejoin="round" d="M11.48 3.499c.198-.39.754-.39.952 0l2.253 4.433 4.801.737c.427.065.597.608.283.923l-3.486 3.402.83 4.793c.074.428-.37.75-.75.55l-4.298-2.26-4.298 2.26c-.38.2-.824-.122-.75-.55l.83-4.793-3.486-3.402c-.314-.315-.144-.858.283-.923l4.801-.737 2.253-4.433z" />
              </svg>
            </div>
            <h3 class="text-xl font-extrabold text-white">{{ modalTitle }}</h3>
            <p v-if="modalType !== 'loggedIn'" class="mt-1 text-xs font-bold uppercase tracking-wider text-amber-400">Coming Soon</p>
            <p class="mt-4 text-sm leading-6 text-slate-300">
              {{ modalBody }}
            </p>
            <div class="mt-7 space-y-2">
              <RouterLink 
                v-if="modalType === 'loggedIn'"
                to="/dashboard"
                class="block w-full rounded-2xl bg-brand py-3 text-sm font-bold text-white shadow-lg shadow-brand/20 transition-all hover:bg-brand/90"
                @click="modalOpen = false"
              >
                Go to Dashboard
              </RouterLink>
              <button 
                type="button" 
                class="w-full rounded-2xl bg-slate-800 py-3 text-sm font-bold text-slate-200 transition-all hover:bg-slate-700"
                @click="modalOpen = false"
              >
                {{ modalType === 'loggedIn' ? 'Close' : 'OK' }}
              </button>
            </div>
          </div>
        </div>
      </Transition>
    </Teleport>
  </PublicLayout>
</template>

<script setup>
import { ref, computed, h } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useStore } from 'vuex'
import PublicLayout from '../../components/layout/PublicLayout.vue'
import { t } from '../../utils/i18n'

const route = useRoute()
const router = useRouter()
const store = useStore()
const pageKey = computed(() => route.meta.pageKey)
const page = computed(() => t(`pages.${pageKey.value}`) || {})
const user = computed(() => store.state.auth.user)

// Help Center state
const helpSearchQuery = ref('')
const helpSelectedCategory = ref('All')
const expandedHelpArticles = ref([])

const helpCategories = [
  'All',
  'Getting Started',
  'Resume Builder',
  'Account & Security'
]

const helpArticles = [
  { 
    category: 'Getting Started', 
    icon: '⚡',
    title: 'How to create a free account', 
    content: 'Click the "Sign up" button on the top right corner of the landing page, enter your name, email, and password, and click submit. You will receive an email verification link to activate your workspace.'
  },
  { 
    category: 'Getting Started', 
    icon: '⚡',
    title: 'Navigating the dashboard', 
    content: 'Once logged in, you will be redirected to the main dashboard. Here you can see your list of resumes, active credits, and start building new resumes or practicing interview preparation questions.'
  },
  { 
    category: 'Resume Builder', 
    icon: '📄',
    title: 'How to build your first resume', 
    content: 'From the dashboard, click "Create New" or "Build Resume". Fill in your contact info, work experience, education, skills, and summary. The builder saves your draft automatically.'
  },
  { 
    category: 'Resume Builder', 
    icon: '📄',
    title: 'Exporting/Downloading to PDF', 
    content: 'When you are satisfied with your resume draft, click the "Print" or "Download PDF" button in the editor. This opens the print preview window allowing you to save the document as a high-fidelity PDF.'
  },
  { 
    category: 'Resume Builder', 
    icon: '🤖',
    title: 'How does AI Resume Optimization work?', 
    content: 'In the editor, click "Optimize with AI". Select a target job title and input the job description. Our AI will analyze your resume against the description, provide an ATS score, and suggest tone-specific line enhancements.'
  },
  { 
    category: 'Account & Security', 
    icon: '🔒',
    title: 'How to reset your password', 
    content: 'If you forgot your password, go to the Login page and click "Forgot Password?". Enter your email address to receive a secure password reset link.'
  },
  { 
    category: 'Account & Security', 
    icon: '🔒',
    title: 'Managing credit balance', 
    content: 'AI enhancements require credits. You can check your remaining credit balance in the settings page. For top-ups, visit the Billing section under Settings.'
  }
]

const filteredHelpArticles = computed(() => {
  return helpArticles.filter(art => {
    const matchesCat = helpSelectedCategory.value === 'All' || art.category === helpSelectedCategory.value
    const matchesSearch = helpSearchQuery.value === '' || 
      art.title.toLowerCase().includes(helpSearchQuery.value.toLowerCase()) ||
      art.content.toLowerCase().includes(helpSearchQuery.value.toLowerCase()) ||
      art.category.toLowerCase().includes(helpSearchQuery.value.toLowerCase())
    return matchesCat && matchesSearch
  })
})

const toggleHelpArticle = (title) => {
  if (expandedHelpArticles.value.includes(title)) {
    expandedHelpArticles.value = expandedHelpArticles.value.filter(t => t !== title)
  } else {
    expandedHelpArticles.value.push(title)
  }
}

// FAQ toggle indices
const openFaqs = ref([0])
const toggleFaq = (index) => {
  if (openFaqs.value.includes(index)) {
    openFaqs.value = openFaqs.value.filter(i => i !== index)
  } else {
    openFaqs.value.push(index)
  }
}

// FAQ search & category states
const faqSearchQuery = ref('')
const faqSelectedCategory = ref('All')

const faqCategories = [
  'All',
  'General',
  'Features',
  'Account'
]

const faqArticles = computed(() => {
  const rawSections = page.value.sections || []
  return rawSections.map((sec, idx) => {
    let category = 'General'
    const headingText = sec.heading.toLowerCase()
    if (headingText.includes('free') || headingText.includes('pricing') || headingText.includes('plan')) {
      category = 'General'
    } else if (headingText.includes('download') || headingText.includes('pdf') || headingText.includes('ai') || headingText.includes('feature')) {
      category = 'Features'
    } else if (headingText.includes('delete') || headingText.includes('account') || headingText.includes('password')) {
      category = 'Account'
    }
    return {
      index: idx,
      heading: sec.heading,
      body: sec.body,
      category
    }
  })
})

const filteredFaqs = computed(() => {
  return faqArticles.value.filter(faq => {
    const matchesCat = faqSelectedCategory.value === 'All' || faq.category === faqSelectedCategory.value
    const matchesSearch = faqSearchQuery.value === '' ||
      faq.heading.toLowerCase().includes(faqSearchQuery.value.toLowerCase()) ||
      faq.body.toLowerCase().includes(faqSearchQuery.value.toLowerCase())
    return matchesCat && matchesSearch
  })
})

// Customer Support interactive state
const supportCategory = ref('billing')
const supportMessage = ref('')
const supportSubject = ref('')
const supportMethod = ref('email')

const supportCategories = [
  { value: 'billing', label: 'Billing & Credits' },
  { value: 'account', label: 'Account & Security' },
  { value: 'editor', label: 'Resume Editor' },
  { value: 'other', label: 'Other Inquiries' }
]

const submitSupportTicket = () => {
  const emailAddress = 'ajitaniket956556@gmail.com'
  const phoneNumber = '916284424697'
  
  const categoryLabel = supportCategories.find(c => c.value === supportCategory.value)?.label || 'General'
  const subjectText = supportSubject.value.trim() || `${categoryLabel} Inquiry`
  const formattedBody = `CareerAI Support Ticket\n---------------------\nCategory: ${categoryLabel}\nSubject: ${subjectText}\n\nMessage:\n${supportMessage.value.trim()}`
  
  if (supportMethod.value === 'whatsapp') {
    const waText = encodeURIComponent(`*CareerAI Support Ticket*\n*Category:* ${categoryLabel}\n*Subject:* ${subjectText}\n\n*Message:*\n${supportMessage.value.trim()}`)
    window.open(`https://wa.me/${phoneNumber}?text=${waText}`, '_blank')
  } else {
    const mailtoSubject = encodeURIComponent(`[CareerAI Support] ${subjectText}`)
    const mailtoBody = encodeURIComponent(formattedBody)
    window.location.href = `mailto:${emailAddress}?subject=${mailtoSubject}&body=${mailtoBody}`
  }
}

// Legal sidebar active section and search filter
const activeSectionIndex = ref(0)
const legalSearchQuery = ref('')

const filteredLegalSections = computed(() => {
  if (!page.value || !page.value.sections) return []
  return page.value.sections.map((sec, idx) => ({ ...sec, originalIndex: idx })).filter(sec => {
    if (!legalSearchQuery.value) return true
    const query = legalSearchQuery.value.toLowerCase()
    return sec.heading.toLowerCase().includes(query) || 
           (sec.body && sec.body.toLowerCase().includes(query)) ||
           (sec.items && sec.items.some(item => item.toLowerCase().includes(query)))
  })
})

// Coming soon modal
const modalOpen = ref(false)
const modalTitle = ref('')
const modalBody = ref('We are currently preparing this section. Stay tuned for career insights and platform updates!')
const modalType = ref('comingSoon')

const openComingSoonModal = (title) => {
  modalType.value = 'comingSoon'
  modalTitle.value = title
  modalBody.value = 'We are currently preparing this section. Stay tuned for career insights and platform updates!'
  modalOpen.value = true
}

const handleCtaClick = (to) => {
  if (to === '/signup' && user.value) {
    modalType.value = 'loggedIn'
    modalTitle.value = 'Already Logged In'
    modalBody.value = 'You are already signed in to your account. Feel free to explore the features from your dashboard.'
    modalOpen.value = true
  } else {
    router.push(to)
  }
}

// Icon mapper for general page sections
const getIconComponent = (heading = '') => {
  const hText = heading.toLowerCase()
  
  // Return h-render function for relevant icon svg
  return {
    render() {
      if (hText.includes('mission') || hText.includes('why') || hText.includes('role')) {
        return h('svg', { fill: 'none', viewBox: '0 0 24 24', stroke: 'currentColor', 'stroke-width': '2' }, [
          h('path', { 'stroke-linecap': 'round', 'stroke-linejoin': 'round', d: 'M13 10V3L4 14h7v7l9-11h-7z' })
        ])
      }
      if (hText.includes('believe') || hText.includes('value') || hText.includes('times')) {
        return h('svg', { fill: 'none', viewBox: '0 0 24 24', stroke: 'currentColor', 'stroke-width': '2' }, [
          h('path', { 'stroke-linecap': 'round', 'stroke-linejoin': 'round', d: 'M9.663 17h4.673M12 3v1m6.364 1.636l-.707.707M21 12h-1M4 12H3m3.343-5.657l-.707-.707m2.828 9.9a5 5 0 117.072 0l-.548.547A3.374 3.374 0 0014 18.469V19a2 2 0 11-4 0v-.531c0-.895-.356-1.754-.988-2.386l-.548-.547z' })
        ])
      }
      if (hText.includes('today') || hText.includes('started') || hText.includes('history')) {
        return h('svg', { fill: 'none', viewBox: '0 0 24 24', stroke: 'currentColor', 'stroke-width': '2' }, [
          h('path', { 'stroke-linecap': 'round', 'stroke-linejoin': 'round', d: 'M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z' })
        ])
      }
      if (hText.includes('inquir') || hText.includes('email') || hText.includes('apply')) {
        return h('svg', { fill: 'none', viewBox: '0 0 24 24', stroke: 'currentColor', 'stroke-width': '2' }, [
          h('path', { 'stroke-linecap': 'round', 'stroke-linejoin': 'round', d: 'M3 8l7.89 5.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z' })
        ])
      }
      if (hText.includes('support') || hText.includes('write')) {
        return h('svg', { fill: 'none', viewBox: '0 0 24 24', stroke: 'currentColor', 'stroke-width': '2' }, [
          h('path', { 'stroke-linecap': 'round', 'stroke-linejoin': 'round', d: 'M18.364 5.636l-3.536 3.536m0 5.656l3.536 3.536M9.172 9.172L5.636 5.636m3.536 9.192l-3.536 3.536M21 12a9 9 0 11-18 0 9 9 0 0118 0zm-5 0a4 4 0 11-8 0 4 4 0 018 0z' })
        ])
      }
      return h('svg', { fill: 'none', viewBox: '0 0 24 24', stroke: 'currentColor', 'stroke-width': '2' }, [
        h('path', { 'stroke-linecap': 'round', 'stroke-linejoin': 'round', d: 'M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z' })
      ])
    }
  }
}

// ==========================================
// INTERACTIVE FEATURES DEMO DATA & LOGIC
// ==========================================

// Tabs definitions
const featureTabs = [
  { 
    id: 'builder', 
    label: 'Resume Builder', 
    icon: {
      render() {
        return h('svg', { fill: 'none', viewBox: '0 0 24 24', stroke: 'currentColor', 'stroke-width': '2' }, [
          h('path', { 'stroke-linecap': 'round', 'stroke-linejoin': 'round', d: 'M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z' })
        ])
      }
    }
  },
  { 
    id: 'ai', 
    label: 'ATS Match Checker', 
    icon: {
      render() {
        return h('svg', { fill: 'none', viewBox: '0 0 24 24', stroke: 'currentColor', 'stroke-width': '2' }, [
          h('path', { 'stroke-linecap': 'round', 'stroke-linejoin': 'round', d: 'M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z' })
        ])
      }
    }
  },
  { 
    id: 'interview', 
    label: 'Interview Prep Hub', 
    icon: {
      render() {
        return h('svg', { fill: 'none', viewBox: '0 0 24 24', stroke: 'currentColor', 'stroke-width': '2' }, [
          h('path', { 'stroke-linecap': 'round', 'stroke-linejoin': 'round', d: 'M8 12h.01M12 12h.01M16 12h.01M21 12c0 4.418-4.03 8-9 8a9.863 9.863 0 01-4.255-.949L3 20l1.395-3.72C3.512 15.042 3 13.574 3 12c0-4.418 4.03-8 9-8s9 3.582 9 8z' })
        ])
      }
    }
  },
  { 
    id: 'sync', 
    label: 'Profile Auto-fill', 
    icon: {
      render() {
        return h('svg', { fill: 'none', viewBox: '0 0 24 24', stroke: 'currentColor', 'stroke-width': '2' }, [
          h('path', { 'stroke-linecap': 'round', 'stroke-linejoin': 'round', d: 'M4 4v5h.582m15.356 2A8.001 8.001 0 1121.21 8H18.23' })
        ])
      }
    }
  }
]

const activeFeatureTab = ref('builder')

// 1. Resume Builder State
const builderColor = ref('purple')
const builderFont = ref('font-sans')
const builderShowEducation = ref(true)
const builderShowProjects = ref(true)
const builderShowSkills = ref(true)

const themeColors = [
  { value: 'purple', colorCode: '#6d4aff', bgCode: '#6d4aff12' },
  { value: 'blue', colorCode: '#3b82f6', bgCode: '#3b82f612' },
  { value: 'emerald', colorCode: '#10b981', bgCode: '#10b98112' },
  { value: 'rose', colorCode: '#f43f5e', bgCode: '#f43f5e12' }
]

const typographyFonts = [
  { value: 'font-sans', label: 'Inter' },
  { value: 'font-serif', label: 'Merriweather' },
  { value: 'font-mono', label: 'Fira Code' }
]

const activeColorCode = computed(() => {
  const matched = themeColors.find(c => c.value === builderColor.value)
  return matched ? matched.colorCode : '#6d4aff'
})

const activeColorBg = computed(() => {
  const matched = themeColors.find(c => c.value === builderColor.value)
  return matched ? matched.bgCode : '#6d4aff12'
})

// 2. ATS Match Checker State
const atsScanning = ref(false)
const atsProgress = ref(0)
const atsScore = ref(null)

const runAtsScanner = () => {
  if (atsScanning.value) return
  atsScanning.value = true
  atsProgress.value = 0
  atsScore.value = null
  
  const timer = setInterval(() => {
    atsProgress.value += 4
    if (atsProgress.value >= 100) {
      clearInterval(timer)
      atsScanning.value = false
      atsScore.value = 94
    }
  }, 50)
}

// 3. Interview Prep State
const selectedQuestion = ref(0)
const interviewAILoading = ref(false)

const mockQuestions = ref([
  { 
    title: 'Vue JS Virtual DOM', 
    difficulty: 'Medium',
    question: 'How does the Virtual DOM optimization work inside Vue 3 compared to direct DOM updates?',
    userAnswer: 'Vue 3 generates an in-memory Virtual DOM tree representation, calculates differences using a fast diffing algorithm, and patches only changed nodes to avoid heavy browser reflows.',
    aiScore: null,
    aiFeedback: ''
  },
  { 
    title: 'Database Indexing', 
    difficulty: 'Hard',
    question: 'Describe B-Tree indexes and why writing operations become slower when database indexing is heavy.',
    userAnswer: 'Indexes store pointers in a structured B-Tree format. While query operations accelerate, write operations (insert, update, delete) require recalculating tree nodes and balancing paths.',
    aiScore: null,
    aiFeedback: ''
  },
  { 
    title: 'State Propagation', 
    difficulty: 'Medium',
    question: 'Explain state propagation in large apps. When would you choose Pinia over prop drilling?',
    userAnswer: 'Prop drilling pushes state through multiple nested components. Pinia centralizes state globally, allowing any component to subscribe directly and avoid intermediate props.',
    aiScore: null,
    aiFeedback: ''
  }
])

const changeQuestion = (index) => {
  selectedQuestion.value = index
}

const runInterviewAI = () => {
  if (interviewAILoading.value) return
  interviewAILoading.value = true
  
  setTimeout(() => {
    interviewAILoading.value = false
    const q = mockQuestions.value[selectedQuestion.value]
    if (selectedQuestion.value === 0) {
      q.aiScore = 95
      q.aiFeedback = 'Excellent answer! You correctly identified memory trees, diffing calculations, and browser reflow savings. For extra points, mention Vue 3 compiler-informed flags (PatchFlags).'
    } else if (selectedQuestion.value === 1) {
      q.aiScore = 88
      q.aiFeedback = 'Very solid explanation. You correctly detailed B-Tree write bottlenecks and node restructuring steps. Mentioning indexes taking up disk space would complete the answer.'
    } else {
      q.aiScore = 92
      q.aiFeedback = 'Great conceptual clarity. Pinia state access is clean and avoids prop-drilling boilerplate. Good comparison of scale and maintenance overhead.'
    }
  }, 1000)
}

// 4. Profile Sync State
const syncActive = ref(false)
const runAutofillSync = () => {
  syncActive.value = true
}

// 5. Advanced Feature Set Grid Data
const advancedFeatures = [
  { 
    title: 'Interactive Resume Customizer', 
    description: 'Adjust layouts, toggle section visibilities, edit margins, and swap between professional ATS-optimized serif or sans fonts.',
    badge: 'Builder Core',
    status: 'Operational',
    icon: {
      render() {
        return h('svg', { fill: 'none', viewBox: '0 0 24 24', stroke: 'currentColor', 'stroke-width': '2' }, [
          h('path', { 'stroke-linecap': 'round', 'stroke-linejoin': 'round', d: 'M12 6V4m0 2a2 2 0 100 4m0-4a2 2 0 110 4m-6 8a2 2 0 100-4m0 4a2 2 0 110-4m0 4v2m0-6V4m6 6v10m6-2a2 2 0 100-4m0 4a2 2 0 110-4m0 4v2m0-6V4' })
        ])
      }
    }
  },
  { 
    title: 'Automated Profile Sync', 
    description: 'Keep your professional biography, contacts, education, and career achievements up-to-date in one central source of truth.',
    badge: 'Core Sync',
    status: 'Operational',
    icon: {
      render() {
        return h('svg', { fill: 'none', viewBox: '0 0 24 24', stroke: 'currentColor', 'stroke-width': '2' }, [
          h('path', { 'stroke-linecap': 'round', 'stroke-linejoin': 'round', d: 'M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z' })
        ])
      }
    }
  },
  { 
    title: 'ATS Scanner (Coming Soon)', 
    description: 'Analyze resume sections against specific job descriptions. Spot missing keywords and fix formatting before submitting.',
    badge: 'AI Utility',
    status: 'In Pipeline',
    icon: {
      render() {
        return h('svg', { fill: 'none', viewBox: '0 0 24 24', stroke: 'currentColor', 'stroke-width': '2' }, [
          h('path', { 'stroke-linecap': 'round', 'stroke-linejoin': 'round', d: 'M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z' })
        ])
      }
    }
  },
  { 
    title: 'Mock Interview Sandbox', 
    description: 'Complete HR and technical mock interviews tailored by topics. Receive real-time assessment scores and detailed study tips.',
    badge: 'Career Hub',
    status: 'Operational',
    icon: {
      render() {
        return h('svg', { fill: 'none', viewBox: '0 0 24 24', stroke: 'currentColor', 'stroke-width': '2' }, [
          h('path', { 'stroke-linecap': 'round', 'stroke-linejoin': 'round', d: 'M17 8h2a2 2 0 012 2v6a2 2 0 01-2 2h-2v4l-4-4H9a1.994 1.994 0 01-1.414-.586m0 0L11 14h4a2 2 0 002-2V6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2v4l.586-.586z' })
        ])
      }
    }
  },
  { 
    title: 'One-Click PDF Generator', 
    description: 'Export highly compatible, standard-format PDFs instantly. No watermarks, no formatting shifts, and no complex settings.',
    badge: 'Export Engine',
    status: 'Operational',
    icon: {
      render() {
        return h('svg', { fill: 'none', viewBox: '0 0 24 24', stroke: 'currentColor', 'stroke-width': '2' }, [
          h('path', { 'stroke-linecap': 'round', 'stroke-linejoin': 'round', d: 'M12 10v6m0 0l-3-3m3 3l3-3m2 8H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z' })
        ])
      }
    }
  },
  { 
    title: 'Version Control & Cloning', 
    description: 'Duplicate and customize target versions of any resume. Keep separate drafts saved for different corporate roles.',
    badge: 'Draft Management',
    status: 'Operational',
    icon: {
      render() {
        return h('svg', { fill: 'none', viewBox: '0 0 24 24', stroke: 'currentColor', 'stroke-width': '2' }, [
          h('path', { 'stroke-linecap': 'round', 'stroke-linejoin': 'round', d: 'M8 7v8a2 2 0 002 2h6M8 7V5a2 2 0 012-2h4.586a1 1 0 01.707.293l4.414 4.414a1 1 0 01.293.707V15a2 2 0 01-2 2h-2M8 7H6a2 2 0 00-2 2v10a2 2 0 002 2h8a2 2 0 002-2v-2' })
        ])
      }
    }
  }
]

// ==========================================
// INTERACTIVE ABOUT PAGE DATA & LOGIC
// ==========================================
const selectedMilestone = ref('ai')
const milestones = [
  { key: 'ai', year: '2026', title: 'AI Breakthrough', tag: 'Intelligence Era', desc: 'Integrated our advanced AI copilot, enabling real-time resume checklist audits, ATS keyword parsing, cover letter generation, and direct resume tailoring to target job descriptions. Resumes tailored with our AI saw a 3x higher interview callback rate.' },
  { key: 'ecosystem', year: '2027+', title: 'Ecosystem Phase', tag: 'Upcoming', desc: 'Expanding CareerAI into a holistic career dashboard. Building personalized learning roadmaps, portfolio generators, job application trackers, and AI-simulated mock interview prep sandboxes to guide candidates from preparation to offer letter.' }
]

const milestoneStats = computed(() => {
  if (selectedMilestone.value === 'ai') {
    return [
      { label: 'AI Operations Run', val: '240k+' },
      { label: 'ATS Target Met', val: '94%' },
      { label: 'Time Saved / Resume', val: '90%' }
    ]
  }
  return [
    { label: 'Ecosystem Modules', val: '5' },
    { label: 'AI Coaching Hours', val: '24/7' },
    { label: 'API Partner Syncs', val: '12' }
  ]
})

const selectedValue = ref('clarity')
const values = [
  { key: 'clarity', title: 'Clarity First', subtitle: 'Structure over styling clutter', icon: '✨' },
  { key: 'time', title: 'Respect Your Time', subtitle: 'Format and tailor in minutes', icon: '⚡' },
  { key: 'data', title: 'Data-Driven Confidence', subtitle: 'Impact-driven phrasing with AI', icon: '📊' }
]

const clarityToggle = ref('before')
const tailoredCount = ref(3)
const hoursSaved = computed(() => tailoredCount.value * 3)

const inputBullet = ref('Led team of 5 and coded the backend.')
const outputBullet = ref('')
const isRewriting = ref(false)

const rewriteBullet = () => {
  isRewriting.value = true
  setTimeout(() => {
    if (engineTone.value === 'technical') {
      outputBullet.value = 'Architected a Ruby on Rails API backend with optimized indexing, handling 1.2M daily HTTP requests and reducing server response time to <120ms.'
    } else if (engineTone.value === 'creative') {
      outputBullet.value = 'Spearheaded the technical rebirth of our backend infrastructure, guiding a 5-engineer team to transform a legacy architecture into a high-performance system.'
    } else {
      outputBullet.value = 'Directed 5 cross-functional software engineers to design, build, and deploy a scalable Rails API, processing 1.2M daily requests and reducing overall server latency by 42%.'
    }
    isRewriting.value = false
  }, 1200)
}

const resetBullet = () => {
  outputBullet.value = ''
}

const engineTone = ref('executive')
const engineLength = ref(80)
const engineKeywords = ref(75)

const engineAtsScore = computed(() => {
  let score = 70
  if (engineTone.value === 'executive') score += 12
  if (engineTone.value === 'technical') score += 8
  score += Math.round((engineKeywords.value - 30) * 0.25)
  return Math.min(score, 100)
})

const engineImpactScore = computed(() => {
  let score = 65
  if (engineTone.value === 'executive') score += 15
  if (engineTone.value === 'creative') score += 10
  score += Math.round((engineLength.value - 50) * 0.3)
  return Math.min(score, 100)
})

const engineReadabilityScore = computed(() => {
  let score = 95
  score -= Math.round((engineLength.value - 50) * 0.2)
  if (engineTone.value === 'technical') score -= 5
  return Math.max(score, 60)
})
</script>

<style scoped>
.animate-fade-in {
  animation: fadeIn 0.4s ease-out forwards;
}

@keyframes fadeIn {
  from {
    opacity: 0;
    transform: translateY(6px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}
</style>
