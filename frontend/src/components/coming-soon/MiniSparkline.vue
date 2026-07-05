<template>
 <svg :viewBox="`0 0 ${width} ${height}`" class="h-full w-full" preserveAspectRatio="none">
 <defs>
 <linearGradient :id="gradientId" x1="0" y1="0" x2="0" y2="1">
 <stop offset="0%" :stop-color="color" stop-opacity="0.35" />
 <stop offset="100%" :stop-color="color" stop-opacity="0" />
 </linearGradient>
 </defs>
 <path :d="areaPath" :fill="`url(#${gradientId})`" />
 <path :d="linePath" fill="none" :stroke="color" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" />
 </svg>
</template>

<script setup>
import { computed } from 'vue'

const props = defineProps({
 values: { type: Array, default: () => [] },
 width: { type: Number, default: 200 },
 height: { type: Number, default: 60 },
 color: { type: String, default: '#6d4aff' }
})

const gradientId = `spark-${Math.random().toString(36).slice(2, 9)}`

const points = computed(() => {
 const vals = props.values.length ? props.values : [0]
 const max = Math.max(...vals, 1)
 const min = Math.min(...vals, 0)
 const range = max - min || 1
 return vals.map((v, i) => ({
 x: (i / Math.max(vals.length - 1, 1)) * props.width,
 y: props.height - ((v - min) / range) * (props.height - 8) - 4
 }))
})

const linePath = computed(() => points.value.map((p, i) => `${i === 0 ? 'M' : 'L'} ${p.x} ${p.y}`).join(' '))

const areaPath = computed(() => {
 const pts = points.value
 if (!pts.length) return ''
 const first = pts[0]
 const last = pts[pts.length - 1]
 return `${linePath.value} L ${last.x} ${props.height} L ${first.x} ${props.height} Z`
})
</script>
