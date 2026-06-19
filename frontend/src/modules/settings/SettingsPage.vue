<template>
  <AppShell>
    <section class="mx-auto max-w-3xl space-y-6">
      <div>
        <p class="text-sm font-semibold text-brand">{{ t('nav.workspace') }}</p>
        <h1 class="mt-1 text-2xl font-bold text-ink sm:text-3xl">{{ t('settings.title') }}</h1>
        <p class="mt-2 text-sm text-slate-500">{{ t('settings.subtitle') }}</p>
      </div>

      <div class="space-y-4">
        <section class="rounded-2xl border border-slate-100 bg-white p-6 shadow-panel">
          <h2 class="text-lg font-bold text-ink">{{ t('settings.account') }}</h2>
          <div class="mt-4 grid gap-4 sm:grid-cols-2">
            <div>
              <label>{{ t('profile.email') }}</label>
              <input :value="user?.email" disabled class="bg-slate-50 text-slate-500" />
            </div>
            <div>
              <label>{{ t('auth.username') }}</label>
              <input :value="user?.username" disabled class="bg-slate-50 text-slate-500" />
            </div>
          </div>
          <div class="mt-4 flex gap-4">
            <RouterLink class="inline-flex text-sm font-semibold text-brand" to="/forgot-password">Change Password</RouterLink>
          </div>
        </section>

        <!-- Subscription / Plans Section -->
        <section class="rounded-2xl border border-slate-100 bg-white p-6 shadow-panel">
          <h2 class="text-lg font-bold text-ink">Subscription Plan</h2>
          <p class="mt-1 text-sm text-slate-500">Your current plan and available upgrade options.</p>

          <div class="mt-6 grid gap-4">
            <div
              v-for="plan in plans"
              :key="plan.id"
              class="relative flex flex-col gap-4 rounded-xl border p-4 transition sm:flex-row sm:items-start sm:justify-between sm:p-5"
              :class="{
                'border-brand/30 bg-brand/5 ring-1 ring-brand/20': plan.state === 'active',
                'border-slate-200 bg-white opacity-60': plan.state === 'deactivated',
                'border-slate-200 bg-white hover:border-brand/30 hover:bg-brand/5': plan.state === 'upgrade'
              }"
            >
              <!-- Active badge -->
              <div v-if="plan.state === 'active'" class="absolute -top-2.5 right-4 rounded-full bg-brand px-3 py-0.5 text-xs font-bold text-white shadow-sm">
                Activated
              </div>

              <div class="flex-1">
                <div class="flex items-center gap-3">
                  <h3 class="text-lg font-bold text-ink" :class="{ 'text-slate-400': plan.state === 'deactivated' }">{{ plan.name }}</h3>
                  <span class="rounded-md bg-slate-100 px-2 py-0.5 text-xs font-semibold" :class="plan.state === 'deactivated' ? 'text-slate-400' : 'text-slate-600'">{{ plan.price }}</span>
                </div>
                <p class="mt-1 text-sm" :class="plan.state === 'deactivated' ? 'text-slate-400' : 'text-slate-500'">{{ plan.description }}</p>

                <!-- Active plan details -->
                <div v-if="plan.state === 'active'" class="mt-3 space-y-1.5">
                  <div class="flex items-center gap-2 text-sm">
                    <svg class="size-4 text-emerald-500" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                      <path d="M22 11.08V12a10 10 0 11-5.93-9.14" /><polyline points="22 4 12 14.01 9 11.01" />
                    </svg>
                    <span class="font-medium text-emerald-700">Active</span>
                  </div>
                  <div v-if="user?.subscription_started_at" class="flex items-center gap-2 text-sm text-slate-600">
                    <svg class="size-4 text-slate-400" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                      <rect x="3" y="4" width="18" height="18" rx="2" ry="2" /><line x1="16" y1="2" x2="16" y2="6" /><line x1="8" y1="2" x2="8" y2="6" /><line x1="3" y1="10" x2="21" y2="10" />
                    </svg>
                    <span>Started: <span class="font-medium text-ink">{{ formatDate(user.subscription_started_at) }}</span></span>
                  </div>
                  <div v-if="user?.subscription_expires_at" class="flex items-center gap-2 text-sm text-slate-600">
                    <svg class="size-4 text-slate-400" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                      <circle cx="12" cy="12" r="10" /><polyline points="12 6 12 12 16 14" />
                    </svg>
                    <span>Expires: <span class="font-medium text-ink">{{ formatDate(user.subscription_expires_at) }}</span></span>
                  </div>
                  <div class="flex items-center gap-2 text-sm text-slate-600">
                    <svg class="size-4 text-slate-400" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                      <circle cx="12" cy="12" r="10" /><polyline points="12 6 12 12 16 14" />
                    </svg>
                    <span>Time remaining: <span class="font-semibold text-ink">{{ formatRemaining(user?.subscription_seconds_remaining || 0) }}</span></span>
                  </div>
                  <div class="flex items-center gap-2 text-sm text-slate-600">
                    <svg class="size-4 text-slate-400" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                      <path d="M14 2H6a2 2 0 00-2 2v16a2 2 0 002 2h12a2 2 0 002-2V8z" /><polyline points="14 2 14 8 20 8" />
                    </svg>
                    <span>Downloads: <span class="font-medium text-ink">{{ plan.id === 'free' ? `${freeDownloads} remaining` : 'Unlimited' }}</span></span>
                  </div>

                  <!-- Plan-specific features -->
                  <div class="mt-3 rounded-lg border border-slate-200 bg-white p-3">
                    <p class="text-xs font-semibold uppercase tracking-wider text-slate-500">Plan Features</p>
                    <ul class="mt-2 space-y-1">
                      <li v-for="feature in plan.features" :key="feature" class="flex items-center gap-2 text-sm text-slate-600">
                        <svg class="size-3.5 shrink-0 text-emerald-500" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5">
                          <polyline points="20 6 9 17 4 12" />
                        </svg>
                        {{ feature }}
                      </li>
                    </ul>
                  </div>
                </div>

                <!-- Deactivated plan details -->
                <div v-if="plan.state === 'deactivated'" class="mt-3">
                  <p class="text-sm text-slate-400">This plan is not currently active on your account.</p>
                  <ul class="mt-2 space-y-1">
                    <li v-for="feature in plan.features" :key="feature" class="flex items-center gap-2 text-sm text-slate-400">
                      <svg class="size-3.5 shrink-0 text-slate-300" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5">
                        <polyline points="20 6 9 17 4 12" />
                      </svg>
                      {{ feature }}
                    </li>
                  </ul>
                </div>
              </div>

              <!-- Action button -->
              <div class="flex shrink-0 items-start sm:ml-4">
                <button
                  v-if="plan.state === 'active'"
                  disabled
                  class="w-full cursor-not-allowed rounded-xl bg-brand/10 px-4 py-2 text-sm font-semibold text-brand/50 sm:w-auto"
                >
                  Current Plan
                </button>
                <button
                  v-else-if="plan.state === 'deactivated'"
                  disabled
                  class="w-full cursor-not-allowed rounded-xl border border-slate-200 bg-slate-50 px-4 py-2 text-sm font-semibold text-slate-300 sm:w-auto"
                >
                  Deactivated
                </button>
                <button
                  v-else
                  class="w-full rounded-xl bg-brand px-4 py-2 text-sm font-semibold text-white shadow-lg shadow-brand/20 hover:bg-brand/90 sm:w-auto"
                  @click="selectPlan(plan)"
                >
                  Upgrade
                </button>
              </div>
            </div>
          </div>
        </section>

        <section class="rounded-2xl border border-slate-100 bg-white p-6 shadow-panel">
          <h2 class="text-lg font-bold text-ink">{{ t('settings.preferences') }}</h2>
          <p class="mt-2 text-sm text-slate-500">{{ t('settings.preferencesBody') }}</p>
          <div class="mt-4 space-y-3">
            <label class="flex items-center justify-between rounded-xl border border-slate-100 p-4">
              <span class="text-sm font-medium text-ink">{{ t('settings.emailUpdates') }}</span>
              <input type="checkbox" checked class="size-4 rounded border-slate-300 text-brand focus:ring-brand/20" />
            </label>
            <label class="flex items-center justify-between rounded-xl border border-slate-100 p-4">
              <span class="text-sm font-medium text-ink">{{ t('settings.productNews') }}</span>
              <input type="checkbox" checked class="size-4 rounded border-slate-300 text-brand focus:ring-brand/20" />
            </label>
          </div>
        </section>

        <section class="rounded-2xl border border-slate-100 bg-white p-6 shadow-panel">
          <h2 class="text-lg font-bold text-ink">{{ t('settings.workspace') }}</h2>
          <p class="mt-2 text-sm text-slate-500">{{ t('settings.workspaceBody') }}</p>
          <div class="mt-4 flex flex-wrap gap-3">
            <RouterLink class="rounded-xl bg-brand px-4 py-2.5 text-sm font-semibold text-white" to="/profile">{{ t('nav.profile') }}</RouterLink>
            <RouterLink class="rounded-xl border border-slate-200 px-4 py-2.5 text-sm font-semibold text-ink" to="/resumes">{{ t('nav.resumes') }}</RouterLink>
          </div>
        </section>
      </div>
    </section>

    <!-- Purchase Modal -->
    <Teleport to="body">
      <div v-if="selectedPlan" class="fixed inset-0 z-50 grid place-items-center bg-ink/70 p-5 backdrop-blur" @click.self="selectedPlan = null">
        <div class="w-full max-w-md rounded-xl bg-white p-6 shadow-2xl">
          <h2 class="text-xl font-bold text-ink">Confirm purchase</h2>
          <p class="mt-2 text-sm text-slate-600">You are buying {{ selectedPlan.name }} for {{ selectedPlan.price }}. The active plan will replace any previous plan and expire after one month.</p>
          <div class="mt-5 rounded-lg border border-slate-200 bg-slate-50 p-4 text-center">
            <p class="text-xs font-bold uppercase tracking-wider text-slate-500">Payment QR / Razorpay Checkout</p>
            <div class="mx-auto mt-3 grid size-28 place-items-center rounded-md bg-white text-3xl font-bold text-brand shadow-inner">₹</div>
            <p class="mt-3 text-xs text-slate-500">Razorpay checkout opens when keys are configured. Local test mode can activate after confirmation.</p>
          </div>
          <label class="mt-5 flex items-start gap-3 text-sm text-slate-600">
            <input v-model="acceptedPolicies" class="mt-1" type="checkbox" />
            <span>I agree to the <RouterLink class="text-brand" to="/privacy">Privacy Policy</RouterLink>, <RouterLink class="text-brand" to="/terms">Terms</RouterLink>, <RouterLink class="text-brand" to="/refund-policy">Refund Policy</RouterLink>, and <RouterLink class="text-brand" to="/shipping-policy">Shipping Policy</RouterLink>.</span>
          </label>
          <div class="mt-6 flex gap-3">
            <button class="flex-1 rounded-md border border-slate-200 px-4 py-3 font-semibold text-ink" @click="selectedPlan = null">Cancel</button>
            <button class="flex-1 rounded-md bg-brand px-4 py-3 font-semibold text-white disabled:opacity-50" :disabled="!acceptedPolicies || purchasing" @click="purchasePlan">
              {{ purchasing ? 'Processing...' : 'Pay now' }}
            </button>
          </div>
        </div>
      </div>
    </Teleport>
  </AppShell>
