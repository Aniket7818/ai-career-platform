<template>
  <div class="optimization-dashboard">
    <div v-if="loading" class="dashboard-loading">
      <div class="skeleton-hero"></div>
      <div class="skeleton-grid">
        <div class="skeleton-card"></div>
        <div class="skeleton-card"></div>
        <div class="skeleton-card"></div>
        <div class="skeleton-card"></div>
      </div>
      <div class="loading-text">Analyzing your resume...</div>
    </div>

    <div v-else-if="!scoreData" class="dashboard-empty">
      <div class="placeholder-icon">🚀</div>
      <h2>AI Resume Optimization</h2>
      <p>Unlock the full potential of your resume. Our AI will analyze your content, keywords, and ATS formatting to help you land more interviews.</p>
      <button class="btn-primary btn-large" @click="analyze" :disabled="analyzing">
        <svg v-if="analyzing" class="spin size-5 mr-2" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M21 12a9 9 0 11-6.219-8.56"/></svg>
        <svg v-else class="size-5 mr-2" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M13 10V3L4 14h7v7l9-11h-7z"/></svg>
        {{ analyzing ? 'Running Analysis...' : 'Start AI Analysis' }}
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
        @optimize="handleOptimize"
      />

      <!-- Section 6: Optimization Progress -->
      <ProgressCard
        class="mb-8"
        :progress="optimizationProgress"
        :remainingIssues="totalIssues"
        :estimatedFinal="Math.min(100, (scoreData.overall_score || 0) + potentialGain)"
        :potentialIncrease="potentialGain"
      />

      <!-- Section 2: Score Cards -->
      <div class="section-block">
        <h2 class="section-title">Score Breakdown</h2>
        <div class="score-cards-grid">
          <ScoreCard
            title="ATS Formatting"
            :score="scoreData.ats_score || 0"
            description="How well applicant tracking systems can read your resume."
            strength="Clean structure detected"
            weakness="Missing some standard headers"
            :estimatedGain="5"
            @view="handleViewDetails('ats')"
          />
          <ScoreCard
            title="Content Quality"
            :score="scoreData.content_score || 0"
            description="The impact and clarity of your bullet points."
            strength="Action verbs used frequently"
            weakness="Lacking quantifiable metrics"
            :estimatedGain="12"
            @view="handleViewDetails('content')"
          />
          <ScoreCard
            title="Keywords"
            :score="scoreData.keyword_score || 0"
            description="Industry-specific terms and skills found."
            strength="Good core technical skills"
            weakness="Missing role-specific keywords"
            :estimatedGain="8"
            @view="handleViewDetails('keywords')"
          />
          <ScoreCard
            title="Completeness"
            :score="scoreData.completeness_score || 0"
            description="Presence of all critical resume sections."
            strength="Experience and Education present"
            weakness="Summary is a bit short"
            :estimatedGain="3"
            @view="handleViewDetails('completeness')"
          />
        </div>
      </div>

      <div class="dashboard-main-grid">
        <div class="main-column">
          <!-- Section 3 & 4: Priority Issues & Quick Wins -->
          <div class="section-block">
            <h2 class="section-title">Actionable Insights</h2>
            
            <div class="issues-list">
              <IssueCard
                v-if="!hasSummary"
                title="Professional Summary Missing"
                description="A strong summary immediately tells recruiters who you are and what you bring to the table."
                priority="HIGH"
                :gain="8"
                time="1 min"
                primaryActionLabel="Generate with AI"
                @fix="handleAiAction('generate_summary')"
                @dismiss="handleDismiss('summary')"
              />
              
              <IssueCard
                title="Missing Quantifiable Metrics"
                description="Your experience bullets lack numbers. Add metrics to show your actual impact."
                priority="MED"
                :gain="12"
                time="3 mins"
                primaryActionLabel="Rewrite with AI"
                @fix="handleAiAction('rewrite_experience')"
                @dismiss="handleDismiss('metrics')"
              />

              <IssueCard
                v-if="!hasLinkedIn"
                title="Missing LinkedIn Profile"
                description="Recruiters expect to see your LinkedIn profile URL."
                priority="QUICK"
                :gain="2"
                time="30 sec"
                primaryActionLabel="Add Link"
                @fix="handleAction('add_linkedin')"
                @dismiss="handleDismiss('linkedin')"
              />
            </div>
          </div>

          <!-- Section 5: Section Analysis -->
          <div class="section-block">
            <h2 class="section-title">Section Health</h2>
            <div class="health-cards-list">
              <SectionHealthCard
                title="Professional Summary"
                :progress="hasSummary ? 90 : 20"
                :issues="hasSummary ? [] : ['Section is missing entirely']"
                :suggestions="['Use AI to generate a targeted summary based on your experience']"
                @improve="handleAiAction('improve_summary')"
              />
              <SectionHealthCard
                title="Work Experience"
                :progress="scoreData.content_score || 60"
                :issues="['2 bullet points are too short', 'Missing measurable results in recent role']"
                :suggestions="['Expand on your leadership responsibilities', 'Add specific technologies used']"
                @improve="handleAiAction('improve_experience')"
              />
              <SectionHealthCard
                title="Skills"
                :progress="scoreData.keyword_score || 50"
                :issues="['Missing soft skills', 'No skill categories defined']"
                :suggestions="['Group skills by category (e.g. Frontend, Backend)']"
                @improve="handleAiAction('improve_skills')"
              />
            </div>
          </div>
        </div>

        <div class="sidebar-column">
          <!-- Section 8: AI Suggestions (Premium Feature) -->
          <div class="section-block premium-block">
            <div class="premium-header">
              <svg class="size-5 text-primary mr-2" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M5 3v4M3 5h4M6 17v4m-2-2h4m5-16l2.286 6.857L21 12l-5.714 2.143L13 21l-2.286-6.857L5 12l5.714-2.143L13 3z"/></svg>
              <h2 class="section-title mb-0">Premium AI Actions</h2>
            </div>
            
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
            </div>
          </div>

          <!-- Section 7: Improvement Timeline -->
          <div class="section-block timeline-block">
            <h2 class="section-title">Recent Optimizations</h2>
            <div class="timeline">
              <div class="timeline-item">
                <div class="tl-dot"></div>
                <div class="tl-content">
                  <div class="tl-title">Initial Analysis Complete</div>
                  <div class="tl-time">Just now</div>
                </div>
              </div>
              <div class="timeline-item">
                <div class="tl-dot"></div>
                <div class="tl-content">
                  <div class="tl-title">Version Created</div>
                  <div class="tl-time">5 mins ago</div>
                </div>
              </div>
            </div>
            <button class="btn-text mt-4" @click="handleAction('view_history')">View Full History &rarr;</button>
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

