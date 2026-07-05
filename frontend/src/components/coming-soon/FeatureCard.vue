<template>
 <article class="group relative flex flex-col overflow-hidden rounded-2xl border border-white/10 bg-surface-light/80 p-6 shadow-glow backdrop-blur transition hover:border-brand/40 hover:shadow-glow">
 <div class="absolute -right-8 -top-8 size-32 rounded-full bg-brand/10 blur-2xl transition group-hover:bg-brand/20" />
 <div class="relative flex items-start justify-between gap-4">
 <FeatureIcon :name="icon" />
 <div class="flex flex-col items-end gap-2">
 <span class="rounded-full bg-brand/20 px-2.5 py-1 text-[10px] font-bold uppercase tracking-wider text-brand">{{ t('comingSoon.badge') }}</span>
 <FeatureStatusBadge :status="feature.status" />
 </div>
 </div>
 <div class="relative mt-5">
 <h3 class="text-lg font-bold text-white">{{ title }}</h3>
 <p class="mt-2 text-sm leading-6 text-txt-disabled">{{ description }}</p>
 </div>
 <ul class="relative mt-4 grid gap-1.5">
 <li v-for="highlight in highlights" :key="highlight" class="flex items-center gap-2 text-xs text-txt-muted">
 <span class="size-1.5 rounded-full bg-mint" />
 {{ highlight }}
 </li>
 </ul>
 <div class="relative mt-5 space-y-4">
 <FeatureProgressBar :progress="feature.progress" :status="feature.status" />
 <div class="flex items-center justify-between text-xs text-txt-disabled">
 <span>{{ t('comingSoon.estimatedAvailability') }}: <strong class="text-slate-200">{{ feature.estimated_availability || feature.estimatedAvailability }}</strong></span>
 <span class="flex items-center gap-1.5">
 <span class="relative flex size-2">
 <span class="absolute inline-flex size-full animate-ping rounded-full bg-mint opacity-60" />
 <span class="relative inline-flex size-2 rounded-full bg-mint" />
 </span>
 <AnimatedNumber :value="feature.interest_count || 0" /> {{ t('comingSoon.interested') }}
 </span>
 </div>
 </div>
 <div class="relative mt-6 flex gap-2">
 <template v-if="feature.notified">
 <div class="flex flex-1 items-center justify-center gap-2 rounded-xl border border-emerald-500/30 bg-emerald-500/10 px-4 py-2.5 text-sm font-semibold text-emerald-300">
 <svg class="size-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M20 6L9 17l-5-5" /></svg>
 {{ t('comingSoon.notified') }}
 </div>
 <button
 class="rounded-xl border border-white/15 px-4 py-2.5 text-sm font-semibold text-txt-muted transition hover:border-red-500/30 hover:bg-red-500/10 hover:text-red-300 disabled:opacity-60"
 :disabled="loading"
 :title="t('comingSoon.removeNotify')"
 @click="$emit('unnotify', feature.key)"
 >
 {{ loading ? '…' : t('comingSoon.removeNotify') }}
 </button>
 </template>
 <button
 v-else
 class="flex flex-1 items-center justify-center rounded-xl bg-brand px-4 py-2.5 text-sm font-semibold text-white shadow-lg shadow-brand/25 transition hover:bg-indigo-600 disabled:opacity-60"
 :disabled="loading"
 @click="$emit('notify', feature.key)"
 >
 {{ loading ? t('common.loading') : t('comingSoon.notifyMe') }}
 </button>
 </div>
 </article>
</template>

<script setup>
import FeatureIcon from './FeatureIcon.vue'
import FeatureStatusBadge from './FeatureStatusBadge.vue'
import FeatureProgressBar from './FeatureProgressBar.vue'
import AnimatedNumber from './AnimatedNumber.vue'
import { FEATURE_ICONS } from '../../constants/features'
import { t } from '../../utils/i18n'
import { computed } from 'vue'

const props = defineProps({
 feature: { type: Object, required: true },
 loading: { type: Boolean, default: false }
})

defineEmits(['notify', 'unnotify'])

const icon = computed(() => FEATURE_ICONS[props.feature.key] || 'resume')
const title = computed(() => t(`comingSoon.features.${props.feature.key}.title`))
const description = computed(() => t(`comingSoon.features.${props.feature.key}.description`))
const highlights = computed(() => {
 const keys = t(`comingSoon.features.${props.feature.key}.highlights`)
 return Array.isArray(keys) ? keys : []
})
</script>
