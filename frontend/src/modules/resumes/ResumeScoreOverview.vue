<template>
  <div class="optimization-dashboard">
    <!-- Premium Coming Soon Modal -->
    <ComingSoonModal 
      v-model="showModal" 
      :message="modalMessage" 
    />

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
        class="mb-8"
        :score="scoreData.overall_score || 0"
        :atsSuccess="scoreData.ats_score || 0"
        :completion="scoreData.completeness_score || 0"
        :issues="totalIssues"
        :potentialGain="potentialGain"
        :lastAnalyzed="formatDate(scoreData.last_analyzed_at)"
        :loading="analyzing"
        @analyze="analyze"
        @optimize="handleAiAction('full_optimize')"
      />

      <!-- Section 6: Optimization Progress -->
      <ProgressCard
        class="mb-10"
        :progress="optimizationProgress"
        :remainingIssues="totalIssues"
        :estimatedFinal="Math.min(100, (scoreData.overall_score || 0) + potentialGain)"
        :potentialIncrease="potentialGain"
      />

      <!-- Section 2: Score Cards -->
      <div class="section-block mb-10">
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

      <div class="dashboard-main-grid">
        <div class="main-column">
          <!-- Section 3 & 4: Priority Issues & Quick Wins -->
          <div class="section-block mb-10">
            <h2 class="section-title">Actionable Insights</h2>
            
            <div class="issues-list">
              <IssueCard
                v-if="!hasSummary"
                title="Professional Summary Missing"
                description="Your resume is missing a professional summary at the top."
                whyItMatters="Recruiters spend only a few seconds reviewing resumes. Without a summary, your profile lacks immediate context and narrative."
                priority="HIGH"
                :gain="8"
                time="1 min"
                primaryActionLabel="Generate Summary"
                @fix="handleAiAction('generate_summary')"
                @dismiss="handleDismiss('summary')"
              />
              
              <IssueCard
                title="Missing Quantifiable Metrics"
                description="Your experience bullets lack numbers. Add metrics to show your actual impact."
                whyItMatters="Numbers provide scale. Saying 'increased sales by 20%' is much stronger than 'increased sales'."
                priority="MED"
                :gain="12"
                time="3 mins"
                primaryActionLabel="Rewrite Bullets"
                @fix="handleAiAction('rewrite_experience')"
                @dismiss="handleDismiss('metrics')"
              />

              <IssueCard
                v-if="!hasLinkedIn"
                title="Missing LinkedIn Profile"
                description="Your contact section is missing a LinkedIn URL."
                whyItMatters="Recruiters expect to see your LinkedIn profile URL to verify your professional network and endorsements."
                priority="QUICK"
                :gain="2"
                time="30 sec"
                primaryActionLabel="Add Link"
                @fix="handleAction('add_linkedin')"
                @dismiss="handleDismiss('linkedin')"
              />
            </div>
          </div>

          <!-- Section 5: Section Health -->
          <div class="section-block">
            <h2 class="section-title">Section Health</h2>
            <div class="health-cards-list">
              <SectionHealthCard
                title="Professional Summary"
                :progress="hasSummary ? 90 : 20"
                :issues="hasSummary ? [] : ['Section is missing entirely']"
                :suggestions="['Use AI to generate a targeted summary based on your experience']"
                aiRecommendation="Let our AI scan your entire work history to craft a compelling 3-sentence summary tailored to your target industry."
                :estimatedGain="8"
                @improve="handleAiAction('improve_summary')"
              />
              <SectionHealthCard
                title="Work Experience"
                :progress="scoreData.content_score || 60"
                :issues="['2 bullet points are too short', 'Missing measurable results in recent role']"
                :suggestions="['Expand on your leadership responsibilities', 'Add specific technologies used']"
                aiRecommendation="Use the Bullet Point Enhancer to automatically inject action verbs and metrics into your most recent role."
                :estimatedGain="12"
                @improve="handleAiAction('improve_experience')"
              />
              <SectionHealthCard
                title="Skills"
                :progress="scoreData.keyword_score || 50"
                :issues="['Missing soft skills', 'No skill categories defined']"
                :suggestions="['Group skills by category (e.g. Frontend, Backend)']"
                aiRecommendation="We can cross-reference your target job title with industry databases to automatically populate missing high-value keywords."
                :estimatedGain="8"
                @improve="handleAiAction('improve_skills')"
              />
            </div>
          </div>
        </div>

        <div class="sidebar-column">
          <!-- Section 8: AI Resume Toolkit (Premium Feature) -->
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
                :actions="[{type:'optimize', label:'Optimize for Job'}]"
                @action="handleAiAction"
              />
              <OptimizationActionCard
                title="Bullet Point Enhancer"
                description="Transform weak duties into powerful achievement statements."
                :actions="[
                  {type:'rewrite', label:'Rewrite'},
                  {type:'expand', label:'Expand'},
                  {type:'shorten', label:'Shorten'}
                ]"
                @action="handleAiAction"
              />
              <OptimizationActionCard
                title="Cover Letter Generator"
                description="Generate a highly personalized cover letter based on this resume."
                :actions="[{type:'generate', label:'Generate Cover Letter'}]"
                @action="handleAiAction"
              />
              <OptimizationActionCard
                title="LinkedIn Optimizer"
                description="Get an AI-generated 'About' section and headline tailored for LinkedIn."
                :actions="[{type:'generate', label:'Optimize LinkedIn'}]"
                @action="handleAiAction"
              />
              <OptimizationActionCard
                title="ATS Keyword Booster"
                description="Automatically inject missing high-value industry keywords naturally."
                :actions="[{type:'improve', label:'Boost Keywords'}]"
                @action="handleAiAction"
              />
              <OptimizationActionCard
                title="Resume Translator"
                description="Translate your entire resume into another language flawlessly."
                :actions="[{type:'generate', label:'Translate'}]"
                @action="handleAiAction"
              />
            </div>
          </div>

          <!-- Section 7: Improvement Timeline -->
          <div class="section-block timeline-block">
            <h2 class="section-title">Recent Activity</h2>
            <div class="timeline">
              <div class="timeline-item">
                <div class="tl-dot pulse-dot"></div>
                <div class="tl-content">
                  <div class="tl-title">Analysis Complete</div>
                  <div class="tl-time">Just now</div>
                </div>
              </div>
              <div class="timeline-item">
                <div class="tl-dot"></div>
                <div class="tl-content">
                  <div class="tl-title">Resume Created</div>
                  <div class="tl-time">Recent</div>
                </div>
              </div>
            </div>
            <button class="btn-text mt-4 w-full" @click="handleAction('view_history')">View Full History &rarr;</button>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import http from '../../services/http'
