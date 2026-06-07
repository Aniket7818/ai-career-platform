<template>
  <div class="min-h-screen w-full max-w-full bg-white">
    <PublicHeader />

    <section class="relative w-full max-w-full overflow-hidden bg-white">
      <div class="pointer-events-none absolute -right-32 top-0 size-96 rounded-full bg-brand/8 blur-3xl" />
      <div class="pointer-events-none absolute -left-24 bottom-0 size-72 rounded-full bg-mint/10 blur-3xl" />
      <div class="page-container relative grid items-center gap-8 py-10 sm:gap-12 sm:py-14 lg:grid-cols-[minmax(0,1fr)_minmax(0,560px)] lg:py-24">
        <div class="min-w-0 animate-fade-up">
          <p class="inline-flex rounded-full bg-brand/10 px-3 py-1 text-sm font-semibold text-brand">{{ t('landing.badge') }}</p>
          <h1 class="mt-5 max-w-3xl text-3xl font-bold leading-tight tracking-tight text-ink sm:text-4xl md:text-5xl lg:text-6xl">{{ t('landing.title') }}</h1>
          <p class="mt-5 max-w-2xl text-base leading-7 text-slate-600 sm:text-lg sm:leading-8">{{ t('landing.subtitle') }}</p>
          <div class="mt-6 flex flex-col gap-3 sm:mt-8 sm:flex-row sm:flex-wrap">
            <RouterLink class="rounded-md bg-brand px-5 py-3 text-center font-semibold text-white shadow-lg shadow-brand/25 transition hover:bg-brand/90" :to="user ? '/dashboard' : '/signup'">{{ t('landing.start') }}</RouterLink>
            <a class="rounded-md border border-slate-200 bg-white px-5 py-3 text-center font-semibold text-ink transition hover:border-slate-300 hover:bg-slate-50" href="#features">{{ t('landing.explore') }}</a>
          </div>
        </div>
        <div class="min-w-0 animate-fade-up rounded-2xl border border-slate-100 bg-gradient-to-br from-skyglass to-white p-4 shadow-panel sm:p-5">
          <div class="mb-3 flex flex-col gap-3 sm:flex-row sm:items-center sm:justify-between">
            <div class="min-w-0">
              <p class="text-[10px] font-bold uppercase tracking-widest text-brand">Live Preview</p>
              <p class="truncate text-sm font-bold text-ink">{{ activeDemo.label }}</p>
            </div>
            <div class="flex flex-wrap gap-1.5">
              <button
                v-for="(demo, index) in demos"
                :key="demo.label"
                class="rounded-full px-2.5 py-1 text-[10px] font-bold uppercase tracking-wider transition"
                :class="index === activeIndex ? 'bg-brand text-white' : 'bg-slate-100 text-slate-500 hover:bg-slate-200'"
                @click="goToSlide(index)"
              >
                {{ demo.short }}
              </button>
            </div>
          </div>
          <div class="relative overflow-hidden rounded-xl" @mouseenter="pauseCarousel" @mouseleave="resumeCarousel">
            <Transition name="slide" mode="out-in">
              <ResumePreview
                :key="activeDemo.label"
                :title="activeDemo.title"
                :content="activeDemo.content"
                :template-id="activeDemo.templateId"
              />
            </Transition>
          </div>
        </div>
      </div>
    </section>

    <section class="w-full max-w-full border-y border-slate-100 bg-white py-10 sm:py-12">
      <div class="page-container grid gap-8 sm:grid-cols-2 lg:grid-cols-4">
        <div v-for="stat in stats" :key="stat.label" class="text-center">
          <p class="text-3xl font-bold text-brand lg:text-4xl">{{ stat.value }}</p>
          <p class="mt-1 text-sm font-medium text-slate-500">{{ stat.label }}</p>
        </div>
      </div>
    </section>

    <section id="features" class="w-full max-w-full bg-slate-50 py-14 sm:py-20">
      <div class="page-container">
        <div class="max-w-2xl">
          <h2 class="text-3xl font-bold text-ink lg:text-4xl">{{ t('landing.featuresTitle') }}</h2>
          <p class="mt-4 text-lg leading-8 text-slate-600">{{ t('landing.featuresSubtitle') }}</p>
        </div>
        <div class="mt-12 grid gap-6 md:grid-cols-3">
          <div
            v-for="item in features"
            :key="item.title"
            class="group rounded-2xl border border-slate-100 bg-white p-7 shadow-panel transition hover:-translate-y-1 hover:border-brand/20 hover:shadow-glow"
          >
            <div class="grid size-12 place-items-center rounded-xl bg-brand/10 text-brand transition group-hover:bg-brand group-hover:text-white">
              <svg class="size-6" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.75" stroke-linecap="round" stroke-linejoin="round">
                <path v-if="item.icon === 'resume'" d="M14 2H6a2 2 0 00-2 2v16a2 2 0 002 2h12a2 2 0 002-2V8z M14 2v6h6 M16 13H8 M16 17H8" />
                <path v-else-if="item.icon === 'shield'" d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z" />
                <template v-else>
                  <path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z" /><circle cx="12" cy="12" r="3" />
                </template>
              </svg>
            </div>
            <p class="mt-5 text-lg font-bold text-ink">{{ item.title }}</p>
            <p class="mt-3 text-sm leading-7 text-slate-500">{{ item.description }}</p>
          </div>
        </div>
        <div class="mt-10 text-center">
          <RouterLink class="inline-flex rounded-md bg-brand px-5 py-3 font-semibold text-white shadow-lg shadow-brand/20 transition hover:bg-brand/90" to="/coming-soon">{{ t('nav.comingSoon') }} →</RouterLink>
        </div>
      </div>
    </section>

    <section id="pricing" class="w-full max-w-full bg-white py-14 sm:py-20">
      <div class="page-container">
      <div class="text-center">
        <h2 class="text-3xl font-bold text-ink lg:text-4xl">{{ t('landing.pricingTitle') }}</h2>
        <p class="mx-auto mt-4 max-w-2xl text-lg text-slate-600">{{ t('landing.pricingSubtitle') }}</p>
      </div>
      <div class="mt-12 grid gap-6 lg:grid-cols-3">
        <div
          v-for="plan in plans"
          :key="plan.name"
          class="relative rounded-2xl border p-7 shadow-panel transition hover:-translate-y-1"
          :class="plan.highlighted ? 'border-brand bg-gradient-to-b from-brand/5 to-white ring-2 ring-brand/20' : 'border-slate-200 bg-white'"
        >
          <span v-if="plan.highlighted" class="absolute -top-3 left-1/2 -translate-x-1/2 rounded-full bg-brand px-3 py-1 text-xs font-semibold text-white">Most popular</span>
          <p class="text-lg font-bold text-ink">{{ plan.name }}</p>
          <div class="mt-3 flex items-baseline gap-1">
            <span class="text-4xl font-bold text-ink">{{ plan.price }}</span>
            <span class="text-slate-500">{{ plan.period }}</span>
          </div>
          <p class="mt-3 text-sm text-slate-500">{{ plan.description }}</p>
          <ul class="mt-6 space-y-3">
            <li v-for="feature in plan.features" :key="feature" class="flex items-center gap-2 text-sm text-slate-600">
              <svg class="size-4 shrink-0 text-mint" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M20 6L9 17l-5-5" /></svg>
              {{ feature }}
            </li>
          </ul>
          <button
            class="mt-8 block rounded-md px-5 py-3 text-center font-semibold transition"
            :class="plan.highlighted ? 'bg-brand text-white shadow-lg shadow-brand/20 hover:bg-brand/90' : 'border border-slate-200 text-ink hover:bg-slate-50'"
            @click="selectPlan(plan)"
          >
            {{ plan.id === 'free' ? t('landing.start') : 'Buy plan' }}
          </button>
        </div>
      </div>
      </div>
    </section>

    <section class="w-full max-w-full bg-ink py-14 text-white sm:py-20">
      <div class="page-container">
        <div class="grid gap-8 lg:grid-cols-[minmax(0,1fr)_auto] lg:items-center">
          <div>
            <p class="text-sm font-semibold uppercase tracking-wider text-mint">{{ t('nav.comingSoon') }}</p>
            <h2 class="mt-3 text-3xl font-bold lg:text-4xl">{{ t('comingSoon.title') }}</h2>
            <p class="mt-4 max-w-2xl text-lg leading-8 text-slate-300">{{ t('comingSoon.subtitle') }}</p>
          </div>
          <RouterLink class="inline-flex w-full justify-center rounded-md bg-brand px-6 py-3 font-semibold text-white shadow-lg shadow-brand/25 transition hover:bg-brand/90 sm:w-auto" to="/coming-soon">{{ t('comingSoon.notifyMe') }}</RouterLink>
        </div>
      </div>
    </section>

    <section class="w-full max-w-full bg-slate-50 py-14 sm:py-20">
      <div class="page-container">
        <div class="text-center">
          <h2 class="text-3xl font-bold text-ink lg:text-4xl">{{ t('landing.testimonialsTitle') }}</h2>
          <p class="mx-auto mt-4 max-w-2xl text-lg text-slate-600">{{ t('landing.testimonialsSubtitle') }}</p>
        </div>
        <div class="mt-12 grid gap-6 md:grid-cols-3">
          <div v-for="item in testimonials" :key="item.name" class="rounded-2xl border border-slate-100 bg-white p-7 shadow-panel">
            <svg class="size-8 text-brand/30" viewBox="0 0 24 24" fill="currentColor"><path d="M14.017 21v-7.391c0-5.704 3.731-9.57 8.983-10.609l.995 2.151c-2.432.917-3.995 3.638-3.995 5.849h4v10h-9.983zm-14.017 0v-7.391c0-5.704 3.748-9.57 9-10.609l.996 2.151c-2.433.917-3.996 3.638-3.996 5.849h3.983v10h-9.983z" /></svg>
            <p class="mt-4 text-sm leading-7 text-slate-600">"{{ item.quote }}"</p>
            <div class="mt-6 flex items-center gap-3 border-t border-slate-100 pt-5">
              <div class="grid size-10 place-items-center rounded-full bg-brand/10 text-sm font-bold text-brand">{{ item.name.charAt(0) }}</div>
              <div>
                <p class="text-sm font-semibold text-ink">{{ item.name }}</p>
                <p class="text-xs text-slate-500">{{ item.role }}</p>
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>

    <section class="relative w-full max-w-full overflow-hidden py-14 sm:py-20">
      <div class="pointer-events-none absolute inset-0 bg-gradient-to-br from-brand/5 via-skyglass to-mint/5" />
      <div class="page-container relative max-w-3xl text-center lg:mx-auto">
        <h2 class="text-3xl font-bold text-ink lg:text-4xl">{{ t('landing.ctaTitle') }}</h2>
        <p class="mx-auto mt-4 max-w-xl text-lg text-slate-600">{{ t('landing.ctaBody') }}</p>
        <RouterLink class="mt-8 inline-flex rounded-md bg-brand px-6 py-3 font-semibold text-white shadow-lg shadow-brand/25 transition hover:bg-brand/90" :to="user ? '/dashboard' : '/signup'">{{ t('landing.ctaButton') }}</RouterLink>
      </div>
    </section>

    <SiteFooter />

    <Teleport to="body">
      <div v-if="selectedPlan" class="fixed inset-0 z-50 grid place-items-center bg-ink/70 p-5 backdrop-blur" @click.self="selectedPlan = null">
        <div class="w-full max-w-md rounded-xl bg-white p-6 shadow-2xl">
          <h2 class="text-xl font-bold text-ink">Confirm purchase</h2>
          <p class="mt-2 text-sm text-slate-600">You are buying {{ selectedPlan.name }} for {{ selectedPlan.price }}{{ selectedPlan.period }}. The active plan will replace any previous plan and expire after one month.</p>
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
  </div>
