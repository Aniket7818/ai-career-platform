<template>
  <div class="section-health-card">
    <div class="shc-header" @click="expanded = !expanded">
      <div class="shc-title-group">
        <h3 class="shc-title">{{ title }}</h3>
        <div class="health-badge" :class="healthClass">{{ healthLabel }}</div>
      </div>
      
      <div class="header-right">
        <div class="progress-container">
          <div class="progress-bar">
            <div class="progress-fill" :style="{ width: `${progress}%`, backgroundColor: healthColor }"></div>
          </div>
          <span class="progress-text">{{ progress }}%</span>
        </div>
        
        <svg class="size-4 expand-icon" :class="{ 'rotate-180': expanded }" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M19 9l-7 7-7-7"/></svg>
      </div>
    </div>

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
      
      <div class="ai-recommendation" v-if="aiRecommendation">
        <div class="rec-header">⭐ AI Recommendation</div>
        <p>{{ aiRecommendation }}</p>
      </div>

      <div class="shc-footer">
        <div class="gain-meta" v-if="estimatedGain">
          Potential Gain: <span class="gain-value">+{{ estimatedGain }} pts</span>
        </div>
        <div class="flex-spacer"></div>
        <button class="btn-ai" @click="$emit('improve')">
          <svg class="size-4 mr-2" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M13 10V3L4 14h7v7l9-11h-7z"/></svg>
          Improve with AI
        </button>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'

const props = defineProps({
  title: { type: String, required: true },
  progress: { type: Number, default: 0 },
  issues: { type: Array, default: () => [] },
  suggestions: { type: Array, default: () => [] },
  aiRecommendation: { type: String, default: '' },
  estimatedGain: { type: Number, default: 0 }
})

defineEmits(['improve'])

const expanded = ref(false)

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
  background: var(--color-surface);
  border: 1px solid var(--color-border);
  border-radius: 1rem;
  transition: all 0.3s;
  display: flex;
  flex-direction: column;
  overflow: hidden;
}
.section-health-card:hover {
  border-color: var(--color-border-hover);
  box-shadow: 0 4px 15px rgba(0,0,0,0.05);
}

.shc-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 1.25rem 1.5rem;
  cursor: pointer;
  user-select: none;
  background: var(--color-surface);
  transition: background 0.2s;
}
.shc-header:hover {
  background: var(--color-surface-2);
}

.shc-title-group {
  display: flex;
  align-items: center;
  gap: 1rem;
}

.shc-title {
  margin: 0;
  font-size: 1.125rem;
  font-weight: 600;
  color: var(--color-text-primary);
}

.health-badge {
  font-size: 0.7rem;
  font-weight: 700;
  padding: 0.25rem 0.75rem;
  border-radius: 1rem;
  text-transform: uppercase;
  letter-spacing: 0.05em;
}
.health-good { background: rgba(16, 185, 129, 0.1); color: #10b981; }
.health-fair { background: rgba(245, 158, 11, 0.1); color: #f59e0b; }
.health-poor { background: rgba(239, 68, 68, 0.1); color: #ef4444; }

.header-right {
  display: flex;
  align-items: center;
  gap: 1rem;
}

.progress-container {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  min-width: 150px;
}

.progress-bar {
  flex: 1;
  height: 6px;
  background: var(--color-surface-3);
  border-radius: 3px;
  overflow: hidden;
}

.progress-fill {
  height: 100%;
  border-radius: 3px;
  transition: width 1s cubic-bezier(0.4, 0, 0.2, 1);
}

.progress-text {
  font-size: 0.875rem;
  font-weight: 700;
  color: var(--color-text-secondary);
  min-width: 2.5rem;
  text-align: right;
}

.expand-icon {
  color: var(--color-text-muted);
  transition: transform 0.3s;
}

.rotate-180 { transform: rotate(180deg); }

.shc-content {
  padding: 0 1.5rem 1.5rem 1.5rem;
  border-top: 1px dashed var(--color-border);
  animation: slideDown 0.3s ease-out;
  margin-top: 0.5rem;
}

@keyframes slideDown {
  from { opacity: 0; transform: translateY(-10px); }
  to { opacity: 1; transform: translateY(0); }
}

.shc-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: 1.5rem;
  margin-top: 1rem;
}

.shc-grid h4 {
  margin: 0 0 1rem 0;
  font-size: 0.875rem;
  color: var(--color-text-primary);
  font-weight: 600;
  display: flex;
  align-items: center;
}

.shc-grid ul {
  list-style: none;
  padding: 0;
  margin: 0;
  display: flex;
  flex-direction: column;
  gap: 0.75rem;
}

.shc-grid li {
  display: flex;
  align-items: flex-start;
  gap: 0.75rem;
  font-size: 0.875rem;
  line-height: 1.5;
  color: var(--color-text-secondary);
}

.bullet {
  width: 6px; height: 6px;
  border-radius: 50%;
  margin-top: 0.4rem;
  flex-shrink: 0;
}
.error-bullet { background: #ef4444; }
.success-bullet { background: #10b981; }

.ai-recommendation {
  background: linear-gradient(135deg, rgba(99, 102, 241, 0.05), rgba(139, 92, 246, 0.05));
  border: 1px solid rgba(99, 102, 241, 0.2);
  padding: 1rem;
  border-radius: 0.75rem;
  margin-top: 1.5rem;
}
.rec-header {
  font-size: 0.875rem;
  font-weight: 700;
  color: var(--color-primary);
  margin-bottom: 0.5rem;
}
.ai-recommendation p {
  margin: 0;
  font-size: 0.875rem;
  color: var(--color-text-primary);
  line-height: 1.5;
}

.shc-footer {
  margin-top: 1.5rem;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.flex-spacer { flex: 1; }

.gain-meta {
  font-size: 0.875rem;
  color: var(--color-text-muted);
  font-weight: 500;
}
.gain-value {
  color: #10b981;
  font-weight: 700;
}

.btn-ai {
  display: inline-flex;
  align-items: center;
  background: var(--color-surface);
  color: var(--color-primary);
  border: 1px solid var(--color-primary);
  padding: 0.5rem 1.25rem;
  border-radius: 0.75rem;
  font-weight: 600;
  font-size: 0.875rem;
  cursor: pointer;
  transition: all 0.2s;
}
.btn-ai:hover { 
  background: var(--color-primary); 
  color: white;
  transform: translateY(-1px); 
  box-shadow: 0 4px 12px rgba(99, 102, 241, 0.3); 
}

.text-error { color: #ef4444; }
.text-success { color: #10b981; }
.size-4 { width: 1rem; height: 1rem; }
.mr-1 { margin-right: 0.25rem; }
.mr-2 { margin-right: 0.5rem; }

@media (max-width: 768px) {
  .shc-header { flex-direction: column; align-items: flex-start; gap: 1rem; }
  .header-right { width: 100%; justify-content: space-between; }
  .progress-container { flex: 1; }
}
</style>
