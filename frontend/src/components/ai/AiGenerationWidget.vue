<template>
 <div class="ai-widget rounded-xl border border-border bg-surface shadow-sm relative overflow-hidden flex flex-col">
 <!-- Header -->
 <div class="flex items-center justify-between px-4 pt-4 pb-3 border-b border-border bg-surface z-10 sticky top-0">
 <div class="flex items-center gap-2">
 <div class="flex h-7 w-7 items-center justify-center rounded-lg bg-violet-100">
 <svg class="size-4 text-violet-600" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
 <path d="M13 2L3 14h9l-1 8 10-12h-9l1-8z"/>
 </svg>
 </div>
 <h3 class="text-sm font-bold text-txt-primary">{{ title }} <span class="text-xs font-normal text-txt-disabled ml-1">Workspace</span></h3>
 </div>
 <div class="flex items-center gap-2">
 <span class="rounded-full bg-violet-50 border border-violet-200 text-violet-700 px-2.5 py-0.5 text-[10px] font-bold tracking-wide shadow-sm">
 ⚡ {{ creditsRequired }} credit{{ creditsRequired === 1 ? '' : 's' }}
 </span>
 <button v-if="history.length > 0" type="button" @click="showHistory = !showHistory"
 class="rounded-lg px-2.5 py-1 text-[10px] font-bold text-txt-muted hover:bg-surface-hover transition shadow-sm border border-transparent hover:border-border">
 {{ showHistory ? 'Hide History' : 'History' }} <span class="bg-surface-hover text-txt-secondary rounded-full px-1.5 ml-1">{{ history.length }}</span>
 </button>
 </div>
 </div>

 <div class="p-4 space-y-4 flex-1 overflow-y-auto">
 <!-- Error message -->
 <Transition name="fade">
 <div v-if="error" class="rounded-lg border p-3 text-xs flex items-start gap-2 shadow-sm"
 :class="errorClass">
 <svg class="size-4 shrink-0 mt-0.5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
 <circle cx="12" cy="12" r="10"/><path d="M12 8v4m0 4h.01"/>
 </svg>
 <span class="leading-relaxed">{{ error }}</span>
 </div>
 </Transition>

 <!-- Loading skeleton -->
 <div v-if="loading" class="space-y-3 py-2 bg-background p-4 rounded-lg border border-border">
 <div class="h-2.5 w-full animate-pulse rounded-full bg-surface-hover"></div>
 <div class="h-2.5 w-5/6 animate-pulse rounded-full bg-surface-hover"></div>
 <div class="h-2.5 w-4/6 animate-pulse rounded-full bg-surface-hover"></div>
 <p class="text-[11px] text-violet-600 font-medium text-center pt-2 flex items-center justify-center gap-2">
 <svg class="size-3.5 animate-spin" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5">
 <path d="M21 12a9 9 0 11-18 0 9 9 0 0118 0z" stroke-opacity="0.25"/>
 <path d="M12 3a9 9 0 019 9"/>
 </svg>
 Generating AI response...
 </p>
 </div>

 <!-- Result Workspace -->
 <div v-else-if="result" class="space-y-3">
 <!-- Output Area -->
 <div class="rounded-lg bg-surface border border-violet-100 shadow-sm overflow-hidden">
 <div class="bg-violet-50/50 px-3 py-2 border-b border-violet-100 flex justify-between items-center">
 <span class="text-[10px] font-bold text-violet-700 uppercase tracking-wider">AI Output</span>
 <button @click="copyResult" class="text-violet-600 hover:text-violet-800 transition p-1 rounded hover:bg-violet-100" title="Copy to clipboard">
 <svg class="size-3.5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="9" y="9" width="13" height="13" rx="2" ry="2"></rect><path d="M5 15H4a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2h9a2 2 0 0 1 2 2v1"></path></svg>
 </button>
 </div>
 <div class="p-3 text-sm text-txt-secondary leading-relaxed whitespace-pre-wrap max-h-64 overflow-y-auto custom-scrollbar">
 {{ result }}
 </div>
 </div>


 <!-- Action Buttons -->
 <div class="flex flex-wrap gap-2 pt-1">
 <button type="button" @click="applyResult"
 class="flex-1 flex items-center justify-center gap-1.5 rounded-lg bg-violet-600 px-4 py-2 text-xs font-bold text-white transition hover:bg-violet-700 shadow-sm active:scale-95">
 <svg class="size-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M20 6L9 17l-5-5"/></svg>
 Apply to Resume
 </button>
 </div>
 </div>

 <!-- Iteration/Instruction Area -->
 <div class="space-y-3 bg-background p-3 rounded-lg border border-border mt-4 relative">
 <div class="flex justify-between items-center mb-1">
 <label class="text-[10px] font-bold text-txt-muted uppercase tracking-wider">
 {{ result ? 'Improve Output' : 'Custom Instructions' }}
 </label>
 <button v-if="instructions" @click="instructions = ''" class="text-[9px] text-txt-disabled hover:text-txt-secondary font-medium">Clear</button>
 </div>
 
 <textarea
 v-if="allowInstructions"
 v-model="instructions"
 :placeholder="result ? 'Tell AI how to improve this result... (e.g., Make it shorter)' : instructionPlaceholder"
 :disabled="loading"
 class="w-full rounded border border-border bg-surface p-2.5 text-xs text-txt-secondary placeholder:text-txt-disabled focus:border-violet-400 focus:ring-1 focus:ring-violet-200 outline-none transition resize-none disabled:opacity-50"
 rows="2"
 maxlength="800"
 ></textarea>

 <!-- Quick Prompts -->
 <div class="flex flex-wrap gap-1.5" v-if="allowInstructions && !loading">
 <button v-for="prompt in quickPrompts" :key="prompt" @click="instructions = prompt"
 class="rounded-full bg-surface border border-border text-txt-muted px-2 py-0.5 text-[9px] hover:border-violet-300 hover:text-violet-600 hover:bg-violet-50 transition">
 {{ prompt }}
 </button>
 </div>

 <!-- Generate Buttons -->
 <div class="flex flex-col sm:flex-row gap-2 pt-1">
 <button
 v-if="!result"
 type="button"
 @click="generate(false)"
 :disabled="loading || !canGenerate"
 class="flex flex-1 items-center justify-center gap-1.5 rounded-lg py-2 text-xs font-bold text-white transition active:scale-95 shadow-sm"
 :class="loading ? 'bg-violet-400 cursor-not-allowed' : !canGenerate ? 'bg-slate-300 cursor-not-allowed' : 'bg-violet-600 hover:bg-violet-700'"
 >
 <svg v-if="loading" class="size-3.5 animate-spin" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M21 12a9 9 0 11-18 0 9 9 0 0118 0z" stroke-opacity="0.3"/><path d="M12 3a9 9 0 019 9"/></svg>
 <svg v-else class="size-3.5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M13 2L3 14h9l-1 8 10-12h-9l1-8z"/></svg>
 Generate (⚡ {{ creditsRequired }})
 </button>

 <template v-else>
 <button
 type="button"
 @click="generate(true)"
 :disabled="loading || !canGenerate"
 class="flex flex-1 items-center justify-center gap-1.5 rounded-lg py-2 text-xs font-bold text-white transition active:scale-95 shadow-sm"
 :class="loading ? 'bg-violet-400 cursor-not-allowed' : !canGenerate ? 'bg-slate-300 cursor-not-allowed' : 'bg-violet-600 hover:bg-violet-700'"
 title="Sends the current output back to the AI with your new instructions"
 >
 <svg v-if="loading" class="size-3.5 animate-spin" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M21 12a9 9 0 11-18 0 9 9 0 0118 0z" stroke-opacity="0.3"/><path d="M12 3a9 9 0 019 9"/></svg>
 <svg v-else class="size-3.5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M12 2v4M12 18v4M4.93 4.93l2.83 2.83M16.24 16.24l2.83 2.83M2 12h4M18 12h4M4.93 19.07l2.83-2.83M16.24 7.76l2.83-2.83"/></svg>
 Improve Output (⚡ {{ creditsRequired }})
 </button>
 <button
 type="button"
 @click="reset"
 :disabled="loading"
 class="rounded-lg border border-border bg-surface px-3 py-2 text-xs font-bold text-txt-secondary transition hover:bg-background disabled:opacity-40"
 title="Start over"
 >
 Reset
 </button>
 </template>
 </div>
 
 <!-- Credit warning -->
 <p v-if="!canGenerate && !loading" class="text-[10px] text-amber-600 text-center font-medium mt-1">
 Not enough credits to generate. Upgrade your plan to continue.
 </p>
 </div>

 <!-- Version History Panel -->
 <Transition name="slide">
 <div v-if="showHistory && history.length > 0" class="pt-4 border-t border-border mt-4">
 <p class="text-[10px] font-bold uppercase tracking-wider text-txt-disabled mb-2 flex items-center justify-between">
 <span>Version History</span>
 <span class="text-[9px] bg-surface-hover text-txt-muted px-1.5 py-0.5 rounded">{{ history.length }} versions</span>
 </p>
 <div class="space-y-3 max-h-64 overflow-y-auto custom-scrollbar pr-1">
 <div v-for="(item, idx) in history" :key="item.id"
 class="group rounded-xl border border-border bg-surface shadow-sm overflow-hidden hover:border-violet-300 transition">
 <div class="bg-background p-2.5 border-b border-border flex items-center justify-between">
 <div class="flex items-center gap-2">
 <span class="bg-surface-hover text-txt-secondary text-[9px] font-bold px-1.5 py-0.5 rounded uppercase">v{{ history.length - idx }}</span>
 <span class="text-[9px] text-txt-muted">{{ formatDate(item.created_at) }}</span>
 </div>
 <div class="flex gap-1">
 <button type="button" @click="previewVersion(item)" class="text-[9px] font-bold text-txt-secondary hover:text-violet-600 hover:bg-violet-50 px-1.5 py-0.5 rounded transition">Preview</button>
 <button type="button" @click="restoreVersion(item.id)" class="text-[9px] font-bold text-violet-600 hover:text-violet-800 hover:bg-violet-100 px-1.5 py-0.5 rounded transition shadow-sm">Restore</button>
 </div>
 </div>
 <div class="p-3 bg-surface">
 <p class="text-xs text-txt-secondary line-clamp-2 leading-relaxed">{{ item.response_content }}</p>
 </div>
 </div>
 </div>
 </div>
 </Transition>

 <!-- Preview Modal -->
 <Teleport to="body">
 <Transition name="fade">
 <div v-if="previewItem" class="fixed inset-0 z-50 flex items-center justify-center bg-surface/40 backdrop-blur-sm p-4"
 @click.self="previewItem = null">
 <div class="bg-surface rounded-2xl shadow-2xl w-full max-w-2xl overflow-hidden flex flex-col max-h-[90vh]">
 <div class="flex items-center justify-between p-4 border-b border-border bg-background">
 <div class="flex items-center gap-2">
 <h4 class="font-bold text-txt-primary">Version Preview</h4>
 <span class="text-[10px] text-txt-muted bg-surface-hover px-1.5 py-0.5 rounded">{{ formatDate(previewItem.created_at) }}</span>
 </div>
 <button @click="previewItem = null" class="text-txt-disabled hover:text-txt-secondary p-1 rounded hover:bg-surface-hover transition">
 <svg class="size-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
 <path d="M18 6 6 18M6 6l12 12"/>
 </svg>
 </button>
 </div>
 <div class="p-5 flex-1 overflow-y-auto">
 <div class="bg-surface border border-border rounded-lg p-4 text-sm text-txt-secondary whitespace-pre-wrap leading-relaxed shadow-inner">
 {{ previewItem.response_content }}
 </div>
 <!-- Mini metadata if available -->
 <div v-if="previewItem.provider" class="mt-3 flex flex-wrap gap-2 text-[10px] text-txt-muted bg-background p-2 rounded">
 <span><strong>Provider:</strong> {{ previewItem.provider }}</span>
 <span><strong>Model:</strong> {{ previewItem.model }}</span>
 </div>
 </div>
 <div class="p-4 border-t border-border bg-background flex flex-col sm:flex-row gap-2 justify-end">
 <button @click="previewItem = null"
 class="rounded-lg border border-border bg-surface px-4 py-2 text-sm font-semibold text-txt-secondary hover:bg-background transition shadow-sm">
 Close
 </button>
 <button @click="restoreVersion(previewItem.id)"
 class="rounded-lg bg-violet-600 px-5 py-2 text-sm font-bold text-white hover:bg-violet-700 transition shadow-sm active:scale-95 flex items-center gap-2">
 <svg class="size-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M3 12a9 9 0 1 0 9-9 9.75 9.75 0 0 0-6.74 2.74L3 8"/><path d="M3 3v5h5"/></svg>
 Restore This Version (Free)
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
import { ref, computed, onMounted, onBeforeUnmount } from 'vue'
import axios from 'axios'
import { useStore } from 'vuex'

