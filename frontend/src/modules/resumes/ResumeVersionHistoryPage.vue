<template>
  <div class="version-history-page">
    <!-- Header -->
    <div class="vh-header">
      <div class="vh-header-left">
        <h2 class="vh-title">Version History</h2>
        <p class="vh-subtitle">{{ versions.length }} saved version{{ versions.length !== 1 ? 's' : '' }}</p>
      </div>
      <button v-if="selectedVersion && (activeMobileTab === 'detail' || !isMobile)" class="btn-restore" :disabled="restoring" @click="handleRestore">
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
      <div class="vh-list" v-show="activeMobileTab === 'list' || !isMobile">
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
      <div class="vh-detail" v-show="activeMobileTab === 'detail' || !isMobile">
        <div class="vh-detail-header-mobile" v-if="isMobile">
          <button class="btn-back-to-list" @click="activeMobileTab = 'list'">
            <svg class="size-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M19 12H5M12 5l-7 7 7 7"/></svg>
            Back to versions list
          </button>
        </div>

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
          <!-- Version Changes Summary Box -->
          <div class="vh-changes-summary-box" v-if="diffData && diffData.has_any_changes">
            <h4 class="vh-changes-title">
              <svg class="size-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M12 20h9M3 20v-8a2 2 0 0 1 2-2h4l2-3h4l2 3h4a2 2 0 0 1 2 2v8"/></svg>
              What changed in this version
            </h4>
            <div class="vh-changes-list">
              <div 
                v-for="(diff, sectionKey) in changedSections" 
                :key="sectionKey" 
                class="vh-change-item"
                :class="`vh-change-item--${diff.status}`"
              >
                <div class="vh-change-header">
                  <span class="vh-change-section-name">{{ sectionLabel(sectionKey) }}</span>
                  <span class="vh-change-badge" :class="`vh-change-badge--${diff.status}`">
                    {{ diff.status }}
                  </span>
                </div>
                <div class="vh-change-diff-details">
                  <div class="diff-meta-desc">{{ getDiffDescription(sectionKey, diff.before, diff.after) }}</div>
                </div>
              </div>
            </div>
          </div>
          <div class="vh-changes-summary-box vh-changes-summary-box--none" v-else-if="diffData && !diffData.has_any_changes">
            <p class="vh-no-changes-text">No structural content changes detected in this version.</p>
          </div>

          <div class="vh-detail-sections">
            <div
              v-for="key in previewSections"
              :key="key"
              class="vh-section"
              v-if="versionContent && hasSectionContent(versionContent[key])"
            >
              <div class="vh-section-title">{{ sectionLabel(key) }}</div>
              
              <!-- Personal Section -->
              <div v-if="key === 'personal'" class="section-preview-personal">
                <div class="personal-grid">
                  <div class="personal-field" v-if="versionContent.personal.name || versionContent.personal.fullName">
                    <strong>Name:</strong> {{ versionContent.personal.name || versionContent.personal.fullName }}
                  </div>
                  <div class="personal-field" v-if="versionContent.personal.title || versionContent.personal.headline">
                    <strong>Headline:</strong> {{ versionContent.personal.title || versionContent.personal.headline }}
                  </div>
                  <div class="personal-field" v-if="versionContent.personal.email">
                    <strong>Email:</strong> {{ versionContent.personal.email }}
                  </div>
                  <div class="personal-field" v-if="versionContent.personal.phone">
                    <strong>Phone:</strong> {{ versionContent.personal.phone }}
                  </div>
                  <div class="personal-field" v-if="versionContent.personal.location">
                    <strong>Location:</strong> {{ versionContent.personal.location }}
                  </div>
                </div>
                <div class="personal-summary" v-if="versionContent.personal.summary">
                  <strong>Summary:</strong>
                  <p class="personal-summary-text">{{ versionContent.personal.summary }}</p>
                </div>
              </div>

              <!-- Experiences Section -->
              <div v-else-if="key === 'experiences' && Array.isArray(versionContent.experiences)" class="section-preview-list">
                <div 
                  v-for="(exp, index) in versionContent.experiences" 
                  :key="index" 
                  class="preview-list-item"
                >
                  <div class="item-header">
                    <span class="item-title">{{ exp.position || exp.title || 'Role' }}</span>
                    <span class="item-meta">{{ exp.company || exp.organization }}</span>
                  </div>
                  <div class="item-duration" v-if="exp.startDate || exp.endDate || exp.duration">
                    {{ exp.startDate }} - {{ exp.endDate || 'Present' }}
                  </div>
                  <p class="item-desc" v-if="exp.description">{{ exp.description }}</p>
                  <ul class="item-bullets" v-if="exp.highlights || exp.bullets">
                    <li v-for="(bullet, bIdx) in (exp.highlights || exp.bullets)" :key="bIdx">{{ bullet }}</li>
                  </ul>
                </div>
              </div>

              <!-- Educations Section -->
              <div v-else-if="key === 'educations' && Array.isArray(versionContent.educations)" class="section-preview-list">
                <div 
                  v-for="(edu, index) in versionContent.educations" 
                  :key="index" 
                  class="preview-list-item"
                >
                  <div class="item-header">
                    <span class="item-title">{{ edu.degree || 'Degree' }}</span>
                    <span class="item-meta">{{ edu.institution || edu.school }}</span>
                  </div>
                  <div class="item-duration" v-if="edu.startDate || edu.endDate || edu.duration">
                    {{ edu.startDate }} - {{ edu.endDate || 'Present' }}
                  </div>
                  <p class="item-desc" v-if="edu.fieldOfStudy">Field of Study: {{ edu.fieldOfStudy }}</p>
                </div>
              </div>

              <!-- Skills Section -->
              <div v-else-if="key === 'skills'" class="section-preview-skills">
                <div class="skills-flex" v-if="Array.isArray(versionContent.skills)">
                  <span v-for="(skill, index) in versionContent.skills" :key="index" class="skill-tag">
                    {{ typeof skill === 'string' ? skill : (skill.name || '') }}
                  </span>
                </div>
                <div class="skills-flex" v-else-if="typeof versionContent.skills === 'string'">
                  <span v-for="(skill, index) in versionContent.skills.split(',')" :key="index" class="skill-tag">
                    {{ skill.trim() }}
                  </span>
                </div>
              </div>

              <!-- Projects Section -->
              <div v-else-if="key === 'projects' && Array.isArray(versionContent.projects)" class="section-preview-list">
                <div 
                  v-for="(proj, index) in versionContent.projects" 
                  :key="index" 
                  class="preview-list-item"
                >
                  <div class="item-header">
                    <span class="item-title">{{ proj.title || proj.name || 'Project' }}</span>
                    <span class="item-meta" v-if="proj.role">{{ proj.role }}</span>
                  </div>
                  <p class="item-desc" v-if="proj.description">{{ proj.description }}</p>
                  <ul class="item-bullets" v-if="proj.highlights || proj.bullets">
                    <li v-for="(bullet, bIdx) in (proj.highlights || proj.bullets)" :key="bIdx">{{ bullet }}</li>
                  </ul>
                </div>
              </div>

              <!-- Certifications Section -->
              <div v-else-if="key === 'certifications' && Array.isArray(versionContent.certifications)" class="section-preview-list">
                <div 
                  v-for="(cert, index) in versionContent.certifications" 
                  :key="index" 
                  class="preview-list-item"
                >
                  <div class="item-header">
                    <span class="item-title">{{ cert.name || 'Certification' }}</span>
                    <span class="item-meta" v-if="cert.issuer">{{ cert.issuer }}</span>
                  </div>
                  <div class="item-duration" v-if="cert.date || cert.issueDate">
                    {{ cert.date || cert.issueDate }}
                  </div>
                </div>
              </div>

              <!-- Fallback -->
              <pre v-else class="vh-section-content">{{ formatSection(versionContent[key]) }}</pre>
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
import { ref, onMounted, onBeforeUnmount, computed } from 'vue'
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

