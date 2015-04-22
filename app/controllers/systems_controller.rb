class SystemsController < ApplicationController
  
  def index
    @systems = System.all.asc(:name)
  end
  
  def new
    @system = System.create_new
  end
  
  def create
    system = System.new
    system.subscribe(self)
    system.create_me(system: params[:system], properties: params[:properties])
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
    system.update_attrs(system: params[:system], properties: params[:properties])
  end

  def destroy
    system = System.find(params[:id])
    system.subscribe(self)
    system.destroy
  end
  
  def successful_save_event(system)
    redirect_to systems_path
  end
  
  def csv
    System.to_csv
    redirect_to systems_path
  end
  
  
  def sap_coverage
    System.sap_coverage
    redirect_to systems_path
  end
  
  def summary
    @system = System.find(params[:id])
  end
  
end