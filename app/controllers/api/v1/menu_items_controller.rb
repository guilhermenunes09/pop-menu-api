class Api::V1::MenuItemsController < ApplicationController
  before_action :set_menu

  def index
    render json: @menu.menu_items
  end

  def show; end

  def create; end

  def update; end

  def destroy; end

  private

  def set_menu
    begin
      @menu = Menu.find(params[:menu_id])
    rescue ActiveRecord::RecordNotFound
      render json: { error: "Menu Not Found" }, status: :not_found
    end
  end
end
