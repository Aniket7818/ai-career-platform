import os

filepath = '/home/aniket/Desktop/Projects/ai-career-platform/frontend/src/modules/settings/SettingsPage.vue'

with open(filepath, 'r') as f:
    content = f.read()

# 1. Section Spacing
content = content.replace(
    '<div class="mx-auto max-w-6xl space-y-8 lg:space-y-12 py-6 lg:py-8 px-4 sm:px-6 lg:px-8 dark:text-slate-200">',
    '<div class="mx-auto max-w-6xl space-y-6 lg:space-y-12 py-4 lg:py-8 px-4 sm:px-6 lg:px-8 dark:text-slate-200">'
)

# 2. Inject Mobile Section Navigator after Header
nav_html = """
      <!-- Mobile Section Navigator -->
      <nav class="sticky top-0 z-40 -mx-4 sm:-mx-6 px-4 sm:px-6 bg-white/90 dark:bg-slate-900/90 backdrop-blur-md border-b border-slate-200/80 dark:border-slate-800/80 lg:hidden flex items-center gap-6 overflow-x-auto custom-scrollbar shadow-sm mb-2 mt-4 transition-transform duration-300">
        <a href="#overview" class="whitespace-nowrap py-3 text-sm font-bold border-b-2 transition-colors" :class="activeTab === 'overview' ? 'text-brand border-brand' : 'text-slate-500 hover:text-slate-800 dark:text-slate-400 dark:hover:text-slate-200 border-transparent'" @click.prevent="scrollTo('overview')">Overview</a>
        <a href="#plans" class="whitespace-nowrap py-3 text-sm font-bold border-b-2 transition-colors" :class="activeTab === 'plans' ? 'text-brand border-brand' : 'text-slate-500 hover:text-slate-800 dark:text-slate-400 dark:hover:text-slate-200 border-transparent'" @click.prevent="scrollTo('plans')">Plans</a>
        <a href="#credits" class="whitespace-nowrap py-3 text-sm font-bold border-b-2 transition-colors" :class="activeTab === 'credits' ? 'text-brand border-brand' : 'text-slate-500 hover:text-slate-800 dark:text-slate-400 dark:hover:text-slate-200 border-transparent'" @click.prevent="scrollTo('credits')">AI Credits</a>
        <a href="#history" class="whitespace-nowrap py-3 text-sm font-bold border-b-2 transition-colors" :class="activeTab === 'history' ? 'text-brand border-brand' : 'text-slate-500 hover:text-slate-800 dark:text-slate-400 dark:hover:text-slate-200 border-transparent'" @click.prevent="scrollTo('history')">History</a>
      </nav>
"""
content = content.replace('</header>', '</header>' + nav_html)

# Add activeTab and scrollTo to script setup
script_logic = """
const activeTab = ref('overview')
const showAllFeatures = ref(false)
const showCreditHistory = ref(false)

const scrollTo = (id) => {
  activeTab.value = id
  const el = document.getElementById(id)
  if (el) {
    const y = el.getBoundingClientRect().top + window.scrollY - 60
    window.scrollTo({ top: y, behavior: 'smooth' })
  }
}

onMounted(() => {
  const observer = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
      if (entry.isIntersecting) {
        activeTab.value = entry.target.id
      }
    })
  }, { rootMargin: '-20% 0px -80% 0px' })
  
  setTimeout(() => {
    ['overview', 'plans', 'credits', 'history'].forEach(id => {
      const el = document.getElementById(id)
      if (el) observer.observe(el)
    })
  }, 500)
})
"""
content = content.replace('const store = useStore()', 'const store = useStore()\n' + script_logic)

# 3. Overview Section
content = content.replace(
    '<section v-if="user" class="relative overflow-hidden rounded-3xl border border-slate-200/80 bg-white p-5 lg:p-8 shadow-sm dark:border-slate-800 dark:bg-slate-900/40">',
    '<section id="overview" v-if="user" class="relative overflow-hidden rounded-2xl lg:rounded-3xl border border-slate-200/80 bg-white p-4 lg:p-8 shadow-sm dark:border-slate-800 dark:bg-slate-900/40 scroll-mt-16">'
)

