class Api::V1::RestaurantsController < ApplicationController
  before_action :set_restaurant, only: [ :show, :update, :destroy ]

  def index
    render json: Restaurant.all
  end

  def show
    render json: @restaurant
  end

  def create
    restaurant = Restaurant.new(restaurant_params)

    if restaurant.save
      render json: restaurant, status: :created
    else
      render json: { message: restaurant.errors.full_messages, error: "Not created" }, status: :unprocessable_entity
    end
  end

  def update
    if @restaurant.update(restaurant_params)
      render json: @restaurant, status: :ok
    else
      render json: { message: @restaurant.errors.full_messages, error: "Not updated" }, status: :unprocessable_entity
    end
  end

  def destroy
    if @restaurant.destroy
      render json: { message: "Restaurant successfully deleted", restaurant_removed: @restaurant }, status: :ok
    else
      render json: { message: @restaurant.errors.full_messages, error: "Not deleted" }, status: :unprocessable_entity
    end
  end

  def import_json
    if params[:file].nil?
      render json: { error: "No file uploaded" }, status: :unprocessable_entity
      return
    end

    importer = ImportJson.new(params[:file])
    result = importer.import(force: params[:force] || false)

    if result.nil?
      render json: { error: "Invalid file uploaded" }, status: :unprocessable_entity
    else
      render json: { import_result: result }, status: :ok
    end
  end

  private

  def set_restaurant
    begin
      @restaurant = Restaurant.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      render json: { error: "Restaurant Not Found" }, status: :not_found
    end
  end

  def restaurant_params
    params.require(:restaurant).permit(:name, :price)
  end
end
