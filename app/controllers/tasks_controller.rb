class TasksController < ApplicationController
  before_action :authenticate_user!
  before_action :set_task, only: [ :show, :edit, :update, :destroy, :update_status ]
  before_action :set_user, only: [ :create ]

  # GET /tasks or /tasks.json
  def index
    @tasks = Task.where(user_id: session[:user_id])
  end

  # GET /tasks/1 or /tasks/1.json
  def show
  end

  # GET /tasks/new
  def new
    @task = Task.new
  end

  # GET /tasks/1/edit
  def edit
  end

  # POST /tasks or /tasks.json
  def create
    puts params
    label = Label.find_by(id: params[:task][:label_id], user_id: session[:user_id]) || Label.find_or_create_by(name: params[:task][:label_name], user_id: session[:user_id])
    params[:task][:label_id] = label.id
    params[:task].delete(:label_name)
    @task = @user.tasks.build(task_params)

    if @task.save
      redirect_to root_path, notice: "Task was successfully created."
    else
      puts @task.errors.full_messages
      redirect_to root_path, alert: "Error creating task."
    end
  end

  # PATCH/PUT /tasks/1 or /tasks/1.json
  def update
    if @task.update(task_params)
      redirect_to root_path, notice: "Task was successfully updated."
    else
      render :edit
    end
  end

  # DELETE /tasks/1 or /tasks/1.json
  def destroy
    @task.destroy
    redirect_to root_path, notice: "Task was successfully destroyed."
  end

  def update_status
    puts @task.status
    puts params[:status]
    if @task.update(status: params[:status])
      render json: { status: "success" }
    else
      puts @task.errors.full_messages
      render json: { status: "error", message: @task.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_task
      @task = Task.find(params[:id])
    end

    def set_user
      @user = User.find(params[:user_id])
    end

    # Only allow a list of trusted parameters through.
    def task_params
      params.require(:task).permit(:title, :description, :due_date, :priority, :status, :label_id, :label_name)
    end
end
