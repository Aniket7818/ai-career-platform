// ─── Keyword Analyzer ─────────────────────────────────────────────────────────
// Compares resume content against role-specific keyword libraries.
// Returns detected keywords, missing keywords, and coverage percentage.

import { getKeywordsForRole } from './RoleKeywordLibrary'

/**
 * Extract all text content from resume for keyword matching
 */
const extractResumeText = (content) => {
 if (!content) return ''
 const parts = []

 // Personal info
 const p = content.personal || {}
 parts.push(p.fullName, p.headline, p.summary)

 // Experience
 const exps = Array.isArray(content.experiences) ? content.experiences : []
 exps.forEach(e => {
 parts.push(e.role, e.company, e.description)
 })

 // Education
 const edus = Array.isArray(content.educations) ? content.educations : []
 edus.forEach(e => {
 parts.push(e.school, e.degree)
 })

 // Projects
 const projs = Array.isArray(content.projects) ? content.projects : []
 projs.forEach(p => {
 parts.push(p.projectName, p.description, p.technologies)
 })

 // Skills
 parts.push(content.skills?.skillList)

 // Certifications
 const certs = Array.isArray(content.certifications) ? content.certifications : []
 certs.forEach(c => {
 parts.push(c.certName, c.issuingOrg)
 })

 // Achievements
 const achs = Array.isArray(content.achievements) ? content.achievements : []
 achs.forEach(a => {
 parts.push(a.title, a.description)
 })

 return parts.filter(Boolean).join(' ').toLowerCase()
}

/**
 * Analyze keyword coverage for a specific role
 * @param {Object} content - Resume content object
 * @param {string} targetRole - Target job role
 * @returns {Object} { detected, missing, coverage, total }
 */
export const analyzeKeywords = (content, targetRole) => {
 const roleKeywords = getKeywordsForRole(targetRole)
 if (!roleKeywords.length) {
 return { detected: [], missing: [], coverage: 0, total: 0 }
 }

 const resumeText = extractResumeText(content)
 const detected = []
 const missing = []

 roleKeywords.forEach(keyword => {
 // Check if keyword appears in resume text (word boundary aware)
 const escaped = keyword.replace(/[.*+?^${}()|[\]\\]/g, '\\$&')
 const regex = new RegExp(`\\b${escaped}\\b`, 'i')
 if (regex.test(resumeText) || resumeText.includes(keyword.toLowerCase())) {
 detected.push(keyword)
 } else {
 missing.push(keyword)
 }
 })

 const coverage = roleKeywords.length > 0
 ? Math.round((detected.length / roleKeywords.length) * 100)
 : 0

 return {
 detected,
 missing,
 coverage,
 total: roleKeywords.length
 }
}

/**
 * Get keyword analysis result as a rule result
 */
export const getKeywordScore = (content, targetRole) => {
 const analysis = analyzeKeywords(content, targetRole)
 
 let severity = 'good'
 let score = 0
 
 if (analysis.coverage >= 60) {
 severity = 'good'
 score = Math.min(20, Math.round(analysis.coverage * 0.2))
 } else if (analysis.coverage >= 30) {
 severity = 'warning'
 score = Math.round(analysis.coverage * 0.15)
 } else if (analysis.total > 0) {
 severity = 'critical'
 score = Math.max(0, Math.round(analysis.coverage * 0.1))
 }

 return {
 score,
 maxScore: 20,
 severity,
 title: 'Keyword Coverage',
 description: analysis.total > 0
 ? `${analysis.detected.length}/${analysis.total} role keywords detected (${analysis.coverage}%)`
 : 'No target role selected',
 fix: analysis.missing.length > 0
 ? `Consider adding: ${analysis.missing.slice(0, 5).join(', ')}`
 : 'Great keyword coverage!',
 details: analysis
 }
}
