class Game < ApplicationRecord

  has_many :reviews, dependent: :destroy
  has_many :favorite_games, dependent: :destroy
  has_many :favorited_by_users, through: :favorite_games, source: :user
end