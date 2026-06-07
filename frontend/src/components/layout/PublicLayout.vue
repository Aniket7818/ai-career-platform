<template>
  <div class="flex min-h-screen flex-col bg-white">
    <PublicHeader />
    <main class="flex-1"><slot /></main>
    <SiteFooter />
  </div>
</template>

<script setup>
import PublicHeader from './PublicHeader.vue'
import SiteFooter from './SiteFooter.vue'
</script>
