<template>
  <div class="optimize-page min-h-screen bg-background">
    <!-- Workspace Tab Bar -->
    <div class="workspace-tabs-bar">
      <div class="workspace-tabs-inner">
        <!-- Mobile hamburger menu button -->
        <button class="mobile-menu-toggle" @click="isDrawerOpen = true" aria-label="Open Optimize Menu">
          <svg class="size-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M4 6h16M4 12h16M4 18h16" /></svg>
        </button>

        <!-- Back to resume list -->
        <RouterLink :to="{ name: ROUTE_NAMES.RESUMES }" class="back-link">
          <svg class="size-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M19 12H5M12 5l-7 7 7 7"/></svg>
          <span class="back-text">Resumes</span>
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
            <span class="tab-label">Edit</span>
          </RouterLink>
          <RouterLink
            :to="{ name: 'resume-print', params: { id: resumeId } }"
            class="workspace-tab"
          >
            <svg class="size-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/><circle cx="12" cy="12" r="3"/></svg>
            <span class="tab-label">Preview</span>
          </RouterLink>
          <RouterLink
            :to="{ name: ROUTE_NAMES.RESUME_OPTIMIZE, params: { id: resumeId } }"
            class="workspace-tab"
            active-class="active"
          >
            <svg class="size-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M13 2L3 14h9l-1 8 10-12h-9l1-8z"/></svg>
            <span class="tab-label">Optimize</span>
          </RouterLink>
        </nav>
      </div>
    </div>

    <!-- Mobile Navigation Drawer -->
    <Transition name="drawer-fade">
      <div v-if="isDrawerOpen" class="drawer-overlay" @click="isDrawerOpen = false">
        <div class="drawer-content" @click.stop>
          <!-- Drawer Header -->
          <div class="drawer-header">
            <div class="drawer-user-info">
              <span class="avatar-circle">
                <template v-if="user?.avatar">
                  <img :src="user.avatar" class="size-full object-cover" />
                </template>
                <template v-else>{{ initials }}</template>
              </span>
              <div class="drawer-user-details">
                <div class="drawer-username">{{ user?.full_name || user?.username || 'User' }}</div>
                <div class="drawer-plan">Premium Plan</div>
              </div>
            </div>
            <button class="btn-close-drawer" @click="isDrawerOpen = false">
              <svg class="size-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M18 6L6 18M6 6l12 12"/></svg>
            </button>
          </div>

          <!-- Drawer Navigation -->
          <div class="drawer-nav-container">
            <!-- Group 1: Resume Optimization -->
            <div class="drawer-nav-group">
              <div class="drawer-group-label">Resume Optimization</div>
              <button
                v-for="section in sidebarSections"
                :key="section.id"
                class="drawer-nav-item"
                :class="{ active: isMobile ? (activeMobileTab === getSectionMobileTab(section.id)) : (activeSection === section.id) }"
                @click="selectSection(section.id)"
              >
                <component :is="section.icon" class="size-4" />
                <span>{{ section.label }}</span>
                <span v-if="section.badge" class="sidebar-badge">{{ section.badge }}</span>
                <span v-if="section.soon" class="sidebar-soon">Soon</span>
              </button>
            </div>

            <!-- Group 2: AI Toolkit -->
            <div class="drawer-nav-group">
              <div class="drawer-group-label">AI Toolkit</div>
              <button class="drawer-nav-item" @click="triggerWorkflow('generate_linkedin')">
                <svg class="size-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M16 8a6 6 0 0 1 6 6v7h-4v-7a2 2 0 0 0-2-2 2 2 0 0 0-2 2v7h-4v-7a6 6 0 0 1 6-6zM2 9h4v12H2z"/><circle cx="4" cy="4" r="2"/></svg>
                <span>LinkedIn Optimizer</span>
              </button>
              <button class="drawer-nav-item" @click="triggerWorkflow('generate_cover_letter')">
                <svg class="size-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2zM22 6l-10 7L2 6"/></svg>
                <span>Cover Letter</span>
              </button>
              <button class="drawer-nav-item" @click="triggerWorkflow('tailor_to_job')">
                <svg class="size-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M14.7 6.3a1 1 0 0 0 0 1.4l1.6 1.6a1 1 0 0 0 1.4 0l3.77-3.77a6 6 0 0 1-7.94 7.94l-6.91 6.91a2.12 2.12 0 0 1-3-3l6.91-6.91a6 6 0 0 1 7.94-7.94l-3.76 3.76z"/></svg>
                <span>Tailor Resume</span>
              </button>
              <button class="drawer-nav-item" @click="navigateToRoute('/interview-prep')">
                <svg class="size-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"/></svg>
                <span>Interview Preparation</span>
              </button>
              <button class="drawer-nav-item" disabled>
                <svg class="size-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="3" width="18" height="18" rx="2"/><path d="M9 17V9l7 4-7 4z"/></svg>
                <span>Portfolio Builder <span class="sidebar-soon">Soon</span></span>
              </button>
            </div>

            <!-- Group 3: Account & Billing -->
            <div class="drawer-nav-group">
              <div class="drawer-group-label">Credits & Billing</div>
              <div class="drawer-credits-card">
                <div class="credits-label">AI Credits Remaining</div>
                <div class="credits-count">{{ creditsRemaining }}</div>
                <div class="credits-bar">
                  <div class="credits-bar-fill" :style="{ width: `${creditsPercentage}%` }"></div>
                </div>
                <button class="btn-buy-credits" @click="navigateToRoute('/settings')">
                  Buy More Credits
                </button>
              </div>
            </div>

            <!-- Settings -->
            <div class="drawer-nav-group">
              <button class="drawer-nav-item" @click="navigateToRoute('/settings')">
                <svg class="size-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="3"/><path d="M19.4 15a1.65 1.65 0 0 0 .33 1.82l.06.06a2 2 0 1 1-2.83 2.83l-.06-.06a1.65 1.65 0 0 0-1.82-.33 1.65 1.65 0 0 0-1 1.51V21a2 2 0 0 1-4 0v-.09A1.65 1.65 0 0 0 9 19.4a1.65 1.65 0 0 0-1.82.33l-.06.06a2 2 0 1 1-2.83-2.83l.06-.06a1.65 1.65 0 0 0 .33-1.82 1.65 1.65 0 0 0-1.51-1H3a2 2 0 0 1 0-4h.09A1.65 1.65 0 0 0 4.6 9a1.65 1.65 0 0 0-.33-1.82l-.06-.06a2 2 0 1 1 2.83-2.83l.06.06a1.65 1.65 0 0 0 1.82.33H9a1.65 1.65 0 0 0 1-1.51V3a2 2 0 0 1 4 0v.09a1.65 1.65 0 0 0 1 1.51 1.65 1.65 0 0 0 1.82-.33l.06-.06a2 2 0 1 1 2.83 2.83l-.06.06a1.65 1.65 0 0 0-.33 1.82V9a1.65 1.65 0 0 0 1.51 1H21a2 2 0 0 1 0 4h-.09a1.65 1.65 0 0 0-1.51 1z"/></svg>
                <span>Settings</span>
              </button>
            </div>
          </div>
        </div>
      </div>
    </Transition>

    <!-- Loading state -->
    <div v-if="loading" class="optimize-loading">
      <svg class="spin size-6" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M21 12a9 9 0 11-6.219-8.56"/></svg>
      <span>Loading resume…</span>
    </div>

    <!-- Main content: sidebar + body -->
    <div v-else class="optimize-layout">
      <!-- Sidebar navigation (desktop only) -->
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
        <ResumeScoreOverview
          v-if="isMobile ? (activeMobileTab === 'overview' || activeMobileTab === 'review' || activeMobileTab === 'insights') : (activeSection === 'overview')"
          :resumeId="resumeId"
          :resume="resume"
          :mobileTab="isMobile ? activeMobileTab : null"
          @update-resume="resume = $event"
          ref="scoreOverviewRef"
        />

        <!-- Version History -->
        <ResumeVersionHistoryPage
          v-else-if="isMobile ? (activeMobileTab === 'history') : (activeSection === 'versions')"
          :resumeId="resumeId"
          @restored="onResumeRestored"
        />

        <!-- Coming Soon sections (desktop only, since mobile drawer maps to tabs) -->
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


    <!-- Sticky Bottom Navigation (Mobile Only) -->
    <nav class="mobile-bottom-nav" v-if="isMobile">
      <button 
        class="bottom-nav-item" 
        :class="{ active: activeMobileTab === 'overview' }"
        @click="selectMobileTab('overview')"
      >
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
          <rect x="3" y="3" width="7" height="7" />
          <rect x="14" y="3" width="7" height="7" />
          <rect x="14" y="14" width="7" height="7" />
          <rect x="3" y="14" width="7" height="7" />
        </svg>
        <span>Overview</span>
      </button>

      <button 
        class="bottom-nav-item" 
        :class="{ active: activeMobileTab === 'review' }"
        @click="selectMobileTab('review')"
      >
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
          <path d="M14 2H6a2 2 0 00-2 2v16a2 2 0 002 2h12a2 2 0 002-2V8z" />
          <path d="M14 2v6h6" />
          <path d="M16 13H8M16 17H8" />
        </svg>
        <span>Review</span>
      </button>

      <button 
        class="bottom-nav-item" 
        :class="{ active: activeMobileTab === 'insights' }"
        @click="selectMobileTab('insights')"
      >
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
          <line x1="18" y1="20" x2="18" y2="10" />
          <line x1="12" y1="20" x2="12" y2="4" />
          <line x1="6" y1="20" x2="6" y2="14" />
        </svg>
        <span>Insights</span>
      </button>

      <button 
        class="bottom-nav-item" 
        :class="{ active: activeMobileTab === 'history' }"
        @click="selectMobileTab('history')"
      >
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
          <circle cx="12" cy="12" r="10" />
          <path d="M12 6v6l4 2" />
        </svg>
        <span>History</span>
      </button>

      <button 
        class="bottom-nav-item" 
        @click="isDrawerOpen = true"
      >
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
          <line x1="3" y1="12" x2="21" y2="12" />
          <line x1="3" y1="6" x2="21" y2="6" />
          <line x1="3" y1="18" x2="21" y2="18" />
        </svg>
        <span>Menu</span>
      </button>
    </nav>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, onBeforeUnmount, h, nextTick } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useStore } from 'vuex'
