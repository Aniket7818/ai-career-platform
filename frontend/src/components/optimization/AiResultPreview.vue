<template>
  <div v-if="modelValue" class="modal-backdrop">
    <div class="modal-content result-modal">
      <div class="modal-header">
        <div class="icon-wrap bg-success">
          <svg class="size-6 text-white" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M5 13l4 4L19 7"/></svg>
        </div>
        <div class="header-titles">
          <h2 v-if="actionType === 'generate_linkedin'">✓ LinkedIn Profile Optimized</h2>
          <h2 v-else-if="actionType === 'generate_cover_letter'">✓ Cover Letter Generated</h2>
          <h2 v-else>✓ AI Resume Optimization Complete</h2>
          <p class="subtitle">Review the generated content below</p>
        </div>
        <button class="btn-close" @click="discard('close')">&times;</button>
      </div>

      <div class="modal-body">
        
        <div v-if="aiStats" class="ai-stats-panel mb-6">
          <div class="stats-grid">
            <div class="stat-item">
              <span class="label">Credits Used</span>
              <span class="value text-primary font-bold">{{ aiStats.credits_used || creditCost }}</span>
            </div>
            <div class="stat-item">
              <span class="label">Remaining Credits</span>
              <span class="value font-bold">{{ remainingCredits }}</span>
            </div>
            <div v-if="actionType !== 'generate_linkedin' && actionType !== 'generate_cover_letter'" class="stat-item">
              <span class="label">Version Saved</span>
              <span class="value">{{ aiStats.version || 'Draft' }}</span>
            </div>
          </div>
        </div>

        <div class="preview-container">
          <div v-if="oldContent && actionType !== 'generate_cover_letter' && actionType !== 'generate_linkedin'" class="preview-panel old-panel">
            <h4>Current Content</h4>
            <div class="content-box">{{ oldContent }}</div>
          </div>
          
          <div class="preview-panel new-panel">
            <h4 v-if="actionType !== 'generate_linkedin'">AI Generated Content</h4>
            
            <!-- LinkedIn Mockup UI -->
            <div v-if="actionType === 'generate_linkedin'" class="linkedin-preview-container">
              
              <!-- LinkedIn Optimization Score Dashboard -->
              <div class="linkedin-score-dashboard">
                <div class="score-main-row">
                  <div class="score-circle-container">
                    <div class="score-circle" :style="`background: conic-gradient(rgb(var(--color-primary)) ${optimizationScore}%, rgba(99, 102, 241, 0.1) ${optimizationScore}% 100%)`">
                      <div class="score-inner">
                        <span class="score-number">{{ optimizationScore }}</span>
                        <span class="score-total">/100</span>
                      </div>
                    </div>
                    <div class="score-meta">
                      <h4>LinkedIn Optimization Score</h4>
                      <p class="score-desc">Based on keyword matching, character counts, and headline variety.</p>
                    </div>
                  </div>

                  <div class="visibility-meter">
                    <div class="meter-label-row">
                      <span>Recruiter Visibility:</span>
                      <strong class="visibility-status" :class="recruiterVisibility.toLowerCase().replace(' ', '-')">{{ recruiterVisibility }}</strong>
                    </div>
                    <div class="meter-bar-container">
                      <div class="meter-bar" :style="`width: ${optimizationScore}%`" :class="recruiterVisibility.toLowerCase().replace(' ', '-')"></div>
                    </div>
                  </div>
                </div>

                <div class="keyword-coverage">
                  <div class="coverage-label-row">
                    <span>Keyword Coverage Summary:</span>
                  </div>
                  <p class="coverage-text">
                    {{ keywordCoverageSummary }}
                  </p>
                </div>
              </div>

              <!-- Recruiter Insights Dashboard -->
              <div v-if="linkedinData?.insights" class="recruiter-insights-section">
                <h3 class="insights-title">
                  <svg class="size-6 text-primary mr-2" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z" />
                  </svg>
                  Recruiter Quality Insights
                </h3>
                <p class="insights-subtitle">
                  AI-evaluated metrics assessing your LinkedIn search readiness, leadership footprint, and structural optimization.
                </p>
                <div class="metrics-dashboard-grid">
                  <div v-for="(metricData, metricKey) in linkedinData.insights" :key="metricKey" class="metric-detail-card">
                    <div class="metric-card-header">
                      <span class="metric-card-label">{{ getMetricLabel(metricKey) }}</span>
                      <span class="metric-score-badge" :class="getScoreBadgeClass(metricData.score)">{{ metricData.score }}%</span>
                    </div>
                    <div class="metric-progress-container">
                      <div class="metric-progress-bar" :style="`width: ${metricData.score}%`" :class="getScoreBadgeClass(metricData.score)"></div>
                    </div>
                    <p class="metric-reasoning">{{ metricData.reasoning }}</p>
                    <div class="metric-suggestion-box">
                      <svg class="size-4 text-warning mr-1 shrink-0" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" d="M9.663 17h4.673M12 3v1m6.364 1.636l-.707.707M21 12h-1M4 12H3m3.343-5.657l-.707-.707m2.828 9.9a5 5 0 117.072 0l-.548.547A3.374 3.374 0 0014 18.469V19a2 2 0 11-4 0v-.531c0-.895-.356-1.754-.988-2.386l-.548-.547z" />
                      </svg>
                      <span class="suggestion-text">{{ metricData.improvement_suggestion }}</span>
                    </div>
                  </div>
                </div>
              </div>

              <!-- Improved Mockup Profile Card -->
              <div class="linkedin-card">
                <div class="linkedin-mock-banner">
                  <div class="banner-edit-hint">📷 Add custom background photo</div>
                </div>
                <div class="linkedin-mock-avatar-row">
                  <div class="linkedin-mock-avatar">
                    <svg class="avatar-placeholder-svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5">
                      <path stroke-linecap="round" stroke-linejoin="round" d="M15.75 6a3.75 3.75 0 1 1-7.5 0 3.75 3.75 0 0 1 7.5 0ZM4.501 20.118a7.5 7.5 0 0 1 14.998 0A17.933 17.933 0 0 1 12 21.75c-2.676 0-5.216-.584-7.499-1.632Z" />
                    </svg>
                  </div>
                  <div class="open-to-work-badge">
                    <span>#OpenToWork</span>
                  </div>
                </div>
                <div class="linkedin-mock-profile-details">
                  <div class="linkedin-mock-name-badge">
                    <span class="mock-name">{{ profileName }}</span>
                    <span class="mock-badge">1st</span>
                  </div>
                  
                  <!-- Active Headline Preview Section -->
                  <div class="linkedin-mock-section headline-mock-section">
                    <div class="section-label-row">
                      <span class="section-label">Active Headline Preview</span>
                      <button class="btn-copy-small" @click="copyHeadline" :disabled="isCopyingHeadline">
                        <svg v-if="!isCopiedHeadline" class="size-icon-sm mr-1" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M8 16H6a2 2 0 01-2-2V6a2 2 0 012-2h8a2 2 0 012 2v2m-6 12h8a2 2 0 002-2v-8a2 2 0 00-2-2h-8a2 2 0 00-2 2v8a2 2 0 002 2z"/></svg>
                        <span v-if="isCopiedHeadline">✓ Headline Copied</span>
                        <span v-else>Copy Headline</span>
                      </button>
                    </div>
                    
                    <div class="linkedin-text-container headline-text active-preview">
                      <transition name="fade-slide" mode="out-in">
                        <div :key="selectedHeadlineText">
                          {{ selectedHeadlineText || 'No headline selected.' }}
                        </div>
                      </transition>
                    </div>
                  </div>

                  <!-- Location, Connections & Contact Row -->
                  <div class="profile-meta-row mt-3">
                    <span class="profile-meta-item location">{{ profileLocation }}</span>
                    <span class="separator-dot">•</span>
                    <span class="profile-meta-item connections">500+ connections</span>
                    <span class="separator-dot">•</span>
                    <span class="profile-meta-item contact-info">Contact info</span>
                  </div>

                  <!-- Mock Profile Action Buttons -->
                  <div class="linkedin-mock-actions mt-4">
                    <button class="btn-linkedin-blue">Open to</button>
                    <button class="btn-linkedin-outline">Add profile section</button>
                    <button class="btn-linkedin-gray">More</button>
                  </div>
                </div>
              </div>

              <!-- Headline suggestions selection panel -->
              <div class="suggestions-card">
                <h3 class="card-title-main">Headline Suggestions</h3>
                <p class="card-subtitle-main">Select one of the optimized options below to preview it on your profile mockup and copy it.</p>
                
                <div class="headline-suggestions-list">
                  <div v-for="(opt, idx) in linkedinData?.headlineOptions" 
                       :key="idx" 
                       class="suggestion-item-card" 
                       :class="{ active: selectedHeadlineIndex === idx }"
                       @click="selectedHeadlineIndex = idx">
                    <div class="suggestion-header">
                      <div class="suggestion-radio-row">
                        <input type="radio" :value="idx" v-model="selectedHeadlineIndex" class="suggestion-radio" @click.stop="selectedHeadlineIndex = idx" />
                        <span class="suggestion-type-badge">{{ opt.type }}</span>
                      </div>
                      
                      <div class="suggestion-actions">
                        <!-- Used / Remaining Counter with dynamic status class -->
                        <div class="character-counter-badge" :class="getHeadlineCounterClass(opt.text.length)">
                          {{ opt.text.length }} / 220 chars ({{ 220 - opt.text.length }} remaining)
                        </div>
                        <button class="btn-copy-tiny" @click.stop="copyHeadlineOption(opt.text, idx)">
                          <span v-if="copiedHeadlineOptionIndex === idx">✓ Copied</span>
                          <span v-else>Copy Headline</span>
                        </button>
                      </div>
                    </div>
                    <p class="suggestion-text-preview">{{ opt.text }}</p>
                    <!-- Strategy Explanation Text -->
                    <p class="suggestion-explanation">{{ getHeadlineExplanation(opt.type) }}</p>
                  </div>
                </div>
              </div>

              <!-- About Section UI -->
              <div class="about-card">
                <div class="card-title-row">
                  <h3 class="card-title-main">LinkedIn About</h3>
                  <div class="about-header-actions">
                    <div class="character-counter-badge" :class="getAboutCounterClass(aboutText.length)">
                      {{ aboutText.length }} / 2600 chars ({{ 2600 - aboutText.length }} remaining)
                    </div>
                    <button class="btn-copy-tiny-compact" @click="copyAbout" :disabled="isCopyingAbout">
                      <span v-if="isCopiedAbout">✓ Copied</span>
                      <span v-else>Copy About</span>
                    </button>
                  </div>
                </div>
                <div class="about-textarea-container">
                  <div class="linkedin-text-container about-text scrollable-about">
                    {{ aboutText || 'No About section generated.' }}
                  </div>
                </div>
              </div>

              <!-- Actionable Checklist panel -->
              <div class="profile-tips-card">
                <h3 class="card-title-main">💡 Actionable Profile Checklist</h3>
                <p class="card-subtitle-main">Follow these manual updates on your LinkedIn profile to maximize recruiter outreach and keyword discoverability.</p>
                
                <div class="tips-checklist">
                  <div class="tip-checkbox-item">
                    <input type="checkbox" id="tip-open-to-work" class="tip-checkbox" />
                    <label for="tip-open-to-work" class="tip-label">
                      <strong>Activate "Open to Work"</strong>
                      <span>Add target roles matching <strong>{{ targetRoleName }}</strong> to your preferences to raise visibility filters.</span>
                    </label>
                  </div>
                  
                  <div class="tip-checkbox-item">
                    <input type="checkbox" id="tip-featured" class="tip-checkbox" />
                    <label for="tip-featured" class="tip-label">
                      <strong>Featured Projects Section</strong>
                      <span>Link directly to your key projects or your portfolio website to build solid visual credentials.</span>
                    </label>
                  </div>

                  <div class="tip-checkbox-item">
                    <input type="checkbox" id="tip-endorsements" class="tip-checkbox" />
                    <label for="tip-endorsements" class="tip-label">
                      <strong>Ask for Endorsements</strong>
                      <span>Request colleagues to endorse you for high-frequency skills like <strong>{{ topSkills[0] || 'Software Engineering' }}</strong>.</span>
                    </label>
                  </div>

                  <div class="tip-checkbox-item">
                    <input type="checkbox" id="tip-certifications" class="tip-checkbox" />
                    <label for="tip-certifications" class="tip-label">
                      <strong>Import Certifications & Badges</strong>
                      <span>Add official resume licenses to your profile badges to satisfy technical recruiters.</span>
                    </label>
                  </div>
                </div>
              </div>

              <!-- Insights Panel -->
              <div class="insights-grid">
                <!-- Personal Brand Statement -->
                <div v-if="linkedinData?.personalBrand" class="insight-card full-width">
                  <div class="insight-header">
                    <span class="insight-label">Personal Brand Statement</span>
                    <button class="btn-copy-tiny" @click="copyText(linkedinData.personalBrand, 'brand')">
                      <span v-if="copiedBrand">✓ Copied</span>
                      <span v-else>Copy Brand Statement</span>
                    </button>
                  </div>
                  <div class="insight-body">
                    <p class="brand-text">"{{ linkedinData.personalBrand }}"</p>
                  </div>
                </div>

                <!-- Top Skills Extracted from Resume -->
                <div class="insight-card">
                  <div class="insight-header">
                    <span class="insight-label">Top Skills (Extracted)</span>
                    <button class="btn-copy-tiny" @click="copyTags(topSkills, 'skills')">
                      <span v-if="copiedSkills">✓ Copied</span>
                      <span v-else>Copy Tags</span>
                    </button>
                  </div>
                  <div class="insight-body tags-container">
                    <span v-for="tag in topSkills" :key="tag" class="insight-tag skill-tag">{{ tag }}</span>
                  </div>
                </div>

                <!-- Target Industries -->
                <div class="insight-card">
                  <div class="insight-header">
                    <span class="insight-label">Target Industries</span>
                    <button class="btn-copy-tiny" @click="copyTags(targetIndustries, 'industries')">
                      <span v-if="copiedIndustries">✓ Copied</span>
                      <span v-else>Copy Tags</span>
                    </button>
                  </div>
                  <div class="insight-body tags-container">
                    <span v-for="tag in targetIndustries" :key="tag" class="insight-tag industry-tag">{{ tag }}</span>
                  </div>
                </div>

                <!-- Target Roles -->
                <div v-if="targetRoles?.length" class="insight-card">
                  <div class="insight-header">
                    <span class="insight-label">Target Roles</span>
                    <button class="btn-copy-tiny" @click="copyTags(targetRoles, 'roles')">
                      <span v-if="copiedRoles">✓ Copied</span>
                      <span v-else>Copy Tags</span>
                    </button>
                  </div>
                  <div class="insight-body tags-container">
                    <span v-for="tag in targetRoles" :key="tag" class="insight-tag role-tag">{{ tag }}</span>
                  </div>
                </div>

                <!-- Recruiter Keywords -->
                <div v-if="linkedinData?.recruiterKeywords?.length" class="insight-card">
                  <div class="insight-header">
                    <span class="insight-label">Recruiter Keywords</span>
                    <button class="btn-copy-tiny" @click="copyTags(linkedinData.recruiterKeywords, 'keywords')">
                      <span v-if="copiedKeywords">✓ Copied</span>
                      <span v-else>Copy Tags</span>
                    </button>
                  </div>
                  <div class="insight-body tags-container">
                    <span v-for="tag in linkedinData.recruiterKeywords" :key="tag" class="insight-tag keyword-tag">{{ tag }}</span>
                  </div>
                </div>

                <!-- Top Technologies -->
                <div v-if="linkedinData?.topTechnologies?.length" class="insight-card">
                  <div class="insight-header">
                    <span class="insight-label">Top Technologies</span>
                    <button class="btn-copy-tiny" @click="copyTags(linkedinData.topTechnologies, 'technologies')">
                      <span v-if="copiedTechnologies">✓ Copied</span>
                      <span v-else>Copy Tags</span>
                    </button>
                  </div>
                  <div class="insight-body tags-container">
                    <span v-for="tag in linkedinData.topTechnologies" :key="tag" class="insight-tag tech-tag">{{ tag }}</span>
                  </div>
                </div>

                <!-- Core Expertise -->
                <div v-if="linkedinData?.coreExpertise?.length" class="insight-card">
                  <div class="insight-header">
                    <span class="insight-label">Core Expertise</span>
                    <button class="btn-copy-tiny" @click="copyTags(linkedinData.coreExpertise, 'expertise')">
                      <span v-if="copiedExpertise">✓ Copied</span>
                      <span v-else>Copy Tags</span>
                    </button>
                  </div>
                  <div class="insight-body tags-container">
                    <span v-for="tag in linkedinData.coreExpertise" :key="tag" class="insight-tag expertise-tag">{{ tag }}</span>
                  </div>
                </div>

                <!-- Networking Topics -->
                <div v-if="linkedinData?.networkingTopics?.length" class="insight-card">
                  <div class="insight-header">
                    <span class="insight-label">Networking Topics</span>
                    <button class="btn-copy-tiny" @click="copyTags(linkedinData.networkingTopics, 'topics')">
                      <span v-if="copiedTopics">✓ Copied</span>
                      <span v-else>Copy Tags</span>
                    </button>
                  </div>
                  <div class="insight-body tags-container">
                    <span v-for="tag in linkedinData.networkingTopics" :key="tag" class="insight-tag topic-tag">{{ tag }}</span>
                  </div>
                </div>
              </div>

              <!-- Master Copy All -->
              <div class="linkedin-mock-footer-actions">
                <button class="btn-copy-all" @click="copyAll" :disabled="isCopyingAll">
                  <svg class="size-4 mr-2" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M8 16H6a2 2 0 01-2-2V6a2 2 0 012-2h8a2 2 0 012 2v2m-6 12h8a2 2 0 002-2v-8a2 2 0 00-2-2h-8a2 2 0 00-2 2v8a2 2 0 002 2z"/></svg>
                  <span v-if="isCopiedAll">✓ All LinkedIn Content Copied</span>
                  <span v-else>Copy All LinkedIn Content</span>
                </button>
              </div>

            </div>

            <!-- Standard Preview Box -->
            <div v-else class="content-box ai-box">
              <pre v-if="isJson(newContent)">{{ formatJson(newContent) }}</pre>
              <div v-else class="text-content">{{ newContent }}</div>
            </div>
          </div>
        </div>

      </div>

      <div class="modal-footer">
        <button class="btn-secondary" @click="discard('discard')">Discard</button>
        <div class="flex-spacer"></div>
        <button v-if="actionType === 'generate_linkedin'" class="btn-primary" @click="discard('done')">
          Done
        </button>
        <button v-else-if="actionType !== 'generate_linkedin'" class="btn-outline" @click="copy" :disabled="isCopying">
          <template v-if="isCopying">
            <svg class="animate-spin size-4 mr-2" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M21 12a9 9 0 11-18 0 9 9 0 0118 0z" stroke-opacity="0.25"/><path d="M12 3a9 9 0 019 9"/></svg>
            Copying...
          </template>
          <template v-else-if="isCopied">
            <svg class="size-4 mr-2 text-emerald-500" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M5 13l4 4L19 7"/></svg>
            Copied
          </template>
          <template v-else>
            <svg class="size-4 mr-2" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M8 16H6a2 2 0 01-2-2V6a2 2 0 012-2h8a2 2 0 012 2v2m-6 12h8a2 2 0 002-2v-8a2 2 0 00-2-2h-8a2 2 0 00-2 2v8a2 2 0 002 2z"/></svg>
            Copy
          </template>
        </button>
        <button v-if="actionType !== 'generate_cover_letter' && actionType !== 'generate_linkedin'" class="btn-primary" @click="apply">
          Apply
        </button>
      </div>
    </div>
  </div>
