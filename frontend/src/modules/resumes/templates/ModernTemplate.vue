<template>
  <div
    class="flex flex-col text-[0.929em] leading-relaxed sm:flex-row min-h-full print-bg-gradient"
    :style="{ color: '#0f172a', ...appearStyle, background: `linear-gradient(to right, ${primaryHex} 34%, white 34%)` }"
  >
    <!-- Sidebar -->
    <aside class="w-full shrink-0 px-5 py-6 text-white sm:w-[34%] sm:px-6 sm:py-8 bg-transparent">
      <h1 class="text-[1.571em] font-bold leading-tight">{{ personal.fullName || title }}</h1>
      <p v-if="personal.headline" class="mt-2 text-[1em] font-medium" style="opacity:0.8">{{ personal.headline }}</p>

      <div v-if="contacts.length" class="mt-6 space-y-2.5 border-t border-white/20 pt-5">
        <p v-for="item in contacts" :key="item.label" class="break-all text-[0.786em]" style="opacity:0.75">
          <span class="font-semibold uppercase tracking-wider block" style="opacity:0.9">{{ item.label }}</span>
          {{ item.value }}
        </p>
      </div>

      <template v-for="section in sidebarSections" :key="section">
        <div v-if="section === 'skills' && skills.skillList" class="mt-6 border-t border-white/20 pt-5">
          <h2 class="text-[0.714em] font-bold uppercase tracking-[0.2em]" style="opacity:0.6">{{ t('builder.skills') }}</h2>
          <p class="mt-3 text-[0.857em] leading-6" style="opacity:0.85">{{ skills.skillList }}</p>
        </div>

        <div v-if="section === 'languages' && languages.length" class="mt-6 border-t border-white/20 pt-5">
          <h2 class="text-[0.714em] font-bold uppercase tracking-[0.2em]" style="opacity:0.6">{{ t('builder.languages') }}</h2>
          <div class="mt-3 space-y-1">
            <p v-for="lang in languages" :key="lang.id" class="text-[0.857em]" style="opacity:0.85">
              {{ lang.language }}<span v-if="lang.proficiency" class="opacity-60"> — {{ lang.proficiency }}</span>
            </p>
          </div>
        </div>

        <div v-if="section === 'certifications' && certifications.length" class="mt-6 border-t border-white/20 pt-5">
          <h2 class="text-[0.714em] font-bold uppercase tracking-[0.2em]" style="opacity:0.6">{{ t('builder.certifications') }}</h2>
          <div class="mt-3 space-y-2">
            <div v-for="cert in certifications" :key="cert.id || cert.certName" class="text-[0.857em]">
              <p style="opacity:0.9">{{ cert.certName }}</p>
              <p v-if="cert.issuingOrg" style="opacity:0.6">{{ cert.issuingOrg }}</p>
            </div>
          </div>
        </div>

        <div v-if="section === 'interests' && interests.length" class="mt-6 border-t border-white/20 pt-5">
          <h2 class="text-[0.714em] font-bold uppercase tracking-[0.2em]" style="opacity:0.6">{{ t('builder.interests') }}</h2>
          <div class="mt-3 flex flex-wrap gap-1.5">
            <span v-for="interest in interests" :key="interest" class="rounded px-1.5 py-0.5 text-[0.786em]" style="background:rgba(255,255,255,0.15)">{{ interest }}</span>
          </div>
        </div>
      </template>
    </aside>

    <!-- Main content -->
    <main class="flex-1 px-7 py-8">
      <template v-for="section in mainSections" :key="section">

        <!-- Summary -->
        <section v-if="section === 'summary' && personal.summary" class="mb-7">
          <h2 class="text-[0.714em] font-bold uppercase tracking-[0.2em]" :style="{ color: primaryHex }">{{ t('builder.summary') }}</h2>
          <p class="mt-3 text-[0.929em] leading-7 text-slate-600">{{ personal.summary }}</p>
        </section>

        <!-- Experience -->
        <section v-if="section === 'experience' && experiences.length" class="mb-7">
          <h2 class="text-[0.714em] font-bold uppercase tracking-[0.2em]" :style="{ color: primaryHex }">{{ t('builder.experience') }}</h2>
          <div v-for="exp in experiences" :key="exp.id || exp.role" class="mt-3 resume-card border-l-2 pl-4" :style="{ borderColor: primaryHex + '50' }">
            <div class="flex flex-wrap items-baseline justify-between gap-2">
              <p class="font-semibold text-ink">{{ exp.role }}</p>
              <p v-if="exp.startDate || exp.endDate" class="text-[0.786em] text-slate-400">{{ dateRange(exp.startDate, exp.endDate) }}</p>
            </div>
            <p class="text-slate-500">{{ exp.company }}</p>
            <p v-if="exp.description" class="mt-1.5 text-[0.857em] leading-6 text-slate-600">{{ exp.description }}</p>
          </div>
        </section>

        <!-- Education -->
        <section v-if="section === 'education' && educations.length" class="mb-7">
          <h2 class="text-[0.714em] font-bold uppercase tracking-[0.2em]" :style="{ color: primaryHex }">{{ t('builder.education') }}</h2>
          <div v-for="edu in educations" :key="edu.id || edu.school" class="mt-3 resume-card">
            <div class="flex flex-wrap items-baseline justify-between gap-2">
              <p class="font-semibold text-ink">{{ edu.school }}</p>
              <p v-if="edu.startDate || edu.endDate" class="text-[0.786em] text-slate-400">{{ dateRange(edu.startDate, edu.endDate) }}</p>
            </div>
            <p v-if="edu.degree" class="text-slate-500">{{ edu.degree }}</p>
            <p v-if="edu.cgpa" class="text-[0.786em] text-slate-400">CGPA: {{ edu.cgpa }}</p>
          </div>
        </section>

        <!-- Projects -->
        <section v-if="section === 'projects' && projects.length" class="mb-7">
          <h2 class="text-[0.714em] font-bold uppercase tracking-[0.2em]" :style="{ color: primaryHex }">{{ t('builder.projects') }}</h2>
          <div v-for="proj in projects" :key="proj.id || proj.projectName" class="mt-3 resume-card">
            <div class="flex flex-wrap items-baseline gap-2">
              <p class="font-semibold text-ink">{{ proj.projectName }}</p>
              <a v-if="proj.projectLink" :href="proj.projectLink" class="text-[0.786em]" :style="{ color: primaryHex }">Link ↗</a>
            </div>
            <p v-if="proj.technologies" class="text-[0.786em] font-medium text-slate-400">{{ proj.technologies }}</p>
            <p v-if="proj.description" class="mt-1 text-[0.857em] leading-6 text-slate-600">{{ proj.description }}</p>
          </div>
        </section>

        <!-- Achievements -->
        <section v-if="section === 'achievements' && achievements.length" class="mb-7">
          <h2 class="text-[0.714em] font-bold uppercase tracking-[0.2em]" :style="{ color: primaryHex }">{{ t('builder.achievements') }}</h2>
          <ul class="mt-3 space-y-1.5 list-disc pl-4">
            <li v-for="ach in achievements" :key="ach.id || ach.title" class="text-[0.857em] text-slate-700">
              <span class="font-semibold">{{ ach.title }}</span>
              <span v-if="ach.description" class="text-slate-500"> — {{ ach.description }}</span>
            </li>
          </ul>
        </section>
      </template>
    </main>
  </div>
