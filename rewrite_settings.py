import re
import os

filepath = '/home/aniket/Desktop/Projects/ai-career-platform/frontend/src/modules/settings/SettingsPage.vue'

with open(filepath, 'r') as f:
    content = f.read()

# 1. Root container
content = content.replace(
    '<div class="mx-auto max-w-6xl space-y-12 py-8 px-4 sm:px-6 lg:px-8 dark:text-slate-200">',
    '<div class="mx-auto max-w-6xl space-y-8 lg:space-y-12 py-6 lg:py-8 px-4 sm:px-6 lg:px-8 dark:text-slate-200">'
)

# 2. Hero Section
content = content.replace(
    '''<header class="text-center max-w-3xl mx-auto space-y-4">
        <div class="inline-flex items-center gap-1.5 rounded-full bg-brand/10 px-3 py-1 text-xs font-semibold text-brand dark:bg-brand/20">
          <span>Billing & Usage</span>
        </div>
        <h1 class="text-3xl font-extrabold tracking-tight text-slate-900 dark:text-white sm:text-5xl">
          Simple, Transparent Pricing
        </h1>
        <p class="text-base sm:text-lg text-slate-500 dark:text-slate-400">
          Unlock the next level of resume intelligence, cover letter generation, and interview preparation.
        </p>
      </header>''',
    '''<header class="flex flex-col items-center text-center max-w-3xl mx-auto space-y-4 md:space-y-6">
        <div class="inline-flex items-center justify-center gap-1.5 rounded-full bg-brand/10 px-3 py-1 text-xs font-semibold text-brand dark:bg-brand/20">
          <span>Billing & Usage</span>
        </div>
        <h1 class="text-[30px] md:text-[40px] lg:text-[56px] font-extrabold tracking-tight leading-tight text-slate-900 dark:text-white">
          Simple, Transparent Pricing
        </h1>
        <p class="text-[15px] lg:text-[18px] leading-relaxed text-slate-500 dark:text-slate-400">
          Unlock the next level of resume intelligence, cover letter generation, and interview preparation.
        </p>
      </header>'''
)

# 3. Current Plan Overview
content = content.replace(
    '<section v-if="user" class="relative overflow-hidden rounded-3xl border border-slate-200/80 bg-white p-6 sm:p-8 shadow-sm dark:border-slate-800 dark:bg-slate-900/40">',
    '<section v-if="user" class="relative overflow-hidden rounded-3xl border border-slate-200/80 bg-white p-5 lg:p-8 shadow-sm dark:border-slate-800 dark:bg-slate-900/40">'
)
content = content.replace(
    '<div class="grid grid-cols-1 lg:grid-cols-12 gap-8 items-stretch">',
    '<div class="flex flex-col lg:grid lg:grid-cols-12 gap-6 lg:gap-8 items-stretch">'
)
content = content.replace(
    '<div class="lg:col-span-7 flex flex-col justify-between space-y-6">',
    '<div class="lg:col-span-7 flex flex-col justify-between space-y-6 w-full">'
)

