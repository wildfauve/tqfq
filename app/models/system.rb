class System
  
  include Wisper::Publisher
  
  include Mongoid::Document
  include Mongoid::Timestamps  
    
  field :name, type: String
  field :type, type: Symbol
  field :sap_coverage, type: Integer
  
  embeds_many :properties
  embeds_many :crud_relationships
  has_and_belongs_to_many :reference_models
  
  #
  #accepts_nested_attributes_for :properties
  
  scope :system_type, -> {where(type: :system)}
    
  @@data_types = {
    description: {type: :long_text}
  }
  @@system_types = [:system, :component, :external, :not_determined]
  
  def self.system_types
    @@system_types
  end

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
  
  def self.to_csv
    props = self.all_property_names.map {|n| n}
    CSV.open("lib/tasks/systems_output.csv", 'w') do |csv|
      csv << ["Name", "Type"] + props
      System.each do |sys| 
        row = []
        row << sys.name
        row << sys.type
        props.each {|p| row << sys.send(p).try(:value)}
        csv << row
      end
    end
  end
  
  def self.all_property_names
    @all_props || @all_props = self.all.map(&:properties).flatten.map(&:name).uniq
  end

  def self.core(type: nil)
    s = self.system_type
    core = s.select {|sys| sys.criticality.try(:value) == "tier_1" || sys.criticality.try(:value) == "tier_2" || sys.criticality.try(:value) == "core" }
    if type == :all
      core
    elsif type == :assessed
      core.select {|sys| sys.assessed_quad?}
    else
      raise
    end
  end
  
  def self.sap_coverage 
    self.each do |sys|
      #decision = sys.replace_decision
      mapping = sys.reference_models.map(&:sap_mapping)
      map_ct = mapping.count
      mapping.delete("N")
      mapping.empty? ? covered = 0   : covered =  ((mapping.count.to_f / map_ct)) * 100
      sys.sap_coverage.value = covered
      sys.save
    end
  end
  
    
  def self.assessed_count
    s = self.system_type.try(:value)
    s.count {|sys| sys.assessed_quad?}
  end
    
  
  #{"name"=>"Quantum", "properties"=>{"asset_type"=>"LOB application", "description"=>"All Financial markets products - FX, MM, Securities, Derivatives", "business_process"=>"Financial Market Trade capture and settlement", "criticality"=>"tier_1", "pace_layer"=>"sor", "tq_fq_quadrant"=>"keep"}}
  
  def create_me(system: nil, properties: nil)
    self.update_attrs(system: system, properties: properties)
  end
  
  def update_attrs(system: nil, properties: nil)
    self.name = system[:name]
    self.add_props(properties: properties)
    if system[:type]
      self.type = symbolise(system[:type])
    else
      self.type = self.determine_type
    end
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
  
  def crud_relationship(crud: nil, info: nil)
    rel = self.crud_relationships.where(rel: info.id).first
    if rel
      rel.update_attrs(crud: crud)
    else
      self.crud_relationships << CrudRelationship.create_me(crud: crud, rel: info)
    end
    self.save
    publish(:successful_save_event, self)
    self
  end
  
  
  def destroy
    self.delete
    publish(:successful_save_event, self)    
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
  
  
  def determine_type
    if ["system_component", "desktop_system"].include? self.asset_type.try(:value)
      return :component
    elsif self.asset_type.try(:value) == "actor"
      return :external
    elsif ["core_application", "lob_application", "reporting_application", "enterprise_application", "marketing_application"].include? self.asset_type
      return :system
    else
      return :not_determined
    end
  end
  
  def components_system
    System.where(name: self.parent_system).first
  end
  
  def tq_fq_point
    "#{self.tq.try(:value)}-#{self.fq.try(:value)}"
  end
  
  def assessed?
    self.tq.try(:value).to_i == 0 || self.fq.try(:value).to_i == 0 ? false : true
  end
  
  def assessed_quad?
    ["replace", "keep", "refactor", "enhance"].include?(self.tq_fq_quadrant.try(:value))
  end
  
  def quad
    if !self.assessed?
      return :not_assessed
    end
    tq = self.tq.to_i
    fq = self.fq.to_i
    if tq < 3 && fq < 3
      :replace
    elsif tq > 3 && fq > 3
      :invest
    elsif tq > 3 && fq < 3
      :enhance
    elsif tq < 3 && fq > 3
      :refactor
    else
      :investigate
    end
  end
    
  def replace_decision
    return {target: "more info", timeframe: "more info"} if self.tq_fq_quadrant.nil? && self.pace_layer.nil?
    if self.tq_fq_quadrant.value == "replace"
      timeframe = "T1"
      if self.pace_layer.value == "sor"
        target = "SAP"
      else
        target = "New"
      end
    elsif self.tq_fq_quadrant.value == "keep"
      if self.pace_layer == "sor"
        target = "SAP"
        timeframe = "T2"
      else
        target = "Keep"
      end
    else
      if self.pace_layer.value == "sor"
        target = "SAP"
        timeframe = "T2"
      else
        target = "Keep"
      end
    end
    {target: target, timeframe: timeframe}
  end
    
  def bian_map_ct
    self.reference_models.count
  end
  
  def symbolise(str)
    str.downcase.gsub(" ", "_").to_sym
  end
  
  def property_type(prop: nil)
    if @@data_types[prop]
      @@data_types[prop][:type]
    else
      nil
    end
  end

  def method_missing(meth, *args, &block)
    prop = self.properties.where(name: meth).first
    if prop
      prop
    else
      nil
      #super # You *must* call super if you don't handle the
            # method, otherwise you'll mess up Ruby's method
            # lookup.
    end
  end

  
end
