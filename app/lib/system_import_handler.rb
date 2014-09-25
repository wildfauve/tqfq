class SystemImportHandler
  
  attr_accessor :exceptions
  
  include Wisper::Publisher  
  
  def initialize(path: nil, systems: nil)
    if path
      @systems = CSV.read(path)
    else
      @systems = systems
    end
    self
  end
  
  def process
    @input_tokens = tokenise(@systems.shift)
    @systems.each do |system|
      System.create_or_update(system: add_props(system))
      #binding.pry if System.components.count > 1
    end
    publish(:successful_import_event, self)
  end
  
  def add_ref_binding(refs: nil, dummy: false)
    @exceptions = []
    refs.each do |ref|
      if !ref[3].nil? # there is a system mapping
        ref_model = ReferenceModel.where(name: ref[1]).first
        if !ref_model
          @exceptions << {exception: "ref model not found", ref: ref, ref_model: ref_model}
        end
        systems = ref[3].split(/\n/)
        systems.each do |sys_name|
          sys_name.gsub!(/^\s/, "")
          sys_name.gsub!(/\s$/, "")
          system = System.where(name: sys_name).first
          if !system
            @exceptions << {exception: "system not found", ref: ref, system: sys_name}
          else
            system.add_reference_model_binding(ref: ref_model) if !dummy
          end
        end
      end
    end
  end
    
  def tokenise(header)
    token_header = header.inject([]) {|out, h| out << h.downcase.gsub(" ", "_").to_sym}
    token_hash = token_header.inject({ properties: {} }) do  |out, token|
      if token == :name
        out[token] = nil
      else
        out[:properties][token] = nil
      end
      out
    end
    {token_hash: token_hash, tokens: token_header}
  end
  
  def add_props(system)
    input_hash = @input_tokens[:token_hash].dup
    ct = 0
    @input_tokens[:tokens].each do |t|
      if t == :name
        input_hash[:name] = system[ct]
      else
        input_hash[:properties][t] = system[ct]
      end
      ct += 1
    end
    input_hash
  end
  
end