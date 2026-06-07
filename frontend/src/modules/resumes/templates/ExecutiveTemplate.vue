<template>
  <div class="min-h-[420px] text-[13px] leading-relaxed text-ink sm:min-h-[560px] lg:min-h-[720px]">
    <header class="bg-ink px-5 py-6 text-white sm:px-8 sm:py-9">
      <h1 class="text-2xl font-bold tracking-tight sm:text-[30px]">{{ personal.fullName || title }}</h1>
      <p v-if="personal.headline" class="mt-2 text-[15px] font-medium text-slate-300">{{ personal.headline }}</p>
      <p v-if="line" class="mt-4 text-[11px] text-slate-400">{{ line }}</p>
    </header>
    <div class="grid gap-0 px-8 py-8 lg:grid-cols-2 lg:gap-10">
      <section v-if="personal.summary" class="lg:col-span-2">
        <h2 class="text-[10px] font-bold uppercase tracking-[0.2em] text-brand">{{ t('builder.summary') }}</h2>
        <p class="mt-3 text-[13px] leading-7 text-slate-700">{{ personal.summary }}</p>
      </section>
      <section v-if="experience.role || experience.company">
        <h2 class="text-[10px] font-bold uppercase tracking-[0.2em] text-brand">{{ t('builder.experience') }}</h2>
        <div class="mt-4 rounded-lg border border-slate-200 bg-slate-50 p-4">
          <p class="text-[15px] font-bold">{{ experience.role }}</p>
          <p class="mt-1 font-medium text-slate-600">{{ experience.company }}</p>
        </div>
      </section>
      <section v-if="education.school">
        <h2 class="text-[10px] font-bold uppercase tracking-[0.2em] text-brand">{{ t('builder.education') }}</h2>
        <p class="mt-4 text-[14px] font-semibold">{{ education.school }}</p>
      </section>
      <section v-if="projects.projectName">
        <h2 class="text-[10px] font-bold uppercase tracking-[0.2em] text-brand">{{ t('builder.projects') }}</h2>
        <p class="mt-4 font-semibold">{{ projects.projectName }}</p>
      </section>
      <section v-if="skills.skillList">
        <h2 class="text-[10px] font-bold uppercase tracking-[0.2em] text-brand">{{ t('builder.skills') }}</h2>
        <p class="mt-4 text-slate-700">{{ skills.skillList }}</p>
      </section>
      <section v-if="certifications.certName" class="lg:col-span-2">
        <h2 class="text-[10px] font-bold uppercase tracking-[0.2em] text-brand">{{ t('builder.certifications') }}</h2>
        <p class="mt-4 font-semibold">{{ certifications.certName }}</p>
      </section>
    </div>
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
