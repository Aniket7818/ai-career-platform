// ─── Resume Analyzer ──────────────────────────────────────────────────────────
// Master intelligence engine that orchestrates all sub-analyzers.
// Every rule returns { score, severity, title, description, fix }.
// Modular and easy to extend.

import { analyzeATS } from './ATSAnalyzer'
import { analyzeKeywords, getKeywordScore } from './KeywordAnalyzer'
import { calculateSectionHealth, calculateHealthScore, getScoreColor, getScoreLabel } from './HealthCalculator'

// ─── Experience Level Detector ────────────────────────────────────────────────

const EXPERIENCE_LEVELS = Object.freeze({
 STUDENT: { key: 'student', label: 'Student', pages: 1, highlights: ['Projects', 'Skills', 'Education'], projects: 3, skills: 10, readiness: 'Growing' },
 FRESHER: { key: 'fresher', label: 'Fresher', pages: 1, highlights: ['Projects', 'Skills', 'Education'], projects: 3, skills: 12, readiness: 'Entry-Level' },
 JUNIOR: { key: 'junior', label: 'Junior', pages: 1, highlights: ['Projects', 'Skills', 'Experience'], projects: 2, skills: 15, readiness: 'Ready' },
 MID: { key: 'mid', label: 'Mid Level', pages: 2, highlights: ['Experience', 'Skills', 'Achievements'], projects: 2, skills: 18, readiness: 'Highly Competitive' },
 SENIOR: { key: 'senior', label: 'Senior', pages: 2, highlights: ['Achievements', 'Leadership', 'Experience'], projects: 1, skills: 20, readiness: 'Expert' }
})

const detectExperienceLevel = (content) => {
 if (!content) return { ...EXPERIENCE_LEVELS.FRESHER, years: 0 }

 const exps = Array.isArray(content.experiences) ? content.experiences : []
 const validExps = exps.filter(e => e.role || e.company)
 
 // Calculate total years based on date ranges
 let totalMonths = 0
 validExps.forEach(exp => {
 if (exp.startDate) {
 const start = new Date(exp.startDate)
 const end = exp.endDate ? new Date(exp.endDate) : new Date()
 if (!isNaN(start.getTime()) && !isNaN(end.getTime())) {
 totalMonths += Math.max(0, (end.getFullYear() - start.getFullYear()) * 12 + (end.getMonth() - start.getMonth()))
 }
 }
 })

 const totalYears = +(totalMonths / 12).toFixed(1)
 const hasEducation = (content.educations || []).some(e => e.school)

 let level = EXPERIENCE_LEVELS.FRESHER
 if (validExps.length === 0 && hasEducation) level = EXPERIENCE_LEVELS.STUDENT
 else if (validExps.length === 0) level = EXPERIENCE_LEVELS.FRESHER
 else if (totalYears < 1) level = EXPERIENCE_LEVELS.FRESHER
 else if (totalYears < 3) level = EXPERIENCE_LEVELS.JUNIOR
 else if (totalYears < 7) level = EXPERIENCE_LEVELS.MID
 else level = EXPERIENCE_LEVELS.SENIOR

 return { ...level, years: totalYears }
}

// ─── Resume Checklist ─────────────────────────────────────────────────────────

