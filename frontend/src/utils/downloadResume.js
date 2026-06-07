import { jsPDF } from 'jspdf'
import { contactLine } from '../modules/resumes/templates/templateHelpers'

const fileName = (title) => `${(title || 'resume').replace(/[^\w\-]+/g, '_').toLowerCase()}.pdf`

const addSection = (doc, title, lines, y) => {
  let cursor = y
  if (cursor > 270) {
    doc.addPage()
    cursor = 20
  }
  doc.setFont('helvetica', 'bold')
  doc.setFontSize(10)
  doc.setTextColor(109, 74, 255)
  doc.text(title.toUpperCase(), 20, cursor)
  cursor += 6
  doc.setDrawColor(226, 232, 240)
  doc.line(20, cursor, 190, cursor)
  cursor += 8
  doc.setFont('helvetica', 'normal')
  doc.setFontSize(11)
  doc.setTextColor(15, 23, 42)
  lines.filter(Boolean).forEach((line) => {
    const wrapped = doc.splitTextToSize(line, 170)
    if (cursor + wrapped.length * 6 > 285) {
      doc.addPage()
      cursor = 20
    }
    doc.text(wrapped, 20, cursor)
    cursor += wrapped.length * 6 + 2
  })
  return cursor + 6
}

export const downloadResume = (resume) => {
  const { title, content = {} } = resume
  const personal = content.personal || {}
  const experience = content.experience || {}
  const education = content.education || {}
  const projects = content.projects || {}
  const skills = content.skills || {}
  const certifications = content.certifications || {}
  const contact = contactLine(personal)

  const doc = new jsPDF({ unit: 'mm', format: 'a4' })
  let y = 24

  doc.setFont('helvetica', 'bold')
  doc.setFontSize(22)
  doc.setTextColor(15, 23, 42)
  doc.text(personal.fullName || title || 'Resume', 20, y)
  y += 10

  if (personal.headline) {
    doc.setFont('helvetica', 'bold')
    doc.setFontSize(12)
    doc.setTextColor(109, 74, 255)
    doc.text(personal.headline, 20, y)
    y += 8
  }

  if (contact) {
    doc.setFont('helvetica', 'normal')
    doc.setFontSize(9)
    doc.setTextColor(100, 116, 139)
    const wrappedContact = doc.splitTextToSize(contact, 170)
    doc.text(wrappedContact, 20, y)
    y += wrappedContact.length * 5 + 6
  }

  if (personal.summary) {
    doc.setFont('helvetica', 'normal')
    doc.setFontSize(11)
    doc.setTextColor(71, 85, 105)
    const summary = doc.splitTextToSize(personal.summary, 170)
    doc.text(summary, 20, y)
    y += summary.length * 6 + 8
  }

  if (experience.role || experience.company) {
    y = addSection(doc, 'Experience', [
      experience.role ? `Role: ${experience.role}` : null,
      experience.company ? `Company: ${experience.company}` : null
    ], y)
  }
  if (education.school) y = addSection(doc, 'Education', [education.school], y)
  if (projects.projectName) y = addSection(doc, 'Projects', [projects.projectName], y)
  if (skills.skillList) y = addSection(doc, 'Skills', [skills.skillList], y)
  if (certifications.certName) y = addSection(doc, 'Certifications', [certifications.certName], y)

  doc.save(fileName(title))
}
