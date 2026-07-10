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

      <div class="modal-body" v-if="creditCost > 0 && remainingCredits < creditCost">
        <div class="insufficient-credits-state">
          <div class="icon-wrap-error">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z"/></svg>
          </div>
          <h3>Insufficient Credits</h3>
          <p>You need <strong>{{ creditCost }} credits</strong> for this action.</p>
          <p class="current-balance">Current balance: <strong>{{ remainingCredits }} Credits</strong></p>
          <div class="error-actions mt-6">
            <button class="btn-primary" @click="$router.push('/settings/billing')">Buy Credits</button>
            <button class="btn-secondary" @click="close">Cancel</button>
          </div>
        </div>
      </div>

      <div class="modal-body" v-else>
        <p class="description">{{ description }}</p>
        
        <div v-if="creditCost > 0" class="credit-info-box mb-6" :class="{ 'premium-info-box': actionType === 'generate_linkedin' }">
          <div v-if="actionType === 'generate_linkedin'" class="premium-badge-tag mb-3">
            <svg class="size-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"/></svg>
            Premium AI Report
          </div>
          
          <div class="credit-cost-main">
            <span class="cost-label" v-if="actionType === 'generate_linkedin'">Premium Report Generation Cost</span>
            <span class="cost-label" v-else>This AI action will consume</span>
            <span class="cost-value" :class="{ 'premium-cost-value': actionType === 'generate_linkedin' }">
              <template v-if="actionType === 'generate_linkedin'">💎 {{ creditCost }} Credits</template>
              <template v-else>⭐⭐ {{ creditCost }} Credits</template>
            </span>
          </div>

          <div v-if="actionType === 'generate_linkedin'" class="premium-features-list mb-4">
            <div class="premium-feature-item">
              <svg class="feature-check" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3"><polyline points="20 6 9 17 4 12"/></svg>
              <span><strong>5 Headline Strategies:</strong> ATS, Recruiter, Personal Brand, Technical, & Concise</span>
            </div>
            <div class="premium-feature-item">
              <svg class="feature-check" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3"><polyline points="20 6 9 17 4 12"/></svg>
              <span><strong>Recruiter Quality Insights:</strong> 9 complex metrics & improvement logs</span>
            </div>
            <div class="premium-feature-item">
              <svg class="feature-check" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3"><polyline points="20 6 9 17 4 12"/></svg>
              <span><strong>Interactive LinkedIn Mockup:</strong> Instant preview & headline testing</span>
            </div>
            <div class="premium-feature-item">
              <svg class="feature-check" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3"><polyline points="20 6 9 17 4 12"/></svg>
              <span><strong>SEO Keyword Analysis:</strong> Top tech, target roles, & networking topics</span>
            </div>
            <div class="premium-feature-item">
              <svg class="feature-check" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3"><polyline points="20 6 9 17 4 12"/></svg>
              <span><strong>Full About Section:</strong> Story-driven personal brand narrative (up to 2,400 chars)</span>
            </div>
          </div>

          <div class="credit-details">
            <div class="detail-item">
              <span class="detail-label">Estimated Time:</span>
              <template v-if="actionType === 'generate_linkedin'">15-25 seconds</template>
              <template v-else>10-20 seconds</template>
            </div>
            <div class="detail-item">
              <span class="detail-label">Remaining Credits:</span> {{ remainingCredits }}
            </div>
          </div>
          <p class="credit-policy">
            Credits are deducted ONLY after successful AI generation. If generation fails, no credits are charged.
          </p>
        </div>


        <!-- Tailor to Job Description -->
        <div v-if="actionType === 'tailor_to_job' || actionType === 'optimize'">
          <div class="form-group">
            <div class="label-row">
              <label>Target Job Description</label>
              <span class="char-counter" :class="{ 'text-danger': formData.job_description.length > MAX_JD_CHARS }">
                {{ formData.job_description.length }} / {{ MAX_JD_CHARS }}
              </span>
            </div>
            <textarea v-model="formData.job_description" rows="6" placeholder="Paste the full job description here..."></textarea>
            
            <div class="helper-message mt-1" v-if="formData.job_description.length > MAX_JD_CHARS">
              <span class="text-danger">Please shorten your Job Description. Maximum 8000 characters allowed.</span>
            </div>
            <div class="helper-message mt-1" v-else-if="meaningfulCharCount === 0">
              <span class="text-secondary">⚠ Waiting for required information. Minimum 50 characters required.</span>
            </div>
            <div class="helper-message mt-1" v-else-if="meaningfulCharCount < 50">
              <span class="text-danger">🔴 {{ meaningfulCharCount }} / 50 characters ({{ 50 - meaningfulCharCount }} more required)</span>
            </div>
            <div class="helper-message mt-1" v-else>
              <span class="text-success font-semibold">✓ Ready to generate</span>
            </div>
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
            <div class="label-row">
              <label>Job Description</label>
              <span class="char-counter" :class="{ 'text-danger': formData.job_description.length > MAX_JD_CHARS }">
                {{ formData.job_description.length }} / {{ MAX_JD_CHARS }}
              </span>
            </div>
            <textarea v-model="formData.job_description" rows="4" placeholder="Paste key responsibilities..."></textarea>
            
            <div class="helper-message mt-1" v-if="formData.job_description.length > MAX_JD_CHARS">
              <span class="text-danger">Please shorten your Job Description. Maximum 8000 characters allowed.</span>
            </div>
            <div class="helper-message mt-1" v-else-if="meaningfulCharCount === 0">
              <span class="text-secondary">⚠ Waiting for required information. Minimum 50 characters required.</span>
            </div>
            <div class="helper-message mt-1" v-else-if="meaningfulCharCount < 50">
              <span class="text-danger">🔴 {{ meaningfulCharCount }} / 50 characters ({{ 50 - meaningfulCharCount }} more required)</span>
            </div>
            <div class="helper-message mt-1" v-else>
              <span class="text-success font-semibold">✓ Ready to generate</span>
            </div>
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
        
        <!-- Project AI Workflow -->
        <div v-else-if="actionType === 'optimize_project'">
          <!-- Step 1: Project Selection -->
          <div v-if="step === 1 && projects.length > 1">
            <div class="form-group">
              <label class="mb-2 block">Select Project to Optimize</label>
              <div class="project-selector-list">
                <label v-for="p in projects" :key="p.id" class="project-selector-item" :class="{ active: selectedProjectId === p.id }">
                  <input type="radio" :value="p.id" v-model="selectedProjectId" class="radio-input" />
                  <div class="project-info">
                    <span class="project-name">{{ p.projectName || 'Untitled Project' }}</span>
                    <span class="project-tech">{{ p.technologies || 'No technologies listed' }}</span>
                  </div>
                </label>
              </div>
              <div v-if="projectValidationError" class="text-danger mt-2" style="font-size:0.85rem">{{ projectValidationError }}</div>
            </div>
          </div>

          <!-- Step 2: Field Selection -->
          <div v-else-if="step === 2">
            <div class="selected-project-preview mb-4">
              <span class="label">Optimizing:</span>
              <span class="value font-bold">{{ selectedProject?.projectName || 'Untitled Project' }}</span>
            </div>

            <div class="form-group mb-4">
              <label>What would you like AI to improve?</label>
              <div class="option-grid">
                <label v-for="field in projectFieldOptions" :key="field.value" class="option-card" :class="{ active: selectedProjectField === field.value }">
                  <input type="radio" :value="field.value" v-model="selectedProjectField" class="radio-input" />
                  <div class="option-card-inner">
                    <span class="option-label">{{ field.label }}</span>
                    <span class="option-hint">{{ field.hint }}</span>
                  </div>
                </label>
              </div>
            </div>

            <div v-if="selectedProjectField === 'description'" class="field-notice mb-4">
              <div class="notice-icon">✍️</div>
              <div class="notice-text">
                <strong>{{ isDescriptionEmpty ? 'Generate Description' : 'Improve Description' }}</strong>
                <span v-if="isDescriptionEmpty"> — AI will craft a fresh ATS-friendly description from your project title and technologies.</span>
                <span v-else> — AI will rewrite your description with better ATS keywords, action verbs, and technical clarity.</span>
              </div>
            </div>

            <div v-else-if="selectedProjectField === 'technologies'" class="field-notice mb-4">
              <div class="notice-icon">⚙️</div>
              <div class="notice-text">
                <strong>{{ areTechnologiesEmpty ? 'Generate Technologies' : 'Improve Technologies' }}</strong>
                <span v-if="areTechnologiesEmpty"> — AI will suggest technologies based on your project title and description.</span>
                <span v-else> — AI will add missing ATS keywords and standardize names while keeping your existing stack.</span>
              </div>
            </div>

            <div class="form-group">
              <div class="label-row">
                <label>Additional Instructions (Optional)</label>
                <span class="char-counter" :class="{ 'text-danger': formData.instructions.length > MAX_INSTRUCTIONS_CHARS }">{{ formData.instructions.length }} / {{ MAX_INSTRUCTIONS_CHARS }}</span>
              </div>
              <textarea v-model="formData.instructions" rows="2" placeholder="Any specific focus areas?"></textarea>
            </div>
          </div>
        </div>

        <!-- Experience AI Workflow -->
        <div v-else-if="actionType === 'rewrite_experience'">
          <!-- No experience at all -->
          <div v-if="experiences.length === 0" class="empty-state-notice">
            <div class="notice-icon">💼</div>
            <div class="notice-text">
              <strong>No Work Experience Found</strong>
              <span> — Please add at least one work experience entry (with a job title and company name) in the resume editor first, then come back to generate or improve your description with AI.</span>
            </div>
          </div>

          <!-- Step 1: Experience Selection (only when >1 experience) -->
          <div v-else-if="step === 1 && experiences.length > 1">
            <div class="form-group">
              <label class="mb-2 block">Select Work Experience to Improve</label>
              <div class="project-selector-list">
                <label v-for="e in experiences" :key="e.id" class="project-selector-item" :class="{ active: selectedExperienceId === e.id }">
                  <input type="radio" :value="e.id" v-model="selectedExperienceId" class="radio-input" />
                  <div class="project-info">
                    <span class="project-name">{{ e.role || 'Job Title' }}</span>
                    <span class="project-tech">{{ e.company || 'Company' }}</span>
                  </div>
                </label>
              </div>
              <div v-if="experienceValidationError" class="text-danger mt-2" style="font-size:0.85rem">{{ experienceValidationError }}</div>
            </div>
          </div>

          <!-- Step 2: Confirmation / Instructions -->
          <div v-else-if="step === 2 && experiences.length > 0">
            <div class="selected-project-preview mb-4">
              <span class="label">Improving:</span>
              <span class="value font-bold">{{ selectedExperience?.role || 'Job Title' }} at {{ selectedExperience?.company || 'Company' }}</span>
            </div>

            <div class="field-notice mb-4">
              <div class="notice-icon">✍️</div>
              <div class="notice-text">
                <strong>{{ isExperienceDescriptionEmpty ? 'Generate Description' : 'Improve Description' }}</strong>
                <span v-if="isExperienceDescriptionEmpty"> — AI will craft fresh resume bullet points based on your role and company.</span>
                <span v-else> — AI will rewrite your work experience bullet points to be more professional, ATS-friendly, and outcome-oriented.</span>
              </div>
            </div>

            <div class="form-group">
              <div class="label-row">
                <label>Additional Instructions (Optional)</label>
                <span class="char-counter" :class="{ 'text-danger': formData.instructions.length > MAX_INSTRUCTIONS_CHARS }">{{ formData.instructions.length }} / {{ MAX_INSTRUCTIONS_CHARS }}</span>
              </div>
              <textarea v-model="formData.instructions" rows="3" placeholder="e.g. Focus on leadership impact, mention specific technologies, tailor for a senior engineering role..."></textarea>
            </div>
          </div>
        </div>

        <!-- Bullet Enhancer AI Workflow -->
        <div v-else-if="['rewrite', 'expand', 'shorten'].includes(actionType)">
          <!-- No experience at all -->
          <div v-if="experiences.length === 0" class="empty-state-notice">
            <div class="notice-icon">💼</div>
            <div class="notice-text">
              <strong>No Work Experience Found</strong>
              <span> — Please add at least one work experience entry in the resume editor first, then come back to use the Bullet Point Enhancer.</span>
            </div>
          </div>

          <!-- Step 1: Experience Selection (only when >1 experience) -->
          <div v-else-if="step === 1 && experiences.length > 1">
            <div class="form-group">
              <label class="mb-2 block">Select Work Experience</label>
              <div class="project-selector-list">
                <label v-for="e in experiences" :key="e.id" class="project-selector-item" :class="{ active: selectedExperienceId === e.id }">
                  <input type="radio" :value="e.id" v-model="selectedExperienceId" class="radio-input" />
                  <div class="project-info">
                    <span class="project-name">{{ e.role || 'Job Title' }}</span>
                    <span class="project-tech">{{ e.company || 'Company' }}</span>
                  </div>
                </label>
              </div>
              <div v-if="experienceValidationError" class="text-danger mt-2" style="font-size:0.85rem">{{ experienceValidationError }}</div>
            </div>
          </div>

          <!-- Step 2: Bullet Selection -->
          <div v-else-if="step === 2 && experiences.length > 0">
            <div class="selected-project-preview mb-4">
              <span class="label">Experience:</span>
              <span class="value font-bold">{{ selectedExperience?.role || 'Job Title' }} at {{ selectedExperience?.company || 'Company' }}</span>
            </div>

            <div class="form-group mb-4">
              <label class="mb-2 block">Select the Bullet Point to {{ actionType.toUpperCase() }}</label>
              <div v-if="selectedExperienceBullets.length === 0" class="text-secondary italic mb-2">
                This experience has no description or bullet points. Please paste or type the bullet below.
              </div>
              <div v-else class="project-selector-list max-h-60 overflow-y-auto">
                <label v-for="(bullet, bIdx) in selectedExperienceBullets" :key="bIdx" class="project-selector-item" :class="{ active: selectedBulletText === bullet }">
                  <input type="radio" :value="bullet" v-model="selectedBulletText" class="radio-input" />
                  <div class="project-info">
                    <span class="project-tech font-normal text-txt-primary">{{ bullet }}</span>
                  </div>
                </label>
              </div>
            </div>

            <!-- Custom Bullet Input if they want to paste/override -->
            <div class="form-group mb-4">
              <label>Edit or Paste the Bullet Point</label>
              <textarea v-model="selectedBulletText" rows="2" placeholder="Select a bullet above or type/paste one here..."></textarea>
            </div>

            <div class="form-group">
              <div class="label-row">
                <label>Additional Instructions (Optional)</label>
                <span class="char-counter" :class="{ 'text-danger': formData.instructions.length > MAX_INSTRUCTIONS_CHARS }">{{ formData.instructions.length }} / {{ MAX_INSTRUCTIONS_CHARS }}</span>
              </div>
              <textarea v-model="formData.instructions" rows="2" placeholder="e.g. Focus on leadership impact, mention specific technologies..."></textarea>
            </div>
          </div>
        </div>

        <!-- Skills AI — Intent-driven -->
        <div v-else-if="actionType === 'improve_skills'">
          <div class="skills-quick-prompts mb-4">
            <p class="skills-hint-label mb-2">What would you like to generate?</p>
            <div class="skills-chip-grid">
              <button
                v-for="chip in skillQuickPrompts"
                :key="chip"
                type="button"
                class="skill-chip"
                :class="{ active: formData.instructions === chip }"
                @click="formData.instructions = formData.instructions === chip ? '' : chip"
              >
                {{ chip }}
              </button>
            </div>
          </div>

          <div class="form-group">
            <div class="label-row">
              <label>Custom Instruction (Optional)</label>
              <span class="char-counter" :class="{ 'text-danger': formData.instructions.length > MAX_INSTRUCTIONS_CHARS }">{{ formData.instructions.length }} / {{ MAX_INSTRUCTIONS_CHARS }}</span>
            </div>
            <textarea
              v-model="formData.instructions"
              rows="2"
              placeholder="e.g. Generate one testing framework  •  Add 2 databases  •  Generate 3 DevOps tools"
            ></textarea>
          </div>

          <div class="skills-intent-notice mt-3">
            <div class="notice-icon">💡</div>
            <div class="notice-text">
              <strong>How it works:</strong>
              <span> Specify a category and quantity for precise results. Leave blank to generate skills based on ATS gaps or to build a foundation if your skills section is empty.</span>
            </div>
          </div>
        </div>

        <!-- General / Default -->
        <div v-else>
          <div class="form-group">
            <div class="label-row">
              <label>Additional Instructions (Optional)</label>
              <span class="char-counter" :class="{ 'text-danger': formData.instructions.length > MAX_INSTRUCTIONS_CHARS }">{{ formData.instructions.length }} / {{ MAX_INSTRUCTIONS_CHARS }}</span>
            </div>
            <textarea v-model="formData.instructions" rows="3" placeholder="Any specific focus areas or tone changes?"></textarea>
          </div>
        </div>

      </div>

      <div class="modal-footer" v-if="remainingCredits >= creditCost || (['rewrite_experience', 'rewrite', 'expand', 'shorten'].includes(actionType) && experiences.length === 0)">
        <button v-if="(actionType === 'optimize_project' && step === 2 && projects.length > 1) || (actionType === 'rewrite_experience' && step === 2 && experiences.length > 1) || (['rewrite', 'expand', 'shorten'].includes(actionType) && step === 2 && experiences.length > 1)" class="btn-secondary" @click="step = 1">Back</button>
        <button v-else class="btn-secondary" @click="close">{{ (['rewrite_experience', 'rewrite', 'expand', 'shorten'].includes(actionType) && experiences.length === 0) ? 'Close' : 'Cancel' }}</button>
        <button v-if="(actionType === 'optimize_project' && step === 1 && projects.length > 1) || (actionType === 'rewrite_experience' && step === 1 && experiences.length > 1) || (['rewrite', 'expand', 'shorten'].includes(actionType) && step === 1 && experiences.length > 1)" class="btn-primary" @click="nextStep">Continue</button>
        <button v-else-if="(!['rewrite_experience', 'rewrite', 'expand', 'shorten'].includes(actionType)) || experiences.length > 0" class="btn-primary" @click="submit" :disabled="!isReady">Generate with AI ({{ creditCost }} Credits)</button>
      </div>

    </div>
  </div>
