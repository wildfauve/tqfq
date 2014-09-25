class ReferenceModelImportHandler
  
  
  def initialize(ref: nil)
    @ref = ref
  end
  
  def process
    ba = nil
    bd = nil
    @input_tokens = tokenise(@ref.shift)
    @ref.each do |elem|
      if elem[0] == "BA" # level 1
        ba = ReferenceModel.create_or_update_me(ref:  add_props(props: elem, level: :business_area), parent: nil)
      elsif elem[0] == "BD"
        bd = ReferenceModel.create_or_update_me(ref:  add_props(props: elem, level: :business_domain), parent: ba)
      else
        ReferenceModel.create_or_update_me(ref:  add_props(props: elem, level: :service_domain), parent: bd)
      end
    end
  end  
  
  def tokenise(header)
    token_header = header.inject([]) {|out, h| out << h.downcase.gsub(" ", "_").to_sym}
    token_hash = token_header.inject({ properties: {} }) do  |out, token|
      if token == :name || token == :level
        out[token] = nil
      else
        out[:properties][token] = nil
      end
      out
    end
    {token_hash: token_hash, tokens: token_header}
  end
  
  def add_props(props: nil, level: nil)
    input_hash = @input_tokens[:token_hash].dup
    ct = 0
    @input_tokens[:tokens].each do |t|
      if t == :name
        input_hash[:name] = props[ct]
      elsif t == :level
        input_hash[:level] = level        
      else
        input_hash[:properties][t] = props[ct]
      end
      ct += 1
    end
    input_hash
  end
  
  
  
end