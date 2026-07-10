<template>
  <div class="optimization-dashboard">
    <!-- UI Components -->
    
    <AiWorkflowModal 
      v-model="showWorkflowModal" 
      :actionType="currentAction"
      :creditCost="getCreditCost(currentAction)"
      :remainingCredits="remainingCredits"
      :projects="projects"
      :experiences="experiences"
      @submit="startOptimization" 
    />
    
    <AiLoadingOverlay 
      v-model="showLoadingOverlay" 
      :actionType="currentAction" 
    />
    
    <AiResultPreview 
      v-model="showResultPreview" 
      :oldContent="oldContent" 
      :newContent="newContent" 
      :actionType="currentAction"
      :creditCost="getCreditCost(currentAction)"
      :remainingCredits="remainingCredits"
      :aiStats="aiStats"
      :resume="resume"
      @apply="applyOptimization" 
      @discard="discardOptimization" 
    />

    <AiErrorModal
      v-model="showErrorModal"
      :title="errorModalTitle"
      :message="errorModalMessage"
    />

    <!-- Main Content -->
    <div v-if="loading" class="dashboard-loading">
      <div class="skeleton-hero"></div>
      <div class="skeleton-grid">
        <div class="skeleton-card" v-for="i in 4" :key="i"></div>
      </div>
      <div class="loading-text">Analyzing your resume for premium insights...</div>
    </div>

    <div v-else-if="!scoreData" class="dashboard-empty">
      <div class="placeholder-icon-wrap">
        <svg class="placeholder-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M13 10V3L4 14h7v7l9-11h-7z"/></svg>
      </div>
      <h2>AI Resume Optimization</h2>
      <p>Unlock the full potential of your resume. Our AI will analyze your content, keywords, and ATS formatting to help you land more interviews.</p>
      <button class="btn-primary btn-large" @click="analyze" :disabled="analyzing">
        <svg v-if="analyzing" class="spin size-5 mr-2" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M21 12a9 9 0 11-6.219-8.56"/></svg>
        <span v-if="analyzing">Running Analysis...</span>
        <span v-else>Start AI Analysis</span>
      </button>
    </div>

    <div v-else class="dashboard-content">
      <!-- Section 1: Hero Card -->
      <HeroScoreCard
        v-if="!mobileTab || mobileTab === 'overview'"
        class="mb-8"
        :score="displayedScore"
        :atsSuccess="scoreData.ats_score || 0"
        :completion="scoreData.completeness_score || 0"
        :issues="totalIssues"
        :potentialGain="potentialGain"
        :lastAnalyzed="formatDate(scoreData.last_analyzed_at)"
        :loading="analyzing"
        @analyze="analyze"
        @optimize="openWorkflow('optimize')"
      />

      <!-- Section 6: Optimization Progress -->
      <ProgressCard
        v-if="!mobileTab || mobileTab === 'insights'"
        class="mb-10"
        :progress="displayedScore"
        :remainingIssues="totalIssues"
        :estimatedFinal="Math.min(100, displayedScore + potentialGain)"
        :potentialIncrease="potentialGain"
      />

      <!-- Section 2: Score Cards -->
      <div v-if="!mobileTab || mobileTab === 'insights'" class="section-block mb-10">
        <h2 class="section-title">Score Breakdown</h2>
        <div class="score-cards-grid">
          <ScoreCard
            title="ATS Formatting"
            :score="scoreData.ats_score || 0"
            description="How well applicant tracking systems can read your resume."
            strength="Clean structural hierarchy detected."
            weakness="Missing some standard industry headers."
            recommendation="Standardize your headers to ensure ATS parsers do not skip your experience."
            :estimatedGain="5"
          />
          <ScoreCard
            title="Content Quality"
            :score="scoreData.content_score || 0"
            description="The impact and clarity of your bullet points."
            strength="Action verbs are used frequently at the start of bullets."
            weakness="Lacking quantifiable metrics to demonstrate scale."
            recommendation="Add specific numbers (revenue, team size, percentages) to at least 3 bullet points."
            :estimatedGain="12"
          />
          <ScoreCard
            title="Keywords"
            :score="scoreData.keyword_score || 0"
            description="Industry-specific terms and skills found."
            strength="Strong presence of core technical skills."
            weakness="Missing role-specific soft skills and leadership terms."
            recommendation="Include words like 'mentored', 'led', or 'collaborated' based on your target role."
            :estimatedGain="8"
          />
          <ScoreCard
            title="Completeness"
            :score="scoreData.completeness_score || 0"
            description="Presence of all critical resume sections."
            strength="Experience and Education sections are well populated."
            weakness="Professional summary is slightly short."
            recommendation="Expand your summary to clearly state your career objective and value proposition."
            :estimatedGain="3"
          />
        </div>
      </div>

      <div class="dashboard-main-grid" v-if="!mobileTab || mobileTab === 'review' || mobileTab === 'insights'">
        <div class="main-column">
          <!-- Section 3 & 4: Priority Issues & Quick Wins -->
          <div v-if="!mobileTab && hasActionableInsights" class="section-block mb-10">
            <h2 class="section-title">Actionable Insights</h2>
            
            <div class="issues-list">
              <IssueCard
                v-if="!hasSummary && !dismissedIssues.includes('summary')"
                title="Professional Summary Missing"
                description="Your resume is missing a professional summary at the top."
                whyItMatters="Recruiters spend only a few seconds reviewing resumes. Without a summary, your profile lacks immediate context and narrative."
                priority="HIGH"
                :gain="8"
                time="1 min"
                primaryActionLabel="Generate Summary"
                @fix="openWorkflow('generate_summary')"
                @dismiss="handleDismiss('summary')"
              />

              <IssueCard
                v-if="!hasExperience && !dismissedIssues.includes('experience_missing')"
                title="Work Experience Missing"
                description="Your resume has no work experience entries."
                whyItMatters="Experience is the most critical part of a resume for demonstrating your capabilities to recruiters."
                priority="HIGH"
                :gain="30"
                time="5 mins"
                primaryActionLabel="Add Experience"
                @fix="navigateToExperience"
                @dismiss="handleDismiss('experience_missing')"
              />

            </div>
          </div>

          <!-- Section 5: Section Health -->
          <div class="section-block" v-if="!mobileTab || mobileTab === 'review'">
            <h2 class="section-title">Section Health</h2>
            <div class="health-cards-list">
              <SectionHealthCard
                title="Professional Summary"
                :progress="summaryProgress"
                :issues="summaryIssues"
                :suggestions="summarySuggestions"
                :stats="summaryStats"
                :isOptimized="summaryRaw?.status === 'complete'"
                aiRecommendation="Let our AI scan your entire work history to craft a compelling 3-sentence summary tailored to your target industry."
                :estimatedGain="8"
                @improve="openWorkflow('generate_summary')"
              />
              <SectionHealthCard
                title="Work Experience"
                :progress="experienceProgress"
                :issues="experienceIssues"
                :suggestions="experienceSuggestions"
                :stats="experienceStats"
                :isOptimized="experienceRaw?.status === 'complete'"
                :aiRecommendation="experienceAiRec"
                :buttonText="experienceButtonText"
                :estimatedGain="12"
                @improve="openWorkflow('rewrite_experience')"
              />
              <SectionHealthCard
                title="Skills"
                :progress="skillsProgress"
                :issues="skillsIssues"
                :suggestions="skillsSuggestions"
                :stats="skillsStats"
                :isOptimized="skillsRaw?.status === 'complete'"
                :aiRecommendation="skillsAiRec"
                :estimatedGain="8"
                @improve="openWorkflow('improve_skills')"
              />
              <SectionHealthCard
                title="Education"
                :progress="educationProgress"
                :issues="educationIssues"
                :suggestions="educationSuggestions"
                :stats="educationStats"
                :isOptimized="educationRaw?.status === 'complete'"
                :validationOnly="true"
              />
              <SectionHealthCard
                title="Projects"
                :progress="projectsProgress"
                :issues="projectsIssues"
                :suggestions="projectsSuggestions"
                :stats="projectsStats"
                :isOptimized="projectsRaw?.status === 'complete'"
                :aiRecommendation="projectsAiRec"
                :estimatedGain="10"
                :buttonText="projectsButtonText"
                @improve="onImproveProjects"
              />
            </div>
          </div>
        </div>

        <div class="sidebar-column" v-if="!mobileTab">
          <!-- Section 8: AI Resume Toolkit -->
          <div class="section-block premium-block mb-10">
            <div class="premium-header">
              <div class="premium-icon">
                <svg class="size-6 text-primary" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M5 3v4M3 5h4M6 17v4m-2-2h4m5-16l2.286 6.857L21 12l-5.714 2.143L13 21l-2.286-6.857L5 12l5.714-2.143L13 3z"/></svg>
              </div>
              <h2 class="section-title mb-0">AI Resume Toolkit</h2>
            </div>
            <p class="toolkit-desc">Unlock advanced AI tools to perfect every aspect of your professional profile.</p>
            
            <div class="ai-actions-list">
              <OptimizationActionCard
                title="Tailor to Job Description"
                description="Paste a job description and AI will optimize your keywords and rewrite bullets to match perfectly."
                :actions="[{type:'tailor_to_job', label:'Optimize for Job', credits: getCreditCost('tailor_to_job')}]"
                @action="openWorkflow"
              />
              <OptimizationActionCard
                v-slot:default
                v-if="false"
                title="Bullet Point Enhancer"
                description="Transform weak duties into powerful achievement statements."
                :actions="[
                  {type:'rewrite', label:'Rewrite', credits: getCreditCost('rewrite')},
                  {type:'expand', label:'Expand', credits: getCreditCost('expand')},
                  {type:'shorten', label:'Shorten', credits: getCreditCost('shorten')}
                ]"
                @action="openWorkflow"
              />
              <OptimizationActionCard
                title="Cover Letter Generator"
                description="Generate a highly personalized cover letter based on this resume."
                :actions="[{type:'generate_cover_letter', label:'Generate Cover Letter', credits: getCreditCost('generate_cover_letter')}]"
                @action="openWorkflow"
              />
              <OptimizationActionCard
                title="LinkedIn Optimizer"
                description="Get an AI-generated 'About' section and headline tailored for LinkedIn."
                :actions="[{type:'generate_linkedin', label:'Optimize LinkedIn', credits: getCreditCost('generate_linkedin')}]"
                @action="openWorkflow"
              />
              <OptimizationActionCard
                v-if="false"
                title="ATS Keyword Booster"
                description="Automatically inject missing high-value industry keywords naturally."
                :actions="[{type:'ats_booster', label:'Boost Keywords', credits: getCreditCost('ats_booster')}]"
                @action="openWorkflow"
              />
              <OptimizationActionCard
                v-if="false"
                title="Resume Translator"
                description="Translate your entire resume into another language flawlessly."
                :actions="[{type:'translator', label:'Translate', credits: getCreditCost('translator')}]"
                @action="openWorkflow"
              />
            </div>
          </div>

          <!-- Section: AI Credit Information -->
          <div class="section-block timeline-block mb-10">
            <h2 class="section-title">AI Credits</h2>
            <div class="credit-stats">
              <div class="stat-row">
                <span class="stat-label">Available</span>
                <span class="stat-value text-primary font-bold">{{ remainingCredits }}</span>
              </div>
              <div class="stat-row">
                <span class="stat-label">Today's Usage</span>
                <span class="stat-value">{{ creditStats.todays_usage }} Credits</span>
              </div>
              <div class="stat-row">
                <span class="stat-label">This Resume</span>
                <span class="stat-value">{{ creditHistory.length }} Optimizations</span>
              </div>
            </div>
            <button class="btn-text mt-4 w-full" @click="$router.push('/settings/billing')">Buy More Credits &rarr;</button>
          </div>

          <!-- Section: Recent AI Usage -->
          <div class="section-block timeline-block">
            <h2 class="section-title">Recent AI Usage</h2>
            <div class="timeline" v-if="creditHistory.length > 0">
              <div class="timeline-item" v-for="act in creditHistory" :key="act.id">
                <div class="tl-dot"></div>
                <div class="tl-content">
                  <div class="tl-title">{{ act.feature_name }} <span class="action-credits">({{ act.credits_used }} Credits)</span></div>
                  <div class="tl-time text-success" v-if="act.action === 'deduct'">Success • {{ formatDate(act.created_at) }}</div>
                  <div class="tl-time text-success" v-else>Refund • {{ formatDate(act.created_at) }}</div>
                </div>
              </div>
            </div>
            <div v-else class="text-sm text-muted mt-2">No recent usage found.</div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, nextTick, watch } from 'vue'