</template>

<script setup>
import { ref, computed, watch } from 'vue'

const props = defineProps({
  modelValue: { type: Boolean, default: false },
  actionType: { type: String, required: true },
  creditCost: { type: Number, default: 0 },
  remainingCredits: { type: Number, default: 0 },
  projects: { type: Array, default: () => [] },
  experiences: { type: Array, default: () => [] }
})

const emit = defineEmits(['update:modelValue', 'submit'])

const MAX_JD_CHARS = 8000
const MAX_INSTRUCTIONS_CHARS = 1000

const skillQuickPrompts = [
  'Generate 1 testing framework',
  'Generate 2 databases',
  'Generate 3 DevOps tools',
  'Generate 1 cloud provider',
  'Generate 5 backend technologies',
  'Add missing ATS skills',
  'Generate some frontend skills',
  'Generate 1 CI/CD tool',
  'Generate 1 authentication technology',
  'Generate some version control tools'
]

const step = ref(1)
const selectedProjectId = ref('')
const selectedProjectField = ref('description')
const selectedProjectAction = ref('rewrite_description')
const projectValidationError = ref('')

const selectedExperienceId = ref('')
const experienceValidationError = ref('')
const selectedBulletText = ref('')

const projectFieldOptions = [
  { value: 'description', label: 'Description', hint: 'Generate or improve project description' },
  { value: 'technologies', label: 'Technologies', hint: 'Generate or improve tech stack' }
]

