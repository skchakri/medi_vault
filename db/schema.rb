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

ActiveRecord::Schema[8.0].define(version: 2025_01_11_000009) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "alerts", force: :cascade do |t|
    t.bigint "credential_id", null: false
    t.integer "offset_days", null: false
    t.date "alert_date", null: false
    t.integer "status", default: 0, null: false
    t.datetime "sent_at"
    t.text "message"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["alert_date"], name: "index_alerts_on_alert_date"
    t.index ["credential_id", "offset_days"], name: "index_alerts_on_credential_id_and_offset_days", unique: true
    t.index ["credential_id"], name: "index_alerts_on_credential_id"
    t.index ["status"], name: "index_alerts_on_status"
  end

  create_table "api_settings", force: :cascade do |t|
    t.string "key", null: false
    t.string "value"
    t.string "encrypted_value"
    t.string "encrypted_value_iv"
    t.boolean "enabled", default: true
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["enabled"], name: "index_api_settings_on_enabled"
    t.index ["key"], name: "index_api_settings_on_key", unique: true
  end

  create_table "credentials", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "title", null: false
    t.date "start_date"
    t.date "end_date"
    t.integer "status", default: 0, null: false
    t.string "source_filename"
    t.jsonb "ai_extracted_json", default: {}
    t.boolean "ai_processed", default: false
    t.datetime "ai_processed_at"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["ai_processed"], name: "index_credentials_on_ai_processed"
    t.index ["end_date"], name: "index_credentials_on_end_date"
    t.index ["status"], name: "index_credentials_on_status"
    t.index ["user_id", "end_date"], name: "index_credentials_on_user_id_and_end_date"
    t.index ["user_id"], name: "index_credentials_on_user_id"
  end

  create_table "llm_requests", force: :cascade do |t|
    t.bigint "user_id"
    t.integer "account_id"
    t.integer "provider", null: false
    t.string "model"
    t.integer "prompt_tokens"
    t.integer "completion_tokens"
    t.integer "total_tokens"
    t.integer "cost_cents"
    t.boolean "success", default: false
    t.text "error_text"
    t.text "request_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_at"], name: "index_llm_requests_on_created_at"
    t.index ["provider"], name: "index_llm_requests_on_provider"
    t.index ["success"], name: "index_llm_requests_on_success"
    t.index ["user_id", "created_at"], name: "index_llm_requests_on_user_id_and_created_at"
    t.index ["user_id"], name: "index_llm_requests_on_user_id"
  end

  create_table "notifications", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "credential_id"
    t.integer "channel", null: false
    t.integer "alert_offset_days"
    t.datetime "sent_at"
    t.integer "status", default: 0, null: false
    t.text "error_text"
    t.text "content"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["channel"], name: "index_notifications_on_channel"
    t.index ["credential_id"], name: "index_notifications_on_credential_id"
    t.index ["sent_at"], name: "index_notifications_on_sent_at"
    t.index ["status"], name: "index_notifications_on_status"
    t.index ["user_id", "status"], name: "index_notifications_on_user_id_and_status"
    t.index ["user_id"], name: "index_notifications_on_user_id"
  end

  create_table "share_links", force: :cascade do |t|
    t.bigint "credential_id", null: false
    t.string "token", null: false
    t.datetime "expires_at", null: false
    t.datetime "used_at"
    t.boolean "one_time", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["credential_id"], name: "index_share_links_on_credential_id"
    t.index ["expires_at"], name: "index_share_links_on_expires_at"
    t.index ["token"], name: "index_share_links_on_token", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.integer "failed_attempts", default: 0, null: false
    t.string "unlock_token"
    t.datetime "locked_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.string "npi"
    t.datetime "npi_verified_at"
    t.string "phone"
    t.boolean "phone_verified", default: false
    t.integer "role", default: 0, null: false
    t.integer "plan", default: 0, null: false
    t.boolean "plan_active", default: false
    t.boolean "notification_email", default: true
    t.boolean "notification_sms", default: false
    t.integer "credentials_count", default: 0, null: false
    t.datetime "trial_ends_at"
    t.datetime "subscription_ends_at"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["npi"], name: "index_users_on_npi"
    t.index ["plan"], name: "index_users_on_plan"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["role"], name: "index_users_on_role"
    t.index ["unlock_token"], name: "index_users_on_unlock_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "alerts", "credentials"
  add_foreign_key "credentials", "users"
  add_foreign_key "llm_requests", "users"
  add_foreign_key "notifications", "credentials"
  add_foreign_key "notifications", "users"
  add_foreign_key "share_links", "credentials"
end