import { useStore } from 'vuex'
import { useRouter } from 'vue-router'
import http from '../../services/http'
import HeroScoreCard from '../../components/optimization/HeroScoreCard.vue'
import ScoreCard from '../../components/optimization/ScoreCard.vue'
import IssueCard from '../../components/optimization/IssueCard.vue'
import SectionHealthCard from '../../components/optimization/SectionHealthCard.vue'
import ProgressCard from '../../components/optimization/ProgressCard.vue'
import OptimizationActionCard from '../../components/optimization/OptimizationActionCard.vue'
import Notification from '../../services/notification'
import buildSuccessMessage from '../../utils/successMessageBuilder'

// Modals
import AiWorkflowModal from '../../components/optimization/AiWorkflowModal.vue'
import AiLoadingOverlay from '../../components/optimization/AiLoadingOverlay.vue'
import AiResultPreview from '../../components/optimization/AiResultPreview.vue'
import AiErrorModal from '../../components/optimization/AiErrorModal.vue'

const props = defineProps({
  resumeId: { type: [String, Number], required: true },
  resume: { type: Object, default: null },
  mobileTab: { type: String, default: null }
})

const emit = defineEmits(['update-resume'])

const router = useRouter()

const projects = computed(() => props.resume?.content?.projects || [])
const experiences = computed(() => props.resume?.content?.experiences || [])

