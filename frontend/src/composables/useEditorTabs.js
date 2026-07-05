// ─── useEditorTabs composable ──────────────────────────────────────────────────
// Manages mobile tab navigation state for the resume editor.
// Persists active tab in sessionStorage for tab restoration.

import { ref, onMounted, onUnmounted, computed } from 'vue'

export const EDITOR_TABS = Object.freeze({
 RESUME: 'resume',
 PREVIEW: 'preview',
 INSIGHTS: 'insights',
 MORE: 'more'
})

const STORAGE_KEY = 'careerai_editor_tab'

export function useEditorTabs() {
 const activeTab = ref(EDITOR_TABS.RESUME)
 const isMobile = ref(false)
 
 const checkMobile = () => {
 isMobile.value = window.innerWidth < 1024
 }

 onMounted(() => {
 checkMobile()
 window.addEventListener('resize', checkMobile)
 
 // Restore last active tab
 const saved = sessionStorage.getItem(STORAGE_KEY)
 if (saved && Object.values(EDITOR_TABS).includes(saved)) {
 activeTab.value = saved
 }
 })

 onUnmounted(() => {
 window.removeEventListener('resize', checkMobile)
 })

 const setTab = (tab) => {
 activeTab.value = tab
 sessionStorage.setItem(STORAGE_KEY, tab)
 }

 const isTab = (tab) => activeTab.value === tab

 // On desktop, all panels are visible regardless of tab
 const showResumeEditor = computed(() => !isMobile.value || activeTab.value === EDITOR_TABS.RESUME)
 const showPreview = computed(() => !isMobile.value || activeTab.value === EDITOR_TABS.PREVIEW)
 const showInsights = computed(() => !isMobile.value || activeTab.value === EDITOR_TABS.INSIGHTS)
 const showMore = computed(() => !isMobile.value || activeTab.value === EDITOR_TABS.MORE)

 return {
 activeTab,
 isMobile,
 setTab,
 isTab,
 showResumeEditor,
 showPreview,
 showInsights,
 showMore,
 EDITOR_TABS
 }
}