# Subscription Metadata Compact Rows
old_metadata = '''<div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4 border-t border-slate-100 dark:border-slate-800/80 pt-6">
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
new_metadata = '''<div class="flex flex-col gap-2.5 lg:grid lg:grid-cols-3 lg:gap-4 border-t border-slate-100 dark:border-slate-800/80 pt-4 lg:pt-6">
              <div class="flex flex-row lg:flex-col justify-between lg:justify-start items-center lg:items-start">
                <span class="block text-xs font-medium text-slate-500 dark:text-slate-400">Billing Cycle</span>
                <span class="block text-sm font-bold text-slate-800 dark:text-slate-200">{{ currentBillingCycle }}</span>
              </div>
              <div class="flex flex-row lg:flex-col justify-between lg:justify-start items-center lg:items-start">
                <span class="block text-xs font-medium text-slate-500 dark:text-slate-400">Price</span>
                <span class="block text-sm font-bold text-slate-800 dark:text-slate-200">{{ currentPlanPrice }}</span>
              </div>
              <div v-if="user.subscription_plan !== 'free' && !isSubscriptionExpired" class="flex flex-row lg:flex-col justify-between lg:justify-start items-center lg:items-start">
                <span class="block text-xs font-medium text-slate-500 dark:text-slate-400">Started On</span>
                <span class="block text-sm font-bold text-slate-800 dark:text-slate-200">{{ formatDate(user.subscription_started_at) }}</span>
              </div>
              <div v-if="user.subscription_plan !== 'free' && !isSubscriptionExpired" class="flex flex-row lg:flex-col justify-between lg:justify-start items-center lg:items-start">
                <span class="block text-xs font-medium text-slate-500 dark:text-slate-400">Renewal Date</span>
                <span class="block text-sm font-bold text-slate-800 dark:text-slate-200">{{ formatDate(user.subscription_expires_at) }}</span>
              </div>
              <div v-if="user.subscription_plan !== 'free' && !isSubscriptionExpired" class="flex flex-row lg:flex-col justify-between lg:justify-start items-center lg:items-start">
                <span class="block text-xs font-medium text-slate-500 dark:text-slate-400">Credits Remaining</span>
                <span class="block text-sm font-bold text-slate-800 dark:text-slate-200">{{ remainingCreditsDisplay }}</span>
              </div>
              <div v-if="user.subscription_plan !== 'free' && !isSubscriptionExpired" class="flex flex-row lg:flex-col justify-between lg:justify-start items-center lg:items-start">
                <span class="block text-xs font-medium text-slate-500 dark:text-slate-400">Credit Reset Date</span>
                <span class="block text-sm font-bold text-slate-800 dark:text-slate-200">{{ creditsResetDate }}</span>
              </div>
            </div>'''
content = content.replace(old_metadata, new_metadata)

content = content.replace(
    '<div class="lg:col-span-5 flex flex-col justify-between bg-slate-50/50 dark:bg-slate-800/40 p-6 rounded-2xl border border-slate-100 dark:border-slate-800/80">',
    '<div class="lg:col-span-5 flex flex-col justify-between bg-slate-50/50 dark:bg-slate-800/40 p-4 lg:p-6 rounded-xl lg:rounded-2xl border border-slate-100 dark:border-slate-800/80">'
)

# AI Credits Stats row
old_stats = '''<div class="grid grid-cols-1 sm:grid-cols-3 gap-3 sm:gap-2 border-t border-slate-105 dark:border-slate-700/60 pt-4 mt-6">
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
new_stats = '''<div class="flex flex-row justify-between lg:grid lg:grid-cols-3 gap-2 border-t border-slate-105 dark:border-slate-700/60 pt-4 mt-4 lg:mt-6">
              <div class="flex flex-col lg:items-center text-left lg:text-center">
                <span class="block text-[10px] lg:text-[9px] font-bold uppercase tracking-wider text-slate-400 dark:text-slate-500">Used</span>
                <span class="mt-0.5 block text-sm lg:text-base font-black text-slate-800 dark:text-slate-200">{{ usedCreditsDisplay }}</span>
              </div>
              <div class="flex flex-col lg:items-center text-left lg:text-center lg:border-x border-slate-105 dark:border-slate-700/60">
                <span class="block text-[10px] lg:text-[9px] font-bold uppercase tracking-wider text-slate-400 dark:text-slate-500">Remaining</span>
                <span class="mt-0.5 block text-sm lg:text-base font-black text-emerald-500 dark:text-emerald-450">{{ remainingCreditsDisplay }}</span>
              </div>
              <div class="flex flex-col lg:items-center text-left lg:text-center">
                <span class="block text-[10px] lg:text-[9px] font-bold uppercase tracking-wider text-slate-400 dark:text-slate-500">Total</span>
                <span class="mt-0.5 block text-sm lg:text-base font-black text-slate-800 dark:text-slate-200">{{ totalCreditsDisplay }}</span>
              </div>
            </div>'''
content = content.replace(old_stats, new_stats)

