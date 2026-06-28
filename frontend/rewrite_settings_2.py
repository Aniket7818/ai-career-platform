import os
import re

filepath = '/home/aniket/Desktop/Projects/ai-career-platform/frontend/src/modules/settings/SettingsPage.vue'
with open(filepath, 'r') as f:
    content = f.read()

# 1. Reduce Hero Height
content = content.replace(
    '<header class="flex flex-col items-center text-center max-w-3xl mx-auto space-y-4 md:space-y-6">',
    '<header class="flex flex-col items-center text-center max-w-3xl mx-auto space-y-3 md:space-y-6 pt-2 lg:pt-0">'
)
content = content.replace(
    '<h1 class="text-[30px] md:text-[40px] lg:text-[56px]',
    '<h1 class="text-[26px] md:text-[40px] lg:text-[56px]'
)
content = content.replace(
    '<p class="text-[15px] lg:text-[18px] leading-relaxed text-slate-500 dark:text-slate-400">',
    '<p class="text-[14px] lg:text-[18px] leading-relaxed text-slate-500 dark:text-slate-400 max-w-[280px] lg:max-w-none">'
)

# 2. Compare Plans Section - Collapse by default on mobile
# Add state to setup
if 'const showCompareMobile = ref(false)' not in content:
    content = content.replace(
        "const activeTab = ref('overview')",
        "const activeTab = ref('overview')\nconst showCompareMobile = ref(false)"
    )

content = content.replace(
    '<div class="md:hidden space-y-4">',
    '''<!-- Mobile Compare Toggle -->
        <button type="button" class="w-full md:hidden flex items-center justify-between p-4 mb-4 rounded-xl border border-brand/20 bg-brand/5 text-brand font-bold focus:outline-none focus:ring-2 focus:ring-brand" @click="showCompareMobile = !showCompareMobile">
          <span>Compare Plan Features</span>
          <svg class="size-5 transition-transform duration-250" :class="{'rotate-180': showCompareMobile}" viewBox="0 0 20 20" fill="currentColor"><path fill-rule="evenodd" d="M5.293 7.293a1 1 0 011.414 0L10 10.586l3.293-3.293a1 1 0 111.414 1.414l-4 4a1 1 0 01-1.414 0l-4-4a1 1 0 010-1.414z" clip-rule="evenodd" /></svg>
        </button>
        <div class="md:hidden space-y-4" v-show="showCompareMobile">'''
)

# 3. AI Credits Section - Horizontal Swipe Carousel on mobile
# Find: <div class="grid gap-3 lg:gap-6 grid-cols-1 sm:grid-cols-2 lg:grid-cols-5">
# Replace with: <div class="flex overflow-x-auto snap-x snap-mandatory lg:grid gap-3 lg:gap-6 lg:grid-cols-5 pb-4 lg:pb-0 -mx-4 px-4 lg:mx-0 lg:px-0 custom-scrollbar">
content = content.replace(
    '<div class="grid gap-3 lg:gap-6 grid-cols-1 sm:grid-cols-2 lg:grid-cols-5">',
    '<div class="flex overflow-x-auto snap-x snap-mandatory lg:grid gap-3 lg:gap-6 lg:grid-cols-5 pb-4 lg:pb-0 -mx-4 px-4 lg:mx-0 lg:px-0 custom-scrollbar">'
)

# Replace the inner card classes to support snapping and width on mobile
# Find: class="focus:outline-none relative group flex flex-col justify-between rounded-xl lg:rounded-2xl w-full bg-white p-4 lg:p-6 shadow-[0_2px_8px_rgba(15,23,42,0.03)] ...
content = content.replace(
    'class="focus:outline-none relative group flex flex-col justify-between rounded-xl lg:rounded-2xl w-full bg-white p-4 lg:p-6 shadow-[0_2px_8px_rgba(15,23,42,0.03)]',
    'class="focus:outline-none relative group flex flex-col justify-between rounded-xl lg:rounded-2xl min-w-[240px] lg:w-full snap-center bg-white p-4 lg:p-6 shadow-[0_2px_8px_rgba(15,23,42,0.03)]'
)

# Write modified content
with open(filepath, 'w') as f:
    f.write(content)
print("Done")
