<template>
  <div v-if="modelValue" class="modal-backdrop">
    <div class="modal-content result-modal">
      <div class="modal-header">
        <div class="icon-wrap bg-success">
          <svg class="size-6 text-white" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M5 13l4 4L19 7"/></svg>
        </div>
        <div class="header-titles">
          <h2>AI Optimization Complete</h2>
          <p class="subtitle">Review the generated content below</p>
        </div>
        <button class="btn-close" @click="discard">&times;</button>
      </div>

      <div class="modal-body">
        
        <div class="preview-container">
          <div v-if="oldContent" class="preview-panel old-panel">
            <h4>Current Content</h4>
            <div class="content-box">{{ oldContent }}</div>
          </div>
          
          <div class="preview-panel new-panel">
            <h4>AI Generated Content</h4>
            <div class="content-box ai-box">
              <pre v-if="isJson(newContent)">{{ formatJson(newContent) }}</pre>
              <div v-else class="text-content">{{ newContent }}</div>
            </div>
          </div>
        </div>

      </div>

      <div class="modal-footer">
        <button class="btn-secondary" @click="discard">Discard</button>
        <div class="flex-spacer"></div>
        <button class="btn-outline" @click="copy">
          <svg class="size-4 mr-2" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M8 16H6a2 2 0 01-2-2V6a2 2 0 012-2h8a2 2 0 012 2v2m-6 12h8a2 2 0 002-2v-8a2 2 0 00-2-2h-8a2 2 0 00-2 2v8a2 2 0 002 2z"/></svg>
          Copy to Clipboard
        </button>
        <button class="btn-primary" @click="apply">
          Apply to Resume
        </button>
      </div>
    </div>
  </div>
</template>

<script setup>
import { computed } from 'vue'

const props = defineProps({
  modelValue: { type: Boolean, default: false },
  oldContent: { type: String, default: '' },
  newContent: { type: [String, Object, Array], default: '' }
})

const emit = defineEmits(['update:modelValue', 'apply', 'discard'])

function isJson(val) {
  return typeof val === 'object' && val !== null
}

function formatJson(val) {
  return JSON.stringify(val, null, 2)
}

function discard() {
  emit('discard')
  emit('update:modelValue', false)
}

function apply() {
  emit('apply')
  emit('update:modelValue', false)
}

function copy() {
  const text = isJson(props.newContent) ? formatJson(props.newContent) : props.newContent
  navigator.clipboard.writeText(text)
  alert('Copied to clipboard!') // Ideally a toast, using alert for simplicity
}
</script>

<style scoped>
.modal-backdrop {
  position: fixed;
  top: 0; left: 0; right: 0; bottom: 0;
  background: rgba(15, 23, 42, 0.6);
  backdrop-filter: blur(8px);
  z-index: 100;
  display: flex;
  align-items: center;
  justify-content: center;
  animation: fadeIn 0.3s ease;
}

@keyframes fadeIn {
  from { opacity: 0; }
  to { opacity: 1; }
}

.result-modal {
  background: var(--color-surface);
  border-radius: 1.5rem;
  width: 95%;
  max-width: 900px;
  max-height: 90vh;
  display: flex;
  flex-direction: column;
  box-shadow: 0 20px 40px rgba(0,0,0,0.15);
  overflow: hidden;
  animation: slideUp 0.3s ease;
  border: 1px solid var(--color-border);
}

@keyframes slideUp {
  from { opacity: 0; transform: translateY(20px) scale(0.95); }
  to { opacity: 1; transform: translateY(0) scale(1); }
}

.modal-header {
  padding: 1.5rem 2rem;
  border-bottom: 1px solid var(--color-border);
  display: flex;
  align-items: center;
  gap: 1.25rem;
  position: relative;
}

.icon-wrap {
  width: 48px; height: 48px;
  border-radius: 14px;
  display: flex;
  align-items: center;
  justify-content: center;
}
.bg-success { background: linear-gradient(135deg, #10b981, #059669); }
.text-white { color: white; }
.size-6 { width: 1.5rem; height: 1.5rem; }
.size-4 { width: 1rem; height: 1rem; }
.mr-2 { margin-right: 0.5rem; }

.header-titles h2 {
  margin: 0 0 0.25rem 0;
  font-size: 1.25rem;
  font-weight: 700;
  color: var(--color-text-primary);
}
.subtitle {
  margin: 0;
  font-size: 0.875rem;
  color: var(--color-text-secondary);
}

.btn-close {
  position: absolute;
  right: 1.5rem;
  top: 1.5rem;
  background: none;
  border: none;
  font-size: 1.5rem;
  color: var(--color-text-muted);
  cursor: pointer;
  transition: color 0.2s;
}
.btn-close:hover { color: var(--color-text-primary); }

.modal-body {
  padding: 2rem;
  overflow-y: auto;
  flex: 1;
}

.preview-container {
  display: flex;
  gap: 2rem;
  min-height: 200px;
}

.preview-panel {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 1rem;
}

.preview-panel h4 {
  margin: 0;
  font-size: 0.875rem;
  text-transform: uppercase;
  letter-spacing: 0.05em;
  color: var(--color-text-secondary);
  font-weight: 600;
}

.content-box {
  flex: 1;
  background: var(--color-surface-2);
  border: 1px solid var(--color-border);
  border-radius: 1rem;
  padding: 1.25rem;
  font-size: 0.95rem;
  color: var(--color-text-primary);
  line-height: 1.6;
  white-space: pre-wrap;
  overflow-y: auto;
}

.ai-box {
  background: linear-gradient(to bottom right, rgba(99, 102, 241, 0.05), rgba(139, 92, 246, 0.05));
  border-color: rgba(99, 102, 241, 0.2);
  position: relative;
}
.ai-box::after {
  content: '✨';
  position: absolute;
  top: 1rem; right: 1rem;
  opacity: 0.5;
}

pre {
  margin: 0;
  white-space: pre-wrap;
  font-family: inherit;
}

.modal-footer {
  padding: 1.5rem 2rem;
  background: var(--color-surface-2);
  border-top: 1px solid var(--color-border);
  display: flex;
  align-items: center;
  gap: 1rem;
}

.flex-spacer { flex: 1; }

.btn-secondary {
  padding: 0.75rem 1.5rem;
  background: var(--color-surface);
  border: 1px solid var(--color-border);
  border-radius: 0.75rem;
  font-weight: 600;
  color: var(--color-text-primary);
  cursor: pointer;
}
.btn-secondary:hover { background: var(--color-surface-3); }

.btn-outline {
  padding: 0.75rem 1.5rem;
  background: transparent;
  border: 1px solid var(--color-border);
  border-radius: 0.75rem;
  font-weight: 600;
  color: var(--color-text-primary);
  cursor: pointer;
  display: inline-flex;
  align-items: center;
}
.btn-outline:hover { background: var(--color-surface-3); }

.btn-primary {
  padding: 0.75rem 2rem;
  background: linear-gradient(135deg, var(--color-primary), #8b5cf6);
  border: none;
  border-radius: 0.75rem;
  font-weight: 600;
  color: white;
  cursor: pointer;
  transition: all 0.2s;
  box-shadow: 0 4px 12px rgba(99, 102, 241, 0.3);
}
.btn-primary:hover {
  transform: translateY(-1px);
  box-shadow: 0 6px 16px rgba(99, 102, 241, 0.4);
}

@media (max-width: 768px) {
  .preview-container { flex-direction: column; }
}
</style>
