<template>
 <AppShell>
 <div class="mx-auto max-w-6xl py-3 sm:py-4 lg:py-8 px-3 sm:px-4 lg:px-8 pb-safe pb-10 ">
 
  <!-- Hero Header & Horizontal Navigation (Top/Right-aligned) -->
  <header class="mb-6 pb-4 border-b border-border flex flex-col md:flex-row md:flex-wrap md:items-center md:justify-between gap-4">
    <div class="min-w-0 md:min-w-[400px] flex-1">
      <h1 class="text-xl sm:text-2xl lg:text-3xl font-extrabold tracking-tight text-txt-primary leading-tight">
        Settings
      </h1>
      <p class="text-xs sm:text-sm text-txt-muted mt-1 hidden sm:block">
        Manage your account, subscription, notifications, security, and developer tools.
      </p>
    </div>
    
    <!-- Horizontal tabs nav -->
    <nav class="flex gap-1.5 overflow-x-auto pb-1 hide-scrollbar snap-x snap-mandatory shrink-0 -mx-3 px-3 md:mx-0 md:px-0">
      <button
        @click="currentSection = 'account'"
        :class="currentSection === 'account'
          ? 'bg-brand text-white shadow-sm shadow-brand/20'
          : 'bg-surface text-txt-secondary border border-border hover:bg-surface-hover'"
        class="flex items-center gap-1.5 px-3.5 py-2 rounded-full text-xs font-semibold whitespace-nowrap shrink-0 transition-all duration-200 snap-start"
        style="min-height:36px"
      >
        <svg class="size-3.5" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2"><path stroke-linecap="round" stroke-linejoin="round" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z" /></svg>
        Account
      </button>
      <button
        @click="currentSection = 'subscription'"
        :class="currentSection === 'subscription'
          ? 'bg-brand text-white shadow-sm shadow-brand/20'
          : 'bg-surface text-txt-secondary border border-border hover:bg-surface-hover'"
        class="flex items-center gap-1.5 px-3.5 py-2 rounded-full text-xs font-semibold whitespace-nowrap shrink-0 transition-all duration-200 snap-start"
        style="min-height:36px"
      >
        <svg class="size-3.5" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2"><path stroke-linecap="round" stroke-linejoin="round" d="M3 10h18M7 15h1m4 0h1m-7 4h12a3 3 0 003-3V8a3 3 0 00-3-3H6a3 3 0 00-3 3v8a3 3 0 003 3z" /></svg>
        Subscription
      </button>
      <button
        @click="currentSection = 'notifications'"
        :class="currentSection === 'notifications'
          ? 'bg-brand text-white shadow-sm shadow-brand/20'
          : 'bg-surface text-txt-secondary border border-border hover:bg-surface-hover'"
        class="flex items-center gap-1.5 px-3.5 py-2 rounded-full text-xs font-semibold whitespace-nowrap shrink-0 transition-all duration-200 snap-start"
        style="min-height:36px"
      >
        <svg class="size-3.5" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2"><path stroke-linecap="round" stroke-linejoin="round" d="M15 17h5l-1.405-1.405A2.032 2.032 0 0118 14.158V11a6.002 6.002 0 00-4-5.659V5a2 2 0 10-4 0v.341C7.67 6.165 6 8.388 6 11v3.159c0 .538-.214 1.055-.595 1.436L4 17h5m6 0v1a3 3 0 11-6 0v-1m6 0H9" /></svg>
        Alerts
      </button>
      <button
        @click="currentSection = 'security'"
        :class="currentSection === 'security'
          ? 'bg-brand text-white shadow-sm shadow-brand/20'
          : 'bg-surface text-txt-secondary border border-border hover:bg-surface-hover'"
        class="flex items-center gap-1.5 px-3.5 py-2 rounded-full text-xs font-semibold whitespace-nowrap shrink-0 transition-all duration-200 snap-start"
        style="min-height:36px"
      >
        <svg class="size-3.5" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2"><path stroke-linecap="round" stroke-linejoin="round" d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z" /></svg>
        Security
      </button>
      <button
        v-if="isAdmin"
        @click="currentSection = 'developer'"
        :class="currentSection === 'developer'
          ? 'bg-indigo-600 text-white shadow-sm shadow-indigo-600/20'
          : 'bg-amber-50 text-amber-600 border border-dashed border-amber-300 hover:bg-amber-100/50'"
        class="flex items-center gap-1.5 px-3.5 py-2 rounded-full text-xs font-bold whitespace-nowrap shrink-0 transition-all duration-200 snap-start"
        style="min-height:36px"
      >
        <svg class="size-3.5" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2"><path stroke-linecap="round" stroke-linejoin="round" d="M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.065 2.572c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.572 1.065c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 00-1.065-2.572c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 2.572-1.065z" /><path stroke-linecap="round" stroke-linejoin="round" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" /></svg>
        Dev Tools
      </button>
    </nav>
  </header>

  <div>
    <main class="space-y-6">
 
 <!-- 1. ACCOUNT SECTION -->
 <section v-if="currentSection === 'account'" class="space-y-6 animate-fade-in">
 <div class="rounded-2xl border border-border/80 bg-surface p-6 shadow-sm ">
 <h2 class="text-xl font-bold text-txt-primary mb-6">Profile Settings</h2>
 
  <form @submit.prevent="saveProfile" class="space-y-8">
    <!-- 1. Personal Details -->
    <div class="space-y-4">
      <div class="flex items-center gap-2.5 pb-2 border-b border-border">
        <span class="grid size-8 place-items-center rounded-lg bg-brand/10 text-brand">
          <svg class="size-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
            <path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/>
            <circle cx="12" cy="7" r="4"/>
          </svg>
        </span>
        <div>
          <h3 class="text-sm font-bold text-txt-primary">Personal Details</h3>
          <p class="text-xs text-txt-muted">Your public name and professional summary.</p>
        </div>
      </div>
      
      <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
        <div>
          <label class="block text-xs font-bold text-txt-muted uppercase tracking-wider mb-2">First Name</label>
          <div class="relative rounded-xl shadow-xs">
            <div class="pointer-events-none absolute inset-y-0 left-0 flex items-center pl-3.5 z-10">
              <svg class="size-5 text-txt-muted" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                <path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/>
                <circle cx="12" cy="7" r="4"/>
              </svg>
            </div>
            <input v-model="profileForm.first_name" required type="text" class="pl-10 block w-full" />
          </div>
        </div>
        
        <div>
          <label class="block text-xs font-bold text-txt-muted uppercase tracking-wider mb-2">Last Name</label>
          <div class="relative rounded-xl shadow-xs">
            <div class="pointer-events-none absolute inset-y-0 left-0 flex items-center pl-3.5 z-10">
              <svg class="size-5 text-txt-muted" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                <path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/>
                <circle cx="12" cy="7" r="4"/>
              </svg>
            </div>
            <input v-model="profileForm.last_name" type="text" class="pl-10 block w-full" />
          </div>
        </div>
      </div>

      <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
        <div>
          <label class="block text-xs font-bold text-txt-muted uppercase tracking-wider mb-2">Job Title</label>
          <div class="relative rounded-xl shadow-xs">
            <div class="pointer-events-none absolute inset-y-0 left-0 flex items-center pl-3.5 z-10">
              <svg class="size-5 text-txt-muted" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                <rect x="2" y="7" width="20" height="14" rx="2" ry="2"/>
                <path d="M16 21V5a2 2 0 0 0-2-2h-4a2 2 0 0 0-2 2v16"/>
              </svg>
            </div>
            <input v-model="profileForm.title" type="text" placeholder="e.g. Senior Software Engineer" class="pl-10 block w-full" />
          </div>
        </div>
        
        <div>
          <label class="block text-xs font-bold text-txt-muted uppercase tracking-wider mb-2">Professional Summary / Bio</label>
          <div class="relative rounded-xl shadow-xs">
            <div class="pointer-events-none absolute inset-y-0 left-0 flex items-center pl-3.5 z-10">
              <svg class="size-5 text-txt-muted" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                <path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"/>
                <path d="M18.5 2.5a2.121 2.121 0 1 1 3 3L12 15l-4 1 1-4z"/>
              </svg>
            </div>
            <input v-model="profileForm.bio" type="text" placeholder="Brief summary of your professional background..." class="pl-10 block w-full" />
          </div>
        </div>
      </div>
    </div>

    <!-- 2. Contact Information -->
    <div class="space-y-4">
      <div class="flex items-center gap-2.5 pb-2 border-b border-border">
        <span class="grid size-8 place-items-center rounded-lg bg-brand/10 text-brand">
          <svg class="size-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
            <path d="M22 16.92v3a2 2 0 0 1-2.18 2 19.79 19.79 0 0 1-8.63-3.07 19.5 19.5 0 0 1-6-6 19.79 19.79 0 0 1-3.07-8.67A2 2 0 0 1 4.11 2h3a2 2 0 0 1 2 1.72 12.84 12.84 0 0 0 .7 2.81 2 2 0 0 1-.45 2.11L8.09 9.91a16 16 0 0 0 6 6l1.27-1.27a2 2 0 0 1 2.11-.45 12.84 12.84 0 0 0 2.81.7A2 2 0 0 1 22 16.92z"/>
          </svg>
        </span>
        <div>
          <h3 class="text-sm font-bold text-txt-primary">Contact Information</h3>
          <p class="text-xs text-txt-muted">Your contact channels and location details.</p>
        </div>
      </div>
      
      <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
        <div>
          <label class="block text-xs font-bold text-txt-muted uppercase tracking-wider mb-2">Username</label>
          <div class="relative rounded-xl shadow-xs">
            <div class="pointer-events-none absolute inset-y-0 left-0 flex items-center pl-3.5 z-10">
              <svg class="size-5 text-txt-muted" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                <circle cx="12" cy="12" r="4"/>
                <path d="M16 8v5a3 3 0 0 0 6 0v-1a10 10 0 1 0-3.92 7.94"/>
              </svg>
            </div>
            <input :value="user?.username" disabled type="text" class="pl-10 block w-full bg-background text-txt-muted cursor-not-allowed" />
          </div>
        </div>
        
        <div>
          <label class="block text-xs font-bold text-txt-muted uppercase tracking-wider mb-2">Email Address</label>
          <div class="relative rounded-xl shadow-xs">
            <div class="pointer-events-none absolute inset-y-0 left-0 flex items-center pl-3.5 z-10">
              <svg class="size-5 text-txt-muted" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                <path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z"/>
                <polyline points="22,6 12,13 2,6"/>
              </svg>
            </div>
            <input :value="user?.email" disabled type="email" class="pl-10 block w-full bg-background text-txt-muted cursor-not-allowed" />
          </div>
        </div>
      </div>

      <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
        <div>
          <label class="block text-xs font-bold text-txt-muted uppercase tracking-wider mb-2">Phone</label>
          <div class="relative rounded-xl shadow-xs">
            <div class="pointer-events-none absolute inset-y-0 left-0 flex items-center pl-3.5 z-10">
              <svg class="size-5 text-txt-muted" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                <path d="M22 16.92v3a2 2 0 0 1-2.18 2 19.79 19.79 0 0 1-8.63-3.07 19.5 19.5 0 0 1-6-6 19.79 19.79 0 0 1-3.07-8.67A2 2 0 0 1 4.11 2h3a2 2 0 0 1 2 1.72 12.84 12.84 0 0 0 .7 2.81 2 2 0 0 1-.45 2.11L8.09 9.91a16 16 0 0 0 6 6l1.27-1.27a2 2 0 0 1 2.11-.45 12.84 12.84 0 0 0 2.81.7A2 2 0 0 1 22 16.92z"/>
              </svg>
            </div>
            <input v-model="profileForm.phone" type="text" placeholder="e.g. +91 99887 76655" class="pl-10 block w-full" />
          </div>
        </div>
        
        <div>
          <label class="block text-xs font-bold text-txt-muted uppercase tracking-wider mb-2">Location</label>
          <div class="relative rounded-xl shadow-xs">
            <div class="pointer-events-none absolute inset-y-0 left-0 flex items-center pl-3.5 z-10">
              <svg class="size-5 text-txt-muted" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                <path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0z"/>
                <circle cx="12" cy="10" r="3"/>
              </svg>
            </div>
            <input v-model="profileForm.location" type="text" placeholder="e.g. Bangalore, India" class="pl-10 block w-full" />
          </div>
        </div>
      </div>
    </div>

    <!-- 3. Professional Links -->
    <div class="space-y-4">
      <div class="flex items-center gap-2.5 pb-2 border-b border-border">
        <span class="grid size-8 place-items-center rounded-lg bg-brand/10 text-brand">
          <svg class="size-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
            <path d="M10 13a5 5 0 0 0 7.54.54l3-3a5 5 0 0 0-7.07-7.07l-1.72 1.71"/>
            <path d="M14 11a5 5 0 0 0-7.54-.54l-3 3a5 5 0 0 0 7.07 7.07l1.71-1.71"/>
          </svg>
        </span>
        <div>
          <h3 class="text-sm font-bold text-txt-primary">Professional Links</h3>
          <p class="text-xs text-txt-muted">Your portfolio, GitHub, and LinkedIn profiles.</p>
        </div>
      </div>
      
      <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
        <div>
          <label class="block text-xs font-bold text-txt-muted uppercase tracking-wider mb-2">Website</label>
          <div class="relative rounded-xl shadow-xs">
            <div class="pointer-events-none absolute inset-y-0 left-0 flex items-center pl-3.5 z-10">
              <svg class="size-5 text-txt-muted" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                <circle cx="12" cy="12" r="10"/>
                <line x1="2" y1="12" x2="22" y2="12"/>
                <path d="M12 2a15.3 15.3 0 0 1 4 10 15.3 15.3 0 0 1-4 10 15.3 15.3 0 0 1-4-10 15.3 15.3 0 0 1 4-10z"/>
              </svg>
            </div>
            <input v-model="profileForm.website" type="text" placeholder="e.g. https://portfolio.dev" class="pl-10 block w-full" />
          </div>
        </div>
        
        <div>
          <label class="block text-xs font-bold text-txt-muted uppercase tracking-wider mb-2">LinkedIn Profile URL</label>
          <div class="relative rounded-xl shadow-xs">
            <div class="pointer-events-none absolute inset-y-0 left-0 flex items-center pl-3.5 z-10">
              <!-- Inline LinkedIn Icon (standard path matching other layouts) -->
              <svg class="size-5 text-txt-muted" viewBox="0 0 24 24" fill="currentColor">
                <path d="M19 0h-14c-2.761 0-5 2.239-5 5v14c0 2.761 2.239 5 5 5h14c2.762 0 5-2.239 5-5v-14c0-2.761-2.238-5-5-5zm-11 19h-3v-11h3v11zm-1.5-12.268c-.966 0-1.75-.779-1.75-1.75s.784-1.75 1.75-1.75 1.75.779 1.75 1.75-.784 1.75-1.75 1.75zm13.5 12.268h-3v-5.604c0-3.368-4-3.113-4 0v5.604h-3v-11h3v1.765c1.396-2.586 7-2.777 7 2.476v6.759z"/>
              </svg>
            </div>
            <input v-model="profileForm.linkedin" type="text" placeholder="e.g. linkedin.com/in/username" class="pl-10 block w-full" />
          </div>
        </div>
      </div>

      <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
        <div>
          <label class="block text-xs font-bold text-txt-muted uppercase tracking-wider mb-2">GitHub Profile URL</label>
          <div class="relative rounded-xl shadow-xs">
            <div class="pointer-events-none absolute inset-y-0 left-0 flex items-center pl-3.5 z-10">
              <!-- Inline GitHub Icon -->
              <svg class="size-5 text-txt-muted" viewBox="0 0 24 24" fill="currentColor">
                <path d="M12 0c-6.626 0-12 5.373-12 12 0 5.302 3.438 9.8 8.207 11.387.599.111.793-.261.793-.577v-2.234c-3.338.726-4.033-1.416-4.033-1.416-.546-1.387-1.333-1.756-1.333-1.756-1.089-.745.083-.729.083-.729 1.205.084 1.839 1.237 1.839 1.237 1.07 1.834 2.807 1.304 3.492.997.107-.775.418-1.305.762-1.604-2.665-.305-5.467-1.334-5.467-5.931 0-1.311.469-2.381 1.236-3.221-.124-.303-.535-1.524.117-3.176 0 0 1.008-.322 3.301 1.23.957-.266 1.983-.399 3.003-.404 1.02.005 2.047.138 3.006.404 2.291-1.552 3.297-1.23 3.297-1.23.653 1.653.242 2.874.118 3.176.77.84 1.235 1.911 1.235 3.221 0 4.609-2.807 5.624-5.479 5.921.43.372.823 1.102.823 2.222v3.293c0 .319.192.694.801.576 4.765-1.589 8.199-6.086 8.199-11.386 0-6.627-5.373-12-12-12z"/>
              </svg>
            </div>
            <input v-model="profileForm.github" type="text" placeholder="e.g. github.com/username" class="pl-10 block w-full" />
          </div>
        </div>
      </div>
    </div>

    <div class="pt-4 border-t border-border flex sm:justify-end">
      <button type="submit" :disabled="savingProfile" class="w-full sm:w-auto rounded-xl bg-brand px-6 py-3 text-sm font-bold text-white shadow-lg shadow-brand/20 hover:bg-brand/90 transition-all disabled:opacity-50" style="min-height:44px">
        {{ savingProfile ? 'Saving Changes...' : 'Save Profile' }}
      </button>
    </div>
  </form>
 </div>
 </section>

 <!-- 2. SUBSCRIPTION SECTION -->
 <section v-if="currentSection === 'subscription'" class="space-y-4 sm:space-y-6 animate-fade-in">
 <!-- Active Plan Card -->
 <div v-if="user" class="relative overflow-hidden rounded-2xl border border-border/80 bg-surface p-4 sm:p-6 shadow-sm ">
 <div class="absolute -right-24 -top-24 -z-10 h-72 w-72 rounded-full bg-brand/5 blur-3xl" />
 
 <div class="flex flex-col gap-4 lg:grid lg:grid-cols-12 lg:gap-6 items-stretch">
 <!-- Left Details -->
 <div class="lg:col-span-7 flex flex-col justify-between gap-4">
 <div class="space-y-2">
 <div class="flex items-center gap-2">
 <span 
 class="rounded-full px-2.5 py-0.5 text-[10px] font-bold uppercase tracking-wider text-white"
 :class="isSubscriptionExpired ? 'bg-rose-500' : 'bg-emerald-500'"
 >
 {{ isSubscriptionExpired ? 'Expired' : 'Active' }}
 </span>
 <h2 class="text-lg sm:text-xl font-extrabold text-txt-primary tracking-tight">
 {{ currentPlanName }}
 </h2>
 </div>
 
 <p class="text-xs sm:text-sm text-txt-muted">
 <span v-if="isSubscriptionExpired">Your subscription ended on <span class="font-semibold text-txt-secondary ">{{ formatDate(user.subscription_expires_at) }}</span>. Upgrade below.</span>
 <span v-else-if="user.subscription_plan !== 'free'">Active · Renews <span class="font-semibold text-txt-secondary">{{ formatDate(user.subscription_expires_at) }}</span>.</span>
 <span v-else>Upgrade below to unlock premium features and AI credits.</span>
 </p>
 </div>

 <div class="grid grid-cols-3 gap-3 border-t border-border pt-3">
 <div>
 <span class="block text-[10px] font-semibold text-txt-disabled uppercase tracking-wide">Billing</span>
 <span class="block text-sm font-bold text-txt-primary mt-0.5">{{ currentBillingCycle }}</span>
 </div>
 <div>
 <span class="block text-[10px] font-semibold text-txt-disabled uppercase tracking-wide">Price</span>
 <span class="block text-sm font-bold text-txt-primary mt-0.5">{{ currentPlanPrice }}</span>
 </div>
 <div v-if="user.subscription_plan !== 'free' && !isSubscriptionExpired">
 <span class="block text-[10px] font-semibold text-txt-disabled uppercase tracking-wide">Renews</span>
 <span class="block text-sm font-bold text-txt-primary mt-0.5">{{ formatDate(user.subscription_expires_at) }}</span>
 </div>
 </div>
 </div>

 <!-- Right AI Credits - Enhanced -->
 <div class="lg:col-span-5 flex flex-col gap-3 bg-gradient-to-br from-brand/5 to-indigo-500/5 p-4 rounded-2xl border border-brand/15 ">
 <!-- Header -->
 <div class="flex items-center justify-between">
 <div class="flex items-center gap-2">
 <span class="grid size-7 place-items-center rounded-lg bg-brand/15 text-brand">
 <svg class="size-3.5" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2"><path stroke-linecap="round" stroke-linejoin="round" d="M13 10V3L4 14h7v7l9-11h-7z" /></svg>
 </span>
 <span class="text-xs font-bold uppercase tracking-wider text-txt-secondary">AI Credits</span>
 </div>
 <span class="rounded-md bg-brand/10 px-1.5 py-0.5 text-[9px] font-bold text-brand uppercase">{{ pricingMode }}</span>
 </div>

 <!-- Big remaining number -->
 <div class="flex items-baseline gap-2">
 <span class="text-4xl font-black text-txt-primary tabular-nums transition-all duration-700">{{ remainingCreditsDisplay }}</span>
 <span class="text-xs font-bold text-txt-disabled">/ {{ totalCreditsDisplay }} total</span>
 </div>

 <!-- Progress bar with animated fill -->
 <div class="space-y-1.5">
 <div class="w-full h-2.5 bg-surface-hover rounded-full overflow-hidden">
 <div
 class="h-full rounded-full transition-all duration-700 ease-out"
 :class="creditColorClass"
 :style="{ width: `${creditPercentage}%` }"
 />
 </div>
 <div class="flex justify-between text-[10px] font-semibold text-txt-disabled">
 <span>{{ creditPercentage }}% remaining</span>
 <span v-if="user.subscription_plan !== 'free' && !isSubscriptionExpired" class="text-brand">Resets in {{ user.credits_resets_in_days ?? 12 }}d</span>
 <span v-else class="text-txt-disabled">No reset</span>
 </div>
 </div>

 <!-- Stat row: Remaining / Used / Total -->
 <div class="grid grid-cols-3 gap-2 pt-1 border-t border-brand/10">
 <div class="text-center">
 <p class="text-base font-black text-emerald-600">{{ remainingCreditsDisplay }}</p>
 <p class="text-[9px] font-bold text-txt-disabled uppercase tracking-wide mt-0.5">Remaining</p>
 </div>
 <div class="text-center border-x border-border ">
 <p class="text-base font-black text-rose-500">{{ usedCreditsDisplay }}</p>
 <p class="text-[9px] font-bold text-txt-disabled uppercase tracking-wide mt-0.5">Used</p>
 </div>
 <div class="text-center">
 <p class="text-base font-black text-txt-secondary ">{{ totalCreditsDisplay }}</p>
 <p class="text-[9px] font-bold text-txt-disabled uppercase tracking-wide mt-0.5">Total</p>
 </div>
 </div>
 </div>
 </div>

 <!-- Extra Cancel/Details toggles -->
 <div v-if="user.subscription_plan !== 'free' && !isSubscriptionExpired" class="mt-6 border-t border-border pt-4 flex flex-wrap gap-3 justify-between items-center">
 <button @click="showDetails = !showDetails" class="text-xs font-bold text-brand hover:underline flex items-center gap-1">
 <span>{{ showDetails ? 'Hide' : 'Show' }} subscription details</span>
 <svg class="size-3.5 transition-transform" :class="{'rotate-180': showDetails}" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2"><path stroke-linecap="round" stroke-linejoin="round" d="M19 9l-7 7-7-7" /></svg>
 </button>
 <button @click="cancelSubscription" class="text-xs font-bold text-rose-500 hover:text-rose-600 transition-colors">
 Cancel Active Subscription
 </button>
 </div>

 <!-- Expanded Details block -->
 <div v-show="showDetails" class="mt-4 border-t border-border pt-4 space-y-2 text-xs">
 <div class="flex justify-between py-1">
 <span class="text-txt-disabled">Subscription Started</span>
 <span class="font-bold">{{ formatDate(user.subscription_started_at) }}</span>
 </div>
 <div class="flex justify-between py-1">
 <span class="text-txt-disabled">Next Credit Reset</span>
 <span class="font-bold">{{ creditsResetDate }}</span>
 </div>
 <div v-if="user.razorpay_subscription_id" class="flex justify-between py-1">
 <span class="text-txt-disabled">Razorpay Subscription ID</span>
 <span class="font-mono bg-surface-hover px-1 py-0.5 rounded select-all">{{ user.razorpay_subscription_id }}</span>
 </div>
 </div>
 </div>

 <!-- Pricing Plans Cards -->
 <div class="space-y-4">
 <div class="flex items-center justify-between gap-3">
 <div>
 <h3 class="text-sm sm:text-base font-bold text-txt-primary">Upgrade or Switch Plans</h3>
 <p class="text-xs text-txt-muted hidden sm:block">Choose the best fit plan for your job hunt journey.</p>
 </div>
 <!-- Toggle switch -->
 <div class="inline-flex items-center gap-1.5 bg-surface-hover p-1 rounded-xl shrink-0">
 <button @click="isYearly = false" :class="!isYearly ? 'bg-surface text-txt-primary shadow-sm' : 'text-txt-muted'" class="px-3 py-1.5 text-xs font-bold rounded-lg transition-all">Monthly</button>
 <button @click="isYearly = true" :class="isYearly ? 'bg-surface text-txt-primary shadow-sm' : 'text-txt-muted'" class="px-3 py-1.5 text-xs font-bold rounded-lg transition-all flex items-center gap-1">
 <span>Yearly</span>
 <span class="bg-emerald-500 text-white text-[8px] px-1 py-px rounded font-black uppercase">Save</span>
 </button>
 </div>
 </div>

 <!-- Grid of cards -->
 <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
 <div v-for="plan in PRICING_PLANS" :key="plan.id" class="relative rounded-2xl border bg-surface p-6 shadow-sm flex flex-col justify-between transition-all hover:shadow-md " :class="isCurrentPlan(plan.id) ? 'border-brand ring-1 ring-brand ' : 'border-border'">
 <div class="space-y-4">
 <!-- Badge -->
 <span v-if="plan.badge" class="absolute -top-3 right-4 bg-brand text-white text-[9px] font-black uppercase px-2.5 py-1 rounded-full shadow-sm">
 {{ plan.badge }}
 </span>

 <h4 class="text-base font-bold text-txt-primary">{{ plan.name }}</h4>
 
 <div class="py-2">
 <span class="text-3xl font-black text-txt-primary">
 ₹{{ isYearly ? plan.yearlyPrice : plan.monthlyPrice }}
 </span>
 <span class="text-xs text-txt-disabled ml-1">
 / {{ isYearly ? 'yearly' : 'monthly' }}
 </span>
 </div>

 <!-- Features -->
 <ul class="space-y-2.5 text-xs text-txt-secondary border-t border-border pt-4">
 <li v-for="feat in plan.features" :key="feat.name" class="flex items-start gap-2">
 <span :class="feat.included ? 'text-brand' : 'text-txt-muted '" class="font-bold select-none">
 {{ feat.included ? '✓' : '✗' }}
 </span>
 <span :class="{'text-txt-disabled line-through': !feat.included}">
 {{ feat.name }}
 </span>
 </li>
 </ul>
 </div>

 <button 
 @click="handlePlanAction(plan)"
 :disabled="isCurrentPlan(plan.id) || purchasing"
 :class="[
 isCurrentPlan(plan.id)
 ? 'bg-surface-hover text-txt-muted cursor-not-allowed '
 : plan.id === 'pro'
 ? 'bg-brand text-white hover:bg-brand/95 shadow-md shadow-brand/10'
 : 'bg-surface border border-border hover:bg-background text-txt-primary '
 ]"
 class="w-full mt-5 py-3 rounded-xl text-xs font-bold transition-all" style="min-height:44px"
 >
 {{ getButtonText(plan) }}
 </button>
 </div>
 </div>
 </div>

 <!-- Credit & Billing History logs -->
 <div class="grid grid-cols-1 lg:grid-cols-2 gap-4">
 
 <!-- Left: Credit history -->
 <div class="rounded-2xl border border-border/80 bg-surface p-4 sm:p-6 shadow-sm flex flex-col justify-between">
  <div>
   <h3 class="text-sm font-bold text-txt-primary mb-3">Credit Transactions</h3>
   <!-- Skeleton loader -->
   <div v-if="loadingCredits" class="space-y-2">
   <div v-for="i in 3" :key="i" class="h-12 bg-surface-hover rounded-xl animate-pulse" />
   </div>
   <div v-else-if="creditHistory && creditHistory.length > 0" class="space-y-2 max-h-72 overflow-y-auto pr-1 custom-scrollbar">
   <div v-for="tx in creditHistory" :key="tx.id" class="flex justify-between items-center p-3 rounded-xl bg-surface-elevated/40 border border-border/50 text-xs animate-card-enter">
   <div class="min-w-0">
   <p class="font-bold text-txt-primary truncate">{{ tx.feature_name }}</p>
   <p class="text-[10px] text-txt-disabled mt-0.5">{{ formatDate(tx.created_at) }}</p>
   </div>
   <span :class="tx.action === 'add' ? 'text-emerald-600 bg-emerald-50 ' : 'text-rose-600 bg-rose-50 '" class="ml-2 shrink-0 px-2 py-1 rounded-lg font-extrabold uppercase text-[10px]">
   {{ tx.action === 'add' ? '+' : '-' }}{{ tx.credits_used }}
   </span>
   </div>
   </div>
   <!-- Premium empty state -->
   <div v-else class="flex flex-col items-center justify-center py-8 text-center">
   <div class="grid size-12 place-items-center rounded-2xl bg-surface-hover mb-3">
   <svg class="size-6 text-txt-muted " fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="1.5"><path stroke-linecap="round" stroke-linejoin="round" d="M13 10V3L4 14h7v7l9-11h-7z" /></svg>
   </div>
   <p class="text-xs font-semibold text-txt-muted">No credit transactions yet</p>
   <p class="text-[10px] text-txt-disabled mt-1">Your AI usage will appear here.</p>
   </div>
  </div>

  <!-- Pagination Controls -->
  <div v-if="totalCreditPages > 1" class="mt-4 pt-3 border-t border-border flex items-center justify-between text-xs">
    <button
      @click="changeCreditPage(currentCreditPage - 1)"
      :disabled="currentCreditPage <= 1 || loadingCredits"
      type="button"
      class="px-3 py-1.5 rounded-lg border border-border bg-surface hover:bg-background text-txt-secondary disabled:opacity-50 disabled:cursor-not-allowed font-semibold transition"
    >
      Prev
    </button>
    <span class="text-txt-muted font-medium">
      Page {{ currentCreditPage }} of {{ totalCreditPages }}
    </span>
    <button
      @click="changeCreditPage(currentCreditPage + 1)"
      :disabled="currentCreditPage >= totalCreditPages || loadingCredits"
      type="button"
      class="px-3 py-1.5 rounded-lg border border-border bg-surface hover:bg-background text-txt-secondary disabled:opacity-50 disabled:cursor-not-allowed font-semibold transition"
    >
      Next
    </button>
  </div>
 </div>

 <!-- Right: Billing invoice history -->
 <div class="rounded-2xl border border-border/80 bg-surface p-4 sm:p-6 shadow-sm ">
 <h3 class="text-sm font-bold text-txt-primary mb-3">Billing History</h3>
 <div v-if="billingHistory && billingHistory.length > 0" class="space-y-3 max-h-72 overflow-y-auto pr-1 custom-scrollbar">
 <!-- Vertically stacked card for each invoice -->
 <div v-for="item in billingHistory" :key="item.id" class="rounded-xl bg-surface-elevated/40 border border-border/50 p-3 space-y-2 animate-card-enter">
 <div class="flex items-start justify-between gap-2">
 <div class="min-w-0">
 <p class="text-xs font-bold text-txt-primary truncate">{{ item.plan_name === 'pro' ? 'CareerAI Pro' : (item.plan_name === 'plus' ? 'CareerAI Plus' : item.plan_name) }}</p>
 <p class="text-[10px] text-txt-disabled mt-0.5">{{ formatDate(item.paid_at) }} · ₹{{ Number(item.amount) }}</p>
 </div>
 <span class="shrink-0 text-[9px] uppercase px-1.5 py-0.5 font-bold rounded-md bg-emerald-100 text-emerald-700 ">{{ item.payment_status }}</span>
 </div>
 <div class="flex gap-2 pt-1 border-t border-border">
 <button @click="paymentService.downloadInvoice(item.id)" class="flex-1 py-1.5 rounded-lg border border-border bg-surface hover:bg-background text-[10px] font-bold transition" style="min-height:32px">Invoice</button>
 <button @click="paymentService.downloadReceipt(item.id)" class="flex-1 py-1.5 rounded-lg border border-border bg-surface hover:bg-background text-[10px] font-bold transition" style="min-height:32px">Receipt</button>
 </div>
 </div>
 </div>
 <!-- Premium empty state -->
 <div v-else class="flex flex-col items-center justify-center py-8 text-center">
 <div class="grid size-12 place-items-center rounded-2xl bg-surface-hover mb-3">
 <svg class="size-6 text-txt-muted " fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="1.5"><path stroke-linecap="round" stroke-linejoin="round" d="M3 10h18M7 15h1m4 0h1m-7 4h12a3 3 0 003-3V8a3 3 0 00-3-3H6a3 3 0 00-3 3v8a3 3 0 003 3z" /></svg>
 </div>
 <p class="text-xs font-semibold text-txt-muted">No billing history yet</p>
 <p class="text-[10px] text-txt-disabled mt-1">Invoices appear after your first payment.</p>
 </div>
 </div>

 </div>
 </section>

 <!-- 3. NOTIFICATIONS SECTION -->
 <section v-if="currentSection === 'notifications'" class="space-y-6 animate-fade-in">
 <div class="rounded-2xl border border-border/80 bg-surface p-6 shadow-sm ">
 <h2 class="text-xl font-bold text-txt-primary mb-2">Notification Preferences</h2>
 <p class="text-xs text-slate-550 mb-6">Choose how and when you'd like to receive updates from CareerAI.</p>
 
 <div class="space-y-4">
 <label class="flex items-start gap-3 p-4 rounded-xl hover:bg-background transition cursor-pointer">
 <input v-model="notificationPrefs.marketing" type="checkbox" class="mt-1 size-4 rounded border-slate-350 text-brand focus:ring-brand " />
 <div>
 <span class="block text-sm font-bold text-txt-primary ">Marketing & Recommendations</span>
 <span class="block text-xs text-slate-450 mt-1">Receive tips, career guide updates, promotion alerts, and feature updates.</span>
 </div>
 </label>

 <label class="flex items-start gap-3 p-4 rounded-xl hover:bg-background transition cursor-pointer">
 <input v-model="notificationPrefs.security" type="checkbox" class="mt-1 size-4 rounded border-slate-350 text-brand focus:ring-brand " />
 <div>
 <span class="block text-sm font-bold text-txt-primary ">Security & Profile Alerts</span>
 <span class="block text-xs text-slate-450 mt-1">Get immediate emails for password changes, new logins, or profile modifications.</span>
 </div>
 </label>

 <label class="flex items-start gap-3 p-4 rounded-xl hover:bg-background transition cursor-pointer">
 <input v-model="notificationPrefs.billing" type="checkbox" class="mt-1 size-4 rounded border-slate-350 text-brand focus:ring-brand " />
 <div>
 <span class="block text-sm font-bold text-txt-primary ">Billing & Renewal Notifications</span>
 <span class="block text-xs text-slate-450 mt-1">Receive invoices, purchase confirmations, subscription failures, and credit refills.</span>
 </div>
 </label>

 <label class="flex items-start gap-3 p-4 rounded-xl hover:bg-background transition cursor-pointer">
 <input v-model="notificationPrefs.digest" type="checkbox" class="mt-1 size-4 rounded border-slate-350 text-brand focus:ring-brand " />
 <div>
 <span class="block text-sm font-bold text-txt-primary ">Weekly Job Hunt Digest</span>
 <span class="block text-xs text-slate-450 mt-1">Get a weekly summary of jobs match calculations and resume health scores.</span>
 </div>
 </label>
 </div>

 <div class="pt-5 border-t border-border flex sm:justify-end">
 <button @click="saveNotificationPrefs" class="w-full sm:w-auto rounded-xl bg-brand px-6 py-3 text-sm font-bold text-white shadow-lg shadow-brand/20 hover:bg-brand/90 transition-all" style="min-height:44px">
 Save Preferences
 </button>
 </div>
 </div>
 </section>

 <!-- 4. SECURITY SECTION -->
 <section v-if="currentSection === 'security'" class="space-y-6 animate-fade-in">
 <!-- Password Form -->
 <div class="rounded-2xl border border-border/80 bg-surface p-6 shadow-sm ">
 <h2 class="text-xl font-bold text-txt-primary mb-6">Change Password</h2>
 
 <form @submit.prevent="updatePassword" class="space-y-4">
 <div>
 <label class="block text-xs font-bold text-txt-muted uppercase tracking-wider mb-2">Current Password</label>
 <input v-model="passwordForm.current_password" required type="password" class="w-full rounded-xl border border-border px-4 py-3 text-sm focus:ring-2 focus:ring-brand focus:outline-none" />
 </div>
 <div>
 <label class="block text-xs font-bold text-txt-muted uppercase tracking-wider mb-2">New Password</label>
 <input v-model="passwordForm.password" required type="password" class="w-full rounded-xl border border-border px-4 py-3 text-sm focus:ring-2 focus:ring-brand focus:outline-none" />
 </div>
 <div>
 <label class="block text-xs font-bold text-txt-muted uppercase tracking-wider mb-2">Confirm New Password</label>
 <input v-model="passwordForm.password_confirmation" required type="password" class="w-full rounded-xl border border-border px-4 py-3 text-sm focus:ring-2 focus:ring-brand focus:outline-none" />
 </div>

 <div class="pt-4 border-t border-border flex sm:justify-end">
 <button type="submit" :disabled="updatingPassword" class="w-full sm:w-auto rounded-xl bg-brand px-6 py-3 text-sm font-bold text-white shadow-lg shadow-brand/20 hover:bg-brand/90 transition-all disabled:opacity-50" style="min-height:44px">
 {{ updatingPassword ? 'Updating...' : 'Change Password' }}
 </button>
 </div>
 </form>
 </div>

 <!-- Danger Zone -->
 <div class="rounded-2xl border border-rose-200 bg-rose-50/20 p-6 shadow-sm ">
 <h2 class="text-xl font-bold text-rose-700 mb-2">Danger Zone</h2>
 <p class="text-xs text-txt-muted mb-6">Once you delete your account, there is no going back. Please be certain.</p>
 
 <div class="flex flex-col sm:flex-row sm:items-center justify-between gap-3 border-t border-rose-100 pt-4">
 <div>
 <span class="block text-sm font-bold text-txt-primary ">Delete Account</span>
 <span class="block text-xs text-slate-450 mt-1">Permanently delete your profile, credit balance, templates and resumes.</span>
 </div>
 <button @click="triggerDeleteAccount" class="w-full sm:w-auto rounded-xl bg-rose-600 px-5 py-3 text-xs font-bold text-white shadow-md shadow-rose-600/10 hover:bg-rose-700 transition-all shrink-0" style="min-height:44px">
 Delete Account...
 </button>
 </div>
 </div>
 </section>

 <!-- 5. DEVELOPER TOOLS SECTION (Admin Only) -->
 <section v-if="currentSection === 'developer' && isAdmin" class="space-y-6 animate-fade-in">
 <div class="rounded-2xl border border-amber-300 bg-amber-50/5 p-6 shadow-sm ">
 
 <div class="flex items-center gap-3 mb-4">
 <span class="grid place-items-center size-8 rounded-lg bg-amber-100 text-amber-700 font-bold text-sm">🛠️</span>
 <div>
 <h2 class="text-lg font-bold text-txt-primary">Developer Configurations</h2>
 <p class="text-xs text-txt-muted">Manage payment testing parameters and feature gates dynamically without code redeployment.</p>
 </div>
 </div>

 <!-- Payment Test Mode Panel -->
 <div class="bg-surface border border-border/80 rounded-xl p-5 space-y-5">
 <div class="flex items-start justify-between">
 <div class="space-y-1">
 <span class="text-sm font-bold text-txt-primary ">Enable Payment Test Mode</span>
 <p class="text-xs text-slate-450 ">Bypass production pricing set and force testing rate values (₹1–₹5).</p>
 </div>
 <input v-model="developerSettings.payment_test_mode" type="checkbox" class="size-5 rounded border-slate-350 text-indigo-600 focus:ring-indigo-500 cursor-pointer" />
 </div>

 <!-- Current Mode Indicator -->
 <div class="border-t border-border pt-4 flex items-center justify-between">
 <span class="text-xs font-bold text-txt-muted uppercase tracking-wider">Current Mode</span>
 <div class="flex items-center gap-3">
 <span :class="!developerSettings.payment_test_mode ? 'bg-surface-hover text-txt-secondary border-border-hover ' : 'bg-amber-500/10 text-amber-600 border-amber-500/20'" class="inline-flex items-center gap-1.5 px-3 py-1 rounded-full text-xs font-bold border">
 <span :class="!developerSettings.payment_test_mode ? 'bg-slate-400' : 'bg-amber-500 animate-ping'" class="size-2 rounded-full inline-block"></span>
 {{ !developerSettings.payment_test_mode ? 'Production Mode' : 'Testing Mode Active' }}
 </span>
 </div>
 </div>
 </div>

 <!-- Expandable feature flags -->
 <div class="mt-4 bg-surface border border-border/80 rounded-xl overflow-hidden">
 <button 
 @click="showExtraFlags = !showExtraFlags"
 type="button"
 class="w-full flex items-center justify-between p-4 text-xs font-bold uppercase tracking-wider text-txt-muted hover:bg-background transition-colors"
 >
 <span>Advanced Feature Flags ({{ Object.keys(developerSettings).length - 1 }} active)</span>
 <svg class="size-4 transition-transform" :class="{'rotate-180': showExtraFlags}" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2.5"><path stroke-linecap="round" stroke-linejoin="round" d="M19 9l-7 7-7-7" /></svg>
 </button>

 <div v-show="showExtraFlags" class="border-t border-border p-5 divide-y divide-slate-100 space-y-4">
 
 <div class="flex items-center justify-between pt-4 first:pt-0">
 <div>
 <span class="block text-sm font-semibold text-txt-primary ">Enable Debug Logs</span>
 <span class="block text-xs text-txt-disabled mt-0.5">Stream detailed Rails execution context to system logger output.</span>
 </div>
 <input v-model="developerSettings.debug_logs" type="checkbox" class="size-4 rounded border-slate-350 text-indigo-600 focus:ring-indigo-500 " />
 </div>

 <div class="flex items-center justify-between pt-4">
 <div>
 <span class="block text-sm font-semibold text-txt-primary ">Enable Fake Payment Success</span>
 <span class="block text-xs text-txt-disabled mt-0.5">Force successful verification responses for any test signatures.</span>
 </div>
 <input v-model="developerSettings.fake_payment_success" type="checkbox" class="size-4 rounded border-slate-350 text-indigo-600 focus:ring-indigo-500 " />
 </div>

 <div class="flex items-center justify-between pt-4">
 <div>
 <span class="block text-sm font-semibold text-txt-primary ">Enable Fake Payment Failure</span>
 <span class="block text-xs text-txt-disabled mt-0.5">Force failed checkouts for error state testing.</span>
 </div>
 <input v-model="developerSettings.fake_payment_failure" type="checkbox" class="size-4 rounded border-slate-350 text-indigo-600 focus:ring-indigo-500 " />
 </div>

 <div class="flex items-center justify-between pt-4">
 <div>
 <span class="block text-sm font-semibold text-txt-primary ">Enable Email Sandbox</span>
 <span class="block text-xs text-txt-disabled mt-0.5">Divert transactional mailings to in-memory mailer sandbox.</span>
 </div>
 <input v-model="developerSettings.email_sandbox" type="checkbox" class="size-4 rounded border-slate-350 text-indigo-600 focus:ring-indigo-500 " />
 </div>

 <div class="flex items-center justify-between pt-4">
 <div>
 <span class="block text-sm font-semibold text-txt-primary ">Enable AI Sandbox</span>
 <span class="block text-xs text-txt-disabled mt-0.5">Run deterministic model mocks without executing real LLM api requests.</span>
 </div>
 <input v-model="developerSettings.ai_sandbox" type="checkbox" class="size-4 rounded border-slate-350 text-indigo-600 focus:ring-indigo-500 " />
 </div>

 <div class="flex items-center justify-between pt-4">
 <div>
 <span class="block text-sm font-semibold text-txt-primary ">Maintenance Mode</span>
 <span class="block text-xs text-txt-disabled mt-0.5">Trigger 503 Service Unavailable maintenance gates across endpoints.</span>
 </div>
 <input v-model="developerSettings.maintenance_mode" type="checkbox" class="size-4 rounded border-slate-350 text-indigo-600 focus:ring-indigo-500 " />
 </div>

 <div class="flex items-center justify-between pt-4">
 <div>
 <span class="block text-sm font-semibold text-txt-primary ">Show API Timings</span>
 <span class="block text-xs text-txt-disabled mt-0.5">Inject execution and DB retrieval durations in response meta objects.</span>
 </div>
 <input v-model="developerSettings.show_api_timings" type="checkbox" class="size-4 rounded border-slate-350 text-indigo-600 focus:ring-indigo-500 " />
 </div>

 <div class="flex items-center justify-between pt-4">
 <div>
 <span class="block text-sm font-semibold text-txt-primary ">Reset Demo Data</span>
 <span class="block text-xs text-txt-disabled mt-0.5">Clean up old mock histories upon sign-in processes.</span>
 </div>
 <input v-model="developerSettings.reset_demo_data" type="checkbox" class="size-4 rounded border-slate-350 text-indigo-600 focus:ring-indigo-500 " />
 </div>

 <div class="flex items-center justify-between pt-4">
 <div>
 <span class="block text-sm font-semibold text-txt-primary ">Force Premium Access</span>
 <span class="block text-xs text-txt-disabled mt-0.5">Bypass subscription validation to allow access to AI models.</span>
 </div>
 <input v-model="developerSettings.force_premium_access" type="checkbox" class="size-4 rounded border-slate-350 text-indigo-600 focus:ring-indigo-500 " />
 </div>

 </div>
 </div>

 <!-- Save button -->
 <div class="mt-6 flex justify-end">
 <button 
 @click="saveDevSettings"
 :disabled="savingDevSettings"
 class="rounded-xl bg-indigo-600 px-6 py-3 text-sm font-bold text-white shadow-lg shadow-indigo-600/20 hover:bg-indigo-700 disabled:opacity-50 transition-all"
 >
 {{ savingDevSettings ? 'Saving Tools...' : 'Save Tools' }}
 </button>
 </div>

 </div>
 </section>

 </main>
 </div>

 <!-- Confirm Purchase Modal -->
 <Teleport to="body">
 <div v-if="selectedPlan" class="fixed inset-0 z-50 grid place-items-center bg-surface/60 p-5 backdrop-blur-sm" @click.self="selectedPlan = null">
 <div class="w-full max-w-md rounded-2xl bg-surface p-6 shadow-2xl border text-center">
 <h2 class="text-xl font-bold text-txt-primary">Confirm Purchase</h2>
 <p class="mt-2 text-sm text-slate-550 ">
 You are subscribing to <strong>{{ selectedPlan.name }}</strong> on a <strong>{{ isYearly ? 'yearly' : 'monthly' }}</strong> basis.
 </p>
 
 <div class="mt-5 rounded-xl border border-slate-205 bg-background p-6 text-center ">
 <p class="text-xs font-bold uppercase tracking-wider text-txt-disabled">Total Amount</p>
 <div class="mx-auto mt-2 text-4xl font-black text-brand">
 ₹{{ isYearly ? selectedPlan.yearlyPrice : selectedPlan.monthlyPrice }}
 </div>
 <p class="mt-1.5 text-xs text-txt-disabled ">Secure checkout via Razorpay</p>
 </div>

 <label class="mt-5 flex items-start gap-3 text-xs text-slate-505 cursor-pointer justify-center text-left">
 <input v-model="acceptedPolicies" class="mt-0.5 size-4 rounded border-slate-350 text-brand focus:ring-brand " type="checkbox" />
 <span>I agree to the <RouterLink class="text-brand hover:underline font-bold" to="/privacy">Privacy Policy</RouterLink> and <RouterLink class="text-brand hover:underline font-bold" to="/terms">Terms</RouterLink>.</span>
 </label>

 <div class="mt-6 flex gap-3">
 <button class="flex-1 rounded-xl border border-border px-4 py-3 text-sm font-bold text-txt-secondary hover:bg-background transition-colors" @click="selectedPlan = null">Cancel</button>
 <button class="flex-1 rounded-xl bg-brand px-4 py-3 text-sm font-bold text-white shadow-lg shadow-brand/20 hover:bg-brand/90 disabled:opacity-50 transition-all" :disabled="!acceptedPolicies || purchasing" @click="purchasePlan">
 {{ purchasing ? 'Processing...' : 'Pay Now' }}
 </button>
 </div>
 </div>
 </div>
 </Teleport>

 <!-- Cancel Subscription Modal -->
 <Teleport to="body">
 <div v-if="showCancelModal" class="fixed inset-0 z-50 grid place-items-center bg-surface/60 p-5 backdrop-blur-sm" @click.self="showCancelModal = false">
 <div class="w-full max-w-sm rounded-2xl bg-surface p-6 shadow-2xl border text-center">
 <div class="mx-auto grid size-12 place-items-center rounded-full bg-red-100 text-red-600 mb-4">
 <svg class="size-6" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
 <path stroke-linecap="round" stroke-linejoin="round" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z" />
 </svg>
 </div>
 <h2 class="text-xl font-bold text-txt-primary">Cancel Subscription?</h2>
 <p class="mt-2 text-sm text-txt-muted">
 You will lose access to all premium features, AI credits, and unlimited PDF downloads at the end of your billing cycle.
 </p>
 <div class="mt-6 flex gap-3">
 <button class="flex-1 rounded-xl border border-border px-4 py-3 text-sm font-bold text-txt-secondary hover:bg-background transition-colors" @click="showCancelModal = false">Keep Plan</button>
 <button class="flex-1 rounded-xl bg-red-600 px-4 py-3 text-sm font-bold text-white shadow-lg shadow-red-600/20 hover:bg-red-700 transition-colors" @click="confirmCancelSubscription">
 Yes, Cancel
 </button>
 </div>
 </div>
 </div>
 </Teleport>

 <!-- Delete Account Modal -->
 <Teleport to="body">
 <div v-if="showDeleteModal" class="fixed inset-0 z-50 grid place-items-center bg-surface/60 p-5 backdrop-blur-sm" @click.self="showDeleteModal = false">
 <div class="w-full max-w-sm rounded-2xl bg-surface p-6 shadow-2xl border text-center">
 <div class="mx-auto grid size-12 place-items-center rounded-full bg-rose-100 text-rose-600 mb-4">
 <svg class="size-6" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2"><path stroke-linecap="round" stroke-linejoin="round" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" /></svg>
 </div>
 <h2 class="text-xl font-bold text-txt-primary">Delete your Account?</h2>
 <p class="mt-2 text-sm text-txt-muted">
 This action is final. All your resumes, templates, billing logs, and remaining AI credits will be permanently removed.
 </p>
 <div class="mt-6 flex gap-3">
 <button class="flex-1 rounded-xl border border-border px-4 py-3 text-sm font-bold text-txt-secondary hover:bg-background transition-colors" @click="showDeleteModal = false">Keep Account</button>
 <button class="flex-1 rounded-xl bg-rose-600 px-4 py-3 text-sm font-bold text-white shadow-lg shadow-rose-600/20 hover:bg-rose-700 transition-colors" @click="confirmDeleteAccount">
 Permanently Delete
 </button>
 </div>
 </div>
 </div>
 </Teleport>

 </div>
 </AppShell>
