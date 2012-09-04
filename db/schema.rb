# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.


ActiveRecord::Schema.define(:version => 20120827214557) do

  create_table "comments", :force => true do |t|
    t.string   "subject"
    t.text     "content"
    t.integer  "author_id"
    t.integer  "commentable_id"
    t.string   "commentable_type"
    t.integer  "version_id"
    t.text     "quote"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  create_table "companies", :force => true do |t|
    t.string   "name"
    t.string   "role"
    t.integer  "primary_person_id"
    t.integer  "billing_person_id"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
    t.string   "highrise_id"
    t.string   "freshbooks_id"
    t.string   "billing_status"
    t.date     "expires_on"
    t.boolean  "active"
    t.float    "balance"
  end

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
  end

  add_index "delayed_jobs", ["priority", "run_at"], :name => "delayed_jobs_priority"

  create_table "documents", :force => true do |t|
    t.string   "title"
    t.text     "body"
    t.datetime "published_at"
    t.integer  "owner_id"
    t.string   "owner_type"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
    t.string   "format"
    t.integer  "author_id"
    t.boolean  "archived"
    t.string   "asin"
    t.boolean  "published"
    t.string   "viewing_token"
    t.string   "level"
  end

  create_table "groups", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "images", :force => true do |t|
    t.string   "image"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "impressions", :force => true do |t|
    t.string   "impressionable_type"
    t.integer  "impressionable_id"
    t.integer  "user_id"
    t.string   "controller_name"
    t.string   "action_name"
    t.string   "view_name"
    t.string   "request_hash"
    t.string   "ip_address"
    t.string   "session_hash"
    t.text     "message"
    t.text     "referrer"
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
  end

  add_index "impressions", ["controller_name", "action_name", "ip_address"], :name => "controlleraction_ip_index"
  add_index "impressions", ["controller_name", "action_name", "request_hash"], :name => "controlleraction_request_index"
  add_index "impressions", ["controller_name", "action_name", "session_hash"], :name => "controlleraction_session_index"
  add_index "impressions", ["impressionable_type", "impressionable_id", "ip_address"], :name => "poly_ip_index"
  add_index "impressions", ["impressionable_type", "impressionable_id", "request_hash"], :name => "poly_request_index"
  add_index "impressions", ["impressionable_type", "impressionable_id", "session_hash"], :name => "poly_session_index"
  add_index "impressions", ["user_id"], :name => "index_impressions_on_user_id"

  create_table "mercury_images", :force => true do |t|
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
  end

  create_table "messages", :force => true do |t|
    t.string   "subject"
    t.text     "content"
    t.integer  "author_id"
    t.datetime "published_at"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
    t.integer  "owner_id"
    t.string   "owner_type"
    t.boolean  "archived"
    t.integer  "counter_cache"
  end

  create_table "moderators", :force => true do |t|
    t.integer  "person_id"
    t.integer  "message_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "observers", :force => true do |t|
    t.integer  "person_id"
    t.integer  "message_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "pages", :force => true do |t|
    t.string   "title"
    t.text     "header"
    t.text     "body"
    t.integer  "owner_id"
    t.integer  "owner_type"
    t.integer  "author_id"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
    t.boolean  "published"
    t.datetime "published_at"
    t.string   "level"
    t.string   "viewing_token"
    t.boolean  "locked"
    t.integer  "locker_id"
    t.datetime "locked_at"
    t.string   "tag_list"
    t.boolean  "commenting_enabled"
  end

  create_table "pages", :force => true do |t|
    t.string   "title"
    t.text     "header"
    t.text     "body"
    t.integer  "owner_id"
    t.integer  "owner_type"
    t.integer  "author_id"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
    t.boolean  "published"
    t.datetime "published_at"
    t.string   "level"
    t.string   "viewing_token"
    t.boolean  "locked"
    t.integer  "locker_id"
    t.datetime "locked_at"
    t.string   "tag_list"
    t.boolean  "commenting_enabled"
  end

  create_table "people", :force => true do |t|
    t.string   "name"
    t.string   "email"
    t.string   "password_digest"
    t.datetime "created_at",               :null => false
    t.datetime "updated_at",               :null => false
    t.integer  "company_id"
    t.string   "highrise_id"
    t.string   "access_token"
    t.string   "perishable_token"
    t.datetime "perishable_token_sent_at"
    t.string   "avatar"
    t.text     "bio"
    t.string   "role"
    t.string   "auth_token"
    t.string   "first_name"
    t.string   "last_name"
    t.boolean  "verified"
    t.string   "pin_code"
    t.string   "mobile_phone"
  end

  create_table "polling_sessions", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "polls", :force => true do |t|
    t.text     "question"
    t.text     "choice_a"
    t.text     "choice_b"
    t.text     "choice_c"
    t.text     "choice_d"
    t.boolean  "active"
    t.integer  "polling_session_id"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
  end

  add_index "polls", ["polling_session_id"], :name => "index_polls_on_polling_session_id"

  create_table "posts", :force => true do |t|
    t.string   "title"
    t.text     "body"
    t.integer  "owner_id"
    t.string   "owner_type"
    t.integer  "author_id"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
    t.boolean  "published"
    t.datetime "published_at"
    t.string   "level"
    t.string   "viewing_token"
    t.boolean  "locked"
    t.integer  "locker_id"
    t.datetime "locked_at"
    t.string   "tag_list"
    t.boolean  "commenting_enabled"
    t.boolean  "archived"
  end

  create_table "questions", :force => true do |t|
    t.integer  "survey_id"
    t.text     "prompt"
    t.text     "possible_responses"
    t.string   "response_type"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
    t.integer  "position"
  end

  add_index "questions", ["survey_id"], :name => "index_questions_on_survey_id"

  create_table "responses", :force => true do |t|
    t.integer  "person_id"
    t.integer  "question_id"
    t.integer  "selected_response"
    t.text     "text_response"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
    t.text     "selected_responses"
  end

  add_index "responses", ["person_id"], :name => "index_responses_on_person_id"
  add_index "responses", ["question_id"], :name => "index_responses_on_question_id"

  create_table "subscriptions", :force => true do |t|
    t.integer  "owner_id"
    t.string   "owner_type"
    t.string   "product"
    t.string   "payment_method"
    t.string   "payment_id"
    t.boolean  "active"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  create_table "surveys", :force => true do |t|
    t.integer  "author_id"
    t.string   "author_type"
    t.integer  "owner_id"
    t.string   "title"
    t.text     "discription"
    t.boolean  "published"
    t.datetime "published_at"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
    t.text     "blurb"
  end

  create_table "taggings", :force => true do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.string   "taggable_type"
    t.integer  "tagger_id"
    t.string   "tagger_type"
    t.string   "context",       :limit => 128
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id"], :name => "index_taggings_on_tag_id"
  add_index "taggings", ["taggable_id", "taggable_type", "context"], :name => "index_taggings_on_taggable_id_and_taggable_type_and_context"

  create_table "tags", :force => true do |t|
    t.string "name"
  end

  create_table "versions", :force => true do |t|
    t.string   "item_type",  :null => false
    t.integer  "item_id",    :null => false
    t.string   "event",      :null => false
    t.string   "whodunnit"
    t.text     "object"
    t.datetime "created_at"
  end

  add_index "versions", ["item_type", "item_id"], :name => "index_versions_on_item_type_and_item_id"

end
