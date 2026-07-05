<template>
 <AdminShell :search-query="search" active-section="overview" @search="handleSearch">
 <template #actions>
 <a
 v-for="item in exports"
 :key="item.kind"
 class="inline-flex w-full items-center justify-center gap-2 rounded-xl border border-white/10 bg-surface/5 px-3 py-2 text-xs font-semibold text-slate-200 transition hover:border-brand/40 hover:bg-brand/10 hover:text-white sm:w-auto sm:px-4 sm:text-sm"
 :href="adminService.exportUrl(item.kind)"
 >
 <svg class="size-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M21 15v4a2 2 0 01-2 2H5a2 2 0 01-2-2v-4" /><path d="M7 10l5 5 5-5" /><path d="M12 15V3" /></svg>
 Export {{ item.label }}
 </a>
 </template>

 <div v-if="loading" class="grid place-items-center rounded-2xl border border-white/5 bg-surface/[0.02] py-24 text-txt-disabled">
 <p>Loading platform analytics...</p>
 </div>

 <div v-else class="space-y-8">
 <section id="overview" class="scroll-mt-24">
 <div class="relative overflow-hidden rounded-2xl border border-white/5 bg-gradient-to-br from-brand/20 via-[#121826] to-[#0b0f17] p-6 lg:p-8">
 <div class="pointer-events-none absolute -right-10 -top-10 size-48 rounded-full bg-brand/20 blur-3xl" />
 <div class="relative">
 <p class="text-xs font-bold uppercase tracking-[0.25em] text-brand">Platform Control Center</p>
 <h1 class="mt-2 text-3xl font-bold text-white lg:text-4xl">Super Admin Dashboard</h1>
 <p class="mt-3 max-w-2xl text-sm leading-7 text-txt-disabled">Manage users, subscriptions, feature rollout, exports, and audit activity from one protected workspace.</p>
 </div>
 </div>

 <div class="mt-6 grid gap-4 sm:grid-cols-2 xl:grid-cols-4">
 <div v-for="card in analyticsCards" :key="card.label" class="group rounded-2xl border border-white/5 bg-[#121826] p-5 transition hover:border-brand/30 hover:shadow-glow">
 <div class="flex items-start justify-between">
 <p class="text-[11px] font-bold uppercase tracking-wider text-txt-muted">{{ card.label }}</p>
 <span class="grid size-9 place-items-center rounded-xl bg-brand/15 text-brand" v-html="card.icon" />
 </div>
 <p class="mt-4 text-3xl font-bold text-white">{{ card.value }}</p>
 <p v-if="card.hint" class="mt-1 text-xs text-txt-muted">{{ card.hint }}</p>
 </div>
 </div>
 </section>

 <section id="analytics" class="scroll-mt-24 grid gap-6 xl:grid-cols-[1.4fr_1fr]">
 <div class="rounded-2xl border border-white/5 bg-[#121826] p-6">
 <div class="flex items-center justify-between">
 <div>
 <h2 class="text-lg font-bold text-white">User Growth</h2>
 <p class="text-sm text-txt-muted">Last six months</p>
 </div>
 <span class="rounded-lg bg-brand/15 px-3 py-1 text-xs font-semibold text-brand">Max {{ growthMax }}</span>
 </div>
 <div class="relative mt-8 h-56">
 <svg class="size-full" viewBox="0 0 400 200" preserveAspectRatio="none">
 <defs>
 <linearGradient id="growthFill" x1="0" y1="0" x2="0" y2="1">
 <stop offset="0%" stop-color="#6d4aff" stop-opacity="0.35" />
 <stop offset="100%" stop-color="#6d4aff" stop-opacity="0" />
 </linearGradient>
 </defs>
 <line x1="40" y1="10" x2="40" y2="170" stroke="rgba(255,255,255,0.08)" />
 <line x1="40" y1="170" x2="390" y2="170" stroke="rgba(255,255,255,0.08)" />
 <polygon :points="growthArea" fill="url(#growthFill)" />
 <polyline :points="growthLine" fill="none" stroke="#6d4aff" stroke-width="3" stroke-linecap="round" stroke-linejoin="round" />
 <g v-for="(point, i) in chartPoints" :key="point.label">
 <circle :cx="point.x" :cy="point.y" r="4" fill="#6d4aff" stroke="#0b0f17" stroke-width="2" />
 <text :x="point.x" y="192" text-anchor="middle" fill="#64748b" font-size="11">{{ point.label }}</text>
 </g>
 </svg>
 </div>
 </div>

 <div class="space-y-6">
 <div class="rounded-2xl border border-white/5 bg-[#121826] p-6">
 <h2 class="text-lg font-bold text-white">Resume Analytics</h2>
 <div class="mt-5 space-y-3">
 <div v-for="item in resumeRows" :key="item.label" class="flex items-center justify-between rounded-xl bg-surface/[0.03] px-4 py-3 text-sm">
 <span class="text-txt-disabled">{{ item.label }}</span>
 <span class="font-semibold text-white">{{ item.value }}</span>
 </div>
 </div>
 </div>

 <div class="rounded-2xl border border-white/5 bg-[#121826] p-6">
 <h2 class="text-lg font-bold text-white">Feature Interest</h2>
 <p class="mt-1 text-xs text-txt-muted">Signals what to build next</p>
 <div class="mt-5 space-y-4">
 <div v-for="feature in data.feature_interest_analytics" :key="feature.key">
 <div class="flex justify-between text-sm">
 <span class="font-medium text-slate-200">{{ feature.label }}</span>
 <span class="text-brand">{{ feature.interested }} interested</span>
 </div>
 <div class="mt-2 h-2 overflow-hidden rounded-full bg-surface/5">
 <div class="h-full rounded-full bg-gradient-to-r from-brand to-mint transition-all" :style="{ width: `${featurePercent(feature.interested)}%` }" />
 </div>
 </div>
 </div>
 </div>
 </div>
 </section>

 <!-- New Billing & Analytics Dashboard Section -->
 <section id="billing" class="scroll-mt-24 space-y-6">
 <div class="flex items-center justify-between border-b border-white/5 pb-4">
 <div>
 <h2 class="text-xl font-bold text-white">Billing & Revenue Dashboard</h2>
 <p class="mt-1 text-sm text-txt-muted">Real-time metrics, MRR, ARR, and transaction logs.</p>
 </div>
 </div>

 <!-- Metrics Grid -->
 <div class="grid gap-4 sm:grid-cols-2 xl:grid-cols-3">
 <div v-for="item in billingRows" :key="item.label" class="rounded-2xl border border-white/5 bg-[#121826] p-5 transition hover:border-brand/30 hover:shadow-glow">
 <p class="text-[11px] font-bold uppercase tracking-wider text-txt-muted">{{ item.label }}</p>
 <p class="mt-3 text-2xl font-bold text-white">{{ item.value }}</p>
 </div>
 </div>

 <!-- Tables -->
 <div class="grid gap-6 xl:grid-cols-3">
 <!-- Recent Payments -->
 <div class="rounded-2xl border border-white/5 bg-[#121826] p-5">
 <h3 class="font-bold text-white mb-4">Latest Transactions</h3>
 <div class="space-y-3">
 <div v-for="pay in data.billing_analytics?.recent_payments" :key="pay.id" class="flex items-center justify-between rounded-xl bg-surface/[0.03] p-3 text-sm">
 <div>
 <p class="text-white font-medium truncate max-w-[120px]">{{ pay.user.split('@')[0] }}</p>
 <p class="text-txt-muted text-xs">{{ formatDate(pay.created_at) }}</p>
 </div>
 <div class="text-right">
 <p class="text-emerald-400 font-bold">+₹{{ pay.amount }}</p>
 <p class="text-brand text-[10px] font-bold uppercase">{{ pay.plan }}</p>
 </div>
 </div>
 <p v-if="!data.billing_analytics?.recent_payments?.length" class="text-txt-muted text-sm">No recent payments.</p>
 </div>
 </div>
 
 <!-- Failed Payments -->
 <div class="rounded-2xl border border-white/5 bg-[#121826] p-5">
 <h3 class="font-bold text-white mb-4">Failed Payments</h3>
 <div class="space-y-3">
 <div v-for="pay in data.billing_analytics?.failed_payments" :key="pay.id" class="flex items-center justify-between rounded-xl bg-surface/[0.03] p-3 text-sm">
 <div>
 <p class="text-white font-medium truncate max-w-[120px]">{{ pay.user.split('@')[0] }}</p>
 <p class="text-txt-muted text-xs">{{ formatDate(pay.created_at) }}</p>
 </div>
 <div class="text-right">
 <p class="text-rose-400 font-bold">Failed</p>
 <p class="text-txt-disabled text-[10px] font-bold uppercase">{{ pay.plan }}</p>
 </div>
 </div>
 <p v-if="!data.billing_analytics?.failed_payments?.length" class="text-txt-muted text-sm">No recent failures.</p>
 </div>
 </div>
 
 <!-- Top Consumers -->
 <div class="rounded-2xl border border-white/5 bg-[#121826] p-5">
 <h3 class="font-bold text-white mb-4">Top AI Consumers</h3>
 <div class="space-y-3">
 <div v-for="user in data.billing_analytics?.top_consumers" :key="user.email" class="flex items-center justify-between rounded-xl bg-surface/[0.03] p-3 text-sm">
 <p class="text-white font-medium truncate max-w-[140px]">{{ user.email.split('@')[0] }}</p>
 <div class="text-right">
 <p class="text-brand font-bold">{{ user.used_credits }} / {{ user.total_credits }}</p>
 <p class="text-txt-muted text-[10px] font-bold uppercase">Credits</p>
 </div>
 </div>
 </div>
 </div>
 </div>
 </section>

 <section id="users" class="scroll-mt-24 rounded-2xl border border-white/5 bg-[#121826]">
 <div class="border-b border-white/5 p-6">
 <h2 class="text-xl font-bold text-white">User Management</h2>
 <p class="mt-1 text-sm text-txt-muted">View, edit, suspend, activate, delete, promote, and adjust subscriptions.</p>
 </div>
 <div class="overflow-x-auto">
 <table class="w-full text-left text-sm whitespace-nowrap">
 <thead class="bg-surface/[0.03] text-[11px] uppercase tracking-wider text-txt-muted">
 <tr>
 <th v-for="head in userHeads" :key="head" class="px-5 py-4 font-bold">{{ head }}</th>
 </tr>
 </thead>
 <tbody class="divide-y divide-white/5">
 <tr v-for="user in data.users.records" :key="user.id" class="transition hover:bg-surface/[0.02]">
 <td class="px-5 py-4">
 <div class="flex items-center gap-3">
 <span class="grid size-9 place-items-center rounded-full bg-brand/20 text-xs font-bold text-brand">{{ userInitial(user) }}</span>
 <div>
 <p class="font-semibold text-white">{{ user.name || user.username }}</p>
 <p class="text-xs text-txt-muted">@{{ user.username }}</p>
 </div>
 </div>
 </td>
 <td class="px-5 py-4 text-txt-muted">{{ user.email }}</td>
 <td class="px-5 py-4"><StatusBadge :tone="user.verified ? 'green' : 'red'">{{ user.verified ? 'Verified' : 'Pending' }}</StatusBadge></td>
 <td class="px-5 py-4">
 <select class="admin-select" :disabled="isSelf(user) || currentUser.role === 'admin'" :value="user.role" @change="saveUser(user.id, { role: $event.target.value })">
 <option value="user">User</option>
 <option value="admin">Admin</option>
 <option value="super_admin">Super Admin</option>
 </select>
 </td>
 <td class="px-5 py-4 text-txt-disabled">{{ formatDate(user.created_at) }}</td>
 <td class="px-5 py-4 text-txt-disabled">{{ formatDate(user.last_login_at) }}</td>
 <td class="px-5 py-4"><StatusBadge :tone="user.status === 'active' ? 'green' : 'red'">{{ user.status }}</StatusBadge></td>
 <td class="px-5 py-4">
 <div class="flex flex-col gap-1">
 <select class="admin-select plan-select" :value="user.subscription_plan" @change="saveUser(user.id, { subscription_plan: $event.target.value, billing_cycle: userBillingCycle(user) })">
 <option value="free">Free</option>
 <option value="plus">Plus - ₹{{ PRICING_PLANS.find(p => p.id === 'plus').monthlyPrice }}/mo</option>
 <option value="pro">Pro - ₹{{ PRICING_PLANS.find(p => p.id === 'pro').monthlyPrice }}/mo</option>
 <option v-if="user.subscription_plan === 'team'" value="team">Team (Legacy)</option>
 </select>
 <select v-if="user.subscription_plan !== 'free'" class="admin-select" :value="userBillingCycle(user)" @change="saveUser(user.id, { billing_cycle: $event.target.value })">
 <option value="monthly">Monthly</option>
 <option value="yearly">Yearly</option>
 </select>
 </div>
 </td>
 <td class="px-5 py-4">
 <div class="flex flex-wrap gap-1.5">
 <button class="admin-btn" @click="selectedUser = user">View</button>
 <button class="admin-btn" :disabled="user.verified" @click="saveUser(user.id, { verified_at: new Date().toISOString() })">{{ user.verified ? 'Verified' : 'Verify' }}</button>
 <button v-if="user.status === 'active'" class="admin-btn warn" @click="suspend(user.id)">Suspend</button>
 <button v-else class="admin-btn ok" @click="activate(user.id)">Activate</button>
 <button class="admin-btn danger" @click="deleteUser(user.id)">Delete</button>
 </div>
 </td>
 </tr>
 </tbody>
 </table>
 <p v-if="!data.users.records.length" class="p-8 text-center text-txt-muted">No users match your search.</p>
 </div>
 <PaginationBar :meta="data.users" @page="usersPage = $event; load()" />
 </section>

 <section id="settings" class="scroll-mt-24 grid gap-6 xl:grid-cols-3">
 <div class="rounded-2xl border border-white/5 bg-[#121826] p-6">
 <h2 class="text-lg font-bold text-white">Subscription Analytics</h2>
 <p class="mt-1 text-xs text-txt-muted">Razorpay-ready metrics (INR)</p>
 <div class="mt-5 grid grid-cols-2 gap-3">
 <div v-for="item in subscriptionRows" :key="item.label" class="rounded-xl border border-white/5 bg-surface/[0.03] p-4">
 <p class="text-[11px] uppercase tracking-wider text-txt-muted">{{ item.label }}</p>
 <p class="mt-2 text-xl font-bold text-white">{{ item.value }}</p>
 </div>
 </div>
 </div>

 <div class="rounded-2xl border border-white/5 bg-[#121826] p-6">
 <h2 class="text-lg font-bold text-white">Feature Flags</h2>
 <p class="mt-1 text-xs text-txt-muted">Toggle without redeploying</p>
 <div class="mt-5 space-y-3">
 <label v-for="flag in featureFlags" :key="flag.key" class="flex items-center justify-between rounded-xl border border-white/5 bg-surface/[0.03] px-4 py-3">
 <span class="text-sm font-medium text-slate-200">{{ flag.label }}</span>
 <button
 type="button"
 class="relative h-6 w-11 rounded-full transition"
 :class="flag.enabled ? 'bg-brand' : 'bg-slate-600'"
 @click="toggleFlag(flag.key, !flag.enabled)"
 >
 <span class="absolute top-0.5 size-5 rounded-full bg-surface shadow transition" :class="flag.enabled ? 'left-5' : 'left-0.5'" />
 </button>
 </label>
 <label class="flex items-center justify-between rounded-xl border border-white/5 bg-surface/[0.03] px-4 py-3">
 <span class="text-sm font-medium text-slate-200">Maintenance Mode</span>
 <button
 type="button"
 class="relative h-6 w-11 rounded-full transition"
 :class="data.settings?.maintenance_mode?.enabled ? 'bg-rose-500' : 'bg-slate-600'"
 @click="saveSetting('maintenance_mode', { enabled: !data.settings?.maintenance_mode?.enabled })"
 >
 <span class="absolute top-0.5 size-5 rounded-full bg-surface shadow transition" :class="data.settings?.maintenance_mode?.enabled ? 'left-5' : 'left-0.5'" />
 </button>
 </label>
 </div>
 </div>

 <div class="rounded-2xl border border-white/5 bg-[#121826] p-6">
 <h2 class="text-lg font-bold text-white">Announcements</h2>
 <div class="mt-5 space-y-4">
 <div>
 <label class="text-xs font-bold uppercase tracking-wider text-txt-muted">Global Announcement Message</label>
 <textarea
 class="admin-textarea mt-2"
 rows="4"
 :value="data.settings?.announcements?.message || ''"
 @change="saveSetting('announcements', { message: $event.target.value })"
 />
 </div>
 </div>
 </div>
 </section>


 <section id="audit" class="scroll-mt-24 rounded-2xl border border-white/5 bg-[#121826]">
 <div class="border-b border-white/5 p-6">
 <h2 class="text-xl font-bold text-white">Audit Logs</h2>
 <p class="mt-1 text-sm text-txt-muted">Track admin actions, plan changes, and sensitive updates.</p>
 </div>
 <div class="overflow-x-auto">
 <table class="w-full text-left text-sm whitespace-nowrap">
 <thead class="bg-surface/[0.03] text-[11px] uppercase tracking-wider text-txt-muted">
 <tr>
 <th class="px-5 py-4">Action</th>
 <th class="px-5 py-4">Details</th>
 <th class="px-5 py-4">Actor</th>
 <th class="px-5 py-4">User</th>
 <th class="px-5 py-4">When</th>
 </tr>
 </thead>
 <tbody class="divide-y divide-white/5">
 <tr v-for="log in data.audit_logs.records" :key="log.id" class="hover:bg-surface/[0.02]">
 <td class="px-5 py-4 font-semibold text-white">{{ log.action }}</td>
 <td class="px-5 py-4 text-txt-disabled">{{ log.details }}</td>
 <td class="px-5 py-4 text-txt-disabled">{{ log.actor || '—' }}</td>
 <td class="px-5 py-4 text-txt-disabled">{{ log.user || '—' }}</td>
 <td class="px-5 py-4 text-txt-muted">{{ formatDate(log.created_at) }}</td>
 </tr>
 </tbody>
 </table>
 </div>
 <PaginationBar :meta="data.audit_logs" @page="logsPage = $event; load()" />
 </section>

 <section id="sessions" class="scroll-mt-24 rounded-2xl border border-white/5 bg-[#121826]">
 <div class="border-b border-white/5 p-6">
 <h2 class="text-xl font-bold text-white">Login Sessions</h2>
 <p class="mt-1 text-sm text-txt-muted">IP address, browser, and login time for user sessions.</p>
 </div>
 <div class="overflow-x-auto">
 <table class="w-full text-left text-sm whitespace-nowrap">
 <thead class="bg-surface/[0.03] text-[11px] uppercase tracking-wider text-txt-muted">
 <tr><th class="px-5 py-4">User</th><th class="px-5 py-4">IP</th><th class="px-5 py-4">User Agent</th><th class="px-5 py-4">Login Time</th></tr>
 </thead>
 <tbody class="divide-y divide-white/5">
 <tr v-for="session in data.login_sessions.records" :key="session.id" class="hover:bg-surface/[0.02]">
 <td class="px-5 py-4 font-semibold text-white">{{ session.user }}</td>
 <td class="px-5 py-4 text-txt-disabled">{{ session.ip_address || '-' }}</td>
 <td class="max-w-xl truncate px-5 py-4 text-txt-disabled">{{ session.user_agent || '-' }}</td>
 <td class="px-5 py-4 text-txt-muted">{{ formatDate(session.logged_in_at) }}</td>
 </tr>
 </tbody>
 </table>
 </div>
 <PaginationBar :meta="data.login_sessions" @page="sessionsPage = $event; load()" />
 </section>
 </div>

 <Teleport to="body">
 <div v-if="selectedUser" class="fixed inset-0 z-50 grid place-items-center bg-black/70 p-5 backdrop-blur-sm" @click.self="selectedUser = null">
 <div class="w-full max-w-lg rounded-2xl border border-white/10 bg-[#121826] p-6 shadow-2xl">
 <div class="flex items-center gap-4">
 <span class="grid size-14 place-items-center rounded-2xl bg-brand/20 text-lg font-bold text-brand">{{ userInitial(selectedUser) }}</span>
 <div>
 <h2 class="text-xl font-bold text-white">{{ selectedUser.name }}</h2>
 <p class="text-sm text-txt-disabled">{{ selectedUser.email }}</p>
 </div>
 </div>
 <div class="mt-6 grid gap-3 rounded-xl bg-surface/[0.03] p-4 text-sm">
 <div class="flex justify-between"><span class="text-txt-muted">Role</span><span class="font-semibold text-white capitalize">{{ selectedUser.role.replace('_', ' ') }}</span></div>
 <div class="flex justify-between"><span class="text-txt-muted">Status</span><StatusBadge :tone="selectedUser.status === 'active' ? 'green' : 'red'">{{ selectedUser.status }}</StatusBadge></div>
 <div class="flex justify-between border-y border-white/5 py-2 my-2">
 <span class="text-txt-muted">Subscription</span>
 <span class="font-semibold text-white text-right">
 {{ getUserPlanDisplay(selectedUser) }}
 </span>
 </div>
 <div v-if="selectedUser.subscription_plan !== 'free'" class="flex justify-between"><span class="text-txt-muted">Plan valid until</span><span class="font-semibold text-brand">{{ formatDate(selectedUser.subscription_expires_at) }}</span></div>
 <div class="flex justify-between"><span class="text-txt-muted">PDF downloads</span><span class="font-semibold text-white">{{ selectedUser.resume_downloads_count }}</span></div>
 <div class="flex justify-between"><span class="text-txt-muted">Verified</span><span class="text-white">{{ selectedUser.verified ? 'Yes' : 'No' }}</span></div>
 <div class="flex justify-between"><span class="text-txt-muted">Created</span><span class="text-white">{{ formatDate(selectedUser.created_at) }}</span></div>
 <div class="flex justify-between"><span class="text-txt-muted">Last login</span><span class="text-white">{{ formatDate(selectedUser.last_login_at) }}</span></div>
 </div>
 <button class="mt-6 w-full rounded-xl bg-brand px-4 py-3 font-semibold text-white transition hover:bg-brand/90" @click="selectedUser = null">Close</button>
 </div>
 </div>
 </Teleport>
 </AdminShell>
