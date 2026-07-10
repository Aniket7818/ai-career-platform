<template>
  <div class="relative bg-black/50 border border-white/5 rounded-lg overflow-hidden group">
    <div class="flex justify-between items-center bg-surface/[0.05] px-4 py-2 border-b border-white/5">
      <h4 class="text-[10px] font-bold text-txt-muted uppercase tracking-wider">{{ title || 'JSON Viewer' }}</h4>
      <div class="flex gap-2">
        <button @click="copyToClipboard" :disabled="isCopying" class="text-[10px] bg-brand/10 text-brand px-2 py-1 rounded hover:bg-brand/20 transition-colors flex items-center gap-1">
          <svg v-if="isCopying" class="size-3 animate-spin" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M21 12a9 9 0 11-18 0 9 9 0 0118 0z" stroke-opacity="0.25"/><path d="M12 3a9 9 0 019 9"/></svg>
          <svg v-else class="size-3" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="9" y="9" width="13" height="13" rx="2" ry="2"></rect><path d="M5 15H4a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2h9a2 2 0 0 1 2 2v1"></path></svg>
          {{ isCopying ? 'Copying...' : copied ? '✓ Copied!' : 'Copy' }}
        </button>
        <button v-if="downloadable" @click="downloadJson" class="text-[10px] bg-white/5 text-white px-2 py-1 rounded hover:bg-white/10 transition-colors flex items-center gap-1">
          <svg class="size-3" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"></path><polyline points="7 10 12 15 17 10"></polyline><line x1="12" y1="15" x2="12" y2="3"></line></svg>
          Download
        </button>
      </div>
    </div>
    
    <div v-if="!data || (typeof data === 'object' && Object.keys(data).length === 0)" class="p-8 flex flex-col items-center justify-center text-center">
      <div class="size-10 rounded-full bg-white/5 flex items-center justify-center mb-3">
        <svg class="size-4 text-txt-disabled" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"></path><polyline points="14 2 14 8 20 8"></polyline><line x1="9" y1="15" x2="15" y2="15"></line></svg>
      </div>
      <p class="text-xs text-txt-muted">No payload data available.</p>
    </div>
    
    <div v-else class="p-4 overflow-auto max-h-96 custom-scrollbar text-xs font-mono">
      <pre class="text-slate-300 whitespace-pre-wrap"><code v-html="highlightedJson"></code></pre>
    </div>
  </div>
</template>

<script setup>
import { computed, ref } from 'vue'
import ClipboardService from '../../../services/clipboard'

const props = defineProps({
  data: {
    type: [Object, Array, String],
    default: null
  },
  title: String,
  downloadable: {
    type: Boolean,
    default: true
  }
})

const copied = ref(false)
const isCopying = ref(false)

const formattedJson = computed(() => {
  if (!props.data) return ''
  try {
    const obj = typeof props.data === 'string' ? JSON.parse(props.data) : props.data
    return JSON.stringify(obj, null, 2)
  } catch (e) {
    return String(props.data)
  }
})

// Simple syntax highlighting for JSON
const highlightedJson = computed(() => {
  let json = formattedJson.value
  if (!json) return ''
  json = json.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;')
  return json.replace(/("(\\u[a-zA-Z0-9]{4}|\\[^u]|[^\\"])*"(\s*:)?|\b(true|false|null)\b|-?\d+(?:\.\d*)?(?:[eE][+\-]?\d+)?)/g, function (match) {
    let cls = 'text-amber-400' // number
    if (/^"/.test(match)) {
      if (/:$/.test(match)) {
        cls = 'text-brand' // key
      } else {
        cls = 'text-emerald-400' // string
      }
    } else if (/true|false/.test(match)) {
      cls = 'text-purple-400' // boolean
    } else if (/null/.test(match)) {
      cls = 'text-rose-400' // null
    }
    return '<span class="' + cls + '">' + match + '</span>'
  })
})

const copyToClipboard = async () => {
  isCopying.value = true
  await new Promise(resolve => setTimeout(resolve, 150))
  isCopying.value = false
  const success = await ClipboardService.copy(formattedJson.value, {
    successMessage: 'JSON payload copied successfully.'
  })
  if (success) {
    copied.value = true
    setTimeout(() => copied.value = false, 2000)
  }
}

const downloadJson = () => {
  const blob = new Blob([formattedJson.value], { type: 'application/json' })
  const url = URL.createObjectURL(blob)
  const a = document.createElement('a')
  a.href = url
  a.download = `payload_${Date.now()}.json`
  document.body.appendChild(a)
  a.click()
  document.body.removeChild(a)
  URL.revokeObjectURL(url)
}
</script>
