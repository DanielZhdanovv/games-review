class FavoriteGame < ApplicationRecord
  
  belongs_to :user
  belongs_to :game
  validates :user_id, uniqueness: { scope: :game_id, message: "has already favorited this game" }
end