</template>

<script setup>
import { computed, defineComponent, h, onMounted, ref } from 'vue'
import { useStore } from 'vuex'
import AdminShell from '../../components/layout/AdminShell.vue'
import { adminService } from '../../services/adminService'
import { PRICING_PLANS } from '../../constants/pricing'
import { toast } from '../../utils/toast'

const StatusBadge = defineComponent({
 props: { tone: String },
 setup(props, { slots }) {
 return () => h('span', {
 class: 'inline-flex rounded-full px-2.5 py-1 text-xs font-bold capitalize ' + (
 props.tone === 'green' ? 'bg-emerald-500/15 text-emerald-400' :
 props.tone === 'red' ? 'bg-rose-500/15 text-rose-400' :
 'bg-background0/15 text-txt-disabled'
 )
 }, slots.default?.())
 }
})

const PaginationBar = defineComponent({
 props: { meta: Object },
 emits: ['page'],
 setup(props, { emit }) {
 return () => h('div', { class: 'sticky bottom-0 flex items-center justify-between border-t border-white/5 bg-[#121826]/95 px-5 py-3 text-sm backdrop-blur' }, [
 h('span', { class: 'text-txt-muted' }, `Page ${props.meta?.page || 1} of ${props.meta?.total_pages || 1} (${props.meta?.total || 0} total)`),
 h('div', { class: 'flex gap-2' }, [
 h('button', { class: 'admin-btn', disabled: (props.meta?.page || 1) <= 1, onClick: () => emit('page', (props.meta?.page || 1) - 1) }, 'Previous'),
 h('button', { class: 'admin-btn', disabled: (props.meta?.page || 1) >= (props.meta?.total_pages || 1), onClick: () => emit('page', (props.meta?.page || 1) + 1) }, 'Next')
 ])
 ])
 }
})

