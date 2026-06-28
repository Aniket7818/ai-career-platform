<template>
  <Teleport to="body">
    <Transition name="fade">
      <div v-if="modelValue" class="fixed inset-0 z-[100] flex items-start justify-center pt-[15vh] px-4">
        <!-- Backdrop -->
        <div class="fixed inset-0 bg-slate-900/40 backdrop-blur-sm" @click="close"></div>
        
        <!-- Palette -->
        <div class="relative w-full max-w-lg bg-white rounded-2xl shadow-2xl overflow-hidden flex flex-col" @click.stop>
          <div class="flex items-center px-4 border-b border-slate-100">
            <svg class="size-5 text-slate-400" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="11" cy="11" r="8"/><path d="M21 21l-4.35-4.35"/></svg>
            <input 
              ref="searchInput"
              v-model="query"
              type="text"
              class="flex-1 bg-transparent border-none focus:ring-0 text-base py-4 px-3 outline-none text-ink placeholder:text-slate-400"
              placeholder="Search actions... (e.g., 'template', 'pdf')"
              @keydown.down.prevent="navigate(1)"
              @keydown.up.prevent="navigate(-1)"
              @keydown.enter.prevent="executeSelected"
              @keydown.esc.prevent="close"
            />
            <span class="text-[10px] font-bold text-slate-400 bg-slate-100 px-1.5 py-0.5 rounded border border-slate-200 uppercase tracking-widest">ESC</span>
          </div>

          <div class="max-h-[300px] overflow-y-auto custom-scrollbar p-2">
            <template v-if="filteredCommands.length > 0">
              <div 
                v-for="(cmd, index) in filteredCommands" 
                :key="cmd.id"
                class="flex items-center justify-between px-3 py-2.5 rounded-xl cursor-pointer transition-colors"
                :class="selectedIndex === index ? 'bg-brand/5 text-brand' : 'text-slate-700 hover:bg-slate-50'"
                @click="execute(cmd)"
                @mouseenter="selectedIndex = index"
              >
                <div class="flex items-center gap-3">
                  <span class="text-sm" :class="selectedIndex === index ? 'text-brand' : 'text-slate-400'" v-html="cmd.icon"></span>
                  <span class="font-semibold text-sm">{{ cmd.label }}</span>
                </div>
                <span class="text-[10px] font-medium text-slate-400">{{ cmd.category }}</span>
              </div>
            </template>
            <div v-else class="px-4 py-8 text-center">
              <p class="text-sm text-slate-500 font-medium">No commands found for "{{ query }}"</p>
            </div>
          </div>
          
          <div class="bg-slate-50 border-t border-slate-100 px-4 py-2 flex items-center justify-between text-[10px] font-medium text-slate-500">
            <div class="flex gap-4">
              <span class="flex items-center gap-1"><kbd class="bg-white px-1.5 py-0.5 rounded border border-slate-200 font-sans shadow-sm">↑</kbd><kbd class="bg-white px-1.5 py-0.5 rounded border border-slate-200 font-sans shadow-sm">↓</kbd> to navigate</span>
              <span class="flex items-center gap-1"><kbd class="bg-white px-1.5 py-0.5 rounded border border-slate-200 font-sans shadow-sm">Enter</kbd> to select</span>
            </div>
          </div>
        </div>
      </div>
    </Transition>
  </Teleport>
</template>

<script setup>
import { ref, computed, watch, onMounted, onBeforeUnmount, nextTick } from 'vue'

const props = defineProps({
  modelValue: { type: Boolean, required: true }
})

const emit = defineEmits(['update:modelValue', 'action'])

const query = ref('')
const searchInput = ref(null)
const selectedIndex = ref(0)

