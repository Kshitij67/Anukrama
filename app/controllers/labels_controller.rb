class LabelsController < ApplicationController
  before_action :set_label, only: %i[show edit update destroy]
  before_action :authenticate_user! # Ensure user is signed in

  # GET /labels or /labels.json
  def index
    @labels = current_user.labels # Fetch only current user's labels
  end

  # GET /labels/1 or /labels/1.json
  def show
  end

  # GET /labels/new
  def new
    @label = Label.new
  end

  # GET /labels/1/edit
  def edit
  end

  # POST /labels or /labels.json
  def create
    @label = current_user.labels.build(label_params) # Associate with current user

    if @label.save
      redirect_to users_path(current_user), notice: "Label was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /labels/1 or /labels/1.json
  def update
    if @label.update(label_params)
      redirect_to users_path(current_user), notice: "Label was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /labels/1 or /labels/1.json
  def destroy
    @label.destroy
    redirect_to users_path(current_user), notice: "Label was successfully destroyed."
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_label
    @label = current_user.labels.find(params[:id]) # Find label for current user
  rescue ActiveRecord::RecordNotFound
    redirect_to users_path(current_user), alert: "Label not found."
  end

  # Only allow a list of trusted parameters through.
  def label_params
    params.require(:label).permit(:name) # Remove user_id from params
  end

  def authenticate_user!
    redirect_to new_user_session_path unless user_signed_in?
  end

  def user_signed_in?
    session[:user_id].present?
  end

  def current_user
    @current_user ||= User.find_by(id: session[:user_id])
  end
end
