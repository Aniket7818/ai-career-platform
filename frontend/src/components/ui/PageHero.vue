<template>
  <section class="relative overflow-hidden rounded-2xl border p-5 shadow-panel sm:rounded-3xl sm:p-6 lg:p-8" :class="sectionClass">
    <div class="absolute -right-16 -top-16 size-56 rounded-full bg-brand/15 blur-3xl" />
    <div class="absolute -bottom-12 -left-12 size-40 rounded-full bg-mint/10 blur-3xl" />
    <div class="relative">
      <p v-if="badge" class="text-sm font-semibold text-mint">{{ badge }}</p>
      <h1 class="mt-2 text-2xl font-bold sm:text-3xl lg:text-4xl" :class="titleClass">{{ title }}</h1>
      <p v-if="subtitle" class="mt-3 max-w-2xl text-base leading-7" :class="subtitleClass">{{ subtitle }}</p>
      <div v-if="$slots.actions" class="mt-6 flex flex-wrap gap-3"><slot name="actions" /></div>
    </div>
  </section>
</template>

<script setup>
defineProps({
  title: { type: String, required: true },
  subtitle: { type: String, default: '' },
  badge: { type: String, default: '' }
})

const sectionClass = 'border-slate-100 bg-gradient-to-br from-ink via-slate-800 to-ink text-white'
const titleClass = 'text-white'
const subtitleClass = 'text-slate-300'
</script>