const selectedProject = computed(() => {
  if (!props.projects || props.projects.length === 0) return null
  return props.projects.find(p => p.id === selectedProjectId.value) || props.projects[0]
})

const selectedExperience = computed(() => {
  if (!props.experiences || props.experiences.length === 0) return null
  return props.experiences.find(e => e.id === selectedExperienceId.value) || props.experiences[0]
})

const isDescriptionEmpty = computed(() => !selectedProject.value?.description?.trim())
const areTechnologiesEmpty = computed(() => !selectedProject.value?.technologies?.trim())
const descriptionDefaultAction = computed(() => isDescriptionEmpty.value ? 'generate_description' : 'rewrite_description')
const technologiesDefaultAction = computed(() => areTechnologiesEmpty.value ? 'generate_technologies' : 'improve_technologies')

const isExperienceDescriptionEmpty = computed(() => !selectedExperience.value?.description?.trim())

const selectedExperienceBullets = computed(() => {
  const desc = selectedExperience.value?.description || ''
  if (!desc.trim()) return []
  let lines = desc.split(/\r?\n/).map(line => line.trim()).filter(line => line.length > 0)
  
  if (lines.length === 1) {
    const singleLine = lines[0]
    const bulletRegex = /\s*[•●▪◦■◆★]\s*|\s+[-\*]\s+/
    if (singleLine.match(bulletRegex)) {
      const parts = singleLine.split(bulletRegex).map(p => p.trim()).filter(p => p.length > 0)
      if (parts.length > 1) {
        return parts.map(p => `• ${p}`)
      }
    }
  }
  return lines
})