import HeroScoreCard from '../../components/optimization/HeroScoreCard.vue'
import ScoreCard from '../../components/optimization/ScoreCard.vue'
import IssueCard from '../../components/optimization/IssueCard.vue'
import SectionHealthCard from '../../components/optimization/SectionHealthCard.vue'
import ProgressCard from '../../components/optimization/ProgressCard.vue'
import OptimizationActionCard from '../../components/optimization/OptimizationActionCard.vue'
import ComingSoonModal from '../../components/ui/ComingSoonModal.vue'

const props = defineProps({
  resumeId: { type: [String, Number], required: true }
})

const loading = ref(false)
const analyzing = ref(false)
const scoreData = ref(null)

const showModal = ref(false)
const modalMessage = ref('This premium AI workflow will be available in the next phase.')

// Mocked derived data for UI purposes until backend provides everything
const hasSummary = ref(false) // Would come from actual resume data
const hasLinkedIn = ref(false)

const totalIssues = computed(() => {
  return 3 + (hasSummary.value ? 0 : 1) + (hasLinkedIn.value ? 0 : 1)
})

const potentialGain = computed(() => {
  return (scoreData.value?.overall_score || 0) < 100 ? 28 : 0
})

const optimizationProgress = computed(() => {
  return Math.min(100, Math.max(0, scoreData.value?.overall_score || 0))
})

onMounted(fetchScore)

async function fetchScore() {
  loading.value = true
  try {
    const { data } = await http.get(`/resumes/${props.resumeId}/score`)
    if (data.overall_score != null) {
      scoreData.value = data
    }
  } catch (e) {
    console.error('Failed to load score', e)
  } finally {
    loading.value = false
  }
}

async function analyze() {
  analyzing.value = true
  try {
    const { data } = await http.post(`/resumes/${props.resumeId}/score`)
    scoreData.value = data
  } catch (e) {
    console.error('Failed to analyze', e)
  } finally {
    analyzing.value = false
  }
}

