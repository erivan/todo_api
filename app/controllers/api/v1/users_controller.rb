class Api::V1::UsersController < ApplicationController
  before_action :authenticate_user!

  def index
    users = Rails.cache.fetch(cache_key) do
      q = User.ransack(params[:q])

      q.result(distinct: true).to_a
    end

    render json: UserSerializer.new(users).serializable_hash
  end

  private

  def cache_key
    [
      "users",
      User.all.cache_key_with_version,
      params[:q].to_s
    ].join("-")
  end
end
