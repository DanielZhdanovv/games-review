class UsersController < ApplicationController
  def index
    @users = User.all
    render json: @users.as_json(
      only: [:id, :first_name, :email, :profile_photo]
    )
  end
  
  def show
    @user = User.find(params[:id])
    render json: @user.as_json(
      only: [:id, :first_name, :email, :profile_photo]
    )
  end
end