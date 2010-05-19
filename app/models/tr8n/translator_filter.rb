class Tr8n::TranslatorFilter < ModelFilter

  def initialize(identity)
    super('Tr8n::Translator', identity)
  end

  def default_order
    'created_at'
  end
  
  def default_order_type
    'desc'
  end
  
end