import { ROUTE_NAMES } from '../../constants/routes'
import ResumeVersionHistoryPage from './ResumeVersionHistoryPage.vue'
import ResumeScoreOverview from './ResumeScoreOverview.vue'

const route = useRoute()
const router = useRouter()
const store = useStore()

const resumeId = computed(() => route.params.id)
const resume = computed({
  get: () => store.state.resumes.currentResume,
  set: (val) => {
    if (val) store.commit('resumes/updateOne', val)
  }
})
const loading = ref(false)
const activeSection = ref('overview')
const activeMobileTab = ref('overview')
const isDrawerOpen = ref(false)
const scoreOverviewRef = ref(null)

const user = computed(() => store.state.auth.user)
const initials = computed(() => {
  const name = user.value?.full_name || user.value?.username || user.value?.email || 'U'
  return name.split(' ').map((p) => p[0]).join('').slice(0, 2).toUpperCase()
})

const creditsRemaining = computed(() => store.state.auth.user?.ai_credits_remaining || 0)
const totalCredits = ref(100)
const creditsPercentage = computed(() => Math.min(100, (creditsRemaining.value / totalCredits.value) * 100))

const isMobile = ref(false)
let mediaQuery = null

const listener = (e) => {
  isMobile.value = e.matches
  if (e.matches) {
    if (activeSection.value === 'versions') {
      activeMobileTab.value = 'history'
    } else if (activeSection.value === 'content') {
      activeMobileTab.value = 'review'
    } else if (activeSection.value === 'ats' || activeSection.value === 'keywords') {
      activeMobileTab.value = 'insights'
    } else {
      activeMobileTab.value = 'overview'
    }
  } else {
    if (activeMobileTab.value === 'history') {
      activeSection.value = 'versions'
    } else if (activeMobileTab.value === 'review') {
      activeSection.value = 'content'
    } else if (activeMobileTab.value === 'insights') {
      activeSection.value = 'ats'
    } else {
      activeSection.value = 'overview'
    }
  }
}