const props = defineProps({
 resumeId: { type: [String, Number], required: true },
 feature: { type: String, required: true },
 title: { type: String, default: 'AI Assistant' },
 creditsRequired: { type: Number, default: 1 },
 allowInstructions: { type: Boolean, default: true },
 instructionPlaceholder: { type: String, default: 'Optional: add context or specific requirements…' }
})

const emit = defineEmits(['apply'])
const store = useStore()

const loading = ref(false)
const error = ref('')
const errorType = ref('error') // 'error' | 'warning' | 'conflict'
const result = ref('')
const metadata = ref(null)
const instructions = ref('')
const history = ref([])
const showHistory = ref(false)
const previewItem = ref(null)

const quickPrompts = [
 'Professional', 'ATS friendly', 'Shorter', 'Longer', 
 'Technical', 'Leadership', 'Achievements', 'Entry Level', 
 'Senior Level', 'Action verbs'
]

const countdownTimer = ref(null)
const remainingSeconds = ref(0)

// Timeout constants (ms) — must align with backend GENERATION_TIMEOUT
const FRONTEND_TIMEOUT_MS = 30_000 // 30s — trigger abort & show error
const FAILSAFE_TIMEOUT_MS = 35_000 // 35s — force loading=false no matter what

let abortController = null
let requestTimer = null // AbortController-linked timeout
let failsafeTimer = null // last-resort loading killer