</template>

<script setup>
import { computed, onMounted, onUnmounted, ref } from 'vue'
import { useRouter } from 'vue-router'
import PublicHeader from '../components/layout/PublicHeader.vue'
import SiteFooter from '../components/layout/SiteFooter.vue'
import ResumePreview from './resumes/ResumePreview.vue'
import { useStore } from 'vuex'
import { t } from '../utils/i18n'
import { paymentService } from '../services/paymentService'
import { toast } from '../utils/toast'

const store = useStore()
const router = useRouter()
const user = computed(() => store.state.auth.user)
const stats = t('landing.stats')
const features = t('landing.featureCards')
const plans = t('landing.pricingCards')
const testimonials = t('landing.testimonials')

const activeIndex = ref(0)
const selectedPlan = ref(null)
const acceptedPolicies = ref(false)
const purchasing = ref(false)
let timer
let paused = false

const goToSlide = (index) => {
  activeIndex.value = index
}

const pauseCarousel = () => { paused = true }
const resumeCarousel = () => { paused = false }

const selectPlan = (plan) => {
  if (plan.id === 'free') {
    router.push(user.value ? '/dashboard' : '/signup')
    return
  }
  if (!user.value) {
    router.push('/signup')
    return
  }
  selectedPlan.value = plan
  acceptedPolicies.value = false
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
    router.push('/dashboard')
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

const demos = [
  {
    label: 'Modern Template',
    short: 'Modern',
    title: 'John Doe',
    templateId: 'modern',
    content: {
      personal: { fullName: 'John Doe', headline: 'Senior Product Manager', email: 'john.doe@example.com', phone: '+91 98765 43210', location: 'Bengaluru, India', linkedin: 'linkedin.com/in/johndoe', summary: 'Product leader with 8 years of experience launching B2B SaaS platforms, improving activation, and aligning engineering, design, and revenue teams around measurable customer outcomes.' },
      education: { school: 'MBA, Indian School of Business' },
      experience: { role: 'Senior Product Manager', company: 'CloudWorks Labs - Led roadmap strategy for analytics products serving 40K monthly users and improved trial-to-paid conversion by 18%.' },
      projects: { projectName: 'Self-serve onboarding revamp, usage-based billing launch, enterprise reporting suite' },
      skills: { skillList: 'Product Strategy, Roadmapping, SQL, Analytics, A/B Testing, Stakeholder Management, SaaS Pricing' },
      certifications: { certName: 'Certified Scrum Product Owner, Product Analytics Certification' }
    }
  },
  {
    label: 'Professional Template',
    short: 'Pro',
    title: 'Priya Sharma',
    templateId: 'professional',
    content: {
      personal: { fullName: 'Priya Sharma', headline: 'Data Analyst', email: 'priya.sharma@example.com', phone: '+91 99887 76655', location: 'Pune, India', summary: 'Analytical problem solver specializing in dashboard automation, revenue reporting, and customer insights for fast-growing digital businesses.' },
      education: { school: 'B.Sc. Statistics, Fergusson College' },
      experience: { role: 'Data Analyst', company: 'FinEdge - Built automated KPI reporting in Power BI and reduced weekly manual reporting effort by 12 hours.' },
      projects: { projectName: 'Customer churn model, revenue cohort dashboard, marketing attribution tracker' },
      skills: { skillList: 'SQL, Python, Power BI, Excel, Statistics, Data Cleaning, Cohort Analysis' },
      certifications: { certName: 'Google Data Analytics Professional Certificate' }
    }
  },
  {
    label: 'Minimal Template',
    short: 'Minimal',
    title: 'Arjun Mehta',
    templateId: 'minimal',
    content: {
      personal: { fullName: 'Arjun Mehta', headline: 'Full Stack Engineer', email: 'arjun.mehta@example.com', phone: '+91 91234 56780', location: 'Hyderabad, India', github: 'github.com/arjunmehta', summary: 'Full stack engineer focused on reliable Rails and Vue applications, clean APIs, and performance improvements that make everyday product workflows faster.' },
      education: { school: 'B.Tech Computer Science, VIT' },
      experience: { role: 'Full Stack Engineer', company: 'Northstar AI - Shipped secure resume builder workflows, background jobs, and responsive Vue interfaces.' },
      projects: { projectName: 'AI resume parser, admin analytics console, PDF export engine' },
      skills: { skillList: 'Ruby on Rails, Vue, PostgreSQL, Redis, Tailwind CSS, REST APIs, Testing' },
      certifications: { certName: 'AWS Cloud Practitioner' }
    }
  },
  {
    label: 'Executive Template',
    short: 'Exec',
    title: 'Sarah Mitchell',
    templateId: 'executive',
    content: {
      personal: { fullName: 'Sarah Mitchell', headline: 'VP of Engineering', email: 'sarah.mitchell@example.com', phone: '+91 98100 22445', location: 'Mumbai, India', linkedin: 'linkedin.com/in/sarahmitchell', summary: 'Engineering executive with 14 years leading distributed teams, scaling SaaS platforms, and delivering reliable products for enterprise customers across India and global markets.' },
      education: { school: 'M.Tech Software Systems, BITS Pilani' },
      experience: { role: 'VP of Engineering', company: 'ScaleForge — Led 45 engineers across platform, data, and product teams while improving release reliability and reducing incident volume by 32%.' },
      projects: { projectName: 'Platform modernization, observability rollout, multi-region deployment strategy' },
      skills: { skillList: 'Engineering Leadership, Hiring, Architecture, OKRs, Budgeting, Stakeholder Management, Cloud Strategy' },
      certifications: { certName: 'Executive Leadership Program, PMP' }
    }
  },
  {
    label: 'Fresher Template',
    short: 'Fresher',
    title: 'Rohan Kapoor',
    templateId: 'fresher',
    content: {
      personal: { fullName: 'Rohan Kapoor', headline: 'Computer Science Graduate', email: 'rohan.kapoor@example.com', phone: '+91 90001 11223', location: 'Delhi, India', github: 'github.com/rohankapoor', portfolio: 'rohankapoor.dev', summary: 'Motivated fresher with strong fundamentals in web development, data structures, and collaborative project delivery. Seeking an entry-level software role to build reliable products and grow with a high-performing team.' },
      education: { school: 'B.Tech Computer Science, DTU — CGPA 8.6, Dean\'s List 2024' },
      experience: { role: 'Software Intern', company: 'BrightApps — Built Vue components, REST integrations, and unit tests for an internal HR dashboard.' },
      projects: { projectName: 'Campus placement tracker, expense split app, collaborative task board' },
      skills: { skillList: 'JavaScript, Vue, React, Python, DSA, Git, SQL, REST APIs, Team Collaboration' },
      certifications: { certName: 'Meta Front-End Developer Certificate' }
    }
  }
]

const activeDemo = computed(() => demos[activeIndex.value])

onMounted(() => {
  timer = window.setInterval(() => {
    if (!paused) activeIndex.value = (activeIndex.value + 1) % demos.length
  }, 4500)
})

onUnmounted(() => window.clearInterval(timer))
</script>

<style scoped>
.slide-enter-active,
.slide-leave-active {
  transition: all 0.45s ease;
}
.slide-enter-from {
  opacity: 0;
  transform: translateX(24px);
}
.slide-leave-to {
  opacity: 0;
  transform: translateX(-24px);
}
</style>
