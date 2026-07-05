import { jsPDF } from 'jspdf'
import {
 contactLine, contactItems,
 normalizeExperiences, normalizeEducations, normalizeProjects,
 normalizeCertifications, normalizeLanguages, normalizeAchievements, normalizeInterests,
 dateRange
} from '../modules/resumes/templates/templateHelpers'
import { COLOR_HEX, FONT_SIZE_PX } from '../constants/resume'
import { buildRenderableSections } from './profileToResume'

// ─── Utilities ────────────────────────────────────────────────────────────────
const fileName = (title) => `${(title || 'resume').replace(/[^\w\-]+/g, '_').toLowerCase()}.pdf`

const hexToRgb = (hex) => {
 const clean = hex.replace('#', '')
 return [
 parseInt(clean.slice(0, 2), 16),
 parseInt(clean.slice(2, 4), 16),
 parseInt(clean.slice(4, 6), 16)
 ]
}

// Shared section writer — colored title bar + underline + body lines
const addSection = (doc, title, lines, y, accentHex = '#6D4AFF', options = {}) => {
 const {
 titleSize = 9,
 bodySize = 10.5,
 indent = 20,
 width = 170,
 lineHeight = 6,
 gap = 4
 } = options
 let cursor = y
 if (cursor > 270) { doc.addPage(); cursor = 20 }
 const [r, g, b] = hexToRgb(accentHex)
 doc.setFont('helvetica', 'bold')
 doc.setFontSize(titleSize)
 doc.setTextColor(r, g, b)
 doc.text(title.toUpperCase(), indent, cursor)
 cursor += 4
 doc.setDrawColor(226, 232, 240)
 doc.line(indent, cursor, indent + width, cursor)
 cursor += gap
 doc.setFont('helvetica', 'normal')
 doc.setFontSize(bodySize)
 doc.setTextColor(15, 23, 42)
 lines.filter(Boolean).forEach((line) => {
 const wrapped = doc.splitTextToSize(line, width)
 if (cursor + wrapped.length * lineHeight > 285) { doc.addPage(); cursor = 20 }
 doc.text(wrapped, indent, cursor)
 cursor += wrapped.length * lineHeight + 1.5
 })
 return cursor + 5
}

// Build section content lines (same logic for all templates)
const buildSectionLines = (section, content, doc) => {
 const skills = content.skills || {}
 const personal = content.personal || {}
 switch (section) {
 case 'summary':
 return personal.summary ? [personal.summary] : []
 case 'experience':
 return normalizeExperiences(content).flatMap((exp) => {
 const parts = []
 if (exp.role) parts.push(`${exp.role}${exp.company ? ' — ' + exp.company : ''}`)
 const range = dateRange(exp.startDate, exp.endDate)
 if (range) parts.push(range)
 if (exp.description) parts.push(exp.description)
 parts.push('')
 return parts
 })
 case 'education':
 return normalizeEducations(content).flatMap((edu) => {
 const parts = [edu.school]
 if (edu.degree) parts.push(edu.degree)
 const range = dateRange(edu.startDate, edu.endDate)
 if (range) parts.push(range)
 if (edu.cgpa) parts.push(`CGPA: ${edu.cgpa}`)
 parts.push('')
 return parts
 })
 case 'projects':
 return normalizeProjects(content).flatMap((proj) => {
 const parts = [proj.projectName]
 if (proj.technologies) parts.push(`Technologies: ${proj.technologies}`)
 if (proj.projectLink) parts.push(`Link: ${proj.projectLink}`)
 if (proj.description) parts.push(proj.description)
 parts.push('')
 return parts
 })
 case 'skills':
 return skills.skillList ? [skills.skillList] : []
 case 'certifications':
 return normalizeCertifications(content).flatMap((cert) => {
 const parts = [cert.certName]
 if (cert.issuingOrg) parts.push(cert.issuingOrg)
 if (cert.issueDate) parts.push(cert.issueDate)
 parts.push('')
 return parts
 })
 case 'languages':
 return normalizeLanguages(content).map((l) => `${l.language}${l.proficiency ? ' — ' + l.proficiency : ''}`)
 case 'achievements':
 return normalizeAchievements(content).map((a) => `• ${a.title}${a.description ? ' — ' + a.description : ''}`)
 case 'interests':
 return normalizeInterests(content).length ? [normalizeInterests(content).join(', ')] : []
 default:
 return []
 }
}

