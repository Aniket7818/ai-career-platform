<template>
  <div class="version-history-page">
    <!-- Header -->
    <div class="vh-header">
      <div class="vh-header-left">
        <h2 class="vh-title">Version History</h2>
        <p class="vh-subtitle">{{ versions.length }} saved version{{ versions.length !== 1 ? 's' : '' }}</p>
      </div>
      <button v-if="selectedVersion" class="btn-restore" :disabled="restoring" @click="handleRestore">
        <svg v-if="restoring" class="spin size-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M21 12a9 9 0 11-6.219-8.56"/></svg>
        <svg v-else class="size-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M3 12a9 9 0 1 0 9-9 9.75 9.75 0 0 0-6.74 2.74L3 8"/><path d="M3 3v5h5"/></svg>
        {{ restoring ? 'Restoring…' : 'Restore This Version' }}
      </button>
    </div>

    <!-- Loading -->
    <div v-if="loading" class="vh-loading">
      <svg class="spin size-6" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M21 12a9 9 0 11-6.219-8.56"/></svg>
      <span>Loading versions…</span>
    </div>

    <!-- Empty state -->
    <div v-else-if="!versions.length" class="vh-empty">
      <svg class="size-12 vh-empty-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5"><path d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z"/></svg>
      <p>No versions yet. Save your resume to create the first version.</p>
    </div>

    <!-- Version list + diff panel -->
    <div v-else class="vh-layout">
      <!-- Version list -->
      <div class="vh-list">
        <div
          v-for="v in versions"
          :key="v.id"
          class="vh-item"
          :class="{ 'vh-item--active': selectedVersion?.id === v.id, 'vh-item--current': v.is_current }"
          @click="selectVersion(v)"
        >
          <div class="vh-item-badge" :class="`vh-badge--${v.source}`">{{ sourceLabel(v.source) }}</div>
          <div class="vh-item-content">
            <div class="vh-item-label">{{ v.label }}</div>
            <div class="vh-item-meta">
              <span>v{{ v.version_number }}</span>
              <span class="dot">·</span>
              <span>{{ formatDate(v.created_at) }}</span>
              <span v-if="v.score_at_creation" class="dot">·</span>
              <span v-if="v.score_at_creation" class="vh-score">{{ v.score_at_creation }}%</span>
            </div>
            <div v-if="v.change_summary" class="vh-item-summary">{{ v.change_summary }}</div>
          </div>
          <div v-if="v.is_current" class="vh-current-pill">Current</div>
        </div>
      </div>

      <!-- Detail panel -->
      <div class="vh-detail">
        <div v-if="!selectedVersion" class="vh-detail-empty">
          <svg class="size-10" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5"><path d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"/><path d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z"/></svg>
          <p>Select a version to preview its details</p>
        </div>
        <div v-else class="vh-detail-content">
          <div class="vh-detail-header">
            <div>
              <h3>{{ selectedVersion.label }}</h3>
              <p class="vh-detail-meta">Version {{ selectedVersion.version_number }} · {{ formatDate(selectedVersion.created_at) }}</p>
            </div>
          </div>
          <div v-if="selectedVersion.change_summary" class="vh-detail-summary">
            <strong>Changes:</strong> {{ selectedVersion.change_summary }}
          </div>
          <div class="vh-detail-sections">
            <div
              v-for="key in previewSections"
              :key="key"
              class="vh-section"
              v-if="versionContent && versionContent[key]"
            >
              <div class="vh-section-title">{{ sectionLabel(key) }}</div>
              <pre class="vh-section-content">{{ formatSection(versionContent[key]) }}</pre>
            </div>
          </div>
          <div v-if="loadingContent" class="vh-loading">
            <svg class="spin size-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M21 12a9 9 0 11-6.219-8.56"/></svg>
            <span>Loading snapshot…</span>
          </div>
        </div>
      </div>
    </div>

    <!-- Success toast -->
    <Transition name="fade">
      <div v-if="restoreSuccess" class="vh-toast">
        <svg class="size-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M20 6L9 17l-5-5"/></svg>
        Version restored successfully
      </div>
    </Transition>
  </div>
</template>

<script setup>
import { ref, onMounted, watch } from 'vue'
import { resumeVersionService } from '../../services/resumeVersionService'

const props = defineProps({ resumeId: { type: [String, Number], required: true } })
const emit = defineEmits(['restored'])