// Clear both timers cleanly
const clearTimers = () => {
 if (requestTimer) { clearTimeout(requestTimer); requestTimer = null }
 if (failsafeTimer) { clearTimeout(failsafeTimer); failsafeTimer = null }
}

// ── Computed ──────────────────────────────────────────────────────────────
const user = computed(() => store.state.auth.user)

const canGenerate = computed(() => {
 if (!user.value) return false
 return (user.value.ai_credits_remaining ?? 0) >= props.creditsRequired
})

const errorClass = computed(() => {
 switch (errorType.value) {
 case 'conflict':
 return 'bg-amber-50 border-amber-200 text-amber-700'
 case 'warning':
 return 'bg-yellow-50 border-yellow-200 text-yellow-700'
 default:
 return 'bg-red-50 border-red-200 text-red-700'
 }
})

// ── Methods ───────────────────────────────────────────────────────────────
const startCountdown = (seconds) => {
 remainingSeconds.value = seconds
 error.value = `Too many requests. Please wait ${remainingSeconds.value} seconds and try again.`
 
 if (countdownTimer.value) clearInterval(countdownTimer.value)
 
 countdownTimer.value = setInterval(() => {
 remainingSeconds.value--
 if (remainingSeconds.value <= 0) {
 if (countdownTimer.value) clearInterval(countdownTimer.value)
 countdownTimer.value = null
 error.value = ''
 } else {
 error.value = `Too many requests. Please wait ${remainingSeconds.value} seconds and try again.`
 }
 }, 1000)
}

