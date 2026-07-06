<template>
  <div class="score-card" :class="scoreClass">
    <div class="card-header" @click="expanded = !expanded">
      <div class="header-main">
        <div class="card-title">{{ title }}</div>
        <div class="card-score">{{ score }}</div>
      </div>
      <p class="card-description">{{ description }}</p>
      <div class="expand-indicator">
        <span class="expand-text">{{ expanded ? 'Hide details' : 'View analysis' }}</span>
        <svg class="size-4 transition-transform" :class="{ 'rotate-180': expanded }" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M19 9l-7 7-7-7"/></svg>
      </div>
    </div>
    
    <div class="card-content" v-show="expanded">
      <div class="details-grid">
        <div class="detail-box strength-box" v-if="strength">
          <div class="detail-header">
            <svg class="size-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M20 6L9 17l-5-5"/></svg>
            <span>Strength</span>
          </div>
          <p>{{ strength }}</p>
        </div>
        
        <div class="detail-box weakness-box" v-if="weakness">
          <div class="detail-header">
            <svg class="size-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"/></svg>
            <span>Weakness</span>
          </div>
          <p>{{ weakness }}</p>
        </div>
      </div>

      <div class="recommendation-box" v-if="recommendation">
        <div class="rec-header">
          <svg class="size-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M13 10V3L4 14h7v7l9-11h-7z"/></svg>
          <span>AI Recommendation</span>
        </div>
        <p>{{ recommendation }}</p>
      </div>

      <div class="card-footer" v-if="estimatedGain > 0">
        <div class="potential-gain">
          Estimated Score Gain: <span class="gain-value">+{{ estimatedGain }} pts</span>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'

const props = defineProps({
  title: { type: String, required: true },
  score: { type: Number, required: true },
  description: { type: String, default: '' },
  strength: { type: String, default: '' },
  weakness: { type: String, default: '' },
  recommendation: { type: String, default: '' },
  estimatedGain: { type: Number, default: 0 }
})

const expanded = ref(false)

const scoreClass = computed(() => {
  if (props.score >= 80) return 'score-high'
  if (props.score >= 60) return 'score-med'
  return 'score-low'
})
</script>

<style scoped>
.score-card {
  background: rgb(var(--color-surface));
  border: 1px solid rgb(var(--color-border));
  border-radius: 1.25rem;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  display: flex;
  flex-direction: column;
  position: relative;
  overflow: hidden;
}

.score-card::before {
  content: '';
  position: absolute;
  top: 0; left: 0; right: 0; height: 4px;
  transition: background-color 0.3s;
}
.score-card.score-high::before { background: #10b981; }
.score-card.score-med::before { background: #f59e0b; }
.score-card.score-low::before { background: #ef4444; }

.score-card:hover {
  transform: translateY(-4px);
  box-shadow: 0 12px 24px -8px rgba(0,0,0,0.15);
  border-color: rgb(var(--color-border-hover));
}

.card-header {
  padding: 1.5rem;
  cursor: pointer;
  user-select: none;
}

.header-main {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 0.5rem;
}

.card-title {
  font-weight: 700;
  font-size: 1.25rem;
  color: rgb(var(--color-text-primary));
}

.card-score {
  font-size: 2rem;
  font-weight: 800;
  line-height: 1;
}
.score-high .card-score { color: #10b981; }
.score-med .card-score { color: #f59e0b; }
.score-low .card-score { color: #ef4444; }

.card-description {
  font-size: 0.875rem;
  color: rgb(var(--color-text-secondary));
  margin: 0 0 1rem 0;
  line-height: 1.5;
}

.expand-indicator {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  color: rgb(var(--color-primary));
  font-size: 0.875rem;
  font-weight: 600;
}

.card-content {
  padding: 0 1.5rem 1.5rem 1.5rem;
  border-top: 1px solid rgb(var(--color-border));
  padding-top: 1.5rem;
  animation: slideDown 0.3s ease-out;
}

.details-grid {
  display: flex;
  flex-direction: column;
  gap: 1rem;
  margin-bottom: 1rem;
}

.detail-box {
  padding: 1rem;
  border-radius: 0.75rem;
  font-size: 0.875rem;
  line-height: 1.5;
}

.detail-header {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  font-weight: 600;
  margin-bottom: 0.5rem;
}

.strength-box {
  background: rgba(16, 185, 129, 0.05);
  border: 1px solid rgba(16, 185, 129, 0.2);
}
.strength-box .detail-header { color: #10b981; }
.strength-box p { margin: 0; color: rgb(var(--color-text-primary)); }

.weakness-box {
  background: rgba(239, 68, 68, 0.05);
  border: 1px solid rgba(239, 68, 68, 0.2);
}
.weakness-box .detail-header { color: #ef4444; }
.weakness-box p { margin: 0; color: rgb(var(--color-text-primary)); }

.recommendation-box {
  background: linear-gradient(135deg, rgba(99, 102, 241, 0.05), rgba(139, 92, 246, 0.05));
  border: 1px solid rgba(99, 102, 241, 0.2);
  padding: 1rem;
  border-radius: 0.75rem;
  margin-bottom: 1rem;
}

.rec-header {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  color: rgb(var(--color-primary));
  font-weight: 600;
  font-size: 0.875rem;
  margin-bottom: 0.5rem;
}

.recommendation-box p {
  margin: 0;
  font-size: 0.875rem;
  color: rgb(var(--color-text-primary));
  line-height: 1.5;
}

.card-footer {
  display: flex;
  align-items: center;
  justify-content: flex-end;
  padding-top: 1rem;
  border-top: 1px dashed rgb(var(--color-border));
}

.potential-gain {
  font-size: 0.875rem;
  color: rgb(var(--color-text-secondary));
  font-weight: 500;
}
.gain-value {
  color: #10b981;
  font-weight: 700;
}

.size-4 { width: 1rem; height: 1rem; }
.transition-transform { transition: transform 0.3s; }
.rotate-180 { transform: rotate(180deg); }

@keyframes slideDown {
  from { opacity: 0; transform: translateY(-10px); }
  to { opacity: 1; transform: translateY(0); }
}
</style>
