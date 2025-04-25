class Api::V1::MenusController < ApplicationController
  def index
    render json: Menu.all
  end

  def show; end

  def create; end

  def update; end

  def destroy; end
end
