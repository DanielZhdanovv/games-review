class User < ApplicationRecord
  
def self.from_omniauth(auth)
  where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
    user.email = auth.info.email
    user.first_name = auth.info.name
    user.profile_photo = auth.info.image
    user.first_name ||= "User"
  end
end
  
  has_many :reviews, dependent: :destroy
  has_many :review_user_votes, dependent: :destroy
  has_many :favorite_games, dependent: :destroy
  has_many :favorited_games, through: :favorite_games, source: :game
  
  validates :uid, presence: true, uniqueness: { scope: :provider }
  validates :provider, presence: true
end