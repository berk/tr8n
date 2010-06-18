require 'model_filter'

class Tr8n::BaseFilter < ModelFilter

  def initialize(class_name, identity)
    super(class_name, identity)
  end

  def predefined_filters(profile)
    [
      ["Created Today", "created_today"],
      ["Updated Today", "updated_today"],
    ]
  end

  def self.load_predefined_filter(profile, filter_name)
    filter = self.name.constantize.new(profile)
    filter.key = filter_name
 
    if (filter_name == "created_today")
      filter.add_condition(:created_at, :is_on, Date.today)
      return filter
    end

    if (filter_name == "updated_today")
      filter.add_condition(:updated_at, :is_on, Date.today)
      return filter
    end

    filter
  end  
end
