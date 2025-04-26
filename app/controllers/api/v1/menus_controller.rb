class Api::V1::MenusController < ApplicationController
  before_action :set_restaurant, only: [ :index, :create ]
  before_action :set_menu, only: [ :show, :update, :destroy, :add_menu_item, :remove_menu_item ]

  def index
    render json: @restaurant.menus
  end

  def show
    render json: @menu
  end

  def create
    menu = @restaurant.menus.new(menu_params)

    if menu.save
      render json: menu, status: :created
    else
      render json: { message: menu.errors.full_messages, error: "Not created" }, status: :unprocessable_entity
    end
  end

  def update
    if @menu.update(menu_params)
      render json: @menu, status: :ok
    else
      render json: { message: @menu.errors.full_messages, error: "Not updated" }, status: :unprocessable_entity
    end
  end

  def destroy
    if @menu.destroy
      render json: { message: "Menu successfully deleted", menu_removed: @menu }, status: :ok
    else
      render json: { message: @menu.errors.full_messages, error: "Not deleted" }, status: :unprocessable_entity
    end
  end

  def add_menu_item
    menu_item = MenuItem.find(params[:menu][:menu_item_id])
    @menu.menu_items << menu_item
    render json: { message: "Menu item added to menu" }, status: :ok
  end

  def remove_menu_item
    menu_item = MenuItem.find(params[:menu][:menu_item_id])
    @menu.menu_items.delete(menu_item)
    render json: { message: "Menu item removed from menu" }, status: :ok
  end

  private

  def set_restaurant
    begin
      @restaurant = Restaurant.find(params[:restaurant_id])
    rescue ActiveRecord::RecordNotFound
      render json: { error: "Restaurant Not Found" }, status: :not_found
    end
  end

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