onMounted(async () => {
  if (typeof window !== 'undefined') {
    mediaQuery = window.matchMedia('(max-width: 768px)')
    isMobile.value = mediaQuery.matches
    mediaQuery.addEventListener('change', listener)
    
    // Initial sync
    if (isMobile.value) {
      if (activeSection.value === 'versions') {
        activeMobileTab.value = 'history'
      } else if (activeSection.value === 'content') {
        activeMobileTab.value = 'review'
      } else if (activeSection.value === 'ats' || activeSection.value === 'keywords') {
        activeMobileTab.value = 'insights'
      } else {
        activeMobileTab.value = 'overview'
      }
    }
  }

  loading.value = true
  try {
    const loaded = await store.dispatch('resumes/loadOne', resumeId.value)
    if (!loaded) router.replace({ name: ROUTE_NAMES.RESUMES })
  } finally {
    loading.value = false
  }
})

onBeforeUnmount(() => {
  if (mediaQuery) {
    mediaQuery.removeEventListener('change', listener)
  }
})

function getSectionMobileTab(sectionId) {
  if (sectionId === 'overview') return 'overview'
  if (sectionId === 'content') return 'review'
  if (sectionId === 'ats' || sectionId === 'keywords') return 'insights'
  if (sectionId === 'versions') return 'history'
  return 'overview'
}

