<template>
 <section id="ai-analytics" class="scroll-mt-24 rounded-2xl border border-white/5 bg-[#121826]">
 <div class="border-b border-white/5 p-6 flex justify-between items-center">
 <div>
 <h2 class="text-xl font-bold text-white">AI Platform Analytics</h2>
 <p class="mt-1 text-sm text-txt-muted">Live monitoring, performance, provider usage, and detailed AI request logs.</p>
 </div>
 <div class="flex gap-2">
 <button @click="loadData" class="admin-btn text-xs" :disabled="loading">
 {{ loading ? 'Refreshing...' : 'Refresh Data' }}
 </button>
 </div>
 </div>
 
 <div v-if="loading && !data" class="p-12 text-center text-txt-muted">Loading AI analytics...</div>
 
 <div v-else-if="data" class="p-6 space-y-6">
 <!-- Top Level Stats -->
 <div class="grid grid-cols-2 md:grid-cols-4 xl:grid-cols-5 gap-4">
 <div class="rounded-xl border border-white/5 bg-surface/[0.02] p-4">
 <p class="text-[10px] uppercase tracking-wider text-txt-muted font-bold mb-1">Total Requests</p>
 <p class="text-2xl font-bold text-white">{{ data.overview.total_requests }}</p>
 <p class="text-[10px] text-txt-disabled mt-1">{{ data.overview.today_requests }} today</p>
 </div>
 <div class="rounded-xl border border-white/5 bg-surface/[0.02] p-4">
 <p class="text-[10px] uppercase tracking-wider text-txt-muted font-bold mb-1">Success Rate</p>
 <p class="text-2xl font-bold text-white">
 {{ data.overview.total_requests > 0 ? Math.round((data.overview.successful_requests / data.overview.total_requests) * 100) : 0 }}%
 </p>
 <p class="text-[10px] text-txt-disabled mt-1">{{ data.overview.failed_requests }} failed</p>
 </div>
 <div class="rounded-xl border border-white/5 bg-surface/[0.02] p-4">
 <p class="text-[10px] uppercase tracking-wider text-txt-muted font-bold mb-1">Avg Response Time</p>
 <p class="text-2xl font-bold text-white">{{ (data.overview.avg_response_time / 1000).toFixed(2) }}s</p>
 </div>
 <div class="rounded-xl border border-white/5 bg-surface/[0.02] p-4">
 <p class="text-[10px] uppercase tracking-wider text-txt-muted font-bold mb-1">Total AI Cost</p>
 <p class="text-2xl font-bold text-white">${{ data.overview.total_cost.toFixed(4) }}</p>
 <p class="text-[10px] text-txt-disabled mt-1">${{ data.overview.today_cost.toFixed(4) }} today</p>
 </div>
 <div class="rounded-xl border border-white/5 bg-surface/[0.02] p-4">
 <p class="text-[10px] uppercase tracking-wider text-txt-muted font-bold mb-1">Cache Hits</p>
 <p class="text-2xl font-bold text-white">{{ data.overview.cache_hits }}</p>
 </div>
 </div>

 <div class="grid xl:grid-cols-2 gap-6">
 <!-- Provider Stats -->
 <div class="rounded-xl border border-white/5 bg-surface/[0.02] p-5">
 <h3 class="text-sm font-bold text-white mb-4">Provider Performance</h3>
 <div class="space-y-3">
 <div v-for="stat in data.provider_stats" :key="stat.name" class="bg-[#121826] border border-white/5 rounded-lg p-3 flex justify-between items-center">
 <div>
 <p class="text-sm font-semibold text-white capitalize">{{ stat.name }}</p>
 <p class="text-xs text-txt-disabled">{{ (stat.avg_time / 1000).toFixed(2) }}s avg time</p>
 </div>
 <div class="text-right">
 <p class="text-sm font-mono text-brand">${{ stat.avg_cost.toFixed(5) }}/req</p>
 </div>
 </div>
 <p v-if="!data.provider_stats.length" class="text-txt-muted text-sm">No provider data available.</p>
 </div>
 </div>

 <!-- Feature Stats -->
 <div class="rounded-xl border border-white/5 bg-surface/[0.02] p-5">
 <h3 class="text-sm font-bold text-white mb-4">Feature Usage</h3>
 <div class="space-y-3 max-h-60 overflow-y-auto custom-scrollbar">
 <div v-for="stat in data.feature_stats" :key="stat.name" class="bg-[#121826] border border-white/5 rounded-lg p-3 flex justify-between items-center">
 <div>
 <p class="text-sm font-semibold text-white capitalize">{{ stat.name.replace(/_/g, ' ') }}</p>
 <p class="text-xs text-txt-disabled">${{ stat.total_cost.toFixed(4) }} total cost</p>
 </div>
 <div class="text-right">
 <p class="text-sm font-mono text-emerald-400">${{ stat.avg_cost.toFixed(5) }}/req</p>
 </div>
 </div>
 </div>
 </div>
 </div>

 <!-- AI Request Explorer -->
 <div class="rounded-xl border border-white/5 bg-[#121826]">
 <div class="p-5 border-b border-white/5 flex justify-between items-center">
 <h3 class="text-sm font-bold text-white">Live Request Explorer</h3>
 <input type="text" v-model="searchQuery" @keyup.enter="loadRequests" placeholder="Search by user or feature..." class="bg-surface/5 border border-white/10 rounded-lg px-3 py-1.5 text-xs text-white outline-none focus:border-brand">
 </div>
 
 <div class="overflow-x-auto">
 <table class="w-full text-left text-sm whitespace-nowrap">
 <thead class="bg-surface/[0.03] text-[10px] uppercase tracking-wider text-txt-muted">
 <tr>
 <th class="px-5 py-3">Time</th>
 <th class="px-5 py-3">User</th>
 <th class="px-5 py-3">Feature</th>
 <th class="px-5 py-3">Provider / Model</th>
 <th class="px-5 py-3">Tokens</th>
 <th class="px-5 py-3">Cost</th>
 <th class="px-5 py-3">Status</th>
 <th class="px-5 py-3"></th>
 </tr>
 </thead>
 <tbody class="divide-y divide-white/5">
 <tr v-for="req in requests" :key="req.id" class="hover:bg-surface/[0.02] transition">
 <td class="px-5 py-3 text-txt-disabled text-xs">{{ formatDate(req.time) }}</td>
 <td class="px-5 py-3 text-txt-muted font-medium text-xs">{{ req.user_email }}</td>
 <td class="px-5 py-3 text-txt-muted capitalize text-xs">{{ req.feature?.replace(/_/g, ' ') }}</td>
 <td class="px-5 py-3 text-txt-disabled text-xs">
 <span class="font-semibold text-brand">{{ req.provider || 'unknown' }}</span>
 <span class="text-txt-muted ml-1">{{ req.model || 'unknown' }}</span>
 </td>
 <td class="px-5 py-3 text-txt-disabled text-xs font-mono">{{ req.tokens || 0 }}</td>
 <td class="px-5 py-3 text-emerald-400 text-xs font-mono">${{ req.cost?.toFixed(5) || '0.00000' }}</td>
 <td class="px-5 py-3">
 <span class="inline-flex rounded-full px-2 py-0.5 text-[10px] font-bold uppercase"
 :class="req.status === 'success' ? 'bg-emerald-500/15 text-emerald-400' : 'bg-rose-500/15 text-rose-400'">
 {{ req.status }}
 </span>
 </td>
 <td class="px-5 py-3 text-right">
 <button @click="viewDetails(req.id)" class="text-[10px] bg-surface/5 hover:bg-surface/10 text-white px-2 py-1 rounded">View</button>
 </td>
 </tr>
 </tbody>
 </table>
 <div v-if="loadingRequests" class="p-6 text-center text-txt-muted text-xs">Loading requests...</div>
 <div v-else-if="!requests.length" class="p-6 text-center text-txt-muted text-xs">No requests found.</div>
 </div>
 
 <div class="flex items-center justify-between p-4 border-t border-white/5 bg-[#121826]">
 <span class="text-xs text-txt-muted">Page {{ currentPage }} of {{ totalPages }}</span>
 <div class="flex gap-2">
 <button @click="changePage(currentPage - 1)" :disabled="currentPage <= 1" class="admin-btn">Prev</button>
 <button @click="changePage(currentPage + 1)" :disabled="currentPage >= totalPages" class="admin-btn">Next</button>
 </div>
 </div>
 </div>
 </div>

 <!-- Request Details Modal -->
 <Teleport to="body">
 <div v-if="selectedRequest" class="fixed inset-0 z-50 flex items-center justify-center bg-black/80 backdrop-blur-sm p-4" @click.self="selectedRequest = null">
 <div class="bg-[#121826] border border-white/10 rounded-2xl shadow-2xl w-full max-w-4xl max-h-[90vh] flex flex-col">
 <div class="p-5 border-b border-white/10 flex justify-between items-center bg-surface/[0.02]">
 <div>
 <h3 class="text-lg font-bold text-white">Request #{{ selectedRequest.id }}</h3>
 <p class="text-xs text-txt-disabled">{{ formatDate(selectedRequest.created_at) }} • {{ selectedRequest.user_email }}</p>
 </div>
 <button @click="selectedRequest = null" class="text-txt-disabled hover:text-white p-1">
 <svg class="size-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M18 6 6 18M6 6l12 12"/></svg>
 </button>
 </div>
 <div class="p-5 flex-1 overflow-y-auto space-y-6">
 <div class="grid grid-cols-2 md:grid-cols-4 gap-4">
 <div class="bg-surface/5 p-3 rounded-lg">
 <p class="text-[10px] text-txt-muted uppercase tracking-wider font-bold">Feature</p>
 <p class="text-sm text-white font-medium capitalize mt-1">{{ selectedRequest.feature?.replace(/_/g, ' ') }}</p>
 </div>
 <div class="bg-surface/5 p-3 rounded-lg">
 <p class="text-[10px] text-txt-muted uppercase tracking-wider font-bold">Provider / Model</p>
 <p class="text-sm text-white font-medium mt-1">{{ selectedRequest.provider }} <span class="text-txt-disabled text-xs block">{{ selectedRequest.model }}</span></p>
 </div>
 <div class="bg-surface/5 p-3 rounded-lg">
 <p class="text-[10px] text-txt-muted uppercase tracking-wider font-bold">Tokens</p>
 <p class="text-sm text-white font-mono mt-1">{{ selectedRequest.tokens_in }} in / {{ selectedRequest.tokens_out }} out</p>
 </div>
 <div class="bg-surface/5 p-3 rounded-lg">
 <p class="text-[10px] text-txt-muted uppercase tracking-wider font-bold">Timing & Cost</p>
 <p class="text-sm text-white font-mono mt-1">{{ selectedRequest.response_time }}ms / ${{ selectedRequest.estimated_cost?.toFixed(5) }}</p>
 </div>
 </div>

 <div>
 <h4 class="text-sm font-bold text-txt-muted mb-2 uppercase tracking-wider">Prompt Context</h4>
 <div class="bg-black/50 border border-white/5 rounded-lg p-4 text-xs font-mono text-txt-muted max-h-64 overflow-y-auto whitespace-pre-wrap custom-scrollbar">
 {{ selectedRequest.request_prompt || 'No prompt recorded' }}
 </div>
 </div>

 <div>
 <h4 class="text-sm font-bold text-brand mb-2 uppercase tracking-wider flex items-center justify-between">
 <span>AI Response</span>
 <span v-if="selectedRequest.status !== 'success'" class="text-rose-400">{{ selectedRequest.status }} - {{ selectedRequest.error_message }}</span>
 </h4>
 <div class="bg-brand/5 border border-brand/20 rounded-lg p-4 text-sm text-slate-200 max-h-64 overflow-y-auto whitespace-pre-wrap custom-scrollbar">
 {{ selectedRequest.response_content || 'No response recorded' }}
 </div>
 </div>
 
 <div class="flex flex-wrap gap-4 text-xs text-txt-muted">
 <p><strong>IP:</strong> {{ selectedRequest.ip_address || 'N/A' }}</p>
 <p><strong>Request ID:</strong> {{ selectedRequest.request_id || 'N/A' }}</p>
 <p><strong>Fingerprint:</strong> {{ selectedRequest.fingerprint || 'N/A' }}</p>
 <p><strong>Cache Hit:</strong> {{ selectedRequest.cache_hit ? 'Yes' : 'No' }}</p>
 </div>
 </div>
 </div>
 </div>
 </Teleport>
 </section>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import axios from 'axios'

