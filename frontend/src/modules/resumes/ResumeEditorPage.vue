<template>
  <div class="min-h-screen bg-slate-50 relative">
    <ErrorState v-if="error" :message="error" />
    <LoadingState v-if="loading && !resume.id && !isNew" />
    <ResumeForm 
      v-else 
      :model="resume" 
      :loading="loading" 
      :isNew="isNew"
      :isDownloading="isDownloading"
      :saveStatus="saveStatus"
      @submit="save" 
      @fill-from-profile="fillFromProfile"
      @download="handleDownload"
    />
    
    <!-- Inline Feedback Toast -->
    <Transition name="fade">
      <div v-if="showInlineFeedback" class="inline-feedback">
        <svg class="size-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M20 6L9 17l-5-5" /></svg>
        <span>{{ inlineFeedbackMessage }}</span>
      </div>
    </Transition>
  </div>
</template>

<script setup>
import { computed, onMounted, reactive, watch, onBeforeUnmount, ref } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useStore } from 'vuex'
import AppShell from '../../components/layout/AppShell.vue'
import ErrorState from '../../components/ui/ErrorState.vue'
import LoadingState from '../../components/ui/LoadingState.vue'
import ResumeForm from './ResumeForm.vue'
import { RESUME_STATUS } from '../../constants/resume'
import { DEFAULT_TEMPLATE_ID } from '../../constants/templates'
import { downloadResume } from '../../utils/downloadResume'
import { emptyResumeContent, migrateContent, mergeProfileIntoContent } from '../../utils/profileToResume'
import { toast } from '../../utils/toast'
import { t } from '../../utils/i18n'
import http from '../../services/http'

const route  = useRoute()
const router = useRouter()
const store  = useStore()
const isNew  = computed(() => route.name === 'resume-new')

const resume = reactive({
  title: '',
  status: RESUME_STATUS.DRAFT,
  template_id: DEFAULT_TEMPLATE_ID,
  content: emptyResumeContent()
})

const loading = computed(() => store.state.resumes.loading)
const error   = computed(() => store.state.resumes.error)

onMounted(async () => {
  if (!store.state.auth.user) await store.dispatch('auth/fetchMe')
  if (!isNew.value) {
    const loaded = await store.dispatch('resumes/loadOne', route.params.id)
    if (loaded) {
      const migratedContent = migrateContent(loaded.content)
      Object.assign(resume, loaded, {
        template_id: loaded.template_id || DEFAULT_TEMPLATE_ID,
        content: migratedContent
      })
    }
  } else if (store.state.auth.user) {
    resume.content = mergeProfileIntoContent(emptyResumeContent(), store.state.auth.user)
  }
  // Capture baseline snapshot so the watcher can detect real changes
  lastSavedSnapshot = getContentSnapshot()
  window.addEventListener('beforeunload', handleUnload)
})

onBeforeUnmount(() => {
  window.removeEventListener('beforeunload', handleUnload)
  if (hasUnsavedChanges && resume.title) save(true)
})

let autoSaveTimeout = null
let autoSaveInterval = null
let hasUnsavedChanges = false
let isSaving = false
let lastSavedSnapshot = ''
const saveStatus = ref('saved')

const showInlineFeedback = ref(false)
const inlineFeedbackMessage = ref('')
let feedbackTimeout = null

const triggerInlineFeedback = (message) => {
  inlineFeedbackMessage.value = message
  showInlineFeedback.value = true
  if (feedbackTimeout) clearTimeout(feedbackTimeout)
  feedbackTimeout = setTimeout(() => {
    showInlineFeedback.value = false
  }, 2500)
}

const getContentSnapshot = () => {
  try {
    return JSON.stringify({
      title: resume.title,
      status: resume.status,
      template_id: resume.template_id,
      content: resume.content
    })
  } catch { return '' }
}

const handleUnload = (e) => {
  if (hasUnsavedChanges && resume.title) {
    save(true)
    e.preventDefault()
    e.returnValue = ''
  }
}

watch(resume, () => {
  // Only flag as unsaved if actual content changed (prevents accordion/scroll triggers)
  const current = getContentSnapshot()
  if (current === lastSavedSnapshot) return
  
  hasUnsavedChanges = true
  saveStatus.value = 'unsaved'
  if (autoSaveTimeout) clearTimeout(autoSaveTimeout)
  
  // 2 seconds of inactivity
  autoSaveTimeout = setTimeout(() => {
    if (resume.title && hasUnsavedChanges) save(true)
  }, 2000)

  // 30 second forced save if typing continuously
  if (!autoSaveInterval) {
    autoSaveInterval = setInterval(() => {
      if (resume.title && hasUnsavedChanges) save(true)
    }, 30000)
  }
}, { deep: true })

const save = async (isAutoSave = false) => {
  if (isSaving || !resume.title) return
  isSaving = true
  saveStatus.value = 'saving'
  hasUnsavedChanges = false // optimistic reset

  const payload = JSON.parse(JSON.stringify(resume)) // snaphot data for saving
  const saved = isNew.value
    ? await store.dispatch('resumes/create', payload)
    : await store.dispatch('resumes/update', payload)
    
  isSaving = false

  if (saved?.id) {
    // Sync critical IDs back to the reactive object without overwriting nested content
    resume.id = saved.id
    resume.template_id = saved.template_id || DEFAULT_TEMPLATE_ID
    saveStatus.value = 'saved'
    lastSavedSnapshot = getContentSnapshot()
    
    if (isNew.value) {
      router.replace(`/resumes/${saved.id}/edit`)
    } else if (!isAutoSave) {
      triggerInlineFeedback(t('toast.saveSuccess'))
    }
  } else if (store.state.resumes.error && !isAutoSave) {
    hasUnsavedChanges = true // revert
    saveStatus.value = 'unsaved'
    toast.error(t('toast.saveError'), store.state.resumes.error)
  }
}

const fillFromProfile = async () => {
  const user = store.state.auth.user || await store.dispatch('auth/fetchMe')
  if (!user) return
  resume.content = mergeProfileIntoContent(resume.content, user)
  hasUnsavedChanges = true
  saveStatus.value = 'unsaved'
  triggerInlineFeedback(t('toast.profileFilled'))
}

import { resumeService } from '../../services/resumeService'

const isDownloading = ref(false)

const handleDownload = async () => {
  if (isDownloading.value) return
  if (hasUnsavedChanges) await save(true)
  if (!resume.id) {
    toast.info('Save your resume first', 'Please save this draft before downloading the PDF.')
    return
  }
  
  isDownloading.value = true
  toast.info('Generating PDF...', 'Please wait while we render your resume. This may take a few seconds.')
  try {
    const response = await resumeService.downloadPdf(resume.id)
    const url = window.URL.createObjectURL(new Blob([response.data]))
    const link = document.createElement('a')
    link.href = url
    link.setAttribute('download', `resume_${resume.id}.pdf`)
    document.body.appendChild(link)
    link.click()
    document.body.removeChild(link)
    await store.dispatch('auth/fetchMe')
    toast.success(t('toast.downloadSuccess'), t('toast.downloadSuccessBody'))
  } catch (error) {
    console.error('PDF Download Error:', error)
    if (error.response?.status === 402) {
      toast.error('Upgrade required', 'Your plan does not support more PDF downloads.')
    } else {
      toast.error('Download Failed', 'Could not generate the PDF. Please try again.')
    }
  } finally {
    isDownloading.value = false
  }
}
</script>
