class Search
  
  attr_accessor :tables, :properties, :property, :orig_table
  
  
  include Wisper::Publisher
  
  def initialize(params)
    @prop_id = params[:prop_id] if params[:prop_id]
    @table_id = params[:id]
  end
  
  def search
    @orig_table = Table.find(@table_id)
    @property = Property.find(@prop_id)
    @properties = Property.where(name: @property.name).asc(:name)
    @tables = @properties.map(&:table).sort {|a,b| a.name <=> b.name}
    publish(:show_tables_event, self)
  end
  
end