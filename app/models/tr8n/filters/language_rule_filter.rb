class Tr8n::LanguageRuleFilter < Tr8n::BaseFilter

  def initialize(identity)
    super('Tr8n::LanguageRule', identity)
  end

  def definition
    defs = super  
    defs[:language_id][:is] = :list
    defs[:language_id][:is_not] = :list
    defs[:type][:is] = :list
    defs[:type][:is_not] = :list
    defs
  end
  
  def value_options_for(criteria_key)
    if criteria_key == :language_id
      return Tr8n::Language.filter_options 
    end

    if criteria_key == :type
      return Tr8n::Config.language_rule_classes.collect{|cls| cls.to_s}
    end

    return []
  end

  def default_order
    'language_id'
  end
  
  def default_order_type
    'asc'
  end

  def self.load_predefined_filter(profile, filter_name)
    filter = super(profile, filter_name)
    filter.empty? ? nil : filter
  end

end
