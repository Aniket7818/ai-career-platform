<template>
  <div class="space-y-3">
    <div class="flex items-center justify-between gap-3">
      <p class="text-xs font-bold uppercase tracking-wider text-slate-500">{{ t('resumes.template') }}</p>
      <span class="rounded-full px-2.5 py-1 text-[10px] font-bold uppercase tracking-wider" :class="atsBadgeClass">
        ATS {{ atsScore }}
      </span>
    </div>
    <div class="flex flex-wrap gap-2">
      <button
        v-for="tpl in RESUME_TEMPLATES"
        :key="tpl.id"
        type="button"
        class="rounded-lg border px-3.5 py-2 text-sm font-semibold transition"
        :class="modelValue === tpl.id
          ? 'border-brand bg-brand text-white shadow-md shadow-brand/20'
          : 'border-slate-200 bg-white text-slate-600 hover:border-brand/30 hover:text-brand'"
        @click="$emit('update:modelValue', tpl.id)"
      >
        {{ tpl.label }}
      </button>
    </div>
    <p class="text-xs text-slate-500">{{ activeTemplate.description }}</p>
  </div>
</template>

<script setup>
import { computed } from 'vue'
import { RESUME_TEMPLATES, templateById } from '../../constants/templates'
import { calculateAtsScore } from '../../utils/profileToResume'
import { t } from '../../utils/i18n'

const props = defineProps({
  modelValue: { type: String, required: true },
  content: { type: Object, default: () => ({}) }
})
defineEmits(['update:modelValue'])

const activeTemplate = computed(() => templateById(props.modelValue))
const atsScore = computed(() => calculateAtsScore(props.content))
const atsBadgeClass = computed(() => {
  if (atsScore.value >= 90) return 'bg-emerald-500/15 text-emerald-700'
  if (atsScore.value >= 70) return 'bg-amber-500/15 text-amber-700'
  return 'bg-slate-200 text-slate-600'
})
</script>
