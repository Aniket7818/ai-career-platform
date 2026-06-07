<template>
  <AppShell>
    <LoadingState v-if="loading && !form.first_name" />
    <section v-else class="mx-auto max-w-4xl space-y-6">
      <div>
        <p class="text-sm font-semibold text-brand">{{ t('nav.workspace') }}</p>
        <h1 class="mt-1 text-2xl font-bold text-ink sm:text-3xl">{{ t('profile.title') }}</h1>
        <p class="mt-2 text-sm text-slate-500">{{ t('profile.subtitle') }}</p>
      </div>

      <div class="overflow-hidden rounded-2xl border border-slate-100 bg-white shadow-panel">
        <div class="relative h-44 bg-gradient-to-r from-brand/20 via-skyglass to-mint/20 sm:h-52">
          <img v-if="form.cover_image" :src="form.cover_image" alt="" class="size-full object-cover" />
          <label class="absolute right-4 top-4 cursor-pointer rounded-xl border border-white/40 bg-white/90 px-3 py-2 text-xs font-semibold text-ink shadow-sm backdrop-blur transition hover:bg-white">
            {{ t('profile.changeCover') }}
            <input class="hidden" type="file" accept="image/*" @change="onCoverChange" />
          </label>
        </div>

        <div class="relative px-4 pb-6 sm:px-6">
          <div class="-mt-12 flex flex-wrap items-end gap-4 sm:-mt-14 sm:gap-5">
            <div class="relative">
              <div class="grid size-28 place-items-center overflow-hidden rounded-2xl border-4 border-white bg-gradient-to-br from-brand to-indigo-600 text-3xl font-bold text-white shadow-panel">
                <img v-if="form.avatar" :src="form.avatar" alt="" class="size-full object-cover" />
                <span v-else>{{ initials }}</span>
              </div>
              <label class="absolute -bottom-1 -right-1 grid size-9 cursor-pointer place-items-center rounded-full border-2 border-white bg-ink text-white shadow-md transition hover:bg-slate-800">
                <svg class="size-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M23 19a2 2 0 01-2 2H3a2 2 0 01-2-2V8a2 2 0 012-2h4l2-3h6l2 3h4a2 2 0 012 2z" /><circle cx="12" cy="13" r="4" /></svg>
                <input class="hidden" type="file" accept="image/*" @change="onAvatarChange" />
              </label>
            </div>
            <div class="min-w-0 flex-1 pb-1">
              <h2 class="truncate text-2xl font-bold text-ink">{{ form.first_name }} {{ form.last_name }}</h2>
              <p class="truncate text-sm text-slate-500">@{{ form.username }}</p>
              <div class="mt-2 flex items-center gap-2">
                <div class="h-2 flex-1 max-w-[200px] overflow-hidden rounded-full bg-slate-100">
                  <div class="h-full rounded-full bg-brand transition-all" :style="{ width: `${strength}%` }" />
                </div>
                <span class="text-xs font-semibold text-brand">{{ strength }}%</span>
              </div>
            </div>
          </div>

          <ErrorState v-if="error" class="mt-6" :message="error" />

          <form class="mt-8 space-y-6" @submit.prevent="save">
            <div class="grid gap-4 md:grid-cols-2">
              <div><label>{{ t('auth.firstName') }}</label><input v-model="form.first_name" required /></div>
              <div><label>{{ t('auth.lastName') }}</label><input v-model="form.last_name" /></div>
              <div><label>{{ t('profile.email') }}</label><input :value="form.email" disabled class="bg-slate-50 text-slate-500" /></div>
              <div><label>{{ t('auth.username') }}</label><input :value="form.username" disabled class="bg-slate-50 text-slate-500" /></div>
              <div><label>{{ t('profile.jobTitle') }}</label><input v-model="form.title" :placeholder="t('profile.jobTitlePlaceholder')" /></div>
              <div><label>{{ t('profile.phone') }}</label><input v-model="form.phone" /></div>
              <div class="md:col-span-2"><label>{{ t('profile.location') }}</label><input v-model="form.location" /></div>
              <div><label>{{ t('profile.linkedin') }}</label><input v-model="form.linkedin" placeholder="https://linkedin.com/in/username" /></div>
              <div><label>{{ t('profile.github') }}</label><input v-model="form.github" placeholder="https://github.com/username" /></div>
              <div class="md:col-span-2"><label>{{ t('profile.portfolio') }}</label><input v-model="form.website" placeholder="https://yourportfolio.com" /></div>
              <div class="md:col-span-2"><label>{{ t('profile.bio') }}</label><textarea v-model="form.bio" rows="4" :placeholder="t('profile.bioPlaceholder')" /></div>
            </div>

            <div class="rounded-xl border border-brand/20 bg-brand/5 p-4">
              <p class="text-sm font-semibold text-ink">{{ t('profile.autofillNote') }}</p>
              <p class="mt-1 text-xs text-slate-500">{{ t('profile.autofillNoteBody') }}</p>
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
