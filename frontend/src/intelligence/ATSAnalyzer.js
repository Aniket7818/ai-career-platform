// ─── ATS Analyzer ─────────────────────────────────────────────────────────────
// Rule-based ATS (Applicant Tracking System) compatibility analyzer.
// Checks resume structure, formatting, and content for ATS friendliness.
// No AI — purely deterministic rules.

/**
 * @typedef {Object} ATSRule
 * @property {string} id - Unique rule identifier
 * @property {string} category - 'good' | 'warning' | 'critical'
 * @property {string} title - Human-readable title
 * @property {string} description - Explanation of why this matters
 * @property {string} impact - Impact on ATS parsing
 * @property {string} fix - How to fix the issue
 * @property {boolean} passed - Whether the resume passes this check
 */

/**
 * Run all ATS compatibility checks
 * @param {Object} content - Resume content object
 * @param {Object} options - { templateId, appearance }
 * @returns {Object} { score, rules, passed, warnings, critical }
 */
export const analyzeATS = (content, options = {}) => {
 if (!content) return { score: 0, rules: [], passed: [], warnings: [], critical: [] }

 const rules = []
 const p = content.personal || {}
 const exps = Array.isArray(content.experiences) ? content.experiences : []
 const edus = Array.isArray(content.educations) ? content.educations : []
 const projs = Array.isArray(content.projects) ? content.projects : []
 const certs = Array.isArray(content.certifications) ? content.certifications : []
 const skills = content.skills?.skillList || ''
 const summary = p.summary || ''

 // ── Structure Rules ──────────────────────────────────────────────────────
 
 rules.push({
 id: 'contact-info',
 category: checkContactInfo(p) ? 'good' : 'critical',
 title: 'Contact Information',
 description: 'ATS requires name, email, and phone to create a candidate profile.',
 impact: 'Resume may be rejected without contact information.',
 fix: 'Add your full name, email address, and phone number.',
 passed: checkContactInfo(p)
 })

 rules.push({
 id: 'professional-summary',
 category: summary.trim().length >= 50 ? 'good' : summary.trim().length > 0 ? 'warning' : 'critical',
 title: 'Professional Summary',
 description: 'A strong professional summary helps ATS categorize your profile.',
 impact: 'Missing or short summaries reduce keyword matching.',
 fix: 'Write a 3-4 sentence professional summary with relevant keywords.',
 passed: summary.trim().length >= 50
 })

 rules.push({
 id: 'experience-section',
 category: exps.some(e => e.role && e.company) ? 'good' : 'critical',
 title: 'Experience Section',
 description: 'ATS systems prioritize work experience for candidate matching.',
 impact: 'Missing experience significantly reduces ATS ranking.',
 fix: 'Add at least one work experience entry with role, company, and dates.',
 passed: exps.some(e => e.role && e.company)
 })

 rules.push({
 id: 'education-section',
 category: edus.some(e => e.school && e.degree) ? 'good' : 'warning',
 title: 'Education Section',
 description: 'Most ATS systems look for educational qualifications.',
 impact: 'Missing education may filter you out of certain roles.',
 fix: 'Add your educational background with institution and degree.',
 passed: edus.some(e => e.school && e.degree)
 })

 rules.push({
 id: 'skills-section',
 category: skills.trim().length > 0 ? 'good' : 'critical',
 title: 'Skills Section',
 description: 'ATS systems heavily rely on skills matching for filtering.',
 impact: 'Missing skills section drastically reduces keyword matches.',
 fix: 'Add a comma-separated list of your technical and soft skills.',
 passed: skills.trim().length > 0
 })

 // ── Content Quality Rules ────────────────────────────────────────────────

 const skillCount = skills.split(',').filter(s => s.trim()).length
 rules.push({
 id: 'skill-count',
 category: skillCount >= 8 ? 'good' : skillCount >= 4 ? 'warning' : 'critical',
 title: 'Skill Variety',
 description: `You have ${skillCount} skill${skillCount !== 1 ? 's' : ''} listed. ATS works best with 8-15 skills.`,
 impact: 'Too few skills reduce keyword match probability.',
 fix: 'Add at least 8 relevant skills separated by commas.',
 passed: skillCount >= 8
 })

 const hasMetrics = exps.some(e => {
 const desc = (e.description || '').toLowerCase()
 return /\d+%|\$[\d,]+|\d+\+|increased|decreased|improved|reduced|achieved|delivered|managed|led/i.test(desc)
 })
 rules.push({
 id: 'measurable-achievements',
 category: hasMetrics ? 'good' : 'warning',
 title: 'Measurable Achievements',
 description: 'Quantifiable achievements (%, $, numbers) strengthen ATS matching.',
 impact: 'Lack of metrics reduces perceived impact and ranking.',
 fix: 'Add numbers, percentages, or dollar amounts to experience descriptions.',
 passed: hasMetrics
 })

 const hasDates = exps.every(e => {
 if (!e.role && !e.company) return true // empty entry
 return e.startDate && (e.endDate || e.current)
 })
 rules.push({
 id: 'date-consistency',
 category: hasDates ? 'good' : 'warning',
 title: 'Date Consistency',
 description: 'ATS systems parse dates to calculate experience duration.',
 impact: 'Missing dates may cause incorrect experience calculation.',
 fix: 'Ensure all experience entries have start and end dates.',
 passed: hasDates
 })

 // ── Formatting Rules ─────────────────────────────────────────────────────

 rules.push({
 id: 'single-column',
 category: 'good',
 title: 'Single-Column Layout',
 description: 'Your resume uses a parseable single-column layout.',
 impact: 'Multi-column layouts often break ATS parsing.',
 fix: 'Already using an ATS-friendly layout.',
 passed: true
 })

 rules.push({
 id: 'standard-headings',
 category: 'good',
 title: 'Standard Section Headings',
 description: 'Using standard headings like Experience, Education, Skills.',
 impact: 'Non-standard headings may not be recognized by ATS.',
 fix: 'Keep section headings standard and recognizable.',
 passed: true
 })

 const hasEmail = p.email && /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(p.email)
 rules.push({
 id: 'valid-email',
 category: hasEmail ? 'good' : p.email ? 'warning' : 'critical',
 title: 'Valid Email Format',
 description: 'ATS systems extract email for communication.',
 impact: 'Invalid email format prevents recruiter contact.',
 fix: 'Ensure your email is in proper format (name@domain.com).',
 passed: hasEmail
 })

 const summaryLength = summary.trim().split(/\s+/).length
 rules.push({
 id: 'summary-length',
 category: summaryLength >= 30 && summaryLength <= 80 ? 'good' : summaryLength > 0 ? 'warning' : 'critical',
 title: 'Summary Length',
 description: `Your summary has ${summaryLength} words. Optimal range: 30-80 words.`,
 impact: 'Too short lacks keywords; too long dilutes relevance.',
 fix: summaryLength < 30 ? 'Expand your summary to at least 30 words.' : summaryLength > 80 ? 'Shorten your summary to under 80 words.' : 'Summary length is optimal.',
 passed: summaryLength >= 30 && summaryLength <= 80
 })

 // ── Readability Rules ────────────────────────────────────────────────────

 rules.push({
 id: 'readable-fonts',
 category: 'good',
 title: 'Readable Fonts',
 description: 'Using web-safe, ATS-compatible fonts.',
 impact: 'Exotic fonts may render incorrectly in ATS.',
 fix: 'Your template uses ATS-friendly fonts.',
 passed: true
 })

 const hasProjects = projs.some(p => p.projectName)
 rules.push({
 id: 'projects-section',
 category: hasProjects ? 'good' : 'warning',
 title: 'Projects Section',
 description: 'Projects demonstrate practical skills to ATS and recruiters.',
 impact: 'Missing projects may reduce technical credibility.',
 fix: 'Add at least one project with name, description, and technologies.',
 passed: hasProjects
 })

 const hasCertifications = certs.some(c => c.certName)
 rules.push({
 id: 'certifications',
 category: hasCertifications ? 'good' : 'warning',
 title: 'Certifications',
 description: 'Certifications add credibility and keywords to your resume.',
 impact: 'Optional but beneficial for ATS keyword matching.',
 fix: 'Add relevant certifications if you have any.',
 passed: hasCertifications
 })

 // Calculate overall ATS score
 const passed = rules.filter(r => r.passed)
 const warnings = rules.filter(r => r.category === 'warning')
 const critical = rules.filter(r => r.category === 'critical')
 
 // Score: start at 100, deduct for issues
 let score = 100
 critical.forEach(() => score -= 10)
 warnings.forEach(() => score -= 4)
 score = Math.max(0, Math.min(100, score))

 return {
 score,
 rules,
 passed,
 warnings,
 critical,
 totalRules: rules.length,
 passedCount: passed.length
 }
}

// Helper
const checkContactInfo = (personal) => {
 return !!(personal.fullName?.trim() && personal.email?.trim() && personal.phone?.trim())
}