const diffData = ref(null)
const loadingDiff = ref(false)

const isMobile = ref(false)
const activeMobileTab = ref('list') // 'list' | 'detail'
let mediaQuery = null

const previewSections = ['personal', 'experiences', 'educations', 'skills', 'projects', 'certifications']

const listener = (e) => {
  isMobile.value = e.matches
  // If moving back to desktop, ensure detail is always ready if a version is selected
  if (!e.matches && versions.value.length && !selectedVersion.value) {
    selectVersion(versions.value[0])
  }
}

onMounted(() => {
  fetchVersions()
  if (typeof window !== 'undefined') {
    mediaQuery = window.matchMedia('(max-width: 768px)')
    isMobile.value = mediaQuery.matches
    mediaQuery.addEventListener('change', listener)
  }
})

onBeforeUnmount(() => {
  if (mediaQuery) {
    mediaQuery.removeEventListener('change', listener)
  }
})

async function fetchVersions() {
  loading.value = true
  try {
    const { data } = await resumeVersionService.list(props.resumeId)
    versions.value = data.versions || []
    if (versions.value.length) {
      selectVersion(versions.value[0])
    }
  } catch (e) {
    console.error('[VersionHistory] fetch error', e)
  } finally {
    loading.value = false
  }
}

async function selectVersion(v) {
  selectedVersion.value = v
  versionContent.value = null
  diffData.value = null
  loadingContent.value = true
  loadingDiff.value = true
  if (isMobile.value) {
    activeMobileTab.value = 'detail'
  }

  // Find predecessor in reverse chronological list (index + 1)
  const idx = versions.value.findIndex(item => item.id === v.id)
  const predecessor = idx !== -1 && idx + 1 < versions.value.length ? versions.value[idx + 1] : null

  try {
    const promises = [
      resumeVersionService.show(props.resumeId, v.id)
    ]
    if (predecessor) {
      promises.push(resumeVersionService.diff(props.resumeId, predecessor.id, v.id))
    }

    const results = await Promise.all(promises)
    versionContent.value = results[0].data.version?.content_snapshot || {}
    
    if (predecessor && results[1]) {
      diffData.value = results[1].data.diff || null
    }
  } catch (e) {
    console.error('[VersionHistory] select error', e)
  } finally {
    loadingContent.value = false
    loadingDiff.value = false
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
    if (isMobile.value) {
      activeMobileTab.value = 'list'
    }
  } catch (e) {
    console.error('[VersionHistory] restore error', e)
  } finally {
    restoring.value = false
  }
}

