<template>
 <div class="space-y-4">
 <div
 v-for="(cert, idx) in entries"
 :key="cert.id"
 class="group relative rounded-xl border border-border bg-surface p-5 transition hover:border-brand/30 hover:shadow-sm"
 >
 <div class="mb-4 flex flex-wrap items-center justify-between gap-3">
 <span class="text-xs font-bold uppercase tracking-wider text-brand">
 {{ entries.length > 1 ? `Certification ${idx + 1}` : 'Certification' }}
 </span>
 <div class="flex flex-wrap items-center gap-1.5 sm:gap-2">
 <button
 type="button"
 class="rounded px-2 py-1 text-[10px] font-semibold text-txt-muted hover:bg-surface-hover disabled:opacity-30"
 :disabled="idx === 0"
 @click="moveUp(idx)"
 >
 ↑
 </button>
 <button
 type="button"
 class="rounded px-2 py-1 text-[10px] font-semibold text-txt-muted hover:bg-surface-hover disabled:opacity-30"
 :disabled="idx === entries.length - 1"
 @click="moveDown(idx)"
 >
 ↓
 </button>
 <button
 type="button"
 class="rounded px-2.5 py-1 text-[10px] font-semibold text-txt-muted hover:bg-surface-hover"
 @click="duplicate(idx)"
 >
 Duplicate
 </button>
 <button
 type="button"
 class="rounded-lg px-2.5 py-1 text-xs font-semibold text-red-500 transition hover:bg-red-50"
 @click="remove(idx)"
 >
 {{ t('builder.deleteCertification') }}
 </button>
 </div>
 </div>
 <div class="grid gap-3 sm:grid-cols-2">
 <div class="sm:col-span-2">
 <label>{{ t('builder.certName') }}</label>
 <input v-model="cert.certName" placeholder="e.g. AWS Solutions Architect" @input="emit('update:modelValue', entries)" />
 </div>
 <div>
 <label>{{ t('builder.issuingOrg') }}</label>
 <input v-model="cert.issuingOrg" placeholder="e.g. Amazon Web Services" @input="emit('update:modelValue', entries)" />
 </div>
 <div>
 <label>{{ t('builder.issueDate') }}</label>
 <input v-model="cert.issueDate" type="month" @input="emit('update:modelValue', entries)" />
 </div>
 <div class="sm:col-span-2">
 <label>{{ t('builder.credentialUrl') }}</label>
 <input v-model="cert.credentialUrl" type="url" placeholder="https://credential.example.com/..." @input="emit('update:modelValue', entries)" />
 </div>
 </div>
 </div>

 <button
 type="button"
 class="w-full rounded-xl border border-dashed border-brand/40 py-2.5 text-sm font-semibold text-brand transition hover:border-brand hover:bg-brand/5"
 @click="add"
 >
 {{ t('builder.addCertification') }}
 </button>
 </div>
</template>

<script setup>
import { ref, watch } from 'vue'
import { t } from '../../../utils/i18n'
import { emptyCertification } from '../../../utils/profileToResume'

const props = defineProps({ modelValue: { type: Array, default: () => [] } })
const emit = defineEmits(['update:modelValue'])

const entries = ref(props.modelValue.length ? props.modelValue.map((c) => ({ ...c })) : [])

watch(() => props.modelValue, (val) => {
 if (JSON.stringify(val) !== JSON.stringify(entries.value)) {
 entries.value = (val || []).length ? (val || []).map((c) => ({ ...c })) : []
 }
}, { deep: true })

const add = () => { entries.value.push(emptyCertification()); emit('update:modelValue', entries.value) }
const remove = (idx) => { entries.value.splice(idx, 1); emit('update:modelValue', entries.value) }

const duplicate = (idx) => {
 const cert = { ...entries.value[idx], id: crypto.randomUUID() }
 entries.value.splice(idx + 1, 0, cert)
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

watch(entries, (val) => emit('update:modelValue', val), { deep: true })
</script>
