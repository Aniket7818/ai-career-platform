<template>
  <form
    class="flex flex-col lg:flex-row min-h-screen lg:h-screen w-full lg:overflow-hidden bg-slate-50"
    :class="{ 'has-bottom-nav': isMobile }"
    @submit.prevent="$emit('submit')"
  >
    <!-- ═══════════════════════════════════════════════════════════════
         LEFT COLUMN: Sidebar & Customization
    ═══════════════════════════════════════════════════════════════ -->
    <aside 
      v-if="!isMobile"
      class="left-sidebar relative flex shrink-0 flex-col border-b lg:border-b-0 lg:border-r border-slate-200 bg-white transition-all duration-300 ease-in-out"
      :class="leftSidebarCollapsed ? '!w-0 !border-r-0 overflow-hidden opacity-0' : ''"
      :style="{ '--lg-width': leftSidebarCollapsed ? '0px' : `${leftWidth}px` }"
    >
      <div class="flex items-center gap-3 border-b border-slate-200 p-5 shrink-0">
        <RouterLink to="/resumes" class="inline-flex items-center gap-2 text-sm font-semibold text-slate-500 transition hover:text-ink">
          <svg class="size-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M19 12H5M12 19l-7-7 7-7"/></svg>
          {{ t('nav.dashboard') }}
        </RouterLink>
      </div>
      <div class="lg:flex-1 lg:overflow-y-auto custom-scrollbar">
        <!-- Sidebar Accordions (Phase 5) -->
        <div class="flex flex-col">
          <!-- Template Section -->
          <div class="border-b border-slate-100">
            <button type="button" class="w-full flex items-center justify-between px-5 py-4 text-left transition hover:bg-slate-50/50" @click="sidebarState.template = !sidebarState.template">
              <span class="text-xs font-bold uppercase tracking-wider text-slate-500">Template</span>
              <svg class="size-4 text-slate-400 transition-transform duration-200" :class="sidebarState.template ? 'rotate-180' : ''" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M6 9l6 6 6-6"/></svg>
            </button>
            <Transition name="collapse">
              <div v-if="sidebarState.template" class="px-5 pb-5">
                <TemplatePicker v-model="model.template_id" :content="model.content" />
              </div>
            </Transition>
          </div>

          <!-- Appearance Section -->
          <div class="border-b border-slate-100">
            <button type="button" class="w-full flex items-center justify-between px-5 py-4 text-left transition hover:bg-slate-50/50" @click="sidebarState.appearance = !sidebarState.appearance">
              <span class="text-xs font-bold uppercase tracking-wider text-slate-500">Settings</span>
              <svg class="size-4 text-slate-400 transition-transform duration-200" :class="sidebarState.appearance ? 'rotate-180' : ''" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M6 9l6 6 6-6"/></svg>
            </button>
            <Transition name="collapse">
              <div v-if="sidebarState.appearance" class="px-5 pb-5">
                <AppearancePanel v-model="model.content.appearance" />
              </div>
            </Transition>
          </div>

          <!-- Customize Section -->
          <div class="border-b border-slate-100">
            <button type="button" class="w-full flex items-center justify-between px-5 py-4 text-left transition hover:bg-slate-50/50" @click="sidebarState.customize = !sidebarState.customize">
              <span class="text-xs font-bold uppercase tracking-wider text-slate-500">Reorder & Layout</span>
              <svg class="size-4 text-slate-400 transition-transform duration-200" :class="sidebarState.customize ? 'rotate-180' : ''" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M6 9l6 6 6-6"/></svg>
            </button>
            <Transition name="collapse">
              <div v-if="sidebarState.customize" class="px-5 pb-5">
                <CustomizePanel v-model:order="model.content.sectionOrder" v-model:visibility="model.content.sectionVisibility" />
              </div>
            </Transition>
          </div>
        </div>
      </div>
      <!-- Resizer Handle -->
      <div 
        v-if="!leftSidebarCollapsed"
        class="hidden lg:block absolute right-0 top-0 h-full w-2 cursor-col-resize z-30 group"
        @mousedown.prevent="startResizeLeft"
      >
        <div class="w-[2px] h-full bg-slate-200 group-hover:bg-brand group-active:bg-brand mx-auto transition-colors duration-200"></div>
      </div>
    </aside>

    <!-- ═══════════════════════════════════════════════════════════════
         MIDDLE COLUMN: Form sections
    ═══════════════════════════════════════════════════════════════ -->
    <main v-if="showResumeEditor" class="flex-1 lg:overflow-y-auto">
      <div class="mx-auto max-w-3xl space-y-6 p-5 sm:p-8">
        <!-- ─── Minimal Premium Header (Phases 2 & 6) ─── -->
        <div class="mb-8 flex flex-col gap-6 md:flex-row md:items-center md:justify-between border-b border-slate-100 pb-6">
          <div class="flex items-center gap-3">
            <!-- Sidebar Toggle Button for Desktop -->
            <button 
              v-if="!isMobile"
              type="button" 
              class="p-2 text-slate-400 hover:text-slate-700 hover:bg-slate-100 rounded-lg transition-colors duration-200 shrink-0"
              @click="leftSidebarCollapsed = !leftSidebarCollapsed"
              :title="leftSidebarCollapsed ? 'Expand Sidebar' : 'Collapse Sidebar'"
            >
              <svg class="size-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <rect x="3" y="3" width="18" height="18" rx="2" />
                <path d="M9 3v18" :class="leftSidebarCollapsed ? 'translate-x-[-3px]' : ''" class="transition-transform duration-200" />
              </svg>
            </button>
            <div>
              <h1 class="text-2xl font-bold tracking-tight text-slate-900">
                <template v-if="userName">{{ greeting }}, <span class="text-brand">{{ userName }} 👋</span></template>
                <template v-else>{{ isNew ? t('resumes.new') : t('resumes.edit') }}</template>
              </h1>
              <p class="text-xs text-slate-500 mt-1">Let’s craft a world-class resume today.</p>
            </div>
          </div>

          <!-- Header Stats (Stripe style) -->
          <div class="flex items-center gap-5 text-[11px] self-start md:self-auto">
            <div class="flex flex-col">
              <span class="font-bold uppercase tracking-wider text-slate-400 text-[9px] mb-0.5">Resume Health</span>
              <span class="font-extrabold" :class="'text-' + healthColor + '-600'">{{ healthScore }}%</span>
            </div>
            <div class="h-6 w-px bg-slate-200"></div>
            <div class="flex flex-col">
              <span class="font-bold uppercase tracking-wider text-slate-400 text-[9px] mb-0.5">ATS Score</span>
              <span class="font-extrabold text-slate-800">{{ atsAnalysis.score }}</span>
            </div>
            <div class="h-6 w-px bg-slate-200"></div>
            <div class="flex flex-col">
              <span class="font-bold uppercase tracking-wider text-slate-400 text-[9px] mb-0.5">Last Saved</span>
              <span class="font-extrabold text-slate-800">
                <template v-if="saveStatus === 'saved'">Just now</template>
                <template v-else-if="saveStatus === 'unsaved'">Unsaved changes</template>
                <template v-else>Saving...</template>
              </span>
            </div>
            <div class="h-6 w-px bg-slate-200 hidden sm:block"></div>
            <div class="flex flex-col hidden sm:flex">
              <span class="font-bold uppercase tracking-wider text-slate-400 text-[9px] mb-0.5">Completion</span>
              <span class="font-extrabold text-slate-800">{{ completionScore }}%</span>
            </div>
          </div>
        </div>

        <!-- Resume meta: title + status + target role -->
        <div class="rounded-2xl border border-slate-100 bg-white p-5 shadow-panel sm:p-6 space-y-4">
          <div class="grid gap-4 md:grid-cols-2">
            <div>
              <label>{{ t('resumes.titleLabel') }}</label>
              <input :value="model.title" required @input="update('title', $event.target.value)" />
            </div>
            <div>
              <label>{{ t('resumes.status') }}</label>
              <select :value="model.status" @change="update('status', $event.target.value)">
                <option v-for="status in statuses" :key="status" :value="status">{{ status }}</option>
              </select>
            </div>
          </div>

          <!-- Target Role Selector -->
          <TargetRoleSelector v-model="targetRole" />

          <!-- Fill from profile CTA -->
          <div class="flex flex-wrap items-center justify-between gap-3 rounded-xl border border-brand/20 bg-brand/5 p-4">
            <div>
              <p class="text-sm font-semibold text-ink">{{ t('resumes.fillFromProfile') }}</p>
              <p class="text-xs text-slate-500">{{ t('resumes.fillFromProfileHint') }}</p>
            </div>
            <button
              type="button"
              class="rounded-xl border border-brand/30 bg-white px-4 py-2 text-sm font-semibold text-brand transition hover:bg-brand/10"
              @click="$emit('fill-from-profile')"
            >
              {{ t('resumes.fillFromProfileAction') }}
            </button>
          </div>
        </div>

        <div
          v-for="section in ALL_SECTIONS"
          :key="section.key"
          :id="`section-${section.key}`"
          class="overflow-hidden rounded-2xl transition-all duration-300"
          :class="openSections[section.key] ? 'bg-white shadow-panel ring-1 ring-black/5' : 'bg-transparent hover:bg-white/60'"
        >
          <!-- Section header (click to toggle) -->
          <button
            type="button"
            class="flex w-full items-center justify-between gap-3 p-5 sm:p-6 text-left transition hover:bg-slate-50/70"
            @click="toggleSection(section.key)"
          >
              <div class="flex items-center gap-3">
                <span class="flex h-7 w-7 shrink-0 items-center justify-center rounded-lg bg-brand/10 text-brand">
                  <span v-html="section.icon" class="size-4 [&>svg]:size-full" />
                </span>
                <div class="flex flex-col text-left">
                  <span class="text-sm font-bold text-ink flex items-center">
                    {{ section.label }}
                    <span v-if="getSectionCount(section.key) > 0" class="ml-2 rounded bg-slate-100 px-1.5 py-0.5 text-[10px] font-semibold text-slate-500">{{ getSectionCount(section.key) }}</span>
                  </span>
                  <!-- Show hint if section is empty and expanded -->
                  <span v-if="openSections[section.key] && getSectionCount(section.key) === 0 && section.hint" class="text-[11px] text-slate-500 mt-0.5 max-w-[240px] leading-snug animate-fade-in">
                    {{ section.hint }}
                  </span>
                </div>
              </div>
              <div class="flex items-center gap-3">
                <template v-if="sectionValidations[section.key]">
                <!-- Complete Indicator -->
                <span 
                  v-if="sectionValidations[section.key].status === 'COMPLETE'" 
                  class="text-emerald-500 text-xs font-bold"
                  title="All required fields complete"
                >✓</span>
                
                <!-- Optimization Opportunity Indicator -->
                <span 
                  v-else-if="sectionValidations[section.key].status === 'OPTIMIZATION'" 
                  class="text-brand text-xs font-bold cursor-help"
                  :title="'Optimization suggestions:\n- ' + sectionValidations[section.key].suggestions.join('\n- ')"
                >💡</span>
                
                <!-- Incomplete Indicator -->
                <span 
                  v-else-if="sectionValidations[section.key].status === 'INCOMPLETE'" 
                  class="text-amber-500 text-xs font-bold cursor-help"
                  :title="'Missing required fields:\n- ' + sectionValidations[section.key].missing.join('\n- ')"
                >⚠</span>
              </template>
              <svg
                class="size-4 text-slate-400 transition-transform"
                :class="openSections[section.key] ? 'rotate-180' : ''"
                viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"
              >
                <path d="M6 9l6 6 6-6"/>
              </svg>
            </div>
          </button>

          <!-- Section body -->
          <Transition name="collapse">
            <div v-if="openSections[section.key]" class="p-5 sm:p-6 sm:pt-2">
              <!-- Personal -->
              <template v-if="section.key === 'personal'">
                <div class="grid gap-4 md:grid-cols-2">
                  <div class="md:col-span-2"><label>{{ t('builder.fullName') }}</label><input v-model="model.content.personal.fullName" /></div>
                  <div class="md:col-span-2"><label>{{ t('builder.headline') }}</label><input v-model="model.content.personal.headline" /></div>
                  <div class="md:col-span-2">
                    <label>{{ t('builder.summaryLabel') }}</label>
                    <textarea v-model="model.content.personal.summary" rows="4" />
                    <div class="mt-2" v-if="model.id">
                      <AiGenerationWidget 
                        :resume-id="model.id" 
                        feature="resume_summary" 
                        title="AI Summary Writer" 
                        :credits-required="3" 
                        @apply="(val) => model.content.personal.summary = val" 
                      />
                    </div>
                    <div class="mt-2 text-xs text-slate-500 italic" v-else>
                      Save your resume first to unlock AI features.
                    </div>
                  </div>
                  <div>
                    <label>{{ t('profile.email') }}</label>
                    <input v-model="model.content.personal.email" type="email" placeholder="email@example.com" class="peer" />
                    <span class="mt-1 hidden text-xs text-red-500 peer-invalid:block">Please enter a valid email.</span>
                  </div>
                  <div>
                    <label>{{ t('profile.phone') }}</label>
                    <input v-model="model.content.personal.phone" type="tel" pattern="^\+?[0-9\s\-\(\)]+$" placeholder="+1 234 567 8900" class="peer" />
                    <span class="mt-1 hidden text-xs text-red-500 peer-invalid:block">Please enter a valid phone number.</span>
                  </div>
                  <div><label>{{ t('profile.location') }}</label><input v-model="model.content.personal.location" /></div>
                  <div>
                    <label>{{ t('profile.portfolio') }}</label>
                    <input v-model="model.content.personal.portfolio" type="url" placeholder="https://..." class="peer" />
                    <span class="mt-1 hidden text-xs text-red-500 peer-invalid:block">Please enter a valid URL (https://...).</span>
                  </div>
                  <div>
                    <label>{{ t('profile.linkedin') }}</label>
                    <input v-model="model.content.personal.linkedin" type="url" placeholder="https://linkedin.com/in/..." class="peer" />
                    <span class="mt-1 hidden text-xs text-red-500 peer-invalid:block">Please enter a valid URL.</span>
                  </div>
                  <div>
                    <label>{{ t('profile.github') }}</label>
                    <input v-model="model.content.personal.github" type="url" placeholder="https://github.com/..." class="peer" />
                    <span class="mt-1 hidden text-xs text-red-500 peer-invalid:block">Please enter a valid URL.</span>
                  </div>
                </div>
              </template>

              <!-- Experience -->
              <template v-else-if="section.key === 'experience'">
                <ExperienceSection v-model="model.content.experiences" />
              </template>

              <!-- Education -->
              <template v-else-if="section.key === 'education'">
                <EducationSection v-model="model.content.educations" />
              </template>

              <!-- Projects -->
              <template v-else-if="section.key === 'projects'">
                <ProjectsSection v-model="model.content.projects" />
              </template>

              <!-- Skills -->
              <template v-else-if="section.key === 'skills'">
                <div>
                  <label>{{ t('builder.skillList') }}</label>
                  <textarea v-model="model.content.skills.skillList" rows="3" placeholder="e.g. JavaScript, Vue.js, Python, SQL, Docker..." />
                  <p class="mt-1 text-xs text-slate-400">Separate skills with commas for best ATS results.</p>
                </div>
              </template>

              <!-- Certifications -->
              <template v-else-if="section.key === 'certifications'">
                <CertificationsSection v-model="model.content.certifications" />
              </template>

              <!-- Languages -->
              <template v-else-if="section.key === 'languages'">
                <LanguagesSection v-model="model.content.languages" />
              </template>

              <!-- Achievements -->
              <template v-else-if="section.key === 'achievements'">
                <AchievementsSection v-model="model.content.achievements" />
              </template>

              <!-- Interests -->
              <template v-else-if="section.key === 'interests'">
                <InterestsSection v-model="model.content.interests" />
              </template>

              <!-- Social Links -->
              <template v-else-if="section.key === 'socialLinks'">
                <SocialLinksSection v-model="model.content.socialLinks" />
              </template>
            </div>
          </Transition>
        </div>

        <div class="flex items-center gap-3">
          <AppButton :loading="loading" @click="$emit('submit')">{{ t('resumes.save') }}</AppButton>
          <span class="text-xs text-slate-400 flex items-center gap-1">
            <template v-if="saveStatus === 'saving'">
              <svg class="size-3 animate-spin" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10" stroke-opacity="0.25"></circle><path d="M12 2v4M12 18v4M4.93 4.93l2.83 2.83M16.24 16.24l2.83 2.83M2 12h4M18 12h4M4.93 19.07l2.83-2.83M16.24 7.76l2.83-2.83"></path></svg>
              Saving...
            </template>
            <template v-else-if="saveStatus === 'saved'">
              <span class="text-emerald-500">✓</span> Saved just now
            </template>
            <template v-else-if="saveStatus === 'unsaved'">
              <span class="text-amber-500">⚠</span> Unsaved changes
            </template>
          </span>
        </div>
      </div>
    </main>

    <!-- ═══════════════════════════════════════════════════════════════
         RIGHT COLUMN: Live preview
    ═══════════════════════════════════════════════════════════════ -->
    <aside 
      v-if="!isMobile"
      class="right-sidebar relative flex shrink-0 flex-col border-t lg:border-t-0 lg:border-l border-slate-200 bg-slate-100/30"
      :style="{ '--lg-width': `${rightWidth}px` }"
    >
      <!-- Resizer Handle -->
      <div 
        class="hidden lg:block absolute left-0 top-0 h-full w-2 cursor-col-resize z-30 group"
        @mousedown.prevent="startResizeRight"
      >
        <div class="w-[2px] h-full bg-slate-200 group-hover:bg-brand group-active:bg-brand mx-auto transition-colors duration-200"></div>
      </div>
      <div class="flex items-center justify-between border-b border-slate-200/60 bg-white p-4">
        <div class="flex items-center gap-2">
          <h2 class="text-sm font-bold text-ink">{{ t('resumes.preview') }}</h2>
          <span class="rounded-full bg-emerald-500/10 px-2.5 py-0.5 text-[9px] font-bold uppercase tracking-wider text-emerald-600">
            {{ t('resumes.live') }}
          </span>
        </div>
        <div class="flex items-center gap-1.5">
          <!-- Desktop Toolbar (Priority 4 Overhaul) -->
          <div class="flex items-center gap-1 bg-white border border-slate-200/80 rounded-full p-1.5 shadow-[0_2px_8px_rgba(15,23,42,0.04)] backdrop-blur-sm">
            <button type="button" class="p-1.5 text-slate-500 hover:bg-slate-100 rounded-full transition-colors" @click="zoomOut" title="Zoom Out">
              <svg class="size-3.5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0zM8 10h6"/></svg>
            </button>
            <button type="button" class="text-[10px] font-bold text-slate-700 w-10 text-center select-none hover:bg-slate-100 rounded-full transition cursor-pointer" @click="previewZoom = 100" title="Reset to 100%">
              {{ Math.round(previewZoom) }}%
            </button>
            <button type="button" class="p-1.5 text-slate-500 hover:bg-slate-100 rounded-full transition-colors" @click="zoomIn" title="Zoom In">
              <svg class="size-3.5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0zM10 7v6m-3-3h6"/></svg>
            </button>
            <div class="w-px h-4 bg-slate-200 mx-0.5"></div>
            <button type="button" class="px-2 py-1 text-slate-500 hover:bg-slate-100 rounded-full transition text-[9px] font-bold uppercase tracking-wider flex items-center gap-0.5" @click="fitToWidth" title="Fit Width">
              <svg class="size-2.5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M4 12h16M4 12l4-4m-4 4l4 4m12-4l-4-4m4 4l-4 4"/></svg>
              Width
            </button>
            <button type="button" class="px-2 py-1 text-slate-500 hover:bg-slate-100 rounded-full transition text-[9px] font-bold uppercase tracking-wider flex items-center gap-0.5" @click="fitToPage" title="Fit Page">
              <svg class="size-2.5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M12 4v16M12 4l-4 4m4-4l4 4m-4 12l-4-4m4 4l-4-4"/></svg>
              Page
            </button>
            <div class="w-px h-4 bg-slate-200 mx-0.5"></div>
            <button type="button" class="p-1.5 text-slate-500 hover:bg-slate-100 rounded-full transition-colors" @click="showFullPreview = true" title="Fullscreen">
              <svg class="size-3.5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M8 3H5a2 2 0 00-2 2v3m18 0V5a2 2 0 00-2-2h-3m0 18h3a2 2 0 002-2v-3M3 16v3a2 2 0 002 2h3"/></svg>
            </button>
            
            <div class="w-px h-4 bg-slate-200 mx-0.5"></div>
            <!-- Download PDF Button (Integrated in Desktop Toolbar) -->
            <button 
              type="button" 
              class="flex items-center gap-1 rounded-full bg-brand px-3 py-1 text-[10px] font-bold text-white hover:bg-brand/90 active:scale-95 transition-all shadow-sm"
              @click="$emit('download')"
              :disabled="isDownloading"
            >
              <svg v-if="isDownloading" class="size-3 animate-spin" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><circle cx="12" cy="12" r="10" stroke-opacity="0.25"></circle><path d="M12 2v4M12 18v4"></path></svg>
              <svg v-else class="size-3" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M21 15v4a2 2 0 01-2 2H5a2 2 0 01-2-2v-4M7 10l5 5 5-5M12 15V3"/></svg>
              <span>Download</span>
            </button>
          </div>
        </div>
      </div>
      
      <div class="flex-1 overflow-y-auto p-4 xl:p-8 space-y-6">
        <!-- Live preview component -->
        <ResumePreview
          :title="model.title"
          :content="model.content"
          :template-id="model.template_id"
          :appearance="model.content.appearance"
          :section-order="model.content.sectionOrder"
          :section-visibility="model.content.sectionVisibility"
          :zoom="previewZoom"
          @page-update="actualPageCount = $event"
        />

        <!-- ═══ Intelligence Panel ═══ -->
        <IntelligencePanel
          :health-score="healthScore"
          :health-label="healthLabel"
          :health-color="healthColor"
          :section-health="sectionHealth"
          :ats-analysis="atsAnalysis"
          :keyword-analysis="keywordAnalysis"
          :checklist="checklist"
          :statistics="statistics"
          :tips="tips"
          :experience-level="experienceLevel"
          :target-role="targetRole"
        />
      </div>
    </aside>

    <!-- ═══════════════════════════════════════════════════════════════
         Full-screen preview modal
    ═══════════════════════════════════════════════════════════════ -->
    <Teleport to="body">
      <Transition name="fade">
        <div
          v-if="showFullPreview"
          class="fixed inset-0 z-50 flex items-start justify-center overflow-y-auto bg-black/70 p-4 backdrop-blur-sm"
          @click.self="showFullPreview = false"
        >
          <div class="mt-8 mb-8 w-full max-w-3xl">
            <div class="mb-4 flex items-center justify-between">
              <h3 class="text-lg font-bold text-white">{{ model.title || 'Resume Preview' }}</h3>
              <button
                type="button"
                class="rounded-xl bg-white/10 px-4 py-2 text-sm font-semibold text-white transition hover:bg-white/20"
                @click="showFullPreview = false"
              >
                {{ t('builder.closePreview') }}
              </button>
            </div>
            <div class="overflow-hidden rounded-2xl shadow-2xl">
              <component
                :is="activeTemplateComponent"
                :title="model.title"
                :content="model.content"
                :appearance="model.content.appearance"
                :section-order="model.content.sectionOrder"
                :section-visibility="model.content.sectionVisibility"
                @page-update="actualPageCount = $event"
              />
            </div>
          </div>
        </div>
      </Transition>
    </Teleport>

    <!-- ═══════════════════════════════════════════════════════════════
         Command Palette (Cmd+K)
    ═══════════════════════════════════════════════════════════════ -->
    <CommandPalette v-model="showCommandPalette" @action="handleCommandAction" />

    <!-- ═══ MOBILE: Preview Tab (full-screen) ═══ -->
    <div v-if="isMobile && activeTab === 'preview'" class="flex-1 flex flex-col min-h-0">
      <div class="flex items-center justify-between border-b border-slate-200 bg-white px-4 py-3 sticky top-0 z-10">
        <h2 class="text-sm font-bold text-ink">Preview</h2>
        <div class="flex items-center gap-2">
          <!-- Mobile Toolbar -->
          <div class="flex items-center gap-1 bg-slate-50 border border-slate-200 rounded-lg p-1">
            <button type="button" class="p-1 text-slate-500 hover:bg-slate-200 rounded transition" @click="zoomOut">
              <svg class="size-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0zM8 10h6"/></svg>
            </button>
            <button type="button" class="text-[10px] font-bold text-slate-700 w-9 text-center select-none hover:bg-slate-200 rounded transition" @click="previewZoom = 100">{{ Math.round(previewZoom) }}%</button>
            <button type="button" class="p-1 text-slate-500 hover:bg-slate-200 rounded transition" @click="zoomIn">
              <svg class="size-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0zM10 7v6m-3-3h6"/></svg>
            </button>
          </div>
          <button type="button" class="rounded-lg border border-brand/30 bg-brand/5 px-3 py-1 text-xs font-semibold text-brand" @click="$emit('download')" :disabled="isDownloading">
            {{ isDownloading ? '...' : 'PDF' }}
          </button>
        </div>
      </div>
      <div class="flex-1 overflow-auto bg-slate-100 p-4">
        <ResumePreview
          :title="model.title" :content="model.content" :template-id="model.template_id"
          :appearance="model.content.appearance" :section-order="model.content.sectionOrder"
          :section-visibility="model.content.sectionVisibility" :zoom="previewZoom"
          @page-update="actualPageCount = $event"
        />
      </div>
    </div>

    <!-- ═══ MOBILE: Insights Tab (full-screen) ═══ -->
    <div v-if="isMobile && activeTab === 'insights'" class="flex-1 overflow-y-auto bg-slate-50 p-4 space-y-4">
      <div class="flex items-center gap-2 mb-2">
        <h2 class="text-lg font-bold text-ink">Resume Intelligence</h2>
        <span class="rounded-full bg-emerald-500/10 px-2 py-0.5 text-[9px] font-bold uppercase tracking-wider text-emerald-600">Free</span>
      </div>
      <TargetRoleSelector v-model="targetRole" />
      <IntelligencePanel
        :health-score="healthScore" :health-label="healthLabel" :health-color="healthColor"
        :section-health="sectionHealth" :ats-analysis="atsAnalysis" :keyword-analysis="keywordAnalysis"
        :checklist="checklist" :statistics="statistics" :tips="tips"
        :experience-level="experienceLevel" :target-role="targetRole"
      />
    </div>

    <!-- ═══ MOBILE: More Tab (full-screen) ═══ -->
    <div v-if="isMobile && activeTab === 'more'" class="flex-1 overflow-y-auto bg-slate-50 p-5 space-y-5">
      <div class="flex items-center justify-between border-b border-slate-200/50 pb-3">
        <h2 class="text-base font-bold text-slate-800">Settings</h2>
        <RouterLink to="/resumes" class="text-xs font-semibold text-slate-500 hover:text-ink flex items-center gap-1">
          <svg class="size-3.5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M19 12H5M12 19l-7-7 7-7"/></svg>
          Back
        </RouterLink>
      </div>

      <!-- Segmented Settings Category Bar -->
      <div class="flex items-center gap-1 overflow-x-auto scrollbar-none bg-slate-100 p-1 rounded-xl shrink-0">
        <button 
          v-for="cat in ['templates', 'content', 'appearance', 'export']" 
          :key="cat"
          type="button" 
          class="flex-1 text-center py-2 px-3 text-xs font-bold rounded-lg capitalize whitespace-nowrap transition-all duration-200"
          :class="activeSettingsCategory === cat ? 'bg-white text-slate-900 shadow-sm' : 'text-slate-500 hover:text-slate-800'"
          @click="activeSettingsCategory = cat"
        >
          {{ cat }}
        </button>
      </div>

      <!-- Settings Category Panels -->
      <Transition name="fade" mode="out-in">
        <div v-if="activeSettingsCategory === 'templates'" class="space-y-3">
          <p class="text-xs font-bold text-slate-400 uppercase tracking-wider">Templates</p>
          <TemplatePicker v-model="model.template_id" :content="model.content" />
        </div>
        <div v-else-if="activeSettingsCategory === 'content'" class="space-y-3">
          <p class="text-xs font-bold text-slate-400 uppercase tracking-wider">Layout & Reorder</p>
          <CustomizePanel v-model:order="model.content.sectionOrder" v-model:visibility="model.content.sectionVisibility" />
        </div>
        <div v-else-if="activeSettingsCategory === 'appearance'" class="space-y-3">
          <p class="text-xs font-bold text-slate-400 uppercase tracking-wider">Appearance</p>
          <AppearancePanel v-model="model.content.appearance" />
        </div>
        <div v-else-if="activeSettingsCategory === 'export'" class="space-y-3">
          <p class="text-xs font-bold text-slate-400 uppercase tracking-wider">Export Document</p>
          <div class="rounded-2xl border border-slate-100 bg-white p-5 shadow-sm space-y-4">
            <p class="text-xs text-slate-500 leading-normal">Ready to download? Your resume is prepared for instant export to a clean, professionally pagination-validated PDF.</p>
            <button 
              type="button" 
              class="w-full rounded-xl bg-brand py-3 text-sm font-semibold text-white transition hover:bg-brand/90 active:scale-95 duration-200 shadow-md shadow-brand/10" 
              @click="$emit('download')" 
              :disabled="isDownloading"
            >
              {{ isDownloading ? 'Generating PDF...' : 'Download PDF' }}
            </button>
          </div>
        </div>
      </Transition>
    </div>

    <!-- ═══ MOBILE: Bottom Navigation ═══ -->
    <nav v-if="isMobile" class="bottom-nav" role="tablist" aria-label="Editor navigation">
      <button type="button" role="tab" class="bottom-nav-item" :class="{ active: activeTab === 'resume' }" :aria-selected="activeTab === 'resume'" @click="setTab('resume')">
        <svg class="size-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M14 2H6a2 2 0 00-2 2v16a2 2 0 002 2h12a2 2 0 002-2V8z"/><path d="M14 2v6h6M16 13H8M16 17H8M10 9H8"/></svg>
        <span class="bottom-nav-label">Resume</span>
      </button>
      <button type="button" role="tab" class="bottom-nav-item" :class="{ active: activeTab === 'preview' }" :aria-selected="activeTab === 'preview'" @click="setTab('preview')">
        <svg class="size-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/><circle cx="12" cy="12" r="3"/></svg>
        <span class="bottom-nav-label">Preview</span>
      </button>
      <button type="button" role="tab" class="bottom-nav-item" :class="{ active: activeTab === 'insights' }" :aria-selected="activeTab === 'insights'" @click="setTab('insights')">
        <svg class="size-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M12 2l2.4 7.2H22l-6.2 4.5 2.4 7.3L12 17l-6.2 4 2.4-7.3L2 9.2h7.6z"/></svg>
        <span class="bottom-nav-label">Insights</span>
      </button>
      <button type="button" role="tab" class="bottom-nav-item" :class="{ active: activeTab === 'more' }" :aria-selected="activeTab === 'more'" @click="setTab('more')">
        <svg class="size-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="1"/><circle cx="12" cy="5" r="1"/><circle cx="12" cy="19" r="1"/></svg>
        <span class="bottom-nav-label">More</span>
      </button>
    </nav>

    <!-- ═══ Floating Draggable Health Score Widget ═══ -->
    <Teleport to="body">
      <Transition name="fade">
        <div
          v-if="isMobile && activeTab === 'resume' && healthScore > 0"
          ref="fabRef"
          class="fixed select-none z-50 h-10 w-24"
          :style="fabStyle"
        >
          <!-- Tooltip/Popover (Priority 5 Widget) -->
          <Transition name="fade">
            <div
              v-if="isExpanded"
              class="absolute z-50 rounded-2xl border border-slate-200 bg-white/95 backdrop-blur-md p-4 shadow-[0_20px_50px_rgba(0,0,0,0.15)] w-56 overflow-exempt animate-fade-in text-ink flex flex-col gap-2.5"
              :class="[
                isOnTopHalf ? 'top-[calc(100%+8px)]' : 'bottom-[calc(100%+8px)]',
                isOnLeftHalf ? 'left-0' : 'right-0'
              ]"
              @click.stop
            >
              <div class="flex items-center justify-between">
                <span class="text-[10px] font-bold uppercase tracking-wider text-slate-400 flex items-center gap-1">
                  <span class="text-emerald-500">✓</span> Resume Health
                </span>
                <button 
                  type="button" 
                  class="shrink-0 rounded-full p-1 hover:bg-slate-100 text-slate-400 transition-colors"
                  @click.stop="isExpanded = false"
                >
                  <svg class="size-3.5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                    <path d="M18 6 6 18M6 6l12 12" />
                  </svg>
                </button>
              </div>
              <div class="flex items-baseline gap-2">
                <span class="text-2xl font-extrabold text-slate-900 tracking-tight">{{ healthScore }}%</span>
                <span class="text-[10px] font-bold px-2 py-0.5 rounded-full" :class="[
                  healthScore >= 80 ? 'bg-emerald-50 text-emerald-700' :
                  healthScore >= 50 ? 'bg-amber-50 text-amber-700' : 'bg-rose-50 text-rose-700'
                ]">{{ healthLabel }}</span>
              </div>
              <div class="text-[10px] text-slate-500 flex items-center justify-between border-t border-slate-100 pt-2">
                <span>Percentile Rating</span>
                <span class="font-semibold text-slate-800" v-if="healthScore >= 80">Top 10%</span>
                <span class="font-semibold text-slate-800" v-else-if="healthScore >= 50">Top 40%</span>
                <span class="font-semibold text-slate-800" v-else>Top 80%</span>
              </div>
            </div>
          </Transition>

          <!-- Glassmorphism Premium Pill FAB button -->
          <button
            type="button"
            class="flex size-full items-center justify-between gap-1.5 rounded-full bg-white/90 backdrop-blur-md shadow-lg border border-slate-200/80 px-3 py-2 transition hover:scale-105 active:scale-95 cursor-grab active:cursor-grabbing hover:border-brand/40"
            @mousedown="startDrag"
            @touchstart="startDrag"
            @click="handleFabClick"
          >
            <span class="flex h-5 w-5 shrink-0 items-center justify-center rounded-full bg-slate-50 border border-slate-100 text-[10px] font-bold" :class="scoreColorClass">✓</span>
            <div class="flex flex-col items-start leading-none text-left flex-1 min-w-0">
              <span class="text-[8px] font-bold text-slate-400 uppercase tracking-wider">Health</span>
              <span class="text-xs font-extrabold text-slate-800">{{ healthScore }}%</span>
            </div>
          </button>
        </div>
      </Transition>
    </Teleport>
  </form>
