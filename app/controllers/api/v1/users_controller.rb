class Api::V1::UsersController < ApplicationController
  def index 
    if current_user
      render json: current_user 
    else 
      render json: nil
    end
    
  end
  def show
    user = User.find_by(id: params[:id])
    render json: user
  end

  
end