const store = useStore()
const loading = ref(true)
const search = ref('')
const usersPage = ref(1)
const logsPage = ref(1)
const sessionsPage = ref(1)
const selectedUser = ref(null)
const data = ref({
 analytics: {}, users: { records: [] }, resume_analytics: {}, feature_interest_analytics: [],
 subscription_analytics: {}, settings: {}, audit_logs: { records: [] }, login_sessions: { records: [] }, growth: { labels: [], values: [] }
})
const currentUser = computed(() => store.state.auth.user || {})

const exports = [
 { kind: 'users', label: 'Users' },
 { kind: 'resumes', label: 'Resumes' },
 { kind: 'audit_logs', label: 'Audit Logs' }
]
const userHeads = ['Name', 'Email', 'Verified', 'Role', 'Created', 'Last Login', 'Status', 'Plan', 'Actions']

const iconSvg = (d) => `<svg class="size-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="${d}"/></svg>`

const load = async () => {
 loading.value = true
 try {
 const response = await adminService.show({ search: search.value, users_page: usersPage.value, logs_page: logsPage.value, sessions_page: sessionsPage.value })
 data.value = response.data
 } finally {
 loading.value = false
 }
}

onMounted(load)

const analyticsCards = computed(() => {
 const a = data.value.analytics
 return [
 { label: 'Total Users', value: a.total_users ?? 0, icon: iconSvg('M17 21v-2a4 4 0 00-4-4H5a4 4 0 00-4 4v2M9 11a4 4 0 100-8 4 4 0 000 8z'), hint: 'All registered accounts' },
 { label: 'New Today', value: a.new_users_today ?? 0, icon: iconSvg('M12 5v14M5 12h14'), hint: 'Signed up today' },
 { label: 'Active Users', value: a.active_users ?? 0, icon: iconSvg('M22 12h-4l-3 9L9 3l-3 9H2'), hint: 'Not suspended' },
 { label: 'Verified Users', value: a.verified_users ?? 0, icon: iconSvg('M22 11.08V12a10 10 0 11-5.93-9.14M22 4L12 14.01l-3-3'), hint: 'Email verified' },
 { label: 'Unverified Users', value: a.unverified_users ?? 0, icon: iconSvg('M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z'), hint: 'Pending verification' },
 { label: 'Total Resumes', value: a.total_resumes ?? 0, icon: iconSvg('M14 2H6a2 2 0 00-2 2v16a2 2 0 002 2h12a2 2 0 002-2V8zM14 2v6h6'), hint: 'Across platform' },
 { label: 'Draft Resumes', value: a.draft_resumes ?? 0, icon: iconSvg('M11 4H4a2 2 0 00-2 2v14a2 2 0 002 2h14a2 2 0 002-2v-7'), hint: 'In progress' },
 { label: 'Published', value: a.published_resumes ?? 0, icon: iconSvg('M20 6L9 17l-5-5'), hint: 'Ready to share' }
 ]
})