const props = defineProps({
  resumeId: { type: [String, Number], required: true }
})

const loading = ref(false)
const analyzing = ref(false)
const scoreData = ref(null)

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

// Placeholder Handlers
function handleOptimize() {
  console.log('Optimize triggered')
  alert('Optimization workflow will launch here.')
}

function handleViewDetails(section) {
  console.log('View details for:', section)
}

function handleAiAction(actionType) {
  console.log('AI Action Triggered:', actionType)
  alert(`AI Action [${actionType}] triggered. (Not consuming credits)`)
}

function handleAction(actionType) {
  console.log('Action Triggered:', actionType)
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
  padding: 2rem;
  max-width: 1400px;
  margin: 0 auto;
}

.dashboard-loading, .dashboard-empty {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  min-height: 400px;
  text-align: center;
  gap: 1.5rem;
}

.placeholder-icon { font-size: 4rem; margin-bottom: 1rem; }
.dashboard-empty h2 { font-size: 2rem; color: var(--color-text-primary); margin: 0; font-weight: 700; }
.dashboard-empty p { max-width: 500px; margin: 0; line-height: 1.6; color: var(--color-text-secondary); font-size: 1.125rem; }

.btn-large {
  padding: 1rem 2rem;
  font-size: 1.125rem;
  border-radius: 1rem;
}

