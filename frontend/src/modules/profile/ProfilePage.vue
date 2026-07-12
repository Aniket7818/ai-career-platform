<template>
  <AppShell>
    <LoadingState v-if="loading && !form.first_name" />
    <section v-else class="mx-auto max-w-4xl space-y-6">
      <div>
        <!-- <p class="text-sm font-semibold text-brand">{{ t('nav.workspace') }}</p> -->
        <h1 class="mt-1 text-2xl font-bold text-txt-primary sm:text-3xl">{{ t('profile.title') }}</h1>
        <p class="mt-2 text-sm text-txt-muted">{{ t('profile.subtitle') }}</p>
      </div>

      <div class="overflow-hidden rounded-2xl border border-border bg-surface shadow-panel">
        <div class="relative h-44 bg-gradient-to-r from-brand/20 via-skyglass to-mint/20 sm:h-52">
          <img v-if="form.cover_image" :src="form.cover_image" alt="" class="size-full object-cover" />
          <label class="absolute right-4 top-4 cursor-pointer rounded-xl border border-white/40 bg-surface/90 px-3 py-2 text-xs font-semibold text-txt-primary shadow-sm backdrop-blur transition hover:bg-surface">
            {{ t('profile.changeCover') }}
            <input class="hidden" type="file" accept="image/*" @change="onCoverChange" />
          </label>
        </div>

        <div class="relative z-10 px-4 pb-6 sm:px-6">
          <div class="-mt-12 flex flex-wrap items-end gap-4 sm:-mt-14 sm:gap-5 pb-4">
            <div class="relative">
              <div class="grid size-28 place-items-center overflow-hidden rounded-2xl border-4 border-white bg-gradient-to-br from-brand to-indigo-600 text-3xl font-bold text-white shadow-panel">
                <img v-if="form.avatar" :src="form.avatar" alt="" class="size-full object-cover" />
                <span v-else>{{ initials }}</span>
              </div>
              <label class="absolute -bottom-1 -right-1 grid size-9 cursor-pointer place-items-center rounded-full border-2 border-white bg-slate-900 text-white shadow-md transition hover:bg-slate-800">
                <svg class="size-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M23 19a2 2 0 01-2 2H3a2 2 0 01-2-2V8a2 2 0 012-2h4l2-3h6l2 3h4a2 2 0 012 2z" /><circle cx="12" cy="13" r="4" /></svg>
                <input class="hidden" type="file" accept="image/*" @change="onAvatarChange" />
              </label>
            </div>
            <div class="min-w-0 flex-1 pb-1">
              <h2 class="mb-1 truncate text-2xl font-bold text-txt-primary">{{ form.first_name }} {{ form.last_name }}</h2>
              <p class="mb-1.5 truncate text-sm text-txt-muted">@{{ form.username }}</p>
              <div class="mt-2 flex items-center gap-2">
                <div class="h-2 flex-1 max-w-[200px] overflow-hidden rounded-full bg-surface-hover">
                  <div class="h-full rounded-full bg-brand transition-all" :style="{ width: `${strength}%` }" />
                </div>
                <span class="text-xs font-semibold text-brand">{{ strength }}%</span>
              </div>
            </div>
          </div>

          <ErrorState v-if="error" class="mt-6" :message="error" />

          <form class="mt-8 space-y-8" @submit.prevent="save">
            <!-- Section 1: Personal Details -->
            <div class="space-y-4">
              <div class="flex items-center gap-2.5 pb-2 border-b border-border">
                <span class="grid size-8 place-items-center rounded-lg bg-brand/10 text-brand">
                  <svg class="size-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>
                </span>
                <div>
                  <h3 class="text-sm font-bold text-txt-primary">Personal Details</h3>
                  <p class="text-xs text-txt-muted">Your public name, username, and professional designation.</p>
                </div>
              </div>
              
              <div class="grid gap-4 md:grid-cols-2">
                <!-- First Name -->
                <div>
                  <label>{{ t('auth.firstName') }}</label>
                  <div class="relative rounded-xl shadow-xs">
                    <div class="pointer-events-none absolute inset-y-0 left-0 flex items-center pl-3.5 z-10">
                      <svg class="size-5 text-txt-muted" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>
                    </div>
                    <input v-model="form.first_name" required class="pl-10 block w-full" />
                  </div>
                </div>
                
                <!-- Last Name -->
                <div>
                  <label>{{ t('auth.lastName') }}</label>
                  <div class="relative rounded-xl shadow-xs">
                    <div class="pointer-events-none absolute inset-y-0 left-0 flex items-center pl-3.5 z-10">
                      <svg class="size-5 text-txt-muted" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>
                    </div>
                    <input v-model="form.last_name" class="pl-10 block w-full" />
                  </div>
                </div>

                <!-- Username (disabled) -->
                <div>
                  <label>{{ t('auth.username') }}</label>
                  <div class="relative rounded-xl shadow-xs">
                    <div class="pointer-events-none absolute inset-y-0 left-0 flex items-center pl-3.5 z-10">
                      <svg class="size-5 text-txt-muted" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="4"/><path d="M16 8v5a3 3 0 0 0 6 0v-1a10 10 0 1 0-3.92 7.94"/></svg>
                    </div>
                    <input :value="form.username" disabled class="pl-10 block w-full bg-background text-txt-muted cursor-not-allowed" />
                  </div>
                </div>

                <!-- Job Title -->
                <div>
                  <label>{{ t('profile.jobTitle') }}</label>
                  <div class="relative rounded-xl shadow-xs">
                    <div class="pointer-events-none absolute inset-y-0 left-0 flex items-center pl-3.5 z-10">
                      <svg class="size-5 text-txt-muted" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="2" y="7" width="20" height="14" rx="2" ry="2"/><path d="M16 21V5a2 2 0 0 0-2-2h-4a2 2 0 0 0-2 2v16"/></svg>
                    </div>
                    <input v-model="form.title" :placeholder="t('profile.jobTitlePlaceholder')" class="pl-10 block w-full" />
                  </div>
                </div>
              </div>
            </div>

            <!-- Section 2: Contact Information -->
            <div class="space-y-4">
              <div class="flex items-center gap-2.5 pb-2 border-b border-border">
                <span class="grid size-8 place-items-center rounded-lg bg-skyglass/10 text-brand">
                  <svg class="size-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z"/><polyline points="22,6 12,13 2,6"/></svg>
                </span>
                <div>
                  <h3 class="text-sm font-bold text-txt-primary">Contact Details</h3>
                  <p class="text-xs text-txt-muted">Your contact information used for resumes and platform communications.</p>
                </div>
              </div>

              <div class="grid gap-4 md:grid-cols-2">
                <!-- Email (disabled) -->
                <div>
                  <label>{{ t('profile.email') }}</label>
                  <div class="relative rounded-xl shadow-xs">
                    <div class="pointer-events-none absolute inset-y-0 left-0 flex items-center pl-3.5 z-10">
                      <svg class="size-5 text-txt-muted" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z"/><polyline points="22,6 12,13 2,6"/></svg>
                    </div>
                    <input :value="form.email" disabled class="pl-10 block w-full bg-background text-txt-muted cursor-not-allowed" />
                  </div>
                </div>

                <!-- Phone -->
                <div>
                  <label>{{ t('profile.phone') }}</label>
                  <div class="relative rounded-xl shadow-xs">
                    <div class="pointer-events-none absolute inset-y-0 left-0 flex items-center pl-3.5 z-10">
                      <svg class="size-5 text-txt-muted" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M22 16.92v3a2 2 0 0 1-2.18 2 19.79 19.79 0 0 1-8.63-3.07 19.5 19.5 0 0 1-6-6 19.79 19.79 0 0 1-3.07-8.67A2 2 0 0 1 4.11 2h3a2 2 0 0 1 2 1.72 12.84 12.84 0 0 0 .7 2.81 2 2 0 0 1-.45 2.11L8.09 9.91a16 16 0 0 0 6 6l1.27-1.27a2 2 0 0 1 2.11-.45 12.84 12.84 0 0 0 2.81.7A2 2 0 0 1 22 16.92z"/></svg>
                    </div>
                    <input v-model="form.phone" class="pl-10 block w-full" />
                  </div>
                </div>

                <!-- Location -->
                <div class="md:col-span-2">
                  <label>{{ t('profile.location') }}</label>
                  <div class="relative rounded-xl shadow-xs">
                    <div class="pointer-events-none absolute inset-y-0 left-0 flex items-center pl-3.5 z-10">
                      <svg class="size-5 text-txt-muted" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0z"/><circle cx="12" cy="10" r="3"/></svg>
                    </div>
                    <input v-model="form.location" class="pl-10 block w-full" />
                  </div>
                </div>
              </div>
            </div>

            <!-- Section 3: Social & Web Profiles -->
            <div class="space-y-4">
              <div class="flex items-center gap-2.5 pb-2 border-b border-border">
                <span class="grid size-8 place-items-center rounded-lg bg-mint/10 text-brand">
                  <svg class="size-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="2" y1="12" x2="22" y2="12"/><path d="M12 2a15.3 15.3 0 0 1 4 10 15.3 15.3 0 0 1-4 10 15.3 15.3 0 0 1-4-10 15.3 15.3 0 0 1 4-10z"/></svg>
                </span>
                <div>
                  <h3 class="text-sm font-bold text-txt-primary">Professional Links</h3>
                  <p class="text-xs text-txt-muted">Links to your LinkedIn profile, GitHub repository, and custom portfolio website.</p>
                </div>
              </div>

              <div class="grid gap-4 md:grid-cols-2">
                <!-- LinkedIn -->
                <div>
                  <label>{{ t('profile.linkedin') }}</label>
                  <div class="relative rounded-xl shadow-xs">
                    <div class="pointer-events-none absolute inset-y-0 left-0 flex items-center pl-3.5 z-10">
                      <svg class="size-5 text-txt-muted fill-current" viewBox="0 0 24 24"><path d="M19 0h-14c-2.761 0-5 2.239-5 5v14c0 2.761 2.239 5 5 5h14c2.762 0 5-2.239 5-5v-14c0-2.761-2.238-5-5-5zm-11 19h-3v-11h3v11zm-1.5-12.268c-.966 0-1.75-.79-1.75-1.764s.784-1.764 1.75-1.764 1.75.79 1.75 1.764-.783 1.764-1.75 1.764zm13.5 12.268h-3v-5.604c0-3.368-4-3.113-4 0v5.604h-3v-11h3v1.765c1.396-2.586 7-2.777 7 2.476v6.759z"/></svg>
                    </div>
                    <input v-model="form.linkedin" placeholder="https://linkedin.com/in/username" class="pl-10 block w-full" />
                  </div>
                </div>

                <!-- GitHub -->
                <div>
                  <label>{{ t('profile.github') }}</label>
                  <div class="relative rounded-xl shadow-xs">
                    <div class="pointer-events-none absolute inset-y-0 left-0 flex items-center pl-3.5 z-10">
                      <svg class="size-5 text-txt-muted fill-current" viewBox="0 0 24 24"><path d="M12 0c-6.626 0-12 5.373-12 12 0 5.302 3.438 9.8 8.207 11.387.599.111.793-.261.793-.577v-2.234c-3.338.726-4.033-1.416-4.033-1.416-.546-1.387-1.333-1.756-1.333-1.756-1.089-.745.083-.729.083-.729 1.205.084 1.839 1.237 1.839 1.237 1.07 1.834 2.807 1.304 3.492.997.107-.775.418-1.305.762-1.604-2.665-.305-5.467-1.334-5.467-5.931 0-1.311.469-2.381 1.236-3.221-.124-.303-.535-1.524.117-3.176 0 0 1.008-.322 3.301 1.23.957-.266 1.983-.399 3.003-.404 1.02.005 2.047.138 3.006.404 2.291-1.552 3.297-1.23 3.297-1.23.653 1.653.242 2.874.118 3.176.77.84 1.235 1.911 1.235 3.221 0 4.609-2.807 5.624-5.479 5.921.43.372.823 1.102.823 2.222v3.293c0 .319.192.694.801.576 4.765-1.589 8.199-6.086 8.199-11.386 0-6.627-5.373-12-12-12z"/></svg>
                    </div>
                    <input v-model="form.github" placeholder="https://github.com/username" class="pl-10 block w-full" />
                  </div>
                </div>

                <!-- Portfolio Website -->
                <div class="md:col-span-2">
                  <label>{{ t('profile.portfolio') }}</label>
                  <div class="relative rounded-xl shadow-xs">
                    <div class="pointer-events-none absolute inset-y-0 left-0 flex items-center pl-3.5 z-10">
                      <svg class="size-5 text-txt-muted" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="2" y1="12" x2="22" y2="12"/><path d="M12 2a15.3 15.3 0 0 1 4 10 15.3 15.3 0 0 1-4 10 15.3 15.3 0 0 1-4-10 15.3 15.3 0 0 1 4-10z"/></svg>
                    </div>
                    <input v-model="form.website" placeholder="https://yourportfolio.com" class="pl-10 block w-full" />
                  </div>
                </div>
              </div>
            </div>

            <!-- Section 4: About & Biography -->
            <div class="space-y-4">
              <div class="flex items-center gap-2.5 pb-2 border-b border-border">
                <span class="grid size-8 place-items-center rounded-lg bg-amber-500/10 text-brand">
                  <svg class="size-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 20h9"/><path d="M16.5 3.5a2.12 2.12 0 0 1 3 3L7 19l-4 1 1-4Z"/></svg>
                </span>
                <div>
                  <h3 class="text-sm font-bold text-txt-primary">Biography</h3>
                  <p class="text-xs text-txt-muted">A brief summary of your professional journey and key skills.</p>
                </div>
              </div>

              <div>
                <label>{{ t('profile.bio') }}</label>
                <div class="relative rounded-xl shadow-xs">
                  <div class="absolute top-3.5 left-3.5 pointer-events-none z-10">
                    <svg class="size-5 text-txt-muted" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 20h9"/><path d="M16.5 3.5a2.12 2.12 0 0 1 3 3L7 19l-4 1 1-4Z"/></svg>
                  </div>
                  <textarea v-model="form.bio" rows="4" :placeholder="t('profile.bioPlaceholder')" class="pl-10 pt-3.5 block w-full" />
                </div>
              </div>
            </div>

            <div class="rounded-xl border border-brand/20 bg-brand/5 p-4">
              <p class="text-sm font-semibold text-txt-primary">{{ t('profile.autofillNote') }}</p>
              <p class="mt-1 text-xs text-txt-muted">{{ t('profile.autofillNoteBody') }}</p>
            </div>

            <AppButton :loading="saving">{{ t('profile.save') }}</AppButton>
          </form>
        </div>
      </div>
    </section>
  </AppShell>
