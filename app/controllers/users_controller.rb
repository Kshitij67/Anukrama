class UsersController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :new, :create ]
  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      session[:user_id] = @user.id
      redirect_to root_path, notice: "Account created successfully!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def dashboard
    @incomplete_count = Task.where(user_id: session[:user_id]).where(status: 0).size
    @ongoing_count = Task.where(user_id: session[:user_id]).where(status: 1).size
    @complete_count = Task.where(user_id: session[:user_id]).where(status: 2).size
  end
  
  def show
    if current_user.id != session[:user_id]
      redirect_to "application#not_found"
    end
    @incomplete = Task.where(user_id: session[:user_id]).where(status: 0)
    @ongoing = Task.where(user_id: session[:user_id]).where(status: 1)
    @complete = Task.where(user_id: session[:user_id]).where(status: 2)
    @labels = Label.where(user_id: session[:user_id])
  end

  def update
    @user = User.find(params[:id])
    if @user.update(user_params)
      redirect_to dashboard_path, notice: "Profile updated successfully!"
    else
      render dashboard_path, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end
end