const loadHistory = async () => {
 try {
 const res = await axios.get('/api/v1/ai/history', {
 params: { resume_id: props.resumeId, feature: props.feature }
 })
 if (res.data.success) {
 history.value = res.data.history
 // If we don't have a result yet, load the latest history item
 if (!result.value && history.value.length > 0) {
 result.value = history.value[0].response_content
 metadata.value = history.value[0]
 }
 }
 } catch { /* non-critical */ }
}

const generate = async (forceNew = false) => {
 // Guard: never allow overlapping requests from same widget
 if (loading.value) return

 loading.value = true
 error.value = ''
 errorType.value = 'error'

 if (countdownTimer.value) {
 clearInterval(countdownTimer.value)
 countdownTimer.value = null
 }
 clearTimers()

 // Cancel any stale in-flight request from a previous attempt
 abortController?.abort()
 abortController = new AbortController()

 // ── Timeout via AbortController (works in all axios versions) ─────────
 // We drive the abort ourselves with setTimeout so we're never dependent
 // on axios's own 'timeout' option (which silently breaks when 'signal' is also set).
 requestTimer = setTimeout(() => {
 abortController?.abort('timeout')
 loading.value = false
 errorType.value = 'error'
 error.value = '⏱ AI generation timed out after 30 seconds. Please try again.'
 clearTimers()
 }, FRONTEND_TIMEOUT_MS)

 // Last-resort failsafe: force loading=false even if the catch/finally block fails
 failsafeTimer = setTimeout(() => {
 if (loading.value) {
 loading.value = false
 if (!error.value) error.value = 'Request timed out. Please try again.'
 }
 clearTimers()
 }, FAILSAFE_TIMEOUT_MS)

 const payload = {
 resume_id: props.resumeId,
 feature: props.feature,
 instructions: instructions.value,
 force_new: forceNew,
 previous_output: forceNew ? result.value : null
 }

 try {
 const res = await axios.post('/api/v1/ai/generate', payload, {
 signal: abortController.signal
 // No 'timeout' here — we manage it via AbortController above
 })

 if (res.data.success) {
 result.value = res.data.response
 metadata.value = res.data.metadata || null
 instructions.value = ''

 if (res.data.remaining_credits !== undefined) {
 store.commit('auth/SET_USER_CREDITS', res.data.remaining_credits)
 }
 loadHistory()
 }
 } catch (err) {
 // Aborted by our own timeout timer — error already set above
 if (err?.name === 'AbortError' || err?.name === 'CanceledError') return
 if (axios.isCancel(err)) return

 const status = err.response?.status
 const data = err.response?.data || {}

 if (status === 409) {
 errorType.value = 'conflict'
 error.value = '⏳ Generation already in progress. Please wait a moment.'
 } else if (status === 413) {
 errorType.value = 'warning'
 error.value = data.error || 'Your instructions or resume content is too large. Please shorten and try again.'
 } else if (status === 429) {
 errorType.value = 'warning'
 const retryAfter = parseInt(err.response?.headers?.['retry-after'], 10) || parseInt(data.retry_after, 10) || 10
 startCountdown(retryAfter)
 } else if (status === 403) {
 error.value = data.error || 'Not enough AI credits. Please upgrade your plan.'
 } else if (status === 504 || status === 502) {
 errorType.value = 'error'
 error.value = '⏱ AI provider timed out. Please try again.'
 } else {
 error.value = data.error || 'AI generation failed. Please try again.'
 }
 } finally {
 // Always stop loading and release resources
 loading.value = false
 abortController = null
 clearTimers()
 }
}

