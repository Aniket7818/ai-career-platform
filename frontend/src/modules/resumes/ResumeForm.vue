<template>
  <form class="grid min-w-0 gap-6 lg:grid-cols-1 xl:grid-cols-[minmax(0,1fr)_minmax(0,480px)]" @submit.prevent="$emit('submit')">
    <section class="min-w-0 space-y-6 rounded-2xl border border-slate-100 bg-white p-4 shadow-panel sm:p-6">
      <div class="grid gap-4 md:grid-cols-2">
        <div>
          <label>{{ t('resumes.titleLabel') }}</label>
          <input :value="model.title" required @input="update('title', $event.target.value)" />
        </div>
        <div>
          <label>{{ t('resumes.status') }}</label>
          <select :value="model.status" @change="update('status', $event.target.value)">
            <option v-for="status in statuses" :key="status" :value="status">{{ status }}</option>
          </select>
        </div>
      </div>

      <div class="flex flex-wrap items-center justify-between gap-3 rounded-xl border border-brand/20 bg-brand/5 p-4">
        <div>
          <p class="text-sm font-semibold text-ink">{{ t('resumes.fillFromProfile') }}</p>
          <p class="text-xs text-slate-500">{{ t('resumes.fillFromProfileHint') }}</p>
        </div>
        <button
          type="button"
          class="rounded-xl border border-brand/30 bg-white px-4 py-2 text-sm font-semibold text-brand transition hover:bg-brand/10"
          @click="$emit('fill-from-profile')"
        >
          {{ t('resumes.fillFromProfileAction') }}
        </button>
      </div>

      <div class="rounded-xl border border-slate-100 bg-slate-50/50 p-5">
        <h3 class="text-sm font-bold uppercase tracking-wider text-brand">{{ t('builder.personal') }}</h3>
        <div class="mt-4 grid gap-4 md:grid-cols-2">
          <div class="md:col-span-2"><label>{{ t('builder.fullName') }}</label><input v-model="model.content.personal.fullName" /></div>
          <div class="md:col-span-2"><label>{{ t('builder.headline') }}</label><input v-model="model.content.personal.headline" /></div>
          <div class="md:col-span-2"><label>{{ t('builder.summary') }}</label><textarea v-model="model.content.personal.summary" rows="4" /></div>
          <div><label>{{ t('profile.email') }}</label><input v-model="model.content.personal.email" type="email" /></div>
          <div><label>{{ t('profile.phone') }}</label><input v-model="model.content.personal.phone" /></div>
          <div><label>{{ t('profile.location') }}</label><input v-model="model.content.personal.location" /></div>
          <div><label>{{ t('profile.portfolio') }}</label><input v-model="model.content.personal.portfolio" /></div>
          <div><label>{{ t('profile.linkedin') }}</label><input v-model="model.content.personal.linkedin" /></div>
          <div><label>{{ t('profile.github') }}</label><input v-model="model.content.personal.github" /></div>
        </div>
      </div>

      <div class="rounded-xl border border-slate-100 bg-slate-50/50 p-5">
        <h3 class="text-sm font-bold uppercase tracking-wider text-brand">{{ t('builder.experience') }}</h3>
        <div class="mt-4 grid gap-4 md:grid-cols-2">
          <div><label>{{ t('builder.role') }}</label><input v-model="model.content.experience.role" /></div>
          <div><label>{{ t('builder.company') }}</label><input v-model="model.content.experience.company" /></div>
        </div>
      </div>

      <div class="grid gap-4 md:grid-cols-2">
        <div class="rounded-xl border border-slate-100 bg-slate-50/50 p-5">
          <h3 class="text-sm font-bold uppercase tracking-wider text-brand">{{ t('builder.education') }}</h3>
          <div class="mt-4"><label>{{ t('builder.school') }}</label><input v-model="model.content.education.school" /></div>
        </div>
        <div class="rounded-xl border border-slate-100 bg-slate-50/50 p-5">
          <h3 class="text-sm font-bold uppercase tracking-wider text-brand">{{ t('builder.projects') }}</h3>
          <div class="mt-4"><label>{{ t('builder.projectName') }}</label><input v-model="model.content.projects.projectName" /></div>
        </div>
      </div>

      <div class="grid gap-4 md:grid-cols-2">
        <div class="rounded-xl border border-slate-100 bg-slate-50/50 p-5">
          <h3 class="text-sm font-bold uppercase tracking-wider text-brand">{{ t('builder.skills') }}</h3>
          <div class="mt-4"><label>{{ t('builder.skillList') }}</label><input v-model="model.content.skills.skillList" /></div>
        </div>
        <div class="rounded-xl border border-slate-100 bg-slate-50/50 p-5">
          <h3 class="text-sm font-bold uppercase tracking-wider text-brand">{{ t('builder.certifications') }}</h3>
          <div class="mt-4"><label>{{ t('builder.certName') }}</label><input v-model="model.content.certifications.certName" /></div>
        </div>
      </div>

      <AppButton :loading="loading">{{ t('resumes.save') }}</AppButton>
    </section>

    <aside class="min-w-0 space-y-4 xl:sticky xl:top-24 xl:self-start">
      <TemplatePicker v-model="model.template_id" :content="model.content" />
      <div class="flex items-center justify-between">
        <h2 class="text-lg font-bold text-ink">{{ t('resumes.preview') }}</h2>
        <span class="rounded-full bg-emerald-500/15 px-2.5 py-1 text-[10px] font-bold uppercase tracking-wider text-emerald-600">{{ t('resumes.live') }}</span>
      </div>
      <ResumePreview :title="model.title" :content="model.content" :template-id="model.template_id" />
    </aside>
  </form>
</template>

<script setup>
import AppButton from '../../components/ui/AppButton.vue'
import ResumePreview from './ResumePreview.vue'
import TemplatePicker from './TemplatePicker.vue'
import { RESUME_STATUS } from '../../constants/resume'
import { t } from '../../utils/i18n'

const props = defineProps({ model: { type: Object, required: true }, loading: Boolean })
defineEmits(['submit', 'fill-from-profile'])
const statuses = Object.values(RESUME_STATUS)
const update = (key, value) => { props.model[key] = value }
</script>
