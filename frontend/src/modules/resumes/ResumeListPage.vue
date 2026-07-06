<template>
 <AppShell>
 <section class="space-y-8">
 <PageHero :title="t('resumes.title')" :subtitle="t('resumes.listSubtitle')" :badge="t('nav.resumes')">
 <template #actions>
 <RouterLink class="rounded-xl bg-brand px-5 py-2.5 text-sm font-semibold text-white shadow-lg shadow-brand/25" to="/resumes/new">{{ t('resumes.new') }}</RouterLink>
 </template>
 </PageHero>

 <LoadingState v-if="loading" />
 <ErrorState v-else-if="error" :message="error" />

 <div v-else-if="!resumes.length" class="rounded-2xl border border-dashed border-border bg-surface p-12 text-center">
 <div class="mx-auto grid size-16 place-items-center rounded-2xl bg-brand/10 text-brand">
 <svg class="size-8" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.75"><path d="M14 2H6a2 2 0 00-2 2v16a2 2 0 002 2h12a2 2 0 002-2V8z" /><path d="M14 2v6h6" /></svg>
 </div>
 <p class="mt-5 text-lg font-semibold text-txt-primary">{{ t('resumes.empty') }}</p>
 <p class="mt-2 text-sm text-txt-muted">{{ t('resumes.emptyHint') }}</p>
 <RouterLink class="mt-6 inline-flex rounded-xl bg-brand px-5 py-2.5 text-sm font-semibold text-white" to="/resumes/new">{{ t('resumes.new') }}</RouterLink>
 </div>

 <div v-else class="grid gap-4">
 <article
 v-for="resume in resumes"
 :key="resume.id"
 class="group rounded-2xl border border-border bg-surface p-5 shadow-panel transition hover:border-brand/30"
 >
 <div class="flex flex-col gap-4 lg:flex-row lg:items-center lg:justify-between">
 <div class="flex items-start gap-4">
 <span class="grid size-12 place-items-center rounded-xl bg-gradient-to-br from-brand/20 to-brand/5 text-brand ring-1 ring-brand/20">
 <svg class="size-6" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.75"><path d="M14 2H6a2 2 0 00-2 2v16a2 2 0 002 2h12a2 2 0 002-2V8z" /><path d="M14 2v6h6" /></svg>
 </span>
 <div>
 <h2 class="text-lg font-bold text-txt-primary">{{ resume.title }}</h2>
 <div class="mt-2 flex flex-wrap items-center gap-3">
 <ResumeStatusBadge :status="resume.status" />
 <span class="text-xs text-txt-muted">{{ formatDate(resume.updated_at) }}</span>
 </div>
 </div>
 </div>
 <div class="flex flex-wrap gap-2">
 <RouterLink class="inline-flex items-center gap-2 rounded-xl border border-border px-4 py-2 text-sm font-semibold text-txt-primary transition hover:bg-background" :to="`/resumes/${resume.id}/edit`">
 <svg class="size-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M11 4H4a2 2 0 00-2 2v14a2 2 0 002 2h14a2 2 0 002-2v-7" /><path d="M18.5 2.5a2.12 2.12 0 013 3L12 15l-4 1 1-4 9.5-9.5z" /></svg>
 {{ t('resumes.edit') }}
 </RouterLink>
 <RouterLink class="inline-flex items-center gap-2 rounded-xl border border-brand/30 bg-brand/5 px-4 py-2 text-sm font-semibold text-brand transition hover:bg-brand/10" :to="`/resumes/${resume.id}/optimize`">
 <svg class="size-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M13 2L3 14h9l-1 8 10-12h-9l1-8z"/></svg>
 Optimize
 <span v-if="resume.version_count > 0" class="ml-0.5 rounded-full bg-brand/20 px-1.5 py-0.5 text-xs font-bold leading-none">{{ resume.version_count }}</span>
 </RouterLink>
 <button class="inline-flex items-center gap-2 rounded-xl bg-red-500/10 px-4 py-2 text-sm font-semibold text-red-600 transition hover:bg-red-500/20" @click="remove(resume.id)">
 <svg class="size-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M3 6h18M19 6v14a2 2 0 01-2 2H7a2 2 0 01-2-2V6m3 0V4a2 2 0 012-2h4a2 2 0 012 2v2" /></svg>
 {{ t('resumes.delete') }}
 </button>
 </div>
 </div>
 </article>
 </div>
 </section>
 </AppShell>
</template>

<script setup>
import { computed, onMounted, ref } from 'vue'
import { useStore } from 'vuex'
import AppShell from '../../components/layout/AppShell.vue'
import LoadingState from '../../components/ui/LoadingState.vue'
import ErrorState from '../../components/ui/ErrorState.vue'
import PageHero from '../../components/ui/PageHero.vue'
import ResumeStatusBadge from '../../components/ui/ResumeStatusBadge.vue'
import { toast } from '../../utils/toast'
import { t } from '../../utils/i18n'

const store = useStore()

onMounted(() => store.dispatch('resumes/load'))

const resumes = computed(() => store.state.resumes.items)
const loading = computed(() => store.state.resumes.loading)
const error = computed(() => store.state.resumes.error)

const remove = async (id) => {
 await store.dispatch('resumes/remove', id)
 if (!store.state.resumes.error) toast.success(t('toast.deleteSuccess'), t('toast.deleteSuccessBody'))
 else toast.error(t('toast.deleteError'), store.state.resumes.error)
}

const formatDate = (value) => {
 if (!value) return ''
 return new Date(value).toLocaleDateString(undefined, { month: 'short', day: 'numeric', year: 'numeric' })
}
</script>
