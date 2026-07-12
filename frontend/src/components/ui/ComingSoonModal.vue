<template>
  <div v-if="isOpen" class="modal-overlay" @click.self="close">
    <div class="modal-content">
      <div class="modal-icon">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M5 3v4M3 5h4M6 17v4m-2-2h4m5-16l2.286 6.857L21 12l-5.714 2.143L13 21l-2.286-6.857L5 12l5.714-2.143L13 3z"/></svg>
      </div>
      <h3 class="modal-title">Premium AI Feature</h3>
      <p class="modal-description">{{ message }}</p>
      
      <div class="modal-actions">
        <button class="btn-primary" @click="close">Understood</button>
      </div>
      
      <button class="btn-close" @click="close">
        <svg class="size-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M18 6L6 18M6 6l12 12"/></svg>
      </button>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'

const props = defineProps({
  modelValue: { type: Boolean, default: false },
  message: { type: String, default: 'This workflow will be available in the next phase.' }
})

const emit = defineEmits(['update:modelValue'])
const isOpen = ref(props.modelValue)

import { watch } from 'vue'
watch(() => props.modelValue, (val) => {
  isOpen.value = val
})

function close() {
  isOpen.value = false
  emit('update:modelValue', false)
}
</script>

<style scoped>
.modal-overlay {
  position: fixed;
  top: 0; left: 0; right: 0; bottom: 0;
  background: rgba(0, 0, 0, 0.5);
  backdrop-filter: blur(4px);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
  animation: fadeIn 0.3s ease;
}

.modal-content {
  background: var(--color-surface);
  border: 1px solid var(--color-border);
  border-radius: 1.5rem;
  padding: 2.5rem;
  max-width: 420px;
  width: 90%;
  position: relative;
  text-align: center;
  box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.25);
  animation: slideUp 0.3s cubic-bezier(0.16, 1, 0.3, 1);
}

.modal-icon {
  width: 64px;
  height: 64px;
  background: linear-gradient(135deg, rgba(99, 102, 241, 0.1), rgba(139, 92, 246, 0.1));
  color: var(--color-primary);
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  margin: 0 auto 1.5rem auto;
}
.modal-icon svg { width: 32px; height: 32px; }

.modal-title {
  font-size: 1.5rem;
  font-weight: 700;
  color: var(--color-text-primary);
  margin: 0 0 1rem 0;
}

.modal-description {
  font-size: 1rem;
  color: var(--color-text-secondary);
  line-height: 1.6;
  margin: 0 0 2rem 0;
}

.modal-actions {
  display: flex;
  justify-content: center;
}

.btn-primary {
  background: linear-gradient(135deg, var(--color-primary), #8b5cf6);
  color: white;
  border: none;
  padding: 0.875rem 2rem;
  border-radius: 1rem;
  font-size: 1rem;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.2s ease;
  box-shadow: 0 4px 12px rgba(99, 102, 241, 0.25);
  width: 100%;
}

.btn-primary:hover {
  transform: translateY(-2px);
  box-shadow: 0 8px 16px rgba(99, 102, 241, 0.35);
}

.btn-close {
  position: absolute;
  top: 1rem;
  right: 1rem;
  background: transparent;
  border: none;
  color: var(--color-text-muted);
  cursor: pointer;
  padding: 0.5rem;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: all 0.2s;
}

.btn-close:hover {
  background: var(--color-surface-2);
  color: var(--color-text-primary);
}

.size-5 { width: 1.25rem; height: 1.25rem; }

@keyframes fadeIn {
  from { opacity: 0; }
  to { opacity: 1; }
}

@keyframes slideUp {
  from { opacity: 0; transform: translateY(20px) scale(0.95); }
  to { opacity: 1; transform: translateY(0) scale(1); }
}
</style>
