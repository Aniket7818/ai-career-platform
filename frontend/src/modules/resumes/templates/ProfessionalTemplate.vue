<template>
  <div class="min-h-[420px] px-5 py-6 text-[13px] leading-relaxed text-ink sm:min-h-[560px] sm:px-8 sm:py-9 lg:min-h-[720px]">
    <header class="border-b-2 border-ink pb-5 text-center">
      <h1 class="text-[26px] font-bold tracking-tight">{{ personal.fullName || title }}</h1>
      <p v-if="personal.headline" class="mt-1.5 text-[14px] font-semibold text-slate-600">{{ personal.headline }}</p>
      <p v-if="line" class="mt-3 text-[11px] text-slate-500">{{ line }}</p>
    </header>
    <section v-if="personal.summary" class="mt-6">
      <h2 class="border-b border-slate-300 pb-1 text-[11px] font-bold uppercase tracking-[0.15em] text-ink">{{ t('builder.summary') }}</h2>
      <p class="mt-3 text-[13px] leading-7 text-slate-700">{{ personal.summary }}</p>
    </section>
    <section v-if="experience.role || experience.company" class="mt-6">
      <h2 class="border-b border-slate-300 pb-1 text-[11px] font-bold uppercase tracking-[0.15em] text-ink">{{ t('builder.experience') }}</h2>
      <div class="mt-3">
        <p class="font-semibold">{{ experience.role }}<span v-if="experience.company"> — {{ experience.company }}</span></p>
      </div>
    </section>
    <section v-if="education.school" class="mt-6">
      <h2 class="border-b border-slate-300 pb-1 text-[11px] font-bold uppercase tracking-[0.15em] text-ink">{{ t('builder.education') }}</h2>
      <p class="mt-3 font-medium">{{ education.school }}</p>
    </section>
    <section v-if="projects.projectName" class="mt-6">
      <h2 class="border-b border-slate-300 pb-1 text-[11px] font-bold uppercase tracking-[0.15em] text-ink">{{ t('builder.projects') }}</h2>
      <p class="mt-3 font-medium">{{ projects.projectName }}</p>
    </section>
    <section v-if="skills.skillList" class="mt-6">
      <h2 class="border-b border-slate-300 pb-1 text-[11px] font-bold uppercase tracking-[0.15em] text-ink">{{ t('builder.skills') }}</h2>
      <p class="mt-3 text-slate-700">{{ skills.skillList }}</p>
    </section>
    <section v-if="certifications.certName" class="mt-6">
      <h2 class="border-b border-slate-300 pb-1 text-[11px] font-bold uppercase tracking-[0.15em] text-ink">{{ t('builder.certifications') }}</h2>
      <p class="mt-3 font-medium">{{ certifications.certName }}</p>
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
