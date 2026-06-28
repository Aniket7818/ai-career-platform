const fs = require('fs');
const file = '/home/aniket/Desktop/Projects/ai-career-platform/frontend/src/modules/resumes/IntelligencePanel.vue';
let content = fs.readFileSync(file, 'utf8');

const sections = ['health', 'coach', 'checklist', 'ats', 'keywords', 'stats', 'level'];
let output = '';

let currentSection = '';
for (let line of content.split('\n')) {
  for (const s of sections) {
    if (line.includes(`toggleSection('${s}')`) || (s === 'health' && line.includes('toggleSection(\'health\')'))) {
      currentSection = s;
    }
  }
  // The health section has an activeSection[''] before the toggleSection call:
  if (line.includes('v-if="activeSection[\'\']"') && output.includes('Score Breakdown')) {
      currentSection = 'health';
  }
  if (line.includes('toggleSection') && line.includes('health')) {
      currentSection = 'health';
  }
  
  // Actually, we can just look for the comment boundaries
  if (line.includes('1. Health Score HERO')) currentSection = 'health';
  else if (line.includes('2. Resume Coach')) currentSection = 'coach';
  else if (line.includes('3. Resume Checklist')) currentSection = 'checklist';
  else if (line.includes('4. ATS Analysis')) currentSection = 'ats';
  else if (line.includes('5. Keyword Analysis')) currentSection = 'keywords';
  else if (line.includes('6. Statistics')) currentSection = 'stats';
  else if (line.includes('7. Experience Level')) currentSection = 'level';
  
  if (currentSection) {
    line = line.replace(/activeSection\[''\]/g, `activeSection['${currentSection}']`);
  }
  output += line + '\n';
}

fs.writeFileSync(file, output.slice(0, -1)); // remove last newline
console.log('Fixed IntelligencePanel.vue');