const formData = ref({
  job_description: '', target_role: '', experience_level: 'mid',
  company_name: '', hiring_manager: '', tone: 'professional',
  length: 'medium', industry: '', instructions: '', project_link: ''
})

const meaningfulCharCount = computed(() => formData.value.job_description.trim().replace(/\s+/g, ' ').length)
const isOverLimit = computed(() => formData.value.job_description.length > MAX_JD_CHARS || formData.value.instructions.length > MAX_INSTRUCTIONS_CHARS)

const isReady = computed(() => {
  if (isOverLimit.value) return false
  if (['tailor_to_job', 'optimize', 'generate_cover_letter'].includes(props.actionType)) return meaningfulCharCount.value >= 50
  if (props.actionType === 'optimize_project') {
    const p = selectedProject.value
    if (!p) return false
    return !!(p.projectName?.trim() || p.technologies?.trim() || p.description?.trim())
  }
  if (props.actionType === 'rewrite_experience') {
    const e = selectedExperience.value
    if (!e) return false
    return !!(e.company?.trim() || e.role?.trim() || e.description?.trim())
  }
  if (['rewrite', 'expand', 'shorten'].includes(props.actionType)) {
    return !!selectedBulletText.value?.trim()
  }
  return true
})

watch(() => props.modelValue, (newVal) => {
  if (!newVal) return
  projectValidationError.value = ''
  experienceValidationError.value = ''
  if (props.actionType === 'optimize_project') {
    step.value = props.projects.length > 1 ? 1 : 2
    selectedProjectId.value = props.projects[0]?.id || ''
    selectedProjectField.value = 'description'
    selectedProjectAction.value = descriptionDefaultAction.value
  } else if (props.actionType === 'rewrite_experience') {
    step.value = props.experiences.length > 1 ? 1 : 2
    selectedExperienceId.value = props.experiences[0]?.id || ''
  } else if (['rewrite', 'expand', 'shorten'].includes(props.actionType)) {
    step.value = props.experiences.length > 1 ? 1 : 2
    selectedExperienceId.value = props.experiences[0]?.id || ''
    selectedBulletText.value = selectedExperienceBullets.value[0] || ''
  } else {
    step.value = 2
  }
  formData.value = { job_description: '', target_role: '', experience_level: 'mid', company_name: '', hiring_manager: '', tone: 'professional', length: 'medium', industry: '', instructions: '', project_link: '' }
})

