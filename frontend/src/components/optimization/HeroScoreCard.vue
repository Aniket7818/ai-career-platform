<template>
  <div class="hero-score-card">
    <div class="hero-content">
      <div class="score-showcase">
        <div class="score-circle-wrapper" :class="scoreClass">
          <svg viewBox="0 0 36 36" class="circular-chart">
            <defs>
              <linearGradient id="highGrad" x1="0%" y1="0%" x2="100%" y2="100%">
                <stop offset="0%" stop-color="#34d399" />
                <stop offset="100%" stop-color="#059669" />
              </linearGradient>
              <linearGradient id="medGrad" x1="0%" y1="0%" x2="100%" y2="100%">
                <stop offset="0%" stop-color="#fbbf24" />
                <stop offset="100%" stop-color="#d97706" />
              </linearGradient>
              <linearGradient id="lowGrad" x1="0%" y1="0%" x2="100%" y2="100%">
                <stop offset="0%" stop-color="#f87171" />
                <stop offset="100%" stop-color="#dc2626" />
              </linearGradient>
            </defs>
            <path class="circle-bg"
              d="M18 2.0845
                a 15.9155 15.9155 0 0 1 0 31.831
                a 15.9155 15.9155 0 0 1 0 -31.831"
            />
            <path class="circle"
              :stroke="gradientColor"
              :stroke-dasharray="`${score}, 100`"
              d="M18 2.0845
                a 15.9155 15.9155 0 0 1 0 31.831
                a 15.9155 15.9155 0 0 1 0 -31.831"
            />
          </svg>
          <div class="score-text">
            <span class="score-value">{{ score }}</span>
            <span class="score-label">Overall</span>
          </div>
        </div>
        
        <div class="status-group">
          <div class="grade-badge" :class="scoreClass">{{ grade }}</div>
          <h2 class="status-title" :class="scoreClass">{{ statusText }}</h2>
          <p class="status-desc">Last updated: {{ lastAnalyzed }}</p>
        </div>
      </div>

      <div class="stats-grid">
        <div class="stat-box">
          <span class="stat-label">ATS Success</span>
          <span class="stat-value">{{ atsSuccess }}%</span>
        </div>
        <div class="stat-box">
          <span class="stat-label">Completion</span>
          <span class="stat-value">{{ completion }}%</span>
        </div>
        <div class="stat-box">
          <span class="stat-label">Issues</span>
          <span class="stat-value error-text">{{ issues }} remaining</span>
        </div>
        <div class="stat-box highlight-box">
          <span class="stat-label">Potential Gain</span>
          <span class="stat-value success-text">+{{ potentialGain }} pts</span>
        </div>
      </div>

      <div class="hero-actions">
        <button class="btn-outline" @click="$emit('analyze')" :disabled="loading">
          <svg v-if="loading" class="spin size-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M21 12a9 9 0 11-6.219-8.56"/></svg>
          <svg v-else class="size-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15"/></svg>
          {{ loading ? 'Analyzing...' : 'Analyze Again' }}
        </button>
        <button class="btn-premium" @click="$emit('optimize')" :disabled="loading">
          ⭐ AI Optimize Resume
        </button>
      </div>
    </div>
  </div>
</template>

<script setup>
import { computed } from 'vue'

const props = defineProps({
  score: { type: Number, default: 0 },
  atsSuccess: { type: Number, default: 0 },
  completion: { type: Number, default: 0 },
  issues: { type: Number, default: 0 },
  potentialGain: { type: Number, default: 0 },
  lastAnalyzed: { type: String, default: '' },
  loading: { type: Boolean, default: false }
})

defineEmits(['analyze', 'optimize'])

const grade = computed(() => {
  if (props.score >= 95) return 'A+'
  if (props.score >= 90) return 'A'
  if (props.score >= 80) return 'B'
  if (props.score >= 70) return 'C'
  if (props.score >= 60) return 'D'
  return 'F'
})

const scoreClass = computed(() => {
  if (props.score >= 80) return 'score-high'
  if (props.score >= 60) return 'score-med'
  return 'score-low'
})

const statusText = computed(() => {
  if (props.score >= 90) return 'Excellent'
  if (props.score >= 80) return 'Interview Ready'
  if (props.score >= 60) return 'Needs Improvement'
  return 'Critical Issues'
})

const gradientColor = computed(() => {
  if (props.score >= 80) return 'url(#highGrad)'
  if (props.score >= 60) return 'url(#medGrad)'
  return 'url(#lowGrad)'
})
</script>

<style scoped>
.hero-score-card {
  background: rgb(var(--color-surface));
  border: 1px solid rgb(var(--color-border));
  border-radius: 1.5rem;
  padding: 2.5rem;
  box-shadow: 0 10px 40px -10px rgba(0, 0, 0, 0.08);
  position: relative;
  overflow: hidden;
  transition: all 0.3s ease;
}

.hero-score-card:hover {
  box-shadow: 0 15px 50px -10px rgba(0, 0, 0, 0.12);
}

.hero-content {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 2.5rem;
}

