export const PRICING_PLANS = [
  {
    id: 'free',
    name: 'Free',
    monthlyPrice: 0,
    yearlyPrice: 0,
    credits: 10,
    badge: null,
    features: [
      { name: 'Resume Builder', included: true },
      { name: 'Interview Preparation', included: true },
      { name: 'Basic ATS Check', included: true },
      { name: '3 PDF Downloads limit', included: true },
      { name: '10 Welcome AI Credits', included: true },
      { name: 'Resume Rewrite', included: false },
      { name: 'Advanced ATS Suggestions', included: false },
      { name: 'LinkedIn Review', included: false },
      { name: 'Cover Letter Generator', included: false },
      { name: 'AI Mock Interviews', included: false }
    ]
  },
  {
    id: 'plus',
    name: 'CareerAI Plus',
    monthlyPrice: 199,
    yearlyPrice: 1999,
    credits: 150,
    badge: 'Recommended',
    features: [
      { name: '150 AI Credits per month', included: true },
      { name: 'Everything in Free', included: true },
      { name: 'Resume Rewrite', included: true },
      { name: 'Advanced ATS Suggestions', included: true },
      { name: 'LinkedIn Review', included: true },
      { name: 'Cover Letter Generator', included: true },
      { name: 'Portfolio Generator', included: true },
      { name: 'Priority Support', included: true }
    ]
  },
  {
    id: 'pro',
    name: 'CareerAI Pro',
    monthlyPrice: 499,
    yearlyPrice: 4999,
    credits: 500,
    badge: 'Best Value',
    features: [
      { name: '500 AI Credits per month', included: true },
      { name: 'Everything in Plus', included: true },
      { name: 'AI Mock Interviews', included: true },
      { name: 'Job Match Analysis', included: true },
      { name: 'Career Roadmap Generator', included: true },
      { name: 'Priority Support (Recruiter)', included: true }
    ]
  }
]

export const FEATURE_COMPARISON = [
  { name: 'Resume Builder', free: 'Basic', plus: 'Advanced', pro: 'Advanced' },
  { name: 'ATS Score', free: 'Basic', plus: 'Detailed', pro: 'Advanced Reports' },
  { name: 'Resume Downloads', free: '3 / month', plus: 'Unlimited', pro: 'Unlimited' },
  { name: 'Resume Rewrite', free: '-', plus: 'Yes (Credits)', pro: 'Yes (Credits)' },
  { name: 'Cover Letter Generator', free: '-', plus: 'Yes (Credits)', pro: 'Yes (Credits)' },
  { name: 'Mock Interviews', free: '-', plus: '-', pro: 'Yes (Credits)' },
  { name: 'Job Match Analysis', free: '-', plus: '-', pro: 'Yes' },
  { name: 'LinkedIn Review', free: '-', plus: 'Yes (Credits)', pro: 'Yes (Credits)' },
  { name: 'Career Roadmaps', free: '-', plus: '-', pro: 'Yes' },
  { name: 'AI Credits', free: '10', plus: '150 / month', pro: '500 / month' },
  { name: 'Support Level', free: 'Community', plus: 'Priority', pro: 'Priority Recruiter' }
]

export const AI_CREDIT_COSTS = [
  { action: 'ATS Analysis', cost: 1 },
  { action: 'Cover Letter Generation', cost: 2 },
  { action: 'Resume Rewrite', cost: 3 },
  { action: 'LinkedIn Review', cost: 3 },
  { action: 'Interview Session', cost: 5 }
]