watch(selectedProjectField, field => {
  if (field === 'description') selectedProjectAction.value = descriptionDefaultAction.value
  else if (field === 'technologies') selectedProjectAction.value = technologiesDefaultAction.value
})

watch(selectedProjectId, () => {
  if (selectedProjectField.value === 'description') selectedProjectAction.value = descriptionDefaultAction.value
  else if (selectedProjectField.value === 'technologies') selectedProjectAction.value = technologiesDefaultAction.value
})

watch(selectedExperienceId, () => {
  if (['rewrite', 'expand', 'shorten'].includes(props.actionType)) {
    selectedBulletText.value = selectedExperienceBullets.value[0] || ''
  }
})

const title = computed(() => {
  const map = {
    tailor_to_job: 'Tailor Resume to Job',
    optimize: 'Tailor Resume to Job',
    generate_cover_letter: 'Generate Cover Letter',
    generate_linkedin: 'Optimize LinkedIn Profile',
    generate_summary: 'Generate Professional Summary',
    rewrite_experience: 'Improve Work Experience',
    ats_booster: 'ATS Keyword Booster',
    optimize_project: 'Project AI',
    rewrite: 'Rewrite Bullet Point',
    expand: 'Expand Bullet Point',
    shorten: 'Shorten Bullet Point'
  }
  return map[props.actionType] || 'AI Optimization'
})

const description = computed(() => {
  if (props.actionType === 'tailor_to_job') return 'Provide the job description you are targeting, and our AI will rewrite your resume to perfectly align with the requirements.'
  if (props.actionType === 'generate_cover_letter') return 'Enter details about the company and role to generate a personalized, highly-converting cover letter.'
  if (props.actionType === 'generate_linkedin') return 'We will craft a compelling LinkedIn headline and About section optimized for recruiter search.'
  if (props.actionType === 'optimize_project') return 'Choose what to improve. AI will only update the selected field — nothing else changes.'
  if (props.actionType === 'rewrite_experience') return 'Choose which experience to rewrite. AI will only update the description field — company names, titles, and dates will not be touched.'
  if (props.actionType === 'rewrite') return 'Rewrite a single bullet point to be more professional, impactful, and results-oriented.'
  if (props.actionType === 'expand') return 'Expand a single bullet point with more detail and action verbs.'
  if (props.actionType === 'shorten') return 'Shorten a single bullet point to be more concise.'
  return 'Customize how the AI should optimize your content.'
})

function close() { emit('update:modelValue', false) }

function nextStep() {
  projectValidationError.value = ''
  experienceValidationError.value = ''
  
  if (props.actionType === 'optimize_project') {
    const p = selectedProject.value
    if (!p || (!p.projectName?.trim() && !p.technologies?.trim() && !p.description?.trim())) {
      projectValidationError.value = 'Please add a project title, technologies, or description first.'
      return
    }
  } else if (props.actionType === 'rewrite_experience' || ['rewrite', 'expand', 'shorten'].includes(props.actionType)) {
    const e = selectedExperience.value
    if (!e || (!e.company?.trim() && !e.role?.trim() && !e.description?.trim())) {
      experienceValidationError.value = 'Please add a company name, job title, or description first.'
      return
    }
  }
  step.value = 2
}

