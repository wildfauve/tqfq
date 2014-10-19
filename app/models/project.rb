class Project
  
  include Mongoid::Document
  include Mongoid::Timestamps  
  
  field :name, type: Symbol
  
  has_and_belongs_to_many :reference_models
  
  def create_me(name: nil)
    self.name = name
    self.save
    self
  end
  
  def rm_count
    self.reference_models.count
  end
          
end