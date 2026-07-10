<template>
  <div v-if="modelValue" class="loading-overlay">
    <div class="loading-container">
      
      <!-- Premium Spinner -->
      <div class="spinner-wrapper">
        <svg class="premium-spinner" viewBox="0 0 50 50">
          <circle class="path" cx="25" cy="25" r="20" fill="none" stroke-width="4"></circle>
        </svg>
        <div class="glow-pulse"></div>
      </div>
      
      <!-- Rotating Messages -->
      <div class="message-wrapper">
        <transition name="fade" mode="out-in">
          <h3 :key="currentMessageIndex" class="loading-message">
            {{ messages[currentMessageIndex] }}
          </h3>
        </transition>
      </div>

      <div class="info-messages mt-4">
        <p class="desc-subtitle">Generating professional content...</p>
        
        <div class="info-badge-box">
          <svg class="info-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
            <circle cx="12" cy="12" r="10"></circle>
            <line x1="12" y1="16" x2="12" y2="12"></line>
            <line x1="12" y1="8" x2="12.01" y2="8"></line>
          </svg>
          <span>Credits will only be deducted after successful completion.</span>
        </div>
        
        <p class="warning-alert-text">
          <span class="warning-pulse"></span>
          Do NOT close this page.
        </p>
      </div>

      <!-- Progress Bar -->
      <div class="progress-bar-container">
        <div class="progress-bar-fill" :style="{ width: `${progress}%` }">
          <div class="progress-shine"></div>
        </div>
      </div>
      
      <p class="estimated-time">Estimated remaining time: <span>{{ Math.max(0, 15 - Math.floor(progress / 6.66)) }} sec</span></p>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, onUnmounted, watch } from 'vue'

const props = defineProps({
  modelValue: { type: Boolean, default: false },
  actionType: { type: String, default: 'optimize' }
})

const emit = defineEmits(['update:modelValue'])

const messages = ref([])
const currentMessageIndex = ref(0)
const progress = ref(0)
let messageInterval = null
let progressInterval = null

const estimatedTime = ref(15) // seconds

function initMessages() {
  const baseMessages = [
    'Initializing AI engine...',
    'Reading your resume content...',
    'Analyzing professional experience...',
    'Cross-referencing with industry standards...',
    'Generating optimal phrasing...',
    'Applying AI enhancements...',
    'Finalizing new version...'
  ]
  
  if (props.actionType === 'tailor_to_job' || props.actionType === 'optimize') {
    messages.value = [
      'Extracting key requirements from Job Description...',
      'Mapping your skills to the required role...',
      'Rewriting bullets for maximum relevance...',
      'Boosting ATS keyword density...',
      'Polishing the final document...'
    ]
  } else if (props.actionType === 'generate_cover_letter') {
    messages.value = [
      'Analyzing your career narrative...',
      'Reviewing company and role details...',
      'Drafting a compelling introduction...',
      'Structuring your key achievements...',
      'Applying the requested tone...',
      'Finalizing your cover letter...'
    ]
  } else if (props.actionType === 'generate_linkedin') {
    messages.value = [
      'Reviewing professional summary...',
      'Extracting top skills...',
      'Crafting an SEO-optimized headline...',
      'Writing an engaging About section...',
      'Formatting for LinkedIn readability...'
    ]
  } else {
    messages.value = baseMessages
  }
}

function startAnimation() {
  initMessages()
  currentMessageIndex.value = 0
  progress.value = 0
  
  // Rotate messages every 2.5s
  messageInterval = setInterval(() => {
    if (currentMessageIndex.value < messages.value.length - 1) {
      currentMessageIndex.value++
    }
  }, 2500)

  // Fake progress up to 90% over estimatedTime
  const tickRate = 100 // ms
  const totalTicks = (estimatedTime.value * 1000) / tickRate
  const progressPerTick = 90 / totalTicks

  progressInterval = setInterval(() => {
    if (progress.value < 90) {
      progress.value += progressPerTick
    }
  }, tickRate)
}

function stopAnimation() {
  clearInterval(messageInterval)
  clearInterval(progressInterval)
  progress.value = 100
}

watch(() => props.modelValue, (newVal) => {
  if (newVal) {
    startAnimation()
  } else {
    stopAnimation()
  }
})

onUnmounted(() => {
  stopAnimation()
})
</script>

<style scoped>
.loading-overlay {
  position: fixed;
  top: 0; left: 0; right: 0; bottom: 0;
  background: rgba(15, 23, 42, 0.8);
  backdrop-filter: blur(12px);
  z-index: 1000;
  display: flex;
  align-items: center;
  justify-content: center;
  animation: fadeIn 0.4s ease;
}

@keyframes fadeIn {
  from { opacity: 0; }
  to { opacity: 1; }
}

.loading-container {
  display: flex;
  flex-direction: column;
  align-items: center;
  width: 90%;
  max-width: 400px;
}

.spinner-wrapper {
  position: relative;
  width: 80px; height: 80px;
  margin-bottom: 2rem;
}

