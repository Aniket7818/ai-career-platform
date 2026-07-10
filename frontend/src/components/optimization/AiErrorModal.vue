<template>
  <div v-if="modelValue" class="fixed inset-0 z-[100] flex items-center justify-center p-4">
    <!-- Backdrop -->
    <div 
      class="absolute inset-0 bg-black/40 backdrop-blur-sm transition-opacity"
      @click="close"
    ></div>
    
    <!-- Modal Panel -->
    <div 
      class="relative w-full max-w-sm rounded-2xl bg-surface p-5 text-left shadow-2xl ring-1 ring-border sm:p-7 transform transition-all"
      role="dialog"
      aria-modal="true"
    >
      <div class="mb-4 flex items-center gap-3">
        <div class="flex h-10 w-10 shrink-0 items-center justify-center rounded-full bg-red-500/10 text-red-500">
          <svg class="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z" />
          </svg>
        </div>
        <h3 class="text-[17px] font-bold text-txt-primary">
          {{ title }}
        </h3>
      </div>
      
      <div class="mb-5">
        <p class="text-sm leading-relaxed text-txt-secondary whitespace-pre-wrap">{{ message }}</p>
      </div>

      <div class="flex justify-end">
        <button 
          @click="close"
          class="inline-flex w-full justify-center rounded-xl bg-surface-hover px-4 py-2.5 font-semibold text-txt-primary transition-colors hover:bg-border sm:w-auto text-sm"
        >
          OK
        </button>
      </div>
    </div>
  </div>
</template>

<script setup>
defineProps({
  modelValue: Boolean,
  title: {
    type: String,
    default: 'Error'
  },
  message: {
    type: String,
    default: 'An unexpected error occurred.'
  }
})

const emit = defineEmits(['update:modelValue', 'close'])

const close = () => {
  emit('update:modelValue', false)
  emit('close')
}
</script>
