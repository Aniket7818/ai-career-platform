# CareerAI Platform

Production-oriented foundation for an AI Career Platform. The current scope intentionally covers authentication, dashboard, resume CRUD, and resume builder/preview only.

## Stack

- Backend: Ruby on Rails API, PostgreSQL, Devise, session-cookie authentication, REST APIs.
- Frontend: Vue 3, Vue Router, Vuex, Tailwind CSS, Axios.

## Structure

- `app/controllers/api/v1`: versioned REST API controllers.
- `app/controllers/api/v1/auth`: Devise JSON controllers for signup, login, logout, and forgot password.
- `app/constants`: backend enum-style constants.
- `app/serializers`: API response serializers.
- `frontend/src/constants`: frontend enum-style constants.
- `frontend/src/locales`: UI translation keys.
- `frontend/src/services`: Axios API request services.
- `frontend/src/components`: reusable layout and UI components.
- `frontend/src/modules`: scalable feature modules.

## Run Locally

```bash
bundle install
bin/rails db:create db:migrate
bin/rails server
```

```bash
cd frontend
npm install
npm run dev
```

Rails runs on `http://localhost:3000`; Vue runs on `http://localhost:5173`.

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...
