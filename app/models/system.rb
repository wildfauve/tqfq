class System
  
  include Wisper::Publisher
  
  include Mongoid::Document
  include Mongoid::Timestamps  
    
  field :name, type: String
  
  embeds_many :properties
  has_and_belongs_to_many :reference_models

  def self.create_or_update(line: nil, tokens: nil, system: nil)
    system_name = system[0]
    syss = self.where(name: system_name)
    if syss.count == 0
      sys = self.new.update_attrs(name: system_name, tokens: tokens, system: system)
    elsif syss.count > 1
      raise
    else
      sys = syss.first
      sys.update_attrs(name: system_name, tokens: tokens, system: system)
    end
    sys
    
    
=begin    
    props = Property.add_properties_from_import(line: line, tokens: tokens, system: system)
    system = self.where(name: props.find_prop_from_import(:name).value).first
    if system
      system.add_props(props.imported_props)
      system.save
    else
      system = self.new.create_me(name: props.find_prop_from_import(:name).value, props: props.imported_props)
    end
=end
    
  end
  
  def self.find_by_prop(prop: nil, value: nil)
    self.where("properties.name" => prop).and("properties.value" => value)
  end
  
  
  
  def update_attrs(name: nil, tokens: nil, system: nil)
    tokens.delete(:name)
    system.shift
    self.name = name
    self.add_props(tokens: tokens, system: system)
    self.save
    publish(:successful_save_event, self)
    self
  end 
  
  def add_props(tokens: nil, system: nil)
    system.each do |prop|
      prop_name = tokens.shift 
      if !prop.nil?
        p = self.properties.where(name: prop_name).first
        if p
          p.add_attrs(name: prop_name, value: prop)
        else
          p = Property.new.add_attrs(name: prop_name, value: prop)
          self.properties << p
        end
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
  
  
end
