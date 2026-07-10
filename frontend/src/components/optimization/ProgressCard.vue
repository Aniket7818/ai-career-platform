<template>
  <div class="progress-card">
    <div class="pc-header">
      <div class="header-left">
        <h3 class="pc-title">Optimization Progress</h3>
        <p class="pc-subtitle">Track your resume's journey to perfection.</p>
      </div>
      <div class="pc-percent-badge">{{ progress }}%</div>
    </div>
    
    <div class="pc-bar-container">
      <div class="pc-bar">
        <div class="pc-fill" :style="{ width: `${progress}%` }">
          <div class="pc-glow"></div>
        </div>
      </div>
      <div class="pc-markers">
        <span>0%</span>
        <span>50%</span>
        <span>100%</span>
      </div>
    </div>

    <div class="pc-stats-grid">
      <div class="stat-card issues-card">
        <span class="stat-label">Remaining Issues</span>
        <span class="stat-value">{{ remainingIssues }}</span>
      </div>
      <div class="stat-card final-card">
        <span class="stat-label">Estimated Final</span>
        <span class="stat-value">{{ estimatedFinal }}</span>
      </div>
      <div class="stat-card increase-card">
        <span class="stat-label">Potential Increase</span>
        <span class="stat-value">+{{ potentialIncrease }} pts</span>
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
  background: rgb(var(--color-surface));
  border: 1px solid rgb(var(--color-border));
  border-radius: 1.5rem;
  padding: 2rem;
  box-shadow: 0 4px 20px rgba(0,0,0,0.02);
}

.pc-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 2rem;
}

.pc-title {
  margin: 0 0 0.25rem 0;
  font-size: 1.25rem;
  font-weight: 750;
  color: rgb(var(--color-text-primary));
}

.pc-subtitle {
  margin: 0;
  font-size: 0.875rem;
  color: rgb(var(--color-text-secondary));
}

.pc-percent-badge {
  background: linear-gradient(135deg, rgba(var(--color-primary), 0.08) 0%, rgba(139, 92, 246, 0.12) 100%);
  color: rgb(var(--color-primary));
  font-size: 1.5rem;
  font-weight: 900;
  padding: 0.5rem 1.25rem;
  border-radius: 1rem;
  border: 1px solid rgba(var(--color-primary), 0.25);
  box-shadow: 0 4px 15px rgba(99, 102, 241, 0.1);
}

.pc-bar-container {
  margin-bottom: 2.5rem;
  position: relative;
}

.pc-bar {
  height: 16px;
  background: rgb(var(--color-surface-elevated));
  border-radius: 8px;
  overflow: hidden;
  box-shadow: inset 0 2px 4px rgba(0,0,0,0.05);
}

.pc-fill {
  height: 100%;
  background: linear-gradient(90deg, rgb(var(--color-primary)) 0%, #8b5cf6 50%, #d946ef 100%);
  border-radius: 8px;
  position: relative;
  overflow: hidden;
  transition: width 1.5s cubic-bezier(0.34, 1.56, 0.64, 1);
}

.pc-glow {
  position: absolute;
  top: 0; left: 0; right: 0; bottom: 0;
  background: linear-gradient(90deg, transparent, rgba(255,255,255,0.3), transparent);
  animation: shine 2s infinite linear;
}

@keyframes shine {
  0% { transform: translateX(-100%); }
  100% { transform: translateX(100%); }
}

.pc-markers {
  display: flex;
  justify-content: space-between;
  margin-top: 0.5rem;
  font-size: 0.75rem;
  color: rgb(var(--color-text-muted));
  font-weight: 600;
}

.pc-stats-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 1.5rem;
}

.stat-card {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
  padding: 1.25rem 1rem;
  background: rgb(var(--color-surface-hover));
  border: 1px solid rgb(var(--color-border));
  border-radius: 1rem;
  align-items: center;
  text-align: center;
  transition: all 0.25s cubic-bezier(0.4, 0, 0.2, 1);
}

.stat-label {
  font-size: 0.75rem;
  color: rgb(var(--color-text-muted));
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 0.05em;
}

.stat-value {
  font-size: 1.5rem;
  font-weight: 850;
  color: rgb(var(--color-text-primary));
}

/* Individual Stat Cards Styling */
.issues-card {
  background: linear-gradient(135deg, rgb(var(--color-surface)) 0%, rgb(var(--color-surface-hover)) 100%);
  border-color: rgba(239, 68, 68, 0.15);
}
.issues-card .stat-value {
  color: #ef4444;
}
.issues-card:hover {
  transform: translateY(-3px);
  border-color: rgba(239, 68, 68, 0.35);
  box-shadow: 0 8px 25px rgba(239, 68, 68, 0.08);
}

.final-card {
  background: linear-gradient(135deg, rgb(var(--color-surface)) 0%, rgb(var(--color-surface-hover)) 100%);
  border-color: rgba(16, 185, 129, 0.15);
}
.final-card .stat-value {
  color: #10b981;
}
.final-card:hover {
  transform: translateY(-3px);
  border-color: rgba(16, 185, 129, 0.35);
  box-shadow: 0 8px 25px rgba(16, 185, 129, 0.08);
}

.increase-card {
  background: linear-gradient(135deg, rgba(99, 102, 241, 0.02) 0%, rgba(139, 92, 246, 0.06) 100%);
  border-color: rgba(99, 102, 241, 0.25);
}
.increase-card .stat-value {
  color: rgb(var(--color-primary));
}
.increase-card:hover {
  transform: translateY(-3px);
  border-color: rgba(99, 102, 241, 0.45);
  box-shadow: 0 8px 25px rgba(99, 102, 241, 0.08);
}

@media (max-width: 640px) {
  .progress-card {
    padding: 1.25rem 1rem;
    border-radius: 1.25rem;
  }
  .pc-header {
    margin-bottom: 1.25rem;
  }
  .pc-percent-badge {
    font-size: 1.25rem;
    padding: 0.4rem 0.85rem;
  }
  .pc-bar-container {
    margin-bottom: 1.75rem;
  }
  .pc-stats-grid { 
    grid-template-columns: 1fr; 
    gap: 1rem; 
  }
}
</style>
