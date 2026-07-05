<template>
 <div class="relative overflow-hidden rounded-3xl border border-border/80 bg-surface p-6 shadow-md transition-all duration-300 hover:shadow-lg hover:border-brand/30 flex flex-col justify-between group">
 <!-- Premium background glow on hover -->
 <div class="absolute -right-12 -top-12 -z-10 h-32 w-32 rounded-full bg-brand/5 blur-2xl transition-all duration-500 group-hover:bg-brand/10" />

 <div>
 <!-- Header with Icon & Lock Badge -->
 <div class="flex items-start justify-between gap-4">
 <div class="flex size-12 items-center justify-center rounded-2xl bg-brand/10 text-brand ">
 <!-- Dynamically render slot icon or fallback SVG -->
 <slot name="icon">
 <span class="text-2xl">{{ icon || '✨' }}</span>
 </slot>
 </div>
 <span class="inline-flex items-center gap-1 rounded-full bg-amber-50 px-2.5 py-1 text-xs font-semibold text-amber-700 ">
 <svg class="size-3" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
 <path stroke-linecap="round" stroke-linejoin="round" d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z" />
 </svg>
 Available in {{ requiredPlan }}
 </span>
 </div>

 <!-- Content -->
 <div class="mt-5">
 <h3 class="text-lg font-bold text-txt-primary">{{ title }}</h3>
 <p class="mt-2 text-sm text-txt-muted leading-relaxed">{{ description }}</p>
 </div>

 <!-- Divider -->
 <div class="my-5 border-t border-border" />

 <!-- Benefits List -->
 <div class="space-y-2.5">
 <p class="text-xs font-semibold uppercase tracking-wider text-txt-disabled">Upgrade to unlock:</p>
 <ul class="space-y-2">
 <li v-for="benefit in benefits" :key="benefit" class="flex items-start gap-2.5 text-sm text-txt-secondary">
 <svg class="size-4 shrink-0 text-brand mt-0.5" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2.5">
 <path stroke-linecap="round" stroke-linejoin="round" d="M5 13l4 4L19 7" />
 </svg>
 <span>{{ benefit }}</span>
 </li>
 </ul>
 </div>
 </div>

 <!-- CTA Button -->
 <div class="mt-8">
 <button
 type="button"
 class="w-full rounded-xl bg-gradient-to-r from-brand to-purple-600 px-4 py-3 text-center text-sm font-semibold text-white shadow-md shadow-brand/10 transition-all duration-200 hover:from-brand/90 hover:to-purple-600/90 hover:shadow-brand/20 hover:scale-[1.02] active:scale-95"
 @click="onClick"
 >
 Upgrade Plan
 </button>
 </div>
 </div>
</template>

<script setup>
import { useRouter } from 'vue-router'

const props = defineProps({
 title: { type: String, required: true },
 description: { type: String, required: true },
 requiredPlan: { type: String, default: 'Plus' },
 icon: { type: String, default: '' },
 benefits: { type: Array, default: () => [] },
 upgradeAction: { type: Function, default: null }
})

const router = useRouter()

const onClick = () => {
 if (props.upgradeAction) {
 props.upgradeAction()
 } else {
 router.push('/settings')
 }
}
</script>