content = content.replace(
    '''<div class="grid grid-cols-2 sm:grid-cols-3 gap-4 border-t border-slate-100 dark:border-slate-800/80 pt-6">
              <div>
                <span class="block text-[10px] font-bold uppercase tracking-wider text-slate-400 dark:text-slate-500">Billing Cycle</span>
                <span class="mt-1 block text-sm font-semibold text-slate-800 dark:text-slate-200">{{ currentBillingCycle }}</span>
              </div>
              <div>
                <span class="block text-[10px] font-bold uppercase tracking-wider text-slate-400 dark:text-slate-500">Price</span>
                <span class="mt-1 block text-sm font-semibold text-slate-800 dark:text-slate-200">{{ currentPlanPrice }}</span>
              </div>
              <div v-if="user.subscription_plan !== 'free' && !isSubscriptionExpired">
                <span class="block text-[10px] font-bold uppercase tracking-wider text-slate-400 dark:text-slate-500">Started On</span>
                <span class="mt-1 block text-sm font-semibold text-slate-800 dark:text-slate-200">{{ formatDate(user.subscription_started_at) }}</span>
              </div>
              <div v-if="user.subscription_plan !== 'free' && !isSubscriptionExpired">
                <span class="block text-[10px] font-bold uppercase tracking-wider text-slate-400 dark:text-slate-500">Renewal Date</span>
                <span class="mt-1 block text-sm font-semibold text-slate-800 dark:text-slate-200">{{ formatDate(user.subscription_expires_at) }}</span>
              </div>
              <div v-if="user.subscription_plan !== 'free' && !isSubscriptionExpired">
                <span class="block text-[10px] font-bold uppercase tracking-wider text-slate-400 dark:text-slate-500">Credits Remaining</span>
                <span class="mt-1 block text-sm font-semibold text-slate-800 dark:text-slate-200">{{ remainingCreditsDisplay }}</span>
              </div>
              <div v-if="user.subscription_plan !== 'free' && !isSubscriptionExpired">
                <span class="block text-[10px] font-bold uppercase tracking-wider text-slate-400 dark:text-slate-500">Credit Reset Date</span>
                <span class="mt-1 block text-sm font-semibold text-slate-800 dark:text-slate-200">{{ creditsResetDate }}</span>
              </div>
            </div>''',
    '''<div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4 border-t border-slate-100 dark:border-slate-800/80 pt-6">
              <div class="flex flex-row sm:flex-col justify-between sm:justify-start items-center sm:items-start">
                <span class="block text-[10px] font-bold uppercase tracking-wider text-slate-400 dark:text-slate-500">Billing Cycle</span>
                <span class="mt-0 sm:mt-1 block text-[15px] sm:text-sm font-semibold text-slate-800 dark:text-slate-200">{{ currentBillingCycle }}</span>
              </div>
              <div class="flex flex-row sm:flex-col justify-between sm:justify-start items-center sm:items-start">
                <span class="block text-[10px] font-bold uppercase tracking-wider text-slate-400 dark:text-slate-500">Price</span>
                <span class="mt-0 sm:mt-1 block text-[15px] sm:text-sm font-semibold text-slate-800 dark:text-slate-200">{{ currentPlanPrice }}</span>
              </div>
              <div v-if="user.subscription_plan !== 'free' && !isSubscriptionExpired" class="flex flex-row sm:flex-col justify-between sm:justify-start items-center sm:items-start">
                <span class="block text-[10px] font-bold uppercase tracking-wider text-slate-400 dark:text-slate-500">Started On</span>
                <span class="mt-0 sm:mt-1 block text-[15px] sm:text-sm font-semibold text-slate-800 dark:text-slate-200">{{ formatDate(user.subscription_started_at) }}</span>
              </div>
              <div v-if="user.subscription_plan !== 'free' && !isSubscriptionExpired" class="flex flex-row sm:flex-col justify-between sm:justify-start items-center sm:items-start">
                <span class="block text-[10px] font-bold uppercase tracking-wider text-slate-400 dark:text-slate-500">Renewal Date</span>
                <span class="mt-0 sm:mt-1 block text-[15px] sm:text-sm font-semibold text-slate-800 dark:text-slate-200">{{ formatDate(user.subscription_expires_at) }}</span>
              </div>
              <div v-if="user.subscription_plan !== 'free' && !isSubscriptionExpired" class="flex flex-row sm:flex-col justify-between sm:justify-start items-center sm:items-start">
                <span class="block text-[10px] font-bold uppercase tracking-wider text-slate-400 dark:text-slate-500">Credits Remaining</span>
                <span class="mt-0 sm:mt-1 block text-[15px] sm:text-sm font-semibold text-slate-800 dark:text-slate-200">{{ remainingCreditsDisplay }}</span>
              </div>
              <div v-if="user.subscription_plan !== 'free' && !isSubscriptionExpired" class="flex flex-row sm:flex-col justify-between sm:justify-start items-center sm:items-start">
                <span class="block text-[10px] font-bold uppercase tracking-wider text-slate-400 dark:text-slate-500">Credit Reset Date</span>
                <span class="mt-0 sm:mt-1 block text-[15px] sm:text-sm font-semibold text-slate-800 dark:text-slate-200">{{ creditsResetDate }}</span>
              </div>
            </div>'''
)

content = content.replace(
    '<div v-show="showTechDetails" class="mt-3 grid grid-cols-1 sm:grid-cols-2 gap-4 rounded-xl bg-slate-50/50 p-4 border border-slate-100 dark:bg-slate-900/60 dark:border-slate-800/80 text-xs transition-all duration-200">',
    '<div v-show="showTechDetails" class="mt-3 flex flex-col sm:grid sm:grid-cols-2 gap-4 rounded-xl bg-slate-50/50 p-4 border border-slate-100 dark:bg-slate-900/60 dark:border-slate-800/80 text-xs transition-all duration-200">'
)

