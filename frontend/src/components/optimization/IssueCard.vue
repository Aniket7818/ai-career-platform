<template>
  <div class="issue-card" :class="priorityClass">
    <div class="issue-header">
      <div class="priority-badge">{{ priority }} PRIORITY</div>
      <div class="issue-meta">
        <span class="gain" v-if="gain">+{{ gain }} pts</span>
        <span class="time" v-if="time">⏱ {{ time }}</span>
      </div>
    </div>
    
    <h3 class="issue-title">{{ title }}</h3>
    
    <div class="issue-body">
      <p class="issue-desc">{{ description }}</p>
      
      <div class="educational-block" v-if="whyItMatters">
        <div class="edu-header">
          <svg class="size-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"/></svg>
          <span>Why this matters</span>
        </div>
        <p>{{ whyItMatters }}</p>
      </div>
    </div>
    
    <div class="issue-actions">
      <button class="btn-primary" @click="$emit('fix')">
        <svg class="size-4 mr-2" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M13 10V3L4 14h7v7l9-11h-7z"/></svg>
        {{ primaryActionLabel }}
      </button>
      <button class="btn-secondary" @click="$emit('dismiss')">Not Now</button>
    </div>
  </div>
</template>

<script setup>
import { computed } from 'vue'

const props = defineProps({
  title: { type: String, required: true },
  description: { type: String, required: true },
  whyItMatters: { type: String, default: '' },
  priority: { type: String, default: 'HIGH' }, // HIGH, MED, LOW, QUICK
  gain: { type: Number, default: 0 },
  time: { type: String, default: '' },
  primaryActionLabel: { type: String, default: 'Fix Issue' }
})

defineEmits(['fix', 'dismiss'])

const priorityClass = computed(() => {
  return `priority-${props.priority.toLowerCase()}`
})
</script>

<style scoped>
.issue-card {
  background: var(--color-surface);
  border: 1px solid var(--color-border);
  border-left: 4px solid var(--color-border);
  border-radius: 1rem;
  padding: 1.5rem;
  transition: all 0.2s cubic-bezier(0.4, 0, 0.2, 1);
  display: flex;
  flex-direction: column;
}

.issue-card:hover {
  transform: translateX(4px);
  box-shadow: 0 8px 16px rgba(0,0,0,0.05);
}

.priority-high { border-left-color: #ef4444; }
.priority-med { border-left-color: #f59e0b; }
.priority-low { border-left-color: #3b82f6; }
.priority-quick { border-left-color: #10b981; }

.issue-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 1rem;
}

.priority-badge {
  font-size: 0.7rem;
  font-weight: 800;
  padding: 0.25rem 0.5rem;
  border-radius: 0.25rem;
  letter-spacing: 0.1em;
  text-transform: uppercase;
}

.priority-high .priority-badge { background: rgba(239, 68, 68, 0.1); color: #ef4444; }
.priority-med .priority-badge { background: rgba(245, 158, 11, 0.1); color: #f59e0b; }
.priority-low .priority-badge { background: rgba(59, 130, 246, 0.1); color: #3b82f6; }
.priority-quick .priority-badge { background: rgba(16, 185, 129, 0.1); color: #10b981; }

.issue-meta {
  display: flex;
  gap: 0.75rem;
  font-size: 0.875rem;
  font-weight: 600;
}

.gain { color: #10b981; }
.time { color: var(--color-text-muted); }

.issue-title {
  margin: 0 0 0.75rem 0;
  font-size: 1.25rem;
  font-weight: 700;
  color: var(--color-text-primary);
}

.issue-body {
  flex: 1;
  margin-bottom: 1.5rem;
}

.issue-desc {
  font-size: 0.875rem;
  color: var(--color-text-secondary);
  margin: 0 0 1rem 0;
  line-height: 1.6;
}

.educational-block {
  background: var(--color-surface-2);
  border-radius: 0.75rem;
  padding: 1rem;
  border: 1px solid var(--color-border);
}

.edu-header {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  color: var(--color-text-primary);
  font-weight: 600;
  font-size: 0.875rem;
  margin-bottom: 0.5rem;
}
.edu-header svg { color: var(--color-primary); }

.educational-block p {
  margin: 0;
  font-size: 0.875rem;
  color: var(--color-text-secondary);
  line-height: 1.5;
}

.issue-actions {
  display: flex;
  gap: 0.75rem;
}

.btn-primary, .btn-secondary {
  padding: 0.75rem 1rem;
  border-radius: 0.75rem;
  font-size: 0.875rem;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.2s;
  display: flex;
  align-items: center;
  justify-content: center;
}

.btn-primary {
  background: var(--color-primary);
  color: white;
  border: none;
  flex: 1;
}
.btn-primary:hover { 
  opacity: 0.9;
  transform: translateY(-1px);
  box-shadow: 0 4px 12px rgba(99, 102, 241, 0.25);
}

.btn-secondary {
  background: transparent;
  color: var(--color-text-secondary);
  border: 1px solid var(--color-border);
}
.btn-secondary:hover { 
  background: var(--color-surface-2); 
  color: var(--color-text-primary); 
}

.size-4 { width: 1rem; height: 1rem; }
.mr-2 { margin-right: 0.5rem; }
</style>
