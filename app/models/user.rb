class User < ApplicationRecord
  
def self.from_omniauth(auth)
  where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
    user.email = auth.info.email
    user.first_name = auth.info.name  # This might be what you need
    user.image = auth.info.image
    
    # Set default values for required field
    user.first_name ||= "User"
  end
end
  
  has_many :reviews
  has_many :favorite_games
  has_many :favorites, through: :favorite_games, source: :game
  
  validates :uid, presence: true, uniqueness: { scope: :provider }
  validates :provider, presence: true
end