</template>

<script setup>
import { computed, onMounted, ref } from 'vue'
import { useStore } from 'vuex'
import AppShell from '../../components/layout/AppShell.vue'
import { t } from '../../utils/i18n'
import { paymentService } from '../../services/paymentService'
import { toast } from '../../utils/toast'

const store = useStore()
onMounted(() => store.dispatch('auth/fetchMe'))
const user = computed(() => store.state.auth.user)

const selectedPlan = ref(null)
const acceptedPolicies = ref(false)
const purchasing = ref(false)

const PLAN_ORDER = ['free', 'pro', 'team']

const formatDate = (value) => {
  if (!value) return ''
  return new Date(value).toLocaleDateString(undefined, {
    year: 'numeric',
    month: 'long',
    day: 'numeric',
    hour: '2-digit',
    minute: '2-digit'
  })
}

const formatRemaining = (seconds = 0) => {
  const days = Math.floor(seconds / 86400)
  const hours = Math.floor((seconds % 86400) / 3600)
  const minutes = Math.floor((seconds % 3600) / 60)
  return `${days}d ${hours}h ${minutes}m`
}

const freeDownloads = computed(() => user.value?.free_downloads_remaining ?? 3)

const plans = computed(() => {
  const currentPlan = user.value?.subscription_plan || 'free'
  const currentIndex = PLAN_ORDER.indexOf(currentPlan)

  return [
    {
      id: 'free',
      name: 'Starter',
      price: 'Free',
      description: 'Perfect for students and first-time job seekers.',
      state: currentPlan === 'free' ? 'active' : 'deactivated',
      features: ['3 free PDF downloads', 'Unlimited edits to saved drafts', 'Live preview builder', 'Profile management']
    },
    {
      id: 'pro',
      name: 'Pro',
      price: '₹99/month',
      description: 'For professionals who want more power and polish.',
      state: currentPlan === 'pro' ? 'active' : currentIndex < PLAN_ORDER.indexOf('pro') ? 'upgrade' : 'deactivated',
      features: ['Unlimited PDF downloads', 'Priority support', 'Advanced templates', 'AI features (coming soon)']
    },
    {
      id: 'team',
      name: 'Team',
      price: '₹199/month',
      description: 'Built for career centers, bootcamps, and mentors.',
      state: currentPlan === 'team' ? 'active' : currentIndex < PLAN_ORDER.indexOf('team') ? 'upgrade' : 'deactivated',
      features: ['Everything in Pro', 'Team dashboard', 'Bulk resume review', 'Custom branding']
    }
  ]
})

