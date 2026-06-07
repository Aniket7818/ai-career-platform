<template>
  <div class="flex h-48 items-end gap-2">
    <div v-for="(item, index) in items" :key="item.key" class="group flex flex-1 flex-col items-center gap-2">
      <span class="text-xs font-semibold text-slate-300 opacity-0 transition group-hover:opacity-100">{{ item.count }}</span>
      <div class="relative w-full overflow-hidden rounded-t-md bg-white/5" :style="{ height: `${barHeight(item.count)}%` }">
        <div
          class="absolute inset-0 rounded-t-md bg-gradient-to-t from-brand/80 to-brand transition-all duration-700"
          :style="{ animationDelay: `${index * 80}ms` }"
        />
      </div>
      <span class="max-w-full truncate text-[10px] font-medium text-slate-500" :title="item.label">{{ item.shortLabel }}</span>
    </div>
  </div>
</template>

<script setup>
import { computed } from 'vue'

const props = defineProps({
  items: { type: Array, default: () => [] }
})

const maxCount = computed(() => Math.max(...props.items.map((i) => i.count), 1))

const barHeight = (count) => Math.max((count / maxCount.value) * 100, 8)
</script>
