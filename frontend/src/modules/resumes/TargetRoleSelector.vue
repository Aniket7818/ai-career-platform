<template>
 <div class="relative">
 <label class="text-xs font-semibold uppercase tracking-wide text-txt-muted">Target Job Role</label>
 <div class="relative mt-1">
 <input
 ref="inputRef"
 :value="modelValue"
 @input="onInput"
 @focus="showDropdown = true"
 @blur="onBlur"
 type="text"
 placeholder="e.g. Frontend Developer"
 class="w-full rounded-xl border border-border bg-surface px-3 py-2.5 pr-8 text-sm text-txt-primary outline-none transition focus:border-brand focus:ring-2 focus:ring-brand/15"
 />
 <svg class="absolute right-2.5 top-1/2 -translate-y-1/2 size-4 text-txt-disabled pointer-events-none" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="11" cy="11" r="8"/><path d="M21 21l-4.35-4.35"/></svg>
 </div>
 <Transition name="fade">
 <ul
 v-if="showDropdown && filteredRoles.length"
 class="absolute z-20 mt-1 w-full max-h-48 overflow-y-auto rounded-xl border border-border bg-surface py-1 shadow-lg"
 >
 <li
 v-for="role in filteredRoles"
 :key="role"
 class="cursor-pointer px-3 py-2 text-sm text-txt-secondary transition hover:bg-brand/5 hover:text-brand"
 @mousedown.prevent="selectRole(role)"
 >
 {{ role }}
 </li>
 </ul>
 </Transition>
 <p class="mt-1 text-[10px] text-txt-disabled leading-tight">
 Used only for Resume Intelligence analysis. This is NOT included in your exported resume or PDF.
 </p>
 </div>
</template>

<script setup>
import { ref, computed } from 'vue'
import { AVAILABLE_ROLES } from '../../intelligence/RoleKeywordLibrary'

const props = defineProps({ modelValue: { type: String, default: '' } })
const emit = defineEmits(['update:modelValue'])

const inputRef = ref(null)
const showDropdown = ref(false)
const searchQuery = ref('')

const filteredRoles = computed(() => {
 const q = (searchQuery.value || props.modelValue || '').toLowerCase().trim()
 if (!q) return AVAILABLE_ROLES
 return AVAILABLE_ROLES.filter(r => r.toLowerCase().includes(q))
})

const onInput = (e) => {
 searchQuery.value = e.target.value
 emit('update:modelValue', e.target.value)
 showDropdown.value = true
}

const selectRole = (role) => {
 emit('update:modelValue', role)
 searchQuery.value = ''
 showDropdown.value = false
}

const onBlur = () => {
 setTimeout(() => { showDropdown.value = false }, 150)
}
</script>

<style scoped>
.fade-enter-active, .fade-leave-active { transition: opacity 0.15s ease; }
.fade-enter-from, .fade-leave-to { opacity: 0; }
</style>
