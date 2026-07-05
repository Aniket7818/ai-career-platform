<template>
 <div class="grid size-12 place-items-center rounded-xl bg-brand/15 text-brand ring-1 ring-brand/25">
 <svg class="size-6" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.75" stroke-linecap="round" stroke-linejoin="round">
 <template v-if="name === 'ats'">
 <path d="M9 12l2 2 4-4" /><path d="M21 12a9 9 0 11-18 0 9 9 0 0118 0z" /><path d="M12 6v1" />
 </template>
 <template v-else-if="name === 'letter'">
 <path d="M4 4h16v16H4z" /><path d="M4 8l8 5 8-5" />
 </template>
 <template v-else-if="name === 'interview'">
 <path d="M12 1a3 3 0 00-3 3v4a3 3 0 006 0V4a3 3 0 00-3-3z" /><path d="M19 10v2a7 7 0 01-14 0v-2" /><path d="M12 19v4" /><path d="M8 23h8" />
 </template>
 <template v-else-if="name === 'portfolio'">
 <rect x="3" y="3" width="18" height="18" rx="2" /><path d="M3 9h18" /><path d="M9 21V9" />
 </template>
 <template v-else-if="name === 'github'">
 <path d="M9 19c-5 1.5-5-2.5-7-3m14 6v-3.87a3.37 3.37 0 00-.94-2.61c3.14-.35 6.44-1.54 6.44-7A5.44 5.44 0 0020 4.77 5.07 5.07 0 0019.91 1S18.73.65 16 2.48a13.38 13.38 0 00-7 0C6.27.65 5.09 1 5.09 1A5.07 5.07 0 005 4.77a5.44 5.44 0 00-1.5 3.78c0 5.42 3.3 6.61 6.44 7A3.37 3.37 0 009 18.13V22" />
 </template>
 <template v-else-if="name === 'linkedin'">
 <path d="M16 8a6 6 0 016 6v7h-4v-7a2 2 0 00-4 0v7h-4v-7a6 6 0 016-6z" /><rect x="2" y="9" width="4" height="12" /><circle cx="4" cy="4" r="2" />
 </template>
 <template v-else-if="name === 'tracker'">
 <path d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2" /><rect x="9" y="3" width="6" height="4" rx="1" /><path d="M9 12h6" /><path d="M9 16h6" />
 </template>
 <template v-else-if="name === 'roadmap'">
 <path d="M3 3v18h18" /><path d="M7 16l4-6 4 3 5-8" />
 </template>
 <template v-else-if="name === 'placement'">
 <path d="M22 10v6M2 10l10-5 10 5-10 5z" /><path d="M6 12v5c0 1 3 3 6 3s6-2 6-3v-5" />
 </template>
 <template v-else>
 <path d="M14 2H6a2 2 0 00-2 2v16a2 2 0 002 2h12a2 2 0 002-2V8z" /><path d="M14 2v6h6" /><path d="M16 13H8" /><path d="M16 17H8" /><path d="M10 9H8" />
 </template>
 </svg>
 </div>
</template>

<script setup>
defineProps({ name: { type: String, required: true } })
</script>