content = content.replace(
    '<div v-if="user.razorpay_subscription_id">',
    '<div v-if="user.razorpay_subscription_id" class="flex flex-col">'
)
content = content.replace(
    '<div v-if="user.razorpay_payment_id">',
    '<div v-if="user.razorpay_payment_id" class="flex flex-col">'
)

content = content.replace(
    '''<div class="grid grid-cols-3 gap-2 border-t border-slate-105 dark:border-slate-700/60 pt-4 mt-6">
              <div class="text-center">
                <span class="block text-[9px] font-bold uppercase tracking-wider text-slate-400 dark:text-slate-500">Used Credits</span>
                <span class="mt-1 block text-base font-black text-slate-800 dark:text-slate-200">{{ usedCreditsDisplay }}</span>
              </div>
              <div class="text-center border-x border-slate-105 dark:border-slate-700/60">
                <span class="block text-[9px] font-bold uppercase tracking-wider text-slate-400 dark:text-slate-500">Remaining</span>
                <span class="mt-1 block text-base font-black text-emerald-500 dark:text-emerald-450">{{ remainingCreditsDisplay }}</span>
              </div>
              <div class="text-center">
                <span class="block text-[9px] font-bold uppercase tracking-wider text-slate-400 dark:text-slate-500">Monthly Allocation</span>
                <span class="mt-1 block text-base font-black text-slate-800 dark:text-slate-200">{{ totalCreditsDisplay }}</span>
              </div>
            </div>''',
    '''<div class="grid grid-cols-1 sm:grid-cols-3 gap-3 sm:gap-2 border-t border-slate-105 dark:border-slate-700/60 pt-4 mt-6">
              <div class="flex items-center justify-between sm:block sm:text-center rounded-xl sm:rounded-none bg-slate-50/80 sm:bg-transparent p-3 sm:p-0 border border-slate-100 sm:border-0 dark:bg-slate-800/50 sm:dark:bg-transparent dark:border-slate-700/50">
                <span class="block text-[10px] font-bold uppercase tracking-wider text-slate-400 dark:text-slate-500">Used Credits</span>
                <span class="mt-0 sm:mt-1 block text-[15px] sm:text-base font-black text-slate-800 dark:text-slate-200">{{ usedCreditsDisplay }}</span>
              </div>
              <div class="flex items-center justify-between sm:block sm:text-center sm:border-x border-slate-105 dark:border-slate-700/60 rounded-xl sm:rounded-none bg-slate-50/80 sm:bg-transparent p-3 sm:p-0 border border-slate-100 sm:border-0 sm:border-y-0 dark:bg-slate-800/50 sm:dark:bg-transparent dark:border-slate-700/50">
                <span class="block text-[10px] font-bold uppercase tracking-wider text-slate-400 dark:text-slate-500">Remaining</span>
                <span class="mt-0 sm:mt-1 block text-[15px] sm:text-base font-black text-emerald-500 dark:text-emerald-450">{{ remainingCreditsDisplay }}</span>
              </div>
              <div class="flex items-center justify-between sm:block sm:text-center rounded-xl sm:rounded-none bg-slate-50/80 sm:bg-transparent p-3 sm:p-0 border border-slate-100 sm:border-0 dark:bg-slate-800/50 sm:dark:bg-transparent dark:border-slate-700/50">
                <span class="block text-[10px] font-bold uppercase tracking-wider text-slate-400 dark:text-slate-500">Monthly Allocation</span>
                <span class="mt-0 sm:mt-1 block text-[15px] sm:text-base font-black text-slate-800 dark:text-slate-200">{{ totalCreditsDisplay }}</span>
              </div>
            </div>'''
)

content = content.replace(
    '<div v-if="user.subscription_plan !== \'free\' && !isSubscriptionExpired" class="mt-6 border-t border-slate-105 dark:border-slate-800 pt-4 flex justify-end">',
    '<div v-if="user.subscription_plan !== \'free\' && !isSubscriptionExpired" class="mt-6 border-t border-slate-105 dark:border-slate-800 pt-4 flex flex-col md:flex-row md:justify-center lg:justify-end">'
)
content = content.replace(
    'class="inline-flex items-center gap-1.5 rounded-xl border border-slate-200 bg-white px-4 py-2 text-xs font-semibold text-slate-700 shadow-sm hover:bg-slate-50 dark:border-slate-700 dark:bg-slate-800 dark:text-slate-300 dark:hover:bg-slate-700 transition-all focus:ring-2 focus:ring-brand focus:outline-none"',
    'class="w-full md:w-auto min-h-[44px] justify-center inline-flex items-center gap-1.5 rounded-xl border border-slate-200 bg-white px-4 py-2 text-[15px] lg:text-xs font-semibold text-slate-700 shadow-sm hover:bg-slate-50 dark:border-slate-700 dark:bg-slate-800 dark:text-slate-300 dark:hover:bg-slate-700 transition-all focus:ring-2 focus:ring-brand focus:outline-none"'
)