const data = ref(null)
const loading = ref(true)

const requests = ref([])
const loadingRequests = ref(false)
const currentPage = ref(1)
const totalPages = ref(1)
const searchQuery = ref('')
const selectedRequest = ref(null)

const loadData = async () => {
 loading.value = true
 try {
 const res = await axios.get('/api/v1/admin/ai_analytics')
 if (res.data.success) {
 data.value = res.data.analytics
 }
 } catch (err) {
 console.error('Failed to load AI analytics', err)
 } finally {
 loading.value = false
 }
}

const loadRequests = async () => {
 loadingRequests.value = true
 try {
 const res = await axios.get('/api/v1/admin/ai_analytics/requests', {
 params: { page: currentPage.value, search: searchQuery.value }
 })
 if (res.data.success) {
 requests.value = res.data.requests
 currentPage.value = res.data.pagination.current_page
 totalPages.value = res.data.pagination.total_pages
 }
 } catch (err) {
 console.error('Failed to load AI requests', err)
 } finally {
 loadingRequests.value = false
 }
}

const changePage = (page) => {
 if (page < 1 || page > totalPages.value) return
 currentPage.value = page
 loadRequests()
}

const viewDetails = async (id) => {
 try {
 const res = await axios.get(`/api/v1/admin/ai_analytics/requests/${id}`)
 if (res.data.success) {
 selectedRequest.value = res.data.request
 }
 } catch (err) {
 console.error('Failed to load request details', err)
 }
}

