<template>
 <article class="relative flex flex-col min-h-[420px] lg:h-full overflow-hidden rounded-2xl bg-surface sm:min-h-[560px] border border-border">
 <!-- Top Status Bar -->
 <div class="flex items-center justify-between px-5 py-3 border-b border-border bg-surface">
 <div class="flex items-center gap-3">
 <span class="rounded bg-surface-elevated px-2 py-0.5 text-[10px] font-bold text-txt-muted border border-border">
 Page {{ pageCount }}
 </span>
 <span v-if="pageCount > 1" class="text-[10px] font-bold text-amber-500 flex items-center gap-1">
 <svg class="size-3" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2.5"><path stroke-linecap="round" stroke-linejoin="round" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z"/></svg>
 Multi-page
 </span>
 </div>
 <div class="flex items-center gap-2">
 <span v-if="showAts" class="rounded-full bg-brand/10 px-2.5 py-0.5 text-[10px] font-bold uppercase tracking-wider text-brand">
 ATS {{ atsScore }}
 </span>
 </div>
 </div>

 <!-- Skeleton Loading State (Priority 11) -->
 <Transition name="fade">
 <div v-if="isRendering" class="absolute inset-0 z-30 bg-background flex flex-col items-center justify-center p-8 sm:p-12">
 <div class="relative bg-surface shadow-[0_20px_50px_rgba(15,23,42,0.06)] rounded border border-border flex flex-col gap-4 p-8 w-full max-w-[420px] h-[580px] animate-pulse">
 <!-- Premium Loader Message -->
 <div class="absolute inset-0 flex items-center justify-center bg-surface/30 backdrop-blur-[1px] z-10">
 <span class="bg-surface/90 text-white text-[10px] font-bold px-3 py-1.5 rounded-full shadow-lg flex items-center gap-1.5 uppercase tracking-wider">
 <svg class="size-3.5 animate-spin" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3"><circle cx="12" cy="12" r="10" stroke-opacity="0.25"></circle><path d="M12 2v4M12 18v4"></path></svg>
 Rendering Resume...
 </span>
 </div>

 <!-- Dummy lines mimicking A4 structure -->
 <div class="flex items-center justify-between pb-6 border-b border-border">
 <div class="space-y-2 flex-1">
 <div class="h-5 w-1/3 bg-surface-hover rounded"></div>
 <div class="h-3 w-1/2 bg-surface-hover rounded"></div>
 </div>
 <div class="size-10 bg-surface-hover rounded-full"></div>
 </div>
 <div class="space-y-3 flex-1 mt-4">
 <div class="h-3 w-1/4 bg-surface-hover rounded"></div>
 <div class="h-2 w-full bg-surface-hover rounded"></div>
 <div class="h-2 w-full bg-surface-hover rounded"></div>
 <div class="h-2 w-5/6 bg-surface-hover rounded"></div>
 
 <div class="h-3 w-1/4 bg-surface-hover rounded mt-8"></div>
 <div class="h-2 w-full bg-surface-hover rounded"></div>
 <div class="h-2 w-full bg-surface-hover rounded"></div>
 <div class="h-2 w-4/5 bg-surface-hover rounded"></div>
 </div>
 </div>
 </div>
 </Transition>

 <!-- Zoom wrapper (Grey workspace bg, floating A4 style paper) -->
 <div class="flex-1 overflow-auto custom-scrollbar p-6 sm:p-12 flex items-start justify-center bg-surface-hover/40 select-none">
 <div 
 class="relative bg-surface shadow-[0_20px_50px_rgba(15,23,42,0.08),0_4px_12px_rgba(15,23,42,0.04)] border border-border/50 rounded-sm transition-all duration-300 ease-out origin-top hover:-translate-y-0.5 hover:shadow-[0_30px_70px_rgba(15,23,42,0.12),0_8px_24px_rgba(15,23,42,0.06)]"
 :style="zoomWrapStyle"
 >
 <!-- Render the A4 page break dividers based on calculated actual breaks -->
 <div class="absolute inset-0 pointer-events-none z-10 overflow-hidden">
 <div v-for="(breakY, idx) in calculatedBreaks" :key="idx" 
 class="absolute left-0 right-0 border-b border-dashed border-rose-400 flex items-center justify-center opacity-85"
 :style="{ top: `${breakY * scale}px` }">
 <span class="bg-rose-500 text-white text-[9px] px-2 py-0.5 rounded-full font-bold -translate-y-1/2 shadow-sm uppercase tracking-wider">Page break</span>
 </div>
 </div>

 <!-- Debug Panel Overlay -->
 <div v-if="showDebug" class="absolute right-[-280px] top-0 w-[260px] bg-surface text-green-400 p-3 rounded-lg text-xs font-mono shadow-xl z-20 max-h-full overflow-auto">
 <div class="flex justify-between items-center border-b border-border-hover pb-2 mb-2">
 <strong class="text-white">Shadow Renderer Debug</strong>
 <button @click="showDebug = false" class="text-txt-disabled hover:text-white">✕</button>
 </div>
 <div>Pages: {{ pageCount }}</div>
 <div>Total Height: {{ totalHeight }}px</div>
 <div class="mt-2 text-txt-muted border-b border-border-hover pb-1 mb-1">Breaks:</div>
 <div v-for="(b, i) in calculatedBreaks" :key="'b'+i">Break {{i+1}}: {{ b }}px</div>
 <div class="mt-2 text-txt-muted border-b border-border-hover pb-1 mb-1">Sections:</div>
 <div v-for="(sec, i) in sectionsData" :key="'s'+i" class="text-[10px] whitespace-nowrap overflow-hidden text-ellipsis">
 <span class="text-blue-300">{{ sec.name }}</span>: {{ sec.top }} - {{ sec.bottom }} ({{ sec.height }}px)
 </div>
 <div class="mt-2 text-txt-muted border-b border-border-hover pb-1 mb-1">Real Estate:</div>
 <div v-for="(pct, name) in realEstateData" :key="'re'+name" class="flex justify-between text-[10px]">
 <span>{{ name }}</span> <span>{{ pct }}</span>
 </div>
 </div>

 <div :style="[zoomInnerStyle, containerBgStyle]" ref="contentRef">
 <component
 :is="activeComponent"
 :title="title"
 :content="content"
 :appearance="appearance"
 :section-order="sectionOrder"
 :section-visibility="sectionVisibility"
 class="min-h-full resume-print-context"
 />
 </div>
 </div>
 </div>
 </article>
