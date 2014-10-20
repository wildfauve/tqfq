class ReferenceModelsController < ApplicationController
  
  def index
    @ref = ReferenceModel.all
  end
  
  def panels
    @ba = ReferenceModel.where(level: :business_area)
  end
  
  def show
    @parent = ReferenceModel.find(params[:id])
    @children = @parent.children
  end
  
  def systems
    @child = ReferenceModel.find(params[:id])
  end
  
  def projects
    @child = ReferenceModel.find(params[:id])
  end
  
  def toggle
    @child = ReferenceModel.find(params[:id])
    @panel_type = params[:class]
  end
  
end