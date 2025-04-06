class TasksController < ApplicationController
  before_action :set_task, only: %i[ show edit destroy update_status ]

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
    @task = Task.new(task_params)
    @task.user_id = session[:user_id]

    # Handle label
    if params[:task][:label_name].present?
      # Find or create label
      @label = Label.find_or_create_by(
        name: params[:task][:label_name],
        user_id: session[:user_id]
      )
      @task.label = @label
    elsif params[:task][:label_id].present?
      @label = Label.find(params[:task][:label_id])
      @task.label = @label
    end

    if @task.save
      redirect_to root_path, notice: "Task was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

    # PATCH/PUT /tasks/1 or /tasks/1.json
    def update_status
      @task = Task.find(params[:id])
      if @task.update(status: params[:status])
        render json: { status: "success" }
      else
        head :unprocessable_entity
      end
    end

  # DELETE /tasks/1 or /tasks/1.json
  def destroy
    @task.destroy!
    redirect_to root_path
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_task
      @task = Task.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def task_params
      params.require(:task).permit(:title, :description, :priority, :status, :user_id, :label_id, :due_date)
    end
end