const resumeRows = computed(() => [
 ['Total Resumes', data.value.resume_analytics.total_resumes],
 ['Created Today', data.value.resume_analytics.created_today],
 ['Downloaded Today', data.value.resume_analytics.downloaded_today],
 ['Top Template', data.value.resume_analytics.top_template],
 ['Avg per User', data.value.resume_analytics.average_resumes_per_user]
].map(([label, value]) => ({ label, value: value ?? 0 })))

const subscriptionRows = computed(() => [
 ['Free Users', data.value.subscription_analytics.free_users],
 ['Plus Users', data.value.subscription_analytics.plus_users],
 ['Pro Users', data.value.subscription_analytics.pro_users],
 ['Revenue', rupees(data.value.subscription_analytics.revenue)],
 ['Monthly Revenue', rupees(data.value.subscription_analytics.monthly_revenue)],
 ['Cancelled Plans', data.value.subscription_analytics.cancelled_plans]
].map(([label, value]) => ({ label, value: value ?? 0 })))

const billingRows = computed(() => {
 const b = data.value.billing_analytics || {}
 return [
 ['Revenue Today', rupees(b.revenue_today)],
 ['Revenue This Month', rupees(b.revenue_this_month)],
 ['MRR (Monthly Recurring)', rupees(b.mrr)],
 ['ARR (Annual Recurring)', rupees(b.arr)],
 ['Active Subscriptions', b.active_subscriptions || 0],
 ['Most Popular Plan', b.most_popular_plan || 'None']
 ].map(([label, value]) => ({ label, value }))
})

