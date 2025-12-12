  module V1
    class GamesController < ApplicationController
      protect_from_forgery with: :null_session
      
      def index
        @games = Game.order(:title)
        
        render json: {
          data: @games.as_json(
            only: [:id, :title, :thumbnail, :genre, :short_description, :platform, :api_id, :game_url, :developer, :publisher, :release_date]
          )
        }
      end
      
def show
  @game = Game.find_by(id: params[:id])
  @game ||= Game.find_by(api_id: params[:id])
  
  if @game
    game_data = @game.as_json(
      only: [:id, :title, :thumbnail, :genre, :short_description, :description, :platform, :api_id, :game_url, :developer, :publisher, :release_date, :screenshot1, :screenshot2, :screenshot3],
      include: {
        reviews: {
          only: [:id, :body, :upvotes, :downvotes, :created_at],
          include: {
            user: {
              only: [:id, :first_name, :profile_photo]
            }
          }
        }
      }
    )
    render json: { data: game_data }
  else
    render json: { error: 'Game not found' }, status: :not_found
  end
end
    end
  end
end