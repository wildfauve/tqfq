class SystemsController < ApplicationController
  
  def index
    @systems = System.all
  end
  
  def new
    @system = System.create_new
  end
  
  def create
    system = System.new
    system.subscribe(self)
    system.create_me(system: params[:system])
  end
  
  def show 
    @system = System.find(params[:id])
  end
  
  def edit 
    @system = System.find(params[:id])
  end
  
  def update
    system = System.find(params[:id])
    system.subscribe(self)
    system.update_attrs(system: params[:system])
  end

  
  def successful_save_event(system)
    redirect_to systems_path
  end
  
  
  
  
end