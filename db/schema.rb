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

ActiveRecord::Schema[7.2].define(version: 2022_01_27_050313) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "favorite_games", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "game_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["game_id"], name: "index_favorite_games_on_game_id"
    t.index ["user_id"], name: "index_favorite_games_on_user_id"
  end

  create_table "games", force: :cascade do |t|
    t.string "title"
    t.string "thumbnail"
    t.string "genre"
    t.string "api_id"
    t.string "short_description"
    t.string "description"
    t.string "game_url"
    t.string "platform"
    t.string "publisher"
    t.string "developer"
    t.string "release_date"
    t.string "minimum_system_requirements"
    t.string "screenshot1"
    t.string "screenshot2"
    t.string "screenshot3"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "os1"
    t.string "os2"
    t.string "os3"
    t.string "os4"
    t.string "os5"
  end

  create_table "review_user_votes", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "review_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["review_id"], name: "index_review_user_votes_on_review_id"
    t.index ["user_id"], name: "index_review_user_votes_on_user_id"
  end

  create_table "reviews", force: :cascade do |t|
    t.text "body", null: false
    t.bigint "game_id", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "upvotes", default: 0
    t.integer "downvotes", default: 0
    t.index ["game_id"], name: "index_reviews_on_game_id"
    t.index ["user_id"], name: "index_reviews_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "first_name", null: false
    t.string "last_name"
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at", precision: nil
    t.datetime "remember_created_at", precision: nil
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "role", default: "member", null: false
    t.string "profile_photo"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end
end
