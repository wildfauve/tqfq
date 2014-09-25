class System
  
  include Wisper::Publisher
  
  include Mongoid::Document
  include Mongoid::Timestamps  
    
  field :name, type: String
  field :type, type: Symbol
  
  embeds_many :properties
  has_and_belongs_to_many :reference_models
  
  #
  #accepts_nested_attributes_for :properties
  
  scope :system_type, -> {where(type: :system)}

  def self.create_or_update(system: nil)
    syss = self.where(name: system[:name])
    if syss.count == 0
      sys = self.new
    elsif syss.count > 1
      raise
    else
      sys = syss.first
    end
    sys.update_attrs(system: system)    
    sys
  end
  
  def self.find_by_prop(prop: nil, value: nil)
    self.where("properties.name" => prop).and("properties.value" => value)
  end
    
  def self.create_new
    prop_source = System.first
    sys = System.new
    prop_source.properties.each {|p| sys.properties << Property.new.add_attrs(name: p.name) }
    sys
  end
  
  #{"name"=>"Quantum", "properties"=>{"asset_type"=>"LOB application", "description"=>"All Financial markets products - FX, MM, Securities, Derivatives", "business_process"=>"Financial Market Trade capture and settlement", "criticality"=>"tier_1", "pace_layer"=>"sor", "tq_fq_quadrant"=>"keep"}}
  
  def create_me(system: nil)
    self.update_attrs(system: system)
  end
  
  def update_attrs(system: nil)
    raise
    self.name = system[:name]
    self.add_props(properties: system[:properties])
    self.type = self.determine_type
    self.save
    publish(:successful_save_event, self)
    self
  end 
  
  def add_props(properties: nil)
    properties.each do |k, v|
      p = self.properties.where(name: k).first
      if p
        p.add_attrs(name: k, value: v)
      else
        p = Property.new.add_attrs(name: k, value: v)
        self.properties << p
      end
    end
  end
  
  def get_system_prop(prop)
    self.properties.where(name: prop).first.try(:value)
  end 
  
  def add_reference_model_binding(ref: nil)
    self.reference_models << ref
    self.save
  end
  
  def associated_with_model?(model: nil)
    self.reference_model_ids.include? model.id
  end
  
  def method_missing(meth, *args, &block)
    prop = self.properties.where(name: meth).first
    if prop
      prop.value
    else
      nil
      #super # You *must* call super if you don't handle the
            # method, otherwise you'll mess up Ruby's method
            # lookup.
    end
  end
  
  def determine_type
    if self.asset_type == "system_component"
      return :component
    elsif self.asset_type == "actor"
      return :external
    else
      return :system
    end
  end
  
  def components_system
    System.where(name: self.parent_system).first
  end
  
  def tq_fq_point
    "#{self.tq}-#{self.fq}"
  end
  
  def assessed?
    if self.tq.to_i == 0 || self.fq.to_i == 0
      return false
    else
      return true
    end
  end
  
  
end