const growthMax = computed(() => Math.max(...data.value.growth.values, 1))

const chartPoints = computed(() => {
 const labels = data.value.growth.labels
 const values = data.value.growth.values
 const max = growthMax.value
 const width = 350
 const startX = 40
 return labels.map((label, i) => {
 const x = startX + (i / Math.max(labels.length - 1, 1)) * width
 const y = 170 - ((values[i] || 0) / max) * 150
 return { label, x, y, value: values[i] || 0 }
 })
})

const growthLine = computed(() => chartPoints.value.map((p) => `${p.x},${p.y}`).join(' '))
const growthArea = computed(() => {
 const pts = chartPoints.value
 if (!pts.length) return ''
 const line = pts.map((p) => `${p.x},${p.y}`).join(' ')
 return `${pts[0].x},170 ${line} ${pts[pts.length - 1].x},170`
})

const handleSearch = (value) => { search.value = value; usersPage.value = 1; logsPage.value = 1; sessionsPage.value = 1; load() }

const featureFlags = computed(() => {
 const flags = data.value.settings.feature_flags || {}
 return [
 { key: 'ats_checker', label: 'ATS Checker', enabled: !!flags.ats_checker },
 { key: 'mock_interview', label: 'Mock Interview', enabled: !!flags.mock_interview },
 { key: 'portfolio_generator', label: 'Portfolio Gen', enabled: !!flags.portfolio_generator }
 ]
})