</template>

<script setup>
import { computed, reactive, ref, onBeforeUnmount, onMounted, nextTick, toRef } from 'vue'
import { useStore } from 'vuex'
import AppButton from '../../components/ui/AppButton.vue'
import ResumePreview from './ResumePreview.vue'
import IntelligencePanel from './IntelligencePanel.vue'
import TargetRoleSelector from './TargetRoleSelector.vue'
import CommandPalette from './CommandPalette.vue'
import AiGenerationWidget from '../../components/ai/AiGenerationWidget.vue'
import TemplatePicker from './TemplatePicker.vue'
import AppearancePanel from './AppearancePanel.vue'
import CustomizePanel from './CustomizePanel.vue'
import ExperienceSection from './form/ExperienceSection.vue'
import EducationSection from './form/EducationSection.vue'
import ProjectsSection from './form/ProjectsSection.vue'
import CertificationsSection from './form/CertificationsSection.vue'
import LanguagesSection from './form/LanguagesSection.vue'
import AchievementsSection from './form/AchievementsSection.vue'
import InterestsSection from './form/InterestsSection.vue'
import SocialLinksSection from './form/SocialLinksSection.vue'
import ModernTemplate from './templates/ModernTemplate.vue'
import ProfessionalTemplate from './templates/ProfessionalTemplate.vue'
import MinimalTemplate from './templates/MinimalTemplate.vue'
import ExecutiveTemplate from './templates/ExecutiveTemplate.vue'
import FresherTemplate from './templates/FresherTemplate.vue'
import { RESUME_STATUS } from '../../constants/resume'
import { calculateCompletion } from '../../utils/profileToResume'
import { useResumeIntelligence } from '../../composables/useResumeIntelligence'
import { useEditorTabs, EDITOR_TABS } from '../../composables/useEditorTabs'
import { t } from '../../utils/i18n'

