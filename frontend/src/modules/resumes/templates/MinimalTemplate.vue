<template>
 <div
 class="px-10 py-10 text-[0.929em] leading-relaxed"
 :style="{ color: '#0f172a', ...appearStyle }"
 >
 <header class="pb-8">
 <h1 class="text-[2em] font-light tracking-tight">{{ personal.fullName || title }}</h1>
 <p v-if="personal.headline" class="mt-2 text-[0.929em] font-medium text-txt-muted">{{ personal.headline }}</p>
 <p v-if="contactStr" class="mt-4 text-[0.786em] tracking-wide text-txt-disabled">{{ contactStr }}</p>
 </header>

 <template v-for="section in visibleSections" :key="section">
 <!-- Summary -->
 <section v-if="section === 'summary' && personal.summary" class="border-t border-border py-6">
 <p class="text-[0.929em] leading-8 text-txt-secondary">{{ personal.summary }}</p>
 </section>

 <!-- Experience -->
 <section v-if="section === 'experience' && experiences.length" class="border-t border-border py-6">
 <h2 class="text-[0.714em] font-medium uppercase tracking-[0.25em] text-txt-disabled">{{ t('builder.experience') }}</h2>
 <div v-for="exp in experiences" :key="exp.id || exp.role" class="mt-4 resume-card">
 <div class="flex flex-wrap items-baseline justify-between gap-2">
 <p class="text-[1em] font-medium">{{ exp.role }}</p>
 <p v-if="exp.startDate || exp.endDate" class="text-[0.786em] text-txt-disabled">{{ dateRange(exp.startDate, exp.endDate) }}</p>
 </div>
 <p class="mt-0.5 text-txt-muted">{{ exp.company }}</p>
 <p v-if="exp.description" class="mt-1.5 text-[0.857em] leading-6 text-txt-secondary">{{ exp.description }}</p>
 </div>
 </section>

 <!-- Education -->
 <section v-if="section === 'education' && educations.length" class="border-t border-border py-6">
 <h2 class="text-[0.714em] font-medium uppercase tracking-[0.25em] text-txt-disabled">{{ t('builder.education') }}</h2>
 <div v-for="edu in educations" :key="edu.id || edu.school" class="mt-4 resume-card">
 <div class="flex flex-wrap items-baseline justify-between gap-2">
 <p class="text-[1em]">{{ edu.school }}</p>
 <p v-if="edu.startDate || edu.endDate" class="text-[0.786em] text-txt-disabled">{{ dateRange(edu.startDate, edu.endDate) }}</p>
 </div>
 <p v-if="edu.degree" class="text-[0.857em] text-txt-disabled">{{ edu.degree }}</p>
 <p v-if="edu.cgpa" class="text-[0.786em] text-txt-disabled">CGPA: {{ edu.cgpa }}</p>
 </div>
 </section>

 <!-- Projects -->
 <section v-if="section === 'projects' && projects.length" class="border-t border-border py-6">
 <h2 class="text-[0.714em] font-medium uppercase tracking-[0.25em] text-txt-disabled">{{ t('builder.projects') }}</h2>
 <div v-for="proj in projects" :key="proj.id || proj.projectName" class="mt-4 resume-card">
 <div class="flex flex-wrap items-baseline gap-2">
 <p class="text-[1em]">{{ proj.projectName }}</p>
 <a v-if="proj.projectLink" :href="proj.projectLink" class="text-[0.786em]" :style="{ color: primaryHex }">Link ↗</a>
 </div>
 <p v-if="proj.technologies" class="text-[0.786em] text-txt-disabled">{{ proj.technologies }}</p>
 <p v-if="proj.description" class="mt-1 text-[0.857em] text-txt-secondary">{{ proj.description }}</p>
 </div>
 </section>

 <!-- Skills -->
 <section v-if="section === 'skills' && skills.skillList" class="border-t border-border py-6">
 <h2 class="text-[0.714em] font-medium uppercase tracking-[0.25em] text-txt-disabled">{{ t('builder.skills') }}</h2>
 <p class="mt-4 text-txt-secondary">{{ skills.skillList }}</p>
 </section>

 <!-- Certifications -->
 <section v-if="section === 'certifications' && certifications.length" class="border-t border-border py-6">
 <h2 class="text-[0.714em] font-medium uppercase tracking-[0.25em] text-txt-disabled">{{ t('builder.certifications') }}</h2>
 <div v-for="cert in certifications" :key="cert.id || cert.certName" class="mt-4 resume-card">
 <p>{{ cert.certName }}</p>
 <p v-if="cert.issuingOrg" class="text-[0.786em] text-txt-disabled">{{ cert.issuingOrg }}<span v-if="cert.issueDate"> · {{ cert.issueDate }}</span></p>
 </div>
 </section>

 <!-- Languages -->
 <section v-if="section === 'languages' && languages.length" class="border-t border-border py-6">
 <h2 class="text-[0.714em] font-medium uppercase tracking-[0.25em] text-txt-disabled">{{ t('builder.languages') }}</h2>
 <div class="mt-4 flex flex-wrap gap-x-6 gap-y-1">
 <p v-for="lang in languages" :key="lang.id" class="text-[0.857em]">
 {{ lang.language }}<span v-if="lang.proficiency" class="text-txt-disabled"> — {{ lang.proficiency }}</span>
 </p>
 </div>
 </section>

 <!-- Achievements -->
 <section v-if="section === 'achievements' && achievements.length" class="border-t border-border py-6">
 <h2 class="text-[0.714em] font-medium uppercase tracking-[0.25em] text-txt-disabled">{{ t('builder.achievements') }}</h2>
 <ul class="mt-4 space-y-1 list-disc pl-4 text-[0.857em] text-txt-secondary">
 <li v-for="ach in achievements" :key="ach.id || ach.title">
 <span class="font-medium">{{ ach.title }}</span>
 <span v-if="ach.description" class="text-txt-muted"> — {{ ach.description }}</span>
 </li>
 </ul>
 </section>

 <!-- Interests -->
 <section v-if="section === 'interests' && interests.length" class="border-t border-border py-6">
 <h2 class="text-[0.714em] font-medium uppercase tracking-[0.25em] text-txt-disabled">{{ t('builder.interests') }}</h2>
 <p class="mt-4 text-[0.857em] text-txt-secondary">{{ interests.join(' · ') }}</p>
 </section>
 </template>
 </div>
