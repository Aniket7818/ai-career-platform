<template>
  <span>{{ display }}</span>
</template>

<script setup>
import { ref, watch, onMounted } from 'vue'

const props = defineProps({
  value: { type: Number, default: 0 },
  duration: { type: Number, default: 1200 },
  suffix: { type: String, default: '' }
})

const display = ref('0')

const animate = (target) => {
  const start = performance.now()
  const from = 0
  const step = (now) => {
    const progress = Math.min((now - start) / props.duration, 1)
    const eased = 1 - (1 - progress) ** 3
    const current = Math.round(from + (target - from) * eased)
    display.value = `${current.toLocaleString()}${props.suffix}`
    if (progress < 1) requestAnimationFrame(step)
  }
  requestAnimationFrame(step)
}

watch(() => props.value, (v) => animate(v), { immediate: false })
onMounted(() => animate(props.value))
</script>
