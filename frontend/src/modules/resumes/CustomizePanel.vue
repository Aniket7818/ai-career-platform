<template>
  <div class="space-y-5">
    <!-- Section Visibility -->
    <div>
      <p class="mb-3 text-xs font-semibold uppercase tracking-wider text-slate-500">{{ t('builder.sectionVisibility') }}</p>
      <div class="space-y-2">
        <div
          v-for="section in orderedSections"
          :key="section"
          class="flex items-center justify-between rounded-lg border border-slate-100 bg-slate-50/50 px-3 py-2"
        >
          <span class="text-sm font-medium text-ink capitalize">{{ SECTION_LABELS[section] || section }}</span>
          <button
            type="button"
            class="relative h-5 w-9 rounded-full transition-colors duration-200"
            :class="visibility[section] ? 'bg-brand' : 'bg-slate-200'"
            @click="toggleVisibility(section)"
          >
            <span
              class="absolute top-0.5 left-0.5 size-4 rounded-full bg-white shadow transition-transform duration-200"
              :class="visibility[section] ? 'translate-x-4' : 'translate-x-0'"
            />
          </button>
        </div>
      </div>
    </div>

    <!-- Section Order (Drag & Drop) -->
    <div>
      <p class="mb-3 text-xs font-semibold uppercase tracking-wider text-slate-500">{{ t('builder.sectionOrder') }}</p>
      <div class="space-y-1.5" @dragover.prevent @drop="onDrop">
        <div
          v-for="(section, idx) in order"
          :key="section"
          draggable="true"
          @dragstart="onDragStart(idx, $event)"
          @dragenter="onDragEnter(idx)"
          @dragend="onDragEnd"
          class="group flex items-center gap-3 rounded-lg border border-slate-100 bg-slate-50/50 px-3 py-2 cursor-grab active:cursor-grabbing transition-colors"
          :class="{ 'opacity-40': dragIndex === idx, 'border-brand bg-brand/5': dropIndex === idx && dragIndex !== idx }"
        >
          <svg class="size-4 text-slate-400 group-hover:text-brand transition-colors" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <path d="M8 6h13M8 12h13M8 18h13M3 6h.01M3 12h.01M3 18h.01" />
          </svg>
          <span class="flex-1 text-sm font-medium text-ink capitalize">{{ SECTION_LABELS[section] || section }}</span>
          
          <div class="flex gap-1 sm:hidden">
            <button
              type="button"
              :disabled="idx === 0"
              class="rounded px-1.5 py-0.5 text-xs font-semibold text-slate-500 transition hover:bg-slate-200 disabled:opacity-30"
              @click="moveUp(idx)"
            >
              ▲
            </button>
            <button
              type="button"
              :disabled="idx === order.length - 1"
              class="rounded px-1.5 py-0.5 text-xs font-semibold text-slate-500 transition hover:bg-slate-200 disabled:opacity-30"
              @click="moveDown(idx)"
            >
              ▼
            </button>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { computed } from 'vue'
import { t } from '../../utils/i18n'
import { SECTION_LABELS } from '../../constants/resume'

const props = defineProps({
  order:      { type: Array,  required: true },
  visibility: { type: Object, required: true }
})
const emit = defineEmits(['update:order', 'update:visibility'])

const orderedSections = computed(() => props.order)

const toggleVisibility = (section) => {
  emit('update:visibility', { ...props.visibility, [section]: !props.visibility[section] })
}

const moveUp = (idx) => {
  if (idx === 0) return
  const arr = [...props.order]
  ;[arr[idx - 1], arr[idx]] = [arr[idx], arr[idx - 1]]
  emit('update:order', arr)
}

const moveDown = (idx) => {
  if (idx === props.order.length - 1) return
  const arr = [...props.order]
  ;[arr[idx], arr[idx + 1]] = [arr[idx + 1], arr[idx]]
  emit('update:order', arr)
}

// Drag and drop implementation
import { ref } from 'vue'
const dragIndex = ref(null)
const dropIndex = ref(null)

const onDragStart = (idx, e) => {
  dragIndex.value = idx
  e.dataTransfer.effectAllowed = 'move'
  e.dataTransfer.setData('text/plain', idx)
}

const onDragEnter = (idx) => {
  if (dragIndex.value !== null) {
    dropIndex.value = idx
  }
}

const onDragEnd = () => {
  dragIndex.value = null
  dropIndex.value = null
}

const onDrop = () => {
  if (dragIndex.value !== null && dropIndex.value !== null && dragIndex.value !== dropIndex.value) {
    const arr = [...props.order]
    const item = arr.splice(dragIndex.value, 1)[0]
    arr.splice(dropIndex.value, 0, item)
    emit('update:order', arr)
  }
  onDragEnd()
}
</script>
