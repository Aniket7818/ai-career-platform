<template>
  <div class="section-health-card" :class="[healthClass, { 'expanded': expanded }]">
    <div class="shc-header" @click="expanded = !expanded">
      <div class="shc-title-group">
        <h3 class="shc-title">{{ title }}</h3>
        <div class="health-badge" :class="healthClass">{{ healthLabel }}</div>
      </div>
      
      <div class="header-right">
        <div class="progress-container">
          <div class="progress-bar" v-if="!isMobile">
            <div class="progress-fill" :style="{ width: `${progress}%`, backgroundColor: healthColor }"></div>
          </div>
          <span class="progress-text">{{ progress }}%</span>
        </div>
        
        <svg class="size-4 expand-icon" :class="{ 'rotate-180': expanded }" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M19 9l-7 7-7-7"/></svg>
      </div>
    </div>

    <Transition name="expand">
      <div class="shc-content" v-show="expanded">
        <div class="shc-grid">
          <div class="shc-issues" v-if="issues.length">
            <h4><svg class="size-4 mr-1 text-error" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"/></svg> Problems Found</h4>
            <ul>
              <li v-for="(issue, i) in issues" :key="i">
                <div class="bullet error-bullet"></div>
                <span>{{ issue }}</span>
              </li>
            </ul>
          </div>

          <div class="shc-stats" v-if="!isMobile && stats && Object.keys(stats).length > 0">
            <h4 style="margin-bottom: 0.5rem; color: rgb(var(--color-text-primary)); font-weight: 600;">Current Status</h4>
            <div style="font-size: 0.875rem; color: rgb(var(--color-text-secondary)); margin-bottom: 0.25rem;">
              <strong>Current:</strong> {{ stats.current }}
            </div>
            <div v-if="stats.quality != null" style="font-size: 0.875rem; color: rgb(var(--color-text-secondary)); margin-bottom: 0.25rem;">
              <strong>Quality Score:</strong> {{ stats.quality }}
            </div>
            <div v-if="stats.target" style="font-size: 0.875rem; color: rgb(var(--color-text-secondary)); margin-bottom: 0.25rem; white-space: pre-line;">
              <strong>Target:</strong> {{ stats.target }}
            </div>
            <div v-if="stats.recommended && !stats.quality" style="font-size: 0.875rem; color: rgb(var(--color-text-secondary)); margin-bottom: 0.25rem;">
              <strong>Recommended:</strong> {{ stats.recommended }}
            </div>
            <div v-if="stats.missing && !stats.quality" style="font-size: 0.875rem; color: rgb(var(--color-text-secondary)); margin-bottom: 0.25rem;">
              <strong>Missing:</strong> {{ stats.missing }}
            </div>
          </div>
          
          <div class="shc-suggestions" v-if="suggestions.length">
            <h4><svg class="size-4 mr-1 text-success" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M13 10V3L4 14h7v7l9-11h-7z"/></svg> Suggestions</h4>
            <ul>
              <li v-for="(sug, i) in suggestions" :key="i">
                <div class="bullet success-bullet"></div>
                <span>{{ sug }}</span>
              </li>
            </ul>
          </div>
        </div>
        
        <div class="ai-recommendation" v-if="aiRecommendation && !validationOnly">
          <div class="rec-header">⭐ AI Recommendation</div>
          <p>{{ aiRecommendation }}</p>
        </div>

        <div class="shc-footer" v-if="!validationOnly || isOptimized">
          <div class="gain-meta" v-if="!validationOnly && isOptimized && issues.length === 0" style="color: rgb(var(--color-success));">
            <svg class="size-4 mr-1" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" style="display: inline;"><path d="M20 6L9 17l-5-5"/></svg>
            {{ validationOnly ? (title === 'Education' ? 'Education section complete' : 'Meets professional standards') : 'Meets professional standards' }}
          </div>
          <div class="gain-meta" v-else-if="!validationOnly && estimatedGain">
            Potential Gain: <span class="gain-value">+{{ estimatedGain }} pts</span>
          </div>
          <div class="flex-spacer" v-if="!validationOnly"></div>
          
          <div class="actions-group" v-if="!validationOnly">
            <button class="btn-ai" @click="$emit('improve')">
              <svg class="size-4 mr-2" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M13 10V3L4 14h7v7l9-11h-7z"/></svg>
              {{ buttonText }}
            </button>
            <button v-if="isMobile" class="btn-view-details" @click="expanded = false">
              Collapse
            </button>
          </div>
        </div>
      </div>
    </Transition>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, onBeforeUnmount } from 'vue'

