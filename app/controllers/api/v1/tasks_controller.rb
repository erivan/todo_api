class Api::V1::TasksController < ApplicationController
  before_action :authenticate_user!

  rescue_from ActiveRecord::StatementInvalid, with: :handle_invalid_status


  def index
    tasks = Rails.cache.fetch(cache_key) do
      q = Task.ransack(params[:q])

       q.result(distinct: true).includes(:user).to_a
    end

    render json: TaskSerializer.new(tasks).serializable_hash
  end

  def show
    task = Task.find(params[:id])

    render json: TaskSerializer.new(task).serializable_hash
  end

  def create
    task = Task.new(task_params)

    if task.save
      render json: TaskSerializer.new(task).serializable_hash, status: :created
    else
      render json: { errors: task.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    task = Task.find(params[:id])

    if task.update(task_params)
      render json: TaskSerializer.new(task).serializable_hash, status: :ok
    else
      render json: { errors: task.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    task = Task.find(params[:id])

    task.destroy

    head :no_content
  end

  private

  def cache_key
    [
      "tasks",
      Task.all.cache_key_with_version,
      params[:q].to_s
    ].join("-")
  end

  def task_params
    params.require(:task).permit(:description, :title, :due_date, :status, :user_id)
  end

  def handle_invalid_status
    render json: { errors: "Invalid status" }, status: :unprocessable_entity
  end
end
