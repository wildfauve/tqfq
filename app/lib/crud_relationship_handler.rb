class CrudRelationshipHandler
  
  def initialize(info: nil, crud: nil, system: nil)
    @info = info
    @crud = crud
    @system = system
  end
  
  def create_relationship
    @info.crud_relationship(crud: @crud, system: @system)
    @system.crud_relationship(crud: @crud, info: @info)
  end
  
end