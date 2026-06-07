<template>
  <div class="flex items-center gap-3 rounded-2xl border border-slate-200 bg-white p-5 text-sm text-slate-500">
    <span class="size-4 animate-spin rounded-full border-2 border-brand border-t-transparent" />
    {{ t('common.loading') }}
  </div>
</template>

<script setup>
import { t } from '../../utils/i18n'
</script>
