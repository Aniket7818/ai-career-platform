<template>
  <div class="optimize-page min-h-screen bg-background">
    <!-- Workspace Tab Bar -->
    <div class="workspace-tabs-bar">
      <div class="workspace-tabs-inner">
        <!-- Back to resume list -->
        <RouterLink :to="{ name: ROUTE_NAMES.RESUMES }" class="back-link">
          <svg class="size-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M19 12H5M12 5l-7 7 7 7"/></svg>
          Resumes
        </RouterLink>

        <div class="tabs-divider"></div>

        <!-- Resume title display -->
        <span class="resume-context-title">{{ resume?.title || 'Loading…' }}</span>

        <div class="tabs-spacer"></div>

        <!-- Mode tabs: Edit | Preview | Optimize -->
        <nav class="workspace-tabs" role="tablist">
          <RouterLink
            :to="{ name: ROUTE_NAMES.RESUME_EDIT, params: { id: resumeId } }"
            class="workspace-tab"
            :class="{ active: false }"
          >
            <svg class="size-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M11 4H4a2 2 0 00-2 2v14a2 2 0 002 2h14a2 2 0 002-2v-7"/><path d="M18.5 2.5a2.121 2.121 0 013 3L12 15l-4 1 1-4 9.5-9.5z"/></svg>
            Edit
          </RouterLink>
          <RouterLink
            :to="{ name: 'resume-print', params: { id: resumeId } }"
            class="workspace-tab"
          >
            <svg class="size-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/><circle cx="12" cy="12" r="3"/></svg>
            Preview
          </RouterLink>
          <RouterLink
            :to="{ name: ROUTE_NAMES.RESUME_OPTIMIZE, params: { id: resumeId } }"
            class="workspace-tab"
            active-class="active"
          >
            <svg class="size-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M13 2L3 14h9l-1 8 10-12h-9l1-8z"/></svg>
            Optimize
          </RouterLink>
        </nav>
      </div>
    </div>

    <!-- Loading state -->
    <div v-if="loading" class="optimize-loading">
      <svg class="spin size-6" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M21 12a9 9 0 11-6.219-8.56"/></svg>
      <span>Loading resume…</span>
    </div>

    <!-- Main content: sidebar + body -->
    <div v-else class="optimize-layout">
      <!-- Sidebar navigation -->
      <aside class="optimize-sidebar">
        <nav class="sidebar-nav">
          <button
            v-for="section in sidebarSections"
            :key="section.id"
            class="sidebar-item"
            :class="{ active: activeSection === section.id }"
            @click="activeSection = section.id"
          >
            <component :is="section.icon" class="size-4" />
            <span>{{ section.label }}</span>
            <span v-if="section.badge" class="sidebar-badge">{{ section.badge }}</span>
            <span v-if="section.soon" class="sidebar-soon">Soon</span>
          </button>
        </nav>
      </aside>

      <!-- Content area -->
      <main class="optimize-content">
        <!-- Overview (fully functional in Phase 3.2) -->
        <ResumeScoreOverview
          v-if="activeSection === 'overview'"
          :resumeId="resumeId"
        />

        <!-- Version History (fully functional in Phase 3.1) -->
        <ResumeVersionHistoryPage
          v-else-if="activeSection === 'versions'"
          :resumeId="resumeId"
          @restored="onResumeRestored"
        />

        <!-- Coming Soon sections -->
        <div v-else class="section-placeholder">
          <div class="placeholder-icon">🔒</div>
          <h2>{{ currentSectionLabel }} — Coming Soon</h2>
          <p>This feature is being built as part of Phase 3. Check the Version History tab which is already live!</p>
          <button class="btn-go-versions" @click="activeSection = 'versions'">
            View Version History →
          </button>
        </div>
      </main>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, defineAsyncComponent, h } from 'vue'
import { RouterLink, useRoute, useRouter } from 'vue-router'
import { useStore } from 'vuex'
import { ROUTE_NAMES } from '../../constants/routes'
import ResumeVersionHistoryPage from './ResumeVersionHistoryPage.vue'
import ResumeScoreOverview from './ResumeScoreOverview.vue'

const route = useRoute()
const router = useRouter()
const store = useStore()

const resumeId = computed(() => route.params.id)
const resume = ref(null)
const loading = ref(false)
const activeSection = ref('overview')