const versions = ref([])
const loading = ref(false)
const selectedVersion = ref(null)
const versionContent = ref(null)
const loadingContent = ref(false)
const restoring = ref(false)
const restoreSuccess = ref(false)

const previewSections = ['personal', 'experiences', 'education', 'skills', 'projects']

onMounted(fetchVersions)

async function fetchVersions() {
  loading.value = true
  try {
    const { data } = await resumeVersionService.list(props.resumeId)
    versions.value = data.versions || []
    if (versions.value.length) selectVersion(versions.value[0])
  } catch (e) {
    console.error('[VersionHistory] fetch error', e)
  } finally {
    loading.value = false
  }
}

async function selectVersion(v) {
  selectedVersion.value = v
  versionContent.value = null
  loadingContent.value = true
  try {
    const { data } = await resumeVersionService.show(props.resumeId, v.id)
    versionContent.value = data.version?.content_snapshot || {}
  } catch (e) {
    console.error('[VersionHistory] show error', e)
  } finally {
    loadingContent.value = false
  }
}

async function handleRestore() {
  if (!selectedVersion.value || restoring.value) return
  restoring.value = true
  try {
    const { data } = await resumeVersionService.restore(props.resumeId, selectedVersion.value.id)
    restoreSuccess.value = true
    setTimeout(() => { restoreSuccess.value = false }, 3000)
    await fetchVersions()
    emit('restored', data.resume)
  } catch (e) {
    console.error('[VersionHistory] restore error', e)
  } finally {
    restoring.value = false
  }
}

function sourceLabel(src) {
  return { manual: 'Save', optimization: 'Optimize', tailoring: 'Tailored', restore: 'Restored' }[src] || src
}

function sectionLabel(key) {
  return { personal: 'Personal', experiences: 'Experience', education: 'Education', skills: 'Skills', projects: 'Projects' }[key] || key
}

function formatSection(val) {
  if (!val) return ''
  if (typeof val === 'string') return val
  return JSON.stringify(val, null, 2)
}

function formatDate(iso) {
  if (!iso) return ''
  return new Intl.DateTimeFormat('en-US', { month: 'short', day: 'numeric', year: 'numeric', hour: '2-digit', minute: '2-digit' }).format(new Date(iso))
}
</script>

<style scoped>
.version-history-page { display: flex; flex-direction: column; gap: 1.5rem; padding: 1.5rem; min-height: 100%; }

.vh-header { display: flex; align-items: center; justify-content: space-between; gap: 1rem; flex-wrap: wrap; }
.vh-title { font-size: 1.25rem; font-weight: 700; color: rgb(var(--color-text-primary)); margin: 0; }
.vh-subtitle { font-size: 0.8125rem; color: rgb(var(--color-text-muted)); margin: 0.125rem 0 0; }

.btn-restore {
  display: inline-flex; align-items: center; gap: 0.5rem;
  padding: 0.5rem 1rem; border-radius: 0.5rem; font-size: 0.875rem; font-weight: 600; cursor: pointer;
  background: rgb(var(--color-primary)); color: #fff; border: none; transition: opacity 0.2s;
}
.btn-restore:disabled { opacity: 0.6; cursor: not-allowed; }
.btn-restore:hover:not(:disabled) { opacity: 0.9; }

.vh-loading { display: flex; align-items: center; gap: 0.75rem; color: rgb(var(--color-text-muted)); padding: 2rem; }
.vh-empty { display: flex; flex-direction: column; align-items: center; gap: 1rem; padding: 4rem 2rem; color: rgb(var(--color-text-muted)); text-align: center; }
.vh-empty-icon { opacity: 0.3; }

.vh-layout { display: grid; grid-template-columns: 280px 1fr; gap: 1.5rem; align-items: start; }
@media (max-width: 768px) { .vh-layout { grid-template-columns: 1fr; } }

.vh-list { display: flex; flex-direction: column; gap: 0.5rem; }
.vh-item {
  padding: 0.875rem 1rem; border-radius: 0.625rem; cursor: pointer;
  border: 1.5px solid rgb(var(--color-border)); background: rgb(var(--color-surface));
  transition: border-color 0.15s, background 0.15s; position: relative;
}
.vh-item:hover { border-color: rgb(var(--color-primary)); background: rgb(var(--color-surface-hover)); }
.vh-item--active { border-color: rgb(var(--color-primary)); background: color-mix(in srgb, rgb(var(--color-primary)) 8%, rgb(var(--color-surface))); }
.vh-item--current { }

