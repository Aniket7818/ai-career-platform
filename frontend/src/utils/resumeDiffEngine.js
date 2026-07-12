/**
 * Reusable utility to compute a deep comparison (diff) between two resume content hashes.
 * Tracks additions, removals, and detailed field-level updates across all sections.
 * 
 * @param {Object} oldContent - Original resume content
 * @param {Object} newContent - Optimized resume content
 * @returns {Object} Structured diff results
 */
export function diffResume(oldContent, newContent) {
  const result = {
    addedProjects: 0,
    updatedProjects: 0,
    updatedTechnology: 0,
    updatedDescriptions: 0,
    
    addedSkills: 0,
    removedSkills: 0,
    
    updatedSummary: false,
    
    addedExperiences: 0,
    updatedExperiences: 0,
    
    addedEducations: 0,
    updatedEducations: 0,
    
    addedCertifications: 0,
    updatedCertifications: 0
  }

  if (!oldContent || !newContent) return result

  // Helper to diff arrays of objects using their 'id' field
  const diffArraySection = (oldList = [], newList = []) => {
    const added = []
    const updated = []
    const removed = []

    const oldMap = new Map(
      oldList
        .filter(item => item && (item.id || item.projectName || item.school || item.company || item.certName))
        .map(item => [item.id || JSON.stringify(item), item])
    )
    
    const newMap = new Map(
      newList
        .filter(item => item && (item.id || item.projectName || item.school || item.company || item.certName))
        .map(item => [item.id || JSON.stringify(item), item])
    )

    newList.forEach(newItem => {
      if (!newItem) return
      const key = newItem.id || JSON.stringify(newItem)
      const oldItem = oldMap.get(key)
      if (!oldItem) {
        added.push(newItem)
      } else {
        const changes = getObjectChanges(oldItem, newItem)
        if (changes.length > 0) {
          updated.push({ oldItem, newItem, changes })
        }
      }
    })

    oldList.forEach(oldItem => {
      if (!oldItem) return
      const key = oldItem.id || JSON.stringify(oldItem)
      if (!newMap.has(key)) {
        removed.push(oldItem)
      }
    })

    return { added, updated, removed }
  }

  // Helper to get changed keys between two objects
  const getObjectChanges = (oldObj, newObj) => {
    const changes = []
    const allKeys = new Set([...Object.keys(oldObj), ...Object.keys(newObj)])
    allKeys.delete('id') // Ignore unique ID fields
    
    for (const key of allKeys) {
      const oldVal = (oldObj[key] === undefined || oldObj[key] === null) ? '' : oldObj[key].toString().trim()
      const newVal = (newObj[key] === undefined || newObj[key] === null) ? '' : newObj[key].toString().trim()
      if (oldVal !== newVal) {
        changes.push(key)
      }
    }
    return changes
  }

  // 1. Projects Diff
  const oldProjs = oldContent.projects || []
  const newProjs = newContent.projects || []
  const projDiff = diffArraySection(oldProjs, newProjs)
  result.addedProjects = projDiff.added.length
  result.updatedProjects = projDiff.updated.length
  projDiff.updated.forEach(({ changes }) => {
    if (changes.includes('technologies')) {
      result.updatedTechnology++
    }
    if (changes.includes('description') || changes.includes('projectName') || changes.includes('projectLink')) {
      // Treat text updates as description/content updates
      result.updatedDescriptions++
    }
  })

  // 2. Skills Diff
  const getSkillsList = (c) => {
    const list = c?.skills?.skillList || c?.skills || ''
    if (typeof list === 'string') {
      return list.split(',').map(s => s.trim().toLowerCase()).filter(Boolean)
    }
    if (Array.isArray(list)) {
      return list.map(s => s.trim().toLowerCase()).filter(Boolean)
    }
    return []
  }
  const oldSkills = getSkillsList(oldContent)
  const newSkills = getSkillsList(newContent)
  result.addedSkills = newSkills.filter(s => !oldSkills.includes(s)).length
  result.removedSkills = oldSkills.filter(s => !newSkills.includes(s)).length

  // 3. Professional Summary Diff
  const oldSummary = (oldContent.personal?.summary || oldContent.personal?.objective || '').toString().trim()
  const newSummary = (newContent.personal?.summary || newContent.personal?.objective || '').toString().trim()
  result.updatedSummary = oldSummary !== newSummary

  // 4. Work Experience Diff
  const oldExps = oldContent.experiences || []
  const newExps = newContent.experiences || []
  const expDiff = diffArraySection(oldExps, newExps)
  result.addedExperiences = expDiff.added.length
  result.updatedExperiences = expDiff.updated.length

  // 5. Education Diff
  const oldEdus = oldContent.educations || []
  const newEdus = newContent.educations || []
  const eduDiff = diffArraySection(oldEdus, newEdus)
  result.addedEducations = eduDiff.added.length
  result.updatedEducations = eduDiff.updated.length

  // 6. Certifications Diff
  const oldCerts = oldContent.certifications || []
  const newCerts = newContent.certifications || []
  const certDiff = diffArraySection(oldCerts, newCerts)
  result.addedCertifications = certDiff.added.length
  result.updatedCertifications = certDiff.updated.length

  return result
}

export default diffResume
