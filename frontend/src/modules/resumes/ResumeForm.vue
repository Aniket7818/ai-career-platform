<template>
  <form
    class="flex flex-col lg:flex-row min-h-screen lg:h-screen w-full lg:overflow-hidden bg-slate-50"
    @submit.prevent="$emit('submit')"
  >
    <!-- ═══════════════════════════════════════════════════════════════
         LEFT COLUMN: Sidebar & Customization
    ═══════════════════════════════════════════════════════════════ -->
    <aside 
      class="left-sidebar relative flex shrink-0 flex-col border-b lg:border-b-0 lg:border-r border-slate-200 bg-white"
      :style="{ '--lg-width': `${leftWidth}px` }"
    >
      <div class="flex items-center gap-3 border-b border-slate-200 p-5">
        <RouterLink to="/resumes" class="inline-flex items-center gap-2 text-sm font-semibold text-slate-500 transition hover:text-ink">
          <svg class="size-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M19 12H5M12 19l-7-7 7-7"/></svg>
          {{ t('nav.dashboard') }}
        </RouterLink>
      </div>
      <div class="lg:flex-1 lg:overflow-y-auto p-5 space-y-6">
        <!-- Template picker -->
        <TemplatePicker v-model="model.template_id" :content="model.content" />

        <!-- Customization panel -->
        <CustomizePanel
          v-model:order="model.content.sectionOrder"
          v-model:visibility="model.content.sectionVisibility"
        />

        <!-- Appearance panel -->
        <AppearancePanel v-model="model.content.appearance" />
      </div>
      <!-- Resizer Handle -->
      <div 
        class="hidden lg:block absolute right-0 top-0 h-full w-1.5 cursor-col-resize hover:bg-brand/50 active:bg-brand z-10 -mr-[3px]"
        @mousedown.prevent="startResizeLeft"
      />
    </aside>

    <!-- ═══════════════════════════════════════════════════════════════
         MIDDLE COLUMN: Form sections
    ═══════════════════════════════════════════════════════════════ -->
    <main class="flex-1 lg:overflow-y-auto">
      <div class="mx-auto max-w-3xl space-y-6 p-5 sm:p-8">
        <!-- Header -->
        <div class="flex flex-wrap items-start justify-between gap-4">
          <div>
            <p class="text-sm font-semibold text-brand">{{ t('nav.builder') }}</p>
            <h1 class="mt-1 text-3xl font-bold text-ink">{{ isNew ? t('resumes.new') : t('resumes.edit') }}</h1>
            <p class="mt-2 text-sm text-slate-500">{{ t('resumes.editorSubtitle') }}</p>
          </div>
          <button
            type="button"
            class="inline-flex items-center gap-2 rounded-xl border border-brand/30 bg-brand/5 px-4 py-2.5 text-sm font-semibold text-brand transition hover:bg-brand/10 disabled:opacity-50 disabled:cursor-not-allowed"
            @click="$emit('download')"
            :disabled="isDownloading"
          >
            <svg v-if="isDownloading" class="size-4 animate-spin" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10" stroke-opacity="0.25"></circle><path d="M12 2v4M12 18v4M4.93 4.93l2.83 2.83M16.24 16.24l2.83 2.83M2 12h4M18 12h4M4.93 19.07l2.83-2.83M16.24 7.76l2.83-2.83"></path></svg>
            <svg v-else class="size-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M21 15v4a2 2 0 01-2 2H5a2 2 0 01-2-2v-4" /><path d="M7 10l5 5 5-5" /><path d="M12 15V3" /></svg>
            {{ isDownloading ? 'Generating...' : t('resumes.download') }}
          </button>
        </div>

        <!-- Profile Completion -->
        <div class="rounded-2xl border border-slate-100 bg-white p-5 shadow-panel sm:p-6">
          <div class="mb-2 flex items-center justify-between text-sm font-bold text-ink">
            <span>Profile Completion</span>
            <span class="text-brand">{{ completionScore }}%</span>
          </div>
          <div class="h-2 w-full overflow-hidden rounded-full bg-slate-100">
            <div
              class="h-full bg-brand transition-all duration-500"
              :style="{ width: `${completionScore}%` }"
            />
          </div>
        </div>

        <!-- Resume meta: title + status -->
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

        <!-- Collapsible sections -->
        <div
          v-for="section in ALL_SECTIONS"
          :key="section.key"
          class="overflow-hidden rounded-2xl border border-slate-100 bg-white shadow-panel"
        >
          <!-- Section header (click to toggle) -->
          <button
            type="button"
            class="flex w-full items-center justify-between gap-3 p-5 sm:p-6 text-left transition hover:bg-slate-50/70"
            @click="toggleSection(section.key)"
          >
            <div class="flex items-center gap-3">
              <span class="flex h-7 w-7 items-center justify-center rounded-lg bg-brand/10 text-brand">
                <span v-html="section.icon" class="size-4 [&>svg]:size-full" />
              </span>
              <span class="text-sm font-bold text-ink">
                {{ section.label }}
                <span v-if="getSectionCount(section.key) > 0" class="ml-1 text-xs text-slate-500 font-normal">({{ getSectionCount(section.key) }})</span>
              </span>
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
            <div v-if="openSections[section.key]" class="border-t border-slate-100 p-5 sm:p-6">
              <!-- Personal -->
              <template v-if="section.key === 'personal'">
                <div class="grid gap-4 md:grid-cols-2">
                  <div class="md:col-span-2"><label>{{ t('builder.fullName') }}</label><input v-model="model.content.personal.fullName" /></div>
                  <div class="md:col-span-2"><label>{{ t('builder.headline') }}</label><input v-model="model.content.personal.headline" /></div>
                  <div class="md:col-span-2">
                    <label>{{ t('builder.summaryLabel') }}</label>
                    <textarea v-model="model.content.personal.summary" rows="4" />
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
      class="right-sidebar relative flex shrink-0 flex-col border-t lg:border-t-0 lg:border-l border-slate-200 bg-slate-100/50"
      :style="{ '--lg-width': `${rightWidth}px` }"
    >
      <!-- Resizer Handle -->
      <div 
        class="hidden lg:block absolute left-0 top-0 h-full w-1.5 cursor-col-resize hover:bg-brand/50 active:bg-brand z-10 -ml-[3px]"
        @mousedown.prevent="startResizeRight"
      />
      <div class="flex items-center justify-between border-b border-slate-200 bg-slate-100 p-4">
        <div class="flex items-center gap-2">
          <h2 class="text-sm font-bold text-ink">{{ t('resumes.preview') }}</h2>
          <span class="rounded-full bg-emerald-500/15 px-2.5 py-1 text-[10px] font-bold uppercase tracking-wider text-emerald-600">
            {{ t('resumes.live') }}
          </span>
        </div>
        <div class="flex items-center gap-1.5">
          <!-- Zoom selector -->
          <select
            v-model="previewZoom"
            class="h-[34px] rounded-lg border border-slate-200 bg-white px-2 py-1 text-xs font-semibold text-slate-600"
          >
            <option v-for="z in ZOOM_LEVELS" :key="z" :value="z">{{ z }}%</option>
          </select>
          <!-- Full preview button -->
          <button
            type="button"
            class="rounded-lg border border-slate-200 bg-white px-3 py-1.5 text-xs font-semibold text-slate-600 transition hover:bg-slate-50"
            @click="showFullPreview = true"
          >
            {{ t('builder.fullPreview') }}
          </button>
        </div>
      </div>
      
      <div class="flex-1 overflow-y-auto p-4 xl:p-8">
        <!-- Live preview component -->
        <ResumePreview
          :title="model.title"
          :content="model.content"
          :template-id="model.template_id"
          :appearance="model.content.appearance"
          :section-order="model.content.sectionOrder"
          :section-visibility="model.content.sectionVisibility"
          :zoom="previewZoom"
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
              />
            </div>
          </div>
        </div>
      </Transition>
    </Teleport>
  </form>
