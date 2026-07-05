<template>
  <div class="rounded-xl border bg-surface/[0.02] p-4 transition relative group"
       :class="[
         isPriority ? 'border-white/10 border-l-4 border-l-brand/80 shadow-[0_0_20px_rgba(109,74,255,0.05)] hover:bg-surface/5' 
                    : 'border-white/5 hover:border-brand/20 hover:bg-surface/5'
       ]">
    <div class="flex justify-between items-center mb-1">
      <p class="text-[10px] uppercase tracking-wider font-bold" :class="isPriority ? 'text-brand/80' : 'text-txt-muted'">
        {{ label }}
      </p>
      <div v-if="tooltip" class="text-txt-disabled cursor-help" :title="tooltip">
        <svg class="size-3" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
          <circle cx="12" cy="12" r="10"></circle>
          <path d="M12 16v-4"></path>
          <path d="M12 8h.01"></path>
        </svg>
      </div>
    </div>
    
    <div class="flex items-end justify-between mt-1">
      <div>
        <p class="text-2xl font-bold text-white">{{ formattedValue }}</p>
        <p v-if="hint" class="text-[10px] text-txt-disabled mt-1">{{ hint }}</p>
      </div>
      <!-- Mini Sparkline Placeholder -->
      <div v-if="trend" class="flex flex-col items-end">
        <span class="text-[10px] font-bold" :class="trend > 0 ? 'text-emerald-400' : 'text-rose-400'">
          {{ trend > 0 ? '▲' : '▼' }} {{ Math.abs(trend) }}%
        </span>
        <svg class="w-12 h-6 mt-1 opacity-50" viewBox="0 0 100 30" preserveAspectRatio="none">
          <polyline :stroke="trend > 0 ? '#10b981' : '#f43f5e'" fill="none" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"
                    :points="trend > 0 ? '0,25 25,20 50,22 75,10 100,5' : '0,5 25,10 50,8 75,20 100,25'"></polyline>
        </svg>
      </div>
    </div>
  </div>
</template>

<script setup>
import { computed, ref, onMounted, watch } from 'vue'

const props = defineProps({
  label: String,
  value: [String, Number],
  hint: String,
  tooltip: String,
  priority: [String, Boolean],
  trend: Number // Optional: percentage trend e.g. 12 or -5
})

const isPriority = computed(() => props.priority === '' || props.priority === true || props.priority === 'true')

// Number animation logic
const displayValue = ref(0)
const isCurrency = computed(() => typeof props.value === 'string' && props.value.startsWith('$'))
const isPercentage = computed(() => typeof props.value === 'string' && props.value.endsWith('%'))
const isSeconds = computed(() => typeof props.value === 'string' && props.value.endsWith('s'))

const numericValue = computed(() => {
  if (typeof props.value === 'number') return props.value
  if (!props.value) return 0
  const clean = props.value.replace(/[^0-9.-]+/g, '')
  return parseFloat(clean) || 0
})

const formattedValue = computed(() => {
  if (displayValue.value === 0 && numericValue.value === 0) return props.value || '0'
  
  let formatted = displayValue.value
  
  // Try to preserve original formatting
  if (typeof props.value === 'string') {
    if (props.value.includes('.')) {
      const decimals = props.value.split('.')[1].replace(/[^0-9]/g, '').length
      formatted = formatted.toFixed(Math.min(decimals, 5))
    } else {
      formatted = Math.round(formatted)
    }
  } else {
    formatted = Math.round(formatted)
  }
  
  if (isCurrency.value) return `$${formatted}`
  if (isPercentage.value) return `${formatted}%`
  if (isSeconds.value) return `${formatted}s`
  return formatted.toLocaleString()
})

const animateValue = (start, end, duration = 1000) => {
  let startTimestamp = null
  const step = (timestamp) => {
    if (!startTimestamp) startTimestamp = timestamp
    const progress = Math.min((timestamp - startTimestamp) / duration, 1)
    // Ease out quad
    const easeProgress = progress * (2 - progress)
    displayValue.value = start + easeProgress * (end - start)
    if (progress < 1) {
      window.requestAnimationFrame(step)
    } else {
      displayValue.value = end
    }
  }
  window.requestAnimationFrame(step)
}

watch(numericValue, (newVal, oldVal) => {
  animateValue(oldVal || 0, newVal)
})

onMounted(() => {
  animateValue(0, numericValue.value)
})
</script>
