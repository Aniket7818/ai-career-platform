<template>
 <div class="min-h-screen w-full max-w-full">
 <RouterView />
 <ToastContainer />
 </div>
</template>

<script setup>
import { onMounted } from 'vue'
import { useStore } from 'vuex'
import ToastContainer from './components/ui/ToastContainer.vue'

const store = useStore()
onMounted(() => {
 document.documentElement.classList.remove('dark')
 store.dispatch('auth/fetchMe')
})
</script>