onMounted(async () => {
  loading.value = true
  try {
    const loaded = await store.dispatch('resumes/loadOne', resumeId.value)
    if (loaded) resume.value = loaded
    else router.replace({ name: ROUTE_NAMES.RESUMES })
  } finally {
    loading.value = false
  }
})

// Simple icon components (inline SVGs as render functions)
const IconDashboard = { render: () => h('svg', { viewBox: '0 0 24 24', fill: 'none', stroke: 'currentColor', 'stroke-width': 2 }, [h('rect', { x: 3, y: 3, width: 7, height: 7 }), h('rect', { x: 14, y: 3, width: 7, height: 7 }), h('rect', { x: 14, y: 14, width: 7, height: 7 }), h('rect', { x: 3, y: 14, width: 7, height: 7 })]) }
const IconFile    = { render: () => h('svg', { viewBox: '0 0 24 24', fill: 'none', stroke: 'currentColor', 'stroke-width': 2 }, [h('path', { d: 'M14 2H6a2 2 0 00-2 2v16a2 2 0 002 2h12a2 2 0 002-2V8z' }), h('path', { d: 'M14 2v6h6' })]) }
const IconCheck   = { render: () => h('svg', { viewBox: '0 0 24 24', fill: 'none', stroke: 'currentColor', 'stroke-width': 2 }, [h('path', { d: 'M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z' })]) }
const IconKey     = { render: () => h('svg', { viewBox: '0 0 24 24', fill: 'none', stroke: 'currentColor', 'stroke-width': 2 }, [h('path', { d: 'M21 2l-2 2m-7.61 7.61a5.5 5.5 0 11-7.778 7.778 5.5 5.5 0 017.777-7.777zm0 0L15.5 7.5m0 0l3 3L22 7l-3-3m-3.5 3.5L19 4' })]) }
const IconClock   = { render: () => h('svg', { viewBox: '0 0 24 24', fill: 'none', stroke: 'currentColor', 'stroke-width': 2 }, [h('circle', { cx: 12, cy: 12, r: 10 }), h('path', { d: 'M12 6v6l4 2' })]) }
const IconBriefcase = { render: () => h('svg', { viewBox: '0 0 24 24', fill: 'none', stroke: 'currentColor', 'stroke-width': 2 }, [h('rect', { x: 2, y: 7, width: 20, height: 14, rx: 2 }), h('path', { d: 'M16 7V5a2 2 0 00-2-2h-4a2 2 0 00-2 2v2' })]) }

const sidebarSections = [
  { id: 'overview',  label: 'Overview',         icon: IconDashboard },
  { id: 'content',   label: 'Content Review',   icon: IconFile,       soon: true },
  { id: 'ats',       label: 'ATS Compatibility', icon: IconCheck,     soon: true },
  { id: 'keywords',  label: 'Keywords & Skills', icon: IconKey,       soon: true },
  { id: 'versions',  label: 'Version History',   icon: IconClock,     badge: null },
  { id: 'jobmatch',  label: 'Job Match',         icon: IconBriefcase, soon: true },
]

const currentSectionLabel = computed(() =>
  sidebarSections.find(s => s.id === activeSection.value)?.label || ''
)

function onResumeRestored(updatedResume) {
  if (updatedResume) resume.value = updatedResume
}
</script>

<style scoped>
/* ── Workspace Tab Bar ─────────────────────────────────────────────────────── */
.workspace-tabs-bar {
  position: sticky; top: 0; z-index: 40;
  background: var(--color-surface); border-bottom: 1px solid var(--color-border);
  backdrop-filter: blur(8px);
}
.workspace-tabs-inner {
  max-width: 1400px; margin: 0 auto; padding: 0 1.5rem;
  display: flex; align-items: center; gap: 0.75rem; height: 52px;
}
.back-link {
  display: flex; align-items: center; gap: 0.375rem;
  font-size: 0.8125rem; color: var(--color-text-muted); text-decoration: none;
  transition: color 0.15s;
}
.back-link:hover { color: var(--color-primary); }
.tabs-divider { width: 1px; height: 20px; background: var(--color-border); }
.resume-context-title { font-size: 0.875rem; font-weight: 600; color: var(--color-text-secondary); white-space: nowrap; overflow: hidden; text-overflow: ellipsis; max-width: 200px; }
.tabs-spacer { flex: 1; }