const loading = ref(false)
const analyzing = ref(false)
const scoreData = ref(null)
const dismissedIssuesKey = `resume_${props.resumeId}_dismissed`
const dismissedIssues = ref(JSON.parse(localStorage.getItem(dismissedIssuesKey) || '[]'))

const store = useStore()
const aiFeatures = computed(() => store.state.auth.aiFeatures || {})
const remainingCredits = computed(() => store.state.auth.user?.ai_credits_remaining || 0)

function getCreditCost(actionType) {
  const map = {
    'tailor_to_job': 'tailor_resume',
    'optimize': 'tailor_resume',
    'generate_summary': 'resume_summary',
    'rewrite_experience': 'professional_experience_improvement',
    'rewrite': 'resume_rewrite',
    'expand': 'resume_rewrite',
    'shorten': 'resume_rewrite',
    'generate_cover_letter': 'cover_letter',
    'generate_linkedin': 'linkedin_optimizer',
    'ats_booster': 'ats_booster',
    'improve_skills': 'skill_suggestions',
    'translator': 'translator',
    'optimize_project': 'project_optimizer'
  }
  const featureKey = map[actionType] || 'resume_rewrite'
  return aiFeatures.value[featureKey]?.credits || 0
}

// AI Workflow State
const showWorkflowModal = ref(false)
const showLoadingOverlay = ref(false)
const showResultPreview = ref(false)
const showErrorModal = ref(false)
const errorModalTitle = ref('')
const errorModalMessage = ref('')

const currentAction = ref('')
const oldContent = ref('')
const newContent = ref(null)
const mergedContent = ref(null)
const aiStats = ref(null)
const animatedScore = ref(0)
const recentActivities = ref([
  { title: 'Analysis Complete', time: 'Just now' },
  { title: 'Resume Created', time: 'Recent' }
])
const creditHistory = ref([])
const creditStats = ref({ available: 0, todays_usage: 0 })

const hasSummary = ref(false)
const totalIssues = computed(() => 2 + (hasSummary.value ? 0 : 1))
const hasActionableInsights = computed(() => {
  const showSummary = !hasSummary.value && !dismissedIssues.value.includes('summary')
  const showExperience = !hasExperience.value && !dismissedIssues.value.includes('experience_missing')
  return showSummary || showExperience
})
const potentialGain = computed(() => (scoreData.value?.overall_score || 0) < 100 ? 28 : 0)

// ── Summary quality computed from actual backend analysis ──────────────────
// The backend stores 0-10 raw points for the summary section.
// We multiply by 10 to get a 0-100 progress value for the health card.
const summaryRaw = computed(() => {
  const sec = scoreData.value?.analysis_data?.completeness?.section_results?.summary
  if (!sec) return null
  return sec
})

const summaryProgress = computed(() => {
  if (!hasSummary.value) return 20          // truly missing: stays at 20
  const pts = summaryRaw.value?.points      // 0-10 from quality scorer
  if (pts != null) return Math.min(100, pts * 10)
  // fallback if no analysis yet — derive from status
  const status = summaryRaw.value?.status
  if (status === 'complete') return 80
  if (status === 'weak') return 50
  if (status === 'poor') return 20          // exists but very poor
  return 25
})

const summaryIssues = computed(() => {
  if (!hasSummary.value) return ['Section is missing entirely']
  const reasoning = summaryRaw.value?.reasoning || ''
  if (!reasoning.startsWith('Issues:')) return []
  return reasoning.replace('Issues: ', '').replace(/\.$/, '').split('; ')
})

const summarySuggestions = computed(() => {
  if (!hasSummary.value) return ['Use AI to generate a targeted summary based on your experience']
  const status = summaryRaw.value?.status
  if (status === 'complete') return ['Your summary looks strong. Keep it tailored to each role.']
  return ['Expand your summary to 3-4 sentences', 'Mention your role, key skills, and one achievement']
})

const summaryStats = computed(() => {
  if (!hasSummary.value) {
    return {
      current: 'Missing',
      quality: '–',
      target: 'Professional quality summary'
    }
  }
  const pts = summaryRaw.value?.points ?? 0
  const status = summaryRaw.value?.status
  const qualityLabel = status === 'complete' ? 'Excellent'
    : status === 'weak' ? 'Needs Work'
    : 'Very Weak'
  return {
    current: `Present (${qualityLabel})`,
    quality: `${pts} / 10`,
    target: 'Professional quality summary'
  }
})

// ── Experience quality computed from actual backend analysis ─────────
const hasExperience = ref(true)

const hasExperienceDescription = computed(() => {
  return experiences.value.some(e => e.description && e.description.trim().length > 0)
})

const experienceRaw = computed(() => {
  const sec = scoreData.value?.analysis_data?.completeness?.section_results?.experiences
  if (!sec) return null
  return sec
})

const experienceProgress = computed(() => {
  if (!hasExperience.value) return 20 // missing
  const pts = experienceRaw.value?.points
  if (pts != null) return Math.min(100, Math.round((pts / 30) * 100))
  
  const status = experienceRaw.value?.status
  if (status === 'complete') return 100
  if (status === 'weak') return 50
  return 20
})

