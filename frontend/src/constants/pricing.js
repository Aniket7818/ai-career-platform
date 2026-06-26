export const PRICING_PLANS = [
  {
    id: 'free',
    name: 'Free',
    monthlyPrice: 0,
    yearlyPrice: 0,
    credits: 0,
    badge: null,
    features: [
      { name: 'Resume Builder', included: true },
      { name: '1 Resume', included: true },
      { name: '3 PDF Downloads', included: true },
      { name: 'Basic ATS Score', included: true },
      { name: 'Profile Management', included: true },
      { name: 'AI Resume Rewrite', included: false },
      { name: 'AI Cover Letter Generator', included: false },
      { name: 'AI Interview Preparation', included: false },
      { name: 'Job Match Analysis', included: false },
      { name: 'LinkedIn Review', included: false }
    ]
  },
  {
    id: 'plus',
    name: 'CareerAI Plus',
    monthlyPrice: 99,
    yearlyPrice: 999,
    credits: 50,
    badge: 'Most Popular',
    features: [
      { name: '50 AI Credits per month', included: true },
      { name: 'Unlimited PDF Downloads', included: true },
      { name: 'ATS Optimization', included: true },
      { name: 'AI Resume Assistant', included: true },
      { name: 'AI Resume Rewrite', included: true },
      { name: 'AI Cover Letter Generator', included: true },
      { name: 'Portfolio Generator', included: true },
      { name: 'LinkedIn Review', included: true },
      { name: 'Priority Support', included: true }
    ]
  },
  {
    id: 'pro',
    name: 'CareerAI Pro',
    monthlyPrice: 199,
    yearlyPrice: 1999,
    credits: 200,
    badge: 'Best Value',
    features: [
      { name: '200 AI Credits per month', included: true },
      { name: 'Everything in Plus', included: true },
      { name: 'AI Mock Interviews', included: true },
      { name: 'Job Match Analysis', included: true },
      { name: 'Career Roadmap Generator', included: true },
      { name: 'Advanced ATS Reports', included: true },
      { name: 'Priority Processing', included: true },
      { name: 'Early Access Features', included: true }
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
  { name: 'AI Credits', free: '0', plus: '50 / month', pro: '200 / month' },
  { name: 'Support Level', free: 'Community', plus: 'Priority', pro: 'Priority' }
]

export const AI_CREDIT_COSTS = [
  { action: 'ATS Analysis', cost: 1 },
  { action: 'Cover Letter Generation', cost: 2 },
  { action: 'Resume Rewrite', cost: 3 },
  { action: 'LinkedIn Review', cost: 3 },
  { action: 'Interview Session', cost: 5 }
]