# 4. Pricing Plans
content = content.replace(
    '<section class="space-y-10">',
    '<section class="space-y-8 lg:space-y-10">'
)
content = content.replace(
    '''<div class="flex items-center justify-center gap-3">
          <span class="text-sm font-semibold" :class="!isYearly ? 'text-slate-900 dark:text-white' : 'text-slate-400 dark:text-slate-500'">Monthly</span>
          <button 
            type="button"
            class="relative inline-flex h-6 w-11 shrink-0 cursor-pointer items-center rounded-full transition-colors duration-200 ease-in-out focus:outline-none focus:ring-2 focus:ring-brand focus:ring-offset-2 dark:focus:ring-offset-slate-900"
            :class="isYearly ? 'bg-brand' : 'bg-slate-200 dark:bg-slate-700'"
            @click="isYearly = !isYearly"
            aria-label="Toggle yearly billing"
          >
            <span 
              class="inline-block size-4 transform rounded-full bg-white shadow ring-0 transition duration-200 ease-in-out"
              :class="isYearly ? 'translate-x-6' : 'translate-x-1'"
            />
          </button>
          <span class="text-sm font-semibold flex items-center gap-2" :class="isYearly ? 'text-slate-900 dark:text-white' : 'text-slate-400 dark:text-slate-500'">
            Annually
            <span class="rounded-full bg-emerald-100 dark:bg-emerald-950/50 px-2.5 py-0.5 text-xs font-bold text-emerald-700 dark:text-emerald-400">Save 16%</span>
          </span>
        </div>''',
    '''<div class="flex items-center justify-center gap-3 min-h-[44px]">
          <span class="text-[15px] lg:text-sm font-semibold" :class="!isYearly ? 'text-slate-900 dark:text-white' : 'text-slate-400 dark:text-slate-500'">Monthly</span>
          <button 
            type="button"
            class="relative inline-flex h-8 w-14 lg:h-6 lg:w-11 shrink-0 cursor-pointer items-center rounded-full transition-colors duration-200 ease-in-out focus:outline-none focus:ring-2 focus:ring-brand focus:ring-offset-2 dark:focus:ring-offset-slate-900"
            :class="isYearly ? 'bg-brand' : 'bg-slate-200 dark:bg-slate-700'"
            @click="isYearly = !isYearly"
            aria-label="Toggle yearly billing"
          >
            <span 
              class="inline-block size-6 lg:size-4 transform rounded-full bg-white shadow ring-0 transition duration-200 ease-in-out"
              :class="isYearly ? 'translate-x-7 lg:translate-x-6' : 'translate-x-1'"
            />
          </button>
          <span class="text-[15px] lg:text-sm font-semibold flex items-center gap-2" :class="isYearly ? 'text-slate-900 dark:text-white' : 'text-slate-400 dark:text-slate-500'">
            Annually
            <span class="rounded-full bg-emerald-100 dark:bg-emerald-950/50 px-2.5 py-0.5 text-[10px] lg:text-xs font-bold text-emerald-700 dark:text-emerald-400">Save 16%</span>
          </span>
        </div>'''
)

content = content.replace(
    '<div class="grid gap-8 lg:grid-cols-3 max-w-lg mx-auto lg:max-w-none lg:mx-0 items-stretch">',
    '<div class="grid gap-6 md:gap-8 grid-cols-1 md:grid-cols-2 lg:grid-cols-3 max-w-none w-full items-stretch">'
)
content = content.replace(
    '<div \n            class="relative flex flex-col rounded-3xl border p-8 shadow-sm transition-all duration-300 hover:shadow-md hover:-translate-y-1 bg-white dark:bg-slate-900/30 flex-1 justify-between"',
    '<div \n            class="relative flex flex-col rounded-3xl border p-6 lg:p-8 shadow-sm transition-all duration-300 hover:shadow-md hover:-translate-y-1 bg-white dark:bg-slate-900/30 flex-1 justify-between"'
)
content = content.replace(
    '<div \n            class="relative flex flex-col rounded-3xl border-2 p-8 shadow-md transition-all duration-300 hover:shadow-lg hover:-translate-y-1 bg-white dark:bg-slate-900/40 flex-1 justify-between z-10 scale-[1.02]"',
    '<div \n            class="relative flex flex-col rounded-3xl border-2 p-6 lg:p-8 shadow-md transition-all duration-300 hover:shadow-lg hover:-translate-y-1 bg-white dark:bg-slate-900/40 flex-1 justify-between z-10 lg:scale-[1.02]"'
)