const experienceIssues = computed(() => {
  if (!hasExperience.value) return ['Work experience section is missing entirely.', 'No employment history found.']
  const reasoning = experienceRaw.value?.reasoning || ''
  if (!reasoning.startsWith('Issues:')) return []
  return reasoning.replace('Issues: ', '').replace(/\.$/, '').split('; ')
})

const experienceSuggestions = computed(() => {
  if (!hasExperience.value) return [
    'Add at least 2 work experience entries for a stronger resume.',
    'Include company name, job title, dates, key responsibilities, and measurable achievements.'
  ]
  const status = experienceRaw.value?.status
  if (status === 'complete') return ['Your experience is highly detailed and impactful.', 'Maintain this structure for future roles.']
  return ['Ensure bullet points emphasize metrics and business impact', 'Highlight leadership and ownership of projects']
})

const experienceStats = computed(() => {
  if (!hasExperience.value) {
    return {
      current: 'Missing',
      target: 'At least one work experience containing:\n• company\n• role\n• dates\n• measurable achievements'
    }
  }
  
  const pts = experienceRaw.value?.points ?? 0
  const status = experienceRaw.value?.status
  const qualityLabel = status === 'complete' ? 'Excellent'
    : status === 'weak' ? 'Needs Work'
    : 'Critical'

  return {
    current: `Present (${qualityLabel})`,
    quality: `${pts} / 30`,
    target: 'Highly detailed, impact-driven bullet points'
  }
})

const experienceAiRec = computed(() => {
  if (!hasExperience.value) {
    return 'Use AI to generate your first work experience from internships, freelance work, academic projects or real projects.'
  }
  return 'Use AI to automatically improve and optimize your work experience descriptions.'
})

// ── Skills quality computed from actual backend analysis ─────────
const hasSkills = ref(true)

const skillsRaw = computed(() => {
  const sec = scoreData.value?.analysis_data?.completeness?.section_results?.skills
  if (!sec) return null
  return sec
})

const skillsProgress = computed(() => {
  if (!hasSkills.value) return 20 // missing
  const pts = skillsRaw.value?.points
  if (pts != null) return Math.min(100, Math.round((pts / 15) * 100))
  
  const status = skillsRaw.value?.status
  if (status === 'complete') return 100
  if (status === 'weak') return 50
  return 20
})

const skillsIssues = computed(() => {
  if (!hasSkills.value) return ['Skills section missing', 'No technical skills detected', 'No soft skills detected', 'Resume lacks competency evidence']
  const reasoning = skillsRaw.value?.reasoning || ''
  if (!reasoning.startsWith('Issues:')) return []
  return reasoning.replace('Issues: ', '').replace(/\.$/, '').split('; ')
})

// Present and missing categories — surfaced directly from backend
const skillsPresentCategories = computed(() => skillsRaw.value?.present_categories ?? [])
const skillsMissingCategories = computed(() => skillsRaw.value?.missing_categories ?? [])

const skillsSuggestions = computed(() => {
  if (!hasSkills.value) return ['Add programming languages', 'Add frameworks', 'Add databases', 'Add cloud technologies', 'Add tools', 'Add soft skills', 'Organize skills into categories']
  const status = skillsRaw.value?.status
  if (status === 'complete') return ['Great coverage of skills. Keep them organized.']
  // Use targeted suggestions computed by the backend
  const backendSuggestions = skillsRaw.value?.category_suggestions ?? []
  return backendSuggestions.length ? backendSuggestions : ['Include both hard and soft skills', 'Match skills to your target job descriptions']
})

const skillsStats = computed(() => {
  if (!hasSkills.value) {
    return {
      current: '0 skills',
      target: '15+ relevant industry skills'
    }
  }
  
  const pts = skillsRaw.value?.points ?? 0
  const count = skillsRaw.value?.count ?? 0
  const status = skillsRaw.value?.status
  const qualityLabel = status === 'complete' ? 'Excellent'
    : status === 'weak' ? 'Needs Work'
    : 'Critical'

  return {
    current: `${count} skills (${qualityLabel})`,
    quality: `${pts} / 15`,
    target: '15+ relevant industry skills'
  }
})

const skillsAiRec = computed(() => {
  return "We can cross-reference your target job title with industry databases to automatically populate missing high-value keywords."
})

// ── Education quality computed from actual backend analysis ──────────
const hasEducation = ref(true)

const educationRaw = computed(() => {
  const sec = scoreData.value?.analysis_data?.completeness?.section_results?.educations
  if (!sec) return null
  return sec
})

const educationProgress = computed(() => {
  if (!hasEducation.value) return 20 // missing
  const pts = educationRaw.value?.points
  if (pts != null) return Math.min(100, Math.round((pts / 20) * 100))

  const status = educationRaw.value?.status
  if (status === 'complete') return 100
  if (status === 'weak') return 50
  return 20
})

const educationIssues = computed(() => {
  if (!hasEducation.value) return ['Education section is missing entirely.', 'No institution, degree, or dates detected.']
  const reasoning = educationRaw.value?.reasoning || ''
  if (!reasoning.startsWith('Issues:')) return []
  return reasoning.replace('Issues: ', '').replace(/\.$/, '').split('; ')
})

const educationSuggestions = computed(() => {
  if (!hasEducation.value) return [
    'Add your most recent educational qualification.',
    'Include school name, degree, and graduation year.',
    'Add CGPA or percentage if it is strong.'
  ]
  const status = educationRaw.value?.status
  if (status === 'complete') return ['Your education section is complete. Keep it up-to-date.']
  return [
    'Include your field of study or major in the degree field (e.g., "Bachelor of Technology - Computer Science").',
    'Include your CGPA or percentage to demonstrate academic strength.'
  ]
})

const educationStats = computed(() => {
  if (!hasEducation.value) {
    return {
      current: 'Missing',
      target: 'At least one education entry with:\n• institution\n• degree\n• field of study\n• graduation year'
    }
  }

  const pts = educationRaw.value?.points ?? 0
  const status = educationRaw.value?.status
  const qualityLabel = status === 'complete' ? 'Excellent'
    : status === 'weak' ? 'Needs Work'
    : 'Critical'

  return {
    current: `Present (${qualityLabel})`,
    quality: `${pts} / 20`,
    target: 'Complete education record with academic achievements'
  }
})

