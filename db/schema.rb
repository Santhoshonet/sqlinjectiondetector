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

ActiveRecord::Schema.define(:version => 20110730101458) do

  create_table "site_contents", :force => true do |t|
    t.text     "data"
    t.integer  "site_id"
    t.integer :response_code
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sites", :force => true do |t|
    t.string   "url"
    t.text     "base_html"
    t.boolean  "status"
    t.boolean  "is_http_authenticated"
    t.boolean  "is_it_root"
    t.string   "comment"
    t.integer  "response_code"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sql_injection_queries", :force => true do |t|
    t.text     "query"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
