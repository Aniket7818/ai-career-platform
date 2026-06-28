const fs = require('fs');
const file = '/home/aniket/Desktop/Projects/ai-career-platform/frontend/src/modules/resumes/IntelligencePanel.vue';
let content = fs.readFileSync(file, 'utf8');

// The bugs are activeSection['']
// We know which section they belong to by the headers and toggleSection('key')

const sections = ['health', 'coach', 'checklist', 'ats', 'keywords', 'stats', 'level'];

for (const sec of sections) {
  // Let's replace line by line based on context.
  // Actually, simpler: replace all activeSection[''] between the section comment and the next section comment.
}