const changedSections = computed(() => {
  if (!diffData.value || !diffData.value.sections) return {}
  const changes = {}
  Object.entries(diffData.value.sections).forEach(([key, value]) => {
    if (value.status !== 'same') {
      changes[key] = value
    }
  })
  return changes
})

function hasSectionContent(val) {
  if (!val) return false
  if (Array.isArray(val)) return val.length > 0
  if (typeof val === 'object') return Object.keys(val).length > 0
  return !!val
}

function getDiffDescription(sectionKey, before, after) {
  if (!before || !after) {
    return 'Content updated.'
  }
  
  if (typeof before === 'string' || typeof after === 'string') {
    return 'Updated description text.'
  }

  if (Array.isArray(before) && Array.isArray(after)) {
    if (before.length !== after.length) {
      const diffLen = after.length - before.length
      return diffLen > 0 
        ? `Added ${diffLen} new item${diffLen > 1 ? 's' : ''}.` 
        : `Removed ${Math.abs(diffLen)} item${Math.abs(diffLen) > 1 ? 's' : ''}.`
    }
    return 'Updated details or description text of existing items.'
  }

  if (typeof before === 'object' && typeof after === 'object') {
    const changedFields = []
    Object.keys({ ...before, ...after }).forEach(key => {
      if (JSON.stringify(before[key]) !== JSON.stringify(after[key])) {
        changedFields.push(key)
      }
    })
    if (changedFields.length) {
      return `Updated ${changedFields.map(f => f.replace(/([A-Z])/g, ' $1').toLowerCase().trim()).join(', ')}.`
    }
  }

  return 'Updated section content.'
}

