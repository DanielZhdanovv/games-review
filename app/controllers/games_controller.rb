class GamesController < ApplicationController
  protect_from_forgery with: :null_session
  
  def index
    @games = Game.order(:title)
    render json: @games.as_json(
      only: [:id, :title, :thumbnail, :genre, :api_id]
    )
  end
  
  def show
    @game = Game.find(params[:id])
    
    respond_to do |format|
      format.html
      format.json do
        game_data = @game.as_json(
          only: [:id, :title, :thumbnail, :genre, :short_description, 
                 :description, :platform, :api_id, :game_url, :developer, 
                 :publisher, :release_date, :screenshot1, :screenshot2, 
                 :screenshot3],
          include: {
            reviews: {
              only: [:id, :body, :created_at],
              include: {
                user: {
                  only: [:id, :first_name, :profile_photo]
                }
              }
            }
          }
        )
        game_data['reviews_count'] = @game.reviews.count
        render json: game_data
      end
    end
  end
  
  # GET /games/:id/api
  def api_show
    @game = Game.find(params[:id])
    
    render json: {
      success: true,
      game: {
        id: @game.id,
        api_id: @game.api_id,
        title: @game.title,
        thumbnail: @game.thumbnail,
        genre: @game.genre,
        platform: @game.platform,
        short_description: @game.short_description,
        description: @game.description,
        game_url: @game.game_url,
        developer: @game.developer,
        publisher: @game.publisher,
        release_date: @game.release_date,
        screenshots: [@game.screenshot1, @game.screenshot2, @game.screenshot3].compact,
        system_requirements: @game.minimum_system_requirements,
        created_at: @game.created_at
      },
      reviews: @game.reviews.order(created_at: :desc).map do |review|
        {
          id: review.id,
          body: review.body,
          created_at: review.created_at,
          user: {
            id: review.user.id,
            name: review.user.first_name || "User ##{review.user.id}",
            avatar: review.user.profile_photo
          }
        }
      end,
      stats: {
        total_reviews: @game.reviews.count,
        last_updated: @game.updated_at
      }
    }
  end
  
  # POST /games/:id/api/reviews
  def api_create_review
    @game = Game.find(params[:id])
    
    # Use test mode
    if params[:test_mode] == 'true'
      test_user = User.first || User.create!(
        email: "test@example.com",
        first_name: "Test User",
        password: "password123"
      )
      @review = @game.reviews.build(review_params)
      @review.user = test_user
    else
      require_login
      @review = @game.reviews.build(review_params)
      @review.user = current_user
    end
    
    if @review.save
      render json: {
        success: true,
        message: "Review created successfully!",
        review: {
          id: @review.id,
          body: @review.body,
          created_at: @review.created_at,
          user: {
            id: @review.user.id,
            name: @review.user.first_name
          }
        }
      }, status: :created
    else
      render json: {
        success: false,
        errors: @review.errors.full_messages
      }, status: :unprocessable_entity
    end
  end
  
  # PUT /games/:id/api/reviews/:review_id
  def api_update_review
    @review = Review.find(params[:review_id])
    
    if params[:test_mode] != 'true'
      require_login
      unless @review.user == current_user
        render json: { error: "Not authorized" }, status: :forbidden
        return
      end
    end
    
    if @review.update(review_params)
      render json: {
        success: true,
        message: "Review updated successfully!",
        review: {
          id: @review.id,
          body: @review.body,
          updated_at: @review.updated_at
        }
      }
    else
      render json: {
        success: false,
        errors: @review.errors.full_messages
      }, status: :unprocessable_entity
    end
  end
  
  # DELETE /games/:id/api/reviews/:review_id
  def api_delete_review
    @review = Review.find(params[:review_id])
    
    if params[:test_mode] != 'true'
      require_login
      unless @review.user == current_user
        render json: { error: "Not authorized" }, status: :forbidden
        return
      end
    end
    
    if @review.destroy
      render json: {
        success: true,
        message: "Review deleted successfully!"
      }
    else
      render json: {
        success: false,
        errors: ["Failed to delete review"]
      }, status: :unprocessable_entity
    end
  end
  
  # GET /api/games/search
  def api_search
    games = Game.all
    
    games = games.where("title ILIKE ?", "%#{params[:q]}%") if params[:q].present?
    games = games.where(genre: params[:genre]) if params[:genre].present?
    games = games.where(platform: params[:platform]) if params[:platform].present?
    
    render json: {
      count: games.count,
      games: games.map do |game|
        {
          id: game.id,
          title: game.title,
          thumbnail: game.thumbnail,
          genre: game.genre,
          platform: game.platform,
          short_description: game.short_description,
          review_count: game.reviews.count
        }
      end
    }
  end
  
  private
  
  def review_params
    params.require(:review).permit(:body, :upvotes, :downvotes)
  end
end