const generateChecklist = (content) => {
 if (!content) return []

 const p = content.personal || {}
 const exps = Array.isArray(content.experiences) ? content.experiences : []
 const edus = Array.isArray(content.educations) ? content.educations : []
 const projs = Array.isArray(content.projects) ? content.projects : []
 const skills = content.skills?.skillList || ''
 const summary = p.summary || ''
 const certs = Array.isArray(content.certifications) ? content.certifications : []

 const checks = []

 // Personal info checks
 checks.push({ label: 'Name Added', done: !!p.fullName?.trim(), section: 'personal', why: 'Essential for identification.', fix: 'Add your full name in the personal details section.' })
 checks.push({ label: 'Email Added', done: !!p.email?.trim(), section: 'personal', why: 'Recruiters need a way to contact you.', fix: 'Add a professional email address.' })
 checks.push({ label: 'Phone Added', done: !!p.phone?.trim(), section: 'personal', why: 'Often used for initial phone screening.', fix: 'Add a phone number.' })
 checks.push({ label: 'LinkedIn Added', done: !!p.linkedin?.trim(), section: 'personal', why: 'Provides recruiters with more context.', fix: 'Add your LinkedIn profile URL.' })
 checks.push({ label: 'Location Added', done: !!p.location?.trim(), section: 'personal', why: 'Important for roles with geographical requirements.', fix: 'Add your current city/country.' })

 // Summary check
 const summaryWords = summary.trim().split(/\s+/).filter(Boolean).length
 checks.push({ label: 'Professional Summary Added', done: summaryWords >= 10, section: 'summary', why: 'The first thing recruiters read.', fix: 'Write a compelling professional summary.' })
 if (summaryWords > 0 && summaryWords < 30) {
 checks.push({ label: 'Professional Summary 30+ Words', done: false, section: 'summary', warning: true, why: 'Too short to include essential keywords.', fix: 'Expand your summary to 3-4 sentences.' })
 }

 // Experience check
 const validExps = exps.filter(e => e.role || e.company)
 checks.push({ label: 'Experience Added', done: validExps.length > 0, section: 'experience', why: 'The core of most hiring decisions.', fix: 'Add your work history.' })
 if (validExps.length > 0) {
 const hasMetrics = validExps.some(e => /\d+%|\$[\d,]+|\d+\+/i.test(e.description || ''))
 checks.push({ label: 'Measurable Achievements', done: hasMetrics, section: 'experience', warning: !hasMetrics, why: 'Numbers prove your impact.', fix: 'Add metrics (%, $, numbers) to your experience.' })
 }

 // Education check
 const validEdus = edus.filter(e => e.school || e.degree)
 checks.push({ label: 'Education Added', done: validEdus.length > 0, section: 'education', why: 'Required for many entry-level roles.', fix: 'Add your educational background.' })

 // Projects check
 const validProjs = projs.filter(p => p.projectName || p.description)
 checks.push({ label: 'Projects Added', done: validProjs.length > 0, section: 'projects', warning: validProjs.length === 0, why: 'Shows practical application of skills.', fix: 'Add a relevant project.' })

 // Skills check
 const skillCount = skills.split(',').filter(s => s.trim()).length
 checks.push({ label: 'Skills Added', done: skillCount > 0, section: 'skills', why: 'Crucial for ATS matching.', fix: 'List your technical and soft skills.' })
 if (skillCount > 0 && skillCount < 8) {
 checks.push({ label: 'At Least 8 Skills', done: false, section: 'skills', warning: true, why: 'ATS needs multiple keywords to match.', fix: 'Add more relevant skills.' })
 }

 // Certifications check
 const validCerts = certs.filter(c => c.certName)
 checks.push({ label: 'Certifications Added', done: validCerts.length > 0, section: 'certifications', warning: validCerts.length === 0, why: 'Validates specialized expertise.', fix: 'Add any relevant certifications.' })

 return checks
}

// ─── Resume Statistics ────────────────────────────────────────────────────────