const selectPlan = (plan) => {
  selectedPlan.value = plan
  acceptedPolicies.value = false
  purchasing.value = false
}

const purchasePlan = async () => {
  purchasing.value = true
  try {
    const { data } = await paymentService.create(selectedPlan.value.id)
    if (data.razorpay_key_id && window.Razorpay) {
      await openRazorpay(data)
    } else {
      await paymentService.verify({
        razorpay_order_id: data.order.razorpay_order_id,
        razorpay_payment_id: `local_${Date.now()}`,
        razorpay_signature: ''
      })
    }
    await store.dispatch('auth/fetchMe')
    toast.success('Plan activated', `${selectedPlan.value.name} is active for one month.`)
    selectedPlan.value = null
  } catch (error) {
    toast.error('Payment failed', error.response?.data?.error || 'Please try again.')
  } finally {
    purchasing.value = false
  }
}

const openRazorpay = (data) => new Promise((resolve, reject) => {
  const checkout = new window.Razorpay({
    key: data.razorpay_key_id,
    amount: data.order.amount_paise,
    currency: data.order.currency,
    name: 'CareerAI',
    description: `${selectedPlan.value.name} monthly subscription`,
    order_id: data.order.razorpay_order_id,
    prefill: { name: user.value?.full_name, email: user.value?.email },
    handler: async (response) => {
      try {
        await paymentService.verify(response)
        resolve()
      } catch (error) {
        reject(error)
      }
    },
    modal: { ondismiss: () => reject(new Error('Payment cancelled.')) },
    theme: { color: '#6d4aff' }
  })
  checkout.open()
})

onMounted(() => {
  if (!document.querySelector('script[src="https://checkout.razorpay.com/v1/checkout.js"]')) {
    const script = document.createElement('script')
    script.src = 'https://checkout.razorpay.com/v1/checkout.js'
    script.async = true
    document.head.appendChild(script)
  }
})
</script>