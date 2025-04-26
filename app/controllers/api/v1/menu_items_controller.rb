class Api::V1::MenuItemsController < ApplicationController
  before_action :set_menu
  before_action :set_menu_item, only: [ :show, :update, :destroy ]

  def index
    render json: @menu.menu_items
  end

  def show
    render json: @menu_item
  end

  def create
    menu_item = @menu.menu_items.new(menu_item_params)

    if menu_item.save
      render json: menu_item, status: :created
    else
      render json: { message: menu_item.errors.full_messages, error: "Not created" }, status: :unprocessable_entity
    end
  end

  def update
    if @menu_item.update(menu_item_params)
      render json: @menu_item, status: :ok
    else
      render json: { message: @menu_item.errors.full_messages, error: "Not updated" }, status: :unprocessable_entity
    end
  end

  def destroy
    if @menu_item.destroy
      render json: { message: "Menu Item successfully deleted", menu_item_removed: @menu_item }, status: :ok
    else
      render json: { message: @menu_item.errors.full_messages, error: "Not deleted" }, status: :unprocessable_entity
    end
  end

  private

  def set_menu
    begin
      @menu = Menu.find(params[:menu_id])
    rescue ActiveRecord::RecordNotFound
      render json: { error: "Menu Not Found" }, status: :not_found
    end
  end

  def set_menu_item
    begin
      @menu_item = @menu.menu_items.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      render json: { error: "Menu Item Not Found" }, status: :not_found
    end
  end

  def menu_item_params
    params.require(:menu_item).permit(:name, :price)
  end
end