</template>

<script setup>
import { computed, onMounted, ref, watch } from 'vue'
import { useStore } from 'vuex'
import { useRouter, useRoute } from 'vue-router'
import AppShell from '../../components/layout/AppShell.vue'
import { paymentService } from '../../services/paymentService'
import { adminService } from '../../services/adminService'
import { profileService } from '../../services/profileService'
import { toast } from '../../utils/toast'
import { PRICING_PLANS } from '../../constants/pricing'

const store = useStore()
const router = useRouter()
const route = useRoute()

const currentSection = ref(route.path.includes('billing') ? 'subscription' : 'account')

watch(
  () => route.path,
  (newPath) => {
    if (newPath.includes('billing')) {
      currentSection.value = 'subscription'
    } else if (newPath === '/settings') {
      currentSection.value = 'account'
    }
  }
)

const isYearly = ref(false)
const showDetails = ref(false)
const showCancelModal = ref(false)
const showDeleteModal = ref(false)
const showExtraFlags = ref(false)

const selectedPlan = ref(null)
const acceptedPolicies = ref(false)
const purchasing = ref(false)

const billingHistory = ref([])
const creditHistory = ref([])
const currentCreditPage = ref(1)
const totalCreditPages = ref(1)
const loadingCredits = ref(false)

const user = computed(() => store.state.auth.user)
const isAdmin = computed(() => user.value && ['admin', 'super_admin'].includes(user.value.role))

