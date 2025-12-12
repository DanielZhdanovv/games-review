class ReviewsController < ApplicationController
  skip_before_action :verify_authenticity_token

  def show
    render json: Review.find_by(params[:id])
  end
  def create
    @game = Game.find_by(id: params[:game_id]) || Game.find_by(api_id: params[:game_id])
    
    if @game
      @review = @game.reviews.new(review_params.merge(user: current_user))
      
      if @review.save
        render json: @review, include: [:user]
      else
        render json: { errors: @review.errors.full_messages }, status: :unprocessable_entity
      end
    else
      render json: { error: 'Game not found' }, status: :not_found
    end
  end

  def edit
    render json: Review.find(params[:id])
  end

  def update
    review = Review.find(params[:id])
    if review.update(review_params)
      flash.now[:notice] = "Review updated"
      render json: review 
    else
      flash.now[:error] = review.errors.full_messages.to_sentence
      render json: review
    end
  end

  def destroy
    review = Review.find(params[:id])
    review.destroy
    flash[:notice] = 'Game deleted successfully'
  end

  private 

  def authorize_user
    if !user_signed_in? || !current_user.admin?
      flash[:notice] = "You do not have access to this page."
      redirect_to root_path
    end
  end

  def review_params
    params.require(:review).permit(:body, :game_id)
  end
end