const applyResult = () => {
 emit('apply', result.value)
}

const copyResult = () => {
 if (result.value) {
 navigator.clipboard.writeText(result.value)
 }
}

const reset = () => {
 result.value = ''
 metadata.value = null
 instructions.value = ''
 error.value = ''
}

const restoreVersion = async (versionId) => {
 if (loading.value) return
 loading.value = true
 error.value = ''
 previewItem.value = null
 try {
 const res = await axios.post(`/api/v1/ai/versions/${versionId}/restore`)
 if (res.data.success) {
 result.value = res.data.response
 // find metadata
 const item = history.value.find(h => h.id === versionId)
 if (item) metadata.value = item
 emit('apply', res.data.response)
 showHistory.value = false
 }
 } catch {
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

onMounted(() => { loadHistory() })

onBeforeUnmount(() => {
 abortController?.abort()
 clearTimers()
 if (countdownTimer.value) clearInterval(countdownTimer.value)
})
</script>

<style scoped>
.custom-scrollbar::-webkit-scrollbar { width: 6px; }
.custom-scrollbar::-webkit-scrollbar-track { background: transparent; }
.custom-scrollbar::-webkit-scrollbar-thumb { background: #cbd5e1; border-radius: 6px; }
.custom-scrollbar::-webkit-scrollbar-thumb:hover { background: #94a3b8; }
.slide-enter-active, .slide-leave-active { transition: all 0.2s ease; }
.slide-enter-from, .slide-leave-to { opacity: 0; transform: translateY(-6px); }
.fade-enter-active, .fade-leave-active { transition: opacity 0.2s ease; }
.fade-enter-from, .fade-leave-to { opacity: 0; }
</style>