// Pricing state
const pricingMode = ref('production')
const dynamicPrices = ref({
 plus: { monthly: 199, yearly: 1999 },
 pro: { monthly: 499, yearly: 4999 }
})

// Forms state
const profileForm = ref({
 first_name: '',
 last_name: '',
 title: '',
 location: '',
 phone: '',
 website: '',
 linkedin: '',
 github: '',
 bio: ''
})
const savingProfile = ref(false)

const passwordForm = ref({
 current_password: '',
 password: '',
 password_confirmation: ''
})
const updatingPassword = ref(false)

const notificationPrefs = ref({
 marketing: true,
 security: true,
 billing: true,
 digest: false
})

const developerSettings = ref({
 payment_test_mode: false,
 debug_logs: false,
 fake_payment_success: false,
 fake_payment_failure: false,
 email_sandbox: false,
 ai_sandbox: false,
 maintenance_mode: false,
 show_api_timings: false,
 reset_demo_data: false,
 force_premium_access: false
})
const savingDevSettings = ref(false)

// Lifecycle
onMounted(async () => {
 await store.dispatch('auth/fetchMe')
 await loadPricing()
 loadCreditHistory()
 loadBillingHistory()
 initializeProfileForm()

 if (isAdmin.value) {
 loadDevSettings()
 }

 // Load Razorpay Script if missing
 if (!document.querySelector('script[src="https://checkout.razorpay.com/v1/checkout.js"]')) {
 const script = document.createElement('script')
 script.src = 'https://checkout.razorpay.com/v1/checkout.js'
 script.async = true
 document.head.appendChild(script)
 }
})

