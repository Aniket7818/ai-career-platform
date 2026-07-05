import { ref, watch, computed } from 'vue'

const BOOKMARKS_KEY = 'iprep_bookmarks'
const COMPLETED_KEY = 'iprep_completed'
const RECENTLY_VIEWED_KEY = 'iprep_recent'
const CONTINUE_LEARNING_KEY = 'iprep_continue'

// Global state initialized from localStorage
const bookmarks = ref(new Set(JSON.parse(localStorage.getItem(BOOKMARKS_KEY) || '[]')))
const completed = ref(new Set(JSON.parse(localStorage.getItem(COMPLETED_KEY) || '[]')))
const recentlyViewed = ref(JSON.parse(localStorage.getItem(RECENTLY_VIEWED_KEY) || '[]'))
const continueLearning = ref(JSON.parse(localStorage.getItem(CONTINUE_LEARNING_KEY) || 'null'))

// Persist changes automatically
watch(bookmarks, (newVal) => localStorage.setItem(BOOKMARKS_KEY, JSON.stringify(Array.from(newVal))), { deep: true })
watch(completed, (newVal) => localStorage.setItem(COMPLETED_KEY, JSON.stringify(Array.from(newVal))), { deep: true })
watch(recentlyViewed, (newVal) => localStorage.setItem(RECENTLY_VIEWED_KEY, JSON.stringify(newVal)), { deep: true })
watch(continueLearning, (newVal) => localStorage.setItem(CONTINUE_LEARNING_KEY, JSON.stringify(newVal)), { deep: true })

export function useInterviewState() {
 // Bookmark Logic
 const toggleBookmark = (subjectSlug, questionId, questionDetails = null) => {
 const key = `${subjectSlug}::${questionId}`
 if (bookmarks.value.has(key)) {
 bookmarks.value.delete(key)
 return false
 } else {
 bookmarks.value.add(key)
 return true
 }
 }

 const isBookmarked = (subjectSlug, questionId) => bookmarks.value.has(`${subjectSlug}::${questionId}`)

 // Completion Logic
 const toggleCompleted = (subjectSlug, questionId) => {
 const key = `${subjectSlug}::${questionId}`
 if (completed.value.has(key)) {
 completed.value.delete(key)
 return false
 } else {
 completed.value.add(key)
 return true
 }
 }

 const isCompleted = (subjectSlug, questionId) => completed.value.has(`${subjectSlug}::${questionId}`)

 // Recently Viewed Logic (Phase 5)
 const addRecentlyViewed = (subjectSlug, questionId, details) => {
 const entry = { subjectSlug, questionId, title: details.title, difficulty: details.difficulty, topic: details.topic, timestamp: Date.now() }
 let recent = recentlyViewed.value.filter(item => !(item.subjectSlug === subjectSlug && String(item.questionId) === String(questionId)))
 recent.unshift(entry)
 if (recent.length > 20) recent = recent.slice(0, 20)
 recentlyViewed.value = recent
 }

 // Continue Learning Logic (Phase 4)
 const setContinueLearning = (subjectSlug, subjectName, questionId, currentIndex, totalQuestions) => {
 continueLearning.value = {
 subjectSlug,
 subjectName,
 questionId,
 currentIndex,
 totalQuestions,
 timestamp: Date.now()
 }
 }

 // Stats Logic (Phase 7, 8, 11)
 const getSubjectStats = (subjectSlug, totalQuestions) => {
 let bCount = 0, cCount = 0
 bookmarks.value.forEach(key => { if (key.startsWith(`${subjectSlug}::`)) bCount++ })
 completed.value.forEach(key => { if (key.startsWith(`${subjectSlug}::`)) cCount++ })
 return {
 bookmarked: bCount,
 completed: cCount,
 remaining: Math.max(0, totalQuestions - cCount),
 progressPercentage: totalQuestions > 0 ? Math.round((cCount / totalQuestions) * 100) : 0
 }
 }
 
 const totalBookmarkedCount = computed(() => bookmarks.value.size)
 const totalCompletedCount = computed(() => completed.value.size)

 return {
 bookmarks,
 completed,
 recentlyViewed,
 continueLearning,
 toggleBookmark,
 isBookmarked,
 toggleCompleted,
 isCompleted,
 addRecentlyViewed,
 setContinueLearning,
 getSubjectStats,
 totalBookmarkedCount,
 totalCompletedCount
 }
}
