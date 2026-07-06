<template>
  <div class="hero-score-card">
    <div class="hero-header">
      <div class="hero-title-group">
        <h2>Resume Optimization</h2>
        <p class="hero-subtitle">Optimize your resume to pass ATS and land more interviews.</p>
      </div>
      <div class="hero-actions">
        <button class="btn-secondary" @click="$emit('analyze')" :disabled="loading">
          <svg v-if="loading" class="spin size-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M21 12a9 9 0 11-6.219-8.56"/></svg>
          {{ loading ? 'Analyzing...' : 'Analyze Again' }}
        </button>
        <button class="btn-primary" @click="$emit('optimize')" :disabled="loading">
          <svg class="size-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M13 10V3L4 14h7v7l9-11h-7z"/></svg>
          Optimize Resume
        </button>
      </div>
    </div>

    <div class="hero-content">
      <div class="main-score">
        <div class="score-circle" :class="scoreClass">
          <svg viewBox="0 0 36 36" class="circular-chart">
            <path class="circle-bg"
              d="M18 2.0845
                a 15.9155 15.9155 0 0 1 0 31.831
                a 15.9155 15.9155 0 0 1 0 -31.831"
            />
            <path class="circle"
              :stroke-dasharray="`${score}, 100`"
              d="M18 2.0845
                a 15.9155 15.9155 0 0 1 0 31.831
                a 15.9155 15.9155 0 0 1 0 -31.831"
            />
            <text x="18" y="20.35" class="percentage">{{ score }}</text>
          </svg>
        </div>
        <div class="main-score-details">
          <h3>Overall Score</h3>
          <div class="grade-badge" :class="scoreClass">{{ grade }}</div>
        </div>
      </div>

      <div class="hero-stats">
        <div class="stat-item">
          <div class="stat-label">Estimated ATS Success %</div>
          <div class="stat-value">{{ atsSuccess }}%</div>
        </div>
        <div class="stat-item">
          <div class="stat-label">Resume Completion %</div>
          <div class="stat-value">{{ completion }}%</div>
        </div>
        <div class="stat-item">
          <div class="stat-label">Total Issues</div>
          <div class="stat-value error-text">{{ issues }}</div>
        </div>
        <div class="stat-item">
          <div class="stat-label">Potential Score Gain</div>
          <div class="stat-value success-text">+{{ potentialGain }}</div>
        </div>
        <div class="stat-item full-width">
          <div class="stat-label">Last Analysis</div>
          <div class="stat-value text-sm">{{ lastAnalyzed }}</div>
        </div>
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
  return 'D'
})

const scoreClass = computed(() => {
  if (props.score >= 80) return 'score-high'
  if (props.score >= 60) return 'score-med'
  return 'score-low'
})
</script>

<style scoped>
.hero-score-card {
  background: linear-gradient(145deg, var(--color-surface), var(--color-surface-2));
  border: 1px solid var(--color-border);
  border-radius: 1.5rem;
  padding: 2.5rem;
  box-shadow: 0 10px 30px -10px rgba(0, 0, 0, 0.1);
  overflow: hidden;
  position: relative;
  transition: transform 0.3s ease;
}

.hero-score-card::before {
  content: '';
  position: absolute;
  top: 0; left: 0; right: 0; height: 4px;
  background: linear-gradient(90deg, var(--color-primary), #10b981, #3b82f6);
}

.hero-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 2rem;
  flex-wrap: wrap;
  gap: 1rem;
}

.hero-title-group h2 {
  font-size: 1.75rem;
  font-weight: 700;
  margin: 0 0 0.5rem 0;
  color: var(--color-text-primary);
}

.hero-subtitle {
  color: var(--color-text-muted);
  margin: 0;
  font-size: 1rem;
}

.hero-actions {
  display: flex;
  gap: 1rem;
}

.btn-primary {
  display: inline-flex;
  align-items: center;
  gap: 0.5rem;
  background: var(--color-primary);
  color: #fff;
  border: none;
  padding: 0.75rem 1.5rem;
  border-radius: 0.75rem;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.2s ease;
  box-shadow: 0 4px 12px rgba(99, 102, 241, 0.3);
}