</template>

<script setup>
import { computed } from 'vue'
import {
  contactItems, normalizeExperiences, normalizeEducations, normalizeProjects,
  normalizeCertifications, normalizeLanguages, normalizeAchievements, normalizeInterests,
  dateRange, primaryColorHex, appearanceStyle
} from './templateHelpers'
import { buildRenderableSections } from '../../../utils/profileToResume'
import { t } from '../../../utils/i18n'

const props = defineProps({
  title:      String,
  content:    { type: Object, required: true },
  appearance: { type: Object, default: () => ({}) },
  sectionOrder:      { type: Array, default: () => [] },
  sectionVisibility: { type: Object, default: () => ({}) }
})

const personal       = computed(() => props.content.personal || {})
const skills         = computed(() => props.content.skills || {})
const contacts       = computed(() => contactItems(personal.value))
const experiences    = computed(() => normalizeExperiences(props.content))
const educations     = computed(() => normalizeEducations(props.content))
const projects       = computed(() => normalizeProjects(props.content))
const certifications = computed(() => normalizeCertifications(props.content))
const languages      = computed(() => normalizeLanguages(props.content))
const achievements   = computed(() => normalizeAchievements(props.content))
const interests      = computed(() => normalizeInterests(props.content))

const primaryHex  = computed(() => primaryColorHex(props.appearance))
const appearStyle = computed(() => appearanceStyle(props.appearance))

const visibleSections = computed(() => buildRenderableSections({
  sectionOrder: props.sectionOrder,
  sectionVisibility: props.sectionVisibility
}))

const sidebarSections = computed(() => visibleSections.value.filter(s => ['skills', 'languages', 'certifications', 'interests'].includes(s)))
const mainSections = computed(() => visibleSections.value.filter(s => ['summary', 'experience', 'education', 'projects', 'achievements'].includes(s)))
</script>