// Load Profile Data
const initializeProfileForm = () => {
 if (user.value) {
 profileForm.value = {
 first_name: user.value.first_name || '',
 last_name: user.value.last_name || '',
 title: user.value.title || '',
 location: user.value.location || '',
 phone: user.value.phone || '',
 website: user.value.website || '',
 linkedin: user.value.linkedin || '',
 github: user.value.github || '',
 bio: user.value.bio || ''
 }
 }
}

// Load Pricing config from backend
const loadPricing = async () => {
 try {
 const { data } = await paymentService.getPricing()
 pricingMode.value = data.mode
 dynamicPrices.value = data.plans
 
 // In-place updates for UI constants
 const plusPlan = PRICING_PLANS.find(p => p.id === 'plus')
 if (plusPlan) {
 plusPlan.monthlyPrice = data.plans.plus.monthly
 plusPlan.yearlyPrice = data.plans.plus.yearly
 }
 const proPlan = PRICING_PLANS.find(p => p.id === 'pro')
 if (proPlan) {
 proPlan.monthlyPrice = data.plans.pro.monthly
 proPlan.yearlyPrice = data.plans.pro.yearly
 }
 } catch (error) {
 console.error('Failed to load dynamic pricing from API', error)
 }
}

// Load billing records
const loadBillingHistory = async () => {
 try {
 const { data } = await paymentService.getHistory()
 billingHistory.value = data.billing_history || []
 } catch (error) {
 console.error('Failed to load billing history logs', error)
 }
}

