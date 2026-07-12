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
        {{ action.label }} <span v-if="action.credits" class="action-credits">({{ action.credits }} Credits)</span>
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
  background: linear-gradient(135deg, rgb(var(--color-surface)), rgb(var(--color-surface-hover)));
  border: 1px solid rgb(var(--color-border));
  border-radius: 1.25rem;
  padding: 1.5rem;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  display: flex;
  flex-direction: column;
  gap: 1.5rem;
  position: relative;
  overflow: hidden;
}

.optimization-action-card::after {
  content: '';
  position: absolute;
  top: 0; right: 0; width: 200px; height: 200px;
  background: radial-gradient(circle, rgba(99,102,241,0.08) 0%, transparent 70%);
  border-radius: 50%;
  pointer-events: none;
  transition: transform 0.3s ease;
}

.optimization-action-card:hover {
  border-color: rgb(var(--color-primary));
  box-shadow: 0 12px 30px rgba(99, 102, 241, 0.15);
  transform: translateY(-4px);
}
.optimization-action-card:hover::after {
  transform: scale(1.2);
}

.oac-content {
  display: flex;
  gap: 1.25rem;
  align-items: flex-start;
}

.oac-icon {
  background: rgba(99, 102, 241, 0.1);
  color: rgb(var(--color-primary));
  padding: 0.875rem;
  border-radius: 1rem;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
  border: 1px solid rgba(99, 102, 241, 0.2);
}
.oac-icon svg { width: 1.5rem; height: 1.5rem; }

.oac-details h4 {
  margin: 0 0 0.5rem 0;
  font-size: 1.125rem;
  font-weight: 700;
  color: rgb(var(--color-text-primary));
}

.oac-details p {
  margin: 0;
  font-size: 0.875rem;
  color: rgb(var(--color-text-secondary));
  line-height: 1.6;
}

.oac-actions {
  display: flex;
  flex-wrap: wrap;
  gap: 0.75rem;
}

.btn-action {
  background: rgb(var(--color-surface));
  color: rgb(var(--color-text-primary));
  border: 1px solid rgb(var(--color-border));
  padding: 0.5rem 1.25rem;
  border-radius: 2rem;
  font-size: 0.875rem;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.2s cubic-bezier(0.4, 0, 0.2, 1);
  position: relative;
  overflow: hidden;
}

.btn-action:hover {
  background: linear-gradient(135deg, rgb(var(--color-primary)), #8b5cf6);
  color: white;
  border-color: transparent;
  transform: translateY(-1px);
  box-shadow: 0 4px 12px rgba(99, 102, 241, 0.3);
}

.btn-action:active {
  transform: translateY(0);
}

.action-credits {
  opacity: 0.8;
  font-weight: normal;
  margin-left: 2px;
}
</style>
