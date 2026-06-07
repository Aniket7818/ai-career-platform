<template>
  <article class="min-h-[420px] overflow-hidden rounded-2xl border border-slate-100 bg-white shadow-panel sm:min-h-[560px] lg:min-h-[720px]">
    <div class="flex items-center justify-between border-b border-slate-100 bg-gradient-to-r from-brand/5 to-mint/5 px-6 py-3">
      <p class="text-[10px] font-bold uppercase tracking-widest text-brand">{{ t('resumes.preview') }}</p>
      <span v-if="showAts" class="rounded-full bg-emerald-500/15 px-2.5 py-1 text-[10px] font-bold uppercase tracking-wider text-emerald-700">
        ATS {{ atsScore }}
      </span>
    </div>
    <component :is="activeComponent" :title="title" :content="content" />
  </article>
</template>

<script setup>
import { computed } from 'vue'
import ModernTemplate from './templates/ModernTemplate.vue'
import ProfessionalTemplate from './templates/ProfessionalTemplate.vue'
import MinimalTemplate from './templates/MinimalTemplate.vue'
import ExecutiveTemplate from './templates/ExecutiveTemplate.vue'
import FresherTemplate from './templates/FresherTemplate.vue'
import { DEFAULT_TEMPLATE_ID } from '../../constants/templates'
import { calculateAtsScore } from '../../utils/profileToResume'
import { t } from '../../utils/i18n'

const TEMPLATE_MAP = {
  modern: ModernTemplate,
  professional: ProfessionalTemplate,
  minimal: MinimalTemplate,
  executive: ExecutiveTemplate,
  fresher: FresherTemplate
}

const props = defineProps({
  title: String,
  content: { type: Object, required: true },
  templateId: { type: String, default: DEFAULT_TEMPLATE_ID },
  showAts: { type: Boolean, default: true }
})

const activeComponent = computed(() => TEMPLATE_MAP[props.templateId] || ModernTemplate)
const atsScore = computed(() => calculateAtsScore(props.content))
</script>
