class Api::V1::MenuItemsController < ApplicationController
  def index
    render json: MenuItem.all
  end

  def show; end

  def create; end

  def update; end

  def destroy; end
end
