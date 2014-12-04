class CrudRelationship
  
  include Mongoid::Document
  include Mongoid::Timestamps  
  
  
  field :c, type: Boolean, default: false
  field :r, type: Boolean, default: false
  field :u, type: Boolean, default: false
  field :d, type: Boolean, default: false
  field :rel, type: BSON::ObjectId
  
  embedded_in :system
  embedded_in :info_model
  
  def self.create_me(crud: nil, rel: nil)
    self.new.update_attrs(crud: crud, rel: rel)
  end
  
  def update_attrs(crud: nil, rel: nil)
    set_crud(crud)
    self.rel = rel.id if rel
    self
  end
  
  def set_crud(crud)
    crud.downcase.split(//).each do |token|
      binding.pry unless ["c", "r", "u", "d"].include? token
      self.send("#{token}=".to_sym, true)
    end
  end
  
  def relation
    if self._parent.class == InfoModel
      System.find(rel)
    elsif self._parent.class == System
      InfoModel.find(rel)
    else
      raise
    end
  end
  
  def tokenise
    token = ""
    [:c, :r, :u, :d].each do |t|
      self.send(t) ? token << t.to_s : token << "-"
    end
    token
  end
  
end