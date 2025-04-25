class Api::V1::MenusController < ApplicationController
  before_action :set_menu, only: [:show, :update, :destroy]

  def index
    render json: Menu.all
  end

  def show
    render json: @menu
  end

  def create
    menu = Menu.new(menu_params)

    if menu.save
      render json: menu, status: :created
    else
      render json: { message: menu.errors.full_messages ,error: "Not created" }, status: :unprocessable_entity
    end
  end

  def update
    if @menu.update(menu_params)
      render json: @menu, status: :ok
    else
      render json: { message: @menu.errors.full_messages ,error: "Not updated" }, status: :unprocessable_entity
    end
  end

  def destroy
    if @menu.destroy
      render json: { message: "Menu successfully deleted", menu_removed: @menu } , status: :ok 
    else
      render json: { message: @menu.errors.full_messages ,error: "Not deleted" }, status: :unprocessable_entity
    end
  end

  private

  def set_menu
    begin
      @menu = Menu.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      render json: { error: "Menu Not Found" }, status: :not_found
    end
  end

  def menu_params
    params.require(:menu).permit(:name, :description)
  end
end
