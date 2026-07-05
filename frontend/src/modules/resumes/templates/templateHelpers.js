import { COLOR_HEX, FONT_SIZE_PX } from '../../../constants/resume'

export const contactItems = (personal = {}) => [
 { label: 'Email', value: personal.email },
 { label: 'Phone', value: personal.phone },
 { label: 'Location', value: personal.location },
 { label: 'LinkedIn', value: personal.linkedin },
 { label: 'GitHub', value: personal.github },
 { label: 'Portfolio', value: personal.portfolio }
].filter((item) => item.value?.trim?.())

export const contactLine = (personal = {}) => contactItems(personal).map((item) => item.value).join(' · ')

// Normalize arrays — ensures both old single-object and new array formats work
export const normalizeExperiences = (content) => {
 if (Array.isArray(content.experiences) && content.experiences.length) return content.experiences
 if (content.experience && (content.experience.role || content.experience.company)) return [content.experience]
 return []
}

export const normalizeEducations = (content) => {
 if (Array.isArray(content.educations) && content.educations.length) return content.educations
 if (content.education && content.education.school) return [content.education]
 return []
}

export const normalizeProjects = (content) => {
 if (Array.isArray(content.projects) && content.projects.length) return content.projects
 if (content.projects && !Array.isArray(content.projects) && content.projects.projectName) return [content.projects]
 return []
}

export const normalizeCertifications = (content) => {
 if (Array.isArray(content.certifications) && content.certifications.length) return content.certifications
 if (content.certifications && !Array.isArray(content.certifications) && content.certifications.certName) return [content.certifications]
 return []
}

export const normalizeLanguages = (content) =>
 Array.isArray(content.languages) ? content.languages.filter((l) => l.language?.trim()) : []

export const normalizeAchievements = (content) =>
 Array.isArray(content.achievements) ? content.achievements.filter((a) => a.title?.trim()) : []

export const normalizeInterests = (content) =>
 Array.isArray(content.interests) ? content.interests.filter(Boolean) : []

// Format month string (YYYY-MM → "Jan 2024")
export const formatMonth = (val) => {
 if (!val) return ''
 try { return new Date(`${val}-01`).toLocaleDateString('en-US', { month: 'short', year: 'numeric' }) } catch { return val }
}

export const dateRange = (start, end) => {
 const s = formatMonth(start)
 const e = end ? formatMonth(end) : 'Present'
 if (!s && !e) return ''
 if (!s) return e
 return `${s} – ${e}`
}

// Appearance helpers
export const primaryColorHex = (appearance = {}) => COLOR_HEX[appearance.primaryColor] || COLOR_HEX.blue
export const fontSizePx = (appearance = {}) => `${FONT_SIZE_PX[appearance.fontSize] || 14}px`
export const fontFamily = (appearance = {}) => appearance.fontFamily || 'Inter'

export const appearanceStyle = (appearance = {}) => ({
 fontFamily: fontFamily(appearance),
 fontSize: fontSizePx(appearance),
 '--resume-primary': primaryColorHex(appearance)
})
