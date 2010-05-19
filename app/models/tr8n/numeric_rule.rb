class Tr8n::NumericRule < Tr8n::LanguageRule

  NUMERIC_VALUE_SEPARATOR = ","

  def rule_options
    [["is", "is"], ["is not", "is_not"], ["ends in", "ends_in"], ["does not end in", "does_not_end_in"]]
  end
  
  def can_have_multiple_parts?
    true
  end
  
  def describe
    rule_desc = describe_partial_rule(part1, value1)
    return rule_desc unless multipart?
    
    rule_desc << " " << operator << " " 
    rule_desc << describe_partial_rule(part2, value2)
    rule_desc   
  end
  
  def describe_partial_rule(name, value)
    return "is #{humanize_values(value)}" if name == "is"
    return "is not #{humanize_values(value)}" if name == "is_not"
    return "ends in #{humanize_values(value)}" if name == "ends_in"
    return "does not end in #{humanize_values(value)}" if name == "does_not_end_in"
    "unknown rule"
  end
  
  def evaluate(token)
    token_value = Tr8n::Config.numeric_token_value(token)
    return false unless token_value
    
    result1 = evaluate_partial_rule(token_value.to_s, part1, sanitize_values(value1))
    return result1 unless multipart?
    
    result2 = evaluate_partial_rule(token_value.to_s, part2, sanitize_values(value2))
    return (result1 or result2) if operator == "or"
    return (result1 and result2)
    
    false
  end

  def sanitize_values(values)
    return [] unless values
    values.split(NUMERIC_VALUE_SEPARATOR).collect{|val| val.strip} 
  end

  def humanize_values(values)
    sanitize_values(values).join(", ")
  end

  def evaluate_partial_rule(token_value, name, values)
    if name == "is"
      return true if values.include?(token_value)
      return false
    end
    
    if name == "is_not"
      return true unless values.include?(token_value)
      return false
    end

    if name == "ends_in"
      values.each do |value|
        return true if token_value.to_s =~ /#{value.to_s}$/  
      end
      return false
    end

    if name == "does_not_end_in"
      values.each do |value|
        return false if token_value.to_s =~ /#{value.to_s}$/  
      end
      return true
    end
    
    false
  end
  
  def dependency
    "numeric" 
  end

  def describe_rule
    "token object may be a number, which #{describe}"
  end
  
end
