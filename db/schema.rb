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

ActiveRecord::Schema.define(:version => 20120531194511) do

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
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
    t.string   "format"
    t.integer  "author_id"
    t.boolean  "archived"
    t.string   "asin"
    t.boolean  "published"
  end

  create_table "images", :force => true do |t|
    t.string   "image"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

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
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
    t.integer  "owner_id"
    t.string   "owner_type"
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
  end

  create_table "posts", :force => true do |t|
    t.string   "title"
    t.text     "body"
    t.integer  "author_id"
    t.string   "author_type"
    t.integer  "owner_id"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
    t.boolean  "published"
    t.datetime "published_at"
  end

  create_table "questions", :force => true do |t|
    t.integer  "survey_id"
    t.text     "prompt"
    t.text     "possible_responses"
    t.string   "response_type"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
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
