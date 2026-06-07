<template>
  <div class="rounded-2xl border p-5 shadow-panel transition" :class="cardClass">
    <div class="flex items-center justify-between">
      <p class="text-xs font-semibold uppercase tracking-wider" :class="labelClass">{{ label }}</p>
      <span class="grid size-9 place-items-center rounded-xl bg-brand/15 text-brand">
        <slot name="icon" />
      </span>
    </div>
    <p class="mt-3 text-3xl font-bold" :class="valueClass">
      <AnimatedNumber :value="numericValue" :suffix="suffix" />
    </p>
    <div v-if="sparkline.length" class="mt-3 h-10">
      <MiniSparkline :values="sparkline" :color="accentColor" />
    </div>
    <div class="mt-4 h-2 overflow-hidden rounded-full" :class="trackClass">
      <div class="h-full rounded-full transition-all duration-700" :class="barClass" :style="{ width: progress }" />
    </div>
  </div>
</template>

<script setup>
import { computed } from 'vue'
import AnimatedNumber from '../coming-soon/AnimatedNumber.vue'
import MiniSparkline from '../coming-soon/MiniSparkline.vue'

const props = defineProps({
  label: { type: String, required: true },
  value: { type: [Number, String], default: 0 },
  suffix: { type: String, default: '' },
  progress: { type: String, default: '0%' },
  sparkline: { type: Array, default: () => [] },
  accentColor: { type: String, default: '#6d4aff' },
  variant: { type: String, default: 'brand' }
})

const numericValue = computed(() => {
  const n = parseInt(String(props.value).replace('%', ''), 10)
  return Number.isNaN(n) ? 0 : n
})

const cardClass = 'border-slate-100 bg-white'
const labelClass = 'text-slate-500'
const valueClass = 'text-ink'
const trackClass = 'bg-slate-100'
const barClass = computed(() => ({
  brand: 'bg-brand',
  mint: 'bg-mint',
  amber: 'bg-amber-400',
  emerald: 'bg-emerald-400'
}[props.variant] || 'bg-brand'))
</script>
