<template>
  <div class="grid gap-4 sm:grid-cols-2">
    <div>
      <label>{{ t('builder.leetcode') }}</label>
      <input
        :value="modelValue.leetcode"
        type="url"
        placeholder="https://leetcode.com/username"
        class="peer"
        @input="update('leetcode', $event.target.value)"
      />
      <span class="mt-1 hidden text-xs text-red-500 peer-invalid:block">Please enter a valid URL.</span>
    </div>
    <div>
      <label>{{ t('builder.codeforces') }}</label>
      <input
        :value="modelValue.codeforces"
        type="url"
        placeholder="https://codeforces.com/profile/username"
        class="peer"
        @input="update('codeforces', $event.target.value)"
      />
      <span class="mt-1 hidden text-xs text-red-500 peer-invalid:block">Please enter a valid URL.</span>
    </div>
    <div>
      <label>{{ t('builder.hackerrank') }}</label>
      <input
        :value="modelValue.hackerrank"
        type="url"
        placeholder="https://hackerrank.com/username"
        class="peer"
        @input="update('hackerrank', $event.target.value)"
      />
      <span class="mt-1 hidden text-xs text-red-500 peer-invalid:block">Please enter a valid URL.</span>
    </div>
    <p class="sm:col-span-2 text-xs text-slate-400">
      LinkedIn, GitHub, and Portfolio are managed in Personal Information above.
    </p>
  </div>
</template>

<script setup>
import { t } from '../../../utils/i18n'

const props = defineProps({ modelValue: { type: Object, default: () => ({}) } })
const emit = defineEmits(['update:modelValue'])

const update = (key, val) => emit('update:modelValue', { ...props.modelValue, [key]: val })
</script>