// Load credit transactions
const loadCreditHistory = async () => {
 if (loadingCredits.value) return
 loadingCredits.value = true
 try {
  const { data } = await paymentService.getCreditHistory(currentCreditPage.value)
  creditHistory.value = data.transactions || []
  totalCreditPages.value = data.meta?.total_pages || 1
  currentCreditPage.value = data.meta?.current_page || 1
 } catch (error) {
  console.error('Failed to load credit history logs', error)
 } finally {
  loadingCredits.value = false
 }
}

const changeCreditPage = async (newPage) => {
 if (newPage < 1 || newPage > totalCreditPages.value) return
 currentCreditPage.value = newPage
 await loadCreditHistory()
}

// Load Developer settings (Admin only)
const loadDevSettings = async () => {
 try {
 const { data } = await adminService.getSettings()
 if (data.settings && data.settings.developer_settings) {
 developerSettings.value = {
 ...developerSettings.value,
 ...data.settings.developer_settings
 }
 }
 } catch (error) {
 console.error('Failed to fetch developer settings', error)
 }
}

// Save profile updates
const saveProfile = async () => {
 savingProfile.value = true
 try {
 await profileService.update(profileForm.value)
 await store.dispatch('auth/fetchMe')
 toast.success('Profile Saved', 'Your profile details have been updated.')
 } catch (error) {
 toast.error('Failed to save profile', error.response?.data?.error || 'Validation error.')
 } finally {
 savingProfile.value = false
 }
}