const calculateStatistics = (content, options = {}) => {
 if (!content) return {}

 const p = content.personal || {}
 const exps = Array.isArray(content.experiences) ? content.experiences : []
 const edus = Array.isArray(content.educations) ? content.educations : []
 const projs = Array.isArray(content.projects) ? content.projects : []
 const certs = Array.isArray(content.certifications) ? content.certifications : []
 const skills = content.skills?.skillList || ''
 const summary = p.summary || ''
 const langs = Array.isArray(content.languages) ? content.languages : []
 const achievements = Array.isArray(content.achievements) ? content.achievements : []

 // Count all words
 const allText = [
 p.fullName, p.headline, summary, p.email, p.phone, p.location,
 ...exps.map(e => `${e.role} ${e.company} ${e.description}`),
 ...edus.map(e => `${e.school} ${e.degree}`),
 ...projs.map(p => `${p.projectName} ${p.description} ${p.technologies}`),
 ...certs.map(c => `${c.certName} ${c.issuingOrg}`),
 skills,
 ...achievements.map(a => `${a.title} ${a.description}`)
 ].filter(Boolean).join(' ')

 const wordCount = allText.split(/\s+/).filter(Boolean).length

 // Count sections with content
 let sectionCount = 0
 if (p.fullName || p.email) sectionCount++
 if (summary.trim()) sectionCount++
 if (exps.some(e => e.role || e.company)) sectionCount++
 if (edus.some(e => e.school)) sectionCount++
 if (projs.some(p => p.projectName)) sectionCount++
 if (skills.trim()) sectionCount++
 if (certs.some(c => c.certName)) sectionCount++
 if (langs.some(l => l.language)) sectionCount++
 if (achievements.some(a => a.title)) sectionCount++

 const skillCount = skills.split(',').filter(s => s.trim()).length
 const validExps = exps.filter(e => e.role || e.company)
 const validEdus = edus.filter(e => e.school)
 const validProjs = projs.filter(p => p.projectName)

 // Estimated reading time (average reader: 200 words/min)
 const readingTime = Math.max(1, Math.ceil(wordCount / 200))
 
 // Estimated ATS parsing time (instant for well-structured)
 const atsParsingTime = wordCount < 300 ? '< 1 sec' : wordCount < 800 ? '1-2 sec' : '2-3 sec'

 // Resume length estimation
 let resumeLength = '1 page'
 if (options.pageCount) {
 if (options.pageCount === 1) {
 resumeLength = wordCount < 300 ? '1 page (short)' : '1 page'
 } else if (options.pageCount === 2) {
 resumeLength = '2 pages'
 } else {
 resumeLength = `${options.pageCount} pages`
 }
 } else {
 // Fallback if no pageCount provided
 resumeLength = wordCount < 300 ? '1 page (short)' : wordCount < 600 ? '1 page' : wordCount < 900 ? '1-2 pages' : '2+ pages'
 }

 const density = wordCount < 200 ? 'Low' : wordCount > 600 ? 'High' : 'Optimal'

 return {
 words: wordCount,
 sections: sectionCount,
 skills: skillCount,
 projects: validProjs.length,
 experienceEntries: validExps.length,
 educationEntries: validEdus.length,
 readingTime: `${readingTime} min`,
 atsParsingTime,
 resumeLength,
 density,
 certifications: certs.filter(c => c.certName).length,
 languages: langs.filter(l => l.language).length,
 achievements: achievements.filter(a => a.title).length
 }
}

// ─── Resume Tips ──────────────────────────────────────────────────────────────

