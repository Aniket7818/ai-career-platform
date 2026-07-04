<template>
  <div class="ai-widget rounded-xl border border-slate-200 bg-white shadow-sm relative overflow-hidden">
    <!-- Header -->
    <div class="flex items-center justify-between px-4 pt-4 pb-3 border-b border-slate-100">
      <div class="flex items-center gap-2">
        <div class="flex h-7 w-7 items-center justify-center rounded-lg bg-violet-100">
          <svg class="size-4 text-violet-600" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <path d="M13 2L3 14h9l-1 8 10-12h-9l1-8z"/>
          </svg>
        </div>
        <h3 class="text-sm font-bold text-slate-800">{{ title }}</h3>
      </div>
      <div class="flex items-center gap-2">
        <span class="rounded-full bg-violet-50 border border-violet-200 text-violet-700 px-2.5 py-0.5 text-[10px] font-bold tracking-wide">
          ⚡ {{ creditsRequired }} credit{{ creditsRequired === 1 ? '' : 's' }}
        </span>
        <button v-if="history.length > 0" type="button" @click="showHistory = !showHistory"
          class="rounded-lg px-2 py-1 text-[10px] font-bold text-slate-500 hover:bg-slate-100 transition">
          {{ showHistory ? 'Hide' : 'History' }} ({{ history.length }})
        </button>
      </div>
    </div>

    <div class="p-4 space-y-3">
      <!-- Error -->
      <div v-if="error" class="rounded-lg bg-red-50 border border-red-200 p-3 text-xs text-red-700 flex items-start gap-2">
        <svg class="size-4 shrink-0 mt-0.5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
          <circle cx="12" cy="12" r="10"/><path d="M12 8v4m0 4h.01"/>
        </svg>
        <span>{{ error }}</span>
      </div>

      <!-- Loading skeleton -->
      <div v-if="loading" class="space-y-2 py-1">
        <div class="h-2.5 w-full animate-pulse rounded-full bg-slate-100"></div>
        <div class="h-2.5 w-5/6 animate-pulse rounded-full bg-slate-100"></div>
        <div class="h-2.5 w-4/6 animate-pulse rounded-full bg-slate-100"></div>
        <p class="text-xs text-slate-400 text-center pt-1 flex items-center justify-center gap-1.5">
          <svg class="size-3 animate-spin" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <path d="M21 12a9 9 0 11-18 0 9 9 0 0118 0z" stroke-opacity="0.25"/>
            <path d="M12 3a9 9 0 019 9"/>
          </svg>
          Generating AI response…
        </p>
      </div>

      <!-- Result -->
      <div v-else-if="result" class="space-y-3">
        <div class="rounded-lg bg-violet-50 border border-violet-100 p-3 text-sm text-slate-700 leading-relaxed whitespace-pre-wrap max-h-48 overflow-y-auto custom-scrollbar">
          {{ result }}
        </div>
        <div class="flex flex-wrap gap-2">
          <button type="button" @click="applyResult"
            class="flex items-center gap-1.5 rounded-lg bg-violet-600 px-3 py-1.5 text-xs font-bold text-white transition hover:bg-violet-700 shadow-sm">
            <svg class="size-3.5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M20 6L9 17l-5-5"/></svg>
            Apply to Resume
          </button>
          <button type="button" @click="generate(true)"
            class="rounded-lg border border-slate-200 bg-white px-3 py-1.5 text-xs font-bold text-slate-600 transition hover:bg-slate-50">
            Regenerate (⚡ {{ creditsRequired }})
          </button>
        </div>
      </div>

      <!-- Default: instruction input + generate button -->
      <div v-else class="space-y-2.5">
        <textarea
          v-if="allowInstructions"
          v-model="instructions"
          :placeholder="instructionPlaceholder"
          class="w-full rounded-lg border border-slate-200 bg-slate-50 p-2.5 text-xs text-slate-700 placeholder:text-slate-400 focus:border-violet-400 focus:ring-1 focus:ring-violet-200 focus:bg-white outline-none transition resize-none"
          rows="2"
          maxlength="500"
        ></textarea>
        <button type="button" @click="generate(false)"
          class="flex w-full items-center justify-center gap-2 rounded-lg bg-violet-600 py-2 text-xs font-bold text-white transition hover:bg-violet-700 active:scale-95 shadow-sm">
          <svg class="size-3.5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5">
            <path d="M13 2L3 14h9l-1 8 10-12h-9l1-8z"/>
          </svg>
          Generate with AI
        </button>
      </div>

      <!-- Version History Panel -->
      <Transition name="slide">
        <div v-if="showHistory && history.length > 0" class="pt-2 border-t border-slate-100">
          <p class="text-[10px] font-bold uppercase tracking-wider text-slate-400 mb-2">Version History</p>
          <div class="space-y-2 max-h-44 overflow-y-auto custom-scrollbar pr-0.5">
            <div v-for="(item, idx) in history" :key="item.id"
              class="group rounded-lg border border-slate-100 bg-slate-50 p-3 hover:border-violet-200 hover:bg-violet-50/40 transition cursor-default">
              <div class="flex items-center justify-between mb-1">
                <div class="flex items-center gap-1.5">
                  <span class="text-[9px] font-bold text-slate-400 uppercase">v{{ history.length - idx }}</span>
                  <span class="text-[10px] text-slate-500">{{ formatDate(item.created_at) }}</span>
                </div>
                <div class="flex gap-1 opacity-0 group-hover:opacity-100 transition">
                  <button type="button" @click="previewVersion(item)"
                    class="text-[10px] font-bold text-slate-500 hover:text-violet-600 px-1.5 py-0.5 rounded hover:bg-violet-100 transition">
                    Preview
                  </button>
                  <button type="button" @click="restoreVersion(item.id)"
                    class="text-[10px] font-bold text-violet-600 hover:text-violet-800 px-1.5 py-0.5 rounded hover:bg-violet-100 transition">
                    Restore
                  </button>
                </div>
              </div>
              <p class="text-xs text-slate-500 line-clamp-2">{{ item.response_content }}</p>
            </div>
          </div>
        </div>
      </Transition>

      <!-- Preview Modal -->
      <Teleport to="body">
        <Transition name="fade">
          <div v-if="previewItem" class="fixed inset-0 z-50 flex items-center justify-center bg-black/40 backdrop-blur-sm p-4"
            @click.self="previewItem = null">
            <div class="bg-white rounded-2xl shadow-2xl w-full max-w-lg p-6 space-y-4">
              <div class="flex items-center justify-between">
                <h4 class="font-bold text-slate-800">Version Preview</h4>
                <button @click="previewItem = null" class="text-slate-400 hover:text-slate-700">
                  <svg class="size-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                    <path d="M18 6 6 18M6 6l12 12"/>
                  </svg>
                </button>
              </div>
              <div class="rounded-lg bg-slate-50 p-4 text-sm text-slate-700 whitespace-pre-wrap max-h-72 overflow-y-auto custom-scrollbar">
                {{ previewItem.response_content }}
              </div>
              <div class="flex gap-2">
                <button @click="restoreVersion(previewItem.id)"
                  class="flex-1 rounded-lg bg-violet-600 py-2 text-sm font-bold text-white hover:bg-violet-700 transition">
                  Restore This Version (Free)
                </button>
                <button @click="previewItem = null"
                  class="rounded-lg border border-slate-200 px-4 py-2 text-sm font-semibold text-slate-600 hover:bg-slate-50 transition">
                  Cancel
                </button>
              </div>
            </div>
          </div>
        </Transition>
      </Teleport>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import axios from 'axios'

