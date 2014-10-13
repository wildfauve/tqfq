class ReferenceModelsController < ApplicationController
  
  def index
    @ref = ReferenceModel.all
  end
end