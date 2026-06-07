<template>
  <div class="flex min-h-[420px] flex-col text-[13px] leading-relaxed text-ink sm:min-h-[560px] sm:flex-row lg:min-h-[720px]">
    <aside class="w-full shrink-0 bg-ink px-5 py-6 text-white sm:w-[34%] sm:px-6 sm:py-8">
      <h1 class="text-[22px] font-bold leading-tight">{{ personal.fullName || title }}</h1>
      <p v-if="personal.headline" class="mt-2 text-sm font-medium text-brand">{{ personal.headline }}</p>
      <div v-if="contacts.length" class="mt-6 space-y-2.5 border-t border-white/10 pt-5">
        <p v-for="item in contacts" :key="item.label" class="break-all text-[11px] text-slate-300">
          <span class="font-semibold uppercase tracking-wider text-slate-500">{{ item.label }}</span><br />{{ item.value }}
        </p>
      </div>
      <div v-if="skills.skillList" class="mt-6 border-t border-white/10 pt-5">
        <h2 class="text-[10px] font-bold uppercase tracking-[0.2em] text-mint">{{ t('builder.skills') }}</h2>
        <p class="mt-3 text-[12px] leading-6 text-slate-200">{{ skills.skillList }}</p>
      </div>
      <div v-if="certifications.certName" class="mt-6 border-t border-white/10 pt-5">
        <h2 class="text-[10px] font-bold uppercase tracking-[0.2em] text-mint">{{ t('builder.certifications') }}</h2>
        <p class="mt-3 text-[12px] text-slate-200">{{ certifications.certName }}</p>
      </div>
    </aside>
    <main class="flex-1 px-7 py-8">
      <section v-if="personal.summary">
        <h2 class="text-[10px] font-bold uppercase tracking-[0.2em] text-brand">{{ t('builder.summary') }}</h2>
        <p class="mt-3 text-[13px] leading-7 text-slate-600">{{ personal.summary }}</p>
      </section>
      <section v-if="experience.role || experience.company" class="mt-7">
        <h2 class="text-[10px] font-bold uppercase tracking-[0.2em] text-brand">{{ t('builder.experience') }}</h2>
        <div class="mt-3 border-l-2 border-brand/30 pl-4">
          <p class="font-semibold text-ink">{{ experience.role }}</p>
          <p class="text-slate-500">{{ experience.company }}</p>
        </div>
      </section>
      <section v-if="education.school" class="mt-7">
        <h2 class="text-[10px] font-bold uppercase tracking-[0.2em] text-brand">{{ t('builder.education') }}</h2>
        <p class="mt-3 font-medium text-ink">{{ education.school }}</p>
      </section>
      <section v-if="projects.projectName" class="mt-7">
        <h2 class="text-[10px] font-bold uppercase tracking-[0.2em] text-brand">{{ t('builder.projects') }}</h2>
        <p class="mt-3 font-medium text-ink">{{ projects.projectName }}</p>
      </section>
    </main>
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
</script>
