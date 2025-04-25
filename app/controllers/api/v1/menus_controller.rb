class Api::V1::MenusController < ApplicationController
  before_action :set_menu, only: [:show]

  def index
    render json: Menu.all
  end

  def show
    render json: @menu
  end

  def create; end

  def update; end

  def destroy; end

  private

  def set_menu
    begin
      @menu = Menu.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      render json: { error: "Menu Not Found" }, status: :not_found
    end
  end
end
