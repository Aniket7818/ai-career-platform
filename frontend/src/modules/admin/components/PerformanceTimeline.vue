<template>
  <div class="py-6 overflow-x-auto custom-scrollbar">
    <div class="flex items-center min-w-max px-4">
      <template v-for="(stage, i) in stages" :key="stage.name">
        <div class="flex flex-col items-center relative group w-24">
          
          <!-- Hover Tooltip -->
          <div class="absolute bottom-full mb-2 opacity-0 group-hover:opacity-100 transition-opacity bg-[#1a2234] text-white text-[10px] px-3 py-2 rounded-lg shadow-xl border border-white/10 pointer-events-none z-20 w-32 text-center flex flex-col gap-1">
            <span class="font-bold text-xs capitalize" :class="getColor(stage.status).text">{{ stage.name }}</span>
            <span class="text-txt-muted">{{ stage.duration ? stage.duration + 'ms' : '---' }}</span>
            <span v-if="stage.timestamp" class="text-[8px] text-txt-disabled">{{ new Date(stage.timestamp).toLocaleTimeString() }}</span>
          </div>
          
          <!-- Node -->
          <div class="size-8 rounded-full flex items-center justify-center text-xs z-10 transition-transform group-hover:scale-110 shadow-lg"
               :class="getColor(stage.status).bg + ' ' + getColor(stage.status).text + ' ' + getColor(stage.status).border">
            <svg v-if="stage.status === 'success'" class="size-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="20 6 9 17 4 12"></polyline></svg>
            <svg v-else-if="stage.status === 'failed'" class="size-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><line x1="18" y1="6" x2="6" y2="18"></line><line x1="6" y1="6" x2="18" y2="18"></line></svg>
            <svg v-else-if="stage.status === 'warning'" class="size-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"></circle><line x1="12" y1="8" x2="12" y2="12"></line><line x1="12" y1="16" x2="12.01" y2="16"></line></svg>
            <svg v-else class="size-4 opacity-50" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"></circle><polyline points="12 6 12 12 16 14"></polyline></svg>
          </div>
          
          <!-- Label -->
          <span class="text-[9px] font-bold uppercase tracking-wider mt-3 text-center"
                :class="stage.status === 'pending' ? 'text-txt-disabled' : 'text-txt-muted'">
            {{ stage.name }}
          </span>
          <span v-if="stage.duration" class="text-[8px] font-mono text-txt-disabled mt-0.5">{{ stage.duration }}ms</span>
        </div>
        
        <!-- Connector Line -->
        <div v-if="i < stages.length - 1" class="h-1 bg-white/5 flex-1 min-w-[40px] max-w-[80px] mx-1 relative top-[-15px] rounded-full overflow-hidden">
          <div class="h-full w-full transition-all duration-1000"
               :class="getLineColor(stage.status, stages[i+1].status)"></div>
        </div>
      </template>
    </div>
  </div>
</template>

<script setup>
const props = defineProps({
  stages: {
    type: Array,
    required: true
    // Array of { name: 'Authentication', status: 'success'|'failed'|'warning'|'pending', duration: 120, timestamp: '2023...' }
  }
})

const getColor = (status) => {
  switch(status) {
    case 'success': return { bg: 'bg-emerald-500/20', text: 'text-emerald-400', border: 'border border-emerald-500/30' }
    case 'failed': return { bg: 'bg-rose-500/20', text: 'text-rose-400', border: 'border border-rose-500/30' }
    case 'warning': return { bg: 'bg-amber-500/20', text: 'text-amber-400', border: 'border border-amber-500/30' }
    default: return { bg: 'bg-surface', text: 'text-txt-muted', border: 'border border-white/10' }
  }
}

const getLineColor = (currentStatus, nextStatus) => {
  if (currentStatus === 'success') {
    if (nextStatus === 'success' || nextStatus === 'warning') return 'bg-emerald-500/50'
    if (nextStatus === 'failed') return 'bg-gradient-to-r from-emerald-500/50 to-rose-500/50'
    return 'bg-gradient-to-r from-emerald-500/50 to-transparent'
  }
  if (currentStatus === 'failed') return 'bg-transparent'
  if (currentStatus === 'warning') return 'bg-amber-500/50'
  return 'bg-transparent'
}
</script>