# 4. Plans Section
content = content.replace('<section class="space-y-8 lg:space-y-10">', '<section id="plans" class="space-y-6 lg:space-y-10 scroll-mt-16">')

content = content.replace(
    '<div \n            class="relative flex flex-col rounded-3xl border p-6 lg:p-8 shadow-sm transition-all duration-300 hover:shadow-md hover:-translate-y-1 bg-white dark:bg-slate-900/30 flex-1 justify-between"',
    '<div \n            class="relative flex flex-col rounded-2xl lg:rounded-3xl border p-5 lg:p-8 shadow-sm transition-all duration-300 hover:shadow-md hover:-translate-y-1 bg-white dark:bg-slate-900/30 flex-1 justify-between"'
)
content = content.replace(
    '<div \n            class="relative flex flex-col rounded-3xl border-2 p-6 lg:p-8 shadow-md transition-all duration-300 hover:shadow-lg hover:-translate-y-1 bg-white dark:bg-slate-900/40 flex-1 justify-between z-10 lg:scale-[1.02]"',
    '<div \n            class="relative flex flex-col rounded-2xl lg:rounded-3xl border-2 p-5 lg:p-8 shadow-md transition-all duration-300 hover:shadow-lg hover:-translate-y-1 bg-white dark:bg-slate-900/40 flex-1 justify-between z-10 lg:scale-[1.02]"'
)

# Replace list items to truncate on mobile. Since there are multiple blocks of ul, I'll use regex.
import re
content = re.sub(
    r'<ul class="mt-8 space-y-3\.5 text-left border-t border-slate-100 dark:border-slate-800 pt-6">(.*?)</ul>',
    lambda m: '<ul class="mt-4 lg:mt-8 space-y-2 lg:space-y-3.5 text-left border-t border-slate-100 dark:border-slate-800 pt-4 lg:pt-6">' +
              re.sub(r'<li class="flex items-start gap-3', r'<li class="flex items-start gap-2 lg:gap-3', m.group(1)) +
              '</ul><button class="lg:hidden w-full text-center text-xs text-brand font-bold mt-3 py-2 bg-brand/5 rounded-lg" @click="showAllFeatures = !showAllFeatures">{{ showAllFeatures ? \'Hide features\' : \'View all features\' }}</button>',
    content, flags=re.DOTALL
)
# Add conditional class to li elements > 3 in each list
def inject_hidden(match):
    items = match.group(0).split('<li')
    out = [items[0]]
    for i, item in enumerate(items[1:]):
        if i >= 4:
            out.append('<li :class="{\'hidden lg:flex\': !showAllFeatures, \'flex\': showAllFeatures}"' + item)
        else:
            out.append('<li' + item)
    return ''.join(out)

content = re.sub(r'<ul class="mt-4 lg:mt-8 space-y-2 lg:space-y-3\.5 text-left border-t border-slate-100 dark:border-slate-800 pt-4 lg:pt-6">.*?</ul>', inject_hidden, content, flags=re.DOTALL)


# 5. AI Credits Section
content = content.replace(
    '<section class="rounded-3xl border border-slate-200 bg-slate-50/50 p-5 lg:p-8 dark:border-slate-800 dark:bg-slate-900/50">',
    '<section id="credits" class="rounded-2xl lg:rounded-3xl border border-slate-200 bg-slate-50/50 p-4 lg:p-8 dark:border-slate-800 dark:bg-slate-900/50 scroll-mt-16">'
)
content = content.replace(
    '<div class="grid gap-4 md:gap-6 grid-cols-1 sm:grid-cols-2 lg:grid-cols-5">',
    '<div class="grid gap-3 lg:gap-6 grid-cols-1 sm:grid-cols-2 lg:grid-cols-5">'
)
content = content.replace(
    'class="focus:outline-none relative group flex flex-col justify-between rounded-2xl w-full bg-white p-5 lg:p-6 shadow-[0_2px_8px_rgba(15,23,42,0.03)] border border-slate-200/60 dark:bg-slate-900/40 dark:border-slate-800/80',
    'class="focus:outline-none relative group flex flex-col justify-between rounded-xl lg:rounded-2xl w-full bg-white p-4 lg:p-6 shadow-[0_2px_8px_rgba(15,23,42,0.03)] border border-slate-200/60 dark:bg-slate-900/40 dark:border-slate-800/80'
)
content = content.replace(
    '<div class="mt-8 lg:mt-10 relative overflow-hidden w-full rounded-3xl bg-gradient-to-br from-brand/5 via-purple-505/5 to-pink-500/5 border border-brand/10 dark:border-brand/20 p-6 lg:p-8 text-center max-w-3xl mx-auto shadow-sm">',
    '<div class="mt-6 lg:mt-10 relative overflow-hidden w-full rounded-2xl lg:rounded-3xl bg-gradient-to-br from-brand/5 via-purple-505/5 to-pink-500/5 border border-brand/10 dark:border-brand/20 p-5 lg:p-8 text-center max-w-3xl mx-auto shadow-sm">'
)

