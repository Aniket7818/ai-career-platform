import { ref, watch, onMounted, onUnmounted } from 'vue'
import { useRoute } from 'vue-router'

export function useMobileNav() {
 const isOpen = ref(false)
 const route = useRoute()

 const open = () => { isOpen.value = true }
 const close = () => { isOpen.value = false }
 const toggle = () => { isOpen.value = !isOpen.value }

 watch(() => route.path, () => close())

 watch(isOpen, (open) => {
 if (typeof document === 'undefined') return
 document.body.style.overflow = open ? 'hidden' : ''
 })

 const onKeydown = (e) => {
 if (e.key === 'Escape') close()
 }

 onMounted(() => window.addEventListener('keydown', onKeydown))
 onUnmounted(() => {
 window.removeEventListener('keydown', onKeydown)
 document.body.style.overflow = ''
 })

 return { isOpen, open, close, toggle }
}
