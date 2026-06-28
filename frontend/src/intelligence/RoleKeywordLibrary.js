// ─── Role-specific keyword libraries ──────────────────────────────────────────
// Each role maps to an array of keywords that ATS systems commonly scan for.
// Keywords are lowercase for case-insensitive comparison.

export const ROLE_KEYWORDS = Object.freeze({
  'Frontend Developer': [
    'react', 'javascript', 'typescript', 'html', 'css', 'vue', 'angular',
    'next.js', 'webpack', 'vite', 'tailwind', 'sass', 'scss', 'responsive design',
    'rest api', 'graphql', 'redux', 'state management', 'jest', 'testing',
    'accessibility', 'a11y', 'performance optimization', 'git', 'ci/cd',
    'figma', 'ui/ux', 'cross-browser', 'progressive web app', 'pwa',
    'component library', 'design system', 'storybook', 'npm', 'node.js'
  ],
  'Backend Developer': [
    'node.js', 'express', 'python', 'django', 'flask', 'java', 'spring boot',
    'sql', 'postgresql', 'mysql', 'mongodb', 'redis', 'rest api', 'graphql',
    'microservices', 'docker', 'kubernetes', 'aws', 'authentication', 'oauth',
    'jwt', 'api design', 'database design', 'orm', 'caching', 'queue',
    'rabbitmq', 'kafka', 'testing', 'ci/cd', 'git', 'linux', 'nginx',
    'serverless', 'lambda', 'scalability', 'security'
  ],
  'Full Stack Developer': [
    'react', 'javascript', 'typescript', 'node.js', 'express', 'python',
    'html', 'css', 'sql', 'postgresql', 'mongodb', 'rest api', 'graphql',
    'docker', 'aws', 'git', 'ci/cd', 'authentication', 'redux',
    'next.js', 'vue', 'angular', 'testing', 'jest', 'responsive design',
    'microservices', 'database design', 'deployment', 'linux', 'agile',
    'scrum', 'devops', 'performance', 'security', 'api design'
  ],
  'Data Analyst': [
    'python', 'sql', 'excel', 'tableau', 'power bi', 'pandas', 'numpy',
    'data visualization', 'statistical analysis', 'r', 'data cleaning',
    'etl', 'data modeling', 'dashboards', 'reporting', 'a/b testing',
    'hypothesis testing', 'regression', 'data mining', 'jupyter',
    'google analytics', 'kpi', 'metrics', 'business intelligence',
    'data warehousing', 'postgresql', 'mysql', 'spark', 'hadoop',
    'machine learning', 'predictive analytics', 'storytelling'
  ],
  'ML Engineer': [
    'python', 'tensorflow', 'pytorch', 'scikit-learn', 'machine learning',
    'deep learning', 'neural networks', 'nlp', 'computer vision', 'pandas',
    'numpy', 'data preprocessing', 'feature engineering', 'model deployment',
    'mlops', 'docker', 'kubernetes', 'aws sagemaker', 'gcp', 'sql',
    'spark', 'hadoop', 'a/b testing', 'statistical modeling', 'research',
    'transformer', 'bert', 'gpt', 'reinforcement learning', 'data pipeline',
    'experiment tracking', 'mlflow', 'wandb', 'git'
  ],
  'DevOps Engineer': [
    'docker', 'kubernetes', 'aws', 'azure', 'gcp', 'terraform', 'ansible',
    'jenkins', 'github actions', 'ci/cd', 'linux', 'bash', 'python',
    'monitoring', 'prometheus', 'grafana', 'elk stack', 'nginx', 'apache',
    'infrastructure as code', 'iac', 'helm', 'microservices', 'networking',
    'security', 'ssl', 'dns', 'load balancing', 'auto-scaling',
    'serverless', 'cloudformation', 'containerization', 'git', 'agile'
  ],
  'UI UX Designer': [
    'figma', 'sketch', 'adobe xd', 'prototyping', 'wireframing',
    'user research', 'usability testing', 'design thinking', 'user journey',
    'information architecture', 'interaction design', 'visual design',
    'typography', 'color theory', 'responsive design', 'accessibility',
    'design system', 'component library', 'a/b testing', 'persona',
    'user flow', 'heuristic evaluation', 'html', 'css', 'motion design',
    'animation', 'illustration', 'photoshop', 'illustrator', 'invision'
  ],
  'Cloud Engineer': [
    'aws', 'azure', 'gcp', 'terraform', 'cloudformation', 'docker',
    'kubernetes', 'serverless', 'lambda', 'ec2', 's3', 'vpc', 'iam',
    'networking', 'security', 'monitoring', 'cloudwatch', 'cost optimization',
    'infrastructure as code', 'iac', 'ansible', 'python', 'bash', 'linux',
    'load balancing', 'auto-scaling', 'database', 'rds', 'dynamodb',
    'cdn', 'cloudfront', 'microservices', 'ci/cd', 'devops'
  ],
  'Cyber Security': [
    'penetration testing', 'vulnerability assessment', 'siem', 'firewall',
    'ids', 'ips', 'encryption', 'ssl/tls', 'oauth', 'owasp', 'nist',
    'iso 27001', 'risk assessment', 'incident response', 'forensics',
    'malware analysis', 'network security', 'python', 'bash', 'linux',
    'wireshark', 'burp suite', 'metasploit', 'nmap', 'compliance',
    'gdpr', 'soc', 'threat modeling', 'zero trust', 'iam',
    'cloud security', 'devsecops', 'security audit'
  ],
  'Data Engineer': [
    'python', 'sql', 'spark', 'hadoop', 'airflow', 'kafka', 'etl',
    'data pipeline', 'data warehouse', 'snowflake', 'redshift', 'bigquery',
    'aws', 'gcp', 'azure', 'docker', 'kubernetes', 'data modeling',
    'dbt', 'data lake', 'data governance', 'streaming', 'batch processing',
    'postgresql', 'mongodb', 'data quality', 'schema design', 'ci/cd',
    'terraform', 'git', 'java', 'scala', 'linux'
  ],
  'Product Manager': [
    'product strategy', 'roadmap', 'agile', 'scrum', 'user research',
    'data analysis', 'a/b testing', 'stakeholder management', 'jira',
    'confluence', 'user stories', 'sprint planning', 'kpi', 'okr',
    'market analysis', 'competitive analysis', 'customer development',
    'product lifecycle', 'mvp', 'go-to-market', 'prioritization',
    'cross-functional', 'leadership', 'communication', 'sql',
    'analytics', 'figma', 'wireframing', 'prototyping'
  ],
  'Mobile Developer': [
    'react native', 'flutter', 'swift', 'kotlin', 'ios', 'android',
    'dart', 'objective-c', 'java', 'xcode', 'android studio', 'firebase',
    'rest api', 'graphql', 'push notifications', 'app store', 'google play',
    'ci/cd', 'testing', 'ui/ux', 'state management', 'redux', 'bloc',
    'sqlite', 'realm', 'performance optimization', 'responsive design',
    'git', 'agile', 'typescript', 'javascript'
  ]
})

// All available roles for the target role selector
export const AVAILABLE_ROLES = Object.keys(ROLE_KEYWORDS)

// Get keywords for a role (case-insensitive match)
export const getKeywordsForRole = (role) => {
  if (!role) return []
  const normalized = role.trim()
  // Exact match first
  if (ROLE_KEYWORDS[normalized]) return ROLE_KEYWORDS[normalized]
  // Case-insensitive match
  const key = Object.keys(ROLE_KEYWORDS).find(
    k => k.toLowerCase() === normalized.toLowerCase()
  )
  return key ? ROLE_KEYWORDS[key] : []
}
