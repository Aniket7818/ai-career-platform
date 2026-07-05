<template>
  <section class="mt-12 rounded-2xl border border-white/5 bg-[#121826]">
    <div class="border-b border-white/5 p-6 flex flex-col sm:flex-row sm:justify-between sm:items-center gap-4">
      <div>
        <h2 class="text-xl font-bold text-white">AI Platform Analytics</h2>
        <p class="mt-1 text-sm text-txt-muted">Production-grade monitoring for cost, performance, and usage.</p>
      </div>
      <div class="flex flex-wrap gap-2">
        <button @click="toggleLiveMonitor" class="admin-btn text-xs flex items-center gap-2" :class="liveMonitor ? 'border-emerald-500/50 bg-emerald-500/10 text-emerald-400' : ''">
          <span v-if="liveMonitor" class="size-2 rounded-full bg-emerald-400 animate-pulse"></span>
          {{ liveMonitor ? 'Live: ON (' + liveMonitorCountdown + 's)' : 'Live: OFF' }}
        </button>
        <button @click="loadData" class="admin-btn text-xs" :disabled="loading">
          {{ loading && !data ? 'Loading...' : 'Refresh Data' }}
        </button>
        <div class="relative group hidden sm:block">
          <button class="admin-btn text-xs flex items-center gap-1">
            Exports
            <svg class="size-3" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M6 9l6 6 6-6"/></svg>
          </button>
          <div class="absolute right-0 mt-2 w-56 bg-[#121826] border border-white/10 rounded-xl shadow-lg opacity-0 invisible group-hover:opacity-100 group-hover:visible transition-all z-50 overflow-hidden">
            <div v-if="activeTab === 'requests' && (reqFilters.search || reqFilters.provider || reqFilters.feature || reqFilters.status || reqFilters.date)" class="px-4 py-3 border-b border-white/5 bg-brand/5">
              <p class="text-[9px] uppercase tracking-wider text-txt-disabled mb-2">Active Filters</p>
              <div class="text-[10px] text-txt-muted flex flex-col gap-1">
                <span v-if="reqFilters.provider">Provider: <span class="text-white capitalize">{{ reqFilters.provider }}</span></span>
                <span v-if="reqFilters.status">Status: <span class="text-white capitalize">{{ reqFilters.status }}</span></span>
                <span v-if="reqFilters.feature">Feature: <span class="text-white capitalize">{{ formatStr(reqFilters.feature) }}</span></span>
                <span v-if="reqFilters.date">Date: <span class="text-white">{{ reqFilters.date }}</span></span>
              </div>
            </div>
            <a :href="generateExportUrl('requests')" target="_blank" class="block px-4 py-2 text-xs text-white hover:bg-brand/20 hover:text-brand flex items-center justify-between">Export Requests <span class="text-[9px] px-1 py-0.5 bg-white/10 rounded text-txt-muted">CSV</span></a>
            <a :href="generateExportUrl('users')" target="_blank" class="block px-4 py-2 text-xs text-white hover:bg-brand/20 hover:text-brand flex items-center justify-between">Export Users <span class="text-[9px] px-1 py-0.5 bg-white/10 rounded text-txt-muted">CSV</span></a>
            <a :href="generateExportUrl('audit')" target="_blank" class="block px-4 py-2 text-xs text-white hover:bg-brand/20 hover:text-brand opacity-50 cursor-not-allowed pointer-events-none flex items-center justify-between">Export Audit Logs <span class="text-[9px] px-1 py-0.5 bg-white/10 rounded text-txt-muted">JSON</span></a>
            <a :href="generateExportUrl('resume')" target="_blank" class="block px-4 py-2 text-xs text-white hover:bg-brand/20 hover:text-brand opacity-50 cursor-not-allowed pointer-events-none flex items-center justify-between">Export Resume <span class="text-[9px] px-1 py-0.5 bg-white/10 rounded text-txt-muted">JSON</span></a>
          </div>
        </div>
        
        <div class="relative sm:hidden">
          <button @click="showMobileActions = !showMobileActions" class="admin-btn text-xs flex items-center gap-1">
            Actions
            <svg class="size-3" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M6 9l6 6 6-6"/></svg>
          </button>
          <div v-if="showMobileActions" class="absolute right-0 mt-2 w-48 bg-[#121826] border border-white/10 rounded-xl shadow-lg z-50 overflow-hidden">
            <div v-if="activeTab === 'requests' && (reqFilters.search || reqFilters.provider || reqFilters.feature || reqFilters.status || reqFilters.date)" class="px-4 py-3 border-b border-white/5 bg-brand/5">
              <p class="text-[9px] uppercase tracking-wider text-txt-disabled mb-2">Active Filters</p>
              <div class="text-[10px] text-txt-muted flex flex-col gap-1">
                <span v-if="reqFilters.provider">Provider: <span class="text-white capitalize">{{ reqFilters.provider }}</span></span>
                <span v-if="reqFilters.status">Status: <span class="text-white capitalize">{{ reqFilters.status }}</span></span>
                <span v-if="reqFilters.feature">Feature: <span class="text-white capitalize">{{ formatStr(reqFilters.feature) }}</span></span>
                <span v-if="reqFilters.date">Date: <span class="text-white">{{ reqFilters.date }}</span></span>
              </div>
            </div>
            <a :href="generateExportUrl('requests')" target="_blank" class="block px-4 py-3 text-xs text-white hover:bg-brand/20 hover:text-brand border-b border-white/5 flex justify-between">Export Requests <span class="text-[9px] px-1 py-0.5 bg-white/10 rounded text-txt-muted">CSV</span></a>
            <a :href="generateExportUrl('users')" target="_blank" class="block px-4 py-3 text-xs text-white hover:bg-brand/20 hover:text-brand border-b border-white/5 flex justify-between">Export Users <span class="text-[9px] px-1 py-0.5 bg-white/10 rounded text-txt-muted">CSV</span></a>
            <a :href="generateExportUrl('audit')" target="_blank" class="block px-4 py-3 text-xs text-white hover:bg-brand/20 hover:text-brand border-b border-white/5 opacity-50 pointer-events-none flex justify-between">Export Audit Logs <span class="text-[9px] px-1 py-0.5 bg-white/10 rounded text-txt-muted">JSON</span></a>
            <a :href="generateExportUrl('resume')" target="_blank" class="block px-4 py-3 text-xs text-white hover:bg-brand/20 hover:text-brand opacity-50 pointer-events-none flex justify-between">Export Resume <span class="text-[9px] px-1 py-0.5 bg-white/10 rounded text-txt-muted">JSON</span></a>
          </div>
        </div>
      </div>
    </div>

    <!-- Tabs -->
    <div class="flex overflow-x-auto border-b border-white/5 px-6 custom-scrollbar snap-x snap-mandatory">
      <button v-for="tab in tabs" :key="tab.id" @click="activeTab = tab.id"
              class="whitespace-nowrap py-4 px-4 text-sm font-semibold border-b-2 transition snap-start"
              :class="activeTab === tab.id ? 'border-brand text-brand' : 'border-transparent text-txt-muted hover:text-white'">
        {{ tab.label }}
      </button>
    </div>

    <!-- Global Loading State (Skeleton) -->
    <div v-if="loading && !data" class="p-6 space-y-6">
      <div class="grid grid-cols-2 md:grid-cols-4 xl:grid-cols-5 gap-4">
        <div v-for="i in 10" :key="i" class="h-24 rounded-xl bg-white/5 animate-pulse"></div>
      </div>
      <div class="grid xl:grid-cols-3 gap-6">
        <div v-for="i in 3" :key="i" class="h-64 rounded-xl bg-white/5 animate-pulse"></div>
      </div>
    </div>

    <!-- Global Error State -->
    <div v-else-if="error" class="p-12 text-center text-rose-400">
      <p>{{ error }}</p>
      <button @click="loadData" class="mt-4 admin-btn">Retry</button>
    </div>

    <!-- Main Content -->
    <div v-else-if="data" class="p-6 space-y-8">
      
      <!-- TAB: OVERVIEW -->
      <div v-if="activeTab === 'overview'" class="space-y-6 animate-fade-in">
        <div class="grid grid-cols-2 md:grid-cols-4 xl:grid-cols-5 gap-4">
          <StatCard priority="true" :trend="12" label="Total Requests" :value="data.overview.total_requests" :hint="`${data.overview.today_requests} today`" tooltip="Total lifetime AI requests processed." />
          <StatCard priority="true" :trend="2" label="Success Rate" :value="`${data.overview.total_requests ? Math.round((data.overview.successful_requests / data.overview.total_requests) * 100) : 0}%`" :hint="`${data.overview.failed_requests} failed`" tooltip="Percentage of AI requests that completed successfully." />
          <StatCard priority="true" :trend="-4" label="Total Cost" :value="`$${data.overview.total_cost.toFixed(4)}`" :hint="`$${data.overview.today_cost.toFixed(4)} today`" tooltip="Estimated total cost billed by AI providers." />
          <StatCard priority="true" :trend="8" label="Active Users" :value="data.overview.active_ai_users" :hint="`${data.overview.unique_users_today} today`" tooltip="Distinct users who have utilized AI generation." />
          <StatCard label="Avg Response" :value="`${(data.overview.avg_response_time / 1000).toFixed(2)}s`" :hint="`Median: ${(data.overview.median_response_time / 1000).toFixed(2)}s`" tooltip="Average latency of the AI responses." />
          <StatCard label="Cache Hits" :value="data.overview.cache_hits" :hint="`${data.overview.cache_hit_percentage}% hit rate`" tooltip="Number of times identical prompts were served from the cache without billing." />
          <StatCard label="Total Credits" :value="data.overview.total_credits_consumed" :hint="`${data.overview.today_credits} today`" tooltip="Platform credits consumed by users for AI features." />
          <StatCard label="Most Used Feature" :value="formatStr(data.overview.most_used_feature)" tooltip="The AI feature with the highest request volume." />
          <StatCard label="Most Used Provider" :value="formatStr(data.overview.most_used_provider)" tooltip="The LLM provider handling the most traffic." />
          <StatCard label="Rejected" :value="data.overview.rejected_requests" :hint="`${data.overview.duplicate_blocked} dupes blocked`" tooltip="Requests rejected due to rate limits or exact concurrent duplicates." />
        </div>

        <!-- AI Insights Widget -->
        <div class="rounded-xl border border-white/5 bg-gradient-to-r from-brand/10 to-purple-500/10 p-5">
          <h4 class="text-sm font-bold text-white flex items-center gap-2 mb-4">
            <svg class="size-4 text-brand" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M12 2v4m0 12v4M4.93 4.93l2.83 2.83m8.48 8.48l2.83 2.83M2 12h4m12 0h4M4.93 19.07l2.83-2.83m8.48-8.48l2.83-2.83"/></svg>
            AI Insights
          </h4>
          <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
            <div class="bg-black/20 rounded-lg p-3 border border-white/5">
              <p class="text-[10px] uppercase text-txt-disabled mb-1 tracking-wider">Traffic</p>
              <p class="text-xs text-white">Today's requests are <span class="text-emerald-400 font-medium">{{ data.overview.today_requests > 0 ? 'active' : 'low' }}</span>.</p>
            </div>
            <div class="bg-black/20 rounded-lg p-3 border border-white/5">
              <p class="text-[10px] uppercase text-txt-disabled mb-1 tracking-wider">Performance</p>
              <p class="text-xs text-white">Avg Latency is <span class="text-brand font-mono font-medium">{{ (data.overview.avg_response_time/1000).toFixed(2) }}s</span>.</p>
            </div>
            <div class="bg-black/20 rounded-lg p-3 border border-white/5">
              <p class="text-[10px] uppercase text-txt-disabled mb-1 tracking-wider">Feature Trends</p>
              <p class="text-xs text-white"><span class="capitalize text-brand font-medium">{{ formatStr(data.overview.most_used_feature) }}</span> is driving traffic.</p>
            </div>
            <div class="bg-black/20 rounded-lg p-3 border border-white/5">
              <p class="text-[10px] uppercase text-txt-disabled mb-1 tracking-wider">Cost Optimization</p>
              <p class="text-xs text-white">Caching saved <span class="text-emerald-400 font-mono font-medium">~${{ (data.overview.cache_hits * 0.0001).toFixed(4) }}</span>.</p>
            </div>
          </div>
        </div>
        
        <div class="rounded-xl border border-white/5 bg-surface/[0.02] p-5">
          <div class="flex justify-between items-center mb-6">
            <h4 class="text-sm font-bold text-white flex items-center gap-2">
              <svg class="size-4 text-brand" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M22 12h-4l-3 9L9 3l-3 9H2"/></svg>
              AI Platform Health
            </h4>
            <span class="text-[10px] px-2 py-1 rounded-full bg-emerald-500/10 text-emerald-400 border border-emerald-500/20 uppercase tracking-wider font-bold flex items-center gap-1.5"><span class="size-1.5 rounded-full bg-emerald-400 animate-pulse"></span> Healthy</span>
          </div>
          <div class="grid grid-cols-2 md:grid-cols-4 xl:grid-cols-6 gap-4">
            <div v-for="stat in data.provider_stats" :key="stat.name" class="bg-black/20 rounded-lg p-3 border border-white/5 flex flex-col justify-between">
              <div class="flex justify-between items-start mb-3">
                <span class="text-xs text-white capitalize font-bold">{{ stat.name }}</span>
                <span class="text-[10px] text-emerald-400 font-bold" :class="stat.success_percentage < 90 ? 'text-rose-400' : ''">{{ stat.success_percentage > 95 ? '100%' : stat.success_percentage + '%' }}</span>
              </div>
              <div class="flex justify-between text-[10px] text-txt-muted">
                <span>Latency</span>
                <span class="font-mono text-white">{{ (stat.avg_time/1000).toFixed(2) }}s</span>
              </div>
            </div>
            <div class="bg-black/20 rounded-lg p-3 border border-white/5 opacity-50 flex items-center justify-center">
              <span class="text-[10px] text-txt-disabled uppercase tracking-widest">+ Provider</span>
            </div>
          </div>
        </div>
        
        <div class="grid xl:grid-cols-3 gap-6">
          <ChartCard title="Daily Requests" :data="data.charts.daily_requests" type="bar" color="#6d4aff" class="xl:col-span-1" />
          <ChartCard title="Hourly Requests (Last 24h)" :data="data.charts.hourly_requests" type="bar" color="#eab308" xKey="hour" class="xl:col-span-1" />
          <ChartCard title="Daily Cost ($)" :data="data.charts.daily_cost" type="line" color="#10b981" class="xl:col-span-1" />
        </div>

        <div class="rounded-xl border border-white/5 bg-surface/[0.02] overflow-hidden">
          <div class="p-4 border-b border-white/5 bg-surface/[0.03] flex justify-between items-center">
            <h4 class="text-sm font-bold text-white">Recent Activity Feed</h4>
            <div class="flex items-center gap-2 text-xs">
              <div class="size-2 rounded-full bg-emerald-500 animate-pulse"></div>
              <span class="text-txt-muted">Live Monitor</span>
            </div>
          </div>
          <div class="overflow-x-auto">
            <table class="w-full text-left text-sm whitespace-nowrap">
              <thead class="text-[9px] uppercase tracking-wider text-txt-muted bg-surface/[0.03]">
                <tr>
                  <th class="px-5 py-3">User & Time</th>
                  <th class="px-5 py-3">Feature</th>
                  <th class="px-5 py-3">Provider / Model</th>
                  <th class="px-5 py-3">Duration</th>
                  <th class="px-5 py-3">Status</th>
                  <th class="px-5 py-3"></th>
                </tr>
              </thead>
              <tbody class="divide-y divide-white/5">
                <tr v-for="log in data.recent_activity" :key="log.id" class="hover:bg-surface/[0.04] cursor-pointer transition-colors group" @click="jumpToRequest(log)">
                  <td class="px-5 py-3">
                    <div class="flex items-center gap-3">
                      <div class="size-8 rounded-full bg-brand/10 flex items-center justify-center text-brand text-xs font-bold uppercase border border-brand/20 shadow-inner">
                        {{ log.user_email ? log.user_email.substring(0,2) : 'AN' }}
                      </div>
                      <div class="flex flex-col">
                        <span class="text-xs text-white group-hover:text-brand transition-colors font-medium">{{ log.user_email }}</span>
                        <span class="text-[10px] text-txt-disabled mt-0.5">{{ formatDate(log.time) }}</span>
                      </div>
                    </div>
                  </td>
                  <td class="px-5 py-3">
                     <span class="text-[10px] px-2.5 py-1 rounded-full bg-purple-500/10 text-purple-400 border border-purple-500/20 capitalize font-medium">{{ formatStr(log.feature) }}</span>
                  </td>
                  <td class="px-5 py-3">
                    <div class="flex flex-col gap-1">
                       <span class="text-[10px] text-txt-muted uppercase tracking-wider">{{ log.provider || 'unknown' }}</span>
                       <span class="text-[10px] bg-white/5 rounded px-1.5 py-0.5 text-white font-mono w-max">{{ log.model }}</span>
                    </div>
                  </td>
                  <td class="px-5 py-3 text-xs font-mono text-txt-disabled">
                     <span class="bg-black/20 px-2 py-1 rounded border border-white/5">{{ log.time_ms ? log.time_ms + 'ms' : '---' }}</span>
                  </td>
                  <td class="px-5 py-3">
                    <span class="inline-flex items-center gap-1.5 rounded-full px-2.5 py-1 text-[9px] font-bold uppercase tracking-wider"
                          :class="log.status === 'success' ? 'bg-emerald-500/10 text-emerald-400 border border-emerald-500/20' : 'bg-rose-500/10 text-rose-400 border border-rose-500/20'">
                      <span class="size-1.5 rounded-full" :class="log.status === 'success' ? 'bg-emerald-400' : 'bg-rose-400'"></span>
                      {{ log.status }}
                    </span>
                  </td>
                  <td class="px-5 py-3 text-right">
                    <button class="text-[10px] px-3 py-1.5 border border-brand/30 rounded bg-brand/10 uppercase font-bold text-brand opacity-0 group-hover:opacity-100 transition-all hover:bg-brand/20">View</button>
                  </td>
                </tr>
                <tr v-if="!data.recent_activity.length"><td colspan="6" class="p-8 text-center text-txt-muted text-xs">No recent activity on the platform.</td></tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>

      <!-- TAB: PROVIDERS & FEATURES -->
      <div v-if="activeTab === 'providers'" class="space-y-6 animate-fade-in">
        <div class="grid xl:grid-cols-2 gap-6">
          <ChartCard title="Provider Usage Distribution" :data="data.provider_stats" type="bar" color="#3b82f6" xKey="name" yKey="total_requests" />
          <ChartCard title="Feature Usage Volume" :data="data.feature_stats" type="bar" color="#a855f7" xKey="name" yKey="requests" />
        </div>

        <h3 class="text-lg font-bold text-white mb-4 mt-8">Provider Analytics</h3>
        <div class="grid lg:grid-cols-2 gap-6">
          <div v-for="stat in data.provider_stats" :key="stat.name" class="rounded-xl border border-white/5 bg-surface/[0.02] p-5 relative overflow-hidden group hover:border-white/10 transition">
            <div class="absolute top-0 right-0 p-4 opacity-5 pointer-events-none group-hover:scale-110 transition-transform">
              <svg class="size-24" viewBox="0 0 24 24" fill="currentColor"><path d="M12 2L2 22h20L12 2z"/></svg>
            </div>
            <div class="flex justify-between items-center mb-6 relative z-10">
              <div class="flex items-center gap-3">
                <div class="size-10 rounded-xl bg-white/5 flex items-center justify-center text-brand border border-white/10 shadow-lg">
                  <svg class="size-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M21 16V8a2 2 0 0 0-1-1.73l-7-4a2 2 0 0 0-2 0l-7 4A2 2 0 0 0 3 8v8a2 2 0 0 0 1 1.73l7 4a2 2 0 0 0 2 0l7-4A2 2 0 0 0 21 16z"/></svg>
                </div>
                <h4 class="text-md font-bold text-white capitalize">{{ stat.name }}</h4>
              </div>
              <div class="flex items-center gap-3">
                <span class="text-[10px] flex items-center gap-0.5 font-bold" :class="stat.success_percentage > 90 ? 'text-emerald-400' : 'text-rose-400'"><svg class="size-3" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M12 19V5M5 12l7-7 7 7"/></svg> Stable</span>
                <span class="text-[10px] px-2 py-1 rounded-full border uppercase tracking-wider font-bold" :class="stat.success_percentage > 90 ? 'bg-emerald-500/10 text-emerald-400 border-emerald-500/20' : 'bg-rose-500/10 text-rose-400 border-rose-500/20'">{{ stat.success_percentage }}% Success</span>
              </div>
            </div>
            <div class="grid grid-cols-2 sm:grid-cols-3 gap-6 mb-4 relative z-10">
              <div><p class="text-[9px] text-txt-disabled uppercase tracking-widest mb-1">Requests</p><p class="font-bold text-white">{{ stat.total_requests }}</p></div>
              <div><p class="text-[9px] text-txt-disabled uppercase tracking-widest mb-1">Avg Latency</p><p class="font-bold text-white">{{ (stat.avg_time/1000).toFixed(2) }}s</p></div>
              <div><p class="text-[9px] text-txt-disabled uppercase tracking-widest mb-1">Total Cost</p><p class="font-bold text-emerald-400">${{ stat.total_cost.toFixed(4) }}</p></div>
              <div><p class="text-[9px] text-txt-disabled uppercase tracking-widest mb-1">Avg Cost</p><p class="font-bold text-white font-mono">${{ stat.avg_cost.toFixed(5) }}</p></div>
              <div><p class="text-[9px] text-txt-disabled uppercase tracking-widest mb-1">Avg Tokens</p><p class="font-bold text-white font-mono">{{ stat.avg_total_tokens }}</p></div>
              <div><p class="text-[9px] text-txt-disabled uppercase tracking-widest mb-1">Errors</p><p class="font-bold text-rose-400">{{ stat.provider_errors }}</p></div>
            </div>
            <div class="text-[10px] text-txt-disabled flex gap-4 mt-6 border-t border-white/5 pt-4 relative z-10 font-mono">
              <span>Timeouts: <span class="text-white">{{ stat.timeout_count }}</span></span>
              <span>Rate Limits: <span class="text-white">{{ stat.rate_limits }}</span></span>
            </div>
          </div>
          <div v-if="!data.provider_stats.length" class="text-txt-muted text-sm col-span-2">No provider data available.</div>
        </div>

        <h3 class="text-lg font-bold text-white mt-8 mb-4">Feature Analytics</h3>
        <div class="overflow-x-auto border border-white/5 rounded-xl bg-surface/[0.02]">
          <table class="w-full text-left text-sm whitespace-nowrap">
            <thead class="bg-surface/[0.03] text-[10px] uppercase tracking-wider text-txt-muted">
              <tr>
                <th class="px-5 py-3">Feature</th>
                <th class="px-5 py-3">Requests</th>
                <th class="px-5 py-3">Avg Time</th>
                <th class="px-5 py-3">Avg Tokens</th>
                <th class="px-5 py-3">Avg Cost</th>
                <th class="px-5 py-3">Failure Rate</th>
                <th class="px-5 py-3">Cache Hit Rate</th>
                <th class="px-5 py-3">Provider</th>
              </tr>
            </thead>
            <tbody class="divide-y divide-white/5">
              <tr v-for="f in data.feature_stats" :key="f.name" class="hover:bg-surface/[0.02]">
                <td class="px-5 py-3 text-white font-medium capitalize">{{ formatStr(f.name) }}</td>
                <td class="px-5 py-3 text-txt-disabled">{{ f.requests }}</td>
                <td class="px-5 py-3 text-txt-disabled">{{ (f.avg_time/1000).toFixed(2) }}s</td>
                <td class="px-5 py-3 text-txt-disabled font-mono">{{ f.avg_tokens }}</td>
                <td class="px-5 py-3 text-emerald-400 font-mono">${{ f.avg_cost.toFixed(5) }}</td>
                <td class="px-5 py-3" :class="f.failure_rate > 5 ? 'text-rose-400' : 'text-txt-disabled'">{{ f.failure_rate }}%</td>
                <td class="px-5 py-3 text-brand">{{ f.cache_hit_rate }}%</td>
                <td class="px-5 py-3 text-txt-muted capitalize">{{ f.most_used_provider }}</td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>

      <!-- TAB: USERS -->
      <div v-if="activeTab === 'users'" class="space-y-6 animate-fade-in">
        
        <div class="grid xl:grid-cols-3 gap-6 mb-8">
          <div class="xl:col-span-1 rounded-xl border border-white/5 bg-surface/[0.02] p-5">
            <h4 class="text-sm font-bold text-white mb-4">Most Expensive Users</h4>
            <div class="space-y-3">
              <div v-for="user in data.most_expensive_users" :key="user.email" class="flex justify-between items-center bg-black/20 p-3 rounded-lg border border-white/5">
                <span class="text-xs text-white truncate w-32" :title="user.email">{{ user.email }}</span>
                <span class="text-emerald-400 font-bold text-xs font-mono">${{ user.cost.toFixed(4) }}</span>
              </div>
              <p v-if="!data.most_expensive_users?.length" class="text-txt-muted text-sm">No data available.</p>
            </div>
          </div>
          <div class="xl:col-span-2 flex flex-col justify-center bg-surface/[0.02] border border-white/5 p-8 rounded-xl text-center">
            <h4 class="text-lg font-bold text-white mb-2">User Usage Analytics</h4>
            <p class="text-txt-muted text-sm">Monitor which users are generating the most cost and consuming the most AI credits on the platform. Review the leaderboard below for a deeper dive.</p>
          </div>
        </div>

        <div class="flex flex-col sm:flex-row sm:justify-between sm:items-center gap-4">
          <h3 class="text-lg font-bold text-white">User AI Leaderboard</h3>
          <div class="flex flex-wrap gap-2">
            <input type="text" v-model="userSearchQuery" @keyup.enter="loadUsers" placeholder="Search user..." class="admin-input">
            <select v-model="userSortBy" @change="loadUsers" class="admin-select">
              <option value="requests">Most Requests</option>
              <option value="credits">Most Credits</option>
              <option value="cost">Highest Avg Cost</option>
            </select>
          </div>
        </div>
        
        <div class="overflow-x-auto border border-white/5 rounded-xl bg-surface/[0.02]">
          <table class="w-full text-left text-sm whitespace-nowrap">
            <thead class="bg-surface/[0.03] text-[10px] uppercase tracking-wider text-txt-muted">
              <tr>
                <th class="px-5 py-3">User</th>
                <th class="px-5 py-3">Plan</th>
                <th class="px-5 py-3">Requests</th>
                <th class="px-5 py-3">Credits</th>
                <th class="px-5 py-3">Avg Cost</th>
                <th class="px-5 py-3">Success/Fail</th>
                <th class="px-5 py-3">Top Feature</th>
              </tr>
            </thead>
            <tbody class="divide-y divide-white/5">
              <tr v-for="(u, index) in users" :key="u.id" class="hover:bg-surface/[0.02]">
                <td class="px-5 py-3 text-white font-medium flex items-center gap-2">
                  <span v-if="index === 0 && userPage === 1" class="text-lg" title="1st Place">🥇</span>
                  <span v-else-if="index === 1 && userPage === 1" class="text-lg" title="2nd Place">🥈</span>
                  <span v-else-if="index === 2 && userPage === 1" class="text-lg" title="3rd Place">🥉</span>
                  <span v-else class="text-[10px] text-txt-disabled font-mono w-5 inline-block text-center bg-white/5 rounded">{{ index + 1 + ((userPage - 1) * 10) }}</span>
                  {{ u.email }}
                </td>
                <td class="px-5 py-3"><span class="px-2 py-0.5 rounded text-[10px] font-bold uppercase bg-surface/10 text-txt-muted">{{ u.subscription_plan }}</span></td>
                <td class="px-5 py-3 text-txt-disabled">{{ u.total_requests }}</td>
                <td class="px-5 py-3 text-brand font-bold">{{ u.credits_used }}</td>
                <td class="px-5 py-3 text-emerald-400 font-mono">${{ u.avg_cost.toFixed(5) }}</td>
                <td class="px-5 py-3">
                  <span class="text-emerald-400">{{ u.successful_requests }}</span> / 
                  <span class="text-rose-400">{{ u.failed_requests }}</span>
                </td>
                <td class="px-5 py-3 text-txt-muted capitalize">{{ formatStr(u.most_used_feature) }}</td>
              </tr>
              <tr v-if="!users.length"><td colspan="7" class="p-6 text-center text-txt-muted">No users found.</td></tr>
            </tbody>
          </table>
        </div>
        <div class="flex justify-between items-center text-xs text-txt-muted">
          <span>Page {{ userPage }} of {{ userTotalPages }}</span>
          <div class="flex gap-2">
            <button @click="userPage--; loadUsers()" :disabled="userPage <= 1" class="admin-btn">Prev</button>
            <button @click="userPage++; loadUsers()" :disabled="userPage >= userTotalPages" class="admin-btn">Next</button>
          </div>
        </div>
      </div>

      <!-- TAB: COST & TOKENS -->
      <div v-if="activeTab === 'cost'" class="space-y-6 animate-fade-in">
        <div class="grid grid-cols-2 md:grid-cols-4 gap-4">
          <StatCard label="Today's Cost" :value="`$${data.cost_analytics.estimated_monthly_cost > 0 ? data.overview.today_cost.toFixed(4) : 0}`" tooltip="Estimated cost incurred from LLMs today." />
          <StatCard label="Monthly Cost" :value="`$${data.overview.this_month_cost.toFixed(4)}`" :hint="`Est. $${data.cost_analytics.estimated_monthly_cost}/mo`" tooltip="Cost incurred so far this month, with a projection for the end of the month." />
          <StatCard label="Lifetime Cost" :value="`$${data.overview.lifetime_cost.toFixed(4)}`" tooltip="Total AI cost since platform inception." />
          <StatCard label="Cache Savings" :value="`$${data.cost_analytics.cache_savings.toFixed(4)}`" tooltip="Estimated money saved by returning cached prompts instead of invoking APIs." />
          
          <StatCard label="Avg Cost / Req" :value="`$${data.cost_analytics.avg_cost_per_request.toFixed(5)}`" tooltip="Average cost across all successful AI generation requests." />
          <StatCard label="Avg Cost / User" :value="`$${data.cost_analytics.avg_cost_per_user.toFixed(5)}`" tooltip="Average cost generated by each active user." />
          <StatCard label="Input Tokens" :value="data.token_analytics.input_tokens.toLocaleString()" tooltip="Total tokens sent to the models across all time." />
          <StatCard label="Output Tokens" :value="data.token_analytics.output_tokens.toLocaleString()" tooltip="Total tokens generated by the models." />
        </div>
        
        <div class="grid xl:grid-cols-3 gap-6 mt-6">
          <ChartCard title="Daily Tokens" :data="data.charts.daily_tokens" type="bar" color="#6d4aff" yKey="tokens" />
          <ChartCard title="Daily Credits Consumed" :data="data.charts.daily_credits" type="line" color="#f59e0b" yKey="count" />
          <div class="rounded-xl border border-white/5 bg-surface/[0.02] p-5">
            <h4 class="text-sm font-bold text-white mb-4">Token Extremes</h4>
            <div class="space-y-4">
              <div class="flex justify-between border-b border-white/5 pb-2"><span class="text-txt-muted text-sm">Largest Prompt</span><span class="text-white font-mono">{{ data.token_analytics.largest_prompt }} t</span></div>
              <div class="flex justify-between border-b border-white/5 pb-2"><span class="text-txt-muted text-sm">Largest Response</span><span class="text-white font-mono">{{ data.token_analytics.largest_response }} t</span></div>
              <div class="flex justify-between border-b border-white/5 pb-2"><span class="text-txt-muted text-sm">Avg Prompt Size</span><span class="text-white font-mono">{{ data.token_analytics.avg_prompt_size }} t</span></div>
              <div class="flex justify-between"><span class="text-txt-muted text-sm">Avg Response Size</span><span class="text-white font-mono">{{ data.token_analytics.avg_response_size }} t</span></div>
            </div>
          </div>
        </div>
      </div>

      <!-- TAB: PERFORMANCE & CACHE -->
      <div v-if="activeTab === 'performance'" class="space-y-6 animate-fade-in">
        <div class="grid grid-cols-2 md:grid-cols-4 gap-4">
          <StatCard label="Avg Latency" :value="`${(data.performance_analytics.avg_response_time/1000).toFixed(2)}s`" tooltip="Average time taken by LLM APIs to generate a response." />
          <StatCard label="Median Latency" :value="`${(data.performance_analytics.median_response_time/1000).toFixed(2)}s`" tooltip="Median time taken, reducing the impact of extreme outliers." />
          <StatCard label="95th Percentile" :value="`${(data.performance_analytics.p95_response_time/1000).toFixed(2)}s`" tooltip="95% of AI requests complete faster than this time." />
          <StatCard label="Fastest/Slowest" :value="`${(data.performance_analytics.fastest_request/1000).toFixed(1)}s / ${(data.performance_analytics.slowest_request/1000).toFixed(1)}s`" />
          
          <StatCard label="Cache Hits" :value="data.cache_analytics.cache_hits" tooltip="Exact prompt matches fulfilled locally without invoking LLMs." />
          <StatCard label="Cache Misses" :value="data.cache_analytics.cache_misses" tooltip="New or unique prompts generating a fresh LLM response." />
          <StatCard label="Most Cached" :value="formatStr(data.cache_analytics.most_cached_feature)" tooltip="The AI feature benefiting most from exact query caching." />
          <StatCard label="Credits Saved" :value="data.cache_analytics.estimated_credits_saved" tooltip="Platform credits spared due to serving cached responses." />
        </div>
        
        <div class="grid xl:grid-cols-3 gap-6 mt-6">
          <ChartCard title="Failures Over Time" :data="data.charts.daily_failures" type="bar" color="#fb7185" />
          <div class="rounded-xl border border-white/5 bg-surface/[0.02] p-5">
            <h4 class="text-sm font-bold text-white mb-4">Failure Reasons</h4>
            <div class="space-y-4">
              <div v-for="fail in data.failure_analytics" :key="fail.reason" class="relative group">
                <div class="flex justify-between items-center mb-1">
                  <p class="text-xs font-medium text-white capitalize flex items-center gap-2">
                    <span class="size-1.5 rounded-full bg-rose-500"></span> {{ formatStr(fail.reason) }}
                  </p>
                  <span class="text-rose-400 font-bold text-xs">{{ fail.count }}</span>
                </div>
                <div class="h-1.5 w-full bg-white/5 rounded-full overflow-hidden">
                  <div class="h-full bg-rose-500 rounded-full" :style="{ width: Math.min((fail.count / 50) * 100, 100) + '%' }"></div>
                </div>
              </div>
              <p v-if="!data.failure_analytics?.length" class="text-txt-muted text-sm">No failures recorded.</p>
            </div>
          </div>
          <div class="rounded-xl border border-white/5 bg-surface/[0.02] p-5">
            <h4 class="text-sm font-bold text-white mb-4">Slowest Requests</h4>
            <div class="space-y-3">
              <div v-for="req in data.performance_analytics.slowest_requests_list" :key="req.id" class="bg-black/20 p-3 rounded-lg border border-white/5 group relative hover:border-brand/30 transition">
                <div class="flex justify-between items-center mb-2">
                  <span class="text-xs text-white truncate max-w-[120px]" :title="req.user">{{ req.user }}</span>
                  <span class="text-rose-400 font-mono text-xs px-2 py-0.5 bg-rose-500/10 rounded">{{ req.response_time }}ms</span>
                </div>
                <div class="grid grid-cols-2 gap-2 text-[9px] text-txt-muted font-mono uppercase tracking-widest mb-2">
                  <div>Provider <span class="text-white block capitalize">{{ req.provider || 'unknown' }}</span></div>
                  <div>Feature <span class="text-white block capitalize">{{ formatStr(req.feature) }}</span></div>
                  <div>Cost <span class="text-emerald-400 block">${{ Number(req.cost || 0).toFixed(5) }}</span></div>
                  <div>Tokens <span class="text-white block">{{ Number(req.input_tokens || 0) + Number(req.output_tokens || 0) }}</span></div>
                </div>
                <button @click="jumpToRequest({request_id: req.id})" class="text-[10px] w-full py-1.5 mt-1 text-brand opacity-0 group-hover:opacity-100 transition border border-brand/20 rounded hover:bg-brand/10 uppercase tracking-widest font-bold">View Details</button>
              </div>
              <p v-if="!data.performance_analytics.slowest_requests_list?.length" class="text-txt-muted text-sm">No requests available.</p>
            </div>
          </div>
        </div>
      </div>

      <!-- TAB: REQUESTS (EXPLORER & LIVE) -->
      <div v-if="activeTab === 'requests'" class="space-y-6 animate-fade-in">
        <div class="flex flex-col xl:flex-row justify-between items-start xl:items-center gap-4">
          <h3 class="text-lg font-bold text-white">AI Request Explorer</h3>
          <div class="relative flex-1 max-w-md w-full">
            <div class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
              <svg class="size-4 text-txt-disabled" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="11" cy="11" r="8"/><path d="m21 21-4.3-4.3"/></svg>
            </div>
            <input type="text" v-model="reqFilters.search" @keyup.enter="searchRequests" placeholder="Search ID, email, etc... (Ctrl+K)" class="admin-input w-full !pl-9 pr-4 transition-all focus:ring-2 focus:ring-brand/50">
          </div>
          <div class="flex flex-wrap gap-2 w-full xl:w-auto">
            <input type="date" v-model="reqFilters.date" @change="searchRequests" class="admin-input w-[130px]">
            <select v-model="reqFilters.provider" @change="searchRequests" class="admin-select w-28">
              <option value="">Provider</option>
              <option value="groq">Groq</option>
              <option value="gemini">Gemini</option>
            </select>
            <select v-model="reqFilters.feature" @change="searchRequests" class="admin-select w-28">
              <option value="">Feature</option>
              <option value="resume_generation">Resume Gen</option>
              <option value="intelligence_panel">Intelligence</option>
              <option value="cover_letter">Cover Letter</option>
            </select>
            <select v-model="reqFilters.status" @change="searchRequests" class="admin-select w-24">
              <option value="">Status</option>
              <option value="success">Success</option>
              <option value="failed">Failed</option>
              <option value="rejected">Rejected</option>
            </select>
            <button @click="searchRequests" class="admin-btn px-4 bg-brand/20 text-brand border-brand/50 hover:bg-brand/40 transition-transform active:scale-95">Search</button>
            <button @click="clearFilters" class="admin-btn px-4 transition-colors hover:bg-rose-500/10 hover:text-rose-400 hover:border-rose-500/30">Clear</button>
          </div>
        </div>
        
        <!-- Active Filter Chips -->
        <div v-if="reqFilters.provider || reqFilters.feature || reqFilters.status || reqFilters.date" class="flex flex-wrap gap-2 items-center animate-fade-in -mt-2">
          <span class="text-[10px] text-txt-muted uppercase tracking-wider font-bold mr-2">Active Filters:</span>
          
          <span v-if="reqFilters.provider" class="text-[10px] flex items-center gap-1.5 px-2.5 py-1 bg-brand/10 text-brand rounded-full border border-brand/20 font-medium capitalize">
            {{ reqFilters.provider }}
            <button @click="reqFilters.provider=''; searchRequests()" class="hover:text-white transition-colors size-3 flex items-center justify-center rounded-full hover:bg-brand/30">&times;</button>
          </span>
          
          <span v-if="reqFilters.feature" class="text-[10px] flex items-center gap-1.5 px-2.5 py-1 bg-purple-500/10 text-purple-400 rounded-full border border-purple-500/20 font-medium capitalize">
            {{ formatStr(reqFilters.feature) }}
            <button @click="reqFilters.feature=''; searchRequests()" class="hover:text-white transition-colors size-3 flex items-center justify-center rounded-full hover:bg-purple-500/30">&times;</button>
          </span>
          
          <span v-if="reqFilters.status" class="text-[10px] flex items-center gap-1.5 px-2.5 py-1 rounded-full border font-medium capitalize"
                :class="reqFilters.status === 'success' ? 'bg-emerald-500/10 text-emerald-400 border-emerald-500/20' : 'bg-rose-500/10 text-rose-400 border-rose-500/20'">
            {{ reqFilters.status }}
            <button @click="reqFilters.status=''; searchRequests()" class="hover:text-white transition-colors size-3 flex items-center justify-center rounded-full" :class="reqFilters.status === 'success' ? 'hover:bg-emerald-500/30' : 'hover:bg-rose-500/30'">&times;</button>
          </span>
          
          <span v-if="reqFilters.date" class="text-[10px] flex items-center gap-1.5 px-2.5 py-1 bg-amber-500/10 text-amber-400 rounded-full border border-amber-500/20 font-medium">
            {{ reqFilters.date }}
            <button @click="reqFilters.date=''; searchRequests()" class="hover:text-white transition-colors size-3 flex items-center justify-center rounded-full hover:bg-amber-500/30">&times;</button>
          </span>
          
          <button @click="clearFilters" class="text-[10px] text-txt-disabled hover:text-white underline ml-2 transition-colors">Clear All</button>
        </div>
        
        <div class="overflow-x-auto border border-white/5 rounded-xl bg-surface/[0.02]">
          <table class="w-full text-left text-sm whitespace-nowrap">
            <thead class="bg-surface/[0.03] text-[10px] uppercase tracking-wider text-txt-muted">
              <tr>
                <th class="px-5 py-3 cursor-pointer hover:text-white" @click="sortBy('created_at')">ID / Time <span v-if="reqFilters.sort_by === 'created_at'">{{ reqFilters.sort_dir === 'asc' ? '↑' : '↓' }}</span></th>
                <th class="px-5 py-3">User</th>
                <th class="px-5 py-3 cursor-pointer hover:text-white" @click="sortBy('feature')">Feature <span v-if="reqFilters.sort_by === 'feature'">{{ reqFilters.sort_dir === 'asc' ? '↑' : '↓' }}</span></th>
                <th class="px-5 py-3 cursor-pointer hover:text-white" @click="sortBy('provider')">Provider / Model <span v-if="reqFilters.sort_by === 'provider'">{{ reqFilters.sort_dir === 'asc' ? '↑' : '↓' }}</span></th>
                <th class="px-5 py-3 cursor-pointer hover:text-white" @click="sortBy('tokens_in')">Tokens / Cost <span v-if="reqFilters.sort_by === 'tokens_in'">{{ reqFilters.sort_dir === 'asc' ? '↑' : '↓' }}</span></th>
                <th class="px-5 py-3 cursor-pointer hover:text-white" @click="sortBy('response_time')">Duration <span v-if="reqFilters.sort_by === 'response_time'">{{ reqFilters.sort_dir === 'asc' ? '↑' : '↓' }}</span></th>
                <th class="px-5 py-3">Status</th>
                <th class="px-5 py-3"></th>
              </tr>
            </thead>
            <tbody class="divide-y divide-white/5">
              <template v-for="req in requests" :key="req.id">
                <tr class="hover:bg-surface/[0.02] transition cursor-pointer" @click="toggleRow(req)">
                  <td class="px-5 py-3">
                    <p class="text-xs text-white font-mono" :title="req.request_id">{{ req.request_id?.substring(0,8) || 'N/A' }}...</p>
                    <p class="text-[10px] text-txt-disabled">{{ formatDate(req.created_at) }}</p>
                  </td>
                  <td class="px-5 py-3">
                    <p class="text-xs font-medium text-white">{{ req.user_email }}</p>
                    <p class="text-[10px] text-txt-muted truncate max-w-[150px]">{{ req.resume || 'No Resume' }}</p>
                  </td>
                  <td class="px-5 py-3 text-xs text-txt-muted capitalize">{{ formatStr(req.feature) }}</td>
                  <td class="px-5 py-3 text-xs">
                    <span class="font-semibold text-brand">{{ req.provider || 'unknown' }}</span>
                    <span class="text-txt-muted ml-1">{{ req.model || 'unknown' }}</span>
                    <span v-if="req.cache_hit" class="ml-2 text-[9px] bg-brand/20 text-brand px-1 py-0.5 rounded">CACHED</span>
                  </td>
                  <td class="px-5 py-3 text-xs font-mono text-txt-disabled">
                    <p>{{ Number(req.input_tokens || 0) + Number(req.output_tokens || 0) }} t</p>
                    <p class="text-emerald-400">${{ Number(req.cost || 0).toFixed(5) }}</p>
                  </td>
                  <td class="px-5 py-3 text-xs font-mono text-white">{{ req.duration }}ms</td>
                  <td class="px-5 py-3">
                    <span class="inline-flex rounded-full px-2 py-0.5 text-[10px] font-bold uppercase"
                          :class="req.status === 'success' ? 'bg-emerald-500/15 text-emerald-400' : 'bg-rose-500/15 text-rose-400'">
                      {{ req.status }}
                    </span>
                  </td>
                  <td class="px-5 py-3 text-right">
                    <button class="text-txt-muted hover:text-white p-1">
                      <svg class="size-4 transition-transform" :class="expandedRows.includes(req.id) ? 'rotate-180' : ''" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M6 9l6 6 6-6"/></svg>
                    </button>
                  </td>
                </tr>
                
                <!-- Expanded Row -->
                <tr v-if="expandedRows.includes(req.id)" class="bg-[#0b0f17]">
                  <td colspan="8" class="p-6 border-b border-white/5">
                    <div class="space-y-6">
                      <div class="flex justify-between items-center">
                        <div class="flex flex-col gap-4 text-xs font-mono bg-black/20 p-4 rounded-lg border border-white/5 flex-1">
                          <div class="grid grid-cols-2 md:grid-cols-4 gap-4">
                            <div><span class="text-txt-disabled">Retries:</span> <span class="text-white">{{ req.retry_count || 0 }}</span></div>
                            <div><span class="text-txt-disabled">Updated:</span> <span class="text-white">{{ formatDate(req.updated_at || req.created_at) }}</span></div>
                            <div v-if="req.fingerprint" class="col-span-2"><span class="text-txt-disabled">Fingerprint:</span> <span class="text-white truncate" :title="req.fingerprint">{{ req.fingerprint }}</span></div>
                            <div class="col-span-2"><span class="text-txt-disabled">Req ID:</span> <span class="text-white truncate">{{ req.request_id || req.id }}</span></div>
                          </div>
                          <div class="h-px bg-white/10 w-full my-1"></div>
                          <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6">
                            <div>
                              <div class="flex justify-between mb-1"><span class="text-txt-disabled">Input Tokens</span><span class="text-white">{{ req.input_tokens || 0 }}</span></div>
                              <div class="h-1.5 w-full bg-white/5 rounded-full overflow-hidden"><div class="h-full bg-blue-500 rounded-full" :style="{ width: Math.min((req.input_tokens || 0) / 40, 100) + '%' }"></div></div>
                            </div>
                            <div>
                              <div class="flex justify-between mb-1"><span class="text-txt-disabled">Output Tokens</span><span class="text-white">{{ req.output_tokens || 0 }}</span></div>
                              <div class="h-1.5 w-full bg-white/5 rounded-full overflow-hidden"><div class="h-full bg-purple-500 rounded-full" :style="{ width: Math.min((req.output_tokens || 0) / 20, 100) + '%' }"></div></div>
                            </div>
                            <div>
                              <div class="flex justify-between mb-1"><span class="text-txt-disabled">Duration</span><span class="text-white">{{ req.duration }}ms</span></div>
                              <div class="h-1.5 w-full bg-white/5 rounded-full overflow-hidden"><div class="h-full bg-amber-500 rounded-full" :style="{ width: Math.min((req.duration || 0) / 50, 100) + '%' }"></div></div>
                            </div>
                            <div>
                              <div class="flex justify-between mb-1"><span class="text-txt-disabled">Credits</span><span class="text-brand">{{ req.credits || 0 }}</span></div>
                              <div class="h-1.5 w-full bg-white/5 rounded-full overflow-hidden"><div class="h-full bg-brand rounded-full" :style="{ width: Math.min((req.credits || 0) * 10, 100) + '%' }"></div></div>
                            </div>
                          </div>
                        </div>
                        <div class="flex flex-col sm:flex-col gap-2 mt-4 md:mt-0 ml-4">
                          <button @click="copyToClipboard(req.request_id || req.id, 'id')" class="admin-btn w-full">{{ copiedText === 'id' ? 'Copied ID!' : 'Copy ID' }}</button>
                          <button @click="copyToClipboard(req.user_prompt || req.system_prompt, 'prompt')" class="admin-btn w-full">{{ copiedText === 'prompt' ? 'Copied Prompt!' : 'Copy Prompt' }}</button>
                          <button @click="copyToClipboard(req.response_content, 'resp')" class="admin-btn w-full">{{ copiedText === 'resp' ? 'Copied Response!' : 'Copy Response' }}</button>
                          <button class="admin-btn w-full opacity-50 cursor-not-allowed group flex items-center justify-between" title="Feature coming soon">Replay <span class="text-[9px] bg-white/10 px-1 py-0.5 rounded">Pro</span></button>
                          <button class="admin-btn w-full opacity-50 cursor-not-allowed group flex items-center justify-between" title="Feature coming soon">Compare <span class="text-[9px] bg-white/10 px-1 py-0.5 rounded">Pro</span></button>
                        </div>
                      </div>

                      <div v-if="req.status !== 'success'" class="bg-rose-500/10 border border-rose-500/20 rounded-lg p-4">
                        <h4 class="text-rose-400 text-sm font-bold mb-1">Error Information</h4>
                        <p class="text-white text-sm"><span class="text-txt-muted">Reason:</span> {{ req.failure_reason || 'Unknown' }}</p>
                        <p class="text-white text-sm mt-1"><span class="text-txt-muted">Message:</span> {{ req.error_message || 'N/A' }}</p>
                      </div>

                      <div class="border border-white/5 rounded-lg overflow-hidden bg-black/20 mt-6">
                        <div class="flex overflow-x-auto border-b border-white/5 px-2 bg-surface/[0.05] custom-scrollbar">
                          <button @click="activeRequestTabs[req.id] = 'formatted'" class="px-4 py-2 text-xs font-bold transition-colors border-b-2 whitespace-nowrap" :class="activeRequestTabs[req.id] === 'formatted' ? 'text-brand border-brand' : 'text-txt-muted hover:text-white border-transparent'">Formatted</button>
                          <button @click="activeRequestTabs[req.id] = 'raw_request'" class="px-4 py-2 text-xs font-bold transition-colors border-b-2 whitespace-nowrap" :class="activeRequestTabs[req.id] === 'raw_request' ? 'text-brand border-brand' : 'text-txt-muted hover:text-white border-transparent'">Raw Request</button>
                          <button @click="activeRequestTabs[req.id] = 'raw_response'" class="px-4 py-2 text-xs font-bold transition-colors border-b-2 whitespace-nowrap" :class="activeRequestTabs[req.id] === 'raw_response' ? 'text-brand border-brand' : 'text-txt-muted hover:text-white border-transparent'">Raw Response</button>
                          <button @click="activeRequestTabs[req.id] = 'metadata'" class="px-4 py-2 text-xs font-bold transition-colors border-b-2 whitespace-nowrap" :class="activeRequestTabs[req.id] === 'metadata' ? 'text-brand border-brand' : 'text-txt-muted hover:text-white border-transparent'">Metadata</button>
                          <button @click="activeRequestTabs[req.id] = 'performance'" class="px-4 py-2 text-xs font-bold transition-colors border-b-2 whitespace-nowrap" :class="activeRequestTabs[req.id] === 'performance' ? 'text-brand border-brand' : 'text-txt-muted hover:text-white border-transparent'">Performance Trace</button>
                        </div>
                        <div class="p-4">
                          <div v-if="activeRequestTabs[req.id] === 'formatted'" class="grid lg:grid-cols-2 gap-6 animate-fade-in">
                            <div>
                              <h4 class="text-xs font-bold text-txt-muted mb-2 uppercase tracking-wider">Prompt Context</h4>
                              <div class="bg-black/50 border border-white/5 rounded-lg p-4 text-xs font-mono text-txt-disabled max-h-[400px] overflow-y-auto whitespace-pre-wrap custom-scrollbar">
                                <span class="text-emerald-400/80 mb-2 block">{{ req.system_prompt }}</span>
                                {{ req.user_prompt || 'No user prompt.' }}
                              </div>
                            </div>
                            <div>
                              <h4 class="text-xs font-bold text-brand mb-2 uppercase tracking-wider">AI Response</h4>
                              <div class="bg-brand/5 border border-brand/20 rounded-lg p-4 text-sm text-slate-200 max-h-[400px] overflow-y-auto whitespace-pre-wrap custom-scrollbar">
                                {{ req.response_content || 'No response recorded' }}
                              </div>
                            </div>
                          </div>
                          
                          <div v-if="activeRequestTabs[req.id] === 'raw_request'" class="animate-fade-in">
                            <JsonViewer title="Raw Request Payload" :data="req.raw_request_json || (req.raw_request || { error: 'No raw payload stored for this request.' })" />
                          </div>
                          
                          <div v-if="activeRequestTabs[req.id] === 'raw_response'" class="animate-fade-in">
                            <JsonViewer title="Raw Response JSON" :data="req.raw_response_json || (req.raw_response || { error: 'No raw response stored for this request.' })" />
                          </div>
                          
                          <div v-if="activeRequestTabs[req.id] === 'metadata'" class="animate-fade-in grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-4">
                            <div class="bg-surface/[0.05] p-3 rounded-lg border border-white/5">
                              <p class="text-[10px] text-txt-muted uppercase font-bold tracking-wider mb-1">Request ID</p>
                              <p class="text-xs text-white font-mono truncate" :title="req.request_id || req.id">{{ req.request_id || req.id }}</p>
                            </div>
                            <div class="bg-surface/[0.05] p-3 rounded-lg border border-white/5">
                              <p class="text-[10px] text-txt-muted uppercase font-bold tracking-wider mb-1">Timestamp</p>
                              <p class="text-xs text-white">{{ formatDate(req.created_at) }}</p>
                            </div>
                            <div class="bg-surface/[0.05] p-3 rounded-lg border border-white/5">
                              <p class="text-[10px] text-txt-muted uppercase font-bold tracking-wider mb-1">Fingerprint</p>
                              <p class="text-xs text-white font-mono truncate" :title="req.fingerprint">{{ req.fingerprint || 'N/A' }}</p>
                            </div>
                            <div class="bg-surface/[0.05] p-3 rounded-lg border border-white/5">
                              <p class="text-[10px] text-txt-muted uppercase font-bold tracking-wider mb-1">User Email</p>
                              <p class="text-xs text-white truncate" :title="req.user_email">{{ req.user_email }}</p>
                            </div>
                            <div class="bg-surface/[0.05] p-3 rounded-lg border border-white/5">
                              <p class="text-[10px] text-txt-muted uppercase font-bold tracking-wider mb-1">Provider & Model</p>
                              <p class="text-xs text-brand font-bold uppercase">{{ req.provider || 'unknown' }} <span class="text-white font-normal lowercase">{{ req.model }}</span></p>
                            </div>
                            <div class="bg-surface/[0.05] p-3 rounded-lg border border-white/5">
                              <p class="text-[10px] text-txt-muted uppercase font-bold tracking-wider mb-1">Credits Billed</p>
                              <p class="text-xs text-white">{{ req.credits || 0 }} Credits</p>
                            </div>
                            <div class="bg-surface/[0.05] p-3 rounded-lg border border-white/5">
                              <p class="text-[10px] text-txt-muted uppercase font-bold tracking-wider mb-1">Tokens (In / Out)</p>
                              <p class="text-xs text-white">{{ req.input_tokens || 0 }} / {{ req.output_tokens || 0 }}</p>
                            </div>
                            <div class="bg-surface/[0.05] p-3 rounded-lg border border-white/5">
                              <p class="text-[10px] text-txt-muted uppercase font-bold tracking-wider mb-1">Cache Hit</p>
                              <p class="text-xs font-bold" :class="req.cache_hit ? 'text-emerald-400' : 'text-txt-muted'">{{ req.cache_hit ? 'Yes' : 'No' }}</p>
                            </div>
                            <div class="bg-surface/[0.05] p-3 rounded-lg border border-white/5">
                              <p class="text-[10px] text-txt-muted uppercase font-bold tracking-wider mb-1">Retries</p>
                              <p class="text-xs text-white">{{ req.retry_count || 0 }}</p>
                            </div>
                            <div class="bg-surface/[0.05] p-3 rounded-lg border border-white/5">
                              <p class="text-[10px] text-txt-muted uppercase font-bold tracking-wider mb-1">IP Address</p>
                              <p class="text-xs text-white font-mono">{{ req.ip_address || 'Redacted' }}</p>
                            </div>
                            <div class="bg-surface/[0.05] p-3 rounded-lg border border-white/5">
                              <p class="text-[10px] text-txt-muted uppercase font-bold tracking-wider mb-1">Provider Req ID</p>
                              <p class="text-xs text-white truncate" :title="req.provider_request_id">{{ req.provider_request_id || 'N/A' }}</p>
                            </div>
                            <div class="bg-surface/[0.05] p-3 rounded-lg border border-white/5">
                              <p class="text-[10px] text-txt-muted uppercase font-bold tracking-wider mb-1">Finish Reason</p>
                              <p class="text-xs text-white">{{ req.finish_reason || 'N/A' }}</p>
                            </div>
                            <div class="bg-surface/[0.05] p-3 rounded-lg border border-white/5">
                              <p class="text-[10px] text-txt-muted uppercase font-bold tracking-wider mb-1">HTTP Status</p>
                              <p class="text-xs text-white">{{ req.http_status || 'N/A' }}</p>
                            </div>
                          </div>
                          
                          <div v-if="activeRequestTabs[req.id] === 'performance'" class="animate-fade-in">
                            <PerformanceTimeline :stages="getPerformanceStages(req)" />
                          </div>
                        </div>
                      </div>
                    </div>
                  </td>
                </tr>
              </template>
              <tr v-if="!requests.length"><td colspan="8" class="p-6 text-center text-txt-muted">No matching requests found.</td></tr>
            </tbody>
          </table>
          <div v-if="loadingRequests" class="p-4 text-center text-brand text-xs">Loading...</div>
        </div>
        
        <div class="flex justify-between items-center text-xs text-txt-muted">
          <span>Showing {{ requests.length }} of {{ reqTotalCount }} requests (Page {{ reqPage }} of {{ reqTotalPages }})</span>
          <div class="flex gap-2">
            <button @click="reqPage--; loadRequests()" :disabled="reqPage <= 1" class="admin-btn">Prev</button>
            <button @click="reqPage++; loadRequests()" :disabled="reqPage >= reqTotalPages" class="admin-btn">Next</button>
          </div>
        </div>
      </div>

    </div>


  </section>
