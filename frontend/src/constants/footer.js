export const SOCIAL_LINKS = Object.freeze([
 { name: 'linkedin',  href: 'https://www.linkedin.com/in/aniket-yadav05', label: 'LinkedIn',    comingSoon: false },
 { name: 'twitter',   href: null,                                          label: 'X (Twitter)', comingSoon: true  },
 { name: 'github',    href: 'https://github.com/Aniket7818',               label: 'GitHub',      comingSoon: false },
 { name: 'instagram', href: 'https://www.instagram.com/infinvo.tech?igsh=YTA0ZGUyMDR4cDEz', label: 'Instagram', comingSoon: false },
 { name: 'youtube',   href: null,                                          label: 'YouTube',     comingSoon: true  },
 { name: 'facebook',  href: 'http://facebook.com/infinvo',                 label: 'Facebook',    comingSoon: false }
])

export const FOOTER_SECTIONS = Object.freeze([
 {
 titleKey: 'footer.sections.product',
 links: [
 { labelKey: 'footer.links.features', to: '/features', external: false },
 { labelKey: 'footer.links.comingSoon', to: '/coming-soon', external: false },
 { labelKey: 'footer.links.dashboard', to: '/dashboard', external: false }
 ]
 },
 {
 titleKey: 'footer.sections.company',
 links: [
 { labelKey: 'footer.links.about', to: '/about', external: false },
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
