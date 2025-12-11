class UserSerializer < ActiveModel::Serializer
  attributes :id, :first_name, :role, :profile_photo, :favorite_games

  has_many :reviews
  has_many :favorite_games

end