// ─── Mobile Tab Navigation ───
const { activeTab, isMobile, setTab, showResumeEditor, showPreview, showInsights, showMore } = useEditorTabs()

const leftSidebarCollapsed = ref(false)
const activeSettingsCategory = ref('templates')

// ─── Floating Draggable Health Score Widget ───
const fabRef = ref(null)
const isExpanded = ref(false)
const position = ref({ x: null, y: null })

const scoreColorClass = computed(() => {
  if (healthScore.value >= 80) return 'text-emerald-600'
  if (healthScore.value >= 50) return 'text-amber-500'
  return 'text-red-500'
})

const fabBorderClass = computed(() => {
  if (healthScore.value >= 80) return 'border-emerald-500'
  if (healthScore.value >= 50) return 'border-amber-500'
  return 'border-red-500'
})

const isOnLeftHalf = computed(() => {
  if (position.value.x === null) return false
  return position.value.x < window.innerWidth / 2
})

const isOnTopHalf = computed(() => {
  if (position.value.y === null) return false
  return position.value.y < window.innerHeight / 2
})

const fabStyle = computed(() => {
  if (position.value.x === null || position.value.y === null) {
    return {
      bottom: 'calc(var(--bottom-nav-height) + var(--safe-area-bottom) + 16px)',
      right: '16px'
    }
  }
  return {
    left: `${position.value.x}px`,
    top: `${position.value.y}px`
  }
})