</template>

<script setup>
import { computed, ref, watch } from 'vue'
import ClipboardService from '../../services/clipboard'

const props = defineProps({
  modelValue: { type: Boolean, default: false },
  oldContent: { type: String, default: '' },
  newContent: { type: [String, Object, Array], default: '' },
  actionType: { type: String, default: '' },
  creditCost: { type: Number, default: 0 },
  remainingCredits: { type: Number, default: 0 },
  aiStats: { type: Object, default: () => null },
  resume: { type: Object, default: () => null }
})

const emit = defineEmits(['update:modelValue', 'apply', 'discard'])

const isCopying = ref(false)
const isCopied = ref(false)

const isCopyingHeadline = ref(false)
const isCopiedHeadline = ref(false)
const isCopyingAbout = ref(false)
const isCopiedAbout = ref(false)
const isCopyingAll = ref(false)
const isCopiedAll = ref(false)
const hasCopied = ref(false)

// Selectable suggestions states
const selectedHeadlineIndex = ref(0)
const copiedHeadlineOptionIndex = ref(-1)
const copiedBrand = ref(false)
const copiedTechnologies = ref(false)
const copiedExpertise = ref(false)
const copiedKeywords = ref(false)
const copiedTopics = ref(false)
const copiedSkills = ref(false)
const copiedIndustries = ref(false)
const copiedRoles = ref(false)

