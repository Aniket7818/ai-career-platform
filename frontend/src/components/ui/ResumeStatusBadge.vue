<template>
 <span :class="['inline-flex items-center gap-1.5 rounded-full px-2.5 py-1 text-xs font-semibold capitalize', classes]">
 <span :class="['size-1.5 rounded-full', dotClass]" />
 {{ status }}
 </span>
</template>

<script setup>
import { computed } from 'vue'
import { RESUME_STATUS } from '../../constants/resume'

const props = defineProps({ status: { type: String, required: true } })

const classes = computed(() => ({
 [RESUME_STATUS.DRAFT]: 'bg-amber-500/15 text-amber-700',
 [RESUME_STATUS.PUBLISHED]: 'bg-emerald-500/15 text-emerald-700',
 [RESUME_STATUS.ARCHIVED]: 'bg-background0/15 text-txt-secondary'
}[props.status] || 'bg-brand/15 text-brand'))

const dotClass = computed(() => ({
 [RESUME_STATUS.DRAFT]: 'bg-amber-400',
 [RESUME_STATUS.PUBLISHED]: 'bg-emerald-400',
 [RESUME_STATUS.ARCHIVED]: 'bg-slate-400'
}[props.status] || 'bg-brand'))
</script>
