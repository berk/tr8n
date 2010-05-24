class Tr8n::TranslationSourceFilter < ModelFilter

  def initialize(identity)
    super('Tr8n::TranslationSource', identity)
  end

  def default_order
    'created_at'
  end
  
  def default_order_type
    'desc'
  end
  
end
