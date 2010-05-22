class Tr8n::NumericRule < Tr8n::LanguageRule

  def self.description
    "token object may be a number, which"
  end

  def self.dependency
    "number" 
  end

  def self.default_rules_for(language = Tr8n::Config.current_language)
    Tr8n::Config.default_numeric_rules(language.locale)
  end

  def self.dependant?(token)
    Tr8n::Config.rules_engine[:numeric_rule][:token_suffixes].include?(Tr8n::TokenizedLabel.token_suffix(token))
  end

  def self.rule_options
    [["is", "is"], ["is not", "is_not"], ["ends in", "ends_in"], ["does not end in", "does_not_end_in"]]
  end
  
  def self.operator_options
    ["and", "or"]
  end
  
  def can_have_multiple_parts?
    true
  end
  
  def evaluate(token)
    return false unless token and token.respond_to?(Tr8n::Config.rules_engine[:numeric_rule][:object_method])
    token_value = token.send(Tr8n::Config.rules_engine[:numeric_rule][:object_method])
    return false unless token_value
    
    result1 = evaluate_partial_rule(token_value.to_s, definition[:part1].to_sym, sanitize_values(definition[:value1]))
    return result1 if definition[:multipart].to_s == "false"
    
    result2 = evaluate_partial_rule(token_value.to_s, definition[:part2].to_sym, sanitize_values(definition[:value2]))
    return (result1 or result2) if definition[:operator] == "or"
    return (result1 and result2)
    
    false
  end

  def sanitize_values(values)
    return [] unless values
    values.split(",").collect{|val| val.strip} 
  end

  def humanize_values(values)
    sanitize_values(values).join(", ")
  end

  def evaluate_partial_rule(token_value, name, values)
    if name == :is
      return true if values.include?(token_value)
      return false
    end
    
    if name == :is_not
      return true unless values.include?(token_value)
      return false
    end

    if name == :ends_in
      values.each do |value|
        return true if token_value.to_s =~ /#{value.to_s}$/  
      end
      return false
    end

    if name == :does_not_end_in
      values.each do |value|
        return false if token_value.to_s =~ /#{value.to_s}$/  
      end
      return true
    end
    
    false
  end

  # used by language rules setup page
  def token_description
    "#{self.class.description} <strong>#{description}</strong>"
  end

  # used to describe a context of a given translation
  def description
    rule_desc = describe_partial_rule(definition[:part1].to_sym, definition[:value1])
    return rule_desc if definition[:multipart].to_s == "false"
    
    rule_desc << " " << definition[:operator] << " " 
    rule_desc << describe_partial_rule(definition[:part2].to_sym, definition[:value2])
    humanize_description(rule_desc)   
  end
  
  def describe_partial_rule(name, value)
    return "is #{humanize_values(value)}" if name == :is
    return "is not #{humanize_values(value)}" if name == :is_not
    return "ends in #{humanize_values(value)}" if name == :ends_in
    return "does not end in #{humanize_values(value)}" if name == :does_not_end_in
    "unknown rule"
  end
  
  def humanize_description(desc)
    desc.gsub(" and does not end in", ", but not in")
  end
  
end
