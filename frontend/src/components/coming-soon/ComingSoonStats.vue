<template>
 <div class="grid gap-4 sm:grid-cols-2 xl:grid-cols-4">
 <div v-for="card in cards" :key="card.label" class="rounded-2xl border border-white/10 bg-surface-light/60 p-5 backdrop-blur">
 <div class="flex items-center justify-between">
 <p class="text-xs font-semibold uppercase tracking-wider text-txt-disabled">{{ card.label }}</p>
 <span class="grid size-8 place-items-center rounded-lg bg-brand/15 text-brand">
 <component :is="card.icon" />
 </span>
 </div>
 <p class="mt-3 text-3xl font-bold text-white">
 <AnimatedNumber :value="card.value" :suffix="card.suffix" />
 </p>
 <div class="mt-3 h-10">
 <MiniSparkline :values="card.sparkline" :color="card.color" />
 </div>
 </div>
 </div>
</template>

<script setup>
import { computed, h } from 'vue'
import AnimatedNumber from './AnimatedNumber.vue'
import MiniSparkline from './MiniSparkline.vue'
import { t } from '../../utils/i18n'

const props = defineProps({
 stats: { type: Object, default: () => ({}) },
 trend: { type: Object, default: () => ({ values: [] }) }
})

const iconSvg = (paths) => ({
 render: () => h('svg', { class: 'size-4', viewBox: '0 0 24 24', fill: 'none', stroke: 'currentColor', 'stroke-width': '2' }, paths.map((d) => h('path', { d })))
})

const cards = computed(() => {
 const trend = props.trend.values?.length ? props.trend.values : [0, 0, 0, 0, 0, 0, 0]
 return [
 {
 label: t('comingSoon.stats.totalInterests'),
 value: props.stats.total_interests || 0,
 suffix: '',
 sparkline: trend,
 color: '#6d4aff',
 icon: iconSvg(['M17 21v-2a4 4 0 00-4-4H5a4 4 0 00-4 4v2', 'M9 11a4 4 0 100-8 4 4 0 000 8z', 'M23 21v-2a4 4 0 00-3-3.87', 'M16 3.13a4 4 0 010 7.75'])
 },
 {
 label: t('comingSoon.stats.inDevelopment'),
 value: props.stats.features_in_development || 0,
 suffix: '',
 sparkline: trend.map((v) => Math.round(v * 0.4)),
 color: '#fbbf24',
 icon: iconSvg(['M12 2v4', 'M12 18v4', 'M4.93 4.93l2.83 2.83', 'M16.24 16.24l2.83 2.83', 'M2 12h4', 'M18 12h4', 'M4.93 19.07l2.83-2.83', 'M16.24 7.76l2.83-2.83'])
 },
 {
 label: t('comingSoon.stats.launchingSoon'),
 value: props.stats.features_launching_soon || 0,
 suffix: '',
 sparkline: trend.map((v) => Math.round(v * 0.25)),
 color: '#34d399',
 icon: iconSvg(['M13 2L3 14h9l-1 8 10-12h-9l1-8z'])
 },
 {
 label: t('comingSoon.stats.avgProgress'),
 value: props.stats.average_progress || 0,
 suffix: '%',
 sparkline: trend.map((v, i) => (props.stats.average_progress || 0) - 10 + i * 2),
 color: '#35d6b4',
 icon: iconSvg(['M22 12h-4l-3 9L9 3l-3 9H2'])
 }
 ]
})
</script>
