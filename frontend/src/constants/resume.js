export const RESUME_STATUS = Object.freeze({
 DRAFT: 'draft',
 PUBLISHED: 'published',
 ARCHIVED: 'archived'
})

export const BUILDER_SECTIONS = Object.freeze([
 'personal',
 'summary',
 'experience',
 'education',
 'projects',
 'skills',
 'certifications',
 'languages',
 'achievements',
 'interests',
 'socialLinks'
])

export const SECTION_LABELS = Object.freeze({
 summary: 'Professional Summary',
 experience: 'Experience',
 education: 'Education',
 projects: 'Projects',
 skills: 'Skills',
 certifications: 'Certifications',
 languages: 'Languages',
 achievements: 'Achievements',
 interests: 'Interests'
})

export const FONT_FAMILIES = Object.freeze([
 { value: 'Inter', label: 'Inter' },
 { value: 'Roboto', label: 'Roboto' },
 { value: 'Open Sans', label: 'Open Sans' },
 { value: 'Poppins', label: 'Poppins' },
 { value: 'Montserrat', label: 'Montserrat' },
 { value: 'Merriweather', label: 'Merriweather' },
 { value: 'Lora', label: 'Lora' },
 { value: 'Playfair Display', label: 'Playfair Display' },
 { value: 'Nunito', label: 'Nunito' },
 { value: 'Ubuntu', label: 'Ubuntu' }
])

export const FONT_SIZES = Object.freeze([
 { value: 'small', label: 'Small', px: 13 },
 { value: 'medium', label: 'Medium', px: 14 },
 { value: 'large', label: 'Large', px: 16 }
])

export const PRIMARY_COLORS = Object.freeze([
 { value: 'blue', label: 'Blue', hex: '#3B82F6' },
 { value: 'purple', label: 'Purple', hex: '#6D28D9' },
 { value: 'black', label: 'Black', hex: '#0F172A' },
 { value: 'green', label: 'Green', hex: '#059669' },
 { value: 'red', label: 'Red', hex: '#DC2626' },
 { value: 'orange', label: 'Orange', hex: '#EA580C' }
])

export const COLOR_HEX = Object.fromEntries(PRIMARY_COLORS.map((c) => [c.value, c.hex]))

export const FONT_SIZE_PX = Object.fromEntries(FONT_SIZES.map((f) => [f.value, f.px]))

export const ZOOM_LEVELS = Object.freeze([50, 75, 100, 125, 150])

export const SOCIAL_LINK_PLATFORMS = Object.freeze([
 { key: 'leetcode', label: 'LeetCode', placeholder: 'https://leetcode.com/username' },
 { key: 'codeforces', label: 'Codeforces', placeholder: 'https://codeforces.com/profile/username' },
 { key: 'hackerrank', label: 'HackerRank', placeholder: 'https://hackerrank.com/username' }
])