</template>

<script setup>
import { computed, reactive, ref, onBeforeUnmount } from 'vue'
import AppButton from '../../components/ui/AppButton.vue'
import ResumePreview from './ResumePreview.vue'
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
import { ZOOM_LEVELS } from '../../constants/resume'
import { calculateCompletion } from '../../utils/profileToResume'
import { t } from '../../utils/i18n'

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
  { key: 'personal',      label: 'Personal Information', icon: IconPerson },
  { key: 'experience',    label: 'Experience',           icon: IconBriefcase },
  { key: 'education',     label: 'Education',            icon: IconGrad },
  { key: 'projects',      label: 'Projects',             icon: IconCode },
  { key: 'skills',        label: 'Skills',               icon: IconSparkle },
  { key: 'certifications',label: 'Certifications',       icon: IconCert },
  { key: 'languages',     label: 'Languages',            icon: IconGlobe },
  { key: 'achievements',  label: 'Achievements',         icon: IconTrophy },
  { key: 'interests',     label: 'Interests',            icon: IconHeart },
  { key: 'socialLinks',   label: 'Social Links',         icon: IconLink }
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

const statuses = Object.values(RESUME_STATUS)
const update = (key, value) => { props.model[key] = value }

// Collapsible section open state — personal open by default
const openSections = reactive(Object.fromEntries(ALL_SECTIONS.map((s, i) => [s.key, i === 0])))
const toggleSection = (key) => { openSections[key] = !openSections[key] }

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