// Save Notification configurations
const saveNotificationPrefs = () => {
 toast.success('Preferences Updated', 'Your notification rules have been saved.')
}

// Save developer tools updates
const saveDevSettings = async () => {
 savingDevSettings.value = true
 try {
 await adminService.updateSettings('developer_settings', developerSettings.value)
 toast.success('Developer Tools Saved', 'Dynamic SaaS flags updated successfully.')
 await loadPricing() // refresh local prices
 } catch (error) {
 toast.error('Failed to update flags', error.response?.data?.error || 'Authorization error.')
 } finally {
 savingDevSettings.value = false
 }
}

// Save password updates
const updatePassword = async () => {
 if (passwordForm.value.password !== passwordForm.value.password_confirmation) {
 toast.error('Password Mismatch', 'New password and confirmation fields do not match.')
 return
 }
 updatingPassword.value = true
 try {
 await profileService.changePassword(passwordForm.value)
 toast.success('Password Changed', 'Your security password has been updated.')
 passwordForm.value = { current_password: '', password: '', password_confirmation: '' }
 } catch (error) {
 const errs = error.response?.data?.errors || []
 toast.error('Failed to update password', errs.join(', ') || 'Validation error.')
 } finally {
 updatingPassword.value = false
 }
}

// Delete Account processes
const triggerDeleteAccount = () => {
 showDeleteModal.value = true
}

