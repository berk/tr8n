class Tr8n::TranslationKeyLockFilter < ModelFilter

  def initialize(identity)
    super('Tr8n::TranslationKeyLock', identity)
  end

  def definition
    defs = super  
    defs[:language_id][:is] = :list
    defs[:language_id][:is_not] = :list
    defs
  end
  
  def value_options_for(criteria_key)
    if criteria_key == :language_id
      return Tr8n::Language.filter_options 
    end

    return []
  end

  def default_order
    'created_at'
  end
  
  def default_order_type
    'desc'
  end
  
  def predefined_filters(profile)
    [
      ["Created Today", "created_today"],
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