# Buttons min height
content = content.replace(
    'class="w-full rounded-xl px-4 py-3 text-center text-sm font-bold transition-all border border-slate-200 dark:border-slate-800 disabled:opacity-85 focus:ring-2 focus:ring-brand focus:outline-none"',
    'class="w-full min-h-[44px] rounded-xl px-4 py-3 text-center text-[15px] lg:text-sm font-bold transition-all border border-slate-200 dark:border-slate-800 disabled:opacity-85 focus:ring-2 focus:ring-brand focus:outline-none"'
)
content = content.replace(
    'class="w-full rounded-xl px-4 py-3 text-center text-sm font-bold transition-all shadow-md focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-brand disabled:opacity-85"',
    'class="w-full min-h-[44px] rounded-xl px-4 py-3 text-center text-[15px] lg:text-sm font-bold transition-all shadow-md focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-brand disabled:opacity-85"'
)


# 5. Feature Comparison Table -> Add Mobile View
TABLE_HTML = '''<section class="rounded-3xl border border-slate-200 bg-white p-6 sm:p-8 shadow-sm dark:border-slate-800 dark:bg-slate-900/30 overflow-x-auto">
        <div class="max-w-2xl mx-auto text-center mb-8">
          <h2 class="text-2xl font-bold tracking-tight text-slate-900 dark:text-white">Compare Plan Features</h2>
          <p class="text-sm text-slate-400 mt-1">Get a granular breakdown of what’s included in each plan tier.</p>
        </div>
        
        <div class="hidden md:block max-h-[600px] overflow-y-auto custom-scrollbar">'''

content = content.replace(
    '''<section class="rounded-3xl border border-slate-200 bg-white p-6 sm:p-8 shadow-sm dark:border-slate-800 dark:bg-slate-900/30 overflow-x-auto">
        <div class="max-w-2xl mx-auto text-center mb-8">
          <h2 class="text-2xl font-bold tracking-tight text-slate-900 dark:text-white">Compare Plan Features</h2>
          <p class="text-sm text-slate-400 mt-1">Get a granular breakdown of what’s included in each plan tier.</p>
        </div>
        
        <div class="max-h-[600px] overflow-y-auto custom-scrollbar">''',
    TABLE_HTML
)

