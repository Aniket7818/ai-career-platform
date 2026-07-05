<template>
 <span :class="['inline-flex items-center gap-1.5 rounded-full px-2.5 py-1 text-xs font-semibold', colors.bg, colors.text]">
 <span :class="['size-1.5 rounded-full', colors.dot]" />
 {{ label }}
 </span>
</template>

<script setup>
import { computed } from 'vue'
import { STATUS_COLORS } from '../../constants/features'
import { t } from '../../utils/i18n'

const props = defineProps({ status: { type: String, required: true } })

const colors = computed(() => STATUS_COLORS[props.status] || STATUS_COLORS.planned)
const label = computed(() => t(`comingSoon.status.${props.status}`))
</script>