watch(() => props.newContent, () => {
  selectedHeadlineIndex.value = 0
}, { immediate: true, deep: true })

const linkedinData = computed(() => {
  if (!props.newContent) return null
  
  let parsed = null
  if (typeof props.newContent === 'object' && props.newContent !== null) {
    parsed = props.newContent
  } else {
    try {
      parsed = JSON.parse(props.newContent)
    } catch (e) {
      // Ignore parser issues
    }
  }
  
  if (parsed && typeof parsed === 'object') {
    let headlineOptions = parsed.headline_options || parsed.headlineOptions || parsed.headlines || []
    if (!Array.isArray(headlineOptions)) {
      headlineOptions = []
    }
    
    if (headlineOptions.length === 0 && (parsed.headline || parsed.headlineText)) {
      const singleH = parsed.headline || parsed.headlineText
      headlineOptions = [
        { type: 'ATS Optimized', text: singleH },
        { type: 'Recruiter Focused', text: singleH },
        { type: 'Personal Branding', text: singleH },
        { type: 'Technical', text: singleH },
        { type: 'Modern & Concise', text: singleH }
      ]
    }
    
    return {
      headlineOptions: headlineOptions.map(opt => {
        if (typeof opt === 'string') {
          return { type: 'General', text: opt }
        }
        return {
          type: opt.type || 'General',
          text: opt.text || opt.headline || ''
        }
      }),
      about: parsed.about || parsed.aboutSection || '',
      topTechnologies: parsed.top_technologies || parsed.topTechnologies || [],
      coreExpertise: parsed.core_expertise || parsed.coreExpertise || [],
      recruiterKeywords: parsed.recruiter_keywords || parsed.recruiterKeywords || [],
      networkingTopics: parsed.networking_topics || parsed.networkingTopics || [],
      personalBrand: parsed.personal_brand || parsed.personalBrand || '',
      targetIndustries: parsed.target_industries || parsed.targetIndustries || [],
      targetRoles: parsed.target_roles || parsed.targetRoles || [],
      insights: parsed.insights || null
    }
  }
  
  // Text extraction fallback
  const headlineMatch = props.newContent.match(/headline["\s:]+([^"\n]+)/i) || props.newContent.match(/headline\s*\-*\s*\n+([^]+?)(?=\n+about|$)/i)
  const aboutMatch = props.newContent.match(/about["\s:]+([^"]+)/i) || props.newContent.match(/about\s*\-*\s*\n+([^]+)/i)
  const singleH = headlineMatch ? headlineMatch[1].trim() : 'Professional Profile'
  
  return {
    headlineOptions: [
      { type: 'ATS Optimized', text: singleH },
      { type: 'Recruiter Focused', text: singleH },
      { type: 'Personal Branding', text: singleH },
      { type: 'Technical', text: singleH },
      { type: 'Modern & Concise', text: singleH }
    ],
    about: aboutMatch ? aboutMatch[1].trim() : props.newContent,
    topTechnologies: [],
    coreExpertise: [],
    recruiterKeywords: [],
    networkingTopics: [],
    personalBrand: '',
    targetIndustries: [],
    targetRoles: [],
    insights: null
  }
})

const profileName = computed(() => props.resume?.content?.personal?.fullName || 'Your Name')
const profileLocation = computed(() => props.resume?.content?.personal?.location || 'San Francisco Bay Area')
const targetRoleName = computed(() => props.resume?.content?.target_role || 'Software Engineer')

const topSkills = computed(() => {
  const skillsObj = props.resume?.content?.skills
  if (!skillsObj) return ['Software Engineering', 'System Design', 'API Development']
  const allSkills = []
  if (Array.isArray(skillsObj)) {
    allSkills.push(...skillsObj)
  } else if (typeof skillsObj === 'object') {
    Object.values(skillsObj).forEach(val => {
      if (Array.isArray(val)) {
        allSkills.push(...val)
      } else if (typeof val === 'string') {
        allSkills.push(...val.split(',').map(s => s.trim()))
      }
    })
  }
  const uniq = [...new Set(allSkills.filter(Boolean))].map(s => {
    if (typeof s === 'object' && s !== null) return s.name || s.skill || ''
    return String(s)
  }).filter(s => s.length > 0 && s.length < 30)

  return uniq.length > 0 ? uniq.slice(0, 8) : ['Software Engineering', 'System Design', 'API Development']
})