function handleAiAction(actionType) {
  console.log('AI Action Triggered:', actionType)
  modalMessage.value = 'This advanced AI workflow is currently in development and will be available in the next phase.'
  showModal.value = true
}

function handleAction(actionType) {
  console.log('Action Triggered:', actionType)
  if (actionType === 'add_linkedin') {
    modalMessage.value = 'Resume editor integration is coming in the next phase.'
    showModal.value = true
  } else if (actionType === 'view_history') {
    modalMessage.value = 'Version history integration will be available shortly.'
    showModal.value = true
  }
}

function handleDismiss(issueId) {
  console.log('Dismissed issue:', issueId)
}

function formatDate(iso) {
  if (!iso) return 'Never'
  return new Intl.DateTimeFormat('en-US', { month: 'short', day: 'numeric', year: 'numeric', hour: '2-digit', minute: '2-digit' }).format(new Date(iso))
}
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
.placeholder-icon { width: 40px; height: 40px; color: var(--color-primary); }

.dashboard-empty h2 { font-size: 2.25rem; color: var(--color-text-primary); margin: 0; font-weight: 800; letter-spacing: -0.02em; }
.dashboard-empty p { max-width: 550px; margin: 0; line-height: 1.7; color: var(--color-text-secondary); font-size: 1.125rem; }

.btn-large {
  padding: 1rem 2.5rem;
  font-size: 1.125rem;
  border-radius: 1rem;
}

.btn-primary {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  background: linear-gradient(135deg, var(--color-primary), #8b5cf6);
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
.text-primary { color: var(--color-primary); }

.section-title {
  font-size: 1.5rem;
  font-weight: 800;
  color: var(--color-text-primary);
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
  background: linear-gradient(145deg, var(--color-surface), var(--color-surface-2));
  border-radius: 1.5rem;
  padding: 2rem;
  border: 1px solid var(--color-border);
  box-shadow: 0 10px 30px rgba(0,0,0,0.02);
  position: relative;
  overflow: hidden;
}

.premium-block::before {
  content: '';
  position: absolute;
  top: 0; left: 0; right: 0; height: 4px;
  background: linear-gradient(90deg, #8b5cf6, var(--color-primary));
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
  color: var(--color-text-secondary);
  font-size: 0.95rem;
  line-height: 1.5;
}

.timeline-block {
  background: var(--color-surface);
  border-radius: 1.5rem;
  padding: 2rem;
  border: 1px solid var(--color-border);
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
  background: var(--color-surface-3);
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
  background: var(--color-surface);
  border: 3px solid var(--color-primary);
  z-index: 1;
  margin-top: 0.125rem;
  box-shadow: 0 0 0 4px var(--color-surface);
}

.pulse-dot {
  animation: dotPulse 2s infinite;
}

@keyframes dotPulse {
  0% { box-shadow: 0 0 0 0 rgba(99, 102, 241, 0.4); }
  70% { box-shadow: 0 0 0 8px rgba(99, 102, 241, 0); }
  100% { box-shadow: 0 0 0 0 rgba(99, 102, 241, 0); }
}

.tl-title { font-weight: 600; font-size: 0.95rem; color: var(--color-text-primary); }
.tl-time { font-size: 0.8rem; color: var(--color-text-muted); margin-top: 0.25rem; font-weight: 500; }

.btn-text {
  background: var(--color-surface-2);
  border: 1px solid transparent;
  color: var(--color-primary);
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
.skeleton-hero { height: 280px; background: var(--color-surface-2); border-radius: 1.5rem; margin-bottom: 2.5rem; width: 100%; animation: pulse 1.5s infinite ease-in-out; }
.skeleton-grid { display: grid; grid-template-columns: repeat(4, 1fr); gap: 1.5rem; width: 100%; margin-bottom: 2rem; }
.skeleton-card { height: 200px; background: var(--color-surface-2); border-radius: 1.25rem; animation: pulse 1.5s infinite ease-in-out; animation-delay: 0.2s; }
.loading-text { font-size: 1.125rem; color: var(--color-text-muted); font-weight: 500; animation: pulse 1.5s infinite; }

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
  .optimization-dashboard { padding: 1.25rem; }
  .score-cards-grid { grid-template-columns: 1fr; }
  .skeleton-grid { grid-template-columns: 1fr; }
}
</style>
