class ReferenceModel
  
  include Wisper::Publisher
  
  include Mongoid::Document
  include Mongoid::Timestamps  
    
  field :name, type: String
  field :level, type: Symbol
  field :parent_id, type: BSON::ObjectId
  
  has_and_belongs_to_many :systems
  
  embeds_many :properties
  
  
  def self.create_or_update_me(ref: nil, parent: nil)
    id = parent.id if parent
    rms = self.where(name: ref[:name])
    if rms.count == 0
      rm = self.new
    elsif rms.count > 1
      binding.pry
    else
      rm = rms.first
    end
    rm.update_attrs(ref: ref, parent_id: id)
    rm
  end
  
    
  
  def update_attrs(ref: nil, parent_id: nil)
    self.name = ref[:name]
    self.parent_id = parent_id
    self.level = ref[:level]
    self.add_props(properties:  ref[:properties])
    #binding.pry if self.level == :service_domain
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
  
  def parent
    if parent_id
      ReferenceModel.find self.parent_id  
    else
      nil
    end
  end
  
  def children
    ReferenceModel.where(parent_id: self.id)
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