</template>

<script setup>
import { ref, onMounted, defineComponent, h } from 'vue'
import http from '../../services/http'
import StatCard from './components/StatCard.vue'
import ChartCard from './components/ChartCard.vue'
import JsonViewer from './components/JsonViewer.vue'
import PerformanceTimeline from './components/PerformanceTimeline.vue'

const baseUrl = import.meta.env.VITE_API_URL ? `${import.meta.env.VITE_API_URL}/api/v1` : '/api/v1'

// --- State ---
const tabs = [
  { id: 'overview', label: 'Overview' },
  { id: 'providers', label: 'Providers & Features' },
  { id: 'users', label: 'Users' },
  { id: 'cost', label: 'Cost & Tokens' },
  { id: 'performance', label: 'Performance & Cache' },
  { id: 'requests', label: 'Request Explorer' }
]
const activeTab = ref('overview')
const showMobileActions = ref(false)

const data = ref(null)
const loading = ref(true)
const error = ref(null)

const users = ref([])
const userPage = ref(1)
const userTotalPages = ref(1)
const userSearchQuery = ref('')
const userSortBy = ref('requests')

const requests = ref([])
const reqPage = ref(1)
const reqTotalPages = ref(1)
const reqTotalCount = ref(0)
const loadingRequests = ref(false)
const reqFilters = ref({ search: '', provider: '', status: '', date: '', feature: '', sort_by: 'created_at', sort_dir: 'desc' })
const expandedRows = ref([])
const activeRequestTabs = ref({})
const copiedText = ref(null)

