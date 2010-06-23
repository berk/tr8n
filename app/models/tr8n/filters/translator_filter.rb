class Tr8n::TranslatorFilter < Tr8n::BaseFilter

  def initialize(identity)
    super('Tr8n::Translator', identity)
  end

  def definition
    defs = super  
    defs[:fallback_language_id][:is] = :list
    defs[:fallback_language_id][:is_not] = :list
    defs
  end
  
  def value_options_for(criteria_key)
    if criteria_key == :fallback_language_id
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