const targetIndustries = computed(() => {
  if (linkedinData.value?.targetIndustries?.length) {
    return linkedinData.value.targetIndustries
  }
  const ind = props.resume?.content?.personal?.industry || props.resume?.content?.industry
  if (ind && typeof ind === 'string') {
    return ind.split(',').map(s => s.trim()).filter(Boolean)
  }
  const role = targetRoleName.value.toLowerCase()
  if (role.includes('software') || role.includes('developer') || role.includes('tech') || role.includes('frontend') || role.includes('backend')) {
    return ['Information Technology', 'Software Development', 'Internet Services']
  } else if (role.includes('finance') || role.includes('fintech') || role.includes('bank')) {
    return ['Financial Services', 'FinTech', 'Banking']
  } else if (role.includes('health') || role.includes('medical') || role.includes('nurse')) {
    return ['Healthcare', 'Medical Technology', 'Biotechnology']
  }
  return ['Technology', 'Professional Services']
})

const targetRoles = computed(() => {
  if (linkedinData.value?.targetRoles?.length) {
    return linkedinData.value.targetRoles
  }
  return [targetRoleName.value]
})

const optimizationScore = computed(() => {
  if (linkedinData.value?.insights) {
    const values = Object.values(linkedinData.value.insights).map(m => m.score || 0)
    if (values.length > 0) {
      return Math.round(values.reduce((a, b) => a + b, 0) / values.length)
    }
  }
  let score = 50 // Base score

  // 1. Headline length (ideal is 180 to 220)
  const hlLength = selectedHeadlineText.value?.length || 0
  if (hlLength >= 180 && hlLength <= 220) score += 20
  else if (hlLength > 100 && hlLength < 180) score += 10
  else if (hlLength > 220) score -= 10

  // 2. About section length (ideal is 1200 to 2400)
  const abLength = aboutText.value?.length || 0
  if (abLength >= 1200 && abLength <= 2500) score += 20
  else if (abLength >= 600 && abLength < 1200) score += 10
  else if (abLength > 0 && abLength < 600) score += 5

  // 3. Keywords density
  const techCount = linkedinData.value?.topTechnologies?.length || 0
  const kwCount = linkedinData.value?.recruiterKeywords?.length || 0
  if (techCount > 3) score += 5
  if (kwCount > 3) score += 5

  return Math.min(100, Math.max(0, score))
})

const recruiterVisibility = computed(() => {
  const score = optimizationScore.value
  if (score >= 85) return 'Very High'
  if (score >= 70) return 'High'
  if (score >= 50) return 'Medium'
  return 'Low'
})

const keywordCoverageSummary = computed(() => {
  if (linkedinData.value?.insights?.keyword_coverage) {
    return linkedinData.value.insights.keyword_coverage.reasoning
  }
  const techCount = linkedinData.value?.topTechnologies?.length || 0
  const skillCount = topSkills.value?.length || 0
  if (techCount + skillCount > 10) {
    return 'Excellent keyword coverage across your target role and skills list.'
  } else if (techCount + skillCount > 5) {
    return 'Good keyword coverage; your primary skills are represented.'
  } else {
    return 'Moderate coverage. Add more specific technologies to improve visibility.'
  }
})

const selectedHeadlineText = computed(() => {
  const opts = linkedinData.value?.headlineOptions || []
  if (opts.length > 0 && selectedHeadlineIndex.value < opts.length) {
    return opts[selectedHeadlineIndex.value].text
  }
  return ''
})

const aboutText = computed(() => {
  return linkedinData.value?.about || ''
})

function isJson(val) {
  return typeof val === 'object' && val !== null
}

function formatJson(val) {
  return JSON.stringify(val, null, 2)
}

function discard(origin = 'discard') {
  emit('discard', origin)
  emit('update:modelValue', false)
}

function apply() {
  emit('apply')
  emit('update:modelValue', false)
}

async function copy() {
  hasCopied.value = true
  const text = isJson(props.newContent) ? formatJson(props.newContent) : props.newContent
  isCopying.value = true
  await new Promise(resolve => setTimeout(resolve, 150))
  isCopying.value = false
  
  const success = await ClipboardService.copy(text)
  if (success) {
    isCopied.value = true
    setTimeout(() => {
      isCopied.value = false
    }, 2000)
  }
}

async function copyHeadline() {
  hasCopied.value = true
  const text = selectedHeadlineText.value
  isCopyingHeadline.value = true
  await new Promise(resolve => setTimeout(resolve, 150))
  isCopyingHeadline.value = false
  
  const success = await ClipboardService.copy(text, {
    successTitle: 'LinkedIn headline copied.',
    successMessage: 'The selected LinkedIn headline was copied to your clipboard.'
  })
  if (success) {
    isCopiedHeadline.value = true
    setTimeout(() => {
      isCopiedHeadline.value = false
    }, 2000)
  }
}

async function copyHeadlineOption(text, idx) {
  hasCopied.value = true
  const success = await ClipboardService.copy(text, {
    successTitle: 'Headline copied.',
    successMessage: `Copied headline suggestion (${linkedinData.value?.headlineOptions[idx]?.type || 'Option'}).`
  })
  if (success) {
    copiedHeadlineOptionIndex.value = idx
    setTimeout(() => {
      if (copiedHeadlineOptionIndex.value === idx) {
        copiedHeadlineOptionIndex.value = -1
      }
    }, 2000)
  }
}

async function copyAbout() {
  hasCopied.value = true
  const text = aboutText.value
  isCopyingAbout.value = true
  await new Promise(resolve => setTimeout(resolve, 150))
  isCopyingAbout.value = false
  
  const success = await ClipboardService.copy(text, {
    successTitle: 'LinkedIn About copied.',
    successMessage: 'The generated LinkedIn About section was copied to your clipboard.'
  })
  if (success) {
    isCopiedAbout.value = true
    setTimeout(() => {
      isCopiedAbout.value = false
    }, 2000)
  }
}

async function copyText(text, type) {
  hasCopied.value = true
  const success = await ClipboardService.copy(text, {
    successTitle: 'Content copied.',
    successMessage: 'Copied personal brand statement.'
  })
  if (success) {
    if (type === 'brand') {
      copiedBrand.value = true
      setTimeout(() => { copiedBrand.value = false }, 2000)
    }
  }
}

async function copyTags(tags, type) {
  hasCopied.value = true
  const text = tags.join(', ')
  const success = await ClipboardService.copy(text, {
    successTitle: 'Tags copied.',
    successMessage: `Copied ${tags.length} items to clipboard.`
  })
  if (success) {
    if (type === 'technologies') {
      copiedTechnologies.value = true
      setTimeout(() => { copiedTechnologies.value = false }, 2000)
    } else if (type === 'expertise') {
      copiedExpertise.value = true
      setTimeout(() => { copiedExpertise.value = false }, 2000)
    } else if (type === 'keywords') {
      copiedKeywords.value = true
      setTimeout(() => { copiedKeywords.value = false }, 2000)
    } else if (type === 'topics') {
      copiedTopics.value = true
      setTimeout(() => { copiedTopics.value = false }, 2000)
    } else if (type === 'skills') {
      copiedSkills.value = true
      setTimeout(() => { copiedSkills.value = false }, 2000)
    } else if (type === 'industries') {
      copiedIndustries.value = true
      setTimeout(() => { copiedIndustries.value = false }, 2000)
    } else if (type === 'roles') {
      copiedRoles.value = true
      setTimeout(() => { copiedRoles.value = false }, 2000)
    }
  }
}

async function copyAll() {
  hasCopied.value = true
  const data = linkedinData.value
  if (!data) return

  const formattedText = [
    `LinkedIn Headline (Selected Option: ${selectedHeadlineText.value ? (data.headlineOptions[selectedHeadlineIndex.value]?.type || 'Selected') : 'None'})`,
    `--------------------------------------------------------------------------------`,
    selectedHeadlineText.value,
    ``,
    `LinkedIn About`,
    `--------------`,
    data.about,
    ``,
    `Personal Brand Statement`,
    `------------------------`,
    data.personalBrand || 'None',
    ``,
    `Top Technologies: ${data.topTechnologies?.join(', ') || 'None'}`,
    `Core Expertise: ${data.coreExpertise?.join(', ') || 'None'}`,
    `Recruiter Keywords: ${data.recruiterKeywords?.join(', ') || 'None'}`,
    `Networking Topics: ${data.networkingTopics?.join(', ') || 'None'}`,
    `Target Industries: ${targetIndustries.value?.join(', ') || 'None'}`,
    `Target Roles: ${targetRoles.value?.join(', ') || 'None'}`
  ].join('\n')

  isCopyingAll.value = true
  const success = await ClipboardService.copy(formattedText, {
    successTitle: 'LinkedIn content copied.',
    successMessage: 'All optimized LinkedIn content was copied to your clipboard.'
  })
  isCopyingAll.value = false
  if (success) {
    isCopiedAll.value = true
    setTimeout(() => {
      isCopiedAll.value = false
    }, 2000)
  }
}

