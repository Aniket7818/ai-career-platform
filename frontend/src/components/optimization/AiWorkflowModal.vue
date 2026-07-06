<template>
  <div v-if="modelValue" class="modal-backdrop" @click.self="close">
    <div class="modal-content">
      <div class="modal-header">
        <div class="icon-wrap">
          <svg class="size-6 text-primary" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M5 3v4M3 5h4M6 17v4m-2-2h4m5-16l2.286 6.857L21 12l-5.714 2.143L13 21l-2.286-6.857L5 12l5.714-2.143L13 3z"/></svg>
        </div>
        <h2>{{ title }}</h2>
        <button class="btn-close" @click="close">&times;</button>
      </div>

      <div class="modal-body">
        <p class="description">{{ description }}</p>

        <!-- Tailor to Job Description -->
        <div v-if="actionType === 'tailor_to_job' || actionType === 'optimize'">
          <div class="form-group">
            <label>Target Job Description</label>
            <textarea v-model="formData.job_description" rows="6" placeholder="Paste the full job description here..."></textarea>
          </div>
          <div class="form-row">
            <div class="form-group">
              <label>Target Role</label>
              <input type="text" v-model="formData.target_role" placeholder="e.g. Senior Frontend Engineer" />
            </div>
            <div class="form-group">
              <label>Experience Level</label>
              <select v-model="formData.experience_level">
                <option value="entry">Entry Level</option>
                <option value="mid">Mid Level</option>
                <option value="senior">Senior Level</option>
                <option value="executive">Executive</option>
              </select>
            </div>
          </div>
        </div>

        <!-- Cover Letter -->
        <div v-else-if="actionType === 'generate_cover_letter'">
          <div class="form-row">
            <div class="form-group">
              <label>Company Name</label>
              <input type="text" v-model="formData.company_name" placeholder="e.g. Acme Corp" />
            </div>
            <div class="form-group">
              <label>Hiring Manager</label>
              <input type="text" v-model="formData.hiring_manager" placeholder="e.g. John Doe (Optional)" />
            </div>
          </div>
          <div class="form-group">
            <label>Job Description</label>
            <textarea v-model="formData.job_description" rows="4" placeholder="Paste key responsibilities..."></textarea>
          </div>
          <div class="form-row">
            <div class="form-group">
              <label>Tone</label>
              <select v-model="formData.tone">
                <option value="professional">Professional</option>
                <option value="friendly">Friendly & Enthusiastic</option>
                <option value="formal">Formal</option>
              </select>
            </div>
            <div class="form-group">
              <label>Length</label>
              <select v-model="formData.length">
                <option value="short">Short & Concise</option>
                <option value="medium">Medium</option>
                <option value="long">Long & Detailed</option>
              </select>
            </div>
          </div>
        </div>

        <!-- LinkedIn -->
        <div v-else-if="actionType === 'generate_linkedin'">
          <div class="form-group">
            <label>Target Role / Headline Goal</label>
            <input type="text" v-model="formData.target_role" placeholder="e.g. Product Manager | Data-driven Innovator" />
          </div>
          <div class="form-group">
            <label>Industry</label>
            <input type="text" v-model="formData.industry" placeholder="e.g. FinTech, Healthcare" />
          </div>
        </div>
        
        <!-- General / Default -->
        <div v-else>
          <div class="form-group">
            <label>Additional Instructions (Optional)</label>
            <textarea v-model="formData.instructions" rows="3" placeholder="Any specific focus areas or tone changes?"></textarea>
          </div>
        </div>

      </div>

      <div class="modal-footer">
        <button class="btn-secondary" @click="close">Cancel</button>
        <button class="btn-primary" @click="submit" :disabled="!isReady">
          Generate with AI
        </button>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, watch } from 'vue'

const props = defineProps({
  modelValue: { type: Boolean, default: false },
  actionType: { type: String, required: true }
})

const emit = defineEmits(['update:modelValue', 'submit'])

const formData = ref({
  job_description: '',
  target_role: '',
  experience_level: 'mid',
  company_name: '',
  hiring_manager: '',
  tone: 'professional',
  length: 'medium',
  industry: '',
  instructions: ''
})

watch(() => props.modelValue, (newVal) => {
  if (newVal) {
    // reset form
    formData.value = {
      job_description: '',
      target_role: '',
      experience_level: 'mid',
      company_name: '',
      hiring_manager: '',
      tone: 'professional',
      length: 'medium',
      industry: '',
      instructions: ''
    }
  }
})

const title = computed(() => {
  switch (props.actionType) {
    case 'tailor_to_job': return 'Tailor Resume to Job'
    case 'optimize': return 'Tailor Resume to Job'
    case 'generate_cover_letter': return 'Generate Cover Letter'
    case 'generate_linkedin': return 'Optimize LinkedIn Profile'
    case 'generate_summary': return 'Generate Professional Summary'
    case 'rewrite_experience': return 'Rewrite Experience Bullets'
    case 'ats_booster': return 'ATS Keyword Booster'
    default: return 'AI Optimization'
  }
})