MOBILE_ACCORDION_HTML = '''
        </div>

        <!-- Mobile Expandable Feature Sections -->
        <div class="md:hidden space-y-4">
          <div v-for="(group, idx) in COMPARISON_GROUPS" :key="group.category" class="rounded-2xl border border-slate-200 dark:border-slate-800 bg-slate-50/50 dark:bg-slate-900/40 overflow-hidden">
            <button 
              type="button"
              class="flex w-full items-center justify-between p-4 text-left focus:outline-none focus:ring-2 focus:ring-inset focus:ring-brand"
              @click="activeFeatureGroup = activeFeatureGroup === idx ? null : idx"
            >
              <span class="text-[15px] font-bold text-slate-900 dark:text-white">{{ group.category }}</span>
              <svg 
                class="size-5 text-slate-400 transition-transform duration-250" 
                :class="{'rotate-180': activeFeatureGroup === idx}"
                viewBox="0 0 20 20" fill="currentColor"
              >
                <path fill-rule="evenodd" d="M5.293 7.293a1 1 0 011.414 0L10 10.586l3.293-3.293a1 1 0 111.414 1.414l-4 4a1 1 0 01-1.414 0l-4-4a1 1 0 010-1.414z" clip-rule="evenodd" />
              </svg>
            </button>
            <div v-show="activeFeatureGroup === idx" class="border-t border-slate-100 dark:border-slate-800 p-4 space-y-4 bg-white dark:bg-slate-900/20">
              <div v-for="row in group.features" :key="row.name" class="space-y-2">
                <p class="text-sm font-semibold text-slate-700 dark:text-slate-300">{{ row.name }}</p>
                <div class="grid grid-cols-3 gap-2">
                  <div class="rounded-lg bg-slate-50 dark:bg-slate-800/60 p-2 text-center">
                    <span class="block text-[9px] font-bold uppercase tracking-wider text-slate-400 dark:text-slate-500 mb-1">Free</span>
                    <span v-if="row.free === 'yes'" class="text-emerald-500 font-bold text-base leading-none">✓</span>
                    <span v-else-if="row.free === 'no'" class="text-slate-400 font-bold text-sm leading-none">-</span>
                    <span v-else class="text-[11px] font-medium text-slate-600 dark:text-slate-400">{{ row.free }}</span>
                  </div>
                  <div class="rounded-lg bg-brand/[0.03] dark:bg-brand/10 border border-brand/10 dark:border-brand/20 p-2 text-center">
                    <span class="block text-[9px] font-bold uppercase tracking-wider text-brand mb-1">Plus</span>
                    <span v-if="row.plus === 'yes'" class="text-brand font-bold text-base leading-none">✓</span>
                    <span v-else-if="row.plus === 'no'" class="text-slate-400 font-bold text-sm leading-none">-</span>
                    <span v-else class="text-[11px] font-medium text-slate-800 dark:text-slate-200">{{ row.plus }}</span>
                  </div>
                  <div class="rounded-lg bg-slate-900 dark:bg-slate-100 p-2 text-center">
                    <span class="block text-[9px] font-bold uppercase tracking-wider text-slate-400 dark:text-slate-500 mb-1">Pro</span>
                    <span v-if="row.pro === 'yes'" class="text-emerald-400 font-bold text-base leading-none">✓</span>
                    <span v-else-if="row.pro === 'no'" class="text-slate-500 font-bold text-sm leading-none">-</span>
                    <span v-else class="text-[11px] font-medium text-slate-100 dark:text-slate-900">{{ row.pro }}</span>
                  </div>
                </div>
              </div>
            </div>
          </div>
'''

content = content.replace(
    '</section>\n\n      <!-- How AI Credits Work Section -->',
    f'{MOBILE_ACCORDION_HTML}\n        </div>\n      </section>\n\n      <!-- How AI Credits Work Section -->'
)


# Add activeFeatureGroup to script setup
content = content.replace(
    'const showCancelModal = ref(false)',
    'const showCancelModal = ref(false)\nconst activeFeatureGroup = ref(null)'
)

# 6. How AI Credits Work
content = content.replace(
    '<div class="grid gap-6 grid-cols-1 sm:grid-cols-2 lg:grid-cols-5">',
    '<div class="grid gap-4 md:gap-6 grid-cols-1 sm:grid-cols-2 lg:grid-cols-5">'
)
content = content.replace(
    '<div v-for="cost in PREMIUM_CREDIT_FEATURES" :key="cost.action" class="relative group flex flex-col justify-between rounded-2xl bg-white p-6 shadow-[0_2px_8px_rgba(15,23,42,0.03)] border border-slate-200/60 dark:bg-slate-900/40 dark:border-slate-800/80 hover:-translate-y-1 hover:shadow-[0_8px_30px_rgba(15,23,42,0.06)] hover:border-brand/30 dark:hover:border-brand/40 transition-all duration-300">',
    '<div v-for="cost in PREMIUM_CREDIT_FEATURES" :key="cost.action" class="relative group flex flex-col justify-between rounded-2xl w-full bg-white p-5 lg:p-6 shadow-[0_2px_8px_rgba(15,23,42,0.03)] border border-slate-200/60 dark:bg-slate-900/40 dark:border-slate-800/80 hover:-translate-y-1 hover:shadow-[0_8px_30px_rgba(15,23,42,0.06)] hover:border-brand/30 dark:hover:border-brand/40 transition-all duration-300">'
)
content = content.replace(
    '<section class="rounded-3xl border border-slate-200 bg-slate-50/50 p-6 sm:p-8 dark:border-slate-800 dark:bg-slate-900/50">',
    '<section class="rounded-3xl border border-slate-200 bg-slate-50/50 p-5 lg:p-8 dark:border-slate-800 dark:bg-slate-900/50">'
)