const props = defineProps({
  title: { type: String, required: true },
  progress: { type: Number, default: 0 },
  issues: { type: Array, default: () => [] },
  suggestions: { type: Array, default: () => [] },
  aiRecommendation: { type: String, default: '' },
  estimatedGain: { type: Number, default: 0 },
  stats: { type: Object, default: () => ({}) },
  isOptimized: { type: Boolean, default: false },
  buttonText: { type: String, default: 'Improve with AI' },
  validationOnly: { type: Boolean, default: false }
})

defineEmits(['improve'])

const expanded = ref(false)
const isMobile = ref(false)
let mediaQuery = null

const listener = (e) => {
  isMobile.value = e.matches
}

onMounted(() => {
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

const healthClass = computed(() => {
  if (props.progress >= 80) return 'health-good'
  if (props.progress >= 50) return 'health-fair'
  return 'health-poor'
})

const healthLabel = computed(() => {
  if (props.progress >= 80) return 'Excellent'
  if (props.progress >= 50) return 'Needs Work'
  return 'Critical'
})

const healthColor = computed(() => {
  if (props.progress >= 80) return '#10b981'
  if (props.progress >= 50) return '#f59e0b'
  return '#ef4444'
})
</script>

<style scoped>
.section-health-card {
  background: rgb(var(--color-surface));
  border: 1px solid rgb(var(--color-border));
  border-left: 4px solid transparent;
  border-radius: 1rem;
  transition: all 0.25s cubic-bezier(0.4, 0, 0.2, 1);
  display: flex;
  flex-direction: column;
  overflow: hidden;
}
.section-health-card:hover {
  border-color: rgb(var(--color-border-hover));
  box-shadow: 0 8px 30px rgba(0, 0, 0, 0.04);
}

/* Expanded Accent Left Strip */
.section-health-card.expanded.health-good {
  border-left: 4px solid #10b981;
  border-color: rgba(16, 185, 129, 0.25);
  box-shadow: 0 8px 30px rgba(16, 185, 129, 0.04);
}
.section-health-card.expanded.health-fair {
  border-left: 4px solid #f59e0b;
  border-color: rgba(245, 158, 11, 0.25);
  box-shadow: 0 8px 30px rgba(245, 158, 11, 0.04);
}
.section-health-card.expanded.health-poor {
  border-left: 4px solid #ef4444;
  border-color: rgba(239, 68, 68, 0.25);
  box-shadow: 0 8px 30px rgba(239, 68, 68, 0.04);
}

.shc-header {
  padding: 1.25rem 1.5rem;
  display: flex;
  justify-content: space-between;
  align-items: center;
  cursor: pointer;
  user-select: none;
}

.shc-title-group {
  display: flex;
  align-items: center;
  gap: 0.75rem;
}

.shc-title {
  margin: 0;
  font-size: 1.05rem;
  font-weight: 750;
  color: rgb(var(--color-text-primary));
}

.health-badge {
  font-size: 0.65rem;
  font-weight: 700;
  padding: 0.2rem 0.6rem;
  border-radius: 6px;
  text-transform: uppercase;
  letter-spacing: 0.05em;
}
.health-good { background: rgba(16, 185, 129, 0.06); border: 1px solid rgba(16, 185, 129, 0.15); color: #10b981; }
.health-fair { background: rgba(245, 158, 11, 0.06); border: 1px solid rgba(245, 158, 11, 0.15); color: #d97706; }
.health-poor { background: rgba(239, 68, 68, 0.06); border: 1px solid rgba(239, 68, 68, 0.15); color: #ef4444; }

.header-right {
  display: flex;
  align-items: center;
  gap: 1.25rem;
}

.progress-container {
  display: flex;
  align-items: center;
  gap: 0.75rem;
}

.progress-bar {
  width: 80px;
  height: 6px;
  background: rgb(var(--color-border));
  border-radius: 9999px;
  overflow: hidden;
}

.progress-fill {
  height: 100%;
  border-radius: 9999px;
  transition: width 0.4s ease;
}

.progress-text {
  font-size: 0.875rem;
  font-weight: 700;
  color: rgb(var(--color-text-secondary));
  min-width: 2.25rem;
  text-align: right;
}

.expand-icon {
  color: rgb(var(--color-text-muted));
  transition: transform 0.3s cubic-bezier(0.4, 0, 0.2, 1);
}

.shc-content {
  border-top: 1px solid rgb(var(--color-border));
  background: rgb(var(--color-surface));
  padding: 1.5rem;
}

.shc-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(240px, 1fr));
  gap: 1.5rem;
  margin-bottom: 1.25rem;
}

.shc-issues h4, .shc-suggestions h4 {
  margin: 0 0 0.75rem 0;
  font-size: 0.875rem;
  font-weight: 700;
  display: flex;
  align-items: center;
  color: rgb(var(--color-text-primary));
}

.shc-issues ul, .shc-suggestions ul {
  list-style: none;
  padding: 0;
  margin: 0;
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
}

.shc-issues li, .shc-suggestions li {
  display: flex;
  align-items: flex-start;
  gap: 0.5rem;
  font-size: 0.875rem;
  color: rgb(var(--color-text-secondary));
  line-height: 1.4;
}

.bullet {
  width: 6px;
  height: 6px;
  border-radius: 50%;
  margin-top: 0.4rem;
  flex-shrink: 0;
}
.error-bullet { background: #ef4444; }
.success-bullet { background: #10b981; }

.ai-recommendation {
  background: linear-gradient(135deg, rgba(var(--color-primary), 0.03) 0%, rgba(139, 92, 246, 0.05) 100%);
  border: 1px solid rgba(var(--color-primary), 0.15);
  border-radius: 0.75rem;
  padding: 1.125rem;
  margin-bottom: 1.25rem;
}

.rec-header {
  font-size: 0.725rem;
  font-weight: 700;
  text-transform: uppercase;
  letter-spacing: 0.06em;
  color: rgb(var(--color-primary));
  margin-bottom: 0.375rem;
}

.ai-recommendation p {
  margin: 0;
  font-size: 0.875rem;
  color: rgb(var(--color-text-secondary));
  line-height: 1.5;
}

.shc-footer {
  display: flex;
  justify-content: space-between;
  align-items: center;
  border-top: 1px solid rgb(var(--color-border));
  padding-top: 1.25rem;
}

.flex-spacer { flex: 1; }

.gain-meta {
  font-size: 0.875rem;
  color: rgb(var(--color-text-muted));
  font-weight: 600;
}
.gain-value {
  color: #10b981;
  font-weight: 750;
}

.btn-ai {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  background: linear-gradient(135deg, rgb(var(--color-primary)) 0%, #8b5cf6 100%);
  color: white;
  border: none;
  padding: 0.55rem 1.5rem;
  border-radius: 0.75rem;
  font-weight: 700;
  font-size: 0.875rem;
  cursor: pointer;
  transition: all 0.2s cubic-bezier(0.4, 0, 0.2, 1);
  box-shadow: 0 4px 12px rgba(99, 102, 241, 0.2);
}
.btn-ai:hover:not(:disabled) { 
  transform: translateY(-2px);
  box-shadow: 0 6px 18px rgba(99, 102, 241, 0.35); 
}
.btn-ai:active:not(:disabled) {
  transform: scale(0.98);
}

.actions-group {
  display: flex;
  align-items: center;
  gap: 0.75rem;
}

.btn-view-details {
  background: rgb(var(--color-surface-hover));
  border: 1px solid rgb(var(--color-border));
  color: rgb(var(--color-text-secondary));
  padding: 0.55rem 1.25rem;
  border-radius: 0.75rem;
  font-weight: 700;
  font-size: 0.875rem;
  cursor: pointer;
  transition: all 0.2s;
}
.btn-view-details:hover {
  background: rgb(var(--color-border));
  color: rgb(var(--color-text-primary));
}
.btn-view-details:active {
  transform: scale(0.98);
}

.text-error { color: #ef4444; }
.text-success { color: #10b981; }
.size-4 { width: 1rem; height: 1rem; }
.mr-1 { margin-right: 0.25rem; }
.mr-2 { margin-right: 0.5rem; }

/* Transitions */
.expand-enter-active,
.expand-leave-active {
  transition: max-height 0.3s cubic-bezier(0.4, 0, 0.2, 1), opacity 0.3s ease, padding 0.3s ease;
  max-height: 1000px;
  overflow: hidden;
}
.expand-enter-from,
.expand-leave-to {
  max-height: 0;
  opacity: 0;
  padding-top: 0 !important;
  padding-bottom: 0 !important;
  border-top-color: transparent !important;
}

@media (max-width: 768px) {
  .shc-header {
    flex-direction: row;
    align-items: center;
    justify-content: space-between;
    padding: 1rem 1.15rem;
    gap: 0.5rem;
  }
  .shc-title-group {
    flex-direction: column;
    align-items: flex-start;
    gap: 0.25rem;
  }
  .shc-title {
    font-size: 0.9375rem;
  }
  .header-right {
    width: auto;
    gap: 0.5rem;
  }
  .progress-container {
    width: auto;
  }
  .shc-content {
    padding: 1rem 1.15rem;
  }
  .shc-grid {
    grid-template-columns: 1fr;
    gap: 1rem;
    margin-bottom: 1rem;
  }
  .shc-footer {
    flex-direction: column;
    align-items: stretch;
    gap: 1rem;
  }
  .actions-group {
    flex-direction: column;
    width: 100%;
    gap: 0.5rem;
  }
  .btn-ai, .btn-view-details {
    width: 100%;
    justify-content: center;
    padding: 0.65rem;
    font-size: 0.85rem;
    height: 40px;
  }
  .gain-meta {
    text-align: center;
  }
}
</style>
