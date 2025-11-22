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

ActiveRecord::Schema[8.0].define(version: 2025_11_19_065719) do
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

  create_table "ai_embeddings", force: :cascade do |t|
    t.string "provider", null: false
    t.string "model", null: false
    t.jsonb "vector", default: [], null: false
    t.integer "dim", null: false
    t.string "source_type"
    t.bigint "source_id"
    t.string "chunk_id"
    t.jsonb "metadata", default: {}, null: false
    t.integer "cost_cents", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["model"], name: "index_ai_embeddings_on_model"
    t.index ["provider"], name: "index_ai_embeddings_on_provider"
    t.index ["source_type", "source_id"], name: "index_ai_embeddings_on_source_type_and_source_id"
  end

  create_table "ai_models", force: :cascade do |t|
    t.string "name", null: false
    t.string "provider", null: false
    t.string "model_identifier", null: false
    t.boolean "is_default", default: false, null: false
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_ai_models_on_active"
    t.index ["is_default"], name: "index_ai_models_on_is_default"
  end

  create_table "alert_types", force: :cascade do |t|
    t.string "name", null: false
    t.integer "offset_days", null: false
    t.text "description"
    t.boolean "active", default: true, null: false
    t.jsonb "notification_channels", default: ["email"], null: false
    t.integer "priority", default: 0, null: false
    t.jsonb "user_plans", default: ["free", "basic", "pro"], null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_alert_types_on_active"
    t.index ["name"], name: "index_alert_types_on_name", unique: true
    t.index ["priority"], name: "index_alert_types_on_priority"
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
    t.bigint "alert_type_id"
    t.index ["alert_date"], name: "index_alerts_on_alert_date"
    t.index ["alert_type_id", "credential_id"], name: "index_alerts_on_alert_type_id_and_credential_id"
    t.index ["alert_type_id"], name: "index_alerts_on_alert_type_id"
    t.index ["credential_id", "offset_days", "alert_type_id"], name: "index_alerts_on_credential_offset_and_type", unique: true
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

  create_table "credential_tags", force: :cascade do |t|
    t.bigint "credential_id", null: false
    t.bigint "tag_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["credential_id", "tag_id"], name: "index_credential_tags_on_credential_id_and_tag_id", unique: true
    t.index ["credential_id"], name: "index_credential_tags_on_credential_id"
    t.index ["tag_id"], name: "index_credential_tags_on_tag_id"
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
    t.integer "tags_count", default: 0
    t.index ["ai_processed"], name: "index_credentials_on_ai_processed"
    t.index ["end_date"], name: "index_credentials_on_end_date"
    t.index ["status"], name: "index_credentials_on_status"
    t.index ["user_id", "end_date"], name: "index_credentials_on_user_id_and_end_date"
    t.index ["user_id"], name: "index_credentials_on_user_id"
  end

  create_table "email_templates", force: :cascade do |t|
    t.string "name", null: false
    t.string "template_type", null: false
    t.string "subject", null: false
    t.text "html_body", null: false
    t.text "text_body"
    t.json "variables", default: {}, null: false
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "sms_body"
    t.index ["name"], name: "index_email_templates_on_name", unique: true
    t.index ["template_type", "active"], name: "index_email_templates_on_template_type_and_active"
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

  create_table "message_usages", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.integer "message_type", null: false
    t.datetime "sent_at"
    t.integer "status", default: 0, null: false
    t.integer "cost_cents", default: 0
    t.string "provider"
    t.text "error_message"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["message_type", "sent_at"], name: "index_message_usages_on_message_type_and_sent_at"
    t.index ["status"], name: "index_message_usages_on_status"
    t.index ["user_id", "sent_at"], name: "index_message_usages_on_user_id_and_sent_at"
    t.index ["user_id"], name: "index_message_usages_on_user_id"
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

  create_table "payments", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "stripe_payment_intent_id"
    t.integer "amount_cents", null: false
    t.string "currency", default: "usd", null: false
    t.integer "status", default: 0, null: false
    t.text "description"
    t.datetime "paid_at"
    t.text "receipt_url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["status"], name: "index_payments_on_status"
    t.index ["stripe_payment_intent_id"], name: "index_payments_on_stripe_payment_intent_id", unique: true
    t.index ["user_id", "paid_at"], name: "index_payments_on_user_id_and_paid_at"
    t.index ["user_id"], name: "index_payments_on_user_id"
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

  create_table "short_urls", force: :cascade do |t|
    t.string "token", null: false
    t.text "original_url", null: false
    t.integer "click_count", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["token"], name: "index_short_urls_on_token", unique: true
  end

  create_table "support_messages", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.text "message"
    t.boolean "is_admin_response"
    t.integer "parent_id"
    t.datetime "read_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_support_messages_on_user_id"
  end

  create_table "tags", force: :cascade do |t|
    t.string "name", null: false
    t.string "color", default: "#6B7280"
    t.text "description"
    t.boolean "is_default", default: false
    t.boolean "active", default: true
    t.bigint "user_id"
    t.integer "usage_count", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index "lower((name)::text)", name: "index_tags_on_lower_name"
    t.index ["active"], name: "index_tags_on_active"
    t.index ["is_default"], name: "index_tags_on_is_default"
    t.index ["name"], name: "index_tags_on_name", unique: true
    t.index ["usage_count"], name: "index_tags_on_usage_count"
    t.index ["user_id"], name: "index_tags_on_user_id"
  end

  create_table "theme_settings", force: :cascade do |t|
    t.string "primary_color", default: "#7E22CE", null: false
    t.string "secondary_color", default: "#9333EA", null: false
    t.string "font_family", default: "system", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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
    t.string "provider"
    t.string "uid"
    t.string "oauth_token"
    t.datetime "oauth_expires_at"
    t.string "avatar_url"
    t.string "title"
    t.string "official_credentials"
    t.string "npi_enumeration_type"
    t.jsonb "mailing_address"
    t.jsonb "practice_address"
    t.jsonb "location_address"
    t.jsonb "npi_data"
    t.string "gender"
    t.string "name_prefix"
    t.string "name_suffix"
    t.string "middle_name"
    t.date "enumeration_date"
    t.date "last_updated"
    t.date "certification_date"
    t.string "npi_status"
    t.boolean "sole_proprietor"
    t.boolean "organizational_subpart"
    t.jsonb "taxonomies"
    t.jsonb "identifiers"
    t.integer "notification_preference", default: 0, null: false
    t.string "stripe_customer_id"
    t.string "payment_method_last4"
    t.string "payment_method_brand"
    t.date "payment_method_expires_at"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["npi"], name: "index_users_on_npi"
    t.index ["plan"], name: "index_users_on_plan"
    t.index ["provider", "uid"], name: "index_users_on_provider_and_uid", unique: true
    t.index ["provider"], name: "index_users_on_provider"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["role"], name: "index_users_on_role"
    t.index ["unlock_token"], name: "index_users_on_unlock_token", unique: true
  end

  create_table "workflows", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.jsonb "nodes", default: [], null: false
    t.jsonb "edges", default: [], null: false
    t.string "status", default: "draft", null: false
    t.bigint "created_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_by_id"], name: "index_workflows_on_created_by_id"
    t.index ["name"], name: "index_workflows_on_name"
    t.index ["status"], name: "index_workflows_on_status"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "alerts", "alert_types"
  add_foreign_key "alerts", "credentials"
  add_foreign_key "credential_tags", "credentials"
  add_foreign_key "credential_tags", "tags"
  add_foreign_key "credentials", "users"
  add_foreign_key "llm_requests", "users"
  add_foreign_key "message_usages", "users"
  add_foreign_key "notifications", "credentials"
  add_foreign_key "notifications", "users"
  add_foreign_key "payments", "users"
  add_foreign_key "share_links", "credentials"
  add_foreign_key "support_messages", "users"
  add_foreign_key "tags", "users"
  add_foreign_key "workflows", "users", column: "created_by_id"
end
