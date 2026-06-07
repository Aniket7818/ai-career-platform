export const contactItems = (personal = {}) => [
  { label: 'Email', value: personal.email },
  { label: 'Phone', value: personal.phone },
  { label: 'Location', value: personal.location },
  { label: 'LinkedIn', value: personal.linkedin },
  { label: 'GitHub', value: personal.github },
  { label: 'Portfolio', value: personal.portfolio }
].filter((item) => item.value?.trim?.())

export const contactLine = (personal = {}) => contactItems(personal).map((item) => item.value).join('  ·  ')
