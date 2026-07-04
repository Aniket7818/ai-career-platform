<div align="center">
  <h1>🚀 CareerAI Platform</h1>
  <p><strong>A production-grade, AI-powered SaaS platform for accelerating tech careers.</strong></p>

  [![Rails](https://img.shields.io/badge/Rails-7.1-CC0000?style=for-the-badge&logo=ruby-on-rails&logoColor=white)](https://rubyonrails.org/)
  [![Vue.js](https://img.shields.io/badge/Vue.js-3.5-4FC08D?style=for-the-badge&logo=vue.js&logoColor=white)](https://vuejs.org/)
  [![PostgreSQL](https://img.shields.io/badge/PostgreSQL-15-4169E1?style=for-the-badge&logo=postgresql&logoColor=white)](https://www.postgresql.org/)
  [![TailwindCSS](https://img.shields.io/badge/TailwindCSS-3.4-38B2AC?style=for-the-badge&logo=tailwind-css&logoColor=white)](https://tailwindcss.com/)
  [![License](https://img.shields.io/badge/License-MIT-blue.svg?style=for-the-badge)](LICENSE)
</div>

<hr/>

## 📖 Overview

CareerAI is a comprehensive SaaS application designed to empower professionals in their job search and career development. It bridges the gap between traditional career tools and modern AI capabilities, providing users with a premium, responsive, and secure experience. 

Currently in production, the platform boasts a robust foundational architecture with features like session-based authentication, a multi-resume builder with live previews, an interactive interview preparation module, and a comprehensive billing/subscription system powered by Razorpay. 

The future roadmap is heavily focused on integrating generative AI to automate resume optimization, tailor cover letters, and conduct realistic mock interviews.

---

## ✨ Features

### 🔐 Authentication
A hardened authentication flow designed for production SaaS environments.
- **Login / Signup** with robust input validation.
- **Forgot & Reset Password** flow with secure, time-limited tokens.
- **Email Verification** required for full platform access.
- **Session Authentication** utilizing HttpOnly, Secure, and SameSite cookies to mitigate XSS.
- **Cloudflare Turnstile** integrated into all auth endpoints to prevent bot abuse.
- **Rack::Attack** rate-limiting configured at the backend layer.
- **Protected Routes** strictly enforced on both frontend (Vue Router) and backend (Rails constraints).

### 📄 Resume Builder
A fully-featured editor for crafting professional resumes.
- **Resume CRUD:** Create, read, update, and delete multiple distinct resumes.
- **Live Preview:** See changes in real-time as you type.
- **Resume Health & Intelligence:** Preliminary static analysis of resume quality and content.
- **Multiple Templates:** Choose from various professional designs.
- **Export to PDF:** High-quality PDF generation using `jspdf`.

### 🎯 Interview Preparation
A dedicated module to sharpen interview skills.
- **Subject-Based Questions:** Browse questions categorized by technical subjects.
- **Interactive Q&A:** View questions, reveal answers, and track progress.
- **History & Bookmarks:** Save important questions and review completed ones.
- **Filtered Lists:** Easily navigate between Bookmarks, Completed, and History views.

### 📊 Dashboard
The central hub for user activity and metrics.
- **Statistics Widgets:** View quick metrics like resume count and completed interview questions.
- **Quick Actions:** Rapid navigation to core platform features.
- **Recent Activity:** Summary of the user's latest interactions.

### 🛡️ Admin Panel
Secure administrative tools for platform management.
- **User Management:** View, promote, suspend, or delete users.
- **Platform Settings:** Configure global platform parameters dynamically.
- **Data Export:** Export user and platform data for analytics.
- **Role-Based Access Control:** Strictly limited to `admin` and `super_admin` roles.

### ⚙️ Settings
Comprehensive account and subscription management.
- **Profile Configuration:** Update personal details and password.
- **Billing & Subscription:** View current plan, billing history, and download invoices/receipts.
- **Developer Mode:** Toggle test pricing and experimental features for internal testing.
- **AI Credits Tracking:** Monitor remaining AI usage limits with visual progress bars.

### 📱 Responsive Design
A premium UI built with Tailwind CSS, ensuring pixel-perfect layouts across all devices.
- **Desktop & Laptop:** Expansive layouts with sidebars and complex grid structures.
- **Tablet (Portrait/Landscape):** Adaptive layouts ensuring usability without horizontal scrolling.
- **Mobile:** Mobile-first approach featuring sticky bottom navigation, horizontal swipe carousels, and optimized touch targets.

### 💳 Payments
Production-ready billing infrastructure.
- **Razorpay Integration:** Secure processing for SaaS subscriptions.
- **Developer Mode:** Seamlessly switch between test and production pricing tiers within the UI.
- **Idempotent Billing:** Backend safeguards to prevent double-charging and manage AI credit resets.
- **Invoice Generation:** Users can download comprehensive PDF invoices and receipts.

---

## 🛠️ Tech Stack

### Backend
| Technology | Description |
|---|---|
| **Ruby on Rails 7** | Core backend framework (API Mode) |
| **PostgreSQL** | Primary relational database |
| **Redis** | In-memory store for sessions & rate-limiting |
| **Devise** | Custom-tailored authentication logic |
| **Rack::Attack** | Throttling and anti-abuse middleware |
| **Razorpay SDK** | Payment processing integration |

### Frontend
| Technology | Description |
|---|---|
| **Vue.js 3** | Composition API-based frontend framework |
| **Vite** | Lightning-fast build tool and dev server |
| **Vue Router 4** | Client-side routing with navigation guards |
| **Vuex 4** | Centralized state management |
| **Tailwind CSS** | Utility-first CSS framework for styling |
| **Axios** | Promise-based HTTP client for API requests |
| **jsPDF** | Client-side PDF generation |

---

## 🏗️ Architecture & Folder Structure

The repository is organized as a monorepo, separating the Rails API backend and the Vue SPA frontend.

### Complete Tree
```text
.
├── app/                  # Rails Backend Source
│   ├── controllers/      # API endpoints (api/v1/...)
│   ├── models/           # ActiveRecord models (User, Resume, etc.)
│   ├── services/         # Business logic (PricingService, Resend email, etc.)
│   └── views/            # Email templates
├── config/               # Rails configuration (routes, initializers, environments)
├── db/                   # Database schema and migrations
├── frontend/             # Vue Frontend SPA
│   ├── src/
│   │   ├── components/   # Reusable UI components (Buttons, Inputs, Cards)
│   │   ├── modules/      # Feature-based pages (Auth, Dashboard, Resumes, Settings)
│   │   ├── router/       # Vue Router configuration
│   │   ├── services/     # API integration logic
│   │   └── store/        # Vuex state modules (auth, resumes, etc.)
│   ├── package.json      # Frontend dependencies
│   └── vite.config.js    # Vite build configuration
├── .env.example          # Environment variable template
└── README.md             # Project documentation
```

---

## 🚀 Installation

Follow these steps to set up the project locally for development.

### 1. Clone the repository
```bash
git clone https://github.com/Aniket7818/ai-career-platform.git
cd ai-career-platform
```

### 2. Backend Setup (Rails)
Ensure you have Ruby (check `.ruby-version`) and PostgreSQL installed.
```bash
bundle install
rails db:create
rails db:migrate
rails db:seed
```

### 3. Frontend Setup (Vue/Vite)
Ensure you have Node.js installed.
```bash
cd frontend
npm install
cd ..
```

### 4. Environment Variables
Copy the example environment file and fill in your local values.
```bash
cp .env.example .env
```

### 5. Run Locally
Start the Rails API server:
```bash
rails s -p 3000
```
In a new terminal window, start the Vite development server:
```bash
cd frontend
npm run dev
```
Visit `http://localhost:5173` in your browser.

---

## 🔑 Environment Variables

The application requires specific environment variables to function correctly. **Never commit secrets to version control.**

* `RAILS_ENV`
* `FRONTEND_URL`
* `CORS_ORIGINS`
* `REDIS_URL`
* `RESEND_API_KEY`
* `MAIL_FROM`
* `TURNSTILE_SITE_KEY`
* `TURNSTILE_SECRET_KEY`
* `POSTGRES_DB` / `POSTGRES_TEST_DB` / `POSTGRES_USER` / `POSTGRES_PASSWORD` / `POSTGRES_HOST` / `POSTGRES_PORT`
* `RAZORPAY_KEY_ID`
* `RAZORPAY_KEY_SECRET`
* `COOKIE_SAME_SITE` / `COOKIE_SECURE`
* `VITE_API_URL`
* `VITE_TURNSTILE_SITE_KEY`

---

## 📸 Screenshots

*(Placeholders - replace with actual screenshots in `/docs/screenshots/`)*

<details>
<summary><b>View Screenshots</b></summary>
<br>

- **Dashboard:** `![Dashboard](/docs/screenshots/dashboard.png)`
- **Resume Builder:** `![Resume Builder](/docs/screenshots/resume-builder.png)`
- **Interview Prep:** `![Interview Prep](/docs/screenshots/interview.png)`
- **Settings & Billing:** `![Settings](/docs/screenshots/settings.png)`
- **Admin Panel:** `![Admin Panel](/docs/screenshots/admin.png)`

</details>

---

## 🌐 API Overview

The backend exposes a strictly versioned REST API (`/api/v1/`).

- **Architecture:** RESTful design principles.
- **Format:** Exclusively JSON responses (`application/json`).
- **Authentication:** Cookie-based session tracking. Requests to protected endpoints must include the session cookie (managed automatically by Axios with `withCredentials: true`).
- **CSRF Protection:** Standard Rails CSRF protection is enforced for state-changing requests.

---

## 🔄 Development Workflow

- **Branching Strategy:** Feature branches derived from `main`.
- **AI Branch:** Experimental AI features are developed in isolated branches before merging.
- **Pull Requests:** All code must pass through PR reviews before merging into `main`.
- **Production Workflow:** The `main` branch represents the stable production state. Deployments (e.g., via Kamal, Render, or Heroku) are triggered from `main`.

---

## ⚡ Performance

- **Lazy Loading:** Vue Router is configured with dynamic imports (`() => import('...')`) to split code and lazily load modules (e.g., Interview Prep filters, Verify Email page).
- **Optimizations:** Vite handles aggressive minification and asset bundling.
- **Responsive:** CSS is heavily optimized using Tailwind's utility classes, preventing CSS bloat.

---

## 🛡️ Security Implementations

- **Cloudflare Turnstile:** Bot protection on all public forms (login, signup, forgot password).
- **Rack::Attack:** Strict rate limiting on auth endpoints (e.g., max 5 login attempts per minute per IP).
- **Session Cookies:** `HttpOnly`, `Secure`, and `SameSite` attributes configured based on environment.
- **CSRF Protection:** ActionController::RequestForgeryProtection enabled.
- **Input Validation:** Strong parameters in Rails and client-side validation in Vue.

---

## 🗺️ Roadmap

### Completed Features
- [x] Secure Authentication System
- [x] Responsive Dashboard UI
- [x] Resume Builder & Live Preview
- [x] PDF Export
- [x] Interview Preparation Module
- [x] Razorpay Integration & Billing
- [x] Admin Management Panel
- [x] Cloudflare Turnstile & Rate Limiting

### AI Roadmap (Upcoming)
- [ ] **Resume Rewrite:** AI-driven suggestions to improve resume impact.
- [ ] **Cover Letter Generation:** Tailored cover letters based on the user's resume and job description.
- [ ] **ATS Scoring:** Analyze resume compatibility with Applicant Tracking Systems.
- [ ] **Interview AI:** Conduct live voice/text mock interviews with an AI recruiter.
- [ ] **Career Roadmap:** AI-generated learning paths based on career goals.

---

## 🤝 Contributing

Contributions are welcome! Please read the `CONTRIBUTING.md` (if available) or follow these steps:
1. Fork the repository.
2. Create a new branch (`git checkout -b feature/amazing-feature`).
3. Commit your changes (`git commit -m 'Add some amazing feature'`).
4. Push to the branch (`git push origin feature/amazing-feature`).
5. Open a Pull Request.

---

## 👨‍💻 Maintainer

**Aniket Yadav**  
*Full Stack Developer*

- [GitHub](https://github.com/Aniket7818)
- [LinkedIn](#) *(Add link here)*

<hr/>
<div align="center">
  <sub>Built with ❤️ and AI</sub>
</div>