</template>

<script setup>
import { computed } from 'vue'
import {
 contactLine, normalizeExperiences, normalizeEducations, normalizeProjects,
 normalizeCertifications, normalizeLanguages, normalizeAchievements, normalizeInterests,
 normalizePersonal, normalizeSkills,
 dateRange, primaryColorHex, appearanceStyle
} from './templateHelpers'
import { t } from '../../../utils/i18n'

const props = defineProps({
 title: String,
 content: { type: Object, required: true },
 appearance: { type: Object, default: () => ({}) },
 sectionOrder: { type: Array, default: () => [] },
 sectionVisibility: { type: Object, default: () => ({}) }
})

const personal = computed(() => normalizePersonal(props.content))
const skills = computed(() => normalizeSkills(props.content))
const contactStr = computed(() => contactLine(personal.value))
const experiences = computed(() => normalizeExperiences(props.content))
const educations = computed(() => normalizeEducations(props.content))
const projects = computed(() => normalizeProjects(props.content))
const certifications = computed(() => normalizeCertifications(props.content))
const languages = computed(() => normalizeLanguages(props.content))
const achievements = computed(() => normalizeAchievements(props.content))
const interests = computed(() => normalizeInterests(props.content))
const primaryHex = computed(() => primaryColorHex(props.appearance))
const appearStyle = computed(() => appearanceStyle(props.appearance))

const defaultOrder = ['summary', 'experience', 'education', 'projects', 'skills', 'certifications', 'languages', 'achievements', 'interests']
const visibleSections = computed(() => {
 const order = props.sectionOrder?.length ? props.sectionOrder : defaultOrder
 const vis = props.sectionVisibility || {}
 return order.filter((s) => vis[s] !== false)
})
</script>