# 6. History Section
content = content.replace(
    'class="mt-8 w-full rounded-2xl border border-slate-200 bg-white shadow-sm dark:border-slate-800 dark:bg-slate-900/40 overflow-hidden"',
    'id="history" class="mt-6 lg:mt-8 w-full rounded-2xl border border-slate-200 bg-white shadow-sm dark:border-slate-800 dark:bg-slate-900/40 overflow-hidden scroll-mt-16"'
)
content = content.replace(
    '<h3 class="text-sm font-bold text-slate-900 dark:text-white flex items-center gap-2">\n              Credit Transaction History',
    '<button type="button" @click="showCreditHistory = !showCreditHistory" class="w-full flex items-center justify-between text-left focus:outline-none focus:ring-2 focus:ring-brand"><h3 class="text-sm font-bold text-slate-900 dark:text-white flex items-center gap-2">\n              Credit Transaction History'
)
content = content.replace(
    '<span class="rounded-full bg-slate-100 dark:bg-slate-800 px-2 py-0.5 text-[9px] font-extrabold text-slate-500 uppercase">Ledger</span>\n            </h3>\n          </div>',
    '<span class="rounded-full bg-slate-100 dark:bg-slate-800 px-2 py-0.5 text-[9px] font-extrabold text-slate-500 uppercase">Ledger</span>\n            </h3><svg class="size-5 text-slate-400 transition-transform duration-250 lg:hidden" :class="{\'rotate-180\': showCreditHistory}" viewBox="0 0 20 20" fill="currentColor"><path fill-rule="evenodd" d="M5.293 7.293a1 1 0 011.414 0L10 10.586l3.293-3.293a1 1 0 111.414 1.414l-4 4a1 1 0 01-1.414 0l-4-4a1 1 0 010-1.414z" clip-rule="evenodd" /></svg></button>\n          </div>'
)

# Wrap credit history body
content = content.replace(
    '<div v-if="loadingCredits && creditHistory.length === 0" class="p-8 text-center text-sm text-slate-500">',
    '<div class="lg:block" :class="showCreditHistory ? \'block\' : \'hidden\'">\n          <div v-if="loadingCredits && creditHistory.length === 0" class="p-8 text-center text-sm text-slate-500">'
)
content = content.replace(
    '</button>\n            </div>\n          </div>\n        </div>',
    '</button>\n            </div>\n          </div>\n          </div>\n        </div>'
)
content = content.replace(
    '<p class="text-[15px] lg:text-sm font-semibold text-slate-600 dark:text-slate-450">No credit transactions yet.</p>\n          </div>',
    '<p class="text-[15px] lg:text-sm font-semibold text-slate-600 dark:text-slate-450">No credit transactions yet.</p>\n          </div>'
)
# Make Subscription Details and History spacing smaller
content = content.replace(
    '<section v-if="user && user.subscription_plan && user.subscription_plan !== \'free\' && !isSubscriptionExpired" class="rounded-3xl border border-slate-200 bg-white shadow-sm dark:border-slate-800 dark:bg-slate-900/40 overflow-hidden transition-all duration-300">',
    '<section v-if="user && user.subscription_plan && user.subscription_plan !== \'free\' && !isSubscriptionExpired" class="mt-6 lg:mt-8 rounded-2xl lg:rounded-3xl border border-slate-200 bg-white shadow-sm dark:border-slate-800 dark:bg-slate-900/40 overflow-hidden transition-all duration-300">'
)
content = content.replace(
    '<section class="rounded-3xl border border-slate-200 bg-white shadow-sm dark:border-slate-800 dark:bg-slate-900/40 overflow-hidden transition-all duration-300">',
    '<section class="mt-6 lg:mt-8 rounded-2xl lg:rounded-3xl border border-slate-200 bg-white shadow-sm dark:border-slate-800 dark:bg-slate-900/40 overflow-hidden transition-all duration-300">'
)

content = content.replace('p-6', 'p-4 lg:p-6')
content = content.replace('p-8', 'p-5 lg:p-8')


with open(filepath, 'w') as f:
    f.write(content)

print("Done")
