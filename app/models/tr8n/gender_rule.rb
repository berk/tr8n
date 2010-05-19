class Tr8n::GenderRule < Tr8n::LanguageRule
  
  def rule_options
    [["is", "is"], ["is not", "is_not"]]
  end

  def value1_type
    "list"
  end

  def value1_options
    [["a male", "male"], ["a female", "female"], ["neutral", "neutral"], ["unknown", "unknown"]]
  end
  
  def describe
    if part1 == "is"
      return "is a #{value1}" if ["male", "female"].include?(value1)
      return "has a neutral gender" if ["neutral"].include?(value1)
      return "has an unknown gender" if ["unknown"].include?(value1)
    elsif part1 == "is_not"
      return "is not a #{value1}" if ["male", "female"].include?(value1)
      return "does not have a neutral gender" if ["neutral"].include?(value1)
      return "does not have an unknown gender" if ["unknown"].include?(value1)
    end
    
    "unsupported rule"
  end
  
  def evaluate(token)
    token_value = Tr8n::Config.gender_token_value(token)
    return false unless token_value
    
    if part1 == "is"
      return true if token_value == Tr8n::Config.gender_token_value_for(value1)
    elsif part1 == "is_not"
      return true if token_value != Tr8n::Config.gender_token_value_for(value1)
    end
    
    false    
  end

  def dependency
    "gender" 
  end

  def describe_rule
    d = "token object may have a gender, which"
    if part1 == "is"
      return "#{d} is a #{value1}" if ["male", "female"].include?(value1)
      return "#{d} is #{value1}"
    elsif part1 == "is_not"
      return "#{d} is not a #{value1}" if ["male", "female"].include?(value1)
      return "#{d} is not #{value1}"
    end
    
    "unsupported rule"
  end

end