const featurePercent = (count) => Math.min(100, (count / 140) * 100)

const replaceUser = (user) => {
 data.value.users.records = data.value.users.records.map((item) => (item.id === user.id ? user : item))
 if (selectedUser.value?.id === user.id) selectedUser.value = user
}

const saveUser = async (id, payload) => {
 const response = await adminService.updateUser(id, payload)
 replaceUser(response.data.user)
 data.value.audit_logs = response.data.audit_logs
 toast.success('User updated')
}

const suspend = async (id) => { const r = await adminService.suspendUser(id); replaceUser(r.data.user); data.value.audit_logs = r.data.audit_logs }
const activate = async (id) => { const r = await adminService.activateUser(id); replaceUser(r.data.user); data.value.audit_logs = r.data.audit_logs }

const deleteUser = async (id) => {
 if (!confirm('Delete this user and all dependent records?')) return
 const response = await adminService.deleteUser(id)
 data.value.users = response.data.users
 data.value.analytics = response.data.analytics
 data.value.audit_logs = response.data.audit_logs
}

const saveSetting = async (key, value) => {
 const response = await adminService.updateSettings(key, value)
 data.value.settings = response.data.settings
 data.value.audit_logs = response.data.audit_logs
}

const toggleFlag = (key, enabled) => saveSetting('feature_flags', { ...(data.value.settings.feature_flags || {}), [key]: enabled })

