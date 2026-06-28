<template>
  <div class="space-y-4">
    <div
      v-for="(exp, idx) in entries"
      :key="exp.id"
      class="group relative rounded-xl border border-slate-200 bg-white p-5 transition hover:border-brand/30 hover:shadow-sm"
    >
      <div class="mb-4 flex flex-wrap items-center justify-between gap-3">
        <span class="text-xs font-bold uppercase tracking-wider text-brand">
          {{ entries.length > 1 ? `Experience ${idx + 1}` : 'Experience' }}
        </span>
        <div class="flex flex-wrap items-center gap-1.5 sm:gap-2">
          <button
            type="button"
            class="rounded px-2 py-1 text-[10px] font-semibold text-slate-500 hover:bg-slate-100 disabled:opacity-30"
            :disabled="idx === 0"
            @click="moveUp(idx)"
          >
            ↑
          </button>
          <button
            type="button"
            class="rounded px-2 py-1 text-[10px] font-semibold text-slate-500 hover:bg-slate-100 disabled:opacity-30"
            :disabled="idx === entries.length - 1"
            @click="moveDown(idx)"
          >
            ↓
          </button>
          <button
            type="button"
            class="rounded px-2.5 py-1 text-[10px] font-semibold text-slate-500 hover:bg-slate-100"
            @click="duplicate(idx)"
          >
            Duplicate
          </button>
          <button
            type="button"
            class="rounded-lg px-2.5 py-1 text-xs font-semibold text-red-500 transition hover:bg-red-50"
            @click="remove(idx)"
          >
            {{ t('builder.deleteExperience') }}
          </button>
        </div>
      </div>
      <div class="grid gap-3 sm:grid-cols-2">
        <div>
          <label>{{ t('builder.role') }}</label>
          <input v-model="exp.role" :placeholder="t('builder.role')" @input="emit('update', entries)" />
        </div>
        <div>
          <label>{{ t('builder.company') }}</label>
          <input v-model="exp.company" :placeholder="t('builder.company')" @input="emit('update', entries)" />
        </div>
        <div>
          <label>{{ t('builder.startDate') }}</label>
          <input v-model="exp.startDate" type="month" @input="emit('update', entries)" />
        </div>
        <div>
          <label>{{ t('builder.endDate') }}</label>
          <input v-model="exp.endDate" type="month" @input="emit('update', entries)" />
        </div>
        <div class="sm:col-span-2">
          <label>{{ t('builder.description') }}</label>
          <textarea v-model="exp.description" rows="3" :placeholder="'Key responsibilities and achievements...'" @input="emit('update', entries)" />
        </div>
      </div>
    </div>

    <button
      type="button"
      class="w-full rounded-xl border border-dashed border-brand/40 py-2.5 text-sm font-semibold text-brand transition hover:border-brand hover:bg-brand/5"
      @click="add"
    >
      {{ t('builder.addExperience') }}
    </button>
  </div>
</template>

<script setup>
import { ref, watch } from 'vue'
import { t } from '../../../utils/i18n'
import { emptyExperience } from '../../../utils/profileToResume'

const props = defineProps({ modelValue: { type: Array, default: () => [] } })
const emit = defineEmits(['update:modelValue', 'update'])

const entries = ref(props.modelValue.length ? props.modelValue.map((e) => ({ ...e })) : [])

watch(() => props.modelValue, (val) => {
  if (JSON.stringify(val) !== JSON.stringify(entries.value)) {
    entries.value = (val || []).length ? (val || []).map((e) => ({ ...e })) : []
  }
}, { deep: true })

const add = () => { entries.value.push(emptyExperience()); emit('update:modelValue', entries.value) }
const remove = (idx) => { entries.value.splice(idx, 1); emit('update:modelValue', entries.value) }

const duplicate = (idx) => {
  const exp = { ...entries.value[idx], id: crypto.randomUUID() }
  entries.value.splice(idx + 1, 0, exp)
  emit('update:modelValue', entries.value)
}

const moveUp = (idx) => {
  if (idx === 0) return
  const temp = entries.value[idx]
  entries.value[idx] = entries.value[idx - 1]
  entries.value[idx - 1] = temp
  emit('update:modelValue', entries.value)
}

const moveDown = (idx) => {
  if (idx === entries.value.length - 1) return
  const temp = entries.value[idx]
  entries.value[idx] = entries.value[idx + 1]
  entries.value[idx + 1] = temp
  emit('update:modelValue', entries.value)
}

// Watch entries for any change and emit
watch(entries, (val) => emit('update:modelValue', val), { deep: true })
</script>