const commands = [
  { id: 'download_pdf', label: 'Download as PDF', category: 'Export', icon: '<svg class="size-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M21 15v4a2 2 0 01-2 2H5a2 2 0 01-2-2v-4"/><path d="M7 10l5 5 5-5"/><path d="M12 15V3"/></svg>', action: 'download' },
  { id: 'add_experience', label: 'Add Experience', category: 'Section', icon: '<svg class="size-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M12 5v14M5 12h14"/></svg>', action: 'add-section', payload: 'experience' },
  { id: 'add_education', label: 'Add Education', category: 'Section', icon: '<svg class="size-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M12 5v14M5 12h14"/></svg>', action: 'add-section', payload: 'education' },
  { id: 'add_project', label: 'Add Project', category: 'Section', icon: '<svg class="size-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M12 5v14M5 12h14"/></svg>', action: 'add-section', payload: 'projects' },
  { id: 'tmpl_modern', label: 'Switch to Modern Template', category: 'Template', icon: '<svg class="size-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M4 5a1 1 0 011-1h4a1 1 0 011 1v4a1 1 0 01-1 1H5a1 1 0 01-1-1V5zM4 15a1 1 0 011-1h4a1 1 0 011 1v4a1 1 0 01-1 1H5a1 1 0 01-1-1v-4zM14 5a1 1 0 011-1h4a1 1 0 011 1v4a1 1 0 01-1 1h-4a1 1 0 01-1-1V5zM14 15a1 1 0 011-1h4a1 1 0 011 1v4a1 1 0 01-1 1h-4a1 1 0 01-1-1v-4z"/></svg>', action: 'set-template', payload: 'modern' },
  { id: 'tmpl_professional', label: 'Switch to Professional Template', category: 'Template', icon: '<svg class="size-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M4 5a1 1 0 011-1h4a1 1 0 011 1v4a1 1 0 01-1 1H5a1 1 0 01-1-1V5zM4 15a1 1 0 011-1h4a1 1 0 011 1v4a1 1 0 01-1 1H5a1 1 0 01-1-1v-4zM14 5a1 1 0 011-1h4a1 1 0 011 1v4a1 1 0 01-1 1h-4a1 1 0 01-1-1V5zM14 15a1 1 0 011-1h4a1 1 0 011 1v4a1 1 0 01-1 1h-4a1 1 0 01-1-1v-4z"/></svg>', action: 'set-template', payload: 'professional' },
  { id: 'tmpl_executive', label: 'Switch to Executive Template', category: 'Template', icon: '<svg class="size-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M4 5a1 1 0 011-1h4a1 1 0 011 1v4a1 1 0 01-1 1H5a1 1 0 01-1-1V5zM4 15a1 1 0 011-1h4a1 1 0 011 1v4a1 1 0 01-1 1H5a1 1 0 01-1-1v-4zM14 5a1 1 0 011-1h4a1 1 0 011 1v4a1 1 0 01-1 1h-4a1 1 0 01-1-1V5zM14 15a1 1 0 011-1h4a1 1 0 011 1v4a1 1 0 01-1 1h-4a1 1 0 01-1-1v-4z"/></svg>', action: 'set-template', payload: 'executive' },
  { id: 'preview', label: 'Toggle Fullscreen Preview', category: 'View', icon: '<svg class="size-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M15 3h6v6M9 21H3v-6M21 3l-7 7M3 21l7-7"/></svg>', action: 'toggle-preview' },
  { id: 'run_intelligence', label: 'Run Intelligence Analysis', category: 'Intelligence', icon: '<svg class="size-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M12 2v20M17 5H9.5a3.5 3.5 0 000 7h5a3.5 3.5 0 010 7H6"/></svg>', action: 'focus-intelligence' }
]

const filteredCommands = computed(() => {
  if (!query.value) return commands
  const q = query.value.toLowerCase()
  return commands.filter(c => 
    c.label.toLowerCase().includes(q) || 
    c.category.toLowerCase().includes(q)
  )
})

watch(() => props.modelValue, (val) => {
  if (val) {
    query.value = ''
    selectedIndex.value = 0
    nextTick(() => {
      if (searchInput.value) searchInput.value.focus()
    })
  }
})

watch(query, () => {
  selectedIndex.value = 0
})

const navigate = (dir) => {
  const max = filteredCommands.value.length - 1
  let next = selectedIndex.value + dir
  if (next < 0) next = max
  if (next > max) next = 0
  selectedIndex.value = next
}

const executeSelected = () => {
  const cmd = filteredCommands.value[selectedIndex.value]
  if (cmd) execute(cmd)
}

const execute = (cmd) => {
  emit('action', { type: cmd.action, payload: cmd.payload })
  close()
}

const close = () => {
  emit('update:modelValue', false)
}

const handleKeydown = (e) => {
  if ((e.metaKey || e.ctrlKey) && e.key === 'k') {
    e.preventDefault()
    emit('update:modelValue', !props.modelValue)
  }
}

onMounted(() => {
  document.addEventListener('keydown', handleKeydown)
})

onBeforeUnmount(() => {
  document.removeEventListener('keydown', handleKeydown)
})
</script>

<style scoped>
.fade-enter-active,
.fade-leave-active {
  transition: opacity 0.2s ease, transform 0.2s ease;
}
.fade-enter-from,
.fade-leave-to {
  opacity: 0;
  transform: scale(0.98);
}
</style>
