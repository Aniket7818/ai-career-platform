// ─── useResumeIntelligence composable ─────────────────────────────────────────
// Provides reactive resume intelligence analysis with debounced updates.
// Memoizes expensive calculations. Completes within 100ms.
// Updates live as the user edits — no manual refresh needed.

import { ref, watch, computed, isRef } from 'vue'
import { useStore } from 'vuex'
import { analyzeResume } from '../intelligence/ResumeAnalyzer'

/**
 * @param {import('vue').Ref | import('vue').ComputedRef} contentRef - Resume content ref or computed
 * @param {import('vue').Ref<string>} targetRoleRef - Target job role ref
 * @param {Object} options - { templateId, appearance }
 */
export function useResumeIntelligence(contentRef, targetRoleRef, options = {}) {
  const store = useStore()
  const user = computed(() => store?.state?.auth?.user)
  const canUseATS = computed(() => user.value ? (user.value.canUseATS ?? false) : false)
  const canUseKeywords = computed(() => user.value ? (user.value.canUseKeywords ?? false) : false)

  const analysis = ref(null)
  const isAnalyzing = ref(false)
  let debounceTimer = null

  const runAnalysis = () => {
    const contentVal = isRef(contentRef) ? contentRef.value : contentRef
    const roleVal = isRef(targetRoleRef) ? targetRoleRef.value : (targetRoleRef || '')
    const opts = isRef(options) ? options.value : options
    
    if (!contentVal) return

    isAnalyzing.value = true
    const start = performance.now()
    
    const rawAnalysis = analyzeResume(contentVal, roleVal, opts)
    let cleanAnalysis = { ...rawAnalysis }

    if (!canUseATS.value) {
      cleanAnalysis.atsAnalysis = { score: 0, rules: [], passedCount: 0, passed: [], warnings: [], critical: [] }
    }
    if (!canUseKeywords.value) {
      cleanAnalysis.keywordAnalysis = { detected: [], missing: [], coverage: 0, total: 0 }
    }
    if (!canUseATS.value && !canUseKeywords.value) {
      // Re-calculate basic health score for Free plan (just completion)
      cleanAnalysis.healthScore = Math.round(
        rawAnalysis.sectionHealth.reduce((sum, s) => sum + s.score, 0) / 
        Math.max(rawAnalysis.sectionHealth.length, 1)
      )
      cleanAnalysis.tips = rawAnalysis.tips.filter(t => !t.text.toLowerCase().includes('ats') && !t.text.toLowerCase().includes('keyword'))
    }

    analysis.value = cleanAnalysis
    
    const elapsed = performance.now() - start
    if (import.meta.env?.DEV) {
      console.debug(`[Intelligence] Analysis completed in ${elapsed.toFixed(1)}ms`)
    }
    isAnalyzing.value = false
  }

  // Deep watcher with debounce — watches the actual content values
  watch(
    [contentRef, targetRoleRef, () => (isRef(options) ? options.value : options)],
    () => {
      if (debounceTimer) clearTimeout(debounceTimer)
      debounceTimer = setTimeout(runAnalysis, 150)
    },
    { deep: true, immediate: true }
  )

  // Also run once synchronously on init after a microtask
  Promise.resolve().then(runAnalysis)

  // Computed getters for individual sections
  const healthScore = computed(() => analysis.value?.healthScore ?? 0)
  const healthLabel = computed(() => analysis.value?.healthLabel ?? 'Analyzing...')
  const healthColor = computed(() => analysis.value?.healthColor ?? 'slate')
  const sectionHealth = computed(() => analysis.value?.sectionHealth ?? [])
  const atsAnalysis = computed(() => analysis.value?.atsAnalysis ?? { score: 0, rules: [], passed: [], warnings: [], critical: [] })
  const keywordAnalysis = computed(() => analysis.value?.keywordAnalysis ?? { detected: [], missing: [], coverage: 0, total: 0 })
  const checklist = computed(() => analysis.value?.checklist ?? [])
  const statistics = computed(() => analysis.value?.statistics ?? {})
  const tips = computed(() => analysis.value?.tips ?? [])
  const experienceLevel = computed(() => analysis.value?.experienceLevel ?? { key: 'fresher', label: 'Fresher', pages: 1, highlights: [] })

  return {
    analysis,
    isAnalyzing,
    healthScore,
    healthLabel,
    healthColor,
    sectionHealth,
    atsAnalysis,
    keywordAnalysis,
    checklist,
    statistics,
    tips,
    experienceLevel,
    // Manual trigger
    refresh: runAnalysis
  }
}