function selectSection(sectionId) {
  isDrawerOpen.value = false
  activeSection.value = sectionId
  
  if (isMobile.value) {
    if (sectionId === 'overview') {
      activeMobileTab.value = 'overview'
    } else if (sectionId === 'content') {
      activeMobileTab.value = 'review'
      activeSection.value = 'overview'
    } else if (sectionId === 'ats' || sectionId === 'keywords') {
      activeMobileTab.value = 'insights'
      activeSection.value = 'overview'
    } else if (sectionId === 'versions') {
      activeMobileTab.value = 'history'
    }
  }
}

function selectMobileTab(tab) {
  activeMobileTab.value = tab
  if (tab === 'history') {
    activeSection.value = 'versions'
  } else if (tab === 'review') {
    activeSection.value = 'overview'
  } else if (tab === 'insights') {
    activeSection.value = 'overview'
  } else {
    activeSection.value = 'overview'
  }
}

async function triggerWorkflow(type) {
  isDrawerOpen.value = false
  if (isMobile.value) {
    activeMobileTab.value = 'overview'
    activeSection.value = 'overview'
    await nextTick()
  } else if (activeSection.value !== 'overview') {
    activeSection.value = 'overview'
    await nextTick()
  }
  if (scoreOverviewRef.value) {
    scoreOverviewRef.value.openWorkflow(type)
  }
}

function navigateToRoute(path) {
  isDrawerOpen.value = false
  router.push(path)
}

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
  background: rgb(var(--color-surface)); border-bottom: 1px solid rgb(var(--color-border));
  backdrop-filter: blur(8px);
}
.workspace-tabs-inner {
  max-width: 1400px; margin: 0 auto; padding: 0 1.5rem;
  display: flex; align-items: center; gap: 0.75rem; height: 52px;
}
.back-link {
  display: flex; align-items: center; gap: 0.375rem;
  font-size: 0.8125rem; color: rgb(var(--color-text-muted)); text-decoration: none;
  transition: color 0.15s;
}
.back-link:hover { color: rgb(var(--color-primary)); }
.tabs-divider { width: 1px; height: 20px; background: rgb(var(--color-border)); }
.resume-context-title { font-size: 0.875rem; font-weight: 600; color: rgb(var(--color-text-secondary)); white-space: nowrap; overflow: hidden; text-overflow: ellipsis; max-width: 200px; }
.tabs-spacer { flex: 1; }