function getHeadlineExplanation(type) {
  const map = {
    'ATS Optimized': 'Best for passing automated resume screening filters (ATS) by matching high-frequency industry keywords.',
    'Recruiter Focused': 'Best for active recruiter search queries on LinkedIn Recruiter; maximizes search relevance for your target role.',
    'Personal Branding': 'Best for networking, building thought leadership, and making a memorable first impression on profile visitors.',
    'Technical': 'Best for technical recruiters and hiring managers who want to see your exact tools, programming languages, and tech stack immediately.',
    'Modern & Concise': 'Best for a clean, professional, and punchy layout that gets straight to the point without clutter.'
  }
  return map[type] || 'Optimized profile strategy.'
}

function getHeadlineCounterClass(len) {
  if (len > 220) return 'error-limit'
  if (len >= 210) return 'warning-limit'
  return 'success-limit'
}

function getAboutCounterClass(len) {
  if (len > 2600 || len < 300) return 'error-limit'
  if (len >= 2500 || len < 500) return 'warning-limit'
  return 'success-limit'
}

function getMetricLabel(key) {
  const map = {
    keyword_coverage: 'Keyword Coverage',
    recruiter_visibility: 'Recruiter Visibility',
    headline_strength: 'Headline Strength',
    technical_depth: 'Technical Depth',
    leadership_signals: 'Leadership Signals',
    business_impact: 'Business Impact',
    achievement_strength: 'Achievement Strength',
    ats_match: 'ATS Match',
    networking_readiness: 'Networking Readiness'
  }
  return map[key] || key.replace(/_/g, ' ').replace(/\b\w/g, c => c.toUpperCase())
}