let dragStartPos = { x: 0, y: 0 }
let initialElementPos = { x: 0, y: 0 }
let isDragging = false
let dragMoved = false

const startDrag = (e) => {
  isDragging = true
  dragMoved = false
  
  const clientX = e.touches ? e.touches[0].clientX : e.clientX
  const clientY = e.touches ? e.touches[0].clientY : e.clientY
  
  dragStartPos = { x: clientX, y: clientY }
  
  if (position.value.x === null || position.value.y === null) {
    const rect = fabRef.value.getBoundingClientRect()
    position.value = { x: rect.left, y: rect.top }
  }
  
  initialElementPos = { x: position.value.x, y: position.value.y }
  
  if (e.touches) {
    document.addEventListener('touchmove', onDrag, { passive: false })
    document.addEventListener('touchend', endDrag)
  } else {
    document.addEventListener('mousemove', onDrag)
    document.addEventListener('mouseup', endDrag)
  }
}

const onDrag = (e) => {
  if (!isDragging) return
  if (e.cancelable) e.preventDefault()
  
  const clientX = e.touches ? e.touches[0].clientX : e.clientX
  const clientY = e.touches ? e.touches[0].clientY : e.clientY
  
  const dx = clientX - dragStartPos.x
  const dy = clientY - dragStartPos.y
  
  if (Math.abs(dx) > 5 || Math.abs(dy) > 5) {
    dragMoved = true
  }
  
  let newX = initialElementPos.x + dx
  let newY = initialElementPos.y + dy
  
  const buttonSize = 48
  const maxX = window.innerWidth - buttonSize - 8
  const maxY = window.innerHeight - buttonSize - 70
  
  newX = Math.max(8, Math.min(newX, maxX))
  newY = Math.max(8, Math.min(newY, maxY))
  
  position.value = { x: newX, y: newY }
}