const userInitial = (user) => (user.name || user.username || 'U').charAt(0).toUpperCase()
const isSelf = (user) => user.id === currentUser.value.id
const formatDate = (date) => date ? new Intl.DateTimeFormat('en-IN', { dateStyle: 'medium', timeStyle: 'short' }).format(new Date(date)) : 'Never'
const rupees = (value) => new Intl.NumberFormat('en-IN', { style: 'currency', currency: 'INR', maximumFractionDigits: 0 }).format(value || 0)

const userBillingCycle = (user) => {
 if (!user.subscription_started_at || !user.subscription_expires_at) return 'monthly'
 const start = new Date(user.subscription_started_at)
 const end = new Date(user.subscription_expires_at)
 return (end - start) / (1000 * 60 * 60 * 24) > 300 ? 'yearly' : 'monthly'
}

const getUserPlanDisplay = (user) => {
 if (user.subscription_plan === 'free') return 'Free Plan'
 if (user.subscription_plan === 'team') return 'Team (Legacy)'
 
 const cycle = userBillingCycle(user)
 const planDetails = PRICING_PLANS.find(p => p.id === user.subscription_plan)
 if (!planDetails) return user.subscription_plan
 
 const price = cycle === 'yearly' ? planDetails.yearlyPrice : planDetails.monthlyPrice
 return `${planDetails.name} (₹${price}/${cycle === 'yearly' ? 'yr' : 'mo'}) - ${cycle.charAt(0).toUpperCase() + cycle.slice(1)}`
}
</script>