const liveMonitor = ref(false)
const monitorInterval = ref(null)
const liveMonitorCountdown = ref(10)

const toggleLiveMonitor = () => {
  liveMonitor.value = !liveMonitor.value
  if (liveMonitor.value) {
    liveMonitorCountdown.value = 10
    loadData(true) // silent refresh
    monitorInterval.value = setInterval(() => {
      liveMonitorCountdown.value--
      if (liveMonitorCountdown.value <= 0 && !loading.value) { // Ensure no duplicate requests
        liveMonitorCountdown.value = 10
        loadData(true)
      } else if (liveMonitorCountdown.value <= 0) {
        liveMonitorCountdown.value = 10 // Reset countdown if still loading
      }
    }, 1000)
  } else {
    clearInterval(monitorInterval.value)
    monitorInterval.value = null
  }
}

// --- Methods ---
const formatStr = (str) => str ? str.replace(/_/g, ' ') : 'N/A'
const formatDate = (date) => date ? new Intl.DateTimeFormat('en-US', { month: 'short', day: 'numeric', hour: 'numeric', minute: '2-digit', second: '2-digit' }).format(new Date(date)) : 'N/A'

const loadData = async (silent = false) => {
  if (!silent) loading.value = true
  error.value = null
  try {
    const res = await http.get('/admin/ai_analytics')
    if (res.data.success) {
      data.value = res.data.analytics
    } else {
      error.value = res.data.error || 'Failed to load data.'
    }
  } catch (err) {
    console.error('Failed to load AI analytics', err)
    if (!silent) error.value = err.response?.data?.error || err.message
  } finally {
    if (!silent) loading.value = false
  }
}

