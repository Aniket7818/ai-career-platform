<template>
  <AppShell>
    <section class="space-y-6">
      <div class="flex flex-wrap items-start justify-between gap-4">
        <div>
          <p class="text-sm font-semibold text-brand">{{ t('nav.builder') }}</p>
          <h1 class="mt-1 text-3xl font-bold text-ink">{{ isNew ? t('resumes.new') : t('resumes.edit') }}</h1>
          <p class="mt-2 text-sm text-slate-500">{{ t('resumes.editorSubtitle') }}</p>
        </div>
        <button
          class="inline-flex items-center gap-2 rounded-xl border border-brand/30 bg-brand/5 px-4 py-2.5 text-sm font-semibold text-brand transition hover:bg-brand/10"
          @click="handleDownload"
        >
          <svg class="size-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M21 15v4a2 2 0 01-2 2H5a2 2 0 01-2-2v-4" /><path d="M7 10l5 5 5-5" /><path d="M12 15V3" /></svg>
          {{ t('resumes.download') }}
        </button>
      </div>
      <ErrorState v-if="error" :message="error" />
      <LoadingState v-if="loading && !resume.id && !isNew" />
      <ResumeForm v-else :model="resume" :loading="loading" @submit="save" @fill-from-profile="fillFromProfile" />
    </section>
  </AppShell>
</template>

<script setup>
import { computed, onMounted, reactive } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useStore } from 'vuex'
import AppShell from '../../components/layout/AppShell.vue'
import ErrorState from '../../components/ui/ErrorState.vue'
import LoadingState from '../../components/ui/LoadingState.vue'
import ResumeForm from './ResumeForm.vue'
import { RESUME_STATUS } from '../../constants/resume'
import { DEFAULT_TEMPLATE_ID } from '../../constants/templates'
import { downloadResume } from '../../utils/downloadResume'
import { emptyResumeContent, mergeProfileIntoContent } from '../../utils/profileToResume'
import { toast } from '../../utils/toast'
import { t } from '../../utils/i18n'

const route = useRoute()
const router = useRouter()
const store = useStore()
const isNew = computed(() => route.name === 'resume-new')
const resume = reactive({ title: '', status: RESUME_STATUS.DRAFT, template_id: DEFAULT_TEMPLATE_ID, content: emptyResumeContent() })
const loading = computed(() => store.state.resumes.loading)
const error = computed(() => store.state.resumes.error)

onMounted(async () => {
  if (!store.state.auth.user) await store.dispatch('auth/fetchMe')
  if (!isNew.value) {
    const loaded = await store.dispatch('resumes/loadOne', route.params.id)
    if (loaded) {
      Object.assign(resume, loaded, {
        template_id: loaded.template_id || DEFAULT_TEMPLATE_ID,
        content: { ...emptyResumeContent(), ...loaded.content, personal: { ...emptyResumeContent().personal, ...loaded.content?.personal } }
      })
    }
  } else if (store.state.auth.user) {
    resume.content = mergeProfileIntoContent(resume.content, store.state.auth.user)
  }
})

const save = async () => {
  const saved = isNew.value ? await store.dispatch('resumes/create', resume) : await store.dispatch('resumes/update', resume)
  if (saved?.id) {
    Object.assign(resume, saved, {
      template_id: saved.template_id || DEFAULT_TEMPLATE_ID,
      content: { ...emptyResumeContent(), ...saved.content, personal: { ...emptyResumeContent().personal, ...saved.content?.personal } }
    })
    toast.success(isNew.value ? t('toast.createSuccess') : t('toast.saveSuccess'), t('toast.saveSuccessBody'))
    if (isNew.value) router.push(`/resumes/${saved.id}/edit`)
  } else if (store.state.resumes.error) {
    toast.error(t('toast.saveError'), store.state.resumes.error)
  }
}

const fillFromProfile = async () => {
  const user = store.state.auth.user || await store.dispatch('auth/fetchMe')
  if (!user) return
  resume.content = mergeProfileIntoContent(resume.content, user)
  toast.success(t('toast.profileFilled'), t('toast.profileFilledBody'))
}

const handleDownload = async () => {
  if (!resume.id) {
    toast.info('Save your resume first', 'Please save this draft before downloading the PDF.')
    return
  }
  const allowed = await store.dispatch('resumes/recordDownload', resume.id)
  if (!allowed) {
    toast.error('Upgrade required', store.state.resumes.error || 'Your plan does not support more PDF downloads.')
    return
  }
  downloadResume(resume)
  toast.success(t('toast.downloadSuccess'), t('toast.downloadSuccessBody'))
}
</script>
