<template>
  <div class="space-y-4">
    <div
      v-for="(ach, idx) in entries"
      :key="ach.id"
      class="group relative rounded-xl border border-slate-200 bg-white p-5 transition hover:border-brand/30 hover:shadow-sm"
    >
      <div class="mb-3 flex items-center justify-between gap-3">
        <span class="text-xs font-bold uppercase tracking-wider text-brand">Achievement {{ idx + 1 }}</span>
        <button
          v-if="entries.length > 1"
          type="button"
          class="rounded-lg px-2.5 py-1 text-xs font-semibold text-red-500 transition hover:bg-red-50"
          @click="remove(idx)"
        >
          {{ t('builder.deleteAchievement') }}
        </button>
      </div>
      <div class="grid gap-3">
        <div>
          <label>{{ t('builder.achievementTitle') }}</label>
          <input v-model="ach.title" placeholder="e.g. Solved 500+ DSA problems on LeetCode" @input="emit('update:modelValue', entries)" />
        </div>
        <div>
          <label>{{ t('builder.achievementDesc') }}</label>
          <input v-model="ach.description" placeholder="Optional additional context..." @input="emit('update:modelValue', entries)" />
        </div>
      </div>
    </div>

    <button
      type="button"
      class="w-full rounded-xl border border-dashed border-brand/40 py-2.5 text-sm font-semibold text-brand transition hover:border-brand hover:bg-brand/5"
      @click="add"
    >
      {{ t('builder.addAchievement') }}
    </button>
  </div>
</template>

<script setup>
import { ref, watch } from 'vue'
import { t } from '../../../utils/i18n'
import { emptyAchievement } from '../../../utils/profileToResume'

const props = defineProps({ modelValue: { type: Array, default: () => [] } })
const emit = defineEmits(['update:modelValue'])

const entries = ref(props.modelValue.length ? props.modelValue.map((a) => ({ ...a })) : [emptyAchievement()])

watch(() => props.modelValue, (val) => {
  if (JSON.stringify(val) !== JSON.stringify(entries.value)) {
    entries.value = val.length ? val.map((a) => ({ ...a })) : [emptyAchievement()]
  }
}, { deep: true })

const add = () => { entries.value.push(emptyAchievement()); emit('update:modelValue', entries.value) }
const remove = (idx) => { entries.value.splice(idx, 1); emit('update:modelValue', entries.value) }

watch(entries, (val) => emit('update:modelValue', val), { deep: true })
</script>
