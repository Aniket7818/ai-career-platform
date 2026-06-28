<template>
  <div class="space-y-4">
    <div class="grid grid-cols-2 gap-3">
      <button
        v-for="tpl in RESUME_TEMPLATES"
        :key="tpl.id"
        type="button"
        class="group relative flex flex-col items-start overflow-hidden rounded-xl border-2 text-left transition-all duration-300 active:scale-[0.98]"
        :class="modelValue === tpl.id
          ? 'border-brand bg-brand/5 shadow-glow ring-2 ring-brand/10 scale-[1.02]'
          : 'border-slate-100 bg-white hover:border-brand/40 hover:shadow-sm hover:scale-[1.01]'"
        @click="$emit('update:modelValue', tpl.id)"
      >
        <!-- Mock visual miniature preview area -->
        <div class="h-20 w-full bg-slate-50/60 border-b border-slate-100 p-2 flex gap-1 overflow-hidden transition-all duration-300 group-hover:bg-slate-100/40">
          <!-- Modern: 2-column sidebar layout -->
          <template v-if="tpl.id === 'modern'">
            <div class="w-1/3 bg-brand/10 h-full rounded p-1 flex flex-col gap-1 shrink-0">
              <div class="h-1.5 w-full bg-brand/30 rounded-sm"></div>
              <div class="h-1 w-2/3 bg-brand/20 rounded-sm"></div>
              <div class="h-1 w-full bg-brand/20 rounded-sm"></div>
              <div class="h-1 w-4/5 bg-brand/20 rounded-sm"></div>
            </div>
            <div class="flex-1 h-full p-1 flex flex-col gap-1 shrink-0">
              <div class="h-1.5 w-1/2 bg-slate-300 rounded-sm"></div>
              <div class="h-1 w-full bg-slate-200 rounded-sm"></div>
              <div class="h-1 w-full bg-slate-200 rounded-sm"></div>
              <div class="h-1.5 w-1/3 bg-slate-300 rounded-sm mt-1"></div>
              <div class="h-1 w-full bg-slate-200 rounded-sm"></div>
            </div>
          </template>

          <!-- Professional: Standard clean layout -->
          <template v-else-if="tpl.id === 'professional'">
            <div class="w-full h-full p-1.5 flex flex-col gap-1 shrink-0">
              <div class="flex items-center justify-between border-b border-slate-200 pb-1 mb-0.5">
                <div class="h-2 w-1/3 bg-slate-400 rounded-sm"></div>
                <div class="h-1 w-1/4 bg-slate-300 rounded-sm"></div>
              </div>
              <div class="h-1 w-1/4 bg-slate-300 rounded-sm"></div>
              <div class="h-1 w-full bg-slate-200 rounded-sm"></div>
              <div class="h-1 w-5/6 bg-slate-200 rounded-sm"></div>
              <div class="h-1 w-1/4 bg-slate-300 rounded-sm mt-1"></div>
              <div class="h-1 w-full bg-slate-200 rounded-sm"></div>
            </div>
          </template>

          <!-- Minimal: Plenty of whitespace, elegant text columns -->
          <template v-else-if="tpl.id === 'minimal'">
            <div class="w-full h-full p-2 flex flex-col gap-1.5 justify-center shrink-0">
              <div class="h-2 w-1/4 bg-slate-400 rounded-sm"></div>
              <div class="h-1 w-1/2 bg-slate-300 rounded-sm"></div>
              <div class="h-1 w-full bg-slate-200 rounded-sm mt-1"></div>
              <div class="h-1 w-full bg-slate-200 rounded-sm"></div>
              <div class="h-1 w-2/3 bg-slate-200 rounded-sm"></div>
            </div>
          </template>

          <!-- Executive: Heavy header layout -->
          <template v-else-if="tpl.id === 'executive'">
            <div class="w-full h-full flex flex-col shrink-0">
              <div class="bg-slate-800 text-white p-1 px-1.5 flex items-center justify-between rounded-t-sm shrink-0">
                <div class="h-1.5 w-1/4 bg-slate-300 rounded-sm"></div>
                <div class="h-1 w-1/5 bg-slate-400 rounded-sm"></div>
              </div>
              <div class="p-1 flex-1 flex flex-col gap-1 bg-slate-50 shrink-0">
                <div class="h-1.5 w-1/3 bg-slate-400 rounded-sm"></div>
                <div class="h-1 w-full bg-slate-200 rounded-sm"></div>
                <div class="h-1 w-full bg-slate-200 rounded-sm"></div>
              </div>
            </div>
          </template>

          <!-- Fresher: Education-first layout -->
          <template v-else-if="tpl.id === 'fresher'">
            <div class="w-full h-full p-1.5 flex flex-col gap-1 shrink-0">
              <div class="flex flex-col gap-0.5 items-center mb-1">
                <div class="h-1.5 w-1/3 bg-slate-400 rounded-sm"></div>
                <div class="h-1 w-1/2 bg-slate-300 rounded-sm"></div>
              </div>
              <div class="flex gap-2 shrink-0">
                <div class="w-1/2 flex flex-col gap-1 shrink-0">
                  <div class="h-1 w-3/4 bg-brand/20 rounded-sm"></div>
                  <div class="h-1 w-full bg-slate-200 rounded-sm"></div>
                </div>
                <div class="w-1/2 flex flex-col gap-1 shrink-0">
                  <div class="h-1 w-3/4 bg-slate-300 rounded-sm"></div>
                  <div class="h-1 w-full bg-slate-200 rounded-sm"></div>
                </div>
              </div>
            </div>
          </template>
        </div>
        
        <div class="p-3 w-full">
          <div class="flex items-center justify-between mb-1">
            <span class="text-xs font-bold text-ink" :class="{ 'text-brand': modelValue === tpl.id }">{{ tpl.label }}</span>
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