<style scoped>
.admin-select {
 width: 140px;
 border-radius: 10px;
 border: 1px solid rgba(255, 255, 255, 0.1);
 background: rgba(255, 255, 255, 0.05);
 padding: 0.4rem 0.55rem;
 font-size: 0.8125rem;
 color: #e2e8f0;
}
.admin-select option {
 background-color: #121826;
 color: #e2e8f0;
}
.admin-btn {
 border-radius: 8px;
 border: 1px solid rgba(255, 255, 255, 0.1);
 background: rgba(255, 255, 255, 0.05);
 padding: 0.35rem 0.6rem;
 font-size: 0.7rem;
 font-weight: 700;
 color: #cbd5e1;
 transition: all 0.15s;
}
.admin-btn:hover:not(:disabled) { border-color: rgba(109, 74, 255, 0.5); color: #fff; background: rgba(109, 74, 255, 0.15); }
.admin-btn:disabled { opacity: 0.4; cursor: not-allowed; background: rgba(255, 255, 255, 0.02); }
.admin-btn.danger { color: #fb7185; }
.admin-btn.warn { color: #fbbf24; }
.admin-btn.ok { color: #34d399; }
.admin-textarea {
 width: 100%;
 border-radius: 10px;
 border: 1px solid rgba(255, 255, 255, 0.1);
 background: rgba(255, 255, 255, 0.05);
 padding: 0.6rem 0.75rem;
 font-size: 0.875rem;
 color: #e2e8f0;
 outline: none;
}
.admin-textarea:focus { border-color: rgba(109, 74, 255, 0.5); ring: 2px rgba(109, 74, 255, 0.2); }
</style>