// Section display name
const SECTION_LABEL = {
 summary: 'Professional Summary', experience: 'Experience', education: 'Education',
 projects: 'Projects', skills: 'Skills', certifications: 'Certifications',
 languages: 'Languages', achievements: 'Achievements', interests: 'Interests'
}

// ─── MODERN TEMPLATE PDF ─────────────────────────────────────────────────────
// Sidebar layout: left colored strip + right body
const renderModern = (doc, resume, accentHex, accentRgb, visibleSections) => {
 const { content = {}, title } = resume
 const personal = content.personal || {}
 const [ar, ag, ab] = accentRgb

 // Draw sidebar background
 doc.setFillColor(ar, ag, ab)
 doc.rect(0, 0, 62, 297, 'F')

 // Sidebar: Name
 let sy = 22
 doc.setFont('helvetica', 'bold')
 doc.setFontSize(16)
 doc.setTextColor(255, 255, 255)
 const nameLines = doc.splitTextToSize(personal.fullName || title || 'Resume', 50)
 doc.text(nameLines, 8, sy)
 sy += nameLines.length * 8 + 4

 if (personal.headline) {
 doc.setFont('helvetica', 'normal')
 doc.setFontSize(9)
 doc.setTextColor(255, 255, 255)
 doc.setGState(new doc.GState({ opacity: 0.75 }))
 const hlLines = doc.splitTextToSize(personal.headline, 50)
 doc.text(hlLines, 8, sy)
 doc.setGState(new doc.GState({ opacity: 1 }))
 sy += hlLines.length * 5 + 6
 }

 // Contact in sidebar
 const contacts = contactItems(personal)
 if (contacts.length) {
 doc.setFontSize(8)
 doc.setTextColor(255, 255, 255)
 contacts.forEach(({ label, value }) => {
 doc.setFont('helvetica', 'bold')
 doc.text(label.toUpperCase(), 8, sy)
 sy += 4
 doc.setFont('helvetica', 'normal')
 const vLines = doc.splitTextToSize(value, 50)
 doc.text(vLines, 8, sy)
 sy += vLines.length * 4.5 + 3
 })
 sy += 4
 }

 // Sidebar sections: skills, languages, certifications, interests
 const sidebarSects = ['skills', 'languages', 'certifications', 'interests']
 sidebarSects.filter(s => visibleSections.includes(s)).forEach((section) => {
 const lines = buildSectionLines(section, content, doc)
 if (!lines.length) return
 if (sy > 275) return
 doc.setFont('helvetica', 'bold')
 doc.setFontSize(8)
 doc.setTextColor(255, 255, 255)
 doc.setGState(new doc.GState({ opacity: 0.65 }))
 doc.text(SECTION_LABEL[section].toUpperCase(), 8, sy)
 doc.setGState(new doc.GState({ opacity: 1 }))
 sy += 5
 doc.setFont('helvetica', 'normal')
 doc.setFontSize(8.5)
 lines.filter(Boolean).forEach((line) => {
 if (sy > 280) return
 const lLines = doc.splitTextToSize(line, 50)
 doc.text(lLines, 8, sy)
 sy += lLines.length * 4.5
 })
 sy += 5
 })

 // Main content: right column
 let my = 22
 const mainSects = visibleSections.filter(s => !sidebarSects.includes(s))
 mainSects.forEach((section) => {
 const lines = buildSectionLines(section, content, doc)
 if (!lines.filter(Boolean).length) return
 my = addSection(doc, SECTION_LABEL[section], lines, my, accentHex, {
 indent: 70, width: 130, titleSize: 9, bodySize: 10
 })
 })
}