const props = defineProps({
  resumeId: { type: [String, Number], required: true },
  feature: { type: String, required: true },
  title: { type: String, default: 'AI Assistant' },
  creditsRequired: { type: Number, default: 1 },
  allowInstructions: { type: Boolean, default: true },
  instructionPlaceholder: { type: String, default: 'Optional: add context or specific requirements…' }
})

const emit = defineEmits(['apply'])

const loading     = ref(false)
const error       = ref('')
const result      = ref('')
const instructions = ref('')
const history     = ref([])
const showHistory = ref(false)
const previewItem = ref(null)

const loadHistory = async () => {
  try {
    const res = await axios.get('/api/v1/ai/history', {
      params: { resume_id: props.resumeId, feature: props.feature }
    })
    if (res.data.success) history.value = res.data.history
  } catch (err) {
    // non-critical, silently ignore
  }
}

const generate = async (forceNew = false) => {
  loading.value = true
  error.value   = ''

  try {
    const res = await axios.post('/api/v1/ai/generate', {
      resume_id:    props.resumeId,
      feature:      props.feature,
      instructions: instructions.value,
      force_new:    forceNew
    })

    if (res.data.success) {
      result.value = res.data.response
      loadHistory()
    }
  } catch (err) {
    const msg = err.response?.data?.error
    if (err.response?.status === 402) {
      error.value = `Not enough credits. ${msg || ''}`
    } else {
      error.value = msg || 'AI generation failed. Please try again.'
    }
  } finally {
    loading.value = false
  }
}

const applyResult = () => {
  emit('apply', result.value)
  // After applying, keep result visible but allow re-generation
}

const restoreVersion = async (versionId) => {
  loading.value = true
  error.value   = ''
  previewItem.value = null
  try {
    const res = await axios.post(`/api/v1/ai/versions/${versionId}/restore`)
    if (res.data.success) {
      result.value = res.data.response
      emit('apply', res.data.response)
      showHistory.value = false
    }
  } catch (err) {
    error.value = 'Failed to restore version. Please try again.'
  } finally {
    loading.value = false
  }
}

const previewVersion = (item) => {
  previewItem.value = item
}

const formatDate = (dateStr) => {
  return new Intl.DateTimeFormat('en-US', {
    month: 'short', day: 'numeric',
    hour: 'numeric', minute: '2-digit'
  }).format(new Date(dateStr))
}

onMounted(() => {
  loadHistory()
})
</script>

<style scoped>
.custom-scrollbar::-webkit-scrollbar { width: 4px; }
.custom-scrollbar::-webkit-scrollbar-track { background: transparent; }
.custom-scrollbar::-webkit-scrollbar-thumb { background: #cbd5e1; border-radius: 4px; }
.slide-enter-active, .slide-leave-active { transition: all 0.2s ease; }
.slide-enter-from, .slide-leave-to { opacity: 0; transform: translateY(-6px); }
.fade-enter-active, .fade-leave-active { transition: opacity 0.2s ease; }
.fade-enter-from, .fade-leave-to { opacity: 0; }
</style>
