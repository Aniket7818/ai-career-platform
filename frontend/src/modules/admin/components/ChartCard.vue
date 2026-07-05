<template>
  <div class="rounded-xl border border-white/5 bg-surface/[0.02] p-5 flex flex-col group relative transition-all duration-300 hover:bg-surface/5 hover:border-white/10 hover:shadow-xl hover:shadow-black/20">
    <div class="flex justify-between items-center mb-4">
      <h4 class="text-sm font-bold text-white tracking-wide">{{ title }}</h4>
      <div class="hidden group-hover:flex gap-1 bg-surface/10 rounded-lg border border-white/5 p-0.5 opacity-0 group-hover:opacity-100 transition-opacity">
        <button v-for="range in ['24h', '7d', '30d', '90d']" :key="range" 
                class="text-[9px] px-2 py-0.5 rounded text-txt-muted hover:text-white hover:bg-white/10 font-bold uppercase tracking-wider transition-colors">
          {{ range }}
        </button>
      </div>
    </div>
    
    <div v-if="!data || !data.length" class="h-40 flex flex-col items-center justify-center text-center">
      <div class="size-12 rounded-full bg-white/5 flex items-center justify-center mb-3 group-hover:scale-110 transition-transform">
        <svg class="size-5 text-txt-muted" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
          <path d="M3 3v18h18" />
          <path d="M18 17V9" />
          <path d="M13 17V5" />
          <path d="M8 17v-3" />
        </svg>
      </div>
      <p class="text-xs text-txt-muted max-w-[200px]">{{ emptyMessage || 'Data is accumulating. Check back shortly.' }}</p>
    </div>

    <template v-else>
      <div class="flex-1 flex items-end gap-1 relative border-b border-white/5 pb-1 mt-2 h-40">
        <!-- Grid lines -->
        <div class="absolute inset-0 flex flex-col justify-between pointer-events-none">
          <div class="border-t border-white/5 w-full opacity-50"></div>
          <div class="border-t border-white/5 w-full opacity-50"></div>
          <div class="border-t border-white/5 w-full opacity-50"></div>
        </div>
        
        <!-- Bars -->
        <div v-for="(d, i) in data" :key="i" class="group/bar relative flex flex-col items-center justify-end h-full flex-1">
          <!-- Tooltip -->
          <div class="absolute bottom-full mb-2 opacity-0 group-hover/bar:opacity-100 transition-opacity bg-[#1a2234] text-white text-[10px] px-3 py-1.5 rounded-lg shadow-xl border border-white/10 pointer-events-none z-10 font-mono flex flex-col items-center gap-1">
            <span class="text-txt-muted uppercase tracking-wider text-[8px]">{{ getLabel(d) }}</span>
            <span class="font-bold text-xs" :style="{ color: color }">{{ getVal(d) }}</span>
          </div>
          
          <!-- Bar -->
          <div class="w-[85%] rounded-t-sm transition-all duration-300 hover:opacity-100 opacity-80"
               :class="type === 'line' ? 'w-full opacity-40' : ''"
               :style="{ 
                 height: `${Math.max(getHVal(d), 2)}px`, 
                 backgroundColor: type === 'line' ? 'transparent' : color,
                 borderTop: type === 'line' ? `2px solid ${color}` : 'none'
               }">
          </div>
        </div>
      </div>
      <div class="flex justify-between text-[9px] text-txt-disabled mt-2 uppercase font-mono font-bold tracking-wider opacity-70">
        <span>{{ getLabel(data[0]) }}</span>
        <span>{{ getLabel(data[data.length - 1]) }}</span>
      </div>
    </template>
  </div>
</template>

<script setup>
import { computed } from 'vue'

const props = defineProps({
  title: String,
  data: Array,
  type: String, // 'bar' or 'line'
  color: String,
  yKey: String,
  xKey: String,
  emptyMessage: String
})

const getVal = (d) => props.yKey ? d[props.yKey] : d.cost !== undefined ? d.cost : d.count
const maxVal = computed(() => {
  if (!props.data || !props.data.length) return 1
  const values = props.data.map(d => getVal(d))
  return Math.max(...values, 1)
})

const getHVal = (d) => {
  return (getVal(d) / maxVal.value) * 150
}
const getLabel = (d) => {
  if (!d) return ''
  return props.xKey ? d[props.xKey] : (d.date || d.name || 'N/A')
}
</script>
