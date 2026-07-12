import { diffResume } from './resumeDiffEngine.js'

/**
 * Reusable helper to construct success notification title and message dynamically.
 * Handles singular vs. plural forms, proper grammar, and section-specific phrasing.
 * Leverages the Resume Diff Engine to describe exact structural changes.
 * 
 * @param {Object} params
 * @param {string} params.type - The optimization action type (e.g., 'improve_skills', 'rewrite_experience', etc.)
 * @param {number} [params.count] - Optional fallback item count
 * @param {Object} [params.oldContent] - The original resume content object prior to optimization
 * @param {Object} [params.newContent] - The new resume content object after optimization
 * @param {Object} [params.backendResponse] - The parsed backend response data
 * @param {Object} [params.diff] - Pre-calculated diff object
 * @returns {Object} { title, message }
 */
export function buildSuccessMessage({ type, count, oldContent, newContent, backendResponse, diff }) {
  const normalizedType = (type || '').toLowerCase()
  
  // Calculate diff if not provided but content is available
  const resumeDiff = diff || (oldContent && newContent ? diffResume(oldContent, newContent) : null)

  let title = 'Changes Applied Successfully'
  let message = 'Your resume has been updated.'

  // 1. If we have a resume diff, prioritize diff-driven messaging
  if (resumeDiff) {
    // Skills Section
    if (['improve_skills', 'ats_booster', 'skills', 'skilllist'].includes(normalizedType)) {
      const added = resumeDiff.addedSkills
      title = 'Skills Applied Successfully'
      message = added === 1
        ? '1 new skill added.'
        : `${added} new skills added.`
      return { title, message }
    }
    
    // Professional Summary
    if (['generate_summary', 'summary', 'personal', 'professional_summary'].includes(normalizedType)) {
      title = 'Professional Summary Updated'
      message = 'Your professional summary has been updated.'
      return { title, message }
    }
    
    // Work Experience Section
    if (['rewrite_experience', 'experience', 'experiences', 'work_experience', 'rewrite', 'expand', 'shorten', 'achievement_generator'].includes(normalizedType)) {
      title = 'Work Experience Updated'
      if (resumeDiff.addedExperiences > 0 && resumeDiff.updatedExperiences > 0) {
        const addedText = resumeDiff.addedExperiences === 1 ? '1 new entry added' : `${resumeDiff.addedExperiences} new entries added`
        const updatedText = resumeDiff.updatedExperiences === 1 ? '1 existing entry updated' : `${resumeDiff.updatedExperiences} existing entries updated`
        message = `${addedText} and ${updatedText}.`
      } else if (resumeDiff.addedExperiences > 0) {
        title = 'Work Experience Added'
        message = resumeDiff.addedExperiences === 1
          ? '1 work experience entry has been added to your resume.'
          : `${resumeDiff.addedExperiences} work experience entries have been added to your resume.`
      } else if (resumeDiff.updatedExperiences > 0) {
        title = 'Work Experience Updated'
        message = resumeDiff.updatedExperiences === 1
          ? '1 work experience entry has been updated.'
          : `${resumeDiff.updatedExperiences} work experience entries have been updated.`
      }
      return { title, message }
    }
    
    // Projects Section
    if (['optimize_project', 'project', 'projects'].includes(normalizedType)) {
      if (resumeDiff.addedProjects > 0 && resumeDiff.updatedProjects > 0) {
        const addedText = resumeDiff.addedProjects === 1 ? '1 new project added' : `${resumeDiff.addedProjects} new projects added`
        const updatedText = resumeDiff.updatedProjects === 1 ? '1 existing project updated' : `${resumeDiff.updatedProjects} existing projects updated`
        title = 'Projects Updated'
        message = `${addedText} and ${updatedText}.`
      } else if (resumeDiff.addedProjects > 0) {
        title = 'Project Added'
        message = resumeDiff.addedProjects === 1
          ? '1 AI-generated project has been added.'
          : `${resumeDiff.addedProjects} AI-generated projects have been added.`
      } else if (resumeDiff.updatedProjects > 0) {
        title = 'Project Updated'
        const techChanged = resumeDiff.updatedTechnology > 0
        const descChanged = resumeDiff.updatedDescriptions > 0
        
        if (techChanged && descChanged) {
          message = 'Description and technologies updated.'
        } else if (techChanged) {
          message = resumeDiff.updatedTechnology === 1
            ? 'Technologies updated in 1 project.'
            : `Technologies updated in ${resumeDiff.updatedTechnology} projects.`
        } else if (descChanged) {
          message = resumeDiff.updatedDescriptions === 1
            ? 'Project description updated.'
            : `Project descriptions updated in ${resumeDiff.updatedDescriptions} projects.`
        } else {
          message = resumeDiff.updatedProjects === 1
            ? '1 project has been updated.'
            : `${resumeDiff.updatedProjects} projects have been updated.`
        }
      }
      return { title, message }
    }
    
    // Education Section
    if (['education', 'educations'].includes(normalizedType)) {
      title = 'Education Updated'
      if (resumeDiff.addedEducations > 0 && resumeDiff.updatedEducations > 0) {
        const addedText = resumeDiff.addedEducations === 1 ? '1 new entry added' : `${resumeDiff.addedEducations} new entries added`
        const updatedText = resumeDiff.updatedEducations === 1 ? '1 existing entry updated' : `${resumeDiff.updatedEducations} existing entries updated`
        message = `${addedText} and ${updatedText}.`
      } else if (resumeDiff.addedEducations > 0) {
        message = resumeDiff.addedEducations === 1
          ? '1 education entry has been added to your resume.'
          : `${resumeDiff.addedEducations} education entries have been added to your resume.`
      } else if (resumeDiff.updatedEducations > 0) {
        message = resumeDiff.updatedEducations === 1
          ? '1 education entry has been updated on your resume.'
          : `${resumeDiff.updatedEducations} education entries have been updated on your resume.`
      }
      return { title, message }
    }
    
    // Certifications Section
    if (['certification', 'certifications'].includes(normalizedType)) {
      title = 'Certifications Updated'
      if (resumeDiff.addedCertifications > 0 && resumeDiff.updatedCertifications > 0) {
        const addedText = resumeDiff.addedCertifications === 1 ? '1 new certification added' : `${resumeDiff.addedCertifications} new certifications added`
        const updatedText = resumeDiff.updatedCertifications === 1 ? '1 existing certification updated' : `${resumeDiff.updatedCertifications} existing certifications updated`
        message = `${addedText} and ${updatedText}.`
      } else if (resumeDiff.addedCertifications > 0) {
        message = resumeDiff.addedCertifications === 1
          ? '1 certification has been added to your resume.'
          : `${resumeDiff.addedCertifications} certifications have been added to your resume.`
      } else if (resumeDiff.updatedCertifications > 0) {
        message = resumeDiff.updatedCertifications === 1
          ? '1 certification has been updated.'
          : `${resumeDiff.updatedCertifications} certifications have been updated.`
      }
      return { title, message }
    }
    
    // Fallback: Check if multiple sections were updated in a general/tailor optimization
    const changes = []
    if (resumeDiff.addedSkills > 0) changes.push(`${resumeDiff.addedSkills} new skill(s) added`)
    if (resumeDiff.updatedSummary) changes.push('professional summary updated')
    if (resumeDiff.addedProjects > 0) changes.push(`${resumeDiff.addedProjects} project(s) added`)
    if (resumeDiff.updatedProjects > 0) changes.push(`${resumeDiff.updatedProjects} project(s) updated`)
    if (resumeDiff.addedExperiences > 0) changes.push(`${resumeDiff.addedExperiences} experience(s) added`)
    if (resumeDiff.updatedExperiences > 0) changes.push(`${resumeDiff.updatedExperiences} experience(s) updated`)
    if (resumeDiff.addedEducations > 0) changes.push(`${resumeDiff.addedEducations} education(s) added`)
    if (resumeDiff.updatedEducations > 0) changes.push(`${resumeDiff.updatedEducations} education(s) updated`)
    if (resumeDiff.addedCertifications > 0) changes.push(`${resumeDiff.addedCertifications} certification(s) added`)
    if (resumeDiff.updatedCertifications > 0) changes.push(`${resumeDiff.updatedCertifications} certification(s) updated`)

    if (changes.length > 0) {
      title = 'Resume Tailored Successfully'
      message = `Updated: ${changes.join(', ')}.`
      return { title, message }
    }
  }

  // 2. Fallback to count-based and default messages if no diff is available
  const finalCount = count || 1
  switch (normalizedType) {
    case 'improve_skills':
    case 'ats_booster':
    case 'skills':
    case 'skilllist':
      title = 'Skills Applied Successfully'
      message = finalCount === 1
        ? '1 new skill added.'
        : `${finalCount} new skills added.`
      break

    case 'generate_summary':
    case 'summary':
    case 'personal':
    case 'professional_summary':
      title = 'Professional Summary Updated'
      message = 'Your professional summary has been updated.'
      break

    case 'rewrite_experience':
    case 'experience':
    case 'experiences':
    case 'work_experience':
    case 'rewrite':
    case 'expand':
    case 'shorten':
    case 'achievement_generator':
      title = 'Work Experience Updated'
      message = finalCount === 1
        ? '1 work experience entry has been updated.'
        : `${finalCount} work experience entries have been updated.`
      break

    case 'optimize_project':
    case 'project':
    case 'projects':
      title = 'Project Updated'
      message = finalCount === 1
        ? '1 project has been updated.'
        : `${finalCount} projects have been updated.`
      break

    case 'education':
    case 'educations':
      title = 'Education Updated'
      message = finalCount === 1
        ? '1 education entry has been updated on your resume.'
        : `${finalCount} education entries have been updated on your resume.`
      break

    case 'certification':
    case 'certifications':
      title = 'Certifications Updated'
      message = finalCount === 1
        ? '1 certification has been updated.'
        : `${finalCount} certifications have been updated.`
      break

    case 'generate_cover_letter':
    case 'cover_letter':
      title = 'Cover Letter Generated Successfully'
      message = 'Your personalized cover letter is ready.'
      break

    case 'generate_linkedin':
    case 'linkedin_optimizer':
      title = 'LinkedIn Profile Optimized'
      message = 'Your LinkedIn profile optimization is ready.'
      break

    default:
      if (backendResponse?.message) {
        message = backendResponse.message
      }
  }

  return { title, message }
}

export default buildSuccessMessage