const educationAiRec = computed(() => {
  if (!hasEducation.value) return 'Fill in your institution, degree, field of study, and graduation year to establish academic credibility.'
  const status = educationRaw.value?.status
  if (status === 'complete') return 'Your education section meets professional standards.'
  return 'Add your GPA, relevant coursework, or honors to differentiate your academic profile.'
})

// ── Projects quality computed from actual backend analysis ──────────
const hasProjects = ref(true)

const projectsRaw = computed(() => {
  const sec = scoreData.value?.analysis_data?.completeness?.section_results?.projects
  if (!sec) return null
  return sec
})

const projectsProgress = computed(() => {
  if (!hasProjects.value) return 20 // missing
  const pts = projectsRaw.value?.points
  if (pts != null) return Math.min(100, Math.round((pts / 30) * 100))

  const status = projectsRaw.value?.status
  if (status === 'complete') return 100
  if (status === 'weak') return 50
  return 20
})

const projectsIssues = computed(() => {
  if (!hasProjects.value) return ['Projects section is missing entirely.', 'No project history found.']
  const reasoning = projectsRaw.value?.reasoning || ''
  if (!reasoning.startsWith('Issues:')) return []
  return reasoning.replace('Issues: ', '').replace(/\.$/, '').split('; ')
})

const projectsSuggestions = computed(() => {
  if (!hasProjects.value) return [
    'Add your first project.',
    'Aim for at least two strong projects.',
    'Include project title, technologies, description and live links.'
  ]

  // Use metadata suggestions if available
  const metaSuggestions = projectsRaw.value?.suggestions
  if (metaSuggestions && metaSuggestions.length > 0) {
    return metaSuggestions
  }

  const status = projectsRaw.value?.status
  if (status === 'complete') return ['Your projects section is complete. Keep it up-to-date.']
  return [
    'Describe your project implementation and goals.',
    'List the key programming languages, frameworks, and tools used.',
    'Quantify your achievements (e.g., performance improvements, load times).'
  ]
})

const projectsStats = computed(() => {
  if (!hasProjects.value) {
    return {
      current: 'Missing',
      target: 'At least two projects containing:\n• project name\n• technologies\n• description\n• project links'
    }
  }

  const pts = projectsRaw.value?.points ?? 0
  const status = projectsRaw.value?.status
  const qualityLabel = status === 'complete' ? 'Excellent'
    : status === 'weak' ? 'Needs Work'
    : 'Critical'

  return {
    current: `Present (${qualityLabel})`,
    quality: `${pts} / 30`,
    target: 'Two or more complete project entries with technologies, descriptions, and metrics'
  }
})

const projectsAiRec = computed(() => {
  if (!hasProjects.value) return 'Use AI to generate your first project description from hackathons, coursework, or freelance work.'
  const status = projectsRaw.value?.status
  if (status === 'complete') return 'Your projects section meets professional standards.'
  return 'AI can strengthen your project by rewriting descriptions, highlighting technical implementation, improving ATS keywords, adding measurable achievements, and making bullet points more impactful.'
})

const projectsButtonText = computed(() => {
  if (!hasProjects.value) return 'Generate Projects'
  return 'Improve with AI'
})


const experienceButtonText = computed(() => {
  if (!hasExperience.value) return 'Add Experience with AI'
  return 'Improve with AI'
})

const fetchCredits = async () => {
  try {
    const { data } = await http.get('/credits/history?per_page=5')
    creditHistory.value = data.transactions
    creditStats.value = data.stats
    if (store.state.auth.user) {
      store.commit('auth/SET_USER_CREDITS', creditStats.value.available)
    }
  } catch (err) {
    console.error('Failed to load credit history', err)
  }
}

const displayedScore = computed(() => animatedScore.value)

onMounted(async () => {
  await fetchScore()
  await fetchCredits()
})

async function fetchScore(quiet = false) {
  if (!quiet) loading.value = true
  try {
    const { data } = await http.get(`/resumes/${props.resumeId}/score`)
    if (data.overall_score != null) {
      scoreData.value = data
      animatedScore.value = data.overall_score

      // Read summary status from analysis_data returned by the score endpoint.
      // data.resume is NOT in the score response — reading it always gave undefined.
      const summaryStatus = data.analysis_data?.completeness?.section_results?.summary?.status
      // 'poor' = exists but very low quality. 'missing' = field is blank.
      hasSummary.value = summaryStatus === 'complete' || summaryStatus === 'weak' || summaryStatus === 'poor'

      const expStatus = data.analysis_data?.completeness?.section_results?.experiences?.status
      hasExperience.value = expStatus !== 'missing'

      const skillsStatus = data.analysis_data?.completeness?.section_results?.skills?.status
      hasSkills.value = skillsStatus !== 'missing'

      const eduStatus = data.analysis_data?.completeness?.section_results?.educations?.status
      hasEducation.value = eduStatus !== 'missing'

      const projStatus = data.analysis_data?.completeness?.section_results?.projects?.status
      hasProjects.value = projStatus !== 'missing'
    }
  } catch (e) {
    console.error('Failed to load score', e)
  } finally {
    if (!quiet) loading.value = false
  }
}

watch(
  () => props.resume,
  (newResume, oldResume) => {
    if (newResume && oldResume && JSON.stringify(newResume.content) !== JSON.stringify(oldResume.content)) {
      fetchScore(true)
    }
  },
  { deep: true }
)

async function analyze() {
  analyzing.value = true
  dismissedIssues.value = []
  localStorage.removeItem(dismissedIssuesKey)
  try {
    const { data } = await http.post(`/resumes/${props.resumeId}/score`)
    scoreData.value = data
    animatedScore.value = data.overall_score

    // Keep hasSummary in sync after a fresh analysis too.
    const summaryStatus = data.analysis_data?.completeness?.section_results?.summary?.status
    // 'poor' = exists but very low quality. 'missing' = field is blank.
    hasSummary.value = summaryStatus === 'complete' || summaryStatus === 'weak' || summaryStatus === 'poor'

    const expStatus = data.analysis_data?.completeness?.section_results?.experiences?.status
    hasExperience.value = expStatus !== 'missing'

    const skillsStatus = data.analysis_data?.completeness?.section_results?.skills?.status
    hasSkills.value = skillsStatus !== 'missing'

    const eduStatus = data.analysis_data?.completeness?.section_results?.educations?.status
    hasEducation.value = eduStatus !== 'missing'

    const projStatus = data.analysis_data?.completeness?.section_results?.projects?.status
    hasProjects.value = projStatus !== 'missing'
  } catch (e) {
    console.error('Failed to analyze', e)
  } finally {
    analyzing.value = false
  }
}