.workspace-tabs { display: flex; gap: 0.25rem; }
.workspace-tab {
  display: flex; align-items: center; gap: 0.375rem;
  padding: 0.375rem 0.875rem; border-radius: 0.5rem;
  font-size: 0.875rem; font-weight: 500; color: rgb(var(--color-text-muted));
  text-decoration: none; transition: color 0.15s, background 0.15s;
}
.workspace-tab:hover { color: rgb(var(--color-text-primary)); background: rgb(var(--color-surface-hover)); }
.workspace-tab.active, .workspace-tab.router-link-active {
  color: rgb(var(--color-primary)); background: color-mix(in srgb, rgb(var(--color-primary)) 10%, transparent);
  font-weight: 600;
}

/* ── Mobile Drawer Toggle & Style ────────────────────────────────────────── */
.mobile-menu-toggle {
  display: none;
  background: transparent;
  border: none;
  color: rgb(var(--color-text-primary));
  padding: 0.5rem;
  cursor: pointer;
  border-radius: 0.375rem;
  align-items: center;
  justify-content: center;
}
.mobile-menu-toggle:hover {
  background: rgb(var(--color-surface-hover));
}

.drawer-overlay {
  position: fixed;
  inset: 0;
  z-index: 100;
  background: rgba(15, 23, 42, 0.6);
  backdrop-filter: blur(4px);
  display: flex;
  justify-content: flex-start;
}

.drawer-content {
  width: 290px;
  max-width: 85vw;
  height: 100%;
  background: rgb(var(--color-surface));
  border-right: 1px solid rgb(var(--color-border));
  display: flex;
  flex-direction: column;
  box-shadow: 10px 0 30px rgba(0, 0, 0, 0.1);
  overflow-y: auto;
}

.drawer-header {
  padding: 1.25rem 1.5rem;
  border-bottom: 1px solid rgb(var(--color-border));
  display: flex;
  align-items: center;
  justify-content: space-between;
}

.drawer-user-info {
  display: flex;
  align-items: center;
  gap: 0.75rem;
}