const formatDate = (date) => date ? new Intl.DateTimeFormat('en-US', { month: 'short', day: 'numeric', hour: 'numeric', minute: '2-digit', second: '2-digit' }).format(new Date(date)) : 'N/A'

onMounted(() => {
 loadData()
 loadRequests()
})
</script>

<style scoped>
.admin-btn {
 border-radius: 8px;
 border: 1px solid rgba(255, 255, 255, 0.1);
 background: rgba(255, 255, 255, 0.05);
 padding: 0.35rem 0.6rem;
 font-size: 0.75rem;
 font-weight: 700;
 color: #cbd5e1;
 transition: all 0.15s;
}
.admin-btn:hover:not(:disabled) { border-color: rgba(109, 74, 255, 0.5); color: #fff; background: rgba(109, 74, 255, 0.15); }
.admin-btn:disabled { opacity: 0.4; cursor: not-allowed; background: rgba(255, 255, 255, 0.02); }

.custom-scrollbar::-webkit-scrollbar { width: 6px; }
.custom-scrollbar::-webkit-scrollbar-track { background: transparent; }
.custom-scrollbar::-webkit-scrollbar-thumb { background: rgba(255, 255, 255, 0.1); border-radius: 6px; }
.custom-scrollbar::-webkit-scrollbar-thumb:hover { background: rgba(255, 255, 255, 0.2); }
</style>
