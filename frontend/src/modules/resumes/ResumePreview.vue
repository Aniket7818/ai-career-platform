<template>
  <article class="flex flex-col min-h-[420px] max-h-[800px] overflow-hidden rounded-2xl border border-slate-100 bg-white shadow-panel sm:min-h-[560px] lg:min-h-[720px]">
    <div class="flex items-center justify-between border-b border-slate-100 bg-gradient-to-r from-brand/5 to-mint/5 px-6 py-3">
      <div class="flex items-center gap-4">
        <p class="text-[10px] font-bold uppercase tracking-widest text-brand">{{ t('resumes.preview') }}</p>
        <span class="rounded bg-white/60 px-2 py-0.5 text-[10px] font-bold text-slate-600 shadow-sm border border-slate-200">
          Page {{ pageCount }}
        </span>
      </div>
      <div class="flex items-center gap-2">
        <span v-if="pageCount > 1" class="text-[10px] font-bold text-amber-600 flex items-center gap-1">
          ⚠ Multi-page
        </span>
        <span v-if="showAts" class="rounded-full bg-emerald-500/15 px-2.5 py-1 text-[10px] font-bold uppercase tracking-wider text-emerald-700">
          ATS {{ atsScore }}
        </span>
      </div>
    </div>

    <!-- Zoom wrapper -->
    <div class="flex-1 overflow-auto bg-slate-200/50 custom-scrollbar p-4 sm:p-8 relative">
      <div class="mx-auto relative shadow-2xl bg-white transition-all duration-300" :style="zoomWrapStyle">
        
        <!-- Render the A4 page break dividers based on calculated actual breaks -->
        <div class="absolute inset-0 pointer-events-none z-10 overflow-hidden">
           <div v-for="(breakY, idx) in calculatedBreaks" :key="idx" 
                class="absolute left-0 right-0 border-b-2 border-dashed border-red-500 flex items-center justify-center opacity-90"
                :style="{ top: `${breakY * scale}px` }">
              <span class="bg-red-500 text-white text-[10px] px-2 py-0.5 rounded-full font-bold -translate-y-1/2 shadow-sm">Continues on Next Page</span>
           </div>
        </div>

        <!-- Debug Panel Overlay -->
        <div v-if="showDebug" class="absolute right-[-280px] top-0 w-[260px] bg-slate-900 text-green-400 p-3 rounded-lg text-xs font-mono shadow-xl z-20 max-h-full overflow-auto">
          <div class="flex justify-between items-center border-b border-slate-700 pb-2 mb-2">
            <strong class="text-white">Shadow Renderer Debug</strong>
            <button @click="showDebug = false" class="text-slate-400 hover:text-white">✕</button>
          </div>
          <div>Pages: {{ pageCount }}</div>
          <div>Total Height: {{ totalHeight }}px</div>
          <div class="mt-2 text-slate-300 border-b border-slate-700 pb-1 mb-1">Breaks:</div>
          <div v-for="(b, i) in calculatedBreaks" :key="'b'+i">Break {{i+1}}: {{ b }}px</div>
          <div class="mt-2 text-slate-300 border-b border-slate-700 pb-1 mb-1">Sections:</div>
          <div v-for="(sec, i) in sectionsData" :key="'s'+i" class="text-[10px] whitespace-nowrap overflow-hidden text-ellipsis">
            <span class="text-blue-300">{{ sec.name }}</span>: {{ sec.top }} - {{ sec.bottom }} ({{ sec.height }}px)
          </div>
          <div class="mt-2 text-slate-300 border-b border-slate-700 pb-1 mb-1">Real Estate:</div>
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
  title:             String,
  content:           { type: Object, required: true },
  templateId:        { type: String,  default: DEFAULT_TEMPLATE_ID },
  showAts:           { type: Boolean, default: true },
  appearance:        { type: Object,  default: () => ({}) },
  sectionOrder:      { type: Array,   default: () => [] },
  sectionVisibility: { type: Object,  default: () => ({}) },
  zoom:              { type: Number,  default: 100 }
})

const activeComponent = computed(() => TEMPLATE_MAP[props.templateId] || ModernTemplate)
const atsScore        = computed(() => calculateAtsScore(props.content))

// Zoom: scale the inner content while keeping wrapper at natural size
const scale        = computed(() => props.zoom / 100)

const contentRef = ref(null)
const pageCount = ref(1)
const A4_HEIGHT_PX = 1122.5 // Exact 297mm at 96 DPI

// Shadow Renderer State
import { calculatePagination } from '../../utils/paginationEngine'
const calculatedBreaks = ref([])
const sectionsData = ref([])
const realEstateData = ref({})
const totalHeight = ref(0)
const showDebug = ref(import.meta.env.DEV) // Hidden in production per requirements

let resizeObserver = null
let debounceTimer = null

const runPaginationEngine = () => {
  if (!contentRef.value) return
  
  // Need to ensure the component adds the required avoid-break classes
  // The 'resume-print-context' class ensures child elements simulate print break behaviors if needed
  
  const result = calculatePagination(contentRef.value, scale.value)
  
  if (pageCount.value !== result.pageCount) pageCount.value = result.pageCount
  calculatedBreaks.value = result.breaks
  sectionsData.value = result.sections
  realEstateData.value = result.realEstate
  totalHeight.value = result.totalHeight
}

// Watch for any data changes that might affect layout and recalculate after DOM updates
watch(
  () => [props.content, props.templateId, props.appearance, props.sectionOrder, props.sectionVisibility, props.zoom],
  () => {
    nextTick(() => {
      if (debounceTimer) clearTimeout(debounceTimer)
      debounceTimer = setTimeout(runPaginationEngine, 50)
    })
  },
  { deep: true }
)

onMounted(() => {
  const observeDOM = () => {
    if (debounceTimer) clearTimeout(debounceTimer)
    debounceTimer = setTimeout(runPaginationEngine, 100) 
  }

  resizeObserver = new ResizeObserver(observeDOM)
  
  if (contentRef.value) {
    resizeObserver.observe(contentRef.value)
    // Run initially
    setTimeout(runPaginationEngine, 200)
  }
})

onBeforeUnmount(() => {
  if (resizeObserver) resizeObserver.disconnect()
})

const zoomWrapStyle = computed(() => {
  // Fix infinite loop: explicitly constrain the wrapper to exact A4 page multiples.
  // Using totalHeight + h-full causes the scrollHeight to grow continuously due to currentShift.
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