function getScoreBadgeClass(score) {
  if (score >= 80) return 'badge-success'
  if (score >= 60) return 'badge-warning'
  return 'badge-danger'
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
  background: rgb(var(--color-surface));
  border-radius: 1.5rem;
  width: 95%;
  max-width: 950px;
  max-height: 90vh;
  display: flex;
  flex-direction: column;
  box-shadow: 0 20px 40px rgba(0,0,0,0.15);
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

.header-titles {
  flex: 1;
  min-width: 0;
}
.header-titles h2 {
  margin: 0 0 0.25rem 0;
  font-size: 1.25rem;
  font-weight: 700;
  color: rgb(var(--color-text-primary));
}
.subtitle {
  margin: 0;
  font-size: 0.875rem;
  color: rgb(var(--color-text-secondary));
}

.btn-close {
  background: none;
  border: none;
  font-size: 1.5rem;
  color: rgb(var(--color-text-muted));
  cursor: pointer;
  transition: color 0.2s;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 0;
  width: 32px;
  height: 32px;
  flex-shrink: 0;
}
.btn-close:hover { color: rgb(var(--color-text-primary)); }

.modal-body {
  padding: 2rem;
  overflow-y: auto;
  flex: 1;
  min-height: 0;
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
  color: rgb(var(--color-text-secondary));
  font-weight: 600;
}

.content-box {
  flex: 1;
  background: rgb(var(--color-surface-hover));
  border: 1px solid rgb(var(--color-border));
  border-radius: 1rem;
  padding: 1.25rem;
  font-size: 0.95rem;
  color: rgb(var(--color-text-primary));
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
  background: rgb(var(--color-surface-hover));
  border-top: 1px solid rgb(var(--color-border));
  display: flex;
  align-items: center;
  gap: 1rem;
}

.flex-spacer {
  flex: 1;
}

.btn-primary {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  gap: 0.5rem;
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

.btn-secondary {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  gap: 0.5rem;
  padding: 0.75rem 1.5rem;
  background: rgb(var(--color-surface));
  border: 1px solid rgb(var(--color-border));
  border-radius: 0.75rem;
  font-weight: 600;
  color: rgb(var(--color-text-primary));
  cursor: pointer;
  transition: all 0.2s;
}
.btn-secondary:hover {
  background: rgb(var(--color-surface-hover));
}

.btn-outline {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  gap: 0.5rem;
  padding: 0.75rem 1.5rem;
  background: transparent;
  border: 1px solid rgb(var(--color-border));
  border-radius: 0.75rem;
  font-weight: 600;
  color: rgb(var(--color-text-secondary));
  cursor: pointer;
  transition: all 0.2s;
}
.btn-outline:hover {
  background: rgb(var(--color-surface-hover));
  border-color: rgb(var(--color-primary));
  color: rgb(var(--color-primary));
}
.btn-outline:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.ai-stats-panel {
  background: rgba(99, 102, 241, 0.05);
  border: 1px solid rgba(99, 102, 241, 0.15);
  border-radius: 1rem;
  padding: 1rem 1.25rem;
}

.stats-grid {
  display: flex;
  flex-wrap: wrap;
  gap: 1.5rem;
  justify-content: space-between;
}

.stat-item {
  display: flex;
  flex-direction: column;
  gap: 0.25rem;
}

.stat-item .label {
  font-size: 0.8rem;
  color: rgb(var(--color-text-secondary));
  text-transform: uppercase;
  letter-spacing: 0.05em;
  font-weight: 600;
}

.stat-item .value {
  font-size: 0.95rem;
  color: rgb(var(--color-text-primary));
}

.mb-6 { margin-bottom: 1.5rem; }
.text-primary { color: rgb(var(--color-primary)); }
.font-bold { font-weight: 700; }
.text-secondary { color: rgb(var(--color-text-secondary)); }

/* LinkedIn Mockup Styles */
.linkedin-preview-container {
  display: flex;
  flex-direction: column;
  gap: 1.75rem;
  width: 100%;
}

/* Optimization Score Dashboard */
.linkedin-score-dashboard {
  background: linear-gradient(135deg, rgba(99, 102, 241, 0.03), rgba(139, 92, 246, 0.03));
  border: 1px solid rgba(99, 102, 241, 0.15);
  border-radius: 1.25rem;
  padding: 1.5rem;
  display: flex;
  flex-direction: column;
  gap: 1.25rem;
}

.score-main-row {
  display: flex;
  align-items: center;
  justify-content: space-between;
  flex-wrap: wrap;
  gap: 2rem;
}

.score-circle-container {
  display: flex;
  align-items: center;
  gap: 1.25rem;
}

.score-circle {
  width: 72px;
  height: 72px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 4px;
  flex-shrink: 0;
}

.score-inner {
  background: rgb(var(--color-surface));
  width: 100%;
  height: 100%;
  border-radius: 50%;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  line-height: 1.1;
}

.score-number {
  font-size: 1.4rem;
  font-weight: 800;
  color: rgb(var(--color-text-primary));
  line-height: 1;
}

.score-total {
  font-size: 0.75rem;
  color: rgb(var(--color-text-secondary));
  font-weight: 600;
  margin-top: 1px;
  line-height: 1;
}

.score-meta h4 {
  margin: 0 0 0.25rem 0;
  font-size: 1.05rem;
  font-weight: 700;
  color: rgb(var(--color-text-primary));
}

.score-desc {
  margin: 0;
  font-size: 0.8rem;
  color: rgb(var(--color-text-secondary));
}

.visibility-meter {
  flex: 1;
  min-width: 250px;
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
}

.meter-label-row {
  display: flex;
  justify-content: space-between;
  font-size: 0.85rem;
  color: rgb(var(--color-text-secondary));
}

.visibility-status {
  font-weight: 700;
  text-transform: uppercase;
}

.visibility-status.very-high { color: #10b981; }
.visibility-status.high { color: #10b981; }
.visibility-status.medium { color: #f59e0b; }
.visibility-status.low { color: #ef4444; }

.meter-bar-container {
  height: 8px;
  background: rgb(var(--color-border));
  border-radius: 4px;
  overflow: hidden;
}

.meter-bar {
  height: 100%;
  border-radius: 4px;
  transition: width 0.5s ease-out;
}

.meter-bar.very-high, .meter-bar.high { background: linear-gradient(90deg, rgb(var(--color-primary)), #10b981); }
.meter-bar.medium { background: #f59e0b; }
.meter-bar.low { background: #ef4444; }

.keyword-coverage {
  border-top: 1px dashed rgb(var(--color-border));
  padding-top: 0.75rem;
}

.coverage-label-row {
  font-size: 0.8rem;
  font-weight: 700;
  color: rgb(var(--color-text-secondary));
  text-transform: uppercase;
  margin-bottom: 0.25rem;
}

.coverage-text {
  margin: 0;
  font-size: 0.875rem;
  color: rgb(var(--color-text-primary));
  font-style: italic;
}

/* Premium LinkedIn profile layout */
.linkedin-card {
  background: rgb(var(--color-surface));
  border: 1px solid rgb(var(--color-border));
  border-radius: 1.25rem;
  overflow: hidden;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.05);
}

.linkedin-mock-banner {
  height: 120px;
  background: linear-gradient(135deg, #a0b2d6 0%, #6e8bbd 100%);
  position: relative;
  display: flex;
  align-items: flex-start;
  justify-content: flex-end;
  padding: 0.75rem;
}

.banner-edit-hint {
  background: rgba(15, 23, 42, 0.4);
  color: white;
  font-size: 0.75rem;
  padding: 0.25rem 0.6rem;
  border-radius: 20px;
  backdrop-filter: blur(4px);
  cursor: pointer;
}

.linkedin-mock-avatar-row {
  margin-top: -55px;
  padding-left: 2rem;
  display: flex;
  align-items: flex-end;
  gap: 1rem;
  position: relative;
  z-index: 2;
}

.linkedin-mock-avatar {
  width: 100px;
  height: 100px;
  border-radius: 50%;
  background: #f1f5f9;
  border: 4px solid rgb(var(--color-surface));
  display: flex;
  align-items: center;
  justify-content: center;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
  overflow: hidden;
}

.avatar-placeholder-svg {
  width: 50px;
  height: 50px;
  color: #94a3b8;
}

.open-to-work-badge {
  background: #059669;
  color: white;
  font-size: 0.75rem;
  font-weight: 700;
  padding: 0.2rem 0.65rem;
  border-radius: 12px;
  margin-bottom: 0.5rem;
  box-shadow: 0 2px 6px rgba(5, 150, 105, 0.3);
}

.linkedin-mock-profile-details {
  padding: 1.25rem 2rem 2rem 2rem;
}

.profile-name-section {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  margin-bottom: 0.5rem;
}

.profile-fullname {
  font-size: 1.4rem;
  font-weight: 700;
  color: rgb(var(--color-text-primary));
  margin: 0;
}

.badge-relationship {
  font-size: 0.7rem;
  font-weight: 600;
  color: #64748b;
  background: #f1f5f9;
  border: 1px solid #cbd5e1;
  padding: 0.05rem 0.3rem;
  border-radius: 4px;
}

.active-headline-container {
  min-height: 44px;
  margin-bottom: 0.75rem;
}

.active-headline-text {
  font-size: 1.05rem;
  font-weight: 500;
  color: rgb(var(--color-text-primary));
  margin: 0;
  line-height: 1.4;
}

.profile-meta-row {
  display: flex;
  align-items: center;
  flex-wrap: wrap;
  gap: 0.4rem;
  font-size: 0.85rem;
  color: #64748b;
}

.separator-dot {
  font-size: 0.9rem;
  line-height: 1;
}

.contact-info {
  color: #0a66c2;
  font-weight: 600;
  cursor: pointer;
}

.linkedin-mock-actions {
  display: flex;
  gap: 0.75rem;
  flex-wrap: wrap;
}

.btn-linkedin-blue {
  background: #0a66c2;
  color: white;
  border: none;
  border-radius: 20px;
  padding: 0.4rem 1.25rem;
  font-size: 0.875rem;
  font-weight: 600;
  cursor: pointer;
  transition: background 0.2s;
}
.btn-linkedin-blue:hover { background: #004182; }

.btn-linkedin-outline {
  background: transparent;
  color: #0a66c2;
  border: 1px solid #0a66c2;
  border-radius: 20px;
  padding: 0.4rem 1.25rem;
  font-size: 0.875rem;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.2s;
}
.btn-linkedin-outline:hover { background: rgba(10, 102, 194, 0.05); }

.btn-linkedin-gray {
  background: transparent;
  color: #5e5e5e;
  border: 1px solid #5e5e5e;
  border-radius: 20px;
  padding: 0.4rem 1.25rem;
  font-size: 0.875rem;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.2s;
}
.btn-linkedin-gray:hover { background: rgba(94, 94, 94, 0.05); }

/* Fade slide animation for active headline transition */
.fade-slide-enter-active,
.fade-slide-leave-active {
  transition: all 0.25s ease;
}
.fade-slide-enter-from {
  opacity: 0;
  transform: translateY(5px);
}
.fade-slide-leave-to {
  opacity: 0;
  transform: translateY(-5px);
}

.linkedin-mock-section {
  padding: 1.25rem 0;
  border-top: 1px solid rgb(var(--color-border));
}

.headline-mock-section {
  padding-bottom: 0.5rem;
  border-top: none;
}

.section-label-row {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 0.75rem;
}

.section-label {
  font-size: 0.85rem;
  font-weight: 700;
  text-transform: uppercase;
  letter-spacing: 0.05em;
  color: rgb(var(--color-text-secondary));
}

.linkedin-text-container {
  font-size: 0.95rem;
  line-height: 1.6;
  color: rgb(var(--color-text-primary));
  white-space: pre-wrap;
  background: rgb(var(--color-surface-hover));
  padding: 1rem;
  border-radius: 0.75rem;
  border: 1px solid rgb(var(--color-border));
}

.headline-text {
  font-weight: 500;
  font-size: 1.05rem;
  color: rgb(var(--color-text-primary));
}

.btn-copy-small {
  display: flex;
  align-items: center;
  padding: 0.35rem 0.75rem;
  background: transparent;
  border: 1px solid rgb(var(--color-border));
  border-radius: 0.5rem;
  font-size: 0.75rem;
  font-weight: 600;
  color: rgb(var(--color-text-secondary));
  cursor: pointer;
  transition: all 0.2s ease;
}

.btn-copy-small:hover {
  background: rgb(var(--color-surface-hover));
  border-color: rgb(var(--color-primary));
  color: rgb(var(--color-primary));
}

.linkedin-mock-footer-actions {
  padding: 1.25rem 1.5rem;
  background: rgb(var(--color-surface-hover));
  border-top: 1px solid rgb(var(--color-border));
  display: flex;
  justify-content: center;
}

.btn-copy-all {
  display: flex;
  align-items: center;
  padding: 0.75rem 2rem;
  background: linear-gradient(135deg, rgb(var(--color-primary)), #8b5cf6);
  border: none;
  border-radius: 0.75rem;
  font-size: 0.95rem;
  font-weight: 600;
  color: white;
  cursor: pointer;
  transition: all 0.2s ease;
  box-shadow: 0 4px 12px rgba(99, 102, 241, 0.2);
}

.btn-copy-all:hover {
  transform: translateY(-1px);
  box-shadow: 0 6px 16px rgba(99, 102, 241, 0.3);
}

.btn-copy-all:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

.size-icon-sm {
  width: 0.875rem;
  height: 0.875rem;
}

/* Suggestion Card Styles */
.suggestions-card {
  background: rgb(var(--color-surface));
  border: 1px solid rgb(var(--color-border));
  border-radius: 1rem;
  padding: 1.5rem;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.03);
}

.card-title-main {
  font-size: 1.1rem;
  font-weight: 700;
  color: rgb(var(--color-text-primary));
  margin: 0 0 0.5rem 0;
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.card-title-row {
  display: flex;
  justify-content: space-between;
  align-items: center;
  flex-wrap: wrap;
  gap: 1rem;
  margin-bottom: 0.75rem;
}

.card-subtitle-main {
  font-size: 0.85rem;
  color: rgb(var(--color-text-secondary));
  margin: 0 0 1.25rem 0;
}

.headline-suggestions-list {
  display: flex;
  flex-direction: column;
  gap: 1rem;
}

.suggestion-item-card {
  border: 1px solid rgb(var(--color-border));
  border-radius: 0.75rem;
  padding: 1.25rem;
  cursor: pointer;
  background: rgb(var(--color-surface-hover));
  transition: all 0.25s ease;
  position: relative;
  display: flex;
  flex-direction: column;
  gap: 0.75rem;
}

.suggestion-item-card:hover {
  border-color: rgba(99, 102, 241, 0.4);
  transform: translateY(-1px);
  box-shadow: 0 4px 12px rgba(99, 102, 241, 0.05);
}

.suggestion-item-card.active {
  border-color: rgb(var(--color-primary));
  background: linear-gradient(to right, rgba(99, 102, 241, 0.04), rgba(139, 92, 246, 0.04));
  box-shadow: 0 4px 15px rgba(99, 102, 241, 0.1);
}

.suggestion-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  flex-wrap: wrap;
  gap: 0.5rem;
}

.suggestion-radio-row {
  display: flex;
  align-items: center;
  gap: 0.75rem;
}

.suggestion-radio {
  accent-color: rgb(var(--color-primary));
  width: 1.1rem;
  height: 1.1rem;
  cursor: pointer;
}

.suggestion-type-badge {
  font-size: 0.75rem;
  font-weight: 700;
  color: rgb(var(--color-primary));
  background: rgba(99, 102, 241, 0.1);
  padding: 0.2rem 0.6rem;
  border-radius: 6px;
  text-transform: uppercase;
  letter-spacing: 0.03em;
}

.suggestion-explanation {
  font-size: 0.75rem;
  color: rgb(var(--color-text-secondary));
  margin: 0;
  padding-left: 1.85rem;
  font-style: italic;
  border-top: 1px dashed rgb(var(--color-border));
  padding-top: 0.5rem;
}

.suggestion-actions {
  display: flex;
  align-items: center;
  gap: 0.75rem;
}

.btn-copy-tiny {
  background: rgb(var(--color-surface));
  border: 1px solid rgb(var(--color-border));
  color: rgb(var(--color-text-secondary));
  padding: 0.25rem 0.6rem;
  font-size: 0.75rem;
  font-weight: 600;
  border-radius: 4px;
  cursor: pointer;
  transition: all 0.2s;
}

.btn-copy-tiny:hover {
  border-color: rgb(var(--color-primary));
  color: rgb(var(--color-primary));
  background: rgb(var(--color-surface-hover));
}

.suggestion-text-preview {
  font-size: 0.95rem;
  color: rgb(var(--color-text-primary));
  line-height: 1.5;
  margin: 0;
  padding-left: 1.85rem;
}

/* About Card styling */
.about-card {
  background: rgb(var(--color-surface));
  border: 1px solid rgb(var(--color-border));
  border-radius: 1rem;
  padding: 1.5rem;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.03);
}

.character-counter-badge {
  font-size: 0.8rem;
  font-weight: 600;
  color: rgb(var(--color-text-secondary));
  background: rgb(var(--color-surface-hover));
  border: 1px solid rgb(var(--color-border));
  padding: 0.25rem 0.65rem;
  border-radius: 20px;
  display: inline-flex;
  align-items: center;
  gap: 0.4rem;
}

.character-counter-badge.success-limit {
  color: #10b981;
  border-color: rgba(16, 185, 129, 0.3);
  background: rgba(16, 185, 129, 0.05);
}

.character-counter-badge.warning-limit {
  color: #d97706;
  border-color: rgba(217, 119, 6, 0.3);
  background: rgba(217, 119, 6, 0.05);
}

.character-counter-badge.error-limit {
  color: #ef4444;
  border-color: rgba(239, 68, 68, 0.3);
  background: rgba(239, 68, 68, 0.05);
}

/* Checklist Styling */
.profile-tips-card {
  background: rgb(var(--color-surface));
  border: 1px solid rgb(var(--color-border));
  border-radius: 1.25rem;
  padding: 1.5rem;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.03);
}

.tips-checklist {
  display: flex;
  flex-direction: column;
  gap: 1rem;
  margin-top: 1rem;
}

.tip-checkbox-item {
  display: flex;
  gap: 0.85rem;
  align-items: flex-start;
  padding: 0.85rem;
  background: rgb(var(--color-surface-hover));
  border-radius: 0.75rem;
  border: 1px solid rgb(var(--color-border));
  transition: all 0.2s;
}
.tip-checkbox-item:hover {
  border-color: rgba(99, 102, 241, 0.3);
}

.tip-checkbox {
  accent-color: rgb(var(--color-primary));
  width: 1.2rem;
  height: 1.2rem;
  margin-top: 0.2rem;
  cursor: pointer;
}

.tip-label {
  display: flex;
  flex-direction: column;
  gap: 0.2rem;
  cursor: pointer;
}

.tip-label strong {
  font-size: 0.9rem;
  color: rgb(var(--color-text-primary));
}

.tip-label span {
  font-size: 0.8rem;
  color: rgb(var(--color-text-secondary));
  line-height: 1.4;
}

.about-textarea-container {
  display: flex;
  flex-direction: column;
  gap: 1rem;
}

.scrollable-about {
  max-height: 350px;
  overflow-y: auto;
}

.about-header-actions {
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.btn-copy-tiny-compact {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  background: rgb(var(--color-surface));
  border: 1px solid rgb(var(--color-border));
  color: rgb(var(--color-text-secondary));
  padding: 0.25rem 0.6rem;
  font-size: 0.75rem;
  font-weight: 600;
  border-radius: 6px;
  cursor: pointer;
  transition: all 0.2s ease;
}

.btn-copy-tiny-compact:hover {
  background: rgb(var(--color-surface-hover));
  border-color: rgb(var(--color-primary));
  color: rgb(var(--color-primary));
}

/* Extracted insights layout */
.insights-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 1.25rem;
}

.insight-card {
  background: rgb(var(--color-surface));
  border: 1px solid rgb(var(--color-border));
  border-radius: 1rem;
  padding: 1.25rem;
  box-shadow: 0 4px 15px rgba(0, 0, 0, 0.02);
  display: flex;
  flex-direction: column;
  gap: 0.75rem;
}

.insight-card.full-width {
  grid-column: 1 / -1;
}

.insight-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.insight-label {
  font-size: 0.8rem;
  font-weight: 700;
  text-transform: uppercase;
  color: rgb(var(--color-text-secondary));
  letter-spacing: 0.05em;
}

.insight-body {
  font-size: 0.95rem;
  color: rgb(var(--color-text-primary));
}

.brand-text {
  font-style: italic;
  color: rgb(var(--color-text-primary));
  margin: 0;
  line-height: 1.5;
}

.tags-container {
  display: flex;
  flex-wrap: wrap;
  gap: 0.5rem;
}

.insight-tag {
  background: rgb(var(--color-surface-hover));
  border: 1px solid rgb(var(--color-border));
  color: rgb(var(--color-text-primary));
  font-size: 0.8rem;
  font-weight: 500;
  padding: 0.25rem 0.6rem;
  border-radius: 6px;
  transition: all 0.2s;
}

.insight-tag:hover {
  border-color: rgb(var(--color-primary));
  color: rgb(var(--color-primary));
}

.active-preview {
  background: linear-gradient(to right, rgba(99, 102, 241, 0.02), rgba(139, 92, 246, 0.02));
  border-color: rgba(99, 102, 241, 0.25) !important;
}

@media (max-width: 767px) {
  .preview-container {
    flex-direction: column;
    gap: 0.75rem;
  }
  .insights-grid { grid-template-columns: 1fr; }
  .metrics-dashboard-grid { grid-template-columns: 1fr; }

  .ai-stats-panel {
    padding: 0.5rem 0.75rem;
    border-radius: 0.75rem;
    margin-bottom: 0.75rem !important;
  }
  
  .stats-grid {
    flex-direction: row !important;
    justify-content: space-between;
    gap: 0.5rem;
  }
  
  .stat-item {
    gap: 0.15rem;
  }
  
  .stat-item .label {
    font-size: 0.65rem;
  }
  
  .stat-item .value {
    font-size: 0.8rem;
  }

  .preview-panel {
    gap: 0.35rem;
  }

  .preview-panel h4 {
    font-size: 0.7rem;
    margin-bottom: 0.25rem;
  }

  .content-box {
    padding: 0.75rem;
    font-size: 0.825rem;
    line-height: 1.5;
    border-radius: 0.75rem;
  }

  .modal-backdrop {
    padding: 16px;
    align-items: center;
  }
  
  .modal-content.result-modal {
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
    font-size: 0.95rem;
    font-weight: 700;
  }

  .modal-header .subtitle {
    font-size: 0.75rem;
  }
  
  .btn-close {
    width: 36px;
    height: 36px;
    font-size: 1.25rem;
  }

  .modal-body {
    padding: 1rem;
    overflow-y: auto;
    flex: 1;
    -webkit-overflow-scrolling: touch;
  }

  .modal-footer {
    padding: 0.75rem 1rem;
    flex-shrink: 0;
    gap: 0.5rem;
    display: flex !important;
    flex-direction: row;
    background: rgb(var(--color-surface-hover));
    border-top: 1px solid rgb(var(--color-border));
  }
  .modal-footer .flex-spacer {
    display: none;
  }
  .modal-footer button {
    flex: 1;
    min-width: 0;
    height: 36px;
    padding: 0 0.5rem;
    border-radius: 8px;
    font-size: 0.8rem;
    display: flex;
    align-items: center;
    justify-content: center;
    margin: 0;
    white-space: nowrap;
  }

  /* Compact spacing for preview details */
  .linkedin-score-dashboard {
    padding: 0.75rem;
    border-radius: 0.75rem;
    gap: 0.75rem;
  }
  .score-main-row {
    gap: 1rem;
  }
  .score-circle-container {
    gap: 0.75rem;
  }
  .score-circle {
    width: 58px;
    height: 58px;
  }
  .score-number {
    font-size: 1.15rem;
  }
  .score-total {
    font-size: 0.65rem;
  }
  .score-meta h4 {
    font-size: 0.95rem;
  }
  .visibility-meter {
    min-width: 100%;
  }
  
  .linkedin-mock-banner {
    height: 80px;
  }
  .linkedin-mock-avatar-row {
    margin-top: -40px;
    padding-left: 1rem;
    gap: 0.75rem;
  }
  .linkedin-mock-avatar {
    width: 72px;
    height: 72px;
  }
  .avatar-placeholder-svg {
    width: 36px;
    height: 36px;
  }
  .linkedin-mock-profile-details {
    padding: 1rem;
  }
  .profile-fullname {
    font-size: 1.15rem;
  }
  .active-headline-text {
    font-size: 0.875rem;
  }
  .linkedin-mock-actions {
    gap: 0.5rem;
  }
  .linkedin-mock-actions button {
    font-size: 0.75rem;
    padding: 0.35rem 1rem;
  }
  .linkedin-text-container {
    font-size: 0.875rem;
    padding: 0.75rem;
    border-radius: 0.5rem;
  }
  .headline-text {
    font-size: 0.95rem;
  }
  
  .suggestions-card, .about-card, .profile-tips-card, .recruiter-insights-section {
    padding: 1rem;
    border-radius: 0.75rem;
  }
  .suggestion-item-card {
    padding: 0.75rem;
    border-radius: 0.5rem;
    gap: 0.5rem;
  }
  .suggestion-text-preview {
    font-size: 0.875rem;
    padding-left: 1.5rem;
  }
  .suggestion-explanation {
    font-size: 0.75rem;
    padding-left: 1.5rem;
  }
  
  .tip-checkbox-item {
    padding: 0.625rem;
    border-radius: 0.5rem;
    gap: 0.5rem;
  }
  .tip-label strong {
    font-size: 0.8125rem;
  }
  .tip-label span {
    font-size: 0.75rem;
  }
  
  .metric-detail-card {
    padding: 0.75rem;
    border-radius: 0.75rem;
    gap: 0.5rem;
  }
  .metric-card-label {
    font-size: 0.8125rem;
  }
  .metric-reasoning {
    font-size: 0.75rem;
  }
  .metric-suggestion-box {
    padding: 0.375rem;
    font-size: 0.75rem;
  }
  
  .section-label-row {
    flex-wrap: wrap;
    gap: 0.5rem;
  }
  
  .suggestion-header {
    flex-direction: column;
    align-items: flex-start;
    gap: 0.5rem;
  }
  
  .suggestion-actions {
    width: 100%;
    display: flex;
    justify-content: space-between;
    align-items: center;
  }
  
  .suggestion-radio-row {
    width: 100%;
  }

  .card-title-row {
    flex-direction: column;
    align-items: flex-start;
    gap: 0.5rem;
    width: 100%;
  }

  .about-header-actions {
    display: flex;
    width: 100%;
    justify-content: space-between;
    align-items: center;
    gap: 0.5rem;
  }

  .btn-copy-all {
    width: 100%;
    height: 36px;
    padding: 0;
    font-size: 0.8rem;
    border-radius: 8px;
    display: flex;
    align-items: center;
    justify-content: center;
  }

  .linkedin-mock-footer-actions {
    padding: 0.75rem 1rem;
  }

  .btn-copy-tiny, .btn-copy-tiny-compact, .btn-copy-small {
    font-size: 0.7rem !important;
    padding: 0.2rem 0.5rem !important;
    border-radius: 6px !important;
  }

  /* Compact typography & spacing overrides for suggestions, insights, checklists */
  .recruiter-insights-section {
    padding: 1rem;
    border-radius: 1rem;
  }
  .insights-title {
    font-size: 0.95rem;
    margin-bottom: 0.15rem;
  }
  .insights-subtitle {
    font-size: 0.75rem;
    margin-bottom: 1rem;
  }
  .metric-detail-card {
    padding: 0.75rem;
    border-radius: 0.75rem;
    gap: 0.5rem;
  }
  .metric-card-label {
    font-size: 0.75rem;
  }
  .metric-card-header .metric-score-badge {
    font-size: 0.75rem;
    padding: 0.15rem 0.4rem;
  }
  .metric-reasoning, .suggestion-text {
    font-size: 0.75rem;
  }
  
  .suggestions-card {
    padding: 1rem;
    border-radius: 1rem;
  }
  .card-title-main {
    font-size: 0.95rem;
    margin-bottom: 0.25rem;
  }
  .card-subtitle-main {
    font-size: 0.75rem;
    margin-bottom: 1rem;
  }
  .suggestion-item-card {
    padding: 0.75rem;
    border-radius: 0.75rem;
    gap: 0.5rem;
  }
  
  .tip-checkbox-item {
    padding: 0.75rem;
    border-radius: 0.75rem;
  }
  .tip-label strong {
    font-size: 0.825rem;
  }
  .tip-label span {
    font-size: 0.75rem;
  }
}


/* Recruiter Quality Insights Section */
.recruiter-insights-section {
  background: rgb(var(--color-surface));
  border: 1px solid rgb(var(--color-border));
  border-radius: 1.25rem;
  padding: 1.5rem;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.03);
}

.insights-title {
  display: flex;
  align-items: center;
  margin: 0 0 0.25rem 0;
  font-size: 1.1rem;
  font-weight: 700;
  color: rgb(var(--color-text-primary));
}

.insights-subtitle {
  margin: 0 0 1.5rem 0;
  font-size: 0.85rem;
  color: rgb(var(--color-text-secondary));
}

.metrics-dashboard-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(260px, 1fr));
  gap: 1.25rem;
}

.metric-detail-card {
  background: rgb(var(--color-surface-hover));
  border: 1px solid rgb(var(--color-border));
  border-radius: 1rem;
  padding: 1rem;
  display: flex;
  flex-direction: column;
  gap: 0.75rem;
  transition: all 0.2s;
}

.metric-detail-card:hover {
  border-color: rgba(99, 102, 241, 0.25);
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(99, 102, 241, 0.05);
}

.metric-card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.metric-card-label {
  font-size: 0.85rem;
  font-weight: 700;
  color: rgb(var(--color-text-primary));
}

.metric-score-badge {
  font-size: 0.75rem;
  font-weight: 700;
  padding: 0.15rem 0.5rem;
  border-radius: 20px;
}

.metric-score-badge.badge-success {
  background: rgba(16, 185, 129, 0.1);
  color: #10b981;
}

.metric-score-badge.badge-warning {
  background: rgba(245, 158, 11, 0.1);
  color: #d97706;
}

.metric-score-badge.badge-danger {
  background: rgba(239, 68, 68, 0.1);
  color: #ef4444;
}

.metric-progress-container {
  height: 6px;
  background: rgb(var(--color-border));
  border-radius: 3px;
  overflow: hidden;
}

.metric-progress-bar {
  height: 100%;
  border-radius: 3px;
}

.metric-progress-bar.badge-success { background: #10b981; }
.metric-progress-bar.badge-warning { background: #f59e0b; }
.metric-progress-bar.badge-danger { background: #ef4444; }

.metric-reasoning {
  margin: 0;
  font-size: 0.8rem;
  color: rgb(var(--color-text-secondary));
  line-height: 1.4;
}

.metric-suggestion-box {
  display: flex;
  align-items: flex-start;
  background: rgb(var(--color-surface));
  border: 1px solid rgb(var(--color-border));
  border-radius: 0.5rem;
  padding: 0.5rem;
  font-size: 0.75rem;
  color: rgb(var(--color-text-primary));
}

.metric-suggestion-box svg {
  margin-top: 0.1rem;
}

.suggestion-text {
  line-height: 1.3;
}

/* Tag variations */
.skill-tag { border-color: rgba(59, 130, 246, 0.25); background: rgba(59, 130, 246, 0.03); color: #3b82f6; }
.industry-tag { border-color: rgba(16, 185, 129, 0.25); background: rgba(16, 185, 129, 0.03); color: #10b981; }
.role-tag { border-color: rgba(139, 92, 246, 0.25); background: rgba(139, 92, 246, 0.03); color: #8b5cf6; }
.keyword-tag { border-color: rgba(236, 72, 153, 0.25); background: rgba(236, 72, 153, 0.03); color: #ec4899; }
.tech-tag { border-color: rgba(245, 158, 11, 0.25); background: rgba(245, 158, 11, 0.03); color: #f59e0b; }
.expertise-tag { border-color: rgba(14, 165, 233, 0.25); background: rgba(14, 165, 233, 0.03); color: #0ea5e9; }
.topic-tag { border-color: rgba(79, 70, 229, 0.25); background: rgba(79, 70, 229, 0.03); color: #4f46e5; }
</style>