async function openWorkflow(actionType) {
  currentAction.value = actionType
  showWorkflowModal.value = true
}

async function onImproveProjects() {
  if (projects.value.length === 0) {
    const updatedContent = {
      ...props.resume.content,
      projects: [
        {
          id: Date.now().toString(),
          projectName: 'New Project',
          technologies: '',
          description: '',
          projectLink: ''
        }
      ]
    }
    
    try {
      const { data } = await http.put(`/resumes/${props.resumeId}`, {
        resume: { content: updatedContent }
      })
      store.commit('resumes/updateOne', data.resume)
      emit('update-resume', data.resume)
      await nextTick()
    } catch (err) {
      console.error('Failed to create initial project', err)
      Notification.error({
        title: 'Project Initialization Failed',
        message: 'Failed to initialize project entry.'
      })
      return
    }
  } else if (projects.value.length === 1) {
    const p = projects.value[0]
    if (!p.projectName?.trim() && !p.technologies?.trim()) {
      const updatedProjects = [...projects.value]
      updatedProjects[0] = {
        ...updatedProjects[0],
        projectName: 'New Project'
      }
      const updatedContent = {
        ...props.resume.content,
        projects: updatedProjects
      }
      
      try {
        const { data } = await http.put(`/resumes/${props.resumeId}`, {
          resume: { content: updatedContent }
        })
        store.commit('resumes/updateOne', data.resume)
        emit('update-resume', data.resume)
        await nextTick()
      } catch (err) {
        console.error('Failed to update empty project name', err)
        Notification.error({
          title: 'Project Initialization Failed',
          message: 'Failed to initialize project name.'
        })
        return
      }
    }
  }
  
  currentAction.value = 'optimize_project'
  showWorkflowModal.value = true
}

async function startOptimization(payload) {
  showWorkflowModal.value = false

  if (currentAction.value === 'optimize_project' && payload.project_action === 'update_link') {
    previewProjectLinkUpdate(payload)
    showResultPreview.value = true
    return
  }

  showLoadingOverlay.value = true
  
  try {
    const { data } = await http.post(`/resumes/${props.resumeId}/optimize`, {
      optimization_action: currentAction.value,
      ...payload
    })
    
    if (data.already_optimized) {
      showLoadingOverlay.value = false
      if (currentAction.value === 'improve_skills' && data.message && data.message.includes('Tell AI')) {
        // Skills: already balanced — show in modal with full guidance
        errorModalTitle.value = '✨ Skills Section Is Strong'
        errorModalMessage.value = data.message
        showErrorModal.value = true
      } else {
        Notification.success({
          title: 'Already Optimized',
          message: data.message || 'Already optimized.'
        })
      }
      return
    }
    
    // Store result to show in preview
    newContent.value = data.result
    mergedContent.value = data.merged_content
    aiStats.value = data.stats
    
    if (currentAction.value === 'optimize_project') {
      const projId = payload.project_id
      const proj = projects.value.find(p => p.id === projId) || projects.value[0]
      oldContent.value = getProjectPreviewContent(proj, payload.project_field)
      newContent.value = getMergedProjectPreviewContent(data.merged_content, projId, payload.project_field)
    } else if (currentAction.value === 'rewrite_experience') {
      const expId = payload.experience_id
      const exp = experiences.value.find(e => e.id === expId) || experiences.value[0]
      oldContent.value = getExperiencePreviewContent(exp)
      newContent.value = getMergedExperiencePreviewContent(data.merged_content, expId)
    } else if (['rewrite', 'expand', 'shorten'].includes(currentAction.value)) {
      oldContent.value = payload.bullet_text
      newContent.value = data.result
    } else {
      oldContent.value = 'Resume content prior to optimization (mocked for preview).'
    }
    
    await fetchCredits()
    
    showLoadingOverlay.value = false
    showResultPreview.value = true
  } catch (err) {
    showLoadingOverlay.value = false
    showWorkflowModal.value = true // keep input modal open
    
    if (err.response?.status === 402) {
      Notification.error({
        title: 'Insufficient Credits',
        message: 'Insufficient AI Credits. Please upgrade your subscription.'
      })
    } else if (err.response?.data?.error_code) {
      errorModalTitle.value = err.response.data.title || 'Error'
      errorModalMessage.value = err.response.data.message || 'An unexpected error occurred.'
      showErrorModal.value = true
    } else {
      const errMsg = err.response?.data?.error || 'An error occurred during AI generation. Please try again.'
      Notification.error({
        title: 'Failed to Optimize',
        message: errMsg,
        onRetry: () => {
          startOptimization(payload)
        }
      })
    }
  }
}

function previewProjectLinkUpdate(payload) {
  const sourceContent = props.resume?.content || {}
  const projectList = sourceContent.projects || []
  const projectIndex = projectList.findIndex(p => p.id === payload.project_id)
  const safeIndex = projectIndex >= 0 ? projectIndex : 0
  const selected = projectList[safeIndex]
  const nextLink = payload.project_link?.trim() || ''

  oldContent.value = selected?.projectLink || '(Empty)'
  newContent.value = nextLink
  aiStats.value = { credits_used: 0, version: 'Draft' }
  mergedContent.value = {
    ...sourceContent,
    projects: projectList.map((project, index) => (
      index === safeIndex ? { ...project, projectLink: nextLink } : project
    ))
  }
}

function getProjectPreviewContent(project, field) {
  if (!project) return '(Empty)'
  if (field === 'technologies') return project.technologies || '(Empty)'
  if (field === 'title') return project.projectName || '(Empty)'
  if (field === 'entire_project') {
    return JSON.stringify({
      projectName: project.projectName || '',
      technologies: project.technologies || '',
      description: project.description || ''
    }, null, 2)
  }
  return project.description || '(Empty)'
}

function getMergedProjectPreviewContent(content, projectId, field) {
  const projectList = content?.projects || []
  const project = projectList.find(p => p.id === projectId) || projectList[0]
  return getProjectPreviewContent(project, field)
}