const endDrag = () => {
  isDragging = false
  document.removeEventListener('touchmove', onDrag)
  document.removeEventListener('touchend', endDrag)
  document.removeEventListener('mousemove', onDrag)
  document.removeEventListener('mouseup', endDrag)
}

const handleFabClick = () => {
  if (!dragMoved) {
    isExpanded.value = !isExpanded.value
  }
}

// ─── Time-aware Greeting ───
const store = useStore()
const userName = computed(() => store.state.auth.user?.name?.split(' ')[0] || '')
const greeting = computed(() => {
  const h = new Date().getHours()
  if (h < 12) return 'Good Morning'
  if (h < 17) return 'Good Afternoon'
  return 'Good Evening'
})

// Icon render helpers (inline SVG functional components for section headers)
const IconPerson = `<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M20 21v-2a4 4 0 00-4-4H8a4 4 0 00-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>`
const IconBriefcase = `<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="2" y="7" width="20" height="14" rx="2"/><path d="M16 7V5a2 2 0 00-2-2h-4a2 2 0 00-2 2v2"/></svg>`
const IconGrad = `<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M22 10v6M2 10l10-5 10 5-10 5z"/><path d="M6 12v5c3 3 9 3 12 0v-5"/></svg>`
const IconCode = `<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="16 18 22 12 16 6"/><polyline points="8 6 2 12 8 18"/></svg>`
const IconSparkle = `<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M12 2l2.4 7.2H22l-6.2 4.5 2.4 7.3L12 17l-6.2 4 2.4-7.3L2 9.2h7.6z"/></svg>`
const IconCert = `<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="8" r="6"/><path d="M15.477 12.89L17 22l-5-3-5 3 1.523-9.11"/></svg>`
const IconGlobe = `<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"/><path d="M2 12h20M12 2a15.3 15.3 0 014 10 15.3 15.3 0 01-4 10 15.3 15.3 0 01-4-10 15.3 15.3 0 014-10z"/></svg>`
const IconTrophy = `<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M6 9H4.5a2.5 2.5 0 010-5H6"/><path d="M18 9h1.5a2.5 2.5 0 000-5H18"/><path d="M4 22h16M10 14.66V17c0 .55-.47.98-.97 1.21C7.85 18.75 7 20.24 7 22"/><path d="M14 14.66V17c0 .55.47.98.97 1.21C16.15 18.75 17 20.24 17 22"/><path d="M18 2H6v7a6 6 0 0012 0V2z"/></svg>`
const IconHeart = `<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M20.84 4.61a5.5 5.5 0 00-7.78 0L12 5.67l-1.06-1.06a5.5 5.5 0 00-7.78 7.78l1.06 1.06L12 21.23l7.78-7.78 1.06-1.06a5.5 5.5 0 000-7.78z"/></svg>`
const IconLink = `<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M10 13a5 5 0 007.54.54l3-3a5 5 0 00-7.07-7.07l-1.72 1.71"/><path d="M14 11a5 5 0 00-7.54-.54l-3 3a5 5 0 007.07 7.07l1.71-1.71"/></svg>`

