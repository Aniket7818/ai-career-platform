<template>
  <button :class="classes" :disabled="disabled || loading">
    <span v-if="loading" class="flex items-center gap-2">
      <svg class="size-4 animate-spin text-current" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3"><circle cx="12" cy="12" r="10" stroke-opacity="0.25"></circle><path d="M12 2v4M12 18v4"></path></svg>
      {{ t('common.loading') }}
    </span>
    <slot v-else />
  </button>
</template>

<script setup>
import { computed } from 'vue'
import { t } from '../../utils/i18n'

const props = defineProps({ variant: { type: String, default: 'primary' }, loading: Boolean, disabled: Boolean })
const classes = computed(() => [
  'inline-flex min-h-10 items-center justify-center rounded-xl px-5 text-sm font-semibold transition-all duration-200 active:scale-[0.98] hover:-translate-y-[1px] active:translate-y-0 disabled:cursor-not-allowed disabled:opacity-60 disabled:transform-none disabled:active:scale-100 shadow-sm select-none',
  props.variant === 'secondary' 
    ? 'border border-slate-200 bg-white text-slate-700 hover:bg-slate-50/80 hover:border-slate-300 hover:shadow-md' 
    : 'bg-brand text-white hover:bg-brand/90 hover:shadow-glow'
])
</script>