function getExperiencePreviewContent(experience) {
  if (!experience) return '(Empty)'
  return experience.description || '(Empty)'
}

function getMergedExperiencePreviewContent(content, experienceId) {
  const experienceList = content?.experiences || []
  const experience = experienceList.find(e => e.id === experienceId) || experienceList[0]
  return getExperiencePreviewContent(experience)
}

async function applyOptimization() {
  showLoadingOverlay.value = true
  
  try {
    const { data } = await http.put(`/resumes/${props.resumeId}`, {
      resume: { content: mergedContent.value }
    })
    
    showResultPreview.value = false // Close only on success
    
    recentActivities.value.unshift({ title: formatActionTitle(currentAction.value), time: 'Just now' })
    
    const successMsg = buildSuccessMessage({
      type: currentAction.value,
      oldContent: props.resume?.content,
      newContent: mergedContent.value,
      backendResponse: data
    })
    
    Notification.success({
      title: successMsg.title,
      message: successMsg.message
    })
    
    // ── Live update: push to Vuex store so same-tab edit page watcher triggers ──
    // This replaces the localStorage approach which only fired in OTHER tabs.
    store.commit('resumes/updateOne', data.resume)
    emit('update-resume', data.resume)
    
    await fetchScore()
    await analyze()
  } catch (err) {
    const errMsg = err.response?.data?.error || err.message || 'We couldn\'t save your changes. Please try again.'
    let errorTitle = 'Failed to Apply Changes'
    
    if (currentAction.value === 'improve_skills') {
      errorTitle = 'Failed to Apply Skills'
    } else if (currentAction.value === 'generate_summary') {
      errorTitle = 'Failed to Apply Summary'
    } else if (currentAction.value === 'rewrite_experience') {
      errorTitle = 'Failed to Apply Work Experience'
    } else if (currentAction.value === 'optimize_project') {
      errorTitle = 'Failed to Apply Project'
    }
    
    Notification.error({
      title: errorTitle,
      message: `Reason: ${errMsg}`,
      onRetry: () => {
        applyOptimization()
      }
    })
  } finally {
    showLoadingOverlay.value = false
  }
}


function discardOptimization(origin) {
  showResultPreview.value = false
  if (currentAction.value === 'generate_linkedin') {
    if (origin === 'done') {
      Notification.success({
        title: 'LinkedIn Optimization Done',
        message: 'Your premium profile report has been successfully processed.'
      })
    } else {
      Notification.info({
        title: 'LinkedIn Optimization Closed',
        message: 'The report was closed without applying updates.'
      })
    }
  } else {
    Notification.info({
      title: 'Changes Discarded',
      message: 'AI optimization changes were not saved to your resume.'
    })
  }
}

function handleDismiss(issueId) {
  if (!dismissedIssues.value.includes(issueId)) {
    dismissedIssues.value.push(issueId)
    localStorage.setItem(dismissedIssuesKey, JSON.stringify(dismissedIssues.value))
  }
}

function navigateToExperience() {
  router.push({ path: `/resumes/${props.resumeId}/edit`, hash: '#section-experience' })
}

function handleAction(actionType) {
  Notification.info({
    title: 'Feature Coming Soon',
    message: 'This feature will be available shortly.'
  })
}

function formatDate(iso) {
  if (!iso) return 'Never'
  return new Intl.DateTimeFormat('en-US', { month: 'short', day: 'numeric', year: 'numeric', hour: '2-digit', minute: '2-digit' }).format(new Date(iso))
}

function formatActionTitle(action) {
  switch (action) {
    case 'generate_summary': return 'Summary Generated'
    case 'rewrite_experience': return 'Experience Rewritten'
    case 'ats_booster': return 'Keywords Boosted'
    case 'generate_cover_letter': return 'Cover Letter Generated'
    case 'generate_linkedin': return 'LinkedIn Profile Generated'
    case 'tailor_to_job': return 'Resume Tailored to Job'
    case 'optimize_project': return 'Project Optimized'
    default: return 'AI Optimization Applied'
  }
}

function animateScore(start, end) {
  const duration = 1500
  const stepTime = 20
  const steps = duration / stepTime
  const increment = (end - start) / steps
  
  let current = start
  const timer = setInterval(() => {
    current += increment
    if (current >= end) {
      animatedScore.value = end
      clearInterval(timer)
    } else {
      animatedScore.value = Math.floor(current)
    }
  }, stepTime)
}

defineExpose({ openWorkflow })
</script>

<style scoped>
.optimization-dashboard {
  padding: 2.5rem;
  max-width: 1400px;
  margin: 0 auto;
  animation: fadeIn 0.4s ease;
}

@keyframes fadeIn {
  from { opacity: 0; transform: translateY(10px); }
  to { opacity: 1; transform: translateY(0); }
}

.dashboard-loading, .dashboard-empty {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  min-height: 500px;
  text-align: center;
  gap: 1.5rem;
}

.placeholder-icon-wrap {
  width: 80px; height: 80px;
  background: linear-gradient(135deg, rgba(99, 102, 241, 0.1), rgba(139, 92, 246, 0.1));
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  margin-bottom: 1rem;
}
.placeholder-icon { width: 40px; height: 40px; color: rgb(var(--color-primary)); }

.dashboard-empty h2 { font-size: 2.25rem; color: rgb(var(--color-text-primary)); margin: 0; font-weight: 800; letter-spacing: -0.02em; }
.dashboard-empty p { max-width: 550px; margin: 0; line-height: 1.7; color: rgb(var(--color-text-secondary)); font-size: 1.125rem; }

.btn-large {
  padding: 1rem 2.5rem;
  font-size: 1.125rem;
  border-radius: 1rem;
}

