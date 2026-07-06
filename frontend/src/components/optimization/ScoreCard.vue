<template>
  <div class="score-card" :class="scoreClass">
    <div class="card-header">
      <div class="card-title">{{ title }}</div>
      <div class="card-score">{{ score }}</div>
    </div>
    
    <p class="card-description">{{ description }}</p>

    <div class="card-details">
      <div v-if="strength" class="detail-row strength">
        <svg class="size-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M20 6L9 17l-5-5"/></svg>
        <span>{{ strength }}</span>
      </div>
      <div v-if="weakness" class="detail-row weakness">
        <svg class="size-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"/></svg>
        <span>{{ weakness }}</span>
      </div>
    </div>

    <div class="card-footer">
      <div class="potential-gain" v-if="estimatedGain > 0">
        Estimated Gain: <span class="gain-value">+{{ estimatedGain }}</span>
      </div>
      <button class="btn-text" @click="$emit('view')">View Details &rarr;</button>
    </div>
  </div>
</template>

<script setup>
import { computed } from 'vue'

const props = defineProps({
  title: { type: String, required: true },
  score: { type: Number, required: true },
  description: { type: String, default: '' },
  strength: { type: String, default: '' },
  weakness: { type: String, default: '' },
  estimatedGain: { type: Number, default: 0 }
})

defineEmits(['view'])

const scoreClass = computed(() => {
  if (props.score >= 80) return 'score-high'
  if (props.score >= 60) return 'score-med'
  return 'score-low'
})
</script>

<style scoped>
.score-card {
  background: var(--color-surface);
  border: 1px solid var(--color-border);
  border-radius: 1rem;
  padding: 1.5rem;
  transition: all 0.3s ease;
  display: flex;
  flex-direction: column;
  position: relative;
  overflow: hidden;
}

.score-card::before {
  content: '';
  position: absolute;
  top: 0; left: 0; right: 0; height: 3px;
}
.score-card.score-high::before { background: #10b981; }
.score-card.score-med::before { background: #f59e0b; }
.score-card.score-low::before { background: #ef4444; }

.score-card:hover {
  transform: translateY(-4px);
  box-shadow: 0 12px 24px -8px rgba(0,0,0,0.15);
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 0.75rem;
}

.card-title {
  font-weight: 700;
  font-size: 1.125rem;
  color: var(--color-text-primary);
}

.card-score {
  font-size: 1.75rem;
  font-weight: 800;
}
.score-high .card-score { color: #10b981; }
.score-med .card-score { color: #f59e0b; }
.score-low .card-score { color: #ef4444; }

.card-description {
  font-size: 0.875rem;
  color: var(--color-text-muted);
  margin: 0 0 1.25rem 0;
  line-height: 1.4;
  flex: 1;
}

.card-details {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
  margin-bottom: 1.5rem;
}

.detail-row {
  display: flex;
  align-items: flex-start;
  gap: 0.5rem;
  font-size: 0.875rem;
  line-height: 1.4;
}

.detail-row.strength { color: #10b981; }
.detail-row.weakness { color: #ef4444; }
.detail-row span { color: var(--color-text-secondary); }

.card-footer {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-top: auto;
  padding-top: 1rem;
  border-top: 1px solid var(--color-border);
}

.potential-gain {
  font-size: 0.75rem;
  color: var(--color-text-muted);
  font-weight: 500;
}
.gain-value {
  color: #10b981;
  font-weight: 700;
  font-size: 0.875rem;
}

.btn-text {
  background: none;
  border: none;
  color: var(--color-primary);
  font-weight: 600;
  font-size: 0.875rem;
  padding: 0;
  cursor: pointer;
  transition: opacity 0.2s;
}
.btn-text:hover { opacity: 0.8; text-decoration: underline; }

.size-4 { width: 1rem; height: 1rem; flex-shrink: 0; margin-top: 0.125rem; }
</style>
