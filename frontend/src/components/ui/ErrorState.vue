<template>
 <div class="rounded-2xl border border-red-200 bg-red-50 p-4 text-sm text-red-700">
 {{ message || t('common.error') }}
 </div>
</template>

<script setup>
import { t } from '../../utils/i18n'
defineProps({ message: String })
</script>