const ALL_SECTIONS = [
  { key: 'personal',      label: 'Personal Information', icon: IconPerson, hint: 'Recruiters look here first. Ensure contact info is accurate.' },
  { key: 'experience',    label: 'Experience',           icon: IconBriefcase, hint: 'Use bullet points with action verbs and quantifiable results.' },
  { key: 'education',     label: 'Education',            icon: IconGrad, hint: 'Include degrees, relevant coursework, or academic honors.' },
  { key: 'projects',      label: 'Projects',             icon: IconCode, hint: 'Highlight your impact, technologies used, and outcomes.' },
  { key: 'skills',        label: 'Skills',               icon: IconSparkle, hint: 'List hard and soft skills relevant to the target role.' },
  { key: 'certifications',label: 'Certifications',       icon: IconCert, hint: 'Add industry-recognized credentials to boost credibility.' },
  { key: 'languages',     label: 'Languages',            icon: IconGlobe, hint: 'List languages and your proficiency level.' },
  { key: 'achievements',  label: 'Achievements',         icon: IconTrophy, hint: 'Include awards, publications, or special recognitions.' },
  { key: 'interests',     label: 'Interests',            icon: IconHeart, hint: 'Show your personality through relevant hobbies or groups.' },
  { key: 'socialLinks',   label: 'Social Links',         icon: IconLink, hint: 'Add LinkedIn, GitHub, or personal portfolio.' }
]