const description = computed(() => {
  switch (props.actionType) {
    case 'tailor_to_job': return 'Provide the job description you are targeting, and our AI will rewrite your resume to perfectly align with the requirements.'
    case 'generate_cover_letter': return 'Enter details about the company and role to generate a personalized, highly-converting cover letter.'
    case 'generate_linkedin': return 'We will craft a compelling LinkedIn headline and About section optimized for recruiter search.'
    default: return 'Customize how the AI should optimize your content.'
  }
})

const isReady = computed(() => {
  if (props.actionType === 'tailor_to_job' || props.actionType === 'optimize') {
    return formData.value.job_description.length > 50
  }
  return true
})

function close() {
  emit('update:modelValue', false)
}

function submit() {
  // Build instructions from form data
  let instructions = formData.value.instructions || ''
  
  if (props.actionType === 'generate_cover_letter') {
    instructions = `Company: ${formData.value.company_name}. Hiring Manager: ${formData.value.hiring_manager}. Tone: ${formData.value.tone}. Length: ${formData.value.length}. JD: ${formData.value.job_description}`
  } else if (props.actionType === 'generate_linkedin') {
    instructions = `Target Role: ${formData.value.target_role}. Industry: ${formData.value.industry}.`
  }

  emit('submit', { ...formData.value, instructions })
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

.modal-content {
  background: rgb(var(--color-surface));
  border-radius: 1.5rem;
  width: 90%;
  max-width: 600px;
  box-shadow: 0 20px 40px rgba(0,0,0,0.1);
  overflow: hidden;
  animation: slideUp 0.3s ease;
  border: 1px solid rgb(var(--color-border));
}

@keyframes slideUp {
  from { opacity: 0; transform: translateY(20px) scale(0.95); }
  to { opacity: 1; transform: translateY(0) scale(1); }
}

.modal-header {
  padding: 1.5rem 2rem;
  border-bottom: 1px solid rgb(var(--color-border));
  display: flex;
  align-items: center;
  gap: 1rem;
  position: relative;
}

.icon-wrap {
  width: 40px; height: 40px;
  background: rgba(99, 102, 241, 0.1);
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
}
.size-6 { width: 1.5rem; height: 1.5rem; }
.text-primary { color: rgb(var(--color-primary)); }

.modal-header h2 {
  margin: 0;
  font-size: 1.25rem;
  font-weight: 700;
  color: rgb(var(--color-text-primary));
}

.btn-close {
  position: absolute;
  right: 1.5rem;
  top: 1.5rem;
  background: none;
  border: none;
  font-size: 1.5rem;
  color: rgb(var(--color-text-muted));
  cursor: pointer;
  transition: color 0.2s;
}
.btn-close:hover { color: rgb(var(--color-text-primary)); }

.modal-body {
  padding: 2rem;
}

.description {
  margin: 0 0 1.5rem 0;
  color: rgb(var(--color-text-secondary));
  font-size: 0.95rem;
  line-height: 1.5;
}

.form-group {
  margin-bottom: 1.25rem;
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
}
.form-group:last-child { margin-bottom: 0; }

.form-row {
  display: flex;
  gap: 1rem;
}
.form-row .form-group {
  flex: 1;
}

label {
  font-size: 0.875rem;
  font-weight: 600;
  color: rgb(var(--color-text-primary));
}

input, textarea, select {
  padding: 0.75rem 1rem;
  border: 1px solid rgb(var(--color-border));
  border-radius: 0.75rem;
  background: rgb(var(--color-surface-hover));
  color: rgb(var(--color-text-primary));
  font-family: inherit;
  font-size: 0.95rem;
  transition: all 0.2s;
}

input:focus, textarea:focus, select:focus {
  outline: none;
  border-color: rgb(var(--color-primary));
  box-shadow: 0 0 0 3px rgba(99, 102, 241, 0.1);
  background: rgb(var(--color-surface));
}

textarea { resize: vertical; }

.modal-footer {
  padding: 1.5rem 2rem;
  background: rgb(var(--color-surface-hover));
  border-top: 1px solid rgb(var(--color-border));
  display: flex;
  justify-content: flex-end;
  gap: 1rem;
}

.btn-secondary {
  padding: 0.75rem 1.5rem;
  background: rgb(var(--color-surface));
  border: 1px solid rgb(var(--color-border));
  border-radius: 0.75rem;
  font-weight: 600;
  color: rgb(var(--color-text-primary));
  cursor: pointer;
}
.btn-secondary:hover { background: rgb(var(--color-surface-elevated)); }

.btn-primary {
  padding: 0.75rem 1.5rem;
  background: linear-gradient(135deg, rgb(var(--color-primary)), #8b5cf6);
  border: none;
  border-radius: 0.75rem;
  font-weight: 600;
  color: white;
  cursor: pointer;
  transition: all 0.2s;
  box-shadow: 0 4px 12px rgba(99, 102, 241, 0.3);
}
.btn-primary:hover:not(:disabled) {
  transform: translateY(-1px);
  box-shadow: 0 6px 16px rgba(99, 102, 241, 0.4);
}
.btn-primary:disabled {
  opacity: 0.5;
  cursor: not-allowed;
  box-shadow: none;
}
</style>