.btn-primary:hover:not(:disabled) {
  transform: translateY(-2px);
  box-shadow: 0 6px 16px rgba(99, 102, 241, 0.4);
}

.btn-secondary {
  display: inline-flex;
  align-items: center;
  gap: 0.5rem;
  background: var(--color-surface);
  color: var(--color-text-primary);
  border: 1px solid var(--color-border);
  padding: 0.75rem 1.5rem;
  border-radius: 0.75rem;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.2s ease;
}

.btn-secondary:hover:not(:disabled) {
  background: var(--color-surface-3);
}

.btn-primary:disabled, .btn-secondary:disabled {
  opacity: 0.6;
  cursor: not-allowed;
  transform: none;
}

.hero-content {
  display: grid;
  grid-template-columns: auto 1fr;
  gap: 3rem;
  align-items: center;
}

.main-score {
  display: flex;
  align-items: center;
  gap: 2rem;
}

.main-score-details h3 {
  font-size: 1.25rem;
  margin: 0 0 0.5rem 0;
  color: var(--color-text-secondary);
}

.grade-badge {
  display: inline-block;
  padding: 0.25rem 1rem;
  border-radius: 2rem;
  font-size: 1.5rem;
  font-weight: 800;
  background: rgba(0,0,0,0.05);
}
.grade-badge.score-high { color: #10b981; background: rgba(16, 185, 129, 0.1); }
.grade-badge.score-med { color: #f59e0b; background: rgba(245, 158, 11, 0.1); }
.grade-badge.score-low { color: #ef4444; background: rgba(239, 68, 68, 0.1); }

/* Circular chart */
.score-circle { width: 140px; height: 140px; position: relative; }
.circular-chart { display: block; margin: 0 auto; width: 100%; height: 100%; }
.circle-bg { fill: none; stroke: var(--color-surface-3); stroke-width: 2.5; }
.circle { fill: none; stroke-width: 2.5; stroke-linecap: round; transition: stroke-dasharray 1.5s cubic-bezier(0.4, 0, 0.2, 1); }
.percentage { fill: var(--color-text-primary); font-family: inherit; font-size: 10px; font-weight: bold; text-anchor: middle; }
.score-high .circle { stroke: #10b981; }
.score-med .circle { stroke: #f59e0b; }
.score-low .circle { stroke: #ef4444; }
.score-high .percentage { fill: #10b981; }
.score-med .percentage { fill: #f59e0b; }
.score-low .percentage { fill: #ef4444; }

.hero-stats {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 1.5rem;
}

.stat-item {
  background: var(--color-surface);
  border: 1px solid var(--color-border);
  padding: 1rem 1.5rem;
  border-radius: 1rem;
  transition: transform 0.2s;
}
.stat-item:hover {
  transform: translateY(-2px);
  border-color: var(--color-border-hover);
}

.stat-item.full-width {
  grid-column: span 2;
}

.stat-label {
  font-size: 0.875rem;
  color: var(--color-text-muted);
  margin-bottom: 0.5rem;
  font-weight: 500;
}

.stat-value {
  font-size: 1.5rem;
  font-weight: 700;
  color: var(--color-text-primary);
}

.stat-value.text-sm {
  font-size: 1rem;
}

.error-text { color: #ef4444; }
.success-text { color: #10b981; }

.spin { animation: spin 1s linear infinite; }
@keyframes spin { to { transform: rotate(360deg); } }
.size-4 { width: 1rem; height: 1rem; }

@media (max-width: 1024px) {
  .hero-content { grid-template-columns: 1fr; gap: 2rem; }
  .main-score { justify-content: center; }
}
@media (max-width: 640px) {
  .hero-actions { width: 100%; flex-direction: column; }
  .btn-primary, .btn-secondary { width: 100%; justify-content: center; }
  .hero-stats { grid-template-columns: 1fr; }
  .stat-item.full-width { grid-column: span 1; }
}
</style>
