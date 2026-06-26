const fs = require('fs');
const path = require('path');

const templatesDir = path.join(__dirname, 'frontend/src/modules/resumes/templates');

// We assume the base font size was 14px.
const pxToEm = (px) => (parseInt(px) / 14).toFixed(3).replace(/\.?0+$/, '') + 'em';

fs.readdirSync(templatesDir).forEach(file => {
  if (file.endsWith('Template.vue')) {
    const filePath = path.join(templatesDir, file);
    let content = fs.readFileSync(filePath, 'utf8');

    // Replace text-[Xpx] with text-[Yem]
    content = content.replace(/text-\[(\d+)px\]/g, (match, p1) => {
      return `text-[${pxToEm(p1)}]`;
    });

    // Replace inline styles like font-size: Xpx
    content = content.replace(/font-size:\s*(\d+)px/g, (match, p1) => {
      return `font-size: ${pxToEm(p1)}`;
    });

    // Replace hardcoded Tailwind classes like text-sm (14px), text-xs (12px), text-lg (18px)
    // We replace them with explicit em brackets so they scale with the root fontSize style
    content = content.replace(/\btext-xs\b/g, `text-[${pxToEm(12)}]`);
    content = content.replace(/\btext-sm\b/g, `text-[${pxToEm(14)}]`);
    content = content.replace(/\btext-base\b/g, `text-[${pxToEm(16)}]`);
    content = content.replace(/\btext-lg\b/g, `text-[${pxToEm(18)}]`);
    content = content.replace(/\btext-xl\b/g, `text-[${pxToEm(20)}]`);
    content = content.replace(/\btext-2xl\b/g, `text-[${pxToEm(24)}]`);
    content = content.replace(/\btext-3xl\b/g, `text-[${pxToEm(30)}]`);

    fs.writeFileSync(filePath, content, 'utf8');
    console.log(`Updated ${file}`);
  }
});
