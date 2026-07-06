<template>
  <div class="progress-card">
    <div class="pc-header">
      <h3 class="pc-title">Optimization Progress</h3>
      <div class="pc-percent">{{ progress }}%</div>
    </div>
    
    <div class="pc-bar-container">
      <div class="pc-bar">
        <div class="pc-fill" :style="{ width: `${progress}%` }"></div>
      </div>
    </div>

    <div class="pc-stats">
      <div class="stat">
        <span class="stat-label">Remaining Issues</span>
        <span class="stat-value">{{ remainingIssues }}</span>
      </div>
      <div class="stat">
        <span class="stat-label">Estimated Final</span>
        <span class="stat-value text-success">{{ estimatedFinal }}</span>
      </div>
      <div class="stat">
        <span class="stat-label">Potential Increase</span>
        <span class="stat-value text-primary">+{{ potentialIncrease }}</span>
      </div>
    </div>
  </div>
</template>

<script setup>
const props = defineProps({
  progress: { type: Number, default: 0 },
  remainingIssues: { type: Number, default: 0 },
  estimatedFinal: { type: Number, default: 0 },
  potentialIncrease: { type: Number, default: 0 }
})
</script>

<style scoped>
.progress-card {
  background: var(--color-surface);
  border: 1px solid var(--color-border);
  border-radius: 1rem;
  padding: 1.5rem;
}

.pc-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 1rem;
}

.pc-title {
  margin: 0;
  font-size: 1.125rem;
  font-weight: 600;
  color: var(--color-text-primary);
}

.pc-percent {
  font-size: 1.25rem;
  font-weight: 700;
  color: var(--color-primary);
}

.pc-bar-container {
  margin-bottom: 1.5rem;
}

.pc-bar {
  height: 12px;
  background: var(--color-surface-3);
  border-radius: 6px;
  overflow: hidden;
}

.pc-fill {
  height: 100%;
  background: linear-gradient(90deg, var(--color-primary), #8b5cf6);
  border-radius: 6px;
  transition: width 1s cubic-bezier(0.4, 0, 0.2, 1);
}

.pc-stats {
  display: flex;
  justify-content: space-between;
  gap: 1rem;
}

.stat {
  display: flex;
  flex-direction: column;
  gap: 0.25rem;
}

.stat-label {
  font-size: 0.75rem;
  color: var(--color-text-muted);
  font-weight: 500;
}

.stat-value {
  font-size: 1.125rem;
  font-weight: 700;
  color: var(--color-text-primary);
}

.text-success { color: #10b981; }
.text-primary { color: var(--color-primary); }
</style>