</template>

<script setup>
import { computed, onMounted, reactive, ref } from 'vue'
import { useStore } from 'vuex'
import AppShell from '../../components/layout/AppShell.vue'
import AppButton from '../../components/ui/AppButton.vue'
import ErrorState from '../../components/ui/ErrorState.vue'
import LoadingState from '../../components/ui/LoadingState.vue'
import { compressImage } from '../../utils/compressImage'
import { toast } from '../../utils/toast'
import { t } from '../../utils/i18n'

const store = useStore()
const saving = ref(false)
const form = reactive({
  first_name: '', last_name: '', email: '', username: '', title: '',
  location: '', phone: '', website: '', linkedin: '', github: '', bio: '',
  avatar: null, cover_image: null
})

const loading = computed(() => store.state.auth.loading)
const error = computed(() => store.state.auth.error)

const initials = computed(() => {
  const name = `${form.first_name} ${form.last_name}`.trim() || form.username || 'U'
  return name.split(' ').map((p) => p[0]).join('').slice(0, 2).toUpperCase()
})

const strength = computed(() => {
  const fields = [form.first_name, form.last_name, form.title, form.location, form.phone, form.website, form.linkedin, form.github, form.bio, form.avatar]
  const filled = fields.filter((f) => f?.trim?.()).length
  return Math.round((filled / fields.length) * 100)
})

