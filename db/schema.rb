# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.2].define(version: 2026_07_10_223500) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "admin_settings", force: :cascade do |t|
    t.string "key", null: false
    t.jsonb "value", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_admin_settings_on_key", unique: true
  end

  create_table "ai_logs", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "resume_id", null: false
    t.string "feature"
    t.string "prompt_version"
    t.string "fingerprint"
    t.integer "credits_used"
    t.integer "tokens_in"
    t.integer "tokens_out"
    t.decimal "estimated_cost", precision: 10, scale: 6
    t.string "model"
    t.integer "response_time"
    t.string "status"
    t.text "error_message"
    t.text "request_prompt"
    t.text "response_content"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "cache_hit"
    t.integer "retry_count"
    t.string "failure_reason"
    t.string "ip_address"
    t.string "user_agent"
    t.string "request_id"
    t.string "provider"
    t.jsonb "raw_request_json"
    t.jsonb "raw_response_json"
    t.jsonb "performance_events"
    t.jsonb "provider_headers"
    t.string "provider_request_id"
    t.string "finish_reason"
    t.integer "http_status"
    t.index ["resume_id"], name: "index_ai_logs_on_resume_id"
    t.index ["user_id"], name: "index_ai_logs_on_user_id"
  end

  create_table "ai_optimization_requests", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "resume_id", null: false
    t.string "action"
    t.string "status"
    t.jsonb "result"
    t.text "error_message"
    t.jsonb "payload"
    t.jsonb "request_meta"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["resume_id"], name: "index_ai_optimization_requests_on_resume_id"
    t.index ["user_id"], name: "index_ai_optimization_requests_on_user_id"
  end

  create_table "audit_logs", force: :cascade do |t|
    t.bigint "actor_id"
    t.bigint "user_id"
    t.string "action", null: false
    t.text "details"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["action"], name: "index_audit_logs_on_action"
    t.index ["actor_id"], name: "index_audit_logs_on_actor_id"
    t.index ["created_at"], name: "index_audit_logs_on_created_at"
    t.index ["user_id"], name: "index_audit_logs_on_user_id"
  end

  create_table "billing_histories", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "plan_name"
    t.decimal "amount"
    t.string "currency"
    t.string "payment_provider"
    t.string "payment_id"
    t.string "order_id"
    t.string "invoice_number"
    t.string "billing_cycle"
    t.string "payment_status"
    t.datetime "paid_at"
    t.datetime "renewal_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "invoice_pdf_path"
    t.string "receipt_pdf_path"
    t.index ["user_id"], name: "index_billing_histories_on_user_id"
  end

  create_table "bookmarks", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "question_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["question_id"], name: "index_bookmarks_on_question_id"
    t.index ["user_id"], name: "index_bookmarks_on_user_id"
  end

  create_table "credit_transactions", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "feature_name"
    t.integer "credits_used"
    t.integer "balance_before"
    t.integer "balance_after"
    t.string "action"
    t.string "reference_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_credit_transactions_on_user_id"
  end

  create_table "email_verification_logs", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.datetime "sent_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_email_verification_logs_on_user_id"
  end

  create_table "feature_interests", force: :cascade do |t|
    t.string "feature_key", null: false
    t.bigint "user_id"
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email", "feature_key"], name: "index_feature_interests_on_email_and_feature_key", unique: true, where: "(email IS NOT NULL)"
    t.index ["feature_key"], name: "index_feature_interests_on_feature_key"
    t.index ["user_id", "feature_key"], name: "index_feature_interests_on_user_id_and_feature_key", unique: true, where: "(user_id IS NOT NULL)"
    t.index ["user_id"], name: "index_feature_interests_on_user_id"
  end

  create_table "login_sessions", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "ip_address"
    t.string "user_agent"
    t.string "session_id"
    t.datetime "logged_in_at", null: false
    t.datetime "logged_out_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["ip_address"], name: "index_login_sessions_on_ip_address"
    t.index ["logged_in_at"], name: "index_login_sessions_on_logged_in_at"
    t.index ["user_id"], name: "index_login_sessions_on_user_id"
  end

  create_table "payment_orders", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "plan", null: false
    t.integer "amount_paise", null: false
    t.string "currency", default: "INR", null: false
    t.string "status", default: "created", null: false
    t.string "razorpay_order_id"
    t.string "razorpay_payment_id"
    t.string "razorpay_signature"
    t.jsonb "metadata", default: {}, null: false
    t.datetime "activated_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["razorpay_order_id"], name: "index_payment_orders_on_razorpay_order_id", unique: true
    t.index ["status"], name: "index_payment_orders_on_status"
    t.index ["user_id"], name: "index_payment_orders_on_user_id"
  end

  create_table "question_notes", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "question_id", null: false
    t.text "content"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["question_id"], name: "index_question_notes_on_question_id"
    t.index ["user_id"], name: "index_question_notes_on_user_id"
  end

  create_table "questions", force: :cascade do |t|
    t.string "title"
    t.string "slug"
    t.text "content"
    t.text "answer"
    t.integer "difficulty", default: 0
    t.integer "question_type", default: 0
    t.bigint "subject_id", null: false
    t.bigint "topic_id", null: false
    t.string "tags", default: [], array: true
    t.integer "estimated_reading_time", default: 5
    t.boolean "is_premium", default: false
    t.boolean "is_active", default: true
    t.integer "view_count", default: 0
    t.integer "bookmark_count", default: 0
    t.integer "created_by_id"
    t.integer "updated_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "explanation"
    t.jsonb "code_examples"
    t.jsonb "key_takeaways"
    t.jsonb "follow_up_questions"
    t.index ["slug"], name: "index_questions_on_slug", unique: true
    t.index ["subject_id"], name: "index_questions_on_subject_id"
    t.index ["topic_id"], name: "index_questions_on_topic_id"
  end

  create_table "quiz_answers", force: :cascade do |t|
    t.bigint "quiz_attempt_id", null: false
    t.bigint "quiz_question_id", null: false
    t.text "selected_answer"
    t.boolean "is_correct"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["quiz_attempt_id"], name: "index_quiz_answers_on_quiz_attempt_id"
    t.index ["quiz_question_id"], name: "index_quiz_answers_on_quiz_question_id"
  end

  create_table "quiz_attempts", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "quiz_id", null: false
    t.integer "score"
    t.integer "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["quiz_id"], name: "index_quiz_attempts_on_quiz_id"
    t.index ["user_id"], name: "index_quiz_attempts_on_user_id"
  end

  create_table "quiz_questions", force: :cascade do |t|
    t.bigint "quiz_id", null: false
    t.bigint "question_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["question_id"], name: "index_quiz_questions_on_question_id"
    t.index ["quiz_id"], name: "index_quiz_questions_on_quiz_id"
  end

  create_table "quizzes", force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.integer "difficulty"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "resume_versions", force: :cascade do |t|
    t.bigint "resume_id", null: false
    t.bigint "user_id", null: false
    t.integer "version_number", default: 1, null: false
    t.string "label", default: "Original", null: false
    t.jsonb "content_snapshot", default: {}, null: false
    t.text "change_summary"
    t.boolean "is_current", default: false, null: false
    t.string "source", default: "manual", null: false
    t.integer "score_at_creation"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["resume_id", "created_at"], name: "index_resume_versions_on_resume_id_and_created_at"
    t.index ["resume_id", "is_current"], name: "index_resume_versions_on_resume_id_and_is_current"
    t.index ["resume_id", "version_number"], name: "index_resume_versions_on_resume_id_and_version_number", unique: true
    t.index ["resume_id"], name: "index_resume_versions_on_resume_id"
    t.index ["source"], name: "index_resume_versions_on_source"
    t.index ["user_id"], name: "index_resume_versions_on_user_id"
  end

  create_table "resumes", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "title", null: false
    t.string "status", default: "draft", null: false
    t.jsonb "content", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "template_id", default: "modern", null: false
    t.datetime "downloaded_at"
    t.integer "download_count", default: 0, null: false
    t.string "target_role"
    t.integer "last_analysis_score"
    t.datetime "last_analyzed_at"
    t.integer "ats_score"
    t.integer "keyword_score"
    t.integer "content_score"
    t.integer "completeness_score"
    t.integer "analysis_version"
    t.jsonb "analysis_data", default: {}
    t.index ["status"], name: "index_resumes_on_status"
    t.index ["user_id", "updated_at"], name: "index_resumes_on_user_id_and_updated_at"
    t.index ["user_id"], name: "index_resumes_on_user_id"
  end

  create_table "study_plan_items", force: :cascade do |t|
    t.bigint "study_plan_id", null: false
    t.bigint "subject_id", null: false
    t.bigint "topic_id", null: false
    t.integer "day_number"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["study_plan_id"], name: "index_study_plan_items_on_study_plan_id"
    t.index ["subject_id"], name: "index_study_plan_items_on_subject_id"
    t.index ["topic_id"], name: "index_study_plan_items_on_topic_id"
  end

  create_table "study_plans", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "subjects", force: :cascade do |t|
    t.string "name"
    t.string "slug"
    t.text "description"
    t.string "icon"
    t.integer "display_order"
    t.boolean "is_active"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["slug"], name: "index_subjects_on_slug", unique: true
  end

  create_table "topics", force: :cascade do |t|
    t.bigint "subject_id", null: false
    t.string "name"
    t.string "slug"
    t.text "description"
    t.integer "display_order"
    t.boolean "is_active"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["slug"], name: "index_topics_on_slug", unique: true
    t.index ["subject_id"], name: "index_topics_on_subject_id"
  end

  create_table "user_question_progresses", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "question_id", null: false
    t.integer "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["question_id"], name: "index_user_question_progresses_on_question_id"
    t.index ["user_id"], name: "index_user_question_progresses_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "first_name", default: "", null: false
    t.string "last_name"
    t.string "title"
    t.string "location"
    t.string "phone"
    t.string "website"
    t.string "linkedin"
    t.string "github"
    t.text "bio"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "username"
    t.text "avatar"
    t.text "cover_image"
    t.string "role", default: "user", null: false
    t.string "status", default: "active", null: false
    t.string "subscription_plan", default: "free", null: false
    t.datetime "last_login_at"
    t.datetime "verified_at"
    t.datetime "subscription_started_at"
    t.datetime "subscription_expires_at"
    t.string "razorpay_customer_id"
    t.string "razorpay_subscription_id"
    t.integer "resume_downloads_count", default: 0, null: false
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.integer "reset_emails_sent_count", default: 0
    t.datetime "last_reset_request_at"
    t.integer "password_reset_strikes", default: 0
    t.integer "monthly_credit_limit"
    t.integer "remaining_credits"
    t.integer "used_credits"
    t.datetime "credit_reset_date"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["razorpay_subscription_id"], name: "index_users_on_razorpay_subscription_id"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["role"], name: "index_users_on_role"
    t.index ["status"], name: "index_users_on_status"
    t.index ["subscription_expires_at"], name: "index_users_on_subscription_expires_at"
    t.index ["subscription_plan"], name: "index_users_on_subscription_plan"
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  add_foreign_key "ai_logs", "resumes", on_delete: :cascade
  add_foreign_key "ai_logs", "users"
  add_foreign_key "ai_optimization_requests", "resumes"
  add_foreign_key "ai_optimization_requests", "users"
  add_foreign_key "audit_logs", "users"
  add_foreign_key "audit_logs", "users", column: "actor_id"
  add_foreign_key "billing_histories", "users"
  add_foreign_key "bookmarks", "questions"
  add_foreign_key "bookmarks", "users"
  add_foreign_key "credit_transactions", "users"
  add_foreign_key "email_verification_logs", "users"
  add_foreign_key "feature_interests", "users"
  add_foreign_key "login_sessions", "users"
  add_foreign_key "payment_orders", "users"
  add_foreign_key "question_notes", "questions"
  add_foreign_key "question_notes", "users"
  add_foreign_key "questions", "subjects"
  add_foreign_key "questions", "topics"
  add_foreign_key "quiz_answers", "quiz_attempts"
  add_foreign_key "quiz_answers", "quiz_questions"
  add_foreign_key "quiz_attempts", "quizzes"
  add_foreign_key "quiz_attempts", "users"
  add_foreign_key "quiz_questions", "questions"
  add_foreign_key "quiz_questions", "quizzes"
  add_foreign_key "resume_versions", "resumes"
  add_foreign_key "resume_versions", "users"
  add_foreign_key "resumes", "users"
  add_foreign_key "study_plan_items", "study_plans"
  add_foreign_key "study_plan_items", "subjects"
  add_foreign_key "study_plan_items", "topics"
  add_foreign_key "topics", "subjects"
  add_foreign_key "user_question_progresses", "questions"
  add_foreign_key "user_question_progresses", "users"
end
