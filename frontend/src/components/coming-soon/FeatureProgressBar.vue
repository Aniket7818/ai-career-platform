<template>
 <div>
 <div class="mb-1.5 flex items-center justify-between text-xs">
 <span class="font-medium text-txt-disabled">{{ t('comingSoon.progress') }}</span>
 <span class="font-semibold text-white">{{ progress }}%</span>
 </div>
 <div class="h-2 overflow-hidden rounded-full bg-surface/10">
 <div
 class="h-full rounded-full transition-all duration-1000 ease-out"
 :class="barColor"
 :style="{ width: `${progress}%` }"
 />
 </div>
 </div>
</template>

<script setup>
import { computed } from 'vue'
import { STATUS_COLORS } from '../../constants/features'
import { t } from '../../utils/i18n'

const props = defineProps({
 progress: { type: Number, default: 0 },
 status: { type: String, default: 'planned' }
})

const barColor = computed(() => STATUS_COLORS[props.status]?.bar || 'bg-brand')
</script>
