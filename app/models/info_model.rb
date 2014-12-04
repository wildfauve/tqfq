class InfoModel
  
  include Wisper::Publisher
  
  include Mongoid::Document
  include Mongoid::Timestamps  
  
  field :name, type: Symbol
  field :level, type: Symbol
  field :parent_id, type: BSON::ObjectId
  
  embeds_many :crud_relationships
  
  
  def self.create_or_update_me(info: nil, parent: nil)
    id = parent.id if parent
    im = self.where(name: info[:name]).and(level: info[:level])
    if im.count == 0
      mod = self.new
    elsif im.count > 1
      binding.pry
    else
      mod = im.first
    end
    mod.update_attrs(info: info, parent_id: id)
    mod
  end
  
  
  def update_attrs(info: nil, parent_id: nil)
    self.name = info[:name]
    self.parent_id = parent_id
    self.level = info[:level]
    self.save
    publish(:successful_save_event, self)
    self
  end
  
  def crud_relationship(crud: nil, system: nil)
    rel = self.crud_relationships.where(rel: system.id).first
    if rel
      rel.update_attrs(crud: crud)
    else
      self.crud_relationships << CrudRelationship.create_me(crud: crud, rel: system)
    end
    self.save
    publish(:successful_save_event, self)
    self
  end
  
  def parent
    parent_id ? InfoModel.find(self.parent_id) : nil
  end
  
  def children
    InfoModel.where(parent_id: self.id)
  end
  
  def leaf?
    self.children.count == 0 ? true : false
  end
  
          
end