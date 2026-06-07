import { createRouter, createWebHistory } from 'vue-router'
import store from '../store'
import { ROUTE_NAMES } from '../constants/routes'
import LandingPage from '../modules/LandingPage.vue'
import AuthGateway from '../modules/auth/AuthGateway.vue'
import ForgotPasswordPage from '../modules/auth/ForgotPasswordPage.vue'
import DashboardPage from '../modules/dashboard/DashboardPage.vue'
import AdminDashboardPage from '../modules/admin/AdminDashboardPage.vue'
import ResumeListPage from '../modules/resumes/ResumeListPage.vue'
import ResumeEditorPage from '../modules/resumes/ResumeEditorPage.vue'
import ComingSoonPage from '../modules/coming-soon/ComingSoonPage.vue'
import ProfilePage from '../modules/profile/ProfilePage.vue'
import SettingsPage from '../modules/settings/SettingsPage.vue'
import StaticPage from '../modules/pages/StaticPage.vue'

const staticPages = [
  { path: '/about', name: ROUTE_NAMES.ABOUT, pageKey: 'about' },
  { path: '/careers', name: ROUTE_NAMES.CAREERS, pageKey: 'careers' },
  { path: '/blog', name: ROUTE_NAMES.BLOG, pageKey: 'blog' },
  { path: '/contact', name: ROUTE_NAMES.CONTACT, pageKey: 'contact' },
  { path: '/help', name: ROUTE_NAMES.HELP, pageKey: 'help' },
  { path: '/faq', name: ROUTE_NAMES.FAQ, pageKey: 'faq' },
  { path: '/support', name: ROUTE_NAMES.SUPPORT, pageKey: 'support' },
  { path: '/status', name: ROUTE_NAMES.STATUS, pageKey: 'status' },
  { path: '/privacy', name: ROUTE_NAMES.PRIVACY, pageKey: 'privacy' },
  { path: '/terms', name: ROUTE_NAMES.TERMS, pageKey: 'terms' },
  { path: '/cookies', name: ROUTE_NAMES.COOKIES, pageKey: 'cookies' },
  { path: '/refund-policy', name: ROUTE_NAMES.REFUND, pageKey: 'refund' },
  { path: '/shipping-policy', name: ROUTE_NAMES.SHIPPING, pageKey: 'shipping' }
]

const routes = [
  { path: '/', name: ROUTE_NAMES.LANDING, component: LandingPage },
  { path: '/coming-soon', name: ROUTE_NAMES.COMING_SOON, component: ComingSoonPage },
  ...staticPages.map(({ path, name, pageKey }) => ({ path, name, component: StaticPage, meta: { pageKey } })),
  { path: '/login', name: ROUTE_NAMES.LOGIN, component: AuthGateway, props: { mode: 'login' }, meta: { guestOnly: true } },
  { path: '/signup', name: ROUTE_NAMES.SIGNUP, component: AuthGateway, props: { mode: 'signup' }, meta: { guestOnly: true } },
  { path: '/forgot-password', name: ROUTE_NAMES.FORGOT_PASSWORD, component: ForgotPasswordPage, meta: { guestOnly: true } },
  { path: '/dashboard', name: ROUTE_NAMES.DASHBOARD, component: DashboardPage, meta: { requiresAuth: true } },
  { path: '/admin', name: ROUTE_NAMES.ADMIN, component: AdminDashboardPage, meta: { requiresAuth: true, requiresAdmin: true } },
  { path: '/profile', name: ROUTE_NAMES.PROFILE, component: ProfilePage, meta: { requiresAuth: true } },
  { path: '/settings', name: ROUTE_NAMES.SETTINGS, component: SettingsPage, meta: { requiresAuth: true } },
  { path: '/resumes', name: ROUTE_NAMES.RESUMES, component: ResumeListPage, meta: { requiresAuth: true } },
  { path: '/resumes/new', name: ROUTE_NAMES.RESUME_NEW, component: ResumeEditorPage, meta: { requiresAuth: true } },
  { path: '/resumes/:id/edit', name: ROUTE_NAMES.RESUME_EDIT, component: ResumeEditorPage, meta: { requiresAuth: true } }
]

const router = createRouter({ history: createWebHistory(), routes })

router.beforeEach(async (to) => {
  const needsSessionCheck = to.meta.requiresAuth || to.meta.guestOnly
  const user = needsSessionCheck ? store.state.auth.user || await store.dispatch('auth/fetchMe') : store.state.auth.user

  if (to.meta.guestOnly && user) return '/'
  if (to.meta.requiresAuth && !user) return '/login'
  if (to.meta.requiresAdmin && !['admin', 'super_admin'].includes(user?.role)) return '/dashboard'

  return true
})

export default router
