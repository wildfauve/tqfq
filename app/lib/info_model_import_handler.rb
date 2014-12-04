class InfoModelImportHandler
  
  
  def initialize(info: nil)
    @info = info
  end
  
  def process
    @input_tokens = tokenise(@info.shift)
    @info.each do |map|
      parent = nil
      indx = 1
      [:level_1, :level_2, :level_3].each do |level|
        break if map[indx].nil? || map[indx] == "TBC"
        im = InfoModel.create_or_update_me(info: {name: map[indx], level: level}, parent: parent)
        parent = im
        indx += 1
      end
    end
  end  
  
  def crud_mapping
    @systems = get_all_systems(@info.shift)
    @info.each do |level2|
      info = InfoModel.where(name: level2.shift).and(level: :level_2).first
      binding.pry if !info
      indx = 1
      @systems.each do |system|
        if !level2[indx].nil? 
          CrudRelationshipHandler.new(info: info, crud: level2[indx], system: system).create_relationship
        end
        indx += 1
      end
    end
  end
  
  def tokenise(header)
    header.inject([]) {|out, h| out << h.downcase.gsub(" ", "_").to_sym}
  end
  
  
  def get_all_systems(header)
    header.shift
    systems = []
    header.each do |sys|
      system = System.where(name: sys).first
      if system
        systems << system
      else
        binding.pry
      end
    end
    systems
  end
  
  
end