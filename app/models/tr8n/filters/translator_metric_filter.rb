class Tr8n::TranslatorMetricFilter < Tr8n::BaseFilter

  def initialize(identity)
    super('Tr8n::TranslatorMetric', identity)
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

end
