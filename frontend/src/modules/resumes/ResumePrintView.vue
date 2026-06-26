<template>
  <div v-if="resume" class="print-container" :style="containerBgStyle">
    <component
      :is="resolvedTemplate"
      :title="resume.title"
      :content="resume.content"
      :appearance="resume.content.appearance"
      :section-order="resume.content.sectionOrder"
      :section-visibility="resume.content.sectionVisibility"
    />
  </div>
  <div v-else-if="error" class="error-container">
    <p>{{ error }}</p>
  </div>
</template>

<script setup>
import { ref, onMounted, computed } from 'vue'
import { useRoute } from 'vue-router'
import { useStore } from 'vuex'
import ModernTemplate from './templates/ModernTemplate.vue'
import ProfessionalTemplate from './templates/ProfessionalTemplate.vue'
import MinimalTemplate from './templates/MinimalTemplate.vue'
import ExecutiveTemplate from './templates/ExecutiveTemplate.vue'
import FresherTemplate from './templates/FresherTemplate.vue'
import { migrateContent, emptyResumeContent } from '../../utils/profileToResume'
import { primaryColorHex } from './templates/templateHelpers'

const route = useRoute()
const store = useStore()

const resume = ref(null)
const error = ref(null)

const resolvedTemplate = computed(() => {
  switch (resume.value?.template_id) {
    case 'professional': return ProfessionalTemplate
    case 'minimal': return MinimalTemplate
    case 'executive': return ExecutiveTemplate
    case 'fresher': return FresherTemplate
    case 'modern':
    default: return ModernTemplate
  }
})

const containerBgStyle = computed(() => {
  if (!resume.value) return { background: 'white' }
  const isModern = resume.value.template_id === 'modern' || !resume.value.template_id
  if (isModern) {
    const hex = primaryColorHex(resume.value.content?.appearance)
    return { background: `linear-gradient(to right, ${hex} 34%, white 34%)` }
  }
  return { background: 'white' }
})

onMounted(async () => {
  try {
    const loaded = await store.dispatch('resumes/loadOne', route.params.id)
    if (loaded) {
      // Ensure content is migrated with all default arrays/objects so the templates don't crash
      const content = loaded.content ? migrateContent(loaded.content) : emptyResumeContent()
      resume.value = { ...loaded, content }
    } else {
      error.value = 'Resume not found'
    }
  } catch (err) {
    error.value = err.message || 'Failed to load resume'
  }
})
</script>

<style>
/* Base print styles for puppeteer */
@page {
  size: A4;
  margin: 0;
}

body {
  margin: 0;
  padding: 0;
  -webkit-print-color-adjust: exact;
  print-color-adjust: exact;
  -webkit-text-size-adjust: none;
  background-color: white;
}

.print-container {
  width: 210mm; /* A4 width */
  min-height: 297mm; /* A4 height */
  background: white;
}

/* Page break rules for templates */
section {
  page-break-inside: avoid;
  break-inside: avoid;
}

.resume-card, .border-l-2 {
  page-break-inside: avoid;
  break-inside: avoid;
}

/* Specific overrides to ensure we don't cut text in half */
h1, h2, h3, p, li {
  page-break-inside: avoid;
  break-inside: avoid;
}
</style>
