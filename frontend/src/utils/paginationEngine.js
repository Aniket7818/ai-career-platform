export const A4_HEIGHT_PX = 1122.5; // Exact 297mm at 96 DPI
export const A4_WIDTH_PX = 794;  // 210mm at 96 DPI

/**
 * Simulates the browser's print pagination engine.
 * Walks the DOM of a shadow render container and calculates exactly 
 * where page breaks will occur based on `break-inside: avoid` rules.
 */
export function calculatePagination(container, scale = 1) {
  if (!container) return { pageCount: 1, breaks: [], sections: [], realEstate: {} };

  const sections = [];
  const breaks = [];
  let currentPage = 1;
  let currentY = 0; // Relative to the document

  // Elements that shouldn't break across pages (matching ResumePrintView.vue CSS)
  const avoidBreakSelectors = 'section, .resume-card, .border-l-2, h1, h2, h3, p, li, .prevent-break';
  
  // Get all unbreakable blocks
  const allBlocks = Array.from(container.querySelectorAll(avoidBreakSelectors));
  
  const containerRect = container.getBoundingClientRect();
  // Chrome Print needs a safe zone roughly equal to the bottom padding of the template (e.g. py-8 = 32px)
  const PRINT_SAFE_ZONE = 32;
  let pageBottomOffset = A4_HEIGHT_PX - PRINT_SAFE_ZONE;
  
  // We process blocks in DOM order. 
  // If a block crosses a page boundary and is smaller than a page, we break before it.
  // We must skip children of a block we just pushed to the next page, as their coordinates will shift.
  // Since we can't physically shift them in this purely analytical pass, we keep track of the cumulative offset.
  
  let currentShift = 0;

  allBlocks.forEach((block) => {
    const rect = block.getBoundingClientRect();
    const top = (rect.top - containerRect.top) / scale + currentShift;
    const height = rect.height / scale;

    // Add the element's bottom margin to accurately simulate flow height
    const style = window.getComputedStyle(block);
    const marginBottom = (parseFloat(style.marginBottom) || 0) / scale;
    
    const bottom = top + height + marginBottom;

    // Record section info for the debug panel (only top-level sections)
    if (block.tagName.toLowerCase() === 'section' || block.classList.contains('resume-section')) {
      let sectionName = block.getAttribute('data-section') || block.id;
      if (!sectionName) {
        // Try to find a header
        const header = block.querySelector('h1, h2, h3');
        if (header) sectionName = header.textContent.trim();
        else sectionName = block.className.split(' ')[0] || 'Unknown';
      }
      sections.push({ name: sectionName, top: Math.round(top), bottom: Math.round(bottom), height: Math.round(height) });
    }

    // Check if block crosses the current page boundary
    if (bottom > pageBottomOffset) {
      if (height < A4_HEIGHT_PX) {
        // Look back to see if the previous block was a header (h1, h2, h3, h4, h5, h6).
        // If so, we must push the header to the next page along with this block.
        let actualTop = top;
        let prevIndex = allBlocks.indexOf(block) - 1;
        let shiftExtra = 0;
        
        if (prevIndex >= 0) {
          const prevBlock = allBlocks[prevIndex];
          if (/^h[1-6]$/i.test(prevBlock.tagName)) {
             const prevRect = prevBlock.getBoundingClientRect();
             const prevTop = (prevRect.top - containerRect.top) / scale + currentShift;
             actualTop = prevTop;
             shiftExtra = top - prevTop;
          }
        }

        // Break before this block (or its header)
        const shiftAmount = pageBottomOffset - actualTop;
        breaks.push(actualTop); // Visual line at the original unshifted coordinate
        currentPage++;
        pageBottomOffset += A4_HEIGHT_PX;
        
        // Because we virtually pushed this block to the next page, all subsequent blocks 
        // will be shifted down by `shiftAmount`.
        currentShift += shiftAmount;
      }
    }
  });

  // Recalculate real estate based on shifted heights
  const realEstate = {};
  sections.forEach(sec => {
    realEstate[sec.name] = ((sec.height / (currentPage * A4_HEIGHT_PX)) * 100).toFixed(1) + '%';
  });

  return {
    pageCount: currentPage,
    breaks: breaks.map(b => Math.round(b)),
    sections,
    realEstate,
    totalHeight: Math.round(container.scrollHeight / scale + currentShift)
  };
}
