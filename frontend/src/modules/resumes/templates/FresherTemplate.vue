<template>
 <div
 class="text-[0.929em] leading-relaxed"
 :style="{ color: '#0f172a', ...appearStyle }"
 >
 <header class="border-b-4 px-8 py-8" :style="{ borderColor: primaryHex, background: `linear-gradient(to right, ${primaryHex}0d, transparent)` }">
 <p class="text-[0.714em] font-bold uppercase tracking-[0.2em]" :style="{ color: primaryHex }">Open to opportunities</p>
 <h1 class="mt-2 text-[1.857em] font-bold">{{ personal.fullName || title }}</h1>
 <p v-if="personal.headline" class="mt-1.5 font-semibold text-txt-secondary">{{ personal.headline }}</p>
 <div v-if="contacts.length" class="mt-4 flex flex-wrap gap-x-4 gap-y-1 text-[0.786em] text-txt-muted">
 <span v-for="item in contacts" :key="item.label">{{ item.value }}</span>
 </div>
 </header>

 <div class="space-y-7 px-8 py-8">
 <template v-for="section in visibleSections" :key="section">

 <!-- Summary -->
 <section v-if="section === 'summary' && personal.summary">
 <h2 class="flex items-center gap-2 text-[0.786em] font-bold uppercase tracking-[0.15em]" :style="{ color: primaryHex }">
 <span class="size-2 rounded-full shrink-0" :style="{ backgroundColor: primaryHex }" />
 {{ t('builder.summary') }}
 </h2>
 <p class="mt-3 leading-7 text-txt-secondary">{{ personal.summary }}</p>
 </section>

 <!-- Experience -->
 <section v-if="section === 'experience' && experiences.length">
 <h2 class="flex items-center gap-2 text-[0.786em] font-bold uppercase tracking-[0.15em]" :style="{ color: primaryHex }">
 <span class="size-2 rounded-full shrink-0" :style="{ backgroundColor: primaryHex }" />
 {{ t('builder.experience') }}
 </h2>
 <div v-for="exp in experiences" :key="exp.id || exp.role" class="mt-3 resume-card">
 <div class="flex flex-wrap items-baseline justify-between gap-2">
 <p class="font-semibold">{{ exp.role }}</p>
 <p v-if="exp.startDate || exp.endDate" class="text-[0.786em] text-txt-disabled">{{ dateRange(exp.startDate, exp.endDate) }}</p>
 </div>
 <p class="text-txt-muted">{{ exp.company }}</p>
 <p v-if="exp.description" class="mt-1.5 text-[0.857em] leading-6 text-txt-secondary">{{ exp.description }}</p>
 </div>
 </section>

 <!-- Education -->
 <section v-if="section === 'education' && educations.length">
 <h2 class="flex items-center gap-2 text-[0.786em] font-bold uppercase tracking-[0.15em]" :style="{ color: primaryHex }">
 <span class="size-2 rounded-full shrink-0" :style="{ backgroundColor: primaryHex }" />
 {{ t('builder.education') }}
 </h2>
 <div v-for="edu in educations" :key="edu.id || edu.school" class="mt-3 resume-card">
 <div class="flex flex-wrap items-baseline justify-between gap-2">
 <p class="text-[1.071em] font-semibold">{{ edu.school }}</p>
 <p v-if="edu.startDate || edu.endDate" class="text-[0.786em] text-txt-disabled">{{ dateRange(edu.startDate, edu.endDate) }}</p>
 </div>
 <p v-if="edu.degree" class="text-txt-muted">{{ edu.degree }}</p>
 <p v-if="edu.cgpa" class="text-[0.786em] text-txt-disabled">CGPA: {{ edu.cgpa }}</p>
 </div>
 </section>

 <!-- Projects -->
 <section v-if="section === 'projects' && projects.length">
 <h2 class="flex items-center gap-2 text-[0.786em] font-bold uppercase tracking-[0.15em]" :style="{ color: primaryHex }">
 <span class="size-2 rounded-full shrink-0" :style="{ backgroundColor: primaryHex }" />
 {{ t('builder.projects') }}
 </h2>
 <div v-for="proj in projects" :key="proj.id || proj.projectName" class="mt-3 resume-card">
 <div class="flex flex-wrap items-baseline gap-2">
 <p class="font-semibold">{{ proj.projectName }}</p>
 <a v-if="proj.projectLink" :href="proj.projectLink" class="text-[0.786em]" :style="{ color: primaryHex }">Link ↗</a>
 </div>
 <p v-if="proj.technologies" class="text-[0.786em] text-txt-disabled">{{ proj.technologies }}</p>
 <p v-if="proj.description" class="mt-1 text-[0.857em] text-txt-secondary">{{ proj.description }}</p>
 </div>
 </section>

 <!-- Skills -->
 <section v-if="section === 'skills' && skills.skillList">
 <h2 class="flex items-center gap-2 text-[0.786em] font-bold uppercase tracking-[0.15em]" :style="{ color: primaryHex }">
 <span class="size-2 rounded-full shrink-0" :style="{ backgroundColor: primaryHex }" />
 {{ t('builder.skills') }}
 </h2>
 <div class="mt-3 flex flex-wrap gap-2">
 <span
 v-for="skill in skillTags"
 :key="skill"
 class="rounded-md px-2.5 py-1 text-[0.786em] font-semibold"
 :style="{ backgroundColor: primaryHex + '18', color: primaryHex }"
 >{{ skill }}</span>
 </div>
 </section>

 <!-- Certifications -->
 <section v-if="section === 'certifications' && certifications.length">
 <h2 class="flex items-center gap-2 text-[0.786em] font-bold uppercase tracking-[0.15em]" :style="{ color: primaryHex }">
 <span class="size-2 rounded-full shrink-0" :style="{ backgroundColor: primaryHex }" />
 {{ t('builder.certifications') }}
 </h2>
 <div v-for="cert in certifications" :key="cert.id || cert.certName" class="mt-3 resume-card">
 <p class="font-medium">{{ cert.certName }}</p>
 <p v-if="cert.issuingOrg" class="text-[0.786em] text-txt-disabled">{{ cert.issuingOrg }}<span v-if="cert.issueDate"> · {{ cert.issueDate }}</span></p>
 </div>
 </section>

 <!-- Languages -->
 <section v-if="section === 'languages' && languages.length">
 <h2 class="flex items-center gap-2 text-[0.786em] font-bold uppercase tracking-[0.15em]" :style="{ color: primaryHex }">
 <span class="size-2 rounded-full shrink-0" :style="{ backgroundColor: primaryHex }" />
 {{ t('builder.languages') }}
 </h2>
 <div class="mt-3 flex flex-wrap gap-x-6 gap-y-1">
 <p v-for="lang in languages" :key="lang.id" class="text-[0.857em]">
 {{ lang.language }}<span v-if="lang.proficiency" class="text-txt-disabled"> — {{ lang.proficiency }}</span>
 </p>
 </div>
 </section>

 <!-- Achievements -->
 <section v-if="section === 'achievements' && achievements.length">
 <h2 class="flex items-center gap-2 text-[0.786em] font-bold uppercase tracking-[0.15em]" :style="{ color: primaryHex }">
 <span class="size-2 rounded-full shrink-0" :style="{ backgroundColor: primaryHex }" />
 {{ t('builder.achievements') }}
 </h2>
 <ul class="mt-3 space-y-1 list-disc pl-5">
 <li v-for="ach in achievements" :key="ach.id || ach.title" class="text-[0.857em] text-txt-secondary">
 <span class="font-semibold">{{ ach.title }}</span>
 <span v-if="ach.description" class="text-txt-muted"> — {{ ach.description }}</span>
 </li>
 </ul>
 </section>

 <!-- Interests -->
 <section v-if="section === 'interests' && interests.length">
 <h2 class="flex items-center gap-2 text-[0.786em] font-bold uppercase tracking-[0.15em]" :style="{ color: primaryHex }">
 <span class="size-2 rounded-full shrink-0" :style="{ backgroundColor: primaryHex }" />
 {{ t('builder.interests') }}
 </h2>
 <div class="mt-3 flex flex-wrap gap-2">
 <span
 v-for="interest in interests"
 :key="interest"
 class="rounded-md px-2.5 py-1 text-[0.786em] font-medium text-txt-secondary bg-surface-hover"
 >{{ interest }}</span>
 </div>
 </section>
 </template>
 </div>
 </div>
</template>

<script setup>
import { computed } from 'vue'
import {
 contactItems, normalizeExperiences, normalizeEducations, normalizeProjects,
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
const contacts = computed(() => contactItems(personal.value))
const experiences = computed(() => normalizeExperiences(props.content))
const educations = computed(() => normalizeEducations(props.content))
const projects = computed(() => normalizeProjects(props.content))
const certifications = computed(() => normalizeCertifications(props.content))
const languages = computed(() => normalizeLanguages(props.content))
const achievements = computed(() => normalizeAchievements(props.content))
const interests = computed(() => normalizeInterests(props.content))
const skillTags = computed(() => (skills.value.skillList || '').split(',').map((s) => s.trim()).filter(Boolean))
const primaryHex = computed(() => primaryColorHex(props.appearance))
const appearStyle = computed(() => appearanceStyle(props.appearance))

const defaultOrder = ['summary', 'experience', 'education', 'projects', 'skills', 'certifications', 'languages', 'achievements', 'interests']
const visibleSections = computed(() => {
 const order = props.sectionOrder?.length ? props.sectionOrder : defaultOrder
 const vis = props.sectionVisibility || {}
 return order.filter((s) => vis[s] !== false)
})
</script>
