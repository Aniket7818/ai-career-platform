<template>
  <div class="space-y-4">
    <div class="flex items-center justify-between gap-3">
      <p class="text-xs font-bold uppercase tracking-wider text-slate-500">{{ t('resumes.template') }}</p>
      <span class="rounded-full px-2.5 py-1 text-[10px] font-bold uppercase tracking-wider" :class="atsBadgeClass">
        Overall ATS {{ atsScore }}
      </span>
    </div>
    
    <div class="grid grid-cols-2 gap-3">
      <button
        v-for="tpl in RESUME_TEMPLATES"
        :key="tpl.id"
        type="button"
        class="group relative flex flex-col items-start overflow-hidden rounded-xl border-2 text-left transition-all duration-200"
        :class="modelValue === tpl.id
          ? 'border-brand bg-brand/5 shadow-md shadow-brand/10'
          : 'border-slate-100 bg-white hover:border-brand/30 hover:shadow-sm'"
        @click="$emit('update:modelValue', tpl.id)"
      >
        <!-- Mock visual preview area -->
        <div class="h-20 w-full bg-slate-50/80 border-b border-slate-100 p-2 flex flex-col gap-1.5 opacity-80 transition-opacity group-hover:opacity-100">
          <div class="h-2 w-1/2 bg-slate-200 rounded"></div>
          <div class="h-1.5 w-3/4 bg-slate-200 rounded"></div>
          <div class="h-1.5 w-full bg-slate-200 rounded"></div>
          <div class="h-1.5 w-5/6 bg-slate-200 rounded"></div>
        </div>
        
        <div class="p-3 w-full">
          <div class="flex items-center justify-between mb-1">
            <span class="text-sm font-bold text-ink" :class="{ 'text-brand': modelValue === tpl.id }">{{ tpl.label }}</span>
            <div v-if="modelValue === tpl.id" class="size-4 rounded-full bg-brand flex items-center justify-center text-white">
              <svg class="size-2.5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3"><path d="M20 6L9 17l-5-5"/></svg>
            </div>
          </div>
          <p class="text-[10px] text-slate-500 line-clamp-2 leading-snug">{{ tpl.description }}</p>
        </div>
      </button>
    </div>
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
