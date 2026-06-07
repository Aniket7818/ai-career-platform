<template>
  <div class="min-h-[420px] text-[13px] leading-relaxed text-ink sm:min-h-[560px] lg:min-h-[720px]">
    <header class="border-b-4 border-brand bg-gradient-to-r from-brand/5 to-mint/5 px-8 py-8">
      <p class="text-[10px] font-bold uppercase tracking-[0.2em] text-brand">Open to opportunities</p>
      <h1 class="mt-2 text-[26px] font-bold">{{ personal.fullName || title }}</h1>
      <p v-if="personal.headline" class="mt-1.5 font-semibold text-slate-600">{{ personal.headline }}</p>
      <div v-if="contacts.length" class="mt-4 flex flex-wrap gap-x-4 gap-y-1 text-[11px] text-slate-500">
        <span v-for="item in contacts" :key="item.label">{{ item.value }}</span>
      </div>
    </header>
    <div class="space-y-7 px-8 py-8">
      <section v-if="education.school">
        <h2 class="flex items-center gap-2 text-[11px] font-bold uppercase tracking-[0.15em] text-brand">
          <span class="size-2 rounded-full bg-brand" />{{ t('builder.education') }}
        </h2>
        <p class="mt-3 text-[15px] font-semibold">{{ education.school }}</p>
      </section>
      <section v-if="personal.summary">
        <h2 class="flex items-center gap-2 text-[11px] font-bold uppercase tracking-[0.15em] text-brand">
          <span class="size-2 rounded-full bg-brand" />{{ t('builder.summary') }}
        </h2>
        <p class="mt-3 leading-7 text-slate-600">{{ personal.summary }}</p>
      </section>
      <section v-if="projects.projectName">
        <h2 class="flex items-center gap-2 text-[11px] font-bold uppercase tracking-[0.15em] text-brand">
          <span class="size-2 rounded-full bg-brand" />{{ t('builder.projects') }}
        </h2>
        <p class="mt-3 font-semibold">{{ projects.projectName }}</p>
      </section>
      <section v-if="skills.skillList">
        <h2 class="flex items-center gap-2 text-[11px] font-bold uppercase tracking-[0.15em] text-brand">
          <span class="size-2 rounded-full bg-brand" />{{ t('builder.skills') }}
        </h2>
        <div class="mt-3 flex flex-wrap gap-2">
          <span v-for="skill in skillTags" :key="skill" class="rounded-md bg-brand/10 px-2.5 py-1 text-[11px] font-semibold text-brand">{{ skill }}</span>
        </div>
      </section>
      <section v-if="experience.role || experience.company">
        <h2 class="flex items-center gap-2 text-[11px] font-bold uppercase tracking-[0.15em] text-brand">
          <span class="size-2 rounded-full bg-brand" />{{ t('builder.experience') }}
        </h2>
        <p class="mt-3 font-semibold">{{ experience.role }}</p>
        <p class="text-slate-500">{{ experience.company }}</p>
      </section>
      <section v-if="certifications.certName">
        <h2 class="flex items-center gap-2 text-[11px] font-bold uppercase tracking-[0.15em] text-brand">
          <span class="size-2 rounded-full bg-brand" />{{ t('builder.certifications') }}
        </h2>
        <p class="mt-3 font-medium">{{ certifications.certName }}</p>
      </section>
    </div>
  </div>
</template>

<script setup>
import { computed } from 'vue'
import { contactItems } from './templateHelpers'
import { t } from '../../../utils/i18n'

const props = defineProps({ title: String, content: { type: Object, required: true } })
const personal = computed(() => props.content.personal || {})
const experience = computed(() => props.content.experience || {})
const education = computed(() => props.content.education || {})
const projects = computed(() => props.content.projects || {})
const skills = computed(() => props.content.skills || {})
const certifications = computed(() => props.content.certifications || {})
const contacts = computed(() => contactItems(personal.value))
const skillTags = computed(() => (skills.value.skillList || '').split(',').map((s) => s.trim()).filter(Boolean))
</script>
