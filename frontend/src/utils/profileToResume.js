export const emptyResumeContent = () => ({
  personal: {
    fullName: '',
    headline: '',
    summary: '',
    email: '',
    phone: '',
    location: '',
    linkedin: '',
    github: '',
    portfolio: ''
  },
  education: { school: '' },
  experience: { role: '', company: '' },
  projects: { projectName: '' },
  skills: { skillList: '' },
  certifications: { certName: '' }
})

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
  return {
    ...content,
    personal: { ...content.personal, ...mapped.personal }
  }
}

export const calculateAtsScore = (content) => {
  if (!content) return 0
  let score = 0
  const personal = content.personal || {}
  const checks = [
    [personal.fullName, 12],
    [personal.headline, 8],
    [personal.summary, 10],
    [personal.email, 8],
    [personal.phone, 6],
    [personal.location, 6],
    [content.experience?.role, 12],
    [content.experience?.company, 8],
    [content.education?.school, 12],
    [content.skills?.skillList, 10],
    [content.projects?.projectName, 8],
    [content.certifications?.certName, 10]
  ]
  checks.forEach(([value, points]) => { if (value?.trim?.()) score += points })
  return Math.min(100, score)
}