# 7. AI Workspace Info Card
content = content.replace(
    '<div class="mt-10 relative overflow-hidden rounded-3xl bg-gradient-to-br from-brand/5 via-purple-505/5 to-pink-500/5 border border-brand/10 dark:border-brand/20 p-8 text-center max-w-3xl mx-auto shadow-sm">',
    '<div class="mt-8 lg:mt-10 relative overflow-hidden w-full rounded-3xl bg-gradient-to-br from-brand/5 via-purple-505/5 to-pink-500/5 border border-brand/10 dark:border-brand/20 p-6 lg:p-8 text-center max-w-3xl mx-auto shadow-sm">'
)

# 8. Credit Transaction History
content = content.replace(
    '<div class="divide-y divide-slate-100 dark:divide-slate-800/60">',
    '<div class="divide-y divide-slate-100 dark:divide-slate-800/60 space-y-0">'
)
content = content.replace(
    '<div class="mt-8 rounded-2xl border border-slate-200 bg-white shadow-sm dark:border-slate-800 dark:bg-slate-900/40 overflow-hidden">',
    '<div class="mt-8 w-full rounded-2xl border border-slate-200 bg-white shadow-sm dark:border-slate-800 dark:bg-slate-900/40 overflow-hidden">'
)

# 9. Subscription Details Accordion
content = content.replace(
    '<div class="grid gap-6 sm:grid-cols-2 md:grid-cols-5">',
    '<div class="grid gap-6 grid-cols-1 sm:grid-cols-2 md:grid-cols-5">'
)
content = content.replace(
    '<div class="mt-6 border-t border-slate-100 dark:border-slate-800 pt-6 flex justify-between items-center">',
    '<div class="mt-6 border-t border-slate-100 dark:border-slate-800 pt-6 flex flex-col sm:flex-row justify-between items-center gap-4">'
)
content = content.replace(
    '''<p class="text-xs text-slate-400">Cancel subscription to revert to Free plan at the end of billing cycle.</p>
            <button 
              type="button"
              class="rounded-xl border border-red-200 px-4 py-2 text-xs font-bold text-red-600 hover:bg-red-50 dark:border-red-900/50 dark:text-red-400 dark:hover:bg-red-950/20 transition-colors focus:ring-2 focus:ring-red-500 focus:outline-none"
              @click="cancelSubscription"
            >
              Cancel Subscription
            </button>''',
    '''<p class="text-xs text-slate-400 text-center sm:text-left">Cancel subscription to revert to Free plan at the end of billing cycle.</p>
            <button 
              type="button"
              class="w-full sm:w-auto min-h-[44px] rounded-xl border border-red-200 px-4 py-2 text-[15px] lg:text-xs font-bold text-red-600 hover:bg-red-50 dark:border-red-900/50 dark:text-red-400 dark:hover:bg-red-950/20 transition-colors focus:ring-2 focus:ring-red-500 focus:outline-none"
              @click="cancelSubscription"
            >
              Cancel Subscription
            </button>'''
)

