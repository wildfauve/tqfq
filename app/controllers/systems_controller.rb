class SystemsController < ApplicationController
  
  def index
    @systems = System.all
  end
  
  def new
    @system = System.new
  end
  
  def create
    system = System.new
    system.subscribe(self)    
    system.create_me(params[:system])
  end

  
  def successful_save_event(system)
    redirect_to systems_path
  end
  
  
  
  
end