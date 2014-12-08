class Property
  
  include Mongoid::Document
  include Mongoid::Timestamps  
    
  field :name, type: Symbol
  field :value, type: String
  field :tokenised, type: Boolean, default: false
  
  embedded_in :system
  embedded_in :reference_model

  @@tokenise_props = [:asset_type, :criticality, :tq_fq_quadrant, :pace_layer]
  @@select_options = {
    asset_type: [:enterprise_application, :system_component, :lob_application, :actor, :desktop_system, :reporting_application, :core_application, :marketing_application, :core],
    tq_fq_quadrant: [:replace, :keep, :refactor, :enhance],
    pace_layer: [:sor, :sod, :soi]
  }
      
  def self.imported_props
    @@props
  end
  
  def self.select_options
    @@select_options
  end
   
  def self.find_prop_from_import(prop)
    @@props.find {|p| p.name == prop}
  end
    
  def add_attrs(name: nil, value: nil)
    self.name = name
    self.value = determine_tokenise(name: name, value: value)
    self
  end
    
  def determine_tokenise(name: nil, value: nil)
    return nil if value.nil?
    if @@tokenise_props.include? name.to_sym 
      self.tokenised = true
      value.downcase.gsub(" ", "_")
    else
      value
    end 
  end
  
  def has_select_options?
    @@select_options.has_key?(self.name.to_sym)
  end
  
  def select_options
    @@select_options[self.name.to_sym]
  end
  
  def add_system(system)
    self.system = system
  end
  
  def get(prop)
  end
      
end