.premium-spinner {
  animation: rotate 2s linear infinite;
  z-index: 2;
  position: relative;
  width: 100%; height: 100%;
}

.premium-spinner .path {
  stroke: #8b5cf6;
  stroke-linecap: round;
  animation: dash 1.5s ease-in-out infinite;
}

@keyframes rotate {
  100% { transform: rotate(360deg); }
}

@keyframes dash {
  0% { stroke-dasharray: 1, 150; stroke-dashoffset: 0; }
  50% { stroke-dasharray: 90, 150; stroke-dashoffset: -35; }
  100% { stroke-dasharray: 90, 150; stroke-dashoffset: -124; }
}

.glow-pulse {
  position: absolute;
  top: 50%; left: 50%;
  transform: translate(-50%, -50%);
  width: 100%; height: 100%;
  background: #8b5cf6;
  border-radius: 50%;
  filter: blur(20px);
  opacity: 0.3;
  animation: pulse 2s infinite ease-in-out;
  z-index: 1;
}

@keyframes pulse {
  0% { transform: translate(-50%, -50%) scale(0.8); opacity: 0.2; }
  50% { transform: translate(-50%, -50%) scale(1.2); opacity: 0.5; }
  100% { transform: translate(-50%, -50%) scale(0.8); opacity: 0.2; }
}

.message-wrapper {
  height: 2rem;
  margin-bottom: 1.5rem;
  display: flex;
  align-items: center;
  justify-content: center;
  text-align: center;
}

.loading-message {
  margin: 0;
  font-size: 1.125rem;
  font-weight: 600;
  color: white;
  letter-spacing: 0.01em;
}

.fade-enter-active,
.fade-leave-active {
  transition: opacity 0.3s ease, transform 0.3s ease;
}
.fade-enter-from { opacity: 0; transform: translateY(10px); }
.fade-leave-to { opacity: 0; transform: translateY(-10px); }

.progress-bar-container {
  width: 100%;
  height: 8px;
  background: rgba(255, 255, 255, 0.08);
  border-radius: 9999px;
  overflow: hidden;
  margin-bottom: 0.85rem;
  position: relative;
  box-shadow: inset 0 1px 2px rgba(0, 0, 0, 0.3);
}

.progress-bar-fill {
  height: 100%;
  background: linear-gradient(90deg, #6366f1, #a855f7, #ec4899);
  border-radius: 9999px;
  transition: width 0.1s linear;
  position: relative;
  overflow: hidden;
  box-shadow: 0 0 8px rgba(168, 85, 247, 0.5);
}

.progress-shine {
  position: absolute;
  top: 0; left: 0; bottom: 0; right: 0;
  background: linear-gradient(90deg, transparent, rgba(255,255,255,0.4), transparent);
  animation: shine 1.5s infinite linear;
}

@keyframes shine {
  0% { transform: translateX(-100%); }
  100% { transform: translateX(100%); }
}

.estimated-time {
  margin: 0;
  font-size: 0.8125rem;
  color: rgba(255, 255, 255, 0.55);
  font-weight: 500;
}
.estimated-time span {
  color: #a855f7;
  font-weight: 700;
}

.info-messages {
  text-align: center;
  width: 100%;
}
.desc-subtitle {
  font-size: 0.875rem;
  color: rgba(255, 255, 255, 0.65);
  margin: 0 0 1rem 0;
  font-weight: 500;
}
.info-badge-box {
  display: inline-flex;
  align-items: center;
  gap: 0.5rem;
  background: rgba(56, 189, 248, 0.08);
  border: 1px solid rgba(56, 189, 248, 0.25);
  color: #38bdf8;
  font-size: 0.8125rem;
  font-weight: 600;
  padding: 0.5rem 0.875rem;
  border-radius: 0.5rem;
  margin-bottom: 1rem;
  max-width: 90%;
  line-height: 1.4;
  text-align: left;
}
.info-icon {
  width: 1.125rem;
  height: 1.125rem;
  flex-shrink: 0;
}
.warning-alert-text {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  gap: 0.375rem;
  font-size: 0.8125rem;
  font-weight: 750;
  color: #ef4444;
  margin: 0 0 1.25rem 0;
  text-transform: uppercase;
  letter-spacing: 0.05em;
}
.warning-pulse {
  width: 6px;
  height: 6px;
  background-color: #ef4444;
  border-radius: 50%;
  display: inline-block;
  box-shadow: 0 0 0 0 rgba(239, 68, 68, 0.7);
  animation: warningPulseAnim 1.6s infinite;
}
@keyframes warningPulseAnim {
  0% {
    transform: scale(0.95);
    box-shadow: 0 0 0 0 rgba(239, 68, 68, 0.7);
  }
  70% {
    transform: scale(1);
    box-shadow: 0 0 0 5px rgba(239, 68, 68, 0);
  }
  100% {
    transform: scale(0.95);
    box-shadow: 0 0 0 0 rgba(239, 68, 68, 0);
  }
}
</style>
