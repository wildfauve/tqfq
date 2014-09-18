class ReferenceModelImportHandler
  
  
  def initialize(ref: nil)
    @ref = ref
  end
  
  def process
    ba = nil
    bd = nil
    tokens = tokenise(@ref.shift)
    @ref.each do |elem|
      t = tokens.dup
      if elem[0] == "BA" # level 1
        ba = ReferenceModel.create_or_update_me(level: :business_area, ref: elem, tokens: t)
      elsif elem[0] == "BD"
        bd = ReferenceModel.create_or_update_me(level: :business_domain, ref: elem, parent: ba, tokens: t)
      else
        ReferenceModel.create_or_update_me(level: :service_domain, ref: elem, parent: bd, tokens: t)
      end
    end
  end  
  
  def tokenise(header)
    if header.is_a? Array
      header.inject([]) {|out, h| out << h.downcase.gsub(" ", "_").to_sym}
    else
      header.split("|").inject([]) {|out, h| out << h.downcase.gsub(" ", "_").to_sym}
    end
  end
  
  
end