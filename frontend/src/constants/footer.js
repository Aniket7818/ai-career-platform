export const SOCIAL_LINKS = Object.freeze([
 { name: 'linkedin', href: 'https://linkedin.com/company/careerai', label: 'LinkedIn' },
 { name: 'twitter', href: 'https://twitter.com/careerai', label: 'X (Twitter)' },
 { name: 'github', href: 'https://github.com/careerai', label: 'GitHub' },
 { name: 'instagram', href: 'https://instagram.com/careerai', label: 'Instagram' },
 { name: 'youtube', href: 'https://youtube.com/@careerai', label: 'YouTube' }
])

export const FOOTER_SECTIONS = Object.freeze([
 {
 titleKey: 'footer.sections.product',
 links: [
 { labelKey: 'footer.links.features', to: '/#features', external: false },
 { labelKey: 'footer.links.pricing', to: '/#pricing', external: false },
 { labelKey: 'footer.links.comingSoon', to: '/coming-soon', external: false },
 { labelKey: 'footer.links.dashboard', to: '/dashboard', external: false }
 ]
 },
 {
 titleKey: 'footer.sections.company',
 links: [
 { labelKey: 'footer.links.about', to: '/about', external: false },
 { labelKey: 'footer.links.careers', to: '/careers', external: false },
 { labelKey: 'footer.links.blog', to: '/blog', external: false },
 { labelKey: 'footer.links.contact', to: '/contact', external: false }
 ]
 },
 {
 titleKey: 'footer.sections.support',
 links: [
 { labelKey: 'footer.links.helpCenter', to: '/help', external: false },
 { labelKey: 'footer.links.faq', to: '/faq', external: false },
 { labelKey: 'footer.links.customerSupport', to: '/support', external: false },
 { labelKey: 'footer.links.status', to: '/status', external: false }
 ]
 },
 {
 titleKey: 'footer.sections.legal',
 links: [
 { labelKey: 'footer.links.privacy', to: '/privacy', external: false },
 { labelKey: 'footer.links.terms', to: '/terms', external: false },
 { labelKey: 'footer.links.cookies', to: '/cookies', external: false }
 ]
 }
])
