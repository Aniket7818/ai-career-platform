<template>
 <PublicLayout>
 <section class="relative overflow-hidden border-b border-border bg-gradient-to-br from-skyglass via-white to-white px-5 py-16 lg:py-20">
 <div class="pointer-events-none absolute -right-20 top-0 size-72 rounded-full bg-brand/10 blur-3xl" />
 <div class="pointer-events-none absolute -left-16 bottom-0 size-56 rounded-full bg-mint/10 blur-3xl" />
 <div class="relative mx-auto max-w-3xl text-center">
 <p v-if="page.badge" class="inline-flex rounded-full bg-brand/10 px-3 py-1 text-sm font-semibold text-brand">{{ page.badge }}</p>
 <h1 class="mt-4 text-4xl font-bold tracking-tight text-txt-primary lg:text-5xl">{{ page.title }}</h1>
 <p v-if="page.subtitle" class="mx-auto mt-4 max-w-2xl text-lg leading-8 text-txt-secondary">{{ page.subtitle }}</p>
 <p v-if="page.updated" class="mt-4 text-sm text-txt-disabled">{{ t('pages.lastUpdated', { date: page.updated }) }}</p>
 </div>
 </section>

 <section class="mx-auto max-w-3xl px-5 py-14 lg:py-16">
 <div v-if="page.comingSoon" class="rounded-2xl border border-border bg-background p-10 text-center shadow-panel">
 <p class="text-lg font-semibold text-txt-primary">{{ t('pages.comingSoonTitle') }}</p>
 <p class="mt-3 text-txt-secondary">{{ t('pages.comingSoonBody') }}</p>
 <RouterLink class="mt-6 inline-flex rounded-md bg-brand px-5 py-3 font-semibold text-white shadow-lg shadow-brand/20" to="/coming-soon">
 {{ t('nav.comingSoon') }}
 </RouterLink>
 </div>

 <div v-else class="space-y-10">
 <div v-for="(section, index) in page.sections" :key="index">
 <h2 v-if="section.heading" class="text-2xl font-bold text-txt-primary">{{ section.heading }}</h2>
 <p v-if="section.body" class="mt-4 text-base leading-8 text-txt-secondary">{{ section.body }}</p>
 <ul v-if="section.items?.length" class="mt-4 space-y-3">
 <li v-for="(item, i) in section.items" :key="i" class="flex gap-3 text-txt-secondary">
 <span class="mt-2 size-1.5 shrink-0 rounded-full bg-brand" />
 <span class="leading-7">{{ item }}</span>
 </li>
 </ul>
 </div>

 <div v-if="page.cta" class="rounded-2xl border border-brand/20 bg-brand/5 p-8 text-center">
 <p class="text-lg font-semibold text-txt-primary">{{ page.cta.title }}</p>
 <p v-if="page.cta.body" class="mt-2 text-txt-secondary">{{ page.cta.body }}</p>
 <RouterLink class="mt-5 inline-flex rounded-md bg-brand px-5 py-3 font-semibold text-white" :to="page.cta.to">
 {{ page.cta.label }}
 </RouterLink>
 </div>
 </div>
 </section>
 </PublicLayout>
</template>

<script setup>
import { computed } from 'vue'
import { useRoute } from 'vue-router'
import PublicLayout from '../../components/layout/PublicLayout.vue'
import { t } from '../../utils/i18n'

const route = useRoute()
const pageKey = computed(() => route.meta.pageKey)
const page = computed(() => t(`pages.${pageKey.value}`) || {})
</script>