const applyUser = (user) => {
  if (!user) return
  Object.assign(form, {
    first_name: user.first_name || '',
    last_name: user.last_name || '',
    email: user.email || '',
    username: user.username || '',
    title: user.title || '',
    location: user.location || '',
    phone: user.phone || '',
    website: user.website || '',
    linkedin: user.linkedin || '',
    github: user.github || '',
    bio: user.bio || '',
    avatar: user.avatar || null,
    cover_image: user.cover_image || null
  })
}

onMounted(async () => {
  const user = store.state.auth.user || await store.dispatch('auth/fetchMe')
  applyUser(user)
})

const onAvatarChange = async (event) => {
  const file = event.target.files?.[0]
  if (!file) return
  try {
    form.avatar = await compressImage(file, { maxWidth: 400, maxHeight: 400, quality: 0.85 })
  } catch {
    toast.error(t('profile.imageError'), t('profile.imageErrorBody'))
  }
}

const onCoverChange = async (event) => {
  const file = event.target.files?.[0]
  if (!file) return
  try {
    form.cover_image = await compressImage(file, { maxWidth: 1400, maxHeight: 500, quality: 0.82 })
  } catch {
    toast.error(t('profile.imageError'), t('profile.imageErrorBody'))
  }
}

const save = async () => {
  saving.value = true
  const updated = await store.dispatch('auth/updateProfile', { ...form })
  saving.value = false
  if (updated) toast.success(t('toast.profileSaved'), t('toast.profileSavedBody'))
  else if (store.state.auth.error) toast.error(t('toast.profileSaveError'), store.state.auth.error)
}
</script>
