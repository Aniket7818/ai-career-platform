<template>
  <div class="section-health-card">
    <div class="shc-header">
      <div class="shc-title-group">
        <h3 class="shc-title">{{ title }}</h3>
        <div class="health-badge" :class="healthClass">{{ healthLabel }}</div>
      </div>
      <div class="progress-container">
        <div class="progress-bar">
          <div class="progress-fill" :style="{ width: `${progress}%`, backgroundColor: healthColor }"></div>
        </div>
        <span class="progress-text">{{ progress }}%</span>
      </div>
    </div>

    <div class="shc-content" v-show="expanded">
      <div class="shc-grid">
        <div class="shc-issues" v-if="issues.length">
          <h4>Issues to Fix</h4>
          <ul>
            <li v-for="(issue, i) in issues" :key="i">
              <svg class="size-4 text-error" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"/></svg>
              <span>{{ issue }}</span>
            </li>
          </ul>
        </div>
        
        <div class="shc-suggestions" v-if="suggestions.length">
          <h4>AI Suggestions</h4>
          <ul>
            <li v-for="(sug, i) in suggestions" :key="i">
              <svg class="size-4 text-success" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M20 6L9 17l-5-5"/></svg>
              <span>{{ sug }}</span>
            </li>
          </ul>
        </div>
      </div>
    </div>

    <div class="shc-footer">
      <button class="btn-expand" @click="expanded = !expanded">
        {{ expanded ? 'Hide Details' : 'View Details' }}
        <svg class="size-4" :class="{ 'rotate-180': expanded }" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M19 9l-7 7-7-7"/></svg>
      </button>
      <button class="btn-ai" @click="$emit('improve')">
        <svg class="size-4 mr-2" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M13 10V3L4 14h7v7l9-11h-7z"/></svg>
        AI Improve
      </button>
    </div>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'

const props = defineProps({
  title: { type: String, required: true },
  progress: { type: Number, default: 0 },
  issues: { type: Array, default: () => [] },
  suggestions: { type: Array, default: () => [] }
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
  padding: 1.5rem;
  transition: all 0.3s;
  display: flex;
  flex-direction: column;
}
.section-health-card:hover {
  border-color: var(--color-border-hover);
  box-shadow: 0 4px 12px rgba(0,0,0,0.05);
}

.shc-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  flex-wrap: wrap;
  gap: 1rem;
}

.shc-title-group {
  display: flex;
  align-items: center;
  gap: 1rem;
}

.shc-title {
  margin: 0;
  font-size: 1.25rem;
  font-weight: 600;
  color: var(--color-text-primary);
}

.health-badge {
  font-size: 0.75rem;
  font-weight: 700;
  padding: 0.25rem 0.75rem;
  border-radius: 1rem;
}
.health-good { background: rgba(16, 185, 129, 0.1); color: #10b981; }
.health-fair { background: rgba(245, 158, 11, 0.1); color: #f59e0b; }
.health-poor { background: rgba(239, 68, 68, 0.1); color: #ef4444; }

.progress-container {
  display: flex;
  align-items: center;
  gap: 1rem;
  min-width: 200px;
}

.progress-bar {
  flex: 1;
  height: 8px;
  background: var(--color-surface-3);
  border-radius: 4px;
  overflow: hidden;
}

.progress-fill {
  height: 100%;
  border-radius: 4px;
  transition: width 1s cubic-bezier(0.4, 0, 0.2, 1);
}

.progress-text {
  font-size: 0.875rem;
  font-weight: 600;
  color: var(--color-text-secondary);
  min-width: 3rem;
  text-align: right;
}

.shc-content {
  margin-top: 1.5rem;
  padding-top: 1.5rem;
  border-top: 1px dashed var(--color-border);
  animation: fadeIn 0.3s ease;
}

@keyframes fadeIn {
  from { opacity: 0; transform: translateY(-10px); }
  to { opacity: 1; transform: translateY(0); }
}

.shc-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: 1.5rem;
}

.shc-grid h4 {
  margin: 0 0 1rem 0;
  font-size: 0.875rem;
  color: var(--color-text-muted);
  text-transform: uppercase;
  letter-spacing: 0.05em;
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
  gap: 0.5rem;
  font-size: 0.875rem;
  line-height: 1.4;
  color: var(--color-text-secondary);
}

.text-error { color: #ef4444; flex-shrink: 0; margin-top: 0.125rem; }
.text-success { color: #10b981; flex-shrink: 0; margin-top: 0.125rem; }

.shc-footer {
  margin-top: 1.5rem;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.btn-expand {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  background: transparent;
  border: none;
  color: var(--color-text-muted);
  font-size: 0.875rem;
  font-weight: 500;
  cursor: pointer;
  padding: 0;
}
.btn-expand:hover { color: var(--color-text-primary); }

.rotate-180 { transform: rotate(180deg); transition: transform 0.3s; }
.size-4 { width: 1rem; height: 1rem; }
.mr-2 { margin-right: 0.5rem; }

.btn-ai {
  display: inline-flex;
  align-items: center;
  background: linear-gradient(135deg, var(--color-primary), #8b5cf6);
  color: white;
  border: none;
  padding: 0.5rem 1.25rem;
  border-radius: 0.5rem;
  font-weight: 600;
  font-size: 0.875rem;
  cursor: pointer;
  transition: all 0.2s;
}
.btn-ai:hover { opacity: 0.9; transform: translateY(-1px); box-shadow: 0 4px 12px rgba(99, 102, 241, 0.3); }

@media (max-width: 640px) {
  .shc-header { flex-direction: column; align-items: flex-start; }
  .progress-container { width: 100%; }
}
</style>