</template>

<script setup>
import { computed, ref, onMounted, onBeforeUnmount, watch, nextTick } from 'vue'
import ModernTemplate from './templates/ModernTemplate.vue'
import ProfessionalTemplate from './templates/ProfessionalTemplate.vue'
import MinimalTemplate from './templates/MinimalTemplate.vue'
import ExecutiveTemplate from './templates/ExecutiveTemplate.vue'
import FresherTemplate from './templates/FresherTemplate.vue'
import { DEFAULT_TEMPLATE_ID } from '../../constants/templates'
import { calculateAtsScore } from '../../utils/profileToResume'
import { t } from '../../utils/i18n'
import { primaryColorHex } from './templates/templateHelpers'

const TEMPLATE_MAP = {
 modern: ModernTemplate,
 professional: ProfessionalTemplate,
 minimal: MinimalTemplate,
 executive: ExecutiveTemplate,
 fresher: FresherTemplate
}

const props = defineProps({
 title: String,
 content: { type: Object, required: true },
 templateId: { type: String, default: DEFAULT_TEMPLATE_ID },
 showAts: { type: Boolean, default: true },
 appearance: { type: Object, default: () => ({}) },
 sectionOrder: { type: Array, default: () => [] },
 sectionVisibility: { type: Object, default: () => ({}) },
 zoom: { type: Number, default: 100 }
})

const emit = defineEmits(['page-update'])

const activeComponent = computed(() => TEMPLATE_MAP[props.templateId] || ModernTemplate)
const atsScore = computed(() => calculateAtsScore(props.content))

// Zoom: scale the inner content while keeping wrapper at natural size
const scale = computed(() => props.zoom / 100)

const contentRef = ref(null)
const pageCount = ref(1)
const A4_HEIGHT_PX = 1122.5 // Exact 297mm at 96 DPI

// Shadow Renderer State
import { calculatePagination } from '../../utils/paginationEngine'
const calculatedBreaks = ref([])
const sectionsData = ref([])
const realEstateData = ref([])
const totalHeight = ref(0)
const showDebug = ref(false) // Hidden in production per requirements
const isRendering = ref(false)

let resizeObserver = null
let debounceTimer = null

const runPaginationEngine = () => {
 if (!contentRef.value) return
 
 const result = calculatePagination(contentRef.value, scale.value)
 
 if (pageCount.value !== result.pageCount) {
 pageCount.value = result.pageCount
 emit('page-update', result.pageCount)
 }
 calculatedBreaks.value = result.breaks
 sectionsData.value = result.sections
 realEstateData.value = result.realEstate
 totalHeight.value = result.totalHeight
}

// Watch for any data changes that might affect layout and recalculate after DOM updates
watch(
 () => [props.content, props.templateId, props.appearance, props.sectionOrder, props.sectionVisibility, props.zoom],
 () => {
 isRendering.value = true
 nextTick(() => {
 if (debounceTimer) clearTimeout(debounceTimer)
 debounceTimer = setTimeout(() => {
 runPaginationEngine()
 setTimeout(() => {
 isRendering.value = false
 }, 250) // premium rendering duration
 }, 50)
 })
 },
 { deep: true }
)

onMounted(() => {
 isRendering.value = true
 const observeDOM = () => {
 if (debounceTimer) clearTimeout(debounceTimer)
 debounceTimer = setTimeout(runPaginationEngine, 100) 
 }

 resizeObserver = new ResizeObserver(observeDOM)
 
 if (contentRef.value) {
 resizeObserver.observe(contentRef.value)
 // Run initially
 setTimeout(() => {
 runPaginationEngine()
 setTimeout(() => {
 isRendering.value = false
 }, 250)
 }, 200)
 }
})

onBeforeUnmount(() => {
 if (resizeObserver) resizeObserver.disconnect()
})

const zoomWrapStyle = computed(() => {
 const actualHeight = A4_HEIGHT_PX * pageCount.value
 return {
 width: `${794 * scale.value}px`, // Standard A4 width at 96 DPI
 height: `${actualHeight * scale.value}px`,
 minHeight: `${A4_HEIGHT_PX * scale.value}px`
 }
})

const zoomInnerStyle = computed(() => ({
 transform: `scale(${scale.value})`,
 transformOrigin: 'top left',
 width: `794px`, // Fixed width for A4 content calculation
 minHeight: `${A4_HEIGHT_PX * pageCount.value}px`
}))

const containerBgStyle = computed(() => {
 const isModern = props.templateId === 'modern' || !props.templateId
 if (isModern) {
 const hex = primaryColorHex(props.appearance)
 return { background: `linear-gradient(to right, ${hex} 34%, white 34%)` }
 }
 return { background: 'white' }
})
</script>

<style scoped>
.fade-enter-active, .fade-leave-active {
 transition: opacity 200ms ease;
}
.fade-enter-from, .fade-leave-to {
 opacity: 0;
}
</style>