.score-showcase {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 1.5rem;
  text-align: center;
}

/* Circular chart */
.score-circle-wrapper {
  position: relative;
  width: 180px;
  height: 180px;
}
.circular-chart { display: block; width: 100%; height: 100%; filter: drop-shadow(0 4px 6px rgba(0,0,0,0.1)); }
.circle-bg { fill: none; stroke: rgb(var(--color-surface-hover)); stroke-width: 2.5; }
.circle { fill: none; stroke-width: 2.5; stroke-linecap: round; transition: stroke-dasharray 1.5s cubic-bezier(0.34, 1.56, 0.64, 1); }

.score-text {
  position: absolute;
  top: 0; left: 0; right: 0; bottom: 0;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
}

.score-value {
  font-size: 3rem;
  font-weight: 800;
  line-height: 1;
  color: rgb(var(--color-text-primary));
}

.score-label {
  font-size: 0.875rem;
  color: rgb(var(--color-text-muted));
  text-transform: uppercase;
  letter-spacing: 0.1em;
  margin-top: 0.25rem;
}

.status-group {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 0.5rem;
}

.grade-badge {
  display: inline-block;
  padding: 0.25rem 1.25rem;
  border-radius: 2rem;
  font-size: 1.25rem;
  font-weight: 800;
  letter-spacing: 0.05em;
}
.grade-badge.score-high { color: #10b981; background: rgba(16, 185, 129, 0.1); border: 1px solid rgba(16, 185, 129, 0.2); }
.grade-badge.score-med { color: #f59e0b; background: rgba(245, 158, 11, 0.1); border: 1px solid rgba(245, 158, 11, 0.2); }
.grade-badge.score-low { color: #ef4444; background: rgba(239, 68, 68, 0.1); border: 1px solid rgba(239, 68, 68, 0.2); }

.status-title {
  margin: 0;
  font-size: 1.5rem;
  font-weight: 700;
}
.status-title.score-high { color: #10b981; }
.status-title.score-med { color: #f59e0b; }
.status-title.score-low { color: #ef4444; }

.status-desc {
  margin: 0;
  font-size: 0.875rem;
  color: rgb(var(--color-text-muted));
}

.stats-grid {
  display: flex;
  gap: 1rem;
  width: 100%;
  justify-content: center;
  flex-wrap: wrap;
}

.stat-box {
  background: rgb(var(--color-surface-hover));
  border: 1px solid rgb(var(--color-border));
  padding: 1rem 1.5rem;
  border-radius: 1rem;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 0.25rem;
  min-width: 140px;
  transition: transform 0.2s;
}
.stat-box:hover {
  transform: translateY(-2px);
  border-color: rgb(var(--color-border-hover));
}

.highlight-box {
  background: linear-gradient(135deg, rgba(16, 185, 129, 0.05), rgba(16, 185, 129, 0.1));
  border-color: rgba(16, 185, 129, 0.2);
}

.stat-label {
  font-size: 0.75rem;
  color: rgb(var(--color-text-muted));
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 0.05em;
}

.stat-value {
  font-size: 1.25rem;
  font-weight: 700;
  color: rgb(var(--color-text-primary));
}

.error-text { color: #ef4444; }
.success-text { color: #10b981; }

.hero-actions {
  display: flex;
  gap: 1rem;
  width: 100%;
  justify-content: center;
  margin-top: 1rem;
}

.btn-outline {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  gap: 0.5rem;
  background: transparent;
  color: rgb(var(--color-text-primary));
  border: 2px solid rgb(var(--color-border));
  padding: 0.75rem 2rem;
  border-radius: 1rem;
  font-weight: 600;
  font-size: 1rem;
  cursor: pointer;
  transition: all 0.2s ease;
}

.btn-outline:hover:not(:disabled) {
  background: rgb(var(--color-surface-hover));
  border-color: rgb(var(--color-text-muted));
}

.btn-premium {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  gap: 0.5rem;
  background: linear-gradient(135deg, rgb(var(--color-primary)), #8b5cf6);
  color: white;
  border: none;
  padding: 0.75rem 2rem;
  border-radius: 1rem;
  font-weight: 600;
  font-size: 1rem;
  cursor: pointer;
  transition: all 0.2s ease;
  box-shadow: 0 4px 15px rgba(99, 102, 241, 0.3);
}

.btn-premium:hover:not(:disabled) {
  transform: translateY(-2px);
  box-shadow: 0 8px 20px rgba(99, 102, 241, 0.4);
}

.btn-premium:disabled, .btn-outline:disabled {
  opacity: 0.6;
  cursor: not-allowed;
  transform: none;
}

.spin { animation: spin 1s linear infinite; }
@keyframes spin { to { transform: rotate(360deg); } }
.size-4 { width: 1rem; height: 1rem; }

@media (max-width: 768px) {
  .hero-actions { flex-direction: column; }
  .btn-premium, .btn-outline { width: 100%; }
  .stats-grid { display: grid; grid-template-columns: 1fr 1fr; }
  .stat-box { min-width: unset; }
}
</style>
