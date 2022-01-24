class FavoriteGames < ActiveRecord::Migration[6.1]
  def change
    create_table :favorite_games do |t|
     t.belongs_to :user, null: false
     t.belongs_to :game, null: false

    t.timestamps null: false
  end
end
end