.avatar-circle {
  width: 40px;
  height: 40px;
  border-radius: 50%;
  background: linear-gradient(135deg, rgb(var(--color-primary)), #8b5cf6);
  color: white;
  font-weight: 700;
  font-size: 0.875rem;
  display: flex;
  align-items: center;
  justify-content: center;
  overflow: hidden;
}

.drawer-user-details {
  display: flex;
  flex-direction: column;
}

.drawer-username {
  font-size: 0.875rem;
  font-weight: 600;
  color: rgb(var(--color-text-primary));
}

.drawer-plan {
  font-size: 0.75rem;
  color: rgb(var(--color-primary));
  font-weight: 500;
}

.btn-close-drawer {
  background: transparent;
  border: none;
  color: rgb(var(--color-text-muted));
  cursor: pointer;
  padding: 0.25rem;
  border-radius: 0.25rem;
  display: flex;
  align-items: center;
  justify-content: center;
}
.btn-close-drawer:hover {
  color: rgb(var(--color-text-primary));
  background: rgb(var(--color-surface-hover));
}

.drawer-nav-container {
  padding: 1rem;
  display: flex;
  flex-direction: column;
  gap: 1.5rem;
  flex: 1;
}

.drawer-nav-group {
  display: flex;
  flex-direction: column;
  gap: 0.25rem;
}

.drawer-group-label {
  font-size: 0.75rem;
  font-weight: 700;
  text-transform: uppercase;
  color: rgb(var(--color-text-muted));
  letter-spacing: 0.05em;
  padding: 0.25rem 0.75rem;
  margin-bottom: 0.25rem;
}

.drawer-nav-item {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  padding: 0.65rem 0.75rem;
  border-radius: 0.5rem;
  border: none;
  background: transparent;
  color: rgb(var(--color-text-secondary));
  font-size: 0.875rem;
  font-weight: 500;
  cursor: pointer;
  text-align: left;
  transition: all 0.2s;
  width: 100%;
}
.drawer-nav-item:hover:not(:disabled) {
  color: rgb(var(--color-text-primary));
  background: rgb(var(--color-surface-hover));
}
.drawer-nav-item.active {
  color: rgb(var(--color-primary));
  background: color-mix(in srgb, rgb(var(--color-primary)) 10%, transparent);
  font-weight: 600;
}
.drawer-nav-item:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

/* Credits card inside drawer */
.drawer-credits-card {
  background: rgb(var(--color-surface-hover));
  border: 1px solid rgb(var(--color-border));
  border-radius: 0.75rem;
  padding: 1rem;
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
}

.credits-label {
  font-size: 0.75rem;
  color: rgb(var(--color-text-secondary));
  font-weight: 500;
}

.credits-count {
  font-size: 1.125rem;
  font-weight: 700;
  color: rgb(var(--color-text-primary));
}

.credits-bar {
  height: 6px;
  background: rgb(var(--color-border));
  border-radius: 3px;
  overflow: hidden;
}

.credits-bar-fill {
  height: 100%;
  background: linear-gradient(90deg, rgb(var(--color-primary)), #8b5cf6);
  border-radius: 3px;
}

.btn-buy-credits {
  margin-top: 0.25rem;
  background: transparent;
  border: 1px solid rgb(var(--color-primary));
  color: rgb(var(--color-primary));
  padding: 0.4rem;
  border-radius: 0.5rem;
  font-size: 0.75rem;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.2s;
  text-align: center;
}
.btn-buy-credits:hover {
  background: rgb(var(--color-primary));
  color: white;
}

/* Drawer Transitions */
.drawer-fade-enter-active,
.drawer-fade-leave-active {
  transition: opacity 0.3s ease;
}
.drawer-fade-enter-active .drawer-content,
.drawer-fade-leave-active .drawer-content {
  transition: transform 0.3s cubic-bezier(0.4, 0, 0.2, 1);
}

.drawer-fade-enter-from {
  opacity: 0;
}
.drawer-fade-enter-from .drawer-content {
  transform: translateX(-100%);
}

.drawer-fade-leave-to {
  opacity: 0;
}
.drawer-fade-leave-to .drawer-content {
  transform: translateX(-100%);
}

/* ── Loading ───────────────────────────────────────────────────────────────── */
.optimize-loading { display: flex; align-items: center; gap: 0.75rem; justify-content: center; padding: 4rem; color: rgb(var(--color-text-muted)); }

/* ── Layout ────────────────────────────────────────────────────────────────── */
.optimize-layout { display: grid; grid-template-columns: 220px 1fr; min-height: calc(100vh - 52px); }

/* ── Sidebar ───────────────────────────────────────────────────────────────── */
.optimize-sidebar {
  border-right: 1px solid rgb(var(--color-border)); background: rgb(var(--color-surface));
  padding: 1.25rem 0.75rem; position: sticky; top: 52px; height: calc(100vh - 52px); overflow-y: auto;
}

.sidebar-nav { display: flex; flex-direction: column; gap: 0.25rem; }

.sidebar-item {
  display: flex; align-items: center; gap: 0.625rem;
  padding: 0.6rem 0.875rem; border-radius: 0.5rem; border: none;
  font-size: 0.875rem; font-weight: 500; color: rgb(var(--color-text-secondary));
  background: transparent; cursor: pointer; text-align: left; width: 100%;
  transition: color 0.15s, background 0.15s; white-space: nowrap;
}
.sidebar-item:hover { color: rgb(var(--color-text-primary)); background: rgb(var(--color-surface-hover)); }
.sidebar-item.active { color: rgb(var(--color-primary)); background: color-mix(in srgb, rgb(var(--color-primary)) 10%, transparent); font-weight: 600; }

.sidebar-badge { margin-left: auto; background: rgb(var(--color-primary)); color: #fff; font-size: 0.625rem; font-weight: 700; padding: 0.125rem 0.375rem; border-radius: 9999px; }
.sidebar-soon { margin-left: auto; font-size: 0.625rem; font-weight: 700; text-transform: uppercase; letter-spacing: 0.05em; color: rgb(var(--color-text-muted)); opacity: 0.6; }

/* ── Content Area ──────────────────────────────────────────────────────────── */
.optimize-content { padding: 0; overflow: hidden; }

/* ── Placeholders ──────────────────────────────────────────────────────────── */
.section-placeholder {
  display: flex; flex-direction: column; align-items: center; justify-content: center;
  gap: 1rem; padding: 4rem 2rem; text-align: center; min-height: 400px; max-width: 500px; margin: 0 auto;
}
.placeholder-icon { font-size: 3rem; }
.section-placeholder h2 { font-size: 1.375rem; font-weight: 700; color: rgb(var(--color-text-primary)); margin: 0; }
.section-placeholder p { font-size: 0.9375rem; color: rgb(var(--color-text-muted)); margin: 0; line-height: 1.6; }
.placeholder-chips { display: flex; flex-wrap: wrap; gap: 0.5rem; justify-content: center; margin-top: 0.5rem; }
.placeholder-chips span {
  font-size: 0.75rem; font-weight: 600; padding: 0.25rem 0.75rem; border-radius: 9999px;
  background: rgb(var(--color-surface-hover)); color: rgb(var(--color-text-muted)); border: 1px solid rgb(var(--color-border));
}
.btn-go-versions {
  margin-top: 0.5rem; padding: 0.625rem 1.25rem; border-radius: 0.5rem; border: none;
  background: rgb(var(--color-primary)); color: #fff; font-size: 0.875rem; font-weight: 600; cursor: pointer; transition: opacity 0.2s;
}
.btn-go-versions:hover { opacity: 0.9; }

/* ── Mobile Bottom Navigation Bar ──────────────────────────────────────────── */
.mobile-bottom-nav {
  position: fixed;
  bottom: 0;
  left: 0;
  right: 0;
  height: 64px;
  background: rgba(var(--color-surface), 0.85);
  backdrop-filter: blur(16px);
  border-top: 1.5px solid rgb(var(--color-border));
  display: none;
  grid-template-columns: repeat(5, 1fr);
  z-index: 50;
  box-shadow: 0 -4px 20px rgba(0, 0, 0, 0.08);
  padding-bottom: env(safe-area-inset-bottom, 0);
}

.bottom-nav-item {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 0.25rem;
  background: transparent;
  border: none;
  color: rgb(var(--color-text-muted));
  font-size: 0.6875rem;
  font-weight: 700;
  cursor: pointer;
  transition: all 0.2s cubic-bezier(0.4, 0, 0.2, 1);
  padding: 0.25rem 0;
}

.bottom-nav-item:hover {
  color: rgb(var(--color-text-primary));
}

.bottom-nav-item.active {
  color: rgb(var(--color-primary));
}

.bottom-nav-item svg {
  width: 1.375rem;
  height: 1.375rem;
  transition: transform 0.2s cubic-bezier(0.4, 0, 0.2, 1);
}

.bottom-nav-item.active svg {
  transform: scale(1.1);
}

/* ── Utilities ─────────────────────────────────────────────────────────────── */
.spin { animation: spin 1s linear infinite; }
@keyframes spin { to { transform: rotate(360deg); } }
.size-4 { width: 1rem; height: 1rem; }
.size-5 { width: 1.25rem; height: 1.25rem; }

/* ── Responsive media queries ──────────────────────────────────────────────── */
@media (max-width: 768px) {
  .optimize-layout { grid-template-columns: 1fr; }
  .optimize-sidebar { display: none; }
  .mobile-menu-toggle { display: flex; }
  .back-text { display: none; }
  .resume-context-title { max-width: 110px; font-size: 0.8rem; }
  
  .optimize-page {
    padding-bottom: 80px; /* Space for bottom navigation only */
  }
  .mobile-bottom-nav {
    display: grid;
  }
}

@media (max-width: 480px) {
  .workspace-tab .tab-label { display: none; }
  .workspace-tab { padding: 0.5rem; }
  .workspace-tabs-inner { padding: 0 0.75rem; gap: 0.5rem; }
  .resume-context-title { max-width: 70px; }
}
</style>
