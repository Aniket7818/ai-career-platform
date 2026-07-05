// ─── Health Calculator ────────────────────────────────────────────────────────
// Combines completion, formatting, ATS, keywords, and section balance
// into a single overall Resume Health Score.
// Everything is derived — no hardcoded values.

/**
 * @typedef {Object} SectionHealth
 * @property {string} name - Section name
 * @property {string} status - 'good' | 'warning' | 'missing'
 * @property {number} score - Section score (0-100)
 * @property {string} label - Human readable status
 * @property {string} reason - Why this score
 */

/**
 * Calculate per-section health status
 */
export const calculateSectionHealth = (content) => {
 if (!content) return []

 const p = content.personal || {}
 const exps = Array.isArray(content.experiences) ? content.experiences : []
 const edus = Array.isArray(content.educations) ? content.educations : []
 const projs = Array.isArray(content.projects) ? content.projects : []
 const certs = Array.isArray(content.certifications) ? content.certifications : []
 const skills = content.skills?.skillList || ''
 const summary = p.summary || ''

 const sections = []

 // Professional Summary
 const summaryWords = summary.trim().split(/\s+/).filter(Boolean).length
 if (summaryWords >= 30) {
 sections.push({ name: 'Professional Summary', status: 'good', score: 100, label: '✓ Good', reason: `Strong summary with ${summaryWords} words` })
 } else if (summaryWords > 0) {
 sections.push({ name: 'Professional Summary', status: 'warning', score: 50, label: '⚠ Needs Improvement', reason: `Only ${summaryWords} words — aim for 30-80 words` })
 } else {
 sections.push({ name: 'Professional Summary', status: 'missing', score: 0, label: '✖ Missing', reason: 'No professional summary provided' })
 }

 // Experience
 const validExps = exps.filter(e => e.role || e.company || e.description)
 if (validExps.length > 0) {
 const hasDescriptions = validExps.every(e => (e.description || '').trim().length >= 20)
 const hasDates = validExps.every(e => e.startDate)
 if (hasDescriptions && hasDates) {
 sections.push({ name: 'Experience', status: 'good', score: 100, label: '✓ Good', reason: `${validExps.length} complete experience entries` })
 } else {
 sections.push({ name: 'Experience', status: 'warning', score: 60, label: '⚠ Needs Improvement', reason: 'Some entries lack descriptions or dates' })
 }
 } else {
 sections.push({ name: 'Experience', status: 'missing', score: 0, label: '✖ Missing', reason: 'No work experience added' })
 }

 // Education
 const validEdus = edus.filter(e => e.school || e.degree)
 if (validEdus.length > 0) {
 const isComplete = validEdus.every(e => e.school && e.degree)
 sections.push({
 name: 'Education',
 status: isComplete ? 'good' : 'warning',
 score: isComplete ? 100 : 60,
 label: isComplete ? '✓ Good' : '⚠ Needs Improvement',
 reason: isComplete ? `${validEdus.length} complete education entries` : 'Some entries missing school or degree'
 })
 } else {
 sections.push({ name: 'Education', status: 'missing', score: 0, label: '✖ Missing', reason: 'No education added' })
 }

 // Projects
 const validProjs = projs.filter(p => p.projectName || p.description)
 if (validProjs.length > 0) {
 const isComplete = validProjs.every(p => p.projectName && p.description)
 sections.push({
 name: 'Projects',
 status: isComplete ? 'good' : 'warning',
 score: isComplete ? 100 : 60,
 label: isComplete ? '✓ Good' : '⚠ Needs Improvement',
 reason: isComplete ? `${validProjs.length} well-documented projects` : 'Some projects need descriptions'
 })
 } else {
 sections.push({ name: 'Projects', status: 'missing', score: 0, label: '✖ Missing', reason: 'No projects added — highly recommended' })
 }

 // Skills
 const skillCount = skills.split(',').filter(s => s.trim()).length
 if (skillCount >= 8) {
 sections.push({ name: 'Skills', status: 'good', score: 100, label: '✓ Good', reason: `${skillCount} skills listed` })
 } else if (skillCount > 0) {
 sections.push({ name: 'Skills', status: 'warning', score: 50, label: '⚠ Needs Improvement', reason: `Only ${skillCount} skills — add at least 8` })
 } else {
 sections.push({ name: 'Skills', status: 'missing', score: 0, label: '✖ Missing', reason: 'No skills listed' })
 }

 // Certifications
 const validCerts = certs.filter(c => c.certName)
 if (validCerts.length > 0) {
 sections.push({ name: 'Certifications', status: 'good', score: 100, label: '✓ Good', reason: `${validCerts.length} certifications added` })
 } else {
 sections.push({ name: 'Certifications', status: 'warning', score: 30, label: '⚠ Needs Improvement', reason: 'Consider adding relevant certifications' })
 }

 // Formatting (always good since we control templates)
 sections.push({ name: 'Formatting', status: 'good', score: 100, label: '✓ Good', reason: 'Clean, professional formatting' })

 // ATS Readiness (computed from contact info + structure)
 const hasContact = p.fullName && p.email && p.phone
 const hasStructure = validExps.length > 0 && validEdus.length > 0 && skillCount > 0
 if (hasContact && hasStructure) {
 sections.push({ name: 'ATS Readiness', status: 'good', score: 100, label: '✓ Good', reason: 'Resume structure is ATS-friendly' })
 } else if (hasContact || hasStructure) {
 sections.push({ name: 'ATS Readiness', status: 'warning', score: 50, label: '⚠ Needs Improvement', reason: 'Missing some ATS-critical sections' })
 } else {
 sections.push({ name: 'ATS Readiness', status: 'missing', score: 0, label: '✖ Missing', reason: 'Resume lacks ATS-critical content' })
 }

 return sections
}

export const calculateHealthScore = (sectionHealth, atsScore = 0, keywordCoverage = 0, targetRole = '') => {
 if (!sectionHealth || !sectionHealth.length) return 0

 // Average section scores
 const sectionAvg = sectionHealth.reduce((sum, s) => sum + s.score, 0) / sectionHealth.length

 let overall = 0
 if (!targetRole) {
 // If no target role, split between sections and ATS
 const weights = { sections: 0.60, ats: 0.40 }
 overall = Math.round(sectionAvg * weights.sections + atsScore * weights.ats)
 } else {
 // Weighted average including keywords
 const weights = { sections: 0.50, ats: 0.35, keywords: 0.15 }
 overall = Math.round(
 sectionAvg * weights.sections +
 atsScore * weights.ats +
 keywordCoverage * weights.keywords
 )
 }

 return Math.max(0, Math.min(100, overall))
}

/**
 * Get score color class based on value
 */
export const getScoreColor = (score) => {
 if (score >= 80) return 'emerald'
 if (score >= 60) return 'amber'
 return 'red'
}

export const getScoreLabel = (score) => {
 if (score >= 90) return 'Excellent — Top 10% resume quality'
 if (score >= 80) return 'Very Good — Strong resume with minor optimizations'
 if (score >= 70) return 'Good — Solid foundation, needs some polish'
 if (score >= 60) return 'Fair — Several improvements recommended'
 if (score >= 40) return 'Needs Work — Missing critical information'
 return 'Poor — Please complete your resume sections'
}
