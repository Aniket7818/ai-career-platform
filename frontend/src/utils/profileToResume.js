// ─── Empty entry factories ────────────────────────────────────────────────────
export const emptyExperience = () => ({ id: crypto.randomUUID(), role: '', company: '', startDate: '', endDate: '', description: '' })
export const emptyEducation = () => ({ id: crypto.randomUUID(), school: '', degree: '', startDate: '', endDate: '', cgpa: '' })
export const emptyProject = () => ({ id: crypto.randomUUID(), projectName: '', projectLink: '', description: '', technologies: '' })
export const emptyCertification = () => ({ id: crypto.randomUUID(), certName: '', issuingOrg: '', issueDate: '', credentialUrl: '' })
export const emptyLanguage = () => ({ id: crypto.randomUUID(), language: '', proficiency: 'Fluent' })
export const emptyAchievement = () => ({ id: crypto.randomUUID(), title: '', description: '' })

// ─── Default settings ─────────────────────────────────────────────────────────
export const DEFAULT_APPEARANCE = Object.freeze({
 fontFamily: 'Inter',
 fontSize: 'medium',
 primaryColor: 'blue'
})

export const DEFAULT_SECTION_ORDER = Object.freeze([
 'summary', 'experience', 'education', 'projects', 'skills',
 'certifications', 'languages', 'achievements', 'interests'
])

export const DEFAULT_SECTION_VISIBILITY = Object.freeze({
 summary: true, experience: true, education: true, projects: true,
 skills: true, certifications: true, languages: true, achievements: true, interests: true
})

// ─── Empty resume content (v2) ────────────────────────────────────────────────
export const emptyResumeContent = () => ({
 personal: {
 fullName: '', headline: '', summary: '',
 email: '', phone: '', location: '',
 linkedin: '', github: '', portfolio: ''
 },
 // Core sections — arrays
 experiences: [emptyExperience()],
 educations: [emptyEducation()],
 projects: [emptyProject()],
 certifications: [emptyCertification()],
 // Skills stays as flat string (ATS-safe, comma-separated)
 skills: { skillList: '' },
 // New sections
 languages: [],
 achievements: [],
 interests: [],
 socialLinks: { leetcode: '', codeforces: '', hackerrank: '' },
 // Appearance & layout settings (persisted in JSONB)
 appearance: { ...DEFAULT_APPEARANCE },
 sectionOrder: [...DEFAULT_SECTION_ORDER],
 sectionVisibility: { ...DEFAULT_SECTION_VISIBILITY }
})

// ─── Backward-compat migration ────────────────────────────────────────────────
// Converts old single-object sections (v1) → arrays (v2) on load
export const migrateContent = (raw = {}) => {
 const empty = emptyResumeContent()
 const c = {
 ...empty,
 ...raw,
 personal: { ...empty.personal, ...(raw.personal || {}) },
 skills: { ...empty.skills, ...(raw.skills || {}) },
 appearance: { ...empty.appearance, ...(raw.appearance || {}) },
 sectionOrder: raw.sectionOrder?.length ? raw.sectionOrder : [...DEFAULT_SECTION_ORDER],
 sectionVisibility: { ...DEFAULT_SECTION_VISIBILITY, ...(raw.sectionVisibility || {}) },
 socialLinks: { ...empty.socialLinks, ...(raw.socialLinks || {}) },
 interests: Array.isArray(raw.interests) ? raw.interests : [],
 languages: Array.isArray(raw.languages) ? raw.languages : [],
 achievements: Array.isArray(raw.achievements) ? raw.achievements : []
 }

 // Migrate v1 experience → v2 experiences
 if (Array.isArray(raw.experiences) && raw.experiences.length) {
 c.experiences = raw.experiences.map((e) => ({ ...emptyExperience(), ...e }))
 } else if (raw.experience && (raw.experience.role || raw.experience.company)) {
 c.experiences = [{ ...emptyExperience(), ...raw.experience }]
 } else {
 c.experiences = [emptyExperience()]
 }

 // Migrate v1 education → v2 educations
 if (Array.isArray(raw.educations) && raw.educations.length) {
 c.educations = raw.educations.map((e) => ({ ...emptyEducation(), ...e }))
 } else if (raw.education && raw.education.school) {
 c.educations = [{ ...emptyEducation(), ...raw.education }]
 } else {
 c.educations = [emptyEducation()]
 }

 // Migrate v1 projects → v2 projects
 if (Array.isArray(raw.projects) && raw.projects.length) {
 c.projects = raw.projects.map((p) => ({ ...emptyProject(), ...p }))
 } else if (raw.projects && !Array.isArray(raw.projects) && raw.projects.projectName) {
 c.projects = [{ ...emptyProject(), ...raw.projects }]
 } else {
 c.projects = [emptyProject()]
 }

 // Migrate v1 certifications → v2 certifications
 if (Array.isArray(raw.certifications) && raw.certifications.length) {
 c.certifications = raw.certifications.map((cert) => ({ ...emptyCertification(), ...cert }))
 } else if (raw.certifications && !Array.isArray(raw.certifications) && raw.certifications.certName) {
 c.certifications = [{ ...emptyCertification(), ...raw.certifications }]
 } else {
 c.certifications = [emptyCertification()]
 }

 // Ensure all entries have IDs
 c.experiences = c.experiences.map((e) => ({ ...emptyExperience(), ...e, id: e.id || crypto.randomUUID() }))
 c.educations = c.educations.map((e) => ({ ...emptyEducation(), ...e, id: e.id || crypto.randomUUID() }))
 c.projects = c.projects.map((p) => ({ ...emptyProject(), ...p, id: p.id || crypto.randomUUID() }))
 c.certifications = c.certifications.map((cert) => ({ ...emptyCertification(), ...cert, id: cert.id || crypto.randomUUID() }))
 c.languages = c.languages.map((l) => ({ ...emptyLanguage(), ...l, id: l.id || crypto.randomUUID() }))
 c.achievements = c.achievements.map((a) => ({ ...emptyAchievement(), ...a, id: a.id || crypto.randomUUID() }))

 return c
}

