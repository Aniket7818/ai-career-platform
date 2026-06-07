<template>
  <button :class="classes" :disabled="disabled || loading">
    <span v-if="loading">{{ t('common.loading') }}</span>
    <slot v-else />
  </button>
</template>

<script setup>
import { computed } from 'vue'
import { t } from '../../utils/i18n'

const props = defineProps({ variant: { type: String, default: 'primary' }, loading: Boolean, disabled: Boolean })
const classes = computed(() => [
  'inline-flex min-h-10 items-center justify-center rounded-md px-4 text-sm font-semibold transition disabled:cursor-not-allowed disabled:opacity-60',
  props.variant === 'secondary' ? 'border border-slate-200 bg-white text-slate-700 hover:bg-slate-50' : 'bg-brand text-white hover:bg-indigo-700'
])
</script>
