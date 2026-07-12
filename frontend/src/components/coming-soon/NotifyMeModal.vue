<template>
 <div v-if="open" class="fixed inset-0 z-50 flex items-center justify-center p-4">
 <div class="absolute inset-0 bg-black/70 backdrop-blur-sm" @click="$emit('close')" />
 <div class="relative w-full max-w-md rounded-2xl border border-white/10 bg-surface-light p-6 shadow-glow">
 <h3 class="text-xl font-bold text-white">{{ t('comingSoon.modal.title') }}</h3>
 <p class="mt-2 text-sm text-txt-disabled">{{ t('comingSoon.modal.subtitle') }}</p>
 <p v-if="featureTitle" class="mt-3 rounded-lg bg-brand/10 px-3 py-2 text-sm font-semibold text-brand">{{ featureTitle }}</p>
 <form class="mt-5 space-y-4" @submit.prevent="submit">
 <div>
 <label class="text-xs font-semibold uppercase tracking-wide text-txt-disabled">{{ t('auth.email') }}</label>
 <input v-model="email" type="email" required class="mt-1.5 w-full rounded-xl border border-white/10 bg-surface px-4 py-2.5 text-txt-primary placeholder:text-txt-muted" :placeholder="t('comingSoon.modal.emailPlaceholder')" />
 </div>
 <ErrorState v-if="error" :message="error" />
 <div class="flex gap-3">
 <button type="button" class="flex-1 rounded-xl border border-white/10 px-4 py-2.5 text-sm font-semibold text-txt-muted hover:bg-surface/5" @click="$emit('close')">{{ t('common.cancel') }}</button>
 <AppButton class="flex-1" :loading="loading" type="submit">{{ t('comingSoon.notifyMe') }}</AppButton>
 </div>
 </form>
 </div>
 </div>
</template>

<script setup>
import { ref, watch, computed } from 'vue'
import AppButton from '../ui/AppButton.vue'
import ErrorState from '../ui/ErrorState.vue'
import { t } from '../../utils/i18n'

const props = defineProps({
 open: Boolean,
 featureKey: { type: String, default: '' },
 loading: Boolean,
 error: { type: String, default: '' },
 defaultEmail: { type: String, default: '' }
})

const emit = defineEmits(['close', 'submit'])

const email = ref('')

watch(() => props.open, (v) => {
 if (v) email.value = props.defaultEmail
})

const featureTitle = computed(() => (props.featureKey ? t(`comingSoon.features.${props.featureKey}.title`) : ''))

const submit = () => emit('submit', { feature_key: props.featureKey, email: email.value })
</script>
