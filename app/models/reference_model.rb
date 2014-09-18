class ReferenceModel
  
  include Wisper::Publisher
  
  include Mongoid::Document
  include Mongoid::Timestamps  
    
  field :name, type: String
  field :level, type: Symbol
  field :parent_id, type: BSON::ObjectId
  
  has_and_belongs_to_many :systems
  
  embeds_many :properties
  
  def self.create_or_update_me(level: nil, ref: nil, parent: nil, tokens: nil)
    model_name = ref[1]
    id = parent.id if parent
    rms = self.where(name: model_name)
    if rms.count == 0
      rm = self.new.update_attrs(name: model_name, level: level, parent_id: id, tokens: tokens, ref: ref)      
    elsif rms.count > 1
      raise
    else
      rm = rms.first
      rm.update_attrs(name: model_name, level: level, parent_id: id, tokens: tokens, ref: ref)
    end
    rm
  end
  
  def update_attrs(name: nil, level: nil, parent_id: nil, tokens: nil, ref: nil)
    tokens.delete(:name)
    tokens.delete(:level)
    self.level = level
    ref.shift
    self.name = ref.shift
    self.parent_id = parent_id
    self.add_props(tokens: tokens, ref: ref)
    #binding.pry if self.level == :service_domain
    self.save
    publish(:successful_save_event, self)
    self
  end
  
  def add_props(tokens: nil, ref: nil)
    ref.each do |prop|
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
  
  def parent
    if parent_id
      ReferenceModel.find self.parent_id  
    else
      nil
    end
  end
  
  def token
    tokens = [self.name]
    parent = self.parent
    while parent
      tokens << parent.name
      parent = parent.parent
    end
    tokens.reverse.join(":")
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