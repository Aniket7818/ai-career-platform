const fs = require('fs');
const file = '/home/aniket/Desktop/Projects/ai-career-platform/frontend/src/modules/resumes/IntelligencePanel.vue';
let content = fs.readFileSync(file, 'utf8');

// The file currently has things like:
// <div v-if="activeSection['health']" class="mt-3 border-t border-slate-100 dark:border-slate-800/80 pt-3 space-y-3">
// mixed up. Let's reset all activeSection['something'] to activeSection[''] first.
content = content.replace(/activeSection\['[^']*'\]/g, "activeSection['']");

const sections = ['health', 'coach', 'checklist', 'ats', 'keywords', 'stats', 'level'];
let output = '';
let currentSection = '';

for (let line of content.split('\n')) {
  if (line.includes('1. Health Score HERO')) currentSection = 'health';
  else if (line.includes('2. Resume Coach')) currentSection = 'coach';
  else if (line.includes('3. Resume Checklist')) currentSection = 'checklist';
  else if (line.includes('4. ATS Analysis')) currentSection = 'ats';
  else if (line.includes('5. Keyword Analysis')) currentSection = 'keywords';
  else if (line.includes('6. Statistics')) currentSection = 'stats';
  else if (line.includes('7. Experience Level')) currentSection = 'level';
  
  if (currentSection && line.includes("activeSection['']")) {
    line = line.replace(/activeSection\[''\]/g, `activeSection['${currentSection}']`);
  }
  output += line + '\n';
}

fs.writeFileSync(file, output.slice(0, -1));
console.log('Fixed IntelligencePanel.vue properly');
