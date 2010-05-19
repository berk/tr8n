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
  
end