# 10. Subscription History (Billing Logs)
content = content.replace(
    '''<div v-for="item in billingHistory" :key="item.id" class="py-4 flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4">
              <div>
                <p class="text-sm font-semibold text-slate-800 dark:text-slate-200">
                  {{ item.plan_name === 'pro' ? 'CareerAI Pro' : (item.plan_name === 'plus' ? 'CareerAI Plus' : item.plan_name) }}
                </p>
                <div class="mt-1 flex items-center gap-2">
                  <span class="inline-flex items-center px-2 py-0.5 rounded text-[10px] font-bold uppercase tracking-wider" :class="item.payment_status === 'Paid' ? 'bg-emerald-100 text-emerald-700 dark:bg-emerald-900/30 dark:text-emerald-400' : 'bg-slate-100 text-slate-700 dark:bg-slate-800 dark:text-slate-300'">
                    {{ item.payment_status }}
                  </span>
                  <span class="text-xs font-bold text-slate-500 dark:text-slate-400">₹{{ Number(item.amount) }}</span>
                </div>
                <p class="mt-1.5 text-xs text-slate-500 dark:text-slate-400">
                  Paid on {{ formatDate(item.paid_at) }} &bull; Renews {{ formatDate(item.renewal_date) }}
                </p>
              </div>
              <div class="flex items-center gap-2">
                <button @click="paymentService.downloadInvoice(item.id)" class="rounded-lg border border-slate-200 bg-white px-3 py-1.5 text-xs font-bold text-slate-600 hover:bg-slate-50 dark:border-slate-700 dark:bg-slate-800 dark:text-slate-300 dark:hover:bg-slate-700 transition-colors">
                  Invoice
                </button>
                <button @click="paymentService.downloadReceipt(item.id)" class="rounded-lg border border-slate-200 bg-white px-3 py-1.5 text-xs font-bold text-slate-600 hover:bg-slate-50 dark:border-slate-700 dark:bg-slate-800 dark:text-slate-300 dark:hover:bg-slate-700 transition-colors">
                  Receipt
                </button>
              </div>
            </div>''',
    '''<div v-for="item in billingHistory" :key="item.id" class="py-4 flex flex-col md:flex-row justify-between items-start md:items-center gap-4 bg-slate-50/50 md:bg-transparent p-4 md:p-0 rounded-2xl md:rounded-none border border-slate-100 md:border-0 dark:bg-slate-800/30 md:dark:bg-transparent dark:border-slate-700/50">
              <div class="w-full md:w-auto">
                <div class="flex justify-between md:justify-start items-center md:items-start gap-2">
                  <p class="text-[15px] lg:text-sm font-semibold text-slate-800 dark:text-slate-200">
                    {{ item.plan_name === 'pro' ? 'CareerAI Pro' : (item.plan_name === 'plus' ? 'CareerAI Plus' : item.plan_name) }}
                  </p>
                  <span class="inline-flex items-center px-2 py-0.5 rounded text-[10px] font-bold uppercase tracking-wider" :class="item.payment_status === 'Paid' ? 'bg-emerald-100 text-emerald-700 dark:bg-emerald-900/30 dark:text-emerald-400' : 'bg-slate-100 text-slate-700 dark:bg-slate-800 dark:text-slate-300'">
                    {{ item.payment_status }}
                  </span>
                </div>
                <div class="mt-2 md:mt-1 flex flex-col md:flex-row gap-1 md:gap-2 text-[13px] md:text-xs text-slate-500 dark:text-slate-400">
                  <span class="font-bold text-slate-700 dark:text-slate-300">₹{{ Number(item.amount) }}</span>
                  <span class="hidden md:inline">&bull;</span>
                  <span>Paid on {{ formatDate(item.paid_at) }}</span>
                  <span class="hidden md:inline">&bull;</span>
                  <span>Renews {{ formatDate(item.renewal_date) }}</span>
                </div>
              </div>
              <div class="flex flex-col sm:flex-row items-stretch sm:items-center gap-2 w-full md:w-auto mt-2 md:mt-0">
                <button @click="paymentService.downloadInvoice(item.id)" class="w-full sm:w-auto min-h-[44px] md:min-h-[auto] rounded-xl md:rounded-lg border border-slate-200 bg-white px-3 py-2 md:py-1.5 text-[15px] lg:text-xs font-bold text-slate-600 hover:bg-slate-50 dark:border-slate-700 dark:bg-slate-800 dark:text-slate-300 dark:hover:bg-slate-700 transition-colors">
                  Invoice
                </button>
                <button @click="paymentService.downloadReceipt(item.id)" class="w-full sm:w-auto min-h-[44px] md:min-h-[auto] rounded-xl md:rounded-lg border border-slate-200 bg-white px-3 py-2 md:py-1.5 text-[15px] lg:text-xs font-bold text-slate-600 hover:bg-slate-50 dark:border-slate-700 dark:bg-slate-800 dark:text-slate-300 dark:hover:bg-slate-700 transition-colors">
                  Receipt
                </button>
              </div>
            </div>'''
)

# Empty states improvements
content = content.replace(
    '''<div v-else class="text-center py-8 space-y-4">''',
    '''<div v-else class="text-center py-8 space-y-4 flex flex-col items-center justify-center">'''
)
content = content.replace(
    '''<div v-else-if="creditHistory.length === 0" class="p-8 text-center">
            <p class="text-sm font-semibold text-slate-600 dark:text-slate-450">No credit transactions yet.</p>
          </div>''',
    '''<div v-else-if="creditHistory.length === 0" class="p-8 text-center flex flex-col items-center justify-center space-y-3">
            <div class="grid size-12 place-items-center rounded-full bg-slate-50 dark:bg-slate-800 text-slate-400">
              <svg class="size-6" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="1.5">
                <path stroke-linecap="round" stroke-linejoin="round" d="M12 6v6h4.5m4.5 0a9 9 0 11-18 0 9 9 0 0118 0z" />
              </svg>
            </div>
            <p class="text-[15px] lg:text-sm font-semibold text-slate-600 dark:text-slate-450">No credit transactions yet.</p>
          </div>'''
)


with open(filepath, 'w') as f:
    f.write(content)

print("Done.")
