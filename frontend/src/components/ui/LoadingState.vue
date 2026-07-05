<template>
 <div class="flex items-center gap-3 rounded-2xl border border-border bg-surface p-5 text-sm text-txt-muted">
 <span class="size-4 animate-spin rounded-full border-2 border-brand border-t-transparent" />
 {{ t('common.loading') }}
 </div>
</template>

<script setup>
import { t } from '../../utils/i18n'
</script>