const confirmDeleteAccount = async () => {
 try {
 await profileService.deleteAccount()
 showDeleteModal.value = false
 toast.success('Account Deleted', 'Your profile has been removed.')
 await store.dispatch('auth/logout')
 router.push('/')
 } catch (error) {
 toast.error('Deletion Failed', 'Failed to remove account. Contact developer support.')
 }
}

// Credit Valuations Tooltip calculation
const creditValuations = computed(() => {
 const credits = Number(user.value?.ai_credits_remaining ?? 0)
 return {
 rewrites: Math.max(0, Math.floor(credits / 5)),
 ats: Math.max(0, Math.floor(credits / 2)),
 answers: Math.max(0, Math.floor(credits / 1)),
 coverLetters: Math.max(0, Math.floor(credits / 4)),
 linkedin: Math.max(0, Math.floor(credits / 5)),
 interviews: Math.max(0, Math.floor(credits / 20))
 }
})

const creditPercentage = computed(() => {
 if (!user.value) return 0
 const total = user.value.ai_credits_total || 10
 const remaining = user.value.ai_credits_remaining ?? 0
 if (total === 0) return 0
 return Math.round((remaining / total) * 100)
})

const creditColorClass = computed(() => {
 if (!user.value) return 'bg-rose-500'
 const pct = creditPercentage.value
 if (pct > 50) return 'bg-emerald-500'
 if (pct > 20) return 'bg-amber-500'
 return 'bg-rose-500'
})

