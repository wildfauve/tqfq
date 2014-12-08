module ApplicationHelper
  
  def set_up_system(system)
    prop_source = System.first
    sys = System.new
    prop_source.properties.each {|p| sys.properties << Property.new.add_attrs(name: p.name) }
    sys
  end
  
  def determine_alert_from_tqfq(system)
    case system.tq_fq_quadrant
    when "replace"
      "alert-danger"
    when "keep"
      "alert-success"
    else
      "alert-warning"
    end 
  end
  
  def determine_alert_from_business_maturity(ref)
    case ref.capability_to_deliver_the_business_service
    when "1"
      "danger"
    when "2"
      "warning"
    else
      "success"
    end 
  end
  
  def tq_fq_colour(quad)
    if quad == "replace"
      "erorr"
    elsif quad == "keep"
      "success"
    else
      "warning"
    end
  end 
  
  def property_list_select(name)
    Property.select_options[name].map{|o| [o.to_s, o.to_s]}
  end
  
end