// ─── Profile → content mapper ─────────────────────────────────────────────────
export const mapProfileToContent = (user) => {
 if (!user) return {}
 return {
 personal: {
 fullName: user.full_name || '',
 headline: user.title || '',
 summary: user.bio || '',
 email: user.email || '',
 phone: user.phone || '',
 location: user.location || '',
 linkedin: user.linkedin || '',
 github: user.github || '',
 portfolio: user.website || ''
 }
 }
}

export const mergeProfileIntoContent = (content, user) => {
 const mapped = mapProfileToContent(user)
 return { ...content, personal: { ...content.personal, ...mapped.personal } }
}

// ─── ATS Score ────────────────────────────────────────────────────────────────
export const calculateAtsScore = (content) => {
 if (!content) return 0
 let score = 0
 const p = content.personal || {}
 const exps = Array.isArray(content.experiences) ? content.experiences : []
 const edus = Array.isArray(content.educations) ? content.educations : []
 const projs = Array.isArray(content.projects) ? content.projects : []
 const certs = Array.isArray(content.certifications) ? content.certifications : []

 // Backward compat for old single-object data not yet migrated in the ATS call
 const hasExp = exps.some((e) => e.role || e.company) || !!(content.experience?.role || content.experience?.company)
 const hasEdu = edus.some((e) => e.school) || !!(content.education?.school)
 const hasProj = projs.some((e) => e.projectName) || !!(content.projects?.projectName)
 const hasCert = certs.some((e) => e.certName) || !!(content.certifications?.certName)

 const checks = [
 [p.fullName, 12],
 [p.headline, 8],
 [p.summary, 10],
 [p.email, 8],
 [p.phone, 6],
 [p.location, 6],
 [hasExp, 12],
 [hasEdu, 12],
 [content.skills?.skillList, 10],
 [hasProj, 8],
 [hasCert, 8]
 ]
 checks.forEach(([value, points]) => {
 if (typeof value === 'boolean' ? value : value?.trim?.()) score += points
 })
 return Math.min(100, score)
}

// ─── Profile Completion ───────────────────────────────────────────────────────
export const calculateCompletion = (content) => {
 if (!content) return 0
 let score = 0
 const p = content.personal || {}
 const exps = Array.isArray(content.experiences) ? content.experiences : []
 const edus = Array.isArray(content.educations) ? content.educations : []
 const projs = Array.isArray(content.projects) ? content.projects : []

 const hasExp = exps.some((e) => e.role || e.company) || !!(content.experience?.role || content.experience?.company)
 const hasEdu = edus.some((e) => e.school) || !!(content.education?.school)
 const hasProj = projs.some((e) => e.projectName) || !!(content.projects?.projectName)

 if (p.fullName?.trim()) score += 10
 if (p.email?.trim()) score += 10
 if (p.phone?.trim()) score += 10
 if (hasExp) score += 20
 if (hasEdu) score += 20
 if (hasProj) score += 15
 if (content.skills?.skillList?.trim()) score += 15

 return Math.min(100, score)
}

// ─── Renderable Sections Helper ───────────────────────────────────────────────
export const buildRenderableSections = (content) => {
 if (!content) return []
 const order = content.sectionOrder || DEFAULT_SECTION_ORDER
 const visibility = content.sectionVisibility || DEFAULT_SECTION_VISIBILITY
 
 return order.filter(section => visibility[section] !== false)
}
