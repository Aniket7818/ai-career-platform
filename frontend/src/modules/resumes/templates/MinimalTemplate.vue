<template>
  <div class="min-h-[420px] px-5 py-6 text-[13px] leading-relaxed text-ink sm:min-h-[560px] sm:px-8 sm:py-8 lg:min-h-[720px] lg:px-10 lg:py-10">
    <header class="pb-8">
      <h1 class="text-[28px] font-light tracking-tight">{{ personal.fullName || title }}</h1>
      <p v-if="personal.headline" class="mt-2 text-[13px] font-medium text-slate-500">{{ personal.headline }}</p>
      <p v-if="line" class="mt-4 text-[11px] tracking-wide text-slate-400">{{ line }}</p>
    </header>
    <section v-if="personal.summary" class="border-t border-slate-200 py-6">
      <p class="text-[13px] leading-8 text-slate-600">{{ personal.summary }}</p>
    </section>
    <section v-if="experience.role || experience.company" class="border-t border-slate-200 py-6">
      <h2 class="text-[10px] font-medium uppercase tracking-[0.25em] text-slate-400">{{ t('builder.experience') }}</h2>
      <p class="mt-4 text-[14px] font-medium">{{ experience.role }}</p>
      <p class="mt-0.5 text-slate-500">{{ experience.company }}</p>
    </section>
    <section v-if="education.school" class="border-t border-slate-200 py-6">
      <h2 class="text-[10px] font-medium uppercase tracking-[0.25em] text-slate-400">{{ t('builder.education') }}</h2>
      <p class="mt-4 text-[14px]">{{ education.school }}</p>
    </section>
    <section v-if="projects.projectName" class="border-t border-slate-200 py-6">
      <h2 class="text-[10px] font-medium uppercase tracking-[0.25em] text-slate-400">{{ t('builder.projects') }}</h2>
      <p class="mt-4 text-[14px]">{{ projects.projectName }}</p>
    </section>
    <section v-if="skills.skillList" class="border-t border-slate-200 py-6">
      <h2 class="text-[10px] font-medium uppercase tracking-[0.25em] text-slate-400">{{ t('builder.skills') }}</h2>
      <p class="mt-4 text-slate-600">{{ skills.skillList }}</p>
    </section>
    <section v-if="certifications.certName" class="border-t border-slate-200 py-6">
      <h2 class="text-[10px] font-medium uppercase tracking-[0.25em] text-slate-400">{{ t('builder.certifications') }}</h2>
      <p class="mt-4">{{ certifications.certName }}</p>
    </section>
  </div>
</template>

<script setup>
import { computed } from 'vue'
import { contactLine } from './templateHelpers'
import { t } from '../../../utils/i18n'

const props = defineProps({ title: String, content: { type: Object, required: true } })
const personal = computed(() => props.content.personal || {})
const experience = computed(() => props.content.experience || {})
const education = computed(() => props.content.education || {})
const projects = computed(() => props.content.projects || {})
const skills = computed(() => props.content.skills || {})
const certifications = computed(() => props.content.certifications || {})
const line = computed(() => contactLine(personal.value))
</script>