const generateTips = (content, targetRole) => {
 if (!content) return []

 const tips = []
 const p = content.personal || {}
 const exps = Array.isArray(content.experiences) ? content.experiences : []
 const projs = Array.isArray(content.projects) ? content.projects : []
 const skills = content.skills?.skillList || ''
 const summary = p.summary || ''
 const certs = Array.isArray(content.certifications) ? content.certifications : []

 const skillCount = skills.split(',').filter(s => s.trim()).length
 const validExps = exps.filter(e => e.role || e.company)
 const validProjs = projs.filter(p => p.projectName)
 const summaryWords = summary.trim().split(/\s+/).filter(Boolean).length

 // Score impact-based priority
 if (validProjs.length === 0) {
 tips.push({ priority: 95, icon: '🔥', text: 'Add at least one project to showcase practical skills', category: 'High', scoreImpact: '+10 Resume Health' })
 } else if (validProjs.length === 1) {
 tips.push({ priority: 70, icon: '🔥', text: 'Add one more project for a stronger portfolio', category: 'Medium', scoreImpact: '+5 Resume Health' })
 }

 if (validExps.length > 0 && !validExps.some(e => /\d+%|\$[\d,]+|\d+/i.test(e.description || ''))) {
 tips.push({ priority: 90, icon: '🔥', text: 'Add measurable achievements with numbers, %, or $', category: 'High', scoreImpact: '+8 Resume Health' })
 }

 if (summaryWords < 30 && summaryWords > 0) {
 tips.push({ priority: 85, icon: '🔥', text: 'Expand your professional summary to 3-4 impactful sentences', category: 'High', scoreImpact: '+6 Resume Health' })
 } else if (summaryWords === 0) {
 tips.push({ priority: 92, icon: '🔥', text: 'Add a professional summary — it\'s the first thing recruiters read', category: 'High', scoreImpact: '+12 Resume Health' })
 }

 if (skillCount < 8 && skillCount > 0) {
 tips.push({ priority: 75, icon: '💡', text: `Add ${8 - skillCount} more skills for better keyword matching`, category: 'Medium', scoreImpact: '+5 Recruiter Appeal' })
 } else if (skillCount === 0) {
 tips.push({ priority: 88, icon: '🔥', text: 'Add your technical skills — critical for ATS matching', category: 'High', scoreImpact: '+15 Resume Health' })
 }

 if (!p.linkedin?.trim()) {
 tips.push({ priority: 60, icon: '💡', text: 'Add your LinkedIn profile URL for credibility', category: 'Low', scoreImpact: '+2 Recruiter Appeal' })
 }

 if (!p.github?.trim() && targetRole?.toLowerCase().includes('developer')) {
 tips.push({ priority: 65, icon: '💡', text: 'Add your GitHub profile — developers benefit from code visibility', category: 'Medium', scoreImpact: '+3 Interview Readiness' })
 }

 if (certs.filter(c => c.certName).length === 0) {
 tips.push({ priority: 50, icon: '💡', text: 'Consider adding relevant certifications for extra credibility', category: 'Low', scoreImpact: '+2 Resume Health' })
 }

 if (validExps.length === 0) {
 tips.push({ priority: 80, icon: '🔥', text: 'Add work experience or internships to strengthen your resume', category: 'High', scoreImpact: '+15 Resume Health' })
 }

 // Sort by priority and return top 3
 return tips
 .sort((a, b) => b.priority - a.priority)
 .slice(0, 3)
}

// ─── Main Analyzer ────────────────────────────────────────────────────────────

/**
 * Run the complete resume intelligence analysis
 * @param {Object} content - Resume content object
 * @param {string} targetRole - Target job role
 * @param {Object} options - { templateId, appearance }
 * @returns {Object} Complete analysis result
 */
export const analyzeResume = (content, targetRole = '', options = {}) => {
 if (!content) {
 return {
 healthScore: 0,
 healthLabel: 'No Data',
 healthColor: 'red',
 sectionHealth: [],
 atsAnalysis: { score: 0, rules: [], passed: [], warnings: [], critical: [] },
 keywordAnalysis: { detected: [], missing: [], coverage: 0, total: 0 },
 keywordScore: { score: 0, maxScore: 20, severity: 'critical' },
 checklist: [],
 statistics: {},
 tips: [],
 experienceLevel: EXPERIENCE_LEVELS.FRESHER
 }
 }

 // Run sub-analyzers
 const sectionHealth = calculateSectionHealth(content)
 const atsAnalysis = analyzeATS(content, options)
 const keywordAnalysis = analyzeKeywords(content, targetRole)
 const keywordScoreResult = getKeywordScore(content, targetRole)
 const checklist = generateChecklist(content)
 const statistics = calculateStatistics(content, options)
 const tips = generateTips(content, targetRole)
 const experienceLevel = detectExperienceLevel(content)

 // Calculate overall health score
 const healthScore = calculateHealthScore(
 sectionHealth,
 atsAnalysis.score,
 keywordAnalysis.coverage,
 targetRole
 )

 return {
 healthScore,
 healthLabel: getScoreLabel(healthScore),
 healthColor: getScoreColor(healthScore),
 sectionHealth,
 atsAnalysis,
 keywordAnalysis,
 keywordScore: keywordScoreResult,
 checklist,
 statistics,
 tips,
 experienceLevel
 }
}

// Re-export experience levels for the UI
export { EXPERIENCE_LEVELS }