.workspace-tabs { display: flex; gap: 0.25rem; }
.workspace-tab {
  display: flex; align-items: center; gap: 0.375rem;
  padding: 0.375rem 0.875rem; border-radius: 0.5rem;
  font-size: 0.875rem; font-weight: 500; color: var(--color-text-muted);
  text-decoration: none; transition: color 0.15s, background 0.15s;
}
.workspace-tab:hover { color: var(--color-text-primary); background: var(--color-surface-2); }
.workspace-tab.active, .workspace-tab.router-link-active {
  color: var(--color-primary); background: color-mix(in srgb, var(--color-primary) 10%, transparent);
  font-weight: 600;
}

/* ── Loading ───────────────────────────────────────────────────────────────── */
.optimize-loading { display: flex; align-items: center; gap: 0.75rem; justify-content: center; padding: 4rem; color: var(--color-text-muted); }

/* ── Layout ────────────────────────────────────────────────────────────────── */
.optimize-layout { display: grid; grid-template-columns: 220px 1fr; min-height: calc(100vh - 52px); }
@media (max-width: 768px) { .optimize-layout { grid-template-columns: 1fr; } }

/* ── Sidebar ───────────────────────────────────────────────────────────────── */
.optimize-sidebar {
  border-right: 1px solid var(--color-border); background: var(--color-surface);
  padding: 1.25rem 0.75rem; position: sticky; top: 52px; height: calc(100vh - 52px); overflow-y: auto;
}
@media (max-width: 768px) { .optimize-sidebar { position: static; height: auto; border-right: none; border-bottom: 1px solid var(--color-border); padding: 0.75rem; } }

.sidebar-nav { display: flex; flex-direction: column; gap: 0.25rem; }
@media (max-width: 768px) { .sidebar-nav { flex-direction: row; overflow-x: auto; gap: 0.375rem; } }

.sidebar-item {
  display: flex; align-items: center; gap: 0.625rem;
  padding: 0.6rem 0.875rem; border-radius: 0.5rem; border: none;
  font-size: 0.875rem; font-weight: 500; color: var(--color-text-secondary);
  background: transparent; cursor: pointer; text-align: left; width: 100%;
  transition: color 0.15s, background 0.15s; white-space: nowrap;
}
.sidebar-item:hover { color: var(--color-text-primary); background: var(--color-surface-2); }
.sidebar-item.active { color: var(--color-primary); background: color-mix(in srgb, var(--color-primary) 10%, transparent); font-weight: 600; }

.sidebar-badge { margin-left: auto; background: var(--color-primary); color: #fff; font-size: 0.625rem; font-weight: 700; padding: 0.125rem 0.375rem; border-radius: 9999px; }
.sidebar-soon { margin-left: auto; font-size: 0.625rem; font-weight: 700; text-transform: uppercase; letter-spacing: 0.05em; color: var(--color-text-muted); opacity: 0.6; }

/* ── Content Area ──────────────────────────────────────────────────────────── */
.optimize-content { padding: 0; overflow: hidden; }

/* ── Placeholders ──────────────────────────────────────────────────────────── */
.section-placeholder {
  display: flex; flex-direction: column; align-items: center; justify-content: center;
  gap: 1rem; padding: 4rem 2rem; text-align: center; min-height: 400px; max-width: 500px; margin: 0 auto;
}
.placeholder-icon { font-size: 3rem; }
.section-placeholder h2 { font-size: 1.375rem; font-weight: 700; color: var(--color-text-primary); margin: 0; }
.section-placeholder p { font-size: 0.9375rem; color: var(--color-text-muted); margin: 0; line-height: 1.6; }
.placeholder-chips { display: flex; flex-wrap: wrap; gap: 0.5rem; justify-content: center; margin-top: 0.5rem; }
.placeholder-chips span {
  font-size: 0.75rem; font-weight: 600; padding: 0.25rem 0.75rem; border-radius: 9999px;
  background: var(--color-surface-2); color: var(--color-text-muted); border: 1px solid var(--color-border);
}
.btn-go-versions {
  margin-top: 0.5rem; padding: 0.625rem 1.25rem; border-radius: 0.5rem; border: none;
  background: var(--color-primary); color: #fff; font-size: 0.875rem; font-weight: 600; cursor: pointer; transition: opacity 0.2s;
}
.btn-go-versions:hover { opacity: 0.9; }

/* ── Utilities ─────────────────────────────────────────────────────────────── */
.spin { animation: spin 1s linear infinite; }
@keyframes spin { to { transform: rotate(360deg); } }
.size-4 { width: 1rem; height: 1rem; }
.size-6 { width: 1.5rem; height: 1.5rem; }
</style>
