<template>
 <div class="min-h-screen w-full max-w-full bg-surface">
 <PublicHeader />

  <section class="relative w-full max-w-full overflow-hidden bg-gradient-to-b from-background to-surface">
    <div class="pointer-events-none absolute -right-32 top-0 size-96 rounded-full bg-brand/8 blur-3xl" />
    <div class="pointer-events-none absolute -left-24 bottom-0 size-72 rounded-full bg-mint/10 blur-3xl" />
    <div class="page-container relative grid items-center gap-8 pt-16 pb-12 sm:gap-12 sm:pt-20 sm:pb-16 lg:grid-cols-[minmax(0,1.1fr)_minmax(0,520px)] lg:pt-24 lg:pb-20">
      <div class="min-w-0 animate-fade-up">
        <p class="inline-flex rounded-full bg-brand/10 px-3 py-1 text-sm font-semibold text-brand">{{ t('landing.badge') }}</p>
        <h1 class="mt-6 max-w-3xl text-4xl font-extrabold leading-tight tracking-tight text-txt-primary sm:text-5xl md:text-6xl">{{ t('landing.title') }}</h1>
        <p class="mt-6 max-w-2xl text-lg leading-8 text-txt-secondary sm:text-xl sm:leading-9">{{ t('landing.subtitle') }}</p>
        <div class="mt-8 flex flex-col gap-4 sm:flex-row sm:flex-wrap">
          <RouterLink class="inline-flex items-center justify-center gap-2 rounded-full bg-gradient-to-r from-brand to-indigo-600 px-6 py-3.5 text-center font-bold text-white shadow-lg shadow-brand/25 transition-all hover:scale-105 hover:shadow-brand/40" :to="user ? '/dashboard' : '/signup'">
            {{ t('landing.start') }}
            <svg class="size-5" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2.5"><path stroke-linecap="round" stroke-linejoin="round" d="M13 7l5 5m0 0l-5 5m5-5H6" /></svg>
          </RouterLink>
          <a class="inline-flex items-center justify-center rounded-full border-2 border-border bg-surface px-6 py-3.5 text-center font-bold text-txt-primary transition-all hover:border-border-hover hover:bg-background" href="#features">{{ t('landing.explore') }}</a>
        </div>
      </div>
      <div class="min-w-0 animate-fade-up rounded-2xl border border-border bg-gradient-to-br from-brand/5 to-surface p-4 shadow-panel sm:p-5 transition-transform hover:-translate-y-2 duration-500 hover:shadow-2xl">
        <div class="mb-3 flex flex-col gap-3 sm:flex-row sm:items-center sm:justify-between">
          <div class="min-w-0">
            <p class="text-[10px] font-bold uppercase tracking-widest text-brand">Live Preview</p>
            <p class="truncate text-sm font-bold text-txt-primary">{{ activeDemo.label }}</p>
          </div>
          <div class="flex flex-wrap gap-1.5">
            <button
              v-for="(demo, index) in demos"
              :key="demo.label"
              class="rounded-full px-2.5 py-1 text-[10px] font-bold uppercase tracking-wider transition"
              :class="index === activeIndex ? 'bg-brand text-white' : 'bg-surface-hover text-txt-muted hover:bg-surface-hover'"
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
              :zoom="previewZoom"
            />
          </Transition>
        </div>
      </div>
    </div>
  </section>

  <section class="w-full max-w-full border-y border-border bg-surface py-12 sm:py-16 relative z-10">
    <div class="page-container grid gap-8 sm:grid-cols-2 lg:grid-cols-4">
      <div v-for="stat in stats" :key="stat.label" class="text-center group p-6 rounded-2xl hover:bg-background transition duration-300">
        <p class="text-4xl font-extrabold text-brand lg:text-5xl transition-transform duration-300 group-hover:scale-110 group-hover:-translate-y-1">{{ stat.value }}</p>
        <p class="mt-3 text-sm font-semibold uppercase tracking-wide text-txt-muted">{{ stat.label }}</p>
      </div>
    </div>
  </section>

  <section id="features" class="w-full max-w-full bg-background py-14 sm:py-20">
    <div class="page-container">
      <div class="max-w-2xl">
        <h2 class="text-3xl font-bold text-txt-primary lg:text-4xl">{{ t('landing.featuresTitle') }}</h2>
        <p class="mt-4 text-lg leading-8 text-txt-secondary">{{ t('landing.featuresSubtitle') }}</p>
      </div>
      <div class="mt-12 grid gap-6 md:grid-cols-3">
        <div
          v-for="(item, idx) in features"
          :key="item.title"
          class="group flex h-full flex-col rounded-2xl border border-border bg-surface p-7 shadow-panel transition-all duration-500 hover:-translate-y-2 hover:border-brand/30 hover:shadow-xl"
          :style="{ transitionDelay: `${idx * 50}ms` }"
        >
          <div class="grid size-14 place-items-center rounded-xl bg-brand/10 text-brand transition-all duration-300 group-hover:scale-110 group-hover:bg-brand group-hover:text-white group-hover:shadow-lg group-hover:shadow-brand/30">
            <svg class="size-7" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.75" stroke-linecap="round" stroke-linejoin="round">
              <path v-if="item.icon === 'resume'" d="M14 2H6a2 2 0 00-2 2v16a2 2 0 002 2h12a2 2 0 002-2V8z M14 2v6h6 M16 13H8 M16 17H8" />
              <path v-else-if="item.icon === 'shield'" d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z" />
              <template v-else>
                <path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z" /><circle cx="12" cy="12" r="3" />
              </template>
            </svg>
          </div>
          <p class="mt-6 text-xl font-bold text-txt-primary">{{ item.title }}</p>
          <p class="mt-3 text-base leading-7 text-txt-muted flex-1">{{ item.description }}</p>
        </div>
      </div>
      <div class="mt-10 text-center">
        <RouterLink class="inline-flex rounded-md bg-brand px-5 py-3 font-semibold text-white shadow-lg shadow-brand/20 transition hover:bg-brand/90" to="/coming-soon">{{ t('nav.comingSoon') }} →</RouterLink>
      </div>
    </div>
  </section>

  <section class="w-full max-w-full bg-background py-14 sm:py-20">
 <div class="page-container">
 <div class="text-center">
 <h2 class="text-3xl font-bold text-txt-primary lg:text-4xl">{{ t('landing.testimonialsTitle') }}</h2>
 <p class="mx-auto mt-4 max-w-2xl text-lg text-txt-secondary">{{ t('landing.testimonialsSubtitle') }}</p>
 </div>
 <div class="mt-12 flex overflow-x-auto snap-x snap-mandatory gap-6 pb-8 md:grid md:grid-cols-3 md:overflow-visible md:snap-none md:pb-0 hide-scrollbar">
 <div v-for="item in testimonials" :key="item.name" class="min-w-[85vw] snap-center rounded-2xl border border-border bg-surface p-8 shadow-panel transition-all duration-300 hover:-translate-y-2 hover:shadow-xl md:min-w-0 flex flex-col h-full">
 <div class="flex gap-1 text-amber-400 mb-5">
 <svg v-for="i in 5" :key="i" class="size-5 drop-shadow-sm" fill="currentColor" viewBox="0 0 20 20"><path d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 00.95.69h3.462c.969 0 1.371 1.24.588 1.81l-2.8 2.034a1 1 0 00-.364 1.118l1.07 3.292c.3.921-.755 1.688-1.54 1.118l-2.8-2.034a1 1 0 00-1.175 0l-2.8 2.034c-.784.57-1.838-.197-1.539-1.118l1.07-3.292a1 1 0 00-.364-1.118L2.98 8.72c-.783-.57-.38-1.81.588-1.81h3.461a1 1 0 00.951-.69l1.07-3.292z" /></svg>
 </div>
 <p class="text-base leading-8 text-txt-secondary italic flex-1">"{{ item.quote }}"</p>
 <div class="mt-8 flex items-center gap-4 border-t border-border pt-6">
 <img v-if="item.avatar" :src="item.avatar" class="size-12 rounded-full object-cover shadow-sm" :alt="item.name" />
 <div v-else class="grid size-12 place-items-center rounded-full bg-brand/10 text-lg font-bold text-brand shadow-sm">{{ item.name.charAt(0) }}</div>
 <div>
 <p class="text-base font-bold text-txt-primary">{{ item.name }}</p>
 <p class="text-sm font-medium text-txt-muted">{{ item.role }}</p>
 </div>
 </div>
 </div>
 </div>
 </div>
 </section>

 <section class="relative w-full max-w-full overflow-hidden py-20 sm:py-28">
 <div class="pointer-events-none absolute inset-0 bg-gradient-to-br from-brand/10 via-skyglass to-mint/10" />
 <div class="pointer-events-none absolute inset-0 bg-[url('/grid-pattern.svg')] bg-center opacity-20" />
 <div class="page-container relative max-w-4xl text-center lg:mx-auto bg-surface/60 backdrop-blur-xl rounded-3xl p-10 sm:p-16 border border-white/80 shadow-[0_20px_50px_rgba(15,23,42,0.06)]">
 <h2 class="text-3xl font-extrabold tracking-tight text-txt-primary lg:text-5xl">{{ t('landing.ctaTitle') }}</h2>
 <p class="mx-auto mt-6 max-w-2xl text-lg leading-8 text-txt-secondary">{{ t('landing.ctaBody') }}</p>
 <RouterLink class="mt-10 inline-flex items-center gap-2 rounded-full bg-gradient-to-r from-brand to-indigo-600 px-8 py-4 font-bold text-white shadow-lg shadow-brand/30 transition-all hover:scale-105 hover:shadow-brand/50" :to="user ? '/dashboard' : '/signup'">
 {{ t('landing.ctaButton') }}
 <svg class="size-5" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2.5"><path stroke-linecap="round" stroke-linejoin="round" d="M13 7l5 5m0 0l-5 5m5-5H6" /></svg>
 </RouterLink>
 </div>
 </section>

 <SiteFooter />


 </div>
