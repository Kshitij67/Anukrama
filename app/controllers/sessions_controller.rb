class SessionsController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :new, :create ]
  def new
    if user_signed_in? 
      redirect_to root_path, notice: "You are already logged in"
    end
  end

  def create
    user = User.find_by(email: params[:email])
    if user && user.authenticate(params[:password])
      session[:user_id] = user.id
      redirect_to root_path, notice: "Logged in successfully!"
    else
      flash.now[:alert] = "Invalid username or password"
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    session[:user_id] = nil
    redirect_to login_path, notice: "Logged out successfully!"
  end
end
