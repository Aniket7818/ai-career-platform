<template>
 <div class="min-h-screen w-full max-w-full">
 <RouterView />
 <ToastContainer />
 <StartupOverlay />
 </div>
</template>

<script setup>
import { onMounted } from 'vue'
import { useStore } from 'vuex'
import ToastContainer from './components/ui/ToastContainer.vue'
import StartupOverlay from './components/ui/StartupOverlay.vue'
import { initiateWakeUp } from './services/backendAvailability'

// Start waking the backend immediately on app load
initiateWakeUp()

const store = useStore()
onMounted(() => {
 document.documentElement.classList.remove('dark')
 store.dispatch('auth/fetchMe')
})
</script>