// ─── PROFESSIONAL TEMPLATE PDF ───────────────────────────────────────────────
// Centered header, all caps section underlines, classic look
const renderProfessional = (doc, resume, accentHex, accentRgb, visibleSections) => {
 const { content = {}, title } = resume
 const personal = content.personal || {}
 const contact = contactLine(personal)

 let y = 24
 // Centered name
 doc.setFont('helvetica', 'bold')
 doc.setFontSize(24)
 doc.setTextColor(15, 23, 42)
 doc.text(personal.fullName || title || 'Resume', 105, y, { align: 'center' })
 y += 10

 if (personal.headline) {
 doc.setFont('helvetica', 'bold')
 doc.setFontSize(12)
 doc.setTextColor(...accentRgb)
 doc.text(personal.headline, 105, y, { align: 'center' })
 y += 8
 }

 if (contact) {
 doc.setFont('helvetica', 'normal')
 doc.setFontSize(9)
 doc.setTextColor(100, 116, 139)
 doc.text(contact, 105, y, { align: 'center' })
 y += 10
 }

 // Double underline border
 doc.setDrawColor(15, 23, 42)
 doc.setLineWidth(1.5)
 doc.line(20, y, 190, y)
 y += 1.5
 doc.setLineWidth(0.4)
 doc.line(20, y, 190, y)
 y += 8

 visibleSections.forEach((section) => {
 const lines = buildSectionLines(section, content, doc)
 if (!lines.filter(Boolean).length) return
 y = addSection(doc, SECTION_LABEL[section], lines, y, '#334155', { titleSize: 10, bodySize: 10.5 })
 })
}

// ─── MINIMAL TEMPLATE PDF ────────────────────────────────────────────────────
// Very clean — no color, thin dividers, light typography
const renderMinimal = (doc, resume, accentHex, accentRgb, visibleSections) => {
 const { content = {}, title } = resume
 const personal = content.personal || {}
 const contact = contactLine(personal)

 let y = 28
 doc.setFont('helvetica', 'normal')
 doc.setFontSize(26)
 doc.setTextColor(15, 23, 42)
 doc.text(personal.fullName || title || 'Resume', 20, y)
 y += 9

 if (personal.headline) {
 doc.setFont('helvetica', 'normal')
 doc.setFontSize(11)
 doc.setTextColor(100, 116, 139)
 doc.text(personal.headline, 20, y)
 y += 7
 }

 if (contact) {
 doc.setFont('helvetica', 'normal')
 doc.setFontSize(9)
 doc.setTextColor(148, 163, 184)
 const wc = doc.splitTextToSize(contact, 170)
 doc.text(wc, 20, y)
 y += wc.length * 5 + 8
 }

 visibleSections.forEach((section) => {
 const lines = buildSectionLines(section, content, doc)
 if (!lines.filter(Boolean).length) return
 // Minimal uses grey section titles, no color
 y = addSection(doc, SECTION_LABEL[section], lines, y, '#94a3b8', {
 titleSize: 8.5, bodySize: 10, gap: 5
 })
 })
}

// ─── EXECUTIVE TEMPLATE PDF ──────────────────────────────────────────────────
// Dark navy banner header
const renderExecutive = (doc, resume, accentHex, accentRgb, visibleSections) => {
 const { content = {}, title } = resume
 const personal = content.personal || {}
 const contact = contactLine(personal)

 // Dark banner
 doc.setFillColor(15, 23, 42)
 doc.rect(0, 0, 210, 42, 'F')
 doc.setFont('helvetica', 'bold')
 doc.setFontSize(22)
 doc.setTextColor(255, 255, 255)
 doc.text(personal.fullName || title || 'Resume', 20, 18)
 if (personal.headline) {
 doc.setFont('helvetica', 'normal')
 doc.setFontSize(12)
 doc.setTextColor(148, 163, 184)
 doc.text(personal.headline, 20, 28)
 }
 if (contact) {
 doc.setFontSize(9)
 doc.setTextColor(100, 116, 139)
 const wc = doc.splitTextToSize(contact, 170)
 doc.text(wc, 20, 36)
 }
 let y = 52

 visibleSections.forEach((section) => {
 const lines = buildSectionLines(section, content, doc)
 if (!lines.filter(Boolean).length) return
 y = addSection(doc, SECTION_LABEL[section], lines, y, accentHex, { titleSize: 9.5, bodySize: 10.5 })
 })
}

