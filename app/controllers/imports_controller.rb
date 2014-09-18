class ImportsController < ApplicationController
  
  def new
  end
  
  def index
  end
  
  def create
    name = params[:import].original_filename
    directory = "public/imports"
    path = File.join(directory, name)
    File.open(path, "wb") { |f| f.write(params[:import].tempfile.read) }
    import = SystemImportHandler.new(path: path)
    import.subscribe(self)
    import.process
  end
  
  def successful_import_event(load)
    redirect_to systems_path
  end
  
    
  
end