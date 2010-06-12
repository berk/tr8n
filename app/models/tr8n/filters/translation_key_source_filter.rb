class Tr8n::TranslationKeySourceFilter < ModelFilter

  def initialize(identity)
    super('Tr8n::TranslationKeySource', identity)
  end

  def default_order
    'created_at'
  end
  
  def default_order_type
    'desc'
  end
  
end
