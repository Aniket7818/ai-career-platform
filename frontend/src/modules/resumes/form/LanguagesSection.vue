<template>
  <div class="space-y-4">
    <div
      v-for="(lang, idx) in entries"
      :key="lang.id"
      class="flex items-center gap-3 rounded-xl border border-slate-200 bg-white p-4"
    >
      <div class="flex-1">
        <input v-model="lang.language" :placeholder="t('builder.language')" class="w-full" @input="emit('update:modelValue', entries)" />
      </div>
      <div class="w-40">
        <select v-model="lang.proficiency" @change="emit('update:modelValue', entries)">
          <option value="">{{ t('builder.proficiency') }}</option>
          <option v-for="opt in proficiencyOptions" :key="opt" :value="opt">{{ opt }}</option>
        </select>
      </div>
      <button
        type="button"
        class="shrink-0 rounded-lg p-1.5 text-red-400 transition hover:bg-red-50 hover:text-red-600"
        @click="remove(idx)"
      >
        <svg class="size-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M18 6 6 18M6 6l12 12"/></svg>
      </button>
    </div>

    <button
      type="button"
      class="w-full rounded-xl border border-dashed border-brand/40 py-2.5 text-sm font-semibold text-brand transition hover:border-brand hover:bg-brand/5"
      @click="add"
    >
      {{ t('builder.addLanguage') }}
    </button>
  </div>
</template>

<script setup>
import { ref, watch } from 'vue'
import { t } from '../../../utils/i18n'
import { emptyLanguage } from '../../../utils/profileToResume'

const proficiencyOptions = ['Native', 'Fluent', 'Conversational', 'Basic']

const props = defineProps({ modelValue: { type: Array, default: () => [] } })
const emit = defineEmits(['update:modelValue'])

const entries = ref(props.modelValue.length ? props.modelValue.map((l) => ({ ...l })) : [])

watch(() => props.modelValue, (val) => {
  if (JSON.stringify(val) !== JSON.stringify(entries.value)) {
    entries.value = (val || []).length ? (val || []).map((l) => ({ ...l })) : []
  }
}, { deep: true })

const add = () => { entries.value.push(emptyLanguage()); emit('update:modelValue', entries.value) }
const remove = (idx) => { entries.value.splice(idx, 1); emit('update:modelValue', entries.value) }

watch(entries, (val) => emit('update:modelValue', val), { deep: true })
</script>