const TEMPLATE_MAP = {
  modern: ModernTemplate,
  professional: ProfessionalTemplate,
  minimal: MinimalTemplate,
  executive: ExecutiveTemplate,
  fresher: FresherTemplate
}

const props = defineProps({ 
  model: { type: Object, required: true }, 
  loading: Boolean,
  isNew: Boolean,
  isDownloading: Boolean,
  saveStatus: { type: String, default: 'saved' }
})
defineEmits(['submit', 'fill-from-profile', 'download'])

const completionScore = computed(() => calculateCompletion(props.model.content))

// Target Role state
const targetRole = ref('')
const actualPageCount = ref(1)
const intelligenceOptions = computed(() => ({
  pageCount: actualPageCount.value
}))

// Intelligence Engine
const contentRef = computed(() => props.model.content)
const {
  healthScore, healthLabel, healthColor,
  sectionHealth, atsAnalysis, keywordAnalysis,
  checklist, statistics, tips, experienceLevel
} = useResumeIntelligence(contentRef, targetRole, intelligenceOptions)

const statuses = Object.values(RESUME_STATUS)
const update = (key, value) => { props.model[key] = value }

// Collapsible section open state — personal open by default
const openSections = reactive(Object.fromEntries(ALL_SECTIONS.map((s, i) => [s.key, i === 0])))
const toggleSection = (key) => {
  if (isMobile.value) {
    // Single-accordion on mobile: close all others
    const wasOpen = openSections[key]
    ALL_SECTIONS.forEach(s => { openSections[s.key] = false })
    openSections[key] = !wasOpen
    // Removed auto-scroll logic to prevent scroll jumping on mobile
  } else {
    openSections[key] = !openSections[key]
  }
}

// Left Sidebar state
const sidebarState = reactive({
  template: true,
  appearance: false,
  customize: false
})

// Resizing logic (20% left, 45% middle, 35% right ideally)
const leftWidth = ref(window.innerWidth > 1024 ? window.innerWidth * 0.20 : 280)
const rightWidth = ref(window.innerWidth > 1024 ? window.innerWidth * 0.35 : 480)

const getSectionCount = (key) => {
  if (key === 'personal' || key === 'skills' || key === 'summary') return 0
  let items = []
  if (key === 'experience') items = props.model.content.experiences
  else if (key === 'education') items = props.model.content.educations
  else if (key === 'projects') items = props.model.content.projects
  else if (key === 'certifications') items = props.model.content.certifications
  else if (key === 'languages') items = props.model.content.languages
  else if (key === 'achievements') items = props.model.content.achievements
  else if (key === 'interests') items = props.model.content.interests
  else items = props.model.content[key]
  
  return Array.isArray(items) ? items.filter(i => Object.values(i).some(v => typeof v === 'string' && v.trim() !== '' && !v.match(/^[0-9a-f]{8}-/i))).length : 0
}