.vh-item-badge {
  display: inline-block; font-size: 0.6875rem; font-weight: 700; letter-spacing: 0.04em;
  padding: 0.125rem 0.5rem; border-radius: 9999px; margin-bottom: 0.375rem; text-transform: uppercase;
}
.vh-badge--manual { background: rgb(var(--color-surface-elevated)); color: rgb(var(--color-text-muted)); }
.vh-badge--optimization { background: color-mix(in srgb, #7c3aed 15%, transparent); color: #7c3aed; }
.vh-badge--tailoring { background: color-mix(in srgb, #0ea5e9 15%, transparent); color: #0ea5e9; }
.vh-badge--restore { background: color-mix(in srgb, #10b981 15%, transparent); color: #10b981; }

.vh-item-label { font-size: 0.875rem; font-weight: 600; color: rgb(var(--color-text-primary)); }
.vh-item-meta { font-size: 0.75rem; color: rgb(var(--color-text-muted)); display: flex; align-items: center; gap: 0.25rem; margin-top: 0.125rem; }
.dot { opacity: 0.4; }
.vh-score { font-weight: 600; color: rgb(var(--color-primary)); }
.vh-item-summary { font-size: 0.75rem; color: rgb(var(--color-text-muted)); margin-top: 0.25rem; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }

.vh-current-pill {
  position: absolute; top: 0.625rem; right: 0.625rem;
  font-size: 0.625rem; font-weight: 700; text-transform: uppercase; letter-spacing: 0.06em;
  background: rgb(var(--color-primary)); color: #fff; padding: 0.125rem 0.4rem; border-radius: 9999px;
}

.vh-detail {
  border: 1.5px solid rgb(var(--color-border)); border-radius: 0.75rem;
  background: rgb(var(--color-surface)); min-height: 300px; overflow: hidden;
}
.vh-detail-empty { display: flex; flex-direction: column; align-items: center; justify-content: center; gap: 0.75rem; height: 300px; color: rgb(var(--color-text-muted)); opacity: 0.5; }
.vh-detail-content { padding: 1.25rem; }
.vh-detail-header { display: flex; align-items: flex-start; justify-content: space-between; gap: 1rem; margin-bottom: 1rem; }
.vh-detail-header h3 { font-size: 1rem; font-weight: 700; color: rgb(var(--color-text-primary)); margin: 0; }
.vh-detail-meta { font-size: 0.75rem; color: rgb(var(--color-text-muted)); margin: 0.25rem 0 0; }
.vh-detail-summary { font-size: 0.8125rem; color: rgb(var(--color-text-secondary)); background: rgb(var(--color-surface-hover)); border-radius: 0.5rem; padding: 0.625rem 0.875rem; margin-bottom: 1rem; }
.vh-detail-sections { display: flex; flex-direction: column; gap: 0.75rem; }
.vh-section { }
.vh-section-title { font-size: 0.75rem; font-weight: 700; text-transform: uppercase; letter-spacing: 0.06em; color: rgb(var(--color-text-muted)); margin-bottom: 0.375rem; }
.vh-section-content { font-size: 0.75rem; color: rgb(var(--color-text-secondary)); background: rgb(var(--color-surface-hover)); border-radius: 0.375rem; padding: 0.625rem; white-space: pre-wrap; word-break: break-word; max-height: 150px; overflow-y: auto; margin: 0; font-family: inherit; }

.vh-toast {
  position: fixed; bottom: 1.5rem; left: 50%; transform: translateX(-50%);
  display: flex; align-items: center; gap: 0.5rem;
  background: #10b981; color: #fff; padding: 0.625rem 1.25rem; border-radius: 9999px;
  font-size: 0.875rem; font-weight: 600; box-shadow: 0 4px 16px rgba(0,0,0,0.18); z-index: 9999;
}

.spin { animation: spin 1s linear infinite; }
@keyframes spin { to { transform: rotate(360deg); } }
.size-4 { width: 1rem; height: 1rem; }
.size-5 { width: 1.25rem; height: 1.25rem; }
.size-6 { width: 1.5rem; height: 1.5rem; }
.size-10 { width: 2.5rem; height: 2.5rem; }
.size-12 { width: 3rem; height: 3rem; }

.fade-enter-active, .fade-leave-active { transition: opacity 0.3s, transform 0.3s; }
.fade-enter-from, .fade-leave-to { opacity: 0; transform: translateX(-50%) translateY(1rem); }
</style>
