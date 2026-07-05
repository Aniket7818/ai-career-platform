<template>
 <main class="grid min-h-screen bg-surface lg:grid-cols-[1.1fr_1fr]">
 <section class="relative hidden overflow-hidden bg-gradient-to-br from-ink via-[#111827] to-[#0b1220] p-12 text-white lg:flex lg:flex-col">
 <div class="pointer-events-none absolute -left-16 top-10 size-64 rounded-full bg-brand/25 blur-3xl" />
 <RouterLink class="relative text-xl font-bold" to="/">{{ t('brand') }}</RouterLink>
 <div class="relative my-auto max-w-xl">
 <p class="inline-flex rounded-full border border-brand/30 bg-brand/10 px-3 py-1 text-xs font-semibold uppercase tracking-wider text-brand">{{ t('landing.badge') }}</p>
 <h1 class="mt-6 text-4xl font-bold leading-tight">{{ t('auth.forgotHeroTitle') }}</h1>
 <p class="mt-5 text-lg leading-8 text-txt-muted">{{ t('auth.forgotHeroSubtitle') }}</p>
 <ul class="mt-8 space-y-3">
 <li v-for="tip in tips" :key="tip" class="flex items-center gap-2 text-sm text-txt-muted">
 <span class="grid size-6 place-items-center rounded-full bg-brand/20 text-brand">✓</span>
 {{ tip }}
 </li>
 </ul>
 </div>
 </section>
 <section class="flex items-center justify-center p-6 sm:p-10">
 <slot />
 </section>
 </main>
</template>

<script setup>
import { t } from '../../utils/i18n'

const tips = [t('auth.forgotTip1'), t('auth.forgotTip2'), t('auth.forgotTip3')]
</script>
