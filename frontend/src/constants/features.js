export const FEATURE_STATUS = Object.freeze({
  PLANNED: 'planned',
  IN_DEVELOPMENT: 'in_development',
  LAUNCHING_SOON: 'launching_soon'
})

export const FEATURE_KEYS = Object.freeze({
  AI_ATS_CHECKER: 'ai_ats_checker',
  AI_COVER_LETTER: 'ai_cover_letter',
  AI_MOCK_INTERVIEWS: 'ai_mock_interviews',
  PORTFOLIO_GENERATOR: 'portfolio_generator',
  GITHUB_ANALYZER: 'github_analyzer',
  LINKEDIN_REVIEW: 'linkedin_review',
  JOB_TRACKER: 'job_tracker',
  CAREER_ROADMAP: 'career_roadmap',
  PLACEMENT_HUB: 'placement_hub',
  AI_RESUME_ASSISTANT: 'ai_resume_assistant'
})

export const FEATURE_ICONS = Object.freeze({
  [FEATURE_KEYS.AI_ATS_CHECKER]: 'ats',
  [FEATURE_KEYS.AI_COVER_LETTER]: 'letter',
  [FEATURE_KEYS.AI_MOCK_INTERVIEWS]: 'interview',
  [FEATURE_KEYS.PORTFOLIO_GENERATOR]: 'portfolio',
  [FEATURE_KEYS.GITHUB_ANALYZER]: 'github',
  [FEATURE_KEYS.LINKEDIN_REVIEW]: 'linkedin',
  [FEATURE_KEYS.JOB_TRACKER]: 'tracker',
  [FEATURE_KEYS.CAREER_ROADMAP]: 'roadmap',
  [FEATURE_KEYS.PLACEMENT_HUB]: 'placement',
  [FEATURE_KEYS.AI_RESUME_ASSISTANT]: 'resume'
})

export const UPCOMING_FEATURES = Object.freeze([
  { key: FEATURE_KEYS.AI_ATS_CHECKER, status: FEATURE_STATUS.IN_DEVELOPMENT, progress: 72, estimatedAvailability: 'Q2 2026', highlights: ['resumeScoring', 'keywordAnalysis', 'atsOptimization'] },
  { key: FEATURE_KEYS.AI_COVER_LETTER, status: FEATURE_STATUS.IN_DEVELOPMENT, progress: 58, estimatedAvailability: 'Q2 2026', highlights: ['jobSpecificLetters', 'oneClickGeneration'] },
  { key: FEATURE_KEYS.AI_MOCK_INTERVIEWS, status: FEATURE_STATUS.LAUNCHING_SOON, progress: 88, estimatedAvailability: 'Q1 2026', highlights: ['technicalInterviews', 'hrInterviews', 'realtimeFeedback', 'interviewScoring'] },
  { key: FEATURE_KEYS.PORTFOLIO_GENERATOR, status: FEATURE_STATUS.PLANNED, progress: 35, estimatedAvailability: 'Q3 2026', highlights: ['oneClickPortfolio', 'customThemes', 'resumeIntegration'] },
  { key: FEATURE_KEYS.GITHUB_ANALYZER, status: FEATURE_STATUS.IN_DEVELOPMENT, progress: 64, estimatedAvailability: 'Q2 2026', highlights: ['repositoryAnalysis', 'bulletGeneration', 'projectSummaries', 'interviewQuestions'] },
  { key: FEATURE_KEYS.LINKEDIN_REVIEW, status: FEATURE_STATUS.PLANNED, progress: 42, estimatedAvailability: 'Q3 2026', highlights: ['profileScoring', 'improvementSuggestions', 'seoOptimization'] },
  { key: FEATURE_KEYS.JOB_TRACKER, status: FEATURE_STATUS.IN_DEVELOPMENT, progress: 55, estimatedAvailability: 'Q2 2026', highlights: ['savedJobs', 'appliedJobs', 'interviewTracking', 'offerManagement'] },
  { key: FEATURE_KEYS.CAREER_ROADMAP, status: FEATURE_STATUS.PLANNED, progress: 28, estimatedAvailability: 'Q3 2026', highlights: ['learningPaths', 'skillGapAnalysis', 'careerRecommendations'] },
  { key: FEATURE_KEYS.PLACEMENT_HUB, status: FEATURE_STATUS.LAUNCHING_SOON, progress: 82, estimatedAvailability: 'Q1 2026', highlights: ['aptitudePractice', 'dsaQuestions', 'interviewExperiences'] },
  { key: FEATURE_KEYS.AI_RESUME_ASSISTANT, status: FEATURE_STATUS.IN_DEVELOPMENT, progress: 68, estimatedAvailability: 'Q2 2026', highlights: ['resumeRewriting', 'contentEnhancement', 'achievementSuggestions'] }
])

export const STATUS_COLORS = Object.freeze({
  [FEATURE_STATUS.PLANNED]: { bg: 'bg-sky-500/15', text: 'text-sky-300', bar: 'bg-sky-400', dot: 'bg-sky-400' },
  [FEATURE_STATUS.IN_DEVELOPMENT]: { bg: 'bg-amber-500/15', text: 'text-amber-300', bar: 'bg-amber-400', dot: 'bg-amber-400' },
  [FEATURE_STATUS.LAUNCHING_SOON]: { bg: 'bg-emerald-500/15', text: 'text-emerald-300', bar: 'bg-emerald-400', dot: 'bg-emerald-400' }
})
