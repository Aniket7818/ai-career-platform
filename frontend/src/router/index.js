import { createRouter, createWebHistory } from 'vue-router'
import store from '../store'
import { ROUTE_NAMES } from '../constants/routes'
import LandingPage from '../modules/LandingPage.vue'
import AuthGateway from '../modules/auth/AuthGateway.vue'
import ForgotPasswordPage from '../modules/auth/ForgotPasswordPage.vue'
import ResetPasswordPage from '../modules/auth/ResetPasswordPage.vue'
import DashboardPage from '../modules/dashboard/DashboardPage.vue'
import AdminDashboardPage from '../modules/admin/AdminDashboardPage.vue'
import ResumeListPage from '../modules/resumes/ResumeListPage.vue'
import ResumeEditorPage from '../modules/resumes/ResumeEditorPage.vue'
import ResumeOptimizePage from '../modules/resumes/ResumeOptimizePage.vue'
import ComingSoonPage from '../modules/coming-soon/ComingSoonPage.vue'
import ProfilePage from '../modules/profile/ProfilePage.vue'
import SettingsPage from '../modules/settings/SettingsPage.vue'
import StaticPage from '../modules/pages/StaticPage.vue'

import ResumePrintView from '../modules/resumes/ResumePrintView.vue'

import InterviewPrepList from '../modules/interview-prep/InterviewPrepList.vue'
import InterviewPrepSubject from '../modules/interview-prep/InterviewPrepSubject.vue'
import InterviewPrepQuestion from '../modules/interview-prep/InterviewPrepQuestion.vue'

const staticPages = [
 { path: '/features', name: ROUTE_NAMES.FEATURES, pageKey: 'features' },
 { path: '/about', name: ROUTE_NAMES.ABOUT, pageKey: 'about' },
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
 { path: '/careers', redirect: '/' },
 { path: '/blog', redirect: '/' },
 ...staticPages.map(({ path, name, pageKey }) => ({ path, name, component: StaticPage, meta: { pageKey } })),
 { path: '/login', name: ROUTE_NAMES.LOGIN, component: AuthGateway, props: { mode: 'login' }, meta: { guestOnly: true } },
 { path: '/signup', name: ROUTE_NAMES.SIGNUP, component: AuthGateway, props: { mode: 'signup' }, meta: { guestOnly: true } },
 { path: '/forgot-password', name: ROUTE_NAMES.FORGOT_PASSWORD, component: ForgotPasswordPage },
 { path: '/reset-password', name: 'reset-password', component: ResetPasswordPage },
 { path: '/verify-email', name: 'verify-email', component: () => import('../modules/auth/VerifyEmailPage.vue') },
 { path: '/dashboard', name: ROUTE_NAMES.DASHBOARD, component: DashboardPage, meta: { requiresAuth: true } },
 { path: '/admin', name: ROUTE_NAMES.ADMIN, component: AdminDashboardPage, meta: { requiresAuth: true, requiresAdmin: true } },
 { path: '/admin/ai-analytics', name: 'admin-ai-analytics', component: () => import('../modules/admin/AdminAiAnalyticsWrapper.vue'), meta: { requiresAuth: true, requiresAdmin: true } },
 { path: '/profile', name: ROUTE_NAMES.PROFILE, component: ProfilePage, meta: { requiresAuth: true } },
 { path: '/settings', name: ROUTE_NAMES.SETTINGS, component: SettingsPage, meta: { requiresAuth: true } },
 { path: '/settings/billing', name: ROUTE_NAMES.SETTINGS_BILLING, component: SettingsPage, meta: { requiresAuth: true } },
 { path: '/resumes', name: ROUTE_NAMES.RESUMES, component: ResumeListPage, meta: { requiresAuth: true } },
 { path: '/resumes/new', name: ROUTE_NAMES.RESUME_NEW, component: ResumeEditorPage, meta: { requiresAuth: true } },
 { path: '/resumes/:id/edit', name: ROUTE_NAMES.RESUME_EDIT, component: ResumeEditorPage, meta: { requiresAuth: true } },
 { path: '/resumes/:id/optimize', name: ROUTE_NAMES.RESUME_OPTIMIZE, component: ResumeOptimizePage, meta: { requiresAuth: true } },
 { path: '/resumes/:id/print', name: 'resume-print', component: ResumePrintView, meta: { requiresAuth: true } },
 { path: '/interview-prep', name: ROUTE_NAMES.INTERVIEW_PREP, component: InterviewPrepList, meta: { requiresAuth: true } },
 { path: '/interview-prep/bookmarks', name: 'interview-prep-bookmarks', component: () => import('../modules/interview-prep/InterviewPrepFilteredList.vue'), meta: { requiresAuth: true, listType: 'bookmarks' } },
 { path: '/interview-prep/completed', name: 'interview-prep-completed', component: () => import('../modules/interview-prep/InterviewPrepFilteredList.vue'), meta: { requiresAuth: true, listType: 'completed' } },
 { path: '/interview-prep/history', name: 'interview-prep-history', component: () => import('../modules/interview-prep/InterviewPrepFilteredList.vue'), meta: { requiresAuth: true, listType: 'history' } },
 { path: '/interview-prep/:subject', name: ROUTE_NAMES.INTERVIEW_PREP_SUBJECT, component: InterviewPrepSubject, meta: { requiresAuth: true } },
 { path: '/interview-prep/:subject/:question_id', name: ROUTE_NAMES.INTERVIEW_PREP_QUESTION, component: InterviewPrepQuestion, meta: { requiresAuth: true } }
]

const router = createRouter({ 
 history: createWebHistory(), 
 routes,
 scrollBehavior(to, from, savedPosition) {
 if (savedPosition) {
 return savedPosition
 }
 // Don't reset scroll if navigating within the same page (e.g. hash changes)
 if (to.path === from.path) {
 return
 }
 // Ensure smooth scroll to top on every navigation
 return { top: 0, behavior: 'smooth' }
 }
})

router.beforeEach(async (to) => {
 // Clear any global auth errors when navigating to a new page
 if (store.state.auth.error) {
 store.commit('auth/setError', null)
 }

 const needsSessionCheck = to.meta.requiresAuth || to.meta.guestOnly
 const user = needsSessionCheck ? store.state.auth.user || await store.dispatch('auth/fetchMe') : store.state.auth.user

 if (to.meta.guestOnly && user) return '/'
 if (to.meta.requiresAuth && !user) return '/login'
 if (to.meta.requiresAdmin && !['admin', 'super_admin'].includes(user?.role)) return '/dashboard'

 // Restrict access if unverified
 if (to.meta.requiresAuth && user && !user.verified) {
 // allow dashboard, profile, and email verification
 const allowedForUnverified = [ROUTE_NAMES.DASHBOARD, ROUTE_NAMES.PROFILE, 'verify-email', 'settings']
 if (!allowedForUnverified.includes(to.name)) {
 return { name: ROUTE_NAMES.DASHBOARD, query: { verify_required: '1' } }
 }
 }

 return true
})

export default router
