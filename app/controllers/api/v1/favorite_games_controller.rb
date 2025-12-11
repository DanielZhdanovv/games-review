class Api::V1::FavoriteGamesController < ApplicationController
  before_action :authenticate_user!
  
  def create
    @favorite_game = current_user.favorite_games.create(game_id: params[:game_id])
    if @favorite_game.save
      render json: { success: true, favorite_game: @favorite_game }
    else
      render json: { success: false, errors: @favorite_game.errors }
    end
  end

  def index
    @favorite_games = current_user.favorite_games.includes(:game)
    render json: @favorite_games
  end
end

