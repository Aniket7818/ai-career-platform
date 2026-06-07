<template>
  <footer class="w-full max-w-full border-t border-slate-200 bg-ink text-white">
    <div class="page-container py-12 sm:py-16">
      <div class="grid gap-12 lg:grid-cols-[1.4fr_2fr]">
        <div>
          <RouterLink class="flex items-center gap-2 text-xl font-bold" to="/">
            <span class="grid size-9 place-items-center rounded-md bg-brand text-white">C</span>
            {{ t('brand') }}
          </RouterLink>
          <p class="mt-4 max-w-sm text-sm leading-7 text-slate-400">{{ t('footer.tagline') }}</p>
          <div class="mt-6 flex flex-wrap gap-3">
            <a
              v-for="social in SOCIAL_LINKS"
              :key="social.name"
              :href="social.href"
              target="_blank"
              rel="noopener noreferrer"
              :aria-label="social.label"
              class="grid size-10 place-items-center rounded-xl border border-white/10 bg-white/5 text-slate-300 transition hover:border-brand/40 hover:bg-brand/20 hover:text-white"
            >
              <SocialIcon :name="social.name" />
            </a>
          </div>
        </div>

        <div class="grid gap-8 sm:grid-cols-2 lg:grid-cols-4">
          <div v-for="section in FOOTER_SECTIONS" :key="section.titleKey">
            <h3 class="text-sm font-semibold uppercase tracking-wider text-slate-300">{{ t(section.titleKey) }}</h3>
            <ul class="mt-4 space-y-3">
              <li v-for="link in section.links" :key="link.labelKey">
                <RouterLink
                  v-if="!link.external"
                  :to="link.to"
                  class="text-sm text-slate-400 transition hover:text-white"
                >
                  {{ t(link.labelKey) }}
                </RouterLink>
                <a
                  v-else
                  :href="link.to"
                  target="_blank"
                  rel="noopener noreferrer"
                  class="text-sm text-slate-400 transition hover:text-white"
                >
                  {{ t(link.labelKey) }}
                </a>
              </li>
            </ul>
          </div>
        </div>
      </div>

      <div class="mt-14 flex flex-col items-center justify-between gap-4 border-t border-white/10 pt-8 sm:flex-row">
        <p class="text-sm text-slate-500">{{ t('footer.copyright', { year }) }}</p>
        <div class="flex flex-wrap items-center justify-center gap-6 text-sm text-slate-500">
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
