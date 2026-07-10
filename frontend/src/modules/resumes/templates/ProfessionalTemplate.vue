<template>
 <div
 class="px-8 py-9 text-[0.929em] leading-relaxed"
 :style="{ color: '#0f172a', ...appearStyle }"
 >
 <header class="border-b-2 border-border pb-5 text-center">
 <h1 class="text-[1.857em] font-bold tracking-tight">{{ personal.fullName || title }}</h1>
 <p v-if="personal.headline" class="mt-1.5 text-[1em] font-semibold text-txt-secondary">{{ personal.headline }}</p>
 <p v-if="contactStr" class="mt-3 text-[0.786em] text-txt-muted">{{ contactStr }}</p>
 </header>

 <template v-for="section in visibleSections" :key="section">

 <!-- Summary -->
 <section v-if="section === 'summary' && personal.summary" class="mt-6">
 <h2 class="border-b border-border-hover pb-1 text-[0.786em] font-bold uppercase tracking-[0.15em] text-txt-primary">{{ t('builder.summary') }}</h2>
 <p class="mt-3 text-[0.929em] leading-7 text-txt-secondary">{{ personal.summary }}</p>
 </section>

 <!-- Experience -->
 <section v-if="section === 'experience' && experiences.length" class="mt-6">
 <h2 class="border-b border-border-hover pb-1 text-[0.786em] font-bold uppercase tracking-[0.15em] text-txt-primary">{{ t('builder.experience') }}</h2>
 <div v-for="exp in experiences" :key="exp.id || exp.role" class="mt-4 resume-card">
 <div class="flex flex-wrap items-baseline justify-between gap-2">
 <p class="font-semibold">{{ exp.role }}<span v-if="exp.company"> — {{ exp.company }}</span></p>
 <p v-if="exp.startDate || exp.endDate" class="text-[0.786em] text-txt-disabled">{{ dateRange(exp.startDate, exp.endDate) }}</p>
 </div>
 <p v-if="exp.description" class="mt-1 text-[0.857em] leading-6 text-txt-secondary">{{ exp.description }}</p>
 </div>
 </section>

 <!-- Education -->
 <section v-if="section === 'education' && educations.length" class="mt-6">
 <h2 class="border-b border-border-hover pb-1 text-[0.786em] font-bold uppercase tracking-[0.15em] text-txt-primary">{{ t('builder.education') }}</h2>
 <div v-for="edu in educations" :key="edu.id || edu.school" class="mt-3 resume-card">
 <div class="flex flex-wrap items-baseline justify-between gap-2">
 <p class="font-medium">{{ edu.school }}</p>
 <p v-if="edu.startDate || edu.endDate" class="text-[0.786em] text-txt-disabled">{{ dateRange(edu.startDate, edu.endDate) }}</p>
 </div>
 <p v-if="edu.degree" class="text-[0.857em] text-txt-muted">{{ edu.degree }}</p>
 <p v-if="edu.cgpa" class="text-[0.786em] text-txt-disabled">CGPA: {{ edu.cgpa }}</p>
 </div>
 </section>

 <!-- Projects -->
 <section v-if="section === 'projects' && projects.length" class="mt-6">
 <h2 class="border-b border-border-hover pb-1 text-[0.786em] font-bold uppercase tracking-[0.15em] text-txt-primary">{{ t('builder.projects') }}</h2>
 <div v-for="proj in projects" :key="proj.id || proj.projectName" class="mt-3 resume-card">
 <div class="flex flex-wrap items-baseline gap-2">
 <p class="font-medium">{{ proj.projectName }}</p>
 <a v-if="proj.projectLink" :href="proj.projectLink" class="text-[0.786em]" :style="{ color: primaryHex }">Link ↗</a>
 </div>
 <p v-if="proj.technologies" class="text-[0.786em] text-txt-disabled">{{ proj.technologies }}</p>
 <p v-if="proj.description" class="mt-1 text-[0.857em] text-txt-secondary">{{ proj.description }}</p>
 </div>
 </section>

 <!-- Skills -->
 <section v-if="section === 'skills' && skills.skillList" class="mt-6">
 <h2 class="border-b border-border-hover pb-1 text-[0.786em] font-bold uppercase tracking-[0.15em] text-txt-primary">{{ t('builder.skills') }}</h2>
 <p class="mt-3 text-txt-secondary">{{ skills.skillList }}</p>
 </section>

 <!-- Certifications -->
 <section v-if="section === 'certifications' && certifications.length" class="mt-6">
 <h2 class="border-b border-border-hover pb-1 text-[0.786em] font-bold uppercase tracking-[0.15em] text-txt-primary">{{ t('builder.certifications') }}</h2>
 <div v-for="cert in certifications" :key="cert.id || cert.certName" class="mt-3 resume-card">
 <p class="font-medium">{{ cert.certName }}</p>
 <p v-if="cert.issuingOrg" class="text-[0.786em] text-txt-muted">{{ cert.issuingOrg }}<span v-if="cert.issueDate"> · {{ cert.issueDate }}</span></p>
 </div>
 </section>

 <!-- Languages -->
 <section v-if="section === 'languages' && languages.length" class="mt-6">
 <h2 class="border-b border-border-hover pb-1 text-[0.786em] font-bold uppercase tracking-[0.15em] text-txt-primary">{{ t('builder.languages') }}</h2>
 <div class="mt-3 flex flex-wrap gap-x-6 gap-y-1">
 <p v-for="lang in languages" :key="lang.id" class="text-[0.857em]">
 {{ lang.language }}<span v-if="lang.proficiency" class="text-txt-disabled"> — {{ lang.proficiency }}</span>
 </p>
 </div>
 </section>

 <!-- Achievements -->
 <section v-if="section === 'achievements' && achievements.length" class="mt-6">
 <h2 class="border-b border-border-hover pb-1 text-[0.786em] font-bold uppercase tracking-[0.15em] text-txt-primary">{{ t('builder.achievements') }}</h2>
 <ul class="mt-3 space-y-1 list-disc pl-4">
 <li v-for="ach in achievements" :key="ach.id || ach.title" class="text-[0.857em] text-txt-secondary">
 <span class="font-semibold">{{ ach.title }}</span>
 <span v-if="ach.description" class="text-txt-muted"> — {{ ach.description }}</span>
 </li>
 </ul>
 </section>

 <!-- Interests -->
 <section v-if="section === 'interests' && interests.length" class="mt-6">
 <h2 class="border-b border-border-hover pb-1 text-[0.786em] font-bold uppercase tracking-[0.15em] text-txt-primary">{{ t('builder.interests') }}</h2>
 <p class="mt-3 text-[0.857em] text-txt-secondary">{{ interests.join(' · ') }}</p>
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
import { buildRenderableSections } from '../../../utils/profileToResume'
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

const visibleSections = computed(() => buildRenderableSections({
 sectionOrder: props.sectionOrder,
 sectionVisibility: props.sectionVisibility
}))
</script>
