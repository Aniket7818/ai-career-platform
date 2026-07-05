<template>
 <footer class="w-full max-w-full border-t border-border bg-slate-900 text-white">
 <div class="page-container py-12 sm:py-16">
 <div class="grid gap-12 lg:grid-cols-[1.4fr_2fr]">
 <div>
 <RouterLink class="flex items-center gap-2 text-xl font-bold" to="/">
 <span class="grid size-9 place-items-center rounded-md bg-brand text-white">C</span>
 {{ t('brand') }}
 </RouterLink>
 <p class="mt-4 max-w-sm text-sm leading-7 text-txt-disabled">{{ t('footer.tagline') }}</p>
 <div class="mt-6 flex flex-wrap gap-3">
 <a
 v-for="social in SOCIAL_LINKS"
 :key="social.name"
 :href="social.href"
 target="_blank"
 rel="noopener noreferrer"
 :aria-label="social.label"
 class="grid size-10 place-items-center rounded-xl border border-white/10 bg-surface/5 text-txt-muted transition-all hover:-translate-y-1 hover:border-brand/40 hover:bg-brand/20 hover:text-white"
 >
 <SocialIcon :name="social.name" />
 </a>
 </div>

 <div class="mt-10 rounded-2xl bg-surface/5 p-6 border border-white/10 relative overflow-hidden group transition-all hover:border-brand/30">
 <h3 class="text-sm font-bold text-white mb-2">Subscribe to our Newsletter</h3>
 <p class="text-xs leading-5 text-txt-disabled mb-4">Get the latest career tips and product updates delivered to your inbox.</p>
 <div class="flex gap-2">
 <input type="email" placeholder="Enter your email" class="w-full rounded-lg bg-surface/10 border border-white/20 px-3 py-2 text-sm text-white placeholder-slate-400 focus:outline-none focus:border-brand focus:ring-1 focus:ring-brand disabled:opacity-50" disabled />
 <button class="rounded-lg bg-brand px-4 py-2 text-sm font-bold text-white transition-all shadow-md shadow-brand/20 disabled:opacity-50" disabled>Subscribe</button>
 </div>
 <div class="absolute inset-0 bg-slate-900/60 backdrop-blur-[2px] flex items-center justify-center opacity-0 group-hover:opacity-100 transition-all duration-300 z-10">
 <span class="inline-flex rounded-full bg-brand/20 px-3 py-1 text-xs font-bold text-brand ring-1 ring-brand/30 uppercase tracking-wider">Coming Soon</span>
 </div>
 </div>
 </div>

 <div class="grid gap-8 sm:grid-cols-2 lg:grid-cols-4">
 <div v-for="section in FOOTER_SECTIONS" :key="section.titleKey">
 <h3 class="text-sm font-semibold uppercase tracking-wider text-txt-muted">{{ t(section.titleKey) }}</h3>
 <ul class="mt-4 space-y-3">
 <li v-for="link in section.links" :key="link.labelKey">
 <RouterLink
 v-if="!link.external"
 :to="link.to"
 class="text-sm text-txt-disabled transition hover:text-white"
 >
 {{ t(link.labelKey) }}
 </RouterLink>
 <a
 v-else
 :href="link.to"
 target="_blank"
 rel="noopener noreferrer"
 class="text-sm text-txt-disabled transition hover:text-white"
 >
 {{ t(link.labelKey) }}
 </a>
 </li>
 </ul>
 </div>
 </div>
 </div>

 <div class="mt-14 flex flex-col items-center justify-between gap-4 border-t border-white/10 pt-8 sm:flex-row">
 <p class="text-sm text-txt-muted">{{ t('footer.copyright', { year }) }}</p>
 <div class="flex flex-wrap items-center justify-center gap-6 text-sm text-txt-muted">
 <RouterLink class="transition hover:text-white" to="/privacy">{{ t('footer.links.privacy') }}</RouterLink>
 <RouterLink class="transition hover:text-white" to="/terms">{{ t('footer.links.terms') }}</RouterLink>
 <RouterLink class="transition hover:text-white" to="/cookies">{{ t('footer.links.cookies') }}</RouterLink>
 </div>
 </div>
 </div>
 </footer>
</template>

<script setup>
import SocialIcon from '../ui/SocialIcon.vue'
import { FOOTER_SECTIONS, SOCIAL_LINKS } from '../../constants/footer'
import { t } from '../../utils/i18n'

const year = new Date().getFullYear()
</script>
