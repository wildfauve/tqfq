class InfoModelsController < ApplicationController
  
  def index
    @info = InfoModel.where(level: :level_1)
  end
  
  def show
    @parent = InfoModel.find(params[:id])
    @children = @parent.children
  end
  
  def systems
    @child = InfoModel.find(params[:id])
  end
  
end