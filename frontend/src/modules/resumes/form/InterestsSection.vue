<template>
 <div class="space-y-4">
 <!-- Tag Input -->
 <div class="flex gap-2">
 <input
 v-model="inputValue"
 :placeholder="t('builder.interestPlaceholder')"
 class="flex-1"
 @keydown.enter.prevent="addTag"
 @keydown.comma.prevent="addTag"
 />
 <button
 type="button"
 class="shrink-0 rounded-xl border border-brand/30 bg-brand/5 px-4 py-2 text-sm font-semibold text-brand transition hover:bg-brand/10"
 @click="addTag"
 >
 Add
 </button>
 </div>
 <!-- Tags Display -->
 <div v-if="tags.length" class="flex flex-wrap gap-2">
 <span
 v-for="tag in tags"
 :key="tag"
 class="group flex items-center gap-1.5 rounded-full border border-brand/20 bg-brand/5 px-3 py-1 text-sm font-medium text-brand"
 >
 {{ tag }}
 <button
 type="button"
 class="rounded-full p-0.5 text-brand/50 transition hover:text-brand"
 @click="removeTag(tag)"
 >
 <svg class="size-3" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M18 6 6 18M6 6l12 12"/></svg>
 </button>
 </span>
 </div>
 <p v-else class="text-xs text-txt-disabled">No interests added yet. Press Enter or comma to add.</p>
 </div>
</template>

<script setup>
import { ref, watch } from 'vue'
import { t } from '../../../utils/i18n'

const props = defineProps({ modelValue: { type: Array, default: () => [] } })
const emit = defineEmits(['update:modelValue'])

const tags = ref([...props.modelValue])
const inputValue = ref('')

watch(() => props.modelValue, (val) => { tags.value = [...val] }, { deep: true })

const addTag = () => {
 const tag = inputValue.value.replace(/,/g, '').trim()
 if (tag && !tags.value.includes(tag)) {
 tags.value = [...tags.value, tag]
 emit('update:modelValue', tags.value)
 }
 inputValue.value = ''
}

const removeTag = (tag) => {
 tags.value = tags.value.filter((t) => t !== tag)
 emit('update:modelValue', tags.value)
}
</script>
