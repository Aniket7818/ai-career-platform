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
 <template v-for="social in SOCIAL_LINKS" :key="social.name">
 <!-- Real link -->
 <a
 v-if="!social.comingSoon"
 :href="social.href"
 target="_blank"
 rel="noopener noreferrer"
 :aria-label="social.label"
 class="grid size-10 place-items-center rounded-xl border border-white/10 bg-surface/5 text-txt-muted transition-all hover:-translate-y-1 hover:border-brand/40 hover:bg-brand/20 hover:text-white"
 >
 <SocialIcon :name="social.name" />
 </a>
 <!-- Coming soon button -->
 <button
 v-else
 type="button"
 :aria-label="`${social.label} — Coming Soon`"
 class="relative grid size-10 place-items-center rounded-xl border border-white/10 bg-surface/5 text-txt-muted transition-all hover:-translate-y-1 hover:border-amber-400/40 hover:bg-amber-400/10 hover:text-amber-400"
 @click="openComingSoon(social.label)"
 >
 <SocialIcon :name="social.name" />
 </button>
 </template>
 </div>

 <div class="mt-8 space-y-3.5 border-t border-white/5 pt-6">
 <h3 class="text-xs font-bold uppercase tracking-wider text-txt-muted">Business & Support Contact</h3>
 <div class="flex flex-col gap-2.5 sm:flex-row sm:items-center">
 <a
 href="https://wa.me/916284424697"
 target="_blank"
 rel="noopener noreferrer"
 class="inline-flex items-center gap-2.5 rounded-xl border border-emerald-500/10 bg-emerald-500/5 px-4 py-2.5 text-sm font-semibold text-emerald-400 transition-all hover:border-emerald-500/30 hover:bg-emerald-500/10 hover:text-emerald-300"
 >
 <SocialIcon name="whatsapp" />
 <span>WhatsApp Business</span>
 </a>
 <a
 href="mailto:ajitaniket956556@gmail.com"
 class="inline-flex items-center gap-2.5 rounded-xl border border-white/10 bg-surface/5 px-4 py-2.5 text-sm font-semibold text-slate-300 transition-all hover:border-brand/40 hover:bg-brand/10 hover:text-white"
 >
 <svg class="size-5 text-slate-400 transition-colors group-hover:text-white" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
 <path stroke-linecap="round" stroke-linejoin="round" d="M3 8l7.89 5.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z" />
 </svg>
 <span>ajitaniket956556@gmail.com</span>
 </a>
 </div>
 </div>

  <div class="mt-10 rounded-2xl bg-surface/5 p-6 border border-white/10 relative overflow-hidden group transition-all hover:border-brand/35">
    <h3 class="text-sm font-bold text-white mb-2">Subscribe to our Newsletter</h3>
    <p class="text-xs leading-5 text-txt-disabled mb-4">Get the latest career tips and product updates delivered to your inbox.</p>
    <div class="flex gap-2">
      <input
        type="email"
        readonly
        placeholder="Enter your email"
        class="w-full rounded-lg bg-surface/10 border border-white/20 px-3 py-2 text-sm text-white placeholder-slate-400 focus:outline-none cursor-pointer"
        @click="openComingSoon('Newsletter')"
      />
      <button
        type="button"
        class="rounded-lg bg-brand px-4 py-2 text-sm font-bold text-white transition-all shadow-md shadow-brand/20 hover:bg-brand/90 cursor-pointer"
        @click="openComingSoon('Newsletter')"
      >
        Subscribe
      </button>
    </div>
  </div>
  </div>

  <div class="grid gap-8 grid-cols-2 lg:grid-cols-4">
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

 <!-- Teleport modal: renders outside footer, never clipped -->
 <Teleport to="body">
  <Transition
   enter-active-class="transition-all duration-300 ease-out"
   enter-from-class="opacity-0"
   enter-to-class="opacity-100"
   leave-active-class="transition-all duration-200 ease-in"
   leave-from-class="opacity-100"
   leave-to-class="opacity-0"
  >
   <div
    v-if="modalOpen"
    class="fixed inset-0 z-[9999] flex items-center justify-center p-4 bg-slate-950/70 backdrop-blur-md"
    @click.self="closeComingSoon"
   >
    <div
     class="relative w-full max-w-sm transform overflow-hidden rounded-3xl border border-white/10 bg-slate-900 p-8 text-center shadow-2xl transition-all scale-100"
    >
     <!-- Decorative Top Icon (Diamond/Star) -->
     <div class="mx-auto mb-5 grid size-16 place-items-center rounded-2xl bg-brand/10 text-brand">
      <svg class="size-8 animate-pulse" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="1.75">
       <path stroke-linecap="round" stroke-linejoin="round" d="M11.48 3.499c.198-.39.754-.39.952 0l2.253 4.433 4.801.737c.427.065.597.608.283.923l-3.486 3.402.83 4.793c.074.428-.37.75-.75.55l-4.298-2.26-4.298 2.26c-.38.2-.824-.122-.75-.55l.83-4.793-3.486-3.402c-.314-.315-.144-.858.283-.923l4.801-.737 2.253-4.433z" />
      </svg>
     </div>

     <!-- Content -->
     <h3 class="text-xl font-extrabold text-white">{{ comingSoonLabel === 'Newsletter' ? 'Newsletter' : comingSoonLabel + ' Page' }}</h3>
     <p class="mt-1 text-xs font-bold uppercase tracking-wider text-amber-400">Coming Soon</p>
     <p class="mt-4 text-sm leading-6 text-slate-300">
      <template v-if="comingSoonLabel === 'Newsletter'">
        We are currently building our newsletter subscription service. Stay tuned for career tips and platform updates!
      </template>
      <template v-else>
        We are currently building a new, polished version of our official page. Stay tuned for updates!
      </template>
     </p>

     <!-- Action Button -->
     <div class="mt-7">
      <button
       type="button"
       class="w-full rounded-2xl bg-brand py-3 text-sm font-bold text-white shadow-lg shadow-brand/20 transition-all hover:bg-brand/90 hover:shadow-brand/35 focus:outline-none"
       @click="closeComingSoon"
      >
       OK
      </button>
     </div>
    </div>
   </div>
  </Transition>
 </Teleport>
</template>

<script setup>
import { ref } from 'vue'
import SocialIcon from '../ui/SocialIcon.vue'
import { FOOTER_SECTIONS, SOCIAL_LINKS } from '../../constants/footer'
import { t } from '../../utils/i18n'

const year = new Date().getFullYear()
const modalOpen = ref(false)
const comingSoonLabel = ref('')

function openComingSoon(label) {
 comingSoonLabel.value = label
 modalOpen.value = true
}

function closeComingSoon() {
 modalOpen.value = false
}
</script>