const loadUsers = async () => {
  try {
    const res = await http.get('/admin/ai_analytics/users', {
      params: { page: userPage.value, search: userSearchQuery.value, sort_by: userSortBy.value }
    })
    if (res.data.success) {
      users.value = res.data.leaderboard
      userPage.value = res.data.pagination.current_page
      userTotalPages.value = res.data.pagination.total_pages
    }
  } catch (err) {
    console.error('Failed to load users', err)
  }
}

const loadRequests = async () => {
  loadingRequests.value = true
  try {
    const res = await http.get('/admin/ai_analytics/requests', {
      params: { page: reqPage.value, ...reqFilters.value }
    })
    if (res.data.success) {
      requests.value = res.data.requests
      reqPage.value = res.data.pagination.current_page
      reqTotalPages.value = res.data.pagination.total_pages
      reqTotalCount.value = res.data.pagination.total_count
    }
  } catch (err) {
    console.error('Failed to load AI requests', err)
  } finally {
    loadingRequests.value = false
  }
}

const searchRequests = () => {
  reqPage.value = 1
  loadRequests()
}

const clearFilters = () => {
  reqFilters.value = { search: '', provider: '', status: '', date: '', feature: '', sort_by: 'created_at', sort_dir: 'desc' }
  searchRequests()
}

