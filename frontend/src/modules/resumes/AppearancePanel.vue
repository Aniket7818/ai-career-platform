<template>
 <div class="space-y-6">
 <!-- Font Family -->
 <div>
 <label class="mb-2 block text-xs font-semibold uppercase tracking-wider text-txt-muted">
 {{ t('builder.fontFamily') }}
 </label>
 <div class="flex flex-wrap gap-2">
 <button
 v-for="font in FONT_FAMILIES"
 :key="font.value"
 type="button"
 class="rounded-lg border px-3 py-1.5 text-sm transition"
 :style="{ fontFamily: font.value }"
 :class="modelValue.fontFamily === font.value
 ? 'border-brand bg-brand text-white shadow-sm'
 : 'border-border bg-surface text-txt-secondary hover:border-brand/40'"
 @click="update('fontFamily', font.value)"
 >
 {{ font.label }}
 </button>
 </div>
 </div>

 <!-- Font Size -->
 <div>
 <label class="mb-2 block text-xs font-semibold uppercase tracking-wider text-txt-muted">
 {{ t('builder.fontSize') }}
 </label>
 <div class="flex gap-2">
 <button
 v-for="size in FONT_SIZES"
 :key="size.value"
 type="button"
 class="flex-1 rounded-lg border py-2 text-sm font-medium transition"
 :class="modelValue.fontSize === size.value
 ? 'border-brand bg-brand text-white shadow-sm'
 : 'border-border bg-surface text-txt-secondary hover:border-brand/40'"
 @click="update('fontSize', size.value)"
 >
 {{ size.label }}
 </button>
 </div>
 </div>

 <!-- Primary Color -->
 <div>
 <label class="mb-2 block text-xs font-semibold uppercase tracking-wider text-txt-muted">
 {{ t('builder.primaryColor') }}
 </label>
 <div class="flex flex-wrap gap-2">
 <button
 v-for="color in PRIMARY_COLORS"
 :key="color.value"
 type="button"
 class="group relative flex items-center gap-2 rounded-lg border px-3 py-1.5 text-xs font-semibold transition"
 :class="modelValue.primaryColor === color.value
 ? 'border-border-hover shadow-sm ring-2 ring-offset-1'
 : 'border-border bg-surface text-txt-secondary hover:border-border-hover'"
 :style="modelValue.primaryColor === color.value ? { '--tw-ring-color': color.hex } : {}"
 @click="update('primaryColor', color.value)"
 >
 <span class="size-3.5 rounded-full shrink-0" :style="{ backgroundColor: color.hex }" />
 {{ color.label }}
 </button>
 </div>
 </div>
 </div>
</template>

<script setup>
import { t } from '../../utils/i18n'
import { FONT_FAMILIES, FONT_SIZES, PRIMARY_COLORS } from '../../constants/resume'

const props = defineProps({
 modelValue: { type: Object, default: () => ({}) }
})
const emit = defineEmits(['update:modelValue'])

const update = (key, val) => emit('update:modelValue', { ...props.modelValue, [key]: val })
</script>
