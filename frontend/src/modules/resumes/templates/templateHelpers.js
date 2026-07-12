import { COLOR_HEX, FONT_SIZE_PX } from '../../../constants/resume'

// Helper to strip any array/object/JSON notation and return human-readable text (Issue 9)
export const cleanText = (val) => {
  if (val === null || val === undefined) return ''
  if (Array.isArray(val)) {
    return val.map(cleanText).filter(Boolean).join(', ')
  }
  if (typeof val === 'object') {
    if (val.skillList) return cleanText(val.skillList)
    if (val.name) return cleanText(val.name)
    if (val.title) return cleanText(val.title)
    if (val.text) return cleanText(val.text)
    return Object.values(val).map(cleanText).filter(Boolean).join(', ')
  }
  const str = String(val).trim()
  if (str === '[]' || str === '{}' || str === '[object Object]') return ''
  return str.replace(/^["']|["']$/g, '').replace(/\\n/g, '\n').replace(/\\"/g, '"').trim()
}

export const contactItems = (personal = {}) => [
  { label: 'Email', value: cleanText(personal.email) },
  { label: 'Phone', value: cleanText(personal.phone) },
  { label: 'Location', value: cleanText(personal.location) },
  { label: 'LinkedIn', value: cleanText(personal.linkedin) },
  { label: 'GitHub', value: cleanText(personal.github) },
  { label: 'Portfolio', value: cleanText(personal.portfolio) }
].filter((item) => item.value?.trim?.())

export const contactLine = (personal = {}) => contactItems(personal).map((item) => item.value).join(' · ')

// Normalize and sanitize personal details
export const normalizePersonal = (content = {}) => {
  const p = content.personal || {}
  return {
    fullName: cleanText(p.fullName),
    email: cleanText(p.email),
    phone: cleanText(p.phone),
    location: cleanText(p.location),
    linkedin: cleanText(p.linkedin),
    github: cleanText(p.github),
    portfolio: cleanText(p.portfolio),
    headline: cleanText(p.headline),
    summary: cleanText(p.summary)
  }
}

// Normalize and sanitize skills
export const normalizeSkills = (content = {}) => {
  const s = content.skills || {}
  return {
    skillList: cleanText(s.skillList || s)
  }
}

// Normalize arrays — ensures both old single-object and new array formats work
// and filters out empty/blank entries (Issue 5)
export const normalizeExperiences = (content) => {
  let list = []
  if (Array.isArray(content.experiences)) {
    list = content.experiences
  } else if (content.experience && (content.experience.role || content.experience.company)) {
    list = [content.experience]
  }
  return list
    .map((e) => {
      if (!e) return null
      return {
        id: e.id,
        role: cleanText(e.role),
        company: cleanText(e.company),
        startDate: cleanText(e.startDate),
        endDate: cleanText(e.endDate),
        description: cleanText(e.description)
      }
    })
    .filter((e) => e && (e.role || e.company || e.description))
}

export const normalizeEducations = (content) => {
  let list = []
  if (Array.isArray(content.educations)) {
    list = content.educations
  } else if (content.education && content.education.school) {
    list = [content.education]
  }
  return list
    .map((e) => {
      if (!e) return null
      return {
        id: e.id,
        school: cleanText(e.school),
        degree: cleanText(e.degree),
        startDate: cleanText(e.startDate),
        endDate: cleanText(e.endDate),
        cgpa: cleanText(e.cgpa)
      }
    })
    .filter((e) => e && (e.school || e.degree || e.cgpa))
}

export const normalizeProjects = (content) => {
  let list = []
  if (Array.isArray(content.projects)) {
    list = content.projects
  } else if (content.projects && !Array.isArray(content.projects) && content.projects.projectName) {
    list = [content.projects]
  }
  return list
    .map((p) => {
      if (!p) return null
      return {
        id: p.id,
        projectName: cleanText(p.projectName),
        projectLink: cleanText(p.projectLink),
        technologies: cleanText(p.technologies),
        description: cleanText(p.description)
      }
    })
    .filter((p) => p && (p.projectName || p.description || p.technologies))
}

export const normalizeCertifications = (content) => {
  let list = []
  if (Array.isArray(content.certifications)) {
    list = content.certifications
  } else if (content.certifications && !Array.isArray(content.certifications) && content.certifications.certName) {
    list = [content.certifications]
  }
  return list
    .map((c) => {
      if (!c) return null
      return {
        id: c.id,
        certName: cleanText(c.certName),
        issuingOrg: cleanText(c.issuingOrg),
        issueDate: cleanText(c.issueDate),
        credentialUrl: cleanText(c.credentialUrl)
      }
    })
    .filter((c) => c && (c.certName || c.issuingOrg))
}

export const normalizeLanguages = (content) => {
  const list = Array.isArray(content.languages) ? content.languages : []
  return list
    .map((l) => {
      if (!l) return null
      return {
        id: l.id,
        language: cleanText(l.language),
        proficiency: cleanText(l.proficiency)
      }
    })
    .filter((l) => l && l.language)
}

export const normalizeAchievements = (content) => {
  const list = Array.isArray(content.achievements) ? content.achievements : []
  return list
    .map((a) => {
      if (!a) return null
      return {
        id: a.id,
        title: cleanText(a.title),
        description: cleanText(a.description)
      }
    })
    .filter((a) => a && (a.title || a.description))
}

export const normalizeInterests = (content) => {
  const list = Array.isArray(content.interests) ? content.interests : []
  return list
    .map((i) => {
      if (typeof i === 'string') return cleanText(i)
      return cleanText(i?.name || '')
    })
    .filter(Boolean)
}

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