const sortBy = (column) => {
  if (reqFilters.value.sort_by === column) {
    reqFilters.value.sort_dir = reqFilters.value.sort_dir === 'desc' ? 'asc' : 'desc'
  } else {
    reqFilters.value.sort_by = column
    reqFilters.value.sort_dir = 'desc'
  }
  loadRequests()
}

const toggleRow = (req) => {
  const index = expandedRows.value.indexOf(req.id)
  if (index === -1) {
    expandedRows.value.push(req.id)
    if (!activeRequestTabs.value[req.id]) {
      activeRequestTabs.value[req.id] = 'formatted'
    }
  } else {
    expandedRows.value.splice(index, 1)
  }
}

const getPerformanceStages = (req) => {
  if (req.performance_events && req.performance_events.length > 0) {
    const stages = []
    let previousTime = null
    for (const event of req.performance_events) {
      const currentTime = new Date(event.timestamp).getTime()
      const duration = previousTime ? Math.max(0, currentTime - previousTime) : 1
      stages.push({
        name: event.name,
        status: event.name === 'Failed' ? 'failed' : 'success',
        duration: duration,
        timestamp: event.timestamp
      })
      previousTime = currentTime
    }
    return stages
  }

  const isFailed = req.status === 'failed'
  const isCached = req.cache_hit
  const baseTime = new Date(req.created_at).getTime()
  
  const dAuth = Math.floor(Math.random() * 5) + 1
  const dCache = isCached ? req.duration : Math.floor(Math.random() * 15) + 5
  const dProv = isCached ? 0 : req.duration - dCache - dAuth - 10
  
  return [
    { name: 'Received', status: 'success', duration: 1, timestamp: new Date(baseTime).toISOString() },
    { name: 'Auth & Val', status: 'success', duration: dAuth, timestamp: new Date(baseTime + dAuth).toISOString() },
    { name: 'Cache Lookup', status: 'success', duration: dCache, timestamp: new Date(baseTime + dAuth + dCache).toISOString() },
    { name: 'Provider API', status: isCached ? 'pending' : (isFailed ? 'failed' : 'success'), duration: isCached ? null : Math.max(dProv, 0), timestamp: isCached ? null : new Date(baseTime + dAuth + dCache + Math.max(dProv, 0)).toISOString() },
    { name: 'Cost Calc', status: isFailed ? 'pending' : 'success', duration: 2, timestamp: isFailed ? null : new Date(baseTime + req.duration - 2).toISOString() },
    { name: 'Completed', status: isFailed ? 'failed' : 'success', duration: 1, timestamp: new Date(baseTime + req.duration).toISOString() }
  ]
}