const isSubscriptionExpired = computed(() => {
 if (!user.value?.subscription_expires_at) return false
 return new Date(user.value.subscription_expires_at) < new Date()
})

const currentPlanName = computed(() => {
 if (!user.value?.subscription_plan) return 'Free'
 if (isSubscriptionExpired.value) return `${user.value.subscription_plan === 'pro' ? 'CareerAI Pro' : 'CareerAI Plus'} (Expired)`
 if (user.value.subscription_plan === 'plus') return 'CareerAI Plus'
 if (user.value.subscription_plan === 'pro') return 'CareerAI Pro'
 return 'Free'
})

const currentBillingCycle = computed(() => {
 if (!user.value?.subscription_started_at || !user.value?.subscription_expires_at) return 'Monthly'
 const start = new Date(user.value.subscription_started_at)
 const end = new Date(user.value.subscription_expires_at)
 const diffDays = (end - start) / (1000 * 60 * 60 * 24)
 return diffDays > 300 ? 'Yearly' : 'Monthly'
})

const currentPlanPrice = computed(() => {
 if (!user.value?.subscription_plan || user.value.subscription_plan === 'free' || isSubscriptionExpired.value) return '₹0'
 const plan = PRICING_PLANS.find(p => p.id === user.value.subscription_plan)
 if (!plan) return '₹0'
 const isYr = currentBillingCycle.value === 'Yearly'
 return `₹${isYr ? plan.yearlyPrice : plan.monthlyPrice}`
})

const remainingCreditsDisplay = computed(() => {
 if (!user.value) return '0'
 return String(user.value.ai_credits_remaining ?? 0)
})

const totalCreditsDisplay = computed(() => {
 if (!user.value) return '0'
 return String(user.value.ai_credits_total ?? 0)
})

const usedCreditsDisplay = computed(() => {
 if (!user.value) return '0'
 const total = user.value.ai_credits_total ?? 0
 const remaining = user.value.ai_credits_remaining ?? 0
 return String(Math.max(0, total - remaining))
})

const creditsResetDate = computed(() => {
 if (!user.value?.subscription_expires_at) return 'N/A'
 return formatDate(user.value.subscription_expires_at)
})

const isCurrentPlan = (planId) => {
 if (isSubscriptionExpired.value) return planId === 'free'
 const current = user.value?.subscription_plan || 'free'
 return current === planId
}

const getButtonText = (plan) => {
 if (isCurrentPlan(plan.id)) return 'Current Plan'
 if (isSubscriptionExpired.value && plan.id !== 'free') return 'Renew Plan'
 const currentPlanId = user.value?.subscription_plan || 'free'
 const planOrder = ['free', 'plus', 'pro']
 if (planOrder.indexOf(plan.id) > planOrder.indexOf(currentPlanId)) return 'Upgrade'
 return 'Downgrade'
}

const handlePlanAction = (plan) => {
 const currentPlanId = user.value?.subscription_plan || 'free'
 const planOrder = ['free', 'plus', 'pro']
 if (planOrder.indexOf(plan.id) < planOrder.indexOf(currentPlanId) && !isSubscriptionExpired.value) {
 toast.info('Downgrade Plan', `To downgrade to the ${plan.name} plan, please cancel your active subscription first.`)
 return
 }
 selectedPlan.value = plan
 acceptedPolicies.value = false
 purchasing.value = false
}

const cancelSubscription = () => {
 showCancelModal.value = true
}

const confirmCancelSubscription = async () => {
 try {
 await paymentService.cancel()
 await store.dispatch('auth/fetchMe')
 toast.success('Subscription Cancelled', 'Your account has been reverted to the Free plan.')
 showDetails.value = false
 showCancelModal.value = false
 } catch (error) {
 toast.error('Cancellation Failed', 'There was an error cancelling your subscription.')
 }
}

const formatDate = (value) => {
 if (!value) return 'N/A'
 return new Date(value).toLocaleDateString(undefined, {
 year: 'numeric',
 month: 'short',
 day: 'numeric'
 })
}

const purchasePlan = async () => {
 purchasing.value = true
 try {
 const billingCycle = isYearly.value ? 'yearly' : 'monthly'
 const { data } = await paymentService.create(selectedPlan.value.id, billingCycle)
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
 toast.success('Plan activated', `${selectedPlan.value.name} is now active.`)
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
 description: `${selectedPlan.value.name} ${isYearly.value ? 'yearly' : 'monthly'} subscription`,
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
</script>

<style scoped>
.hide-scrollbar::-webkit-scrollbar {
 display: none;
}
.hide-scrollbar {
 -ms-overflow-style: none;
 scrollbar-width: none;
}
</style>