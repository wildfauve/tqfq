class Property
  
  include Mongoid::Document
  include Mongoid::Timestamps  
  
  # Name|GUID|Notes|Technical Fit|Tech Assessment Rationale|Functional Assessment|Functional Assessment Rationale|TSSD Scope|TSSD Rationale
  
  field :name, type: Symbol
  field :value, type: String
  field :tokenised, type: Boolean, default: false
  
  embedded_in :system
  embedded_in :reference_model

  @@tokenise_props = [:criticality, :tq_fq_quadrant, :pace_layer]
    
  def self.imported_props
    @@props
  end
    
  def self.find_prop_from_import(prop)
    @@props.find {|p| p.name == prop}
  end
    
  def add_attrs(name: nil, value: nil)
    self.name = name
    self.value = determine_tokenise(value: value, name: name)
    self
  end
    
  def determine_tokenise(name: nil, value: nil)
    return nil if value.nil?
    if @@tokenise_props.include? name 
      self.tokenised = true
      value.downcase.gsub(" ", "_")
    else
      value
    end 
  end
  
  def add_system(system)
    self.system = system
  end
  
  def get(prop)
  end
      
end