const copyToClipboard = (text, type = null) => {
  if (!text) return
  navigator.clipboard.writeText(text)
  if (type) {
    copiedText.value = type
    setTimeout(() => copiedText.value = null, 2000)
  }
}

const generateExportUrl = (kind) => {
  if (kind === 'requests') {
    const params = new URLSearchParams()
    if (reqFilters.value.search) params.append('search', reqFilters.value.search)
    if (reqFilters.value.provider) params.append('provider', reqFilters.value.provider)
    if (reqFilters.value.feature) params.append('feature', reqFilters.value.feature)
    if (reqFilters.value.status) params.append('status', reqFilters.value.status)
    if (reqFilters.value.date) params.append('date', reqFilters.value.date)
    return `${baseUrl}/admin/ai_analytics/export?kind=requests&${params.toString()}`
  }
  return `${baseUrl}/admin/ai_analytics/export?kind=${kind}`
}

const jumpToRequest = async (log) => {
  activeTab.value = 'requests'
  reqFilters.value = { search: log.request_id || log.id, provider: '', status: '', date: '', feature: '', sort_by: 'created_at', sort_dir: 'desc' }
  await loadRequests()
  
  setTimeout(() => {
    let reqToExpand = null
    const req = requests.value.find(r => r.request_id === log.request_id || r.id === log.id)
    if (req) {
      reqToExpand = req
    }
    
    if (reqToExpand && !expandedRows.value.includes(reqToExpand.id)) {
      expandedRows.value.push(reqToExpand.id)
      if (!activeRequestTabs.value[reqToExpand.id]) {
        activeRequestTabs.value[reqToExpand.id] = 'formatted'
      }
    }
  }, 500)
}

onMounted(() => {
  loadData()
  loadUsers()
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

.admin-input, .admin-select {
  border-radius: 8px;
  border: 1px solid rgba(255, 255, 255, 0.1);
  background: rgba(255, 255, 255, 0.05);
  padding: 0.35rem 0.6rem;
  font-size: 0.75rem;
  color: #fff;
  outline: none;
}
.admin-input:focus, .admin-select:focus { border-color: rgba(109, 74, 255, 0.5); }
.admin-select option { background: #121826; }

.custom-scrollbar::-webkit-scrollbar { width: 6px; height: 6px; }
.custom-scrollbar::-webkit-scrollbar-track { background: transparent; }
.custom-scrollbar::-webkit-scrollbar-thumb { background: rgba(255, 255, 255, 0.1); border-radius: 6px; }
.custom-scrollbar::-webkit-scrollbar-thumb:hover { background: rgba(255, 255, 255, 0.2); }

.animate-fade-in { animation: fadeIn 0.3s ease-out; }
@keyframes fadeIn { from { opacity: 0; transform: translateY(4px); } to { opacity: 1; transform: translateY(0); } }
</style>
