class Tr8n::TranslationKeyLockFilter < Tr8n::BaseFilter

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
  
  def self.load_predefined_filter(profile, filter_name)
    filter = super(profile, filter_name)
    filter.empty? ? nil : filter
  end  
end
