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

ActiveRecord::Schema[7.2].define(version: 2026_06_13_185920) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "admin_settings", force: :cascade do |t|
    t.string "key", null: false
    t.jsonb "value", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_admin_settings_on_key", unique: true
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
    t.index ["status"], name: "index_resumes_on_status"
    t.index ["user_id", "updated_at"], name: "index_resumes_on_user_id_and_updated_at"
    t.index ["user_id"], name: "index_resumes_on_user_id"
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

  add_foreign_key "audit_logs", "users"
  add_foreign_key "audit_logs", "users", column: "actor_id"
  add_foreign_key "email_verification_logs", "users"
  add_foreign_key "feature_interests", "users"
  add_foreign_key "login_sessions", "users"
  add_foreign_key "payment_orders", "users"
  add_foreign_key "resumes", "users"
end