// ─── FRESHER TEMPLATE PDF ────────────────────────────────────────────────────
// Gradient-style accent border at top, bullet dot section titles
const renderFresher = (doc, resume, accentHex, accentRgb, visibleSections) => {
 const { content = {}, title } = resume
 const personal = content.personal || {}
 const skills = content.skills || {}
 const contacts = contactItems(personal)
 const [ar, ag, ab] = accentRgb

 // Accent top bar
 doc.setFillColor(ar, ag, ab)
 doc.rect(0, 0, 210, 4, 'F')

 let y = 18
 // "Open to opportunities" tag in accent
 doc.setFont('helvetica', 'bold')
 doc.setFontSize(8)
 doc.setTextColor(ar, ag, ab)
 doc.text('OPEN TO OPPORTUNITIES', 20, y)
 y += 7

 doc.setFont('helvetica', 'bold')
 doc.setFontSize(22)
 doc.setTextColor(15, 23, 42)
 doc.text(personal.fullName || title || 'Resume', 20, y)
 y += 9

 if (personal.headline) {
 doc.setFont('helvetica', 'bold')
 doc.setFontSize(11)
 doc.setTextColor(71, 85, 105)
 doc.text(personal.headline, 20, y)
 y += 7
 }

 if (contacts.length) {
 doc.setFont('helvetica', 'normal')
 doc.setFontSize(9)
 doc.setTextColor(100, 116, 139)
 doc.text(contacts.map(c => c.value).join(' · '), 20, y)
 y += 10
 }

 // Fresher uses skill tags rendered as comma-separated
 const sectionLines = (section) => {
 if (section === 'skills' && skills.skillList) {
 return [skills.skillList]
 }
 return buildSectionLines(section, content, doc)
 }

 visibleSections.forEach((section) => {
 const lines = sectionLines(section)
 if (!lines.filter(Boolean).length) return
 // Draw a bullet dot before section title
 if (y > 270) { doc.addPage(); y = 20 }
 doc.setFillColor(ar, ag, ab)
 doc.circle(20, y - 1.5, 1.5, 'F')
 doc.setFont('helvetica', 'bold')
 doc.setFontSize(9)
 doc.setTextColor(ar, ag, ab)
 doc.text(SECTION_LABEL[section].toUpperCase(), 24, y)
 y += 4
 doc.setDrawColor(226, 232, 240)
 doc.line(20, y, 190, y)
 y += 5
 doc.setFont('helvetica', 'normal')
 doc.setFontSize(10.5)
 doc.setTextColor(15, 23, 42)
 lines.filter(Boolean).forEach((line) => {
 const wrapped = doc.splitTextToSize(line, 168)
 if (y + wrapped.length * 6 > 285) { doc.addPage(); y = 20 }
 doc.text(wrapped, 20, y)
 y += wrapped.length * 6 + 1.5
 })
 y += 5
 })
}

// ─── Main export ─────────────────────────────────────────────────────────────
export const downloadResume = (resume) => {
 const { content = {}, template_id = 'modern' } = resume
 const appearance = content.appearance || {}
 const accentHex = COLOR_HEX[appearance.primaryColor] || '#6D4AFF'
 const accentRgb = hexToRgb(accentHex)

 const visibleSections = buildRenderableSections(content)

 const doc = new jsPDF({ unit: 'mm', format: 'a4' })

 switch (template_id) {
 case 'modern': renderModern(doc, resume, accentHex, accentRgb, visibleSections); break
 case 'professional': renderProfessional(doc, resume, accentHex, accentRgb, visibleSections); break
 case 'minimal': renderMinimal(doc, resume, accentHex, accentRgb, visibleSections); break
 case 'executive': renderExecutive(doc, resume, accentHex, accentRgb, visibleSections); break
 case 'fresher': renderFresher(doc, resume, accentHex, accentRgb, visibleSections); break
 default: renderModern(doc, resume, accentHex, accentRgb, visibleSections)
 }

 doc.save(fileName(resume.title))
}