.btn-primary {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  background: var(--color-primary);
  color: #fff;
  border: none;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.2s ease;
  box-shadow: 0 4px 12px rgba(99, 102, 241, 0.3);
}
.btn-primary:hover:not(:disabled) {
  transform: translateY(-2px);
  box-shadow: 0 6px 16px rgba(99, 102, 241, 0.4);
}
.btn-primary:disabled { opacity: 0.7; cursor: not-allowed; transform: none; }

.mb-8 { margin-bottom: 2rem; }
.mb-0 { margin-bottom: 0 !important; }
.mr-2 { margin-right: 0.5rem; }
.mt-4 { margin-top: 1rem; }
.size-5 { width: 1.25rem; height: 1.25rem; }
.text-primary { color: var(--color-primary); }

.section-block {
  margin-bottom: 2.5rem;
}

.section-title {
  font-size: 1.25rem;
  font-weight: 700;
  color: var(--color-text-primary);
  margin: 0 0 1.25rem 0;
}

.score-cards-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(240px, 1fr));
  gap: 1.5rem;
}

.dashboard-main-grid {
  display: grid;
  grid-template-columns: 2fr 1fr;
  gap: 2.5rem;
}

.issues-list, .health-cards-list, .ai-actions-list {
  display: flex;
  flex-direction: column;
  gap: 1rem;
}

.premium-block {
  background: linear-gradient(to bottom right, var(--color-surface), var(--color-surface-2));
  border-radius: 1.5rem;
  padding: 1.5rem;
  border: 1px solid var(--color-border);
}

.premium-header {
  display: flex;
  align-items: center;
  margin-bottom: 1.5rem;
}

.timeline-block {
  background: var(--color-surface);
  border-radius: 1rem;
  padding: 1.5rem;
  border: 1px solid var(--color-border);
}

.timeline {
  display: flex;
  flex-direction: column;
  gap: 1.5rem;
  position: relative;
  padding-left: 1rem;
}
.timeline::before {
  content: '';
  position: absolute;
  top: 0; left: 1.3rem; bottom: 0;
  width: 2px;
  background: var(--color-border);
}

.timeline-item {
  position: relative;
  display: flex;
  gap: 1rem;
}

.tl-dot {
  width: 12px; height: 12px;
  border-radius: 50%;
  background: var(--color-primary);
  border: 2px solid var(--color-surface);
  z-index: 1;
  margin-top: 0.25rem;
}

.tl-title { font-weight: 600; font-size: 0.875rem; color: var(--color-text-primary); }
.tl-time { font-size: 0.75rem; color: var(--color-text-muted); margin-top: 0.25rem; }

.btn-text {
  background: none; border: none; color: var(--color-primary);
  font-weight: 600; font-size: 0.875rem; padding: 0; cursor: pointer;
}
.btn-text:hover { text-decoration: underline; }

/* Skeletons */
.skeleton-hero { height: 250px; background: var(--color-surface-2); border-radius: 1.5rem; margin-bottom: 2rem; width: 100%; animation: pulse 1.5s infinite; }
.skeleton-grid { display: grid; grid-template-columns: repeat(4, 1fr); gap: 1.5rem; width: 100%; }
.skeleton-card { height: 180px; background: var(--color-surface-2); border-radius: 1rem; animation: pulse 1.5s infinite; }
.loading-text { font-size: 1.125rem; color: var(--color-text-muted); font-weight: 500; animation: pulse 1.5s infinite; }

@keyframes pulse {
  0% { opacity: 1; }
  50% { opacity: 0.5; }
  100% { opacity: 1; }
}

.spin { animation: spin 1s linear infinite; }
@keyframes spin { to { transform: rotate(360deg); } }

@media (max-width: 1024px) {
  .dashboard-main-grid { grid-template-columns: 1fr; }
  .skeleton-grid { grid-template-columns: repeat(2, 1fr); }
}
@media (max-width: 640px) {
  .optimization-dashboard { padding: 1rem; }
  .score-cards-grid { grid-template-columns: 1fr; }
  .skeleton-grid { grid-template-columns: 1fr; }
}
</style>