function sourceLabel(src) {
  return { manual: 'Save', optimization: 'Optimize', tailoring: 'Tailored', restore: 'Restored' }[src] || src
}

function sectionLabel(key) {
  return { 
    personal: 'Personal Info', 
    experiences: 'Experience', 
    educations: 'Education', 
    skills: 'Skills', 
    projects: 'Projects',
    certifications: 'Certifications'
  }[key] || key
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
.version-history-page { 
  display: flex; 
  flex-direction: column; 
  gap: 1.5rem; 
  padding: 1.5rem; 
  min-height: 100%; 
}

.vh-header { 
  display: flex; 
  align-items: center; 
  justify-content: space-between; 
  gap: 1rem; 
  flex-wrap: wrap; 
}
.vh-title { 
  font-size: 1.25rem; 
  font-weight: 750; 
  color: rgb(var(--color-text-primary)); 
  margin: 0; 
}
.vh-subtitle { 
  font-size: 0.8125rem; 
  color: rgb(var(--color-text-secondary)); 
  margin: 0.125rem 0 0; 
}

.btn-restore {
  display: inline-flex; 
  align-items: center; 
  justify-content: center;
  gap: 0.5rem;
  padding: 0.6rem 1.5rem; 
  border-radius: 0.75rem; 
  font-size: 0.875rem; 
  font-weight: 700; 
  cursor: pointer;
  background: linear-gradient(135deg, rgb(var(--color-primary)) 0%, #8b5cf6 100%); 
  color: #fff; 
  border: none; 
  transition: all 0.2s cubic-bezier(0.4, 0, 0.2, 1);
  box-shadow: 0 4px 12px rgba(99, 102, 241, 0.2);
}
.btn-restore:disabled { 
  opacity: 0.6; 
  cursor: not-allowed; 
  box-shadow: none;
}
.btn-restore:hover:not(:disabled) { 
  transform: translateY(-1px);
  box-shadow: 0 6px 16px rgba(99, 102, 241, 0.35);
}
.btn-restore:active:not(:disabled) {
  transform: scale(0.98);
}

.vh-loading { 
  display: flex; 
  align-items: center; 
  gap: 0.75rem; 
  color: rgb(var(--color-text-muted)); 
  padding: 2rem; 
}
.vh-empty { 
  display: flex; 
  flex-direction: column; 
  align-items: center; 
  gap: 1rem; 
  padding: 4rem 2rem; 
  color: rgb(var(--color-text-muted)); 
  text-align: center; 
}
.vh-empty-icon { 
  opacity: 0.3; 
}

.vh-layout { 
  display: grid; 
  grid-template-columns: 300px 1fr; 
  gap: 1.5rem; 
  align-items: start; 
}
@media (max-width: 768px) { 
  .vh-layout { 
    grid-template-columns: 1fr; 
  } 
}

.vh-list { 
  display: flex; 
  flex-direction: column; 
  gap: 0.75rem; 
}

.vh-item {
  padding: 1rem; 
  border-radius: 0.875rem; 
  cursor: pointer;
  border: 1px solid rgb(var(--color-border)); 
  border-left: 4px solid transparent;
  background: rgb(var(--color-surface));
  transition: all 0.25s cubic-bezier(0.4, 0, 0.2, 1); 
  position: relative;
}
.vh-item:hover { 
  border-color: rgb(var(--color-border-hover)); 
  background: rgb(var(--color-surface-hover)); 
}
.vh-item--active { 
  border-color: rgba(99, 102, 241, 0.3); 
  border-left-color: rgb(var(--color-primary));
  background: linear-gradient(135deg, rgba(99, 102, 241, 0.02) 0%, rgba(139, 92, 246, 0.04) 100%); 
}

.vh-item-badge {
  display: inline-block; 
  font-size: 0.625rem; 
  font-weight: 750; 
  letter-spacing: 0.06em;
  padding: 0.2rem 0.6rem; 
  border-radius: 6px; 
  margin-bottom: 0.5rem; 
  text-transform: uppercase;
}
.vh-badge--manual { 
  background: rgba(107, 114, 128, 0.06); 
  border: 1px solid rgba(107, 114, 128, 0.15); 
  color: rgb(var(--color-text-secondary)); 
}
.vh-badge--optimization { 
  background: rgba(124, 58, 237, 0.06); 
  border: 1px solid rgba(124, 58, 237, 0.15); 
  color: #7c3aed; 
}
.vh-badge--tailoring { 
  background: rgba(14, 165, 233, 0.06); 
  border: 1px solid rgba(14, 165, 233, 0.15); 
  color: #0ea5e9; 
}
.vh-badge--restore { 
  background: rgba(16, 185, 129, 0.06); 
  border: 1px solid rgba(16, 185, 129, 0.15); 
  color: #10b981; 
}

.vh-item-label { 
  font-size: 0.875rem; 
  font-weight: 700; 
  color: rgb(var(--color-text-primary)); 
}
.vh-item-meta { 
  font-size: 0.75rem; 
  color: rgb(var(--color-text-secondary)); 
  display: flex; 
  align-items: center; 
  gap: 0.25rem; 
  margin-top: 0.25rem; 
}
.dot { 
  opacity: 0.4; 
}
.vh-score { 
  font-weight: 700; 
  color: rgb(var(--color-primary)); 
}
.vh-item-summary { 
  font-size: 0.75rem; 
  color: rgb(var(--color-text-muted)); 
  margin-top: 0.375rem; 
  white-space: nowrap; 
  overflow: hidden; 
  text-overflow: ellipsis; 
}

.vh-current-pill {
  position: absolute; 
  top: 0.875rem; 
  right: 0.875rem;
  font-size: 0.625rem; 
  font-weight: 750; 
  text-transform: uppercase; 
  letter-spacing: 0.06em;
  background: linear-gradient(135deg, rgb(var(--color-primary)) 0%, #8b5cf6 100%); 
  color: #fff; 
  padding: 0.15rem 0.5rem; 
  border-radius: 6px;
}

.vh-detail {
  border: 1px solid rgb(var(--color-border)); 
  border-radius: 1rem;
  background: rgb(var(--color-surface)); 
  min-height: 300px; 
  overflow: hidden;
  box-shadow: 0 4px 20px rgba(0,0,0,0.02);
}
.vh-detail-empty { 
  display: flex; 
  flex-direction: column; 
  align-items: center; 
  justify-content: center; 
  gap: 0.75rem; 
  height: 300px; 
  color: rgb(var(--color-text-muted)); 
  opacity: 0.5; 
}
.vh-detail-content { 
  padding: 1.5rem; 
}
.vh-detail-header { 
  display: flex; 
  align-items: flex-start; 
  justify-content: space-between; 
  gap: 1rem; 
  margin-bottom: 1.25rem; 
}
.vh-detail-header h3 { 
  font-size: 1.15rem; 
  font-weight: 750; 
  color: rgb(var(--color-text-primary)); 
  margin: 0; 
}
.vh-detail-meta { 
  font-size: 0.785rem; 
  color: rgb(var(--color-text-secondary)); 
  margin: 0.25rem 0 0; 
}
.vh-detail-summary { 
  font-size: 0.875rem; 
  color: rgb(var(--color-text-secondary)); 
  background: rgb(var(--color-surface-hover)); 
  border-radius: 0.75rem; 
  border: 1px solid rgb(var(--color-border));
  padding: 0.75rem 1rem; 
  margin-bottom: 1.25rem; 
}
.vh-detail-sections { 
  display: flex; 
  flex-direction: column; 
  gap: 1rem; 
}
.vh-section { }
.vh-section-title { 
  font-size: 0.725rem; 
  font-weight: 750; 
  text-transform: uppercase; 
  letter-spacing: 0.06em; 
  color: rgb(var(--color-primary)); 
  margin-bottom: 0.5rem; 
}
.vh-section-content { 
  font-size: 0.75rem; 
  color: rgb(var(--color-text-secondary)); 
  background: rgb(var(--color-surface-hover)); 
  border: 1px solid rgb(var(--color-border));
  border-radius: 0.5rem; 
  padding: 0.75rem 1rem; 
  white-space: pre-wrap; 
  word-break: break-word; 
  max-height: 180px; 
  overflow-y: auto; 
  margin: 0; 
  font-family: inherit; 
}

.vh-detail-header-mobile {
  padding: 0.85rem 1.25rem;
  border-bottom: 1px solid rgb(var(--color-border));
  background: rgb(var(--color-surface-hover));
}
.btn-back-to-list {
  display: inline-flex;
  align-items: center;
  gap: 0.5rem;
  background: transparent;
  border: none;
  color: rgb(var(--color-primary));
  font-weight: 700;
  font-size: 0.875rem;
  cursor: pointer;
  padding: 0.25rem 0;
  transition: opacity 0.2s;
}
.btn-back-to-list:hover {
  opacity: 0.85;
}

.vh-toast {
  position: fixed; 
  bottom: 1.5rem; 
  left: 50%; 
  transform: translateX(-50%);
  display: flex; 
  align-items: center; 
  gap: 0.5rem;
  background: #10b981; 
  color: #fff; 
  padding: 0.65rem 1.5rem; 
  border-radius: 9999px;
  font-size: 0.875rem; 
  font-weight: 700; 
  box-shadow: 0 4px 16px rgba(0,0,0,0.18); 
  z-index: 9999;
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

/* Version changes summary box */
.vh-changes-summary-box {
  background: rgb(var(--color-surface-hover));
  border: 1px dashed rgb(var(--color-border));
  border-radius: 0.875rem;
  padding: 1.25rem;
  margin-bottom: 1.5rem;
}
.vh-changes-summary-box--none {
  border-style: solid;
  text-align: center;
  padding: 1.5rem;
}
.vh-changes-title {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  font-size: 0.875rem;
  font-weight: 750;
  color: rgb(var(--color-text-primary));
  margin: 0 0 1rem 0;
  text-transform: uppercase;
  letter-spacing: 0.04em;
}
.vh-changes-list {
  display: flex;
  flex-direction: column;
  gap: 0.75rem;
}
.vh-change-item {
  background: rgb(var(--color-surface));
  border: 1px solid rgb(var(--color-border));
  border-radius: 0.5rem;
  padding: 0.75rem 1rem;
}
.vh-change-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 0.25rem;
}
.vh-change-section-name {
  font-weight: 700;
  font-size: 0.875rem;
  color: rgb(var(--color-text-primary));
}
.vh-change-badge {
  font-size: 0.625rem;
  font-weight: 750;
  text-transform: uppercase;
  padding: 0.15rem 0.4rem;
  border-radius: 4px;
  letter-spacing: 0.04em;
}
.vh-change-badge--added {
  background: rgba(16, 185, 129, 0.08);
  color: #10b981;
  border: 1px solid rgba(16, 185, 129, 0.15);
}
.vh-change-badge--changed {
  background: rgba(245, 158, 11, 0.08);
  color: #f59e0b;
  border: 1px solid rgba(245, 158, 11, 0.15);
}
.vh-change-badge--removed {
  background: rgba(239, 68, 68, 0.08);
  color: #ef4444;
  border: 1px solid rgba(239, 68, 68, 0.15);
}
.vh-change-diff-details {
  font-size: 0.8125rem;
  color: rgb(var(--color-text-secondary));
}
.diff-meta-desc {
  font-style: italic;
}
.vh-no-changes-text {
  font-size: 0.875rem;
  color: rgb(var(--color-text-secondary));
  margin: 0;
}

/* Beautiful Section Preview Cards */
.section-preview-personal {
  background: rgb(var(--color-surface-hover));
  border: 1px solid rgb(var(--color-border));
  border-radius: 0.75rem;
  padding: 1.25rem;
}
.personal-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 0.75rem 1.5rem;
  margin-bottom: 0.75rem;
}
@media (max-width: 640px) {
  .personal-grid {
    grid-template-columns: 1fr;
  }
}
.personal-field {
  font-size: 0.875rem;
  color: rgb(var(--color-text-secondary));
}
.personal-field strong {
  color: rgb(var(--color-text-primary));
}
.personal-summary {
  border-top: 1px dashed rgb(var(--color-border));
  padding-top: 0.75rem;
  font-size: 0.875rem;
  color: rgb(var(--color-text-secondary));
}
.personal-summary-text {
  margin: 0.25rem 0 0 0;
  line-height: 1.5;
}

.section-preview-list {
  display: flex;
  flex-direction: column;
  gap: 0.75rem;
}
.preview-list-item {
  background: rgb(var(--color-surface-hover));
  border: 1px solid rgb(var(--color-border));
  border-radius: 0.75rem;
  padding: 1rem 1.25rem;
}
.item-header {
  display: flex;
  justify-content: space-between;
  align-items: baseline;
  gap: 1rem;
  flex-wrap: wrap;
}
.item-title {
  font-weight: 700;
  font-size: 0.9375rem;
  color: rgb(var(--color-text-primary));
}
.item-meta {
  font-size: 0.8125rem;
  color: rgb(var(--color-primary));
  font-weight: 600;
}
.item-duration {
  font-size: 0.75rem;
  color: rgb(var(--color-text-secondary));
  margin-top: 0.125rem;
}
.item-desc {
  font-size: 0.875rem;
  color: rgb(var(--color-text-secondary));
  margin: 0.5rem 0 0 0;
  line-height: 1.5;
}
.item-bullets {
  margin: 0.5rem 0 0 0;
  padding-left: 1.25rem;
  font-size: 0.875rem;
  color: rgb(var(--color-text-secondary));
  line-height: 1.5;
}
.item-bullets li {
  margin-bottom: 0.25rem;
}

.section-preview-skills {
  background: rgb(var(--color-surface-hover));
  border: 1px solid rgb(var(--color-border));
  border-radius: 0.75rem;
  padding: 1.25rem;
}
.skills-flex {
  display: flex;
  flex-wrap: wrap;
  gap: 0.5rem;
}
.skill-tag {
  background: rgb(var(--color-surface));
  border: 1px solid rgb(var(--color-border));
  color: rgb(var(--color-text-primary));
  font-size: 0.8125rem;
  font-weight: 600;
  padding: 0.35rem 0.75rem;
  border-radius: 6px;
}

@media (max-width: 768px) {
  .version-history-page {
    padding: 1rem 1.15rem;
    padding-bottom: 120px; /* Safe space to prevent bottom navigation overlaps */
  }
  .vh-header {
    flex-direction: column;
    align-items: stretch;
    gap: 0.75rem;
  }
  .btn-restore {
    width: 100%;
    height: 44px;
    font-size: 0.875rem;
  }
}
</style>
