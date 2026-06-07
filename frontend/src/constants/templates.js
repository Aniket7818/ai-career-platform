export const RESUME_TEMPLATES = Object.freeze([
  { id: 'modern', label: 'Modern', description: 'Two-column layout with a clean sidebar for contact and skills.' },
  { id: 'professional', label: 'Professional', description: 'Classic single-column format trusted by recruiters worldwide.' },
  { id: 'minimal', label: 'Minimal', description: 'Ultra-clean design with generous whitespace and sharp typography.' },
  { id: 'executive', label: 'Executive', description: 'Bold leadership-focused layout for senior roles and managers.' },
  { id: 'fresher', label: 'Fresher', description: 'Education-first layout ideal for students and early careers.' }
])

export const DEFAULT_TEMPLATE_ID = 'modern'

export const templateById = (id) => RESUME_TEMPLATES.find((t) => t.id === id) || RESUME_TEMPLATES[0]