const sectionValidations = computed(() => {
  const v = {}
  const content = props.model.content
  if (!content) return v

  for (const sec of ALL_SECTIONS) {
    const key = sec.key
    const res = { status: 'COMPLETE', missing: [], suggestions: [] }
    
    if (key === 'personal') {
      if (!content.personal.fullName) res.missing.push('Full Name')
      if (!content.personal.email) res.missing.push('Email')
      if (!content.personal.phone) res.missing.push('Phone')
      if (res.missing.length > 0) res.status = 'INCOMPLETE'
      else if (!content.personal.linkedin && !content.personal.github && !content.personal.portfolio) {
        res.status = 'OPTIMIZATION'
        res.suggestions.push('Add at least one professional link (LinkedIn/GitHub/Portfolio)')
      }
    } else if (key === 'summary') {
      if (!content.personal.summary || content.personal.summary.trim().length < 20) {
        res.status = 'INCOMPLETE'
        res.missing.push('Professional Summary (min 20 chars)')
      } else if (content.personal.summary.trim().length < 100) {
        res.status = 'OPTIMIZATION'
        res.suggestions.push('Summary is a bit short. Aim for 3-4 impactful sentences.')
      }
    } else if (key === 'experience') {
      const items = content.experiences || []
      const validItems = items.filter(i => i.role || i.company || i.description)
      if (!validItems.length) {
        res.status = 'INCOMPLETE'
        res.missing.push('At least one experience entry')
      } else {
        validItems.forEach((item, idx) => {
          const name = item.company || `Entry ${idx + 1}`
          if (!item.role) res.missing.push(`${name}: Role`)
          if (!item.company) res.missing.push(`${name}: Company`)
          if (!item.startDate) res.missing.push(`${name}: Start Date`)
          if (!item.endDate) res.missing.push(`${name}: End Date`)
          if (!item.description || item.description.trim().length < 20) res.missing.push(`${name}: Description`)
          else if (!item.description.includes('%') && !item.description.includes('$') && !/\d/.test(item.description)) {
            res.suggestions.push(`${name}: Add measurable metrics (numbers, %, $)`)
          }
        })
      }
    } else if (key === 'education') {
      const items = content.educations || []
      const validItems = items.filter(i => i.school || i.degree)
      if (!validItems.length) {
        res.status = 'INCOMPLETE'
        res.missing.push('At least one education entry')
      } else {
        validItems.forEach((item, idx) => {
          const name = item.school || `Entry ${idx + 1}`
          if (!item.school) res.missing.push(`${name}: School`)
          if (!item.degree) res.missing.push(`${name}: Degree`)
        })
      }
    } else if (key === 'projects') {
      const items = content.projects || []
      const validItems = items.filter(i => i.projectName || i.description)
      if (!validItems.length) {
        res.status = 'INCOMPLETE'
        res.missing.push('At least one project entry')
      } else {
        validItems.forEach((item, idx) => {
          const name = item.projectName || `Entry ${idx + 1}`
          if (!item.projectName) res.missing.push(`${name}: Project Name`)
          if (!item.description) res.missing.push(`${name}: Description`)
        })
      }
    } else if (key === 'skills') {
      if (!content.skills?.skillList?.trim()) {
        res.status = 'INCOMPLETE'
        res.missing.push('Add your skills')
      } else if (!content.skills.skillList.includes(',')) {
        res.status = 'OPTIMIZATION'
        res.suggestions.push('Separate skills with commas')
      }
    } else if (key === 'certifications') {
      const items = (content.certifications || []).filter(i => i.certName || i.issuingOrg)
      items.forEach((item, idx) => {
        const name = item.certName || `Entry ${idx + 1}`
        if (!item.certName) res.missing.push(`${name}: Certification Name`)
        if (!item.issuingOrg) res.missing.push(`${name}: Issuing Organization`)
      })
    }
    
    if (res.missing.length > 0) res.status = 'INCOMPLETE'
    else if (res.suggestions.length > 0 && res.status !== 'INCOMPLETE') res.status = 'OPTIMIZATION'
    else if (getSectionCount(key) === 0 && !['personal', 'summary', 'skills'].includes(key)) res.status = 'EMPTY'
    
    v[key] = res
  }
  
  // Debug log exactly what is incomplete as requested
  if (import.meta.env.DEV) {
    console.groupCollapsed('Validation Report')
    for (const [k, val] of Object.entries(v)) {
      if (val.status !== 'COMPLETE') {
        console.log(`Section: ${k}`)
        console.log(`Status: ${val.status}`)
        if (val.missing.length) console.log(`Reason:\n- ${val.missing.join('\n- ')}`)
        if (val.suggestions.length) console.log(`Suggestions:\n- ${val.suggestions.join('\n- ')}`)
      }
    }
    console.groupEnd()
  }
  
  return v
})

let isResizingLeft = false
let isResizingRight = false

const startResizeLeft = () => {
  isResizingLeft = true
  document.addEventListener('mousemove', resizeLeft)
  document.addEventListener('mouseup', stopResize)
  document.body.style.cursor = 'col-resize'
  document.body.style.userSelect = 'none'
}

const resizeLeft = (e) => {
  if (isResizingLeft) {
    const newWidth = e.clientX
    if (newWidth > 200 && newWidth < 500) {
      leftWidth.value = newWidth
    }
  }
}

const startResizeRight = () => {
  isResizingRight = true
  document.addEventListener('mousemove', resizeRight)
  document.addEventListener('mouseup', stopResize)
  document.body.style.cursor = 'col-resize'
  document.body.style.userSelect = 'none'
}

const resizeRight = (e) => {
  if (isResizingRight) {
    const newWidth = document.body.clientWidth - e.clientX
    if (newWidth > 300 && newWidth < 800) {
      rightWidth.value = newWidth
    }
  }
}

const stopResize = () => {
  isResizingLeft = false
  isResizingRight = false
  document.removeEventListener('mousemove', resizeLeft)
  document.removeEventListener('mousemove', resizeRight)
  document.removeEventListener('mouseup', stopResize)
  document.body.style.cursor = ''
  document.body.style.userSelect = ''
}

onBeforeUnmount(() => {
  stopResize()
})

// Preview zoom & fullscreen
const previewZoom     = ref(100)
const showFullPreview = ref(false)
const showCommandPalette = ref(false)

const zoomIn = () => previewZoom.value = Math.min(200, Math.floor(previewZoom.value / 10) * 10 + 10)
const zoomOut = () => previewZoom.value = Math.max(25, Math.ceil(previewZoom.value / 10) * 10 - 10)

const handleCommandAction = (action) => {
  if (action.type === 'download') emit('download')
  else if (action.type === 'toggle-preview') showFullPreview.value = !showFullPreview.value
  else if (action.type === 'set-template') update('template_id', action.payload)
  else if (action.type === 'add-section') {
    // Open the accordion
    openSections[action.payload] = true
  }
}

const fitToWidth = () => {
  // A4 width is 794px. Right aside width minus padding (~64px).
  previewZoom.value = Math.min(150, Math.round(((rightWidth.value - 64) / 794) * 100))
}

const fitToPage = () => {
  // A4 height is 1122.5px. Viewer area height approx innerHeight - 120px.
  previewZoom.value = Math.min(150, Math.round(((window.innerHeight - 120) / 1122.5) * 100))
}

const activeTemplateComponent = computed(() => TEMPLATE_MAP[props.model.template_id] || ModernTemplate)
</script>

<style scoped>
.left-sidebar, .right-sidebar {
  width: 100%;
}
@media (min-width: 1024px) {
  .left-sidebar, .right-sidebar {
    width: var(--lg-width);
  }
}

.collapse-enter-active,
.collapse-leave-active {
  transition: max-height 0.25s ease, opacity 0.2s ease;
  overflow: hidden;
}
.collapse-enter-from,
.collapse-leave-to {
  max-height: 0;
  opacity: 0;
}
.collapse-enter-to,
.collapse-leave-from {
  max-height: 3000px;
  opacity: 1;
}

.fade-enter-active, .fade-leave-active { transition: opacity 0.2s ease; }
.fade-enter-from, .fade-leave-to { opacity: 0; }
</style>