.btn-primary {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  background: linear-gradient(135deg, rgb(var(--color-primary)), #8b5cf6);
  color: #fff;
  border: none;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.2s ease;
  box-shadow: 0 4px 15px rgba(99, 102, 241, 0.3);
}
.btn-primary:hover:not(:disabled) {
  transform: translateY(-2px);
  box-shadow: 0 8px 20px rgba(99, 102, 241, 0.4);
}
.btn-primary:disabled { opacity: 0.7; cursor: not-allowed; transform: none; box-shadow: none; }

.mb-8 { margin-bottom: 2rem; }
.mb-10 { margin-bottom: 2.5rem; }
.mb-0 { margin-bottom: 0 !important; }
.mr-2 { margin-right: 0.5rem; }
.mt-4 { margin-top: 1rem; }
.w-full { width: 100%; text-align: center; justify-content: center; display: inline-flex; }
.size-5 { width: 1.25rem; height: 1.25rem; }
.size-6 { width: 1.5rem; height: 1.5rem; }
.text-primary { color: rgb(var(--color-primary)); }

.section-title {
  font-size: 1.5rem;
  font-weight: 800;
  color: rgb(var(--color-text-primary));
  margin: 0 0 1.5rem 0;
  letter-spacing: -0.01em;
}

.score-cards-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(260px, 1fr));
  gap: 1.5rem;
}

.dashboard-main-grid {
  display: grid;
  grid-template-columns: 1.8fr 1.2fr;
  gap: 3rem;
}

.issues-list, .health-cards-list, .ai-actions-list {
  display: flex;
  flex-direction: column;
  gap: 1.25rem;
}

.premium-block {
  background: linear-gradient(145deg, rgb(var(--color-surface)), rgb(var(--color-surface-hover)));
  border-radius: 1.5rem;
  padding: 2rem;
  border: 1px solid rgb(var(--color-border));
  box-shadow: 0 10px 30px rgba(0,0,0,0.02);
  position: relative;
  overflow: hidden;
}

.premium-block::before {
  content: '';
  position: absolute;
  top: 0; left: 0; right: 0; height: 4px;
  background: linear-gradient(90deg, #8b5cf6, rgb(var(--color-primary)));
}

.premium-header {
  display: flex;
  align-items: center;
  gap: 1rem;
  margin-bottom: 0.5rem;
}

.premium-icon {
  width: 48px; height: 48px;
  background: rgba(99, 102, 241, 0.1);
  border-radius: 1rem;
  display: flex;
  align-items: center;
  justify-content: center;
}

.toolkit-desc {
  margin: 0 0 2rem 0;
  color: rgb(var(--color-text-secondary));
  font-size: 0.95rem;
  line-height: 1.5;
}

.timeline-block {
  background: rgb(var(--color-surface));
  border-radius: 1.5rem;
  padding: 2rem;
  border: 1px solid rgb(var(--color-border));
  box-shadow: 0 4px 20px rgba(0,0,0,0.02);
}

.timeline {
  display: flex;
  flex-direction: column;
  gap: 2rem;
  position: relative;
  padding-left: 1.25rem;
  margin-top: 1rem;
}
.timeline::before {
  content: '';
  position: absolute;
  top: 0; left: 1.5rem; bottom: 0;
  width: 2px;
  background: rgb(var(--color-surface-hover));
  border-radius: 2px;
}

.timeline-item {
  position: relative;
  display: flex;
  gap: 1.25rem;
}

.tl-dot {
  width: 14px; height: 14px;
  border-radius: 50%;
  background: rgb(var(--color-surface));
  border: 3px solid rgb(var(--color-primary));
  z-index: 1;
  margin-top: 0.125rem;
  box-shadow: 0 0 0 4px rgb(var(--color-surface));
}

.pulse-dot {
  animation: dotPulse 2s infinite;
}

@keyframes dotPulse {
  0% { box-shadow: 0 0 0 0 rgba(99, 102, 241, 0.4); }
  70% { box-shadow: 0 0 0 8px rgba(99, 102, 241, 0); }
  100% { box-shadow: 0 0 0 0 rgba(99, 102, 241, 0); }
}

.tl-title { font-weight: 600; font-size: 0.95rem; color: rgb(var(--color-text-primary)); }
.tl-time { font-size: 0.8rem; color: rgb(var(--color-text-muted)); margin-top: 0.25rem; font-weight: 500; }

.btn-text {
  background: rgb(var(--color-surface-hover));
  border: 1px solid transparent;
  color: rgb(var(--color-primary));
  font-weight: 600;
  font-size: 0.95rem;
  padding: 0.75rem;
  border-radius: 1rem;
  cursor: pointer;
  transition: all 0.2s;
}
.btn-text:hover { 
  background: rgba(99, 102, 241, 0.05);
  border-color: rgba(99, 102, 241, 0.2);
}

/* Skeletons */
.skeleton-hero { height: 280px; background: rgb(var(--color-surface-hover)); border-radius: 1.5rem; margin-bottom: 2.5rem; width: 100%; animation: pulse 1.5s infinite ease-in-out; }
.skeleton-grid { display: grid; grid-template-columns: repeat(4, 1fr); gap: 1.5rem; width: 100%; margin-bottom: 2rem; }
.skeleton-card { height: 200px; background: rgb(var(--color-surface-hover)); border-radius: 1.25rem; animation: pulse 1.5s infinite ease-in-out; animation-delay: 0.2s; }
.loading-text { font-size: 1.125rem; color: rgb(var(--color-text-muted)); font-weight: 500; animation: pulse 1.5s infinite; }

.credit-stats {
  display: flex;
  flex-direction: column;
  gap: 0.75rem;
}

.stat-row {
  display: flex;
  justify-content: space-between;
  align-items: center;
  font-size: 0.95rem;
  padding-bottom: 0.5rem;
  border-bottom: 1px dashed rgb(var(--color-border));
}

.stat-row:last-child {
  border-bottom: none;
  padding-bottom: 0;
}

.stat-label {
  color: rgb(var(--color-text-secondary));
}

.stat-value {
  color: rgb(var(--color-text-primary));
  font-weight: 500;
}

.action-credits {
  font-weight: normal;
  opacity: 0.8;
  font-size: 0.85em;
  color: rgb(var(--color-text-secondary));
}

@keyframes pulse {
  0% { opacity: 1; }
  50% { opacity: 0.6; }
  100% { opacity: 1; }
}

.spin { animation: spin 1s linear infinite; }
@keyframes spin { to { transform: rotate(360deg); } }

@media (max-width: 1024px) {
  .dashboard-main-grid { grid-template-columns: 1fr; }
  .skeleton-grid { grid-template-columns: repeat(2, 1fr); }
}
@media (max-width: 640px) {
  .optimization-dashboard { padding: 0.75rem; }
  .score-cards-grid { grid-template-columns: 1fr; gap: 1rem; }
  .skeleton-grid { grid-template-columns: 1fr; }
  .dashboard-main-grid { gap: 1.5rem; }
}
</style>
