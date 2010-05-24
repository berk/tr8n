class Tr8n::TranslatorLogFilter < ModelFilter

  def initialize(identity)
    super('Tr8n::TranslatorLog', identity)
  end

  def default_order
    'created_at'
  end
  
  def default_order_type
    'desc'
  end
  
  def definition
    defs = super  
    defs[:action][:is] = :list
    defs[:action][:is_not] = :list
    defs
  end

  def value_options_for(criteria_key)
    if criteria_key == :action
      return Tr8n::TranslatorLog::ACTIONS
    end

    return []
  end
  
  
  def predefined_filters(profile)
    [
      ["Logged Today", "created_today"],
    ]
  end

  def self.load_predefined_filter(profile, filter_name)
    filter = self.name.constantize.new(profile)
    filter.key=filter_name
 
    if (filter_name=="created_today")
      filter.add_condition(:created_at, :is_on, Date.today)
      return filter
    end

    nil
  end  
  
  
end