function submit() {
  let instructions = formData.value.instructions || ''
  if (props.actionType === 'generate_cover_letter') instructions = `Company: ${formData.value.company_name}. Hiring Manager: ${formData.value.hiring_manager}. Tone: ${formData.value.tone}. Length: ${formData.value.length}. JD: ${formData.value.job_description}`
  else if (props.actionType === 'generate_linkedin') instructions = `Target Role: ${formData.value.target_role}. Industry: ${formData.value.industry}.`

  const payload = { ...formData.value, instructions }
  if (props.actionType === 'optimize_project') {
    payload.project_id = selectedProjectId.value || (props.projects[0]?.id || 0)
    payload.project_field = selectedProjectField.value
    payload.project_action = selectedProjectAction.value
  } else if (props.actionType === 'rewrite_experience') {
    payload.experience_id = selectedExperienceId.value || (props.experiences[0]?.id || 0)
  } else if (['rewrite', 'expand', 'shorten'].includes(props.actionType)) {
    payload.experience_id = selectedExperienceId.value || (props.experiences[0]?.id || 0)
    payload.bullet_text = selectedBulletText.value
  }
  emit('submit', payload)
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
@keyframes fadeIn { from { opacity: 0; } to { opacity: 1; } }

.modal-content {
  background: rgb(var(--color-surface));
  border-radius: 1.5rem;
  width: 90%;
  max-width: 600px;
  max-height: 90vh;
  overflow-y: auto;
  box-shadow: 0 20px 40px rgba(0,0,0,0.1);
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
.icon-wrap { width: 40px; height: 40px; background: rgba(99, 102, 241, 0.1); border-radius: 12px; display: flex; align-items: center; justify-content: center; }
.size-6 { width: 1.5rem; height: 1.5rem; }
.text-primary { color: rgb(var(--color-primary)); }
.modal-header h2 { margin: 0; font-size: 1.25rem; font-weight: 700; color: rgb(var(--color-text-primary)); }
.btn-close { position: absolute; right: 1.5rem; top: 1.5rem; background: none; border: none; font-size: 1.5rem; color: rgb(var(--color-text-muted)); cursor: pointer; transition: color 0.2s; }
.btn-close:hover { color: rgb(var(--color-text-primary)); }

.modal-body { padding: 2rem; }
.description { margin: 0 0 1.5rem 0; color: rgb(var(--color-text-secondary)); font-size: 0.95rem; line-height: 1.5; }

.form-group { margin-bottom: 1.25rem; display: flex; flex-direction: column; gap: 0.5rem; }
.form-group:last-child { margin-bottom: 0; }
.form-row { display: flex; gap: 1rem; }
.form-row .form-group { flex: 1; }

label { font-size: 0.875rem; font-weight: 600; color: rgb(var(--color-text-primary)); }
input, textarea, select { padding: 0.75rem 1rem; border: 1px solid rgb(var(--color-border)); border-radius: 0.75rem; background: rgb(var(--color-surface-hover)); color: rgb(var(--color-text-primary)); font-family: inherit; font-size: 0.95rem; transition: all 0.2s; }
input:focus, textarea:focus, select:focus { outline: none; border-color: rgb(var(--color-primary)); box-shadow: 0 0 0 3px rgba(99, 102, 241, 0.1); background: rgb(var(--color-surface)); }
textarea { resize: vertical; }

.modal-footer { padding: 1.5rem 2rem; background: rgb(var(--color-surface-hover)); border-top: 1px solid rgb(var(--color-border)); display: flex; justify-content: flex-end; gap: 1rem; }
.btn-secondary { padding: 0.75rem 1.5rem; background: rgb(var(--color-surface)); border: 1px solid rgb(var(--color-border)); border-radius: 0.75rem; font-weight: 600; color: rgb(var(--color-text-primary)); cursor: pointer; }
.btn-secondary:hover { background: rgb(var(--color-surface-elevated)); }
.btn-primary { padding: 0.75rem 1.5rem; background: linear-gradient(135deg, rgb(var(--color-primary)), #8b5cf6); border: none; border-radius: 0.75rem; font-weight: 600; color: white; cursor: pointer; transition: all 0.2s; box-shadow: 0 4px 12px rgba(99, 102, 241, 0.3); }
.btn-primary:hover:not(:disabled) { transform: translateY(-1px); box-shadow: 0 6px 16px rgba(99, 102, 241, 0.4); }
.btn-primary:disabled { opacity: 0.5; cursor: not-allowed; box-shadow: none; }

.credit-info-box { background: rgba(99, 102, 241, 0.05); border: 1px solid rgba(99, 102, 241, 0.15); border-radius: 1rem; padding: 1.25rem; }
.credit-cost-main { display: flex; align-items: center; justify-content: space-between; margin-bottom: 0.75rem; padding-bottom: 0.75rem; border-bottom: 1px dashed rgba(99, 102, 241, 0.2); }
.cost-label { font-weight: 600; color: rgb(var(--color-text-primary)); }
.cost-value { font-weight: 700; color: rgb(var(--color-primary)); font-size: 1.1rem; }
.credit-details { display: flex; justify-content: space-between; font-size: 0.85rem; color: rgb(var(--color-text-secondary)); margin-bottom: 0.75rem; }
.detail-label { font-weight: 500; }
.credit-policy { margin: 0; font-size: 0.8rem; color: rgb(var(--color-text-muted)); text-align: center; background: rgb(var(--color-surface)); padding: 0.5rem; border-radius: 0.5rem; }

.label-row { display: flex; justify-content: space-between; align-items: center; }
.char-counter { font-size: 0.8rem; color: rgb(var(--color-text-muted)); }
.text-danger { color: rgb(var(--color-danger, 239, 68, 68)); font-weight: 600; }
.text-secondary { color: rgb(var(--color-text-secondary)); }
.helper-message { font-size: 0.8rem; }
.text-success { color: rgb(var(--color-success, 16, 185, 129)); }
.font-semibold { font-weight: 600; }
.mt-1 { margin-top: 0.25rem; }
.mb-4 { margin-bottom: 1rem; }
.font-bold { font-weight: 700; }

.insufficient-credits-state { text-align: center; padding: 2rem 1rem; }
.icon-wrap-error { width: 64px; height: 64px; background: rgba(239, 68, 68, 0.1); color: rgb(var(--color-danger, 239, 68, 68)); border-radius: 50%; display: flex; align-items: center; justify-content: center; margin: 0 auto 1.5rem auto; }
.icon-wrap-error svg { width: 32px; height: 32px; }
.insufficient-credits-state h3 { margin: 0 0 1rem 0; font-size: 1.5rem; color: rgb(var(--color-text-primary)); }
.insufficient-credits-state p { color: rgb(var(--color-text-secondary)); margin-bottom: 0.5rem; }
.current-balance { font-size: 1.1rem; }
.error-actions { display: flex; justify-content: center; gap: 1rem; }

/* Project selector */
.project-selector-list { display: flex; flex-direction: column; gap: 0.75rem; }
.project-selector-item { display: flex; align-items: center; gap: 1rem; padding: 1rem; border: 1px solid rgb(var(--color-border)); border-radius: 0.75rem; background: rgb(var(--color-surface-hover)); cursor: pointer; transition: all 0.2s ease; }
.project-selector-item:hover { border-color: rgb(var(--color-primary)); background: rgb(var(--color-surface-elevated)); }
.project-selector-item.active { border-color: rgb(var(--color-primary)); background: rgba(99, 102, 241, 0.05); box-shadow: 0 0 0 3px rgba(99, 102, 241, 0.1); }
.radio-input { width: 1.25rem; height: 1.25rem; accent-color: rgb(var(--color-primary)); }
.project-info { display: flex; flex-direction: column; }
.project-name { font-weight: 600; color: rgb(var(--color-text-primary)); }
.project-tech { font-size: 0.85rem; color: rgb(var(--color-text-secondary)); }

/* Selected project preview */
.selected-project-preview { padding: 0.75rem 1rem; background: rgb(var(--color-surface-hover)); border: 1px solid rgb(var(--color-border)); border-radius: 0.75rem; display: flex; justify-content: space-between; align-items: center; }
.selected-project-preview .label { font-size: 0.875rem; color: rgb(var(--color-text-secondary)); }
.selected-project-preview .value { font-size: 0.875rem; color: rgb(var(--color-text-primary)); }

/* Option grid — simplified 2-column */
.option-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 0.75rem; }
.option-card { display: flex; align-items: flex-start; gap: 0.75rem; padding: 1rem; border: 1px solid rgb(var(--color-border)); border-radius: 0.75rem; background: rgb(var(--color-surface-hover)); cursor: pointer; transition: all 0.2s ease; }
.option-card:hover, .option-card.active { border-color: rgb(var(--color-primary)); background: rgba(99, 102, 241, 0.05); }
.option-card-inner { display: flex; flex-direction: column; gap: 0.2rem; }
.option-label { font-size: 0.9rem; font-weight: 700; color: rgb(var(--color-text-primary)); }
.option-hint { font-size: 0.78rem; color: rgb(var(--color-text-secondary)); line-height: 1.3; }

/* Field notice */
.field-notice { display: flex; gap: 0.75rem; padding: 0.875rem 1rem; background: rgba(99, 102, 241, 0.05); border: 1px solid rgba(99, 102, 241, 0.2); border-radius: 0.75rem; align-items: flex-start; }
.field-notice .notice-icon { font-size: 1.2rem; line-height: 1; margin-top: 0.1rem; }
.field-notice .notice-text { font-size: 0.875rem; color: rgb(var(--color-text-secondary)); line-height: 1.5; }
.field-notice .notice-text strong { color: rgb(var(--color-text-primary)); }

.validation-error-message { font-size: 0.85rem; font-weight: 500; }

/* Empty state notice */
.empty-state-notice { display: flex; gap: 0.75rem; padding: 1rem 1.25rem; background: rgba(245, 158, 11, 0.06); border: 1px solid rgba(245, 158, 11, 0.25); border-radius: 0.75rem; align-items: flex-start; }
.empty-state-notice .notice-icon { font-size: 1.5rem; line-height: 1; margin-top: 0.1rem; }
.empty-state-notice .notice-text { font-size: 0.875rem; color: rgb(var(--color-text-secondary)); line-height: 1.6; }
.empty-state-notice .notice-text strong { color: rgb(var(--color-text-primary)); }

/* Skills quick prompts */
.skills-hint-label { font-size: 0.875rem; font-weight: 600; color: rgb(var(--color-text-primary)); margin: 0; }
.skills-chip-grid { display: flex; flex-wrap: wrap; gap: 0.5rem; }
.skill-chip {
  padding: 0.375rem 0.875rem;
  background: rgb(var(--color-surface-hover));
  border: 1px solid rgb(var(--color-border));
  border-radius: 2rem;
  font-size: 0.78rem;
  font-weight: 600;
  color: rgb(var(--color-text-secondary));
  cursor: pointer;
  transition: all 0.15s ease;
}
.skill-chip:hover {
  border-color: rgb(var(--color-primary));
  color: rgb(var(--color-primary));
  background: rgba(99, 102, 241, 0.06);
}
.skill-chip.active {
  border-color: rgb(var(--color-primary));
  background: rgba(99, 102, 241, 0.1);
  color: rgb(var(--color-primary));
  box-shadow: 0 0 0 2px rgba(99, 102, 241, 0.15);
}
/* Skills intent notice (reuse field-notice style) */
.skills-intent-notice { display: flex; gap: 0.75rem; padding: 0.75rem 1rem; background: rgba(16, 185, 129, 0.05); border: 1px solid rgba(16, 185, 129, 0.2); border-radius: 0.75rem; align-items: flex-start; }
.skills-intent-notice .notice-icon { font-size: 1.1rem; line-height: 1; margin-top: 0.1rem; }
.skills-intent-notice .notice-text { font-size: 0.82rem; color: rgb(var(--color-text-secondary)); line-height: 1.5; }
.skills-intent-notice .notice-text strong { color: rgb(var(--color-text-primary)); }
.mt-3 { margin-top: 0.75rem; }
.mb-2 { margin-bottom: 0.5rem; }

.premium-info-box {
  background: linear-gradient(135deg, rgba(99, 102, 241, 0.08), rgba(139, 92, 246, 0.08));
  border: 1px solid rgba(139, 92, 246, 0.3) !important;
}

.premium-badge-tag {
  display: inline-flex;
  align-items: center;
  gap: 0.375rem;
  background: linear-gradient(135deg, rgb(var(--color-primary)), #8b5cf6);
  color: white;
  font-size: 0.75rem;
  font-weight: 700;
  padding: 0.25rem 0.625rem;
  border-radius: 9999px;
  text-transform: uppercase;
  letter-spacing: 0.05em;
  box-shadow: 0 2px 6px rgba(139, 92, 246, 0.2);
}

.premium-badge-tag svg {
  animation: shine 2s infinite linear;
}

.premium-cost-value {
  color: #8b5cf6 !important;
  font-size: 1.25rem !important;
  text-shadow: 0 0 10px rgba(139, 92, 246, 0.1);
}

.premium-features-list {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
  padding: 0.75rem;
  background: rgba(255, 255, 255, 0.4);
  border-radius: 0.75rem;
  border: 1px solid rgba(139, 92, 246, 0.1);
}

/* Dark mode compatibility */
@media (prefers-color-scheme: dark) {
  .premium-features-list {
    background: rgba(0, 0, 0, 0.2);
  }
}

.premium-feature-item {
  display: flex;
  align-items: flex-start;
  gap: 0.5rem;
  font-size: 0.85rem;
  color: rgb(var(--color-text-primary));
}

.premium-feature-item svg.feature-check {
  width: 1rem;
  height: 1rem;
  color: #10b981;
  flex-shrink: 0;
  margin-top: 0.15rem;
}

@keyframes shine {
  0% { transform: scale(1); }
  50% { transform: scale(1.1); }
  100% { transform: scale(1); }
}

@media (max-width: 767px) {
  .modal-backdrop {
    padding: 16px;
    align-items: center;
  }
  
  .modal-content {
    width: 100%;
    max-height: 88vh;
    display: flex;
    flex-direction: column;
    border-radius: 1rem;
    overflow: hidden;
  }

  .modal-header {
    padding: 0.75rem 1rem;
    flex-shrink: 0;
    gap: 0.75rem;
    border-bottom: 1px solid rgb(var(--color-border));
  }
  
  .modal-header .icon-wrap {
    width: 32px;
    height: 32px;
    border-radius: 8px;
  }
  .modal-header .icon-wrap svg {
    width: 1.15rem;
    height: 1.15rem;
  }
  
  .modal-header h2 {
    font-size: 1.05rem; /* ~17px */
    font-weight: 700;
  }
  
  .btn-close {
    right: 0.5rem;
    top: 0.5rem;
    width: 36px;
    height: 36px;
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 1.25rem;
  }

  .modal-body {
    padding: 1rem;
    overflow-y: auto;
    flex: 1;
    -webkit-overflow-scrolling: touch;
  }
  
  .description {
    margin-bottom: 0.75rem;
    font-size: 0.8125rem; /* 13px */
    line-height: 1.4;
  }

  .modal-body label {
    font-size: 0.8125rem; /* 13px */
  }
  
  .helper-message {
    font-size: 0.75rem; /* 12px */
  }
  
  .char-counter {
    font-size: 0.75rem; /* 12px */
  }

  .form-group {
    margin-bottom: 0.75rem;
    gap: 0.25rem;
  }
  
  .form-row {
    gap: 0.5rem;
  }
  
  input, select {
    height: 40px; /* inputs compact */
    padding: 0 0.75rem;
    font-size: 0.8125rem;
    border-radius: 0.5rem;
  }
  
  textarea {
    max-height: 110px; /* max 120px */
    padding: 0.5rem 0.75rem;
    font-size: 0.8125rem;
    border-radius: 0.5rem;
  }

  /* Credit Box: compact 2-column info card layout */
  .credit-info-box {
    padding: 0.625rem 0.75rem;
    border-radius: 0.75rem;
    margin-bottom: 0.75rem;
  }
  
  .credit-cost-main {
    flex-direction: row;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 0.5rem;
    padding-bottom: 0.5rem;
  }
  
  .cost-label {
    font-size: 0.75rem; /* 12px */
    font-weight: 500;
  }
  
  .cost-value {
    font-size: 0.8125rem; /* ~13px */
    font-weight: 700;
  }
  
  .credit-details {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 0.5rem;
    margin-bottom: 0.5rem;
  }
  
  .detail-item {
    background: rgba(var(--color-surface-hover), 0.5);
    border: 1px solid rgb(var(--color-border));
    padding: 0.25rem 0.5rem;
    border-radius: 0.5rem;
    display: flex;
    flex-direction: column;
    align-items: center;
    text-align: center;
    gap: 0.125rem;
    font-size: 0.75rem;
  }
  
  .detail-label {
    font-size: 0.6875rem;
    color: rgb(var(--color-text-muted));
    font-weight: 600;
    text-transform: uppercase;
  }

  .credit-policy {
    font-size: 0.75rem;
    padding: 0.375rem 0.5rem;
    border-radius: 0.5rem;
    background: rgba(var(--color-primary), 0.05);
    border: 1px solid rgba(99, 102, 241, 0.1);
    color: rgb(var(--color-text-muted));
    text-align: left;
    margin: 0;
    line-height: 1.3;
    display: flex;
    align-items: flex-start;
    gap: 0.25rem;
  }
  .credit-policy::before {
    content: "ℹ";
    font-weight: 700;
    color: rgb(var(--color-primary));
  }

  .premium-features-list {
    padding: 0.5rem;
    gap: 0.375rem;
    border-radius: 0.5rem;
    margin-bottom: 0.75rem;
  }
  .premium-feature-item {
    font-size: 0.75rem;
  }

  .project-selector-list {
    gap: 0.5rem;
  }
  .project-selector-item {
    padding: 0.625rem 0.75rem;
    border-radius: 0.5rem;
    gap: 0.5rem;
  }
  .project-name {
    font-size: 0.8125rem;
  }
  .project-tech {
    font-size: 0.75rem;
  }
  .selected-project-preview {
    padding: 0.5rem 0.75rem;
    border-radius: 0.5rem;
    margin-bottom: 0.5rem;
  }
  .selected-project-preview .label, .selected-project-preview .value {
    font-size: 0.75rem;
  }

  .option-grid {
    gap: 0.5rem;
  }
  .option-card {
    padding: 0.625rem 0.75rem;
    border-radius: 0.5rem;
    gap: 0.5rem;
  }
  .option-label {
    font-size: 0.8125rem;
  }
  .option-hint {
    font-size: 0.75rem;
  }

  .field-notice, .empty-state-notice, .skills-intent-notice {
    padding: 0.5rem 0.75rem;
    border-radius: 0.5rem;
    margin-bottom: 0.5rem;
    gap: 0.5rem;
  }
  .field-notice .notice-icon, .empty-state-notice .notice-icon, .skills-intent-notice .notice-icon {
    font-size: 1rem;
  }
  .field-notice .notice-text, .empty-state-notice .notice-text, .skills-intent-notice .notice-text {
    font-size: 0.75rem;
    line-height: 1.4;
  }

  .skills-chip-grid {
    gap: 0.375rem;
  }
  .skill-chip {
    padding: 0.25rem 0.75rem;
    font-size: 0.75rem;
  }

  /* Footer: fixed / sticky and compact */
  .modal-footer {
    padding: 0.75rem 1rem;
    flex-shrink: 0;
    gap: 0.5rem;
    display: flex;
    background: rgb(var(--color-surface-hover));
    border-top: 1px solid rgb(var(--color-border));
  }
  .modal-footer button {
    flex: 1;
    height: 40px;
    padding: 0;
    border-radius: 10px;
    font-size: 0.8125rem;
    display: flex;
    align-items: center;
    justify-content: center;
    margin: 0;
  }
  
  .error-actions {
    gap: 0.5rem;
    margin-top: 0.75rem;
  }
  .error-actions button {
    flex: 1;
    height: 40px;
    border-radius: 10px;
    font-size: 0.8125rem;
  }
}
</style>
