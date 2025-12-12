class User < ApplicationRecord
  # The join model
  has_many :favorites, class_name: 'FavoriteGame', dependent: :destroy
  
  # The actual games through the join
  has_many :favorite_games, through: :favorites, source: :game
end

# app/models/game.rb
class Game < ApplicationRecord
  # The join model  
  has_many :favorites, class_name: 'FavoriteGame', dependent: :destroy
  
  # The users through the join
  has_many :favorited_by, through: :favorites, source: :user
end

# app/models/favorite_game.rb  
class FavoriteGame < ApplicationRecord
  belongs_to :user
  belongs_to :game
  validates :user_id, uniqueness: { scope: :game_id }
end