</template>

<script setup>
import { computed, onMounted, onUnmounted, ref, onBeforeUnmount } from 'vue'
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
const testimonials = t('landing.testimonials')
const activeIndex = ref(0)
const windowWidth = ref(window.innerWidth)
let timer
let paused = false

const handleResize = () => { windowWidth.value = window.innerWidth }

const previewZoom = computed(() => {
 if (windowWidth.value < 500) return 30
 if (windowWidth.value < 640) return 35
 if (windowWidth.value < 1024) return 38
 return 42
})

const goToSlide = (index) => {
 activeIndex.value = index
}

const pauseCarousel = () => { paused = true }
const resumeCarousel = () => { paused = false }



onMounted(() => {
 window.addEventListener('resize', handleResize)
 if (!document.querySelector('script[src="https://checkout.razorpay.com/v1/checkout.js"]')) {
 const script = document.createElement('script')
 script.src = 'https://checkout.razorpay.com/v1/checkout.js'
 script.async = true
 document.head.appendChild(script)
 }
})

onBeforeUnmount(() => {
 window.removeEventListener('resize', handleResize)
})

const demos = [
 {
 label: 'Modern Template',
 short: 'Modern',
 title: 'John Doe',
 templateId: 'modern',
 content: {
 personal: { fullName: 'John Doe', headline: 'Senior Product Manager', email: 'john.doe@example.com', phone: '+91 98765 43210', location: 'Bengaluru, India', linkedin: 'linkedin.com/in/johndoe', summary: 'Product leader with 8 years of experience launching B2B SaaS platforms, improving activation, and aligning engineering, design, and revenue teams around measurable customer outcomes.' },
 education: { school: 'MBA, Indian School of Business', degree: 'MBA', date: '2016 - 2018' },
 experience: { role: 'Senior Product Manager', company: 'CloudWorks Labs\n- Led roadmap strategy for analytics products serving 40K monthly users and improved trial-to-paid conversion by 18%.\n- Directed a cross-functional team of 12 engineers and 3 designers to deliver 5 major product updates.\n- Reduced churn by 14% by introducing proactive health scores.\n\nProduct Manager | InnovateX\n- Launched MVP for mobile dashboard resulting in 20K active users in month one.\n- Streamlined agile development cycles reducing time-to-market by 25%.' },
 projects: { projectName: 'Self-serve onboarding revamp, usage-based billing launch, enterprise reporting suite\n\nAI Driven Candidate Matching\n- Built an AI model matching resumes to JDs with 92% accuracy.' },
 skills: { skillList: 'Product Strategy, Roadmapping, SQL, Analytics, A/B Testing, Stakeholder Management, SaaS Pricing, Go-To-Market, OKRs, Agile Scrum' },
 certifications: { certName: 'Certified Scrum Product Owner, Product Analytics Certification (Reforge)' }
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
 transition: all 0.45s cubic-bezier(0.4, 0, 0.2, 1);
}
.slide-enter-from {
 opacity: 0;
 transform: translateX(30px) scale(0.98);
}
.slide-leave-to {
 opacity: 0;
 transform: translateX(-30px) scale(0.98);
}

.hide-scrollbar::-webkit-scrollbar {
 display: none;
}
.hide-scrollbar {
 -ms-overflow-style: none;
 scrollbar-width: none;
}
</style>
