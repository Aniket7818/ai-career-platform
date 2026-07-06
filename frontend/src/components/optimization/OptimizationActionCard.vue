<template>
  <div class="optimization-action-card">
    <div class="oac-content">
      <div class="oac-icon">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M12 2v4m0 12v4M4.93 4.93l2.83 2.83m8.48 8.48l2.83 2.83M2 12h4m12 0h4M4.93 19.07l2.83-2.83m8.48-8.48l2.83-2.83"/></svg>
      </div>
      <div class="oac-details">
        <h4>{{ title }}</h4>
        <p>{{ description }}</p>
      </div>
    </div>
    
    <div class="oac-actions">
      <button class="btn-action" v-for="action in actions" :key="action.type" @click="$emit('action', action.type)">
        {{ action.label }}
      </button>
    </div>
  </div>
</template>

<script setup>
const props = defineProps({
  title: { type: String, required: true },
  description: { type: String, required: true },
  actions: { 
    type: Array, 
    default: () => [
      { type: 'generate', label: 'Generate' },
      { type: 'rewrite', label: 'Rewrite' },
      { type: 'improve', label: 'Improve' }
    ] 
  }
})

defineEmits(['action'])
</script>

<style scoped>
.optimization-action-card {
  background: linear-gradient(135deg, var(--color-surface), var(--color-surface-2));
  border: 1px solid var(--color-border);
  border-radius: 1rem;
  padding: 1.5rem;
  transition: all 0.3s;
  display: flex;
  flex-direction: column;
  gap: 1.5rem;
  position: relative;
  overflow: hidden;
}

.optimization-action-card::after {
  content: '';
  position: absolute;
  top: 0; right: 0; width: 150px; height: 150px;
  background: radial-gradient(circle, rgba(99,102,241,0.05) 0%, transparent 70%);
  border-radius: 50%;
  pointer-events: none;
}

.optimization-action-card:hover {
  border-color: var(--color-primary);
  box-shadow: 0 8px 24px rgba(99, 102, 241, 0.1);
  transform: translateY(-2px);
}

.oac-content {
  display: flex;
  gap: 1rem;
  align-items: flex-start;
}

.oac-icon {
  background: rgba(99, 102, 241, 0.1);
  color: var(--color-primary);
  padding: 0.75rem;
  border-radius: 0.75rem;
  display: flex;
  align-items: center;
  justify-content: center;
}
.oac-icon svg { width: 1.5rem; height: 1.5rem; }

.oac-details h4 {
  margin: 0 0 0.5rem 0;
  font-size: 1.125rem;
  font-weight: 600;
  color: var(--color-text-primary);
}

.oac-details p {
  margin: 0;
  font-size: 0.875rem;
  color: var(--color-text-secondary);
  line-height: 1.5;
}

.oac-actions {
  display: flex;
  flex-wrap: wrap;
  gap: 0.75rem;
}

.btn-action {
  background: var(--color-surface);
  color: var(--color-text-primary);
  border: 1px solid var(--color-border);
  padding: 0.5rem 1rem;
  border-radius: 2rem;
  font-size: 0.875rem;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.2s;
}

.btn-action:hover {
  background: var(--color-primary);
  color: white;
  border-color: var(--color-primary);
}
</style>
