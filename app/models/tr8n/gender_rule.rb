class Tr8n::GenderRule < Tr8n::LanguageRule
  
  def self.description
    "token object may have a gender, which"
  end
  
  def self.dependency
    "gender" 
  end

  def self.default_rules_for(language = Tr8n::Config.current_language)
    Tr8n::Config.default_gender_rules(language.locale)
  end
  
  def self.dependant?(token)
    Tr8n::Config.rules_engine[:gender_rule][:token_suffixes].include?(Tr8n::TokenizedLabel.token_suffix(token))
  end
  
  def self.operator_options
    [["is", "is"], ["is not", "is_not"]]
  end

  def self.gender_options
    [["a male", "male"], ["a female", "female"], ["neutral", "neutral"], ["unknown", "unknown"]]
  end
  
  def gender_token_value(token)
    return nil unless token and token.respond_to?(Tr8n::Config.rules_engine[:gender_rule][:object_method])
    token.send(Tr8n::Config.rules_engine[:gender_rule][:object_method])
  end

  def gender_object_value_for(type)
    Tr8n::Config.rules_engine[:gender_rule][:method_values][type]
  end
  
  def evaluate(token)
    token_value = gender_token_value(token)
    return false unless token_value
    
    if definition[:part1] == "is"
      return true if token_value == gender_object_value_for(definition[:value1])
    elsif definition[:part1] == "is_not"
      return true if token_value != gender_object_value_for(definition[:value1])
    end
    
    false    
  end

  # used by language rules setup page
  def token_description
    if definition[:part1] == "is"
      return "token object may have a gender, which is <strong>a #{definition[:value1]}</strong>" if ["male", "female"].include?(definition[:value1])
      return "token object may have <strong>a neutral gender</strong>" if "neutral" == definition[:value1]
      return "token object may have <strong>an unknown gender</strong>" if "unknown" == definition[:value1]
    end
    
    if definition[:part1] == "is_not"
      return "token object may have a gender, which is <strong>not a #{definition[:value1]}</strong>" if ["male", "female"].include?(definition[:value1])
      return "token object may have a gender, which is <strong>not neutral</strong>" if "neutral" == definition[:value1]
      return "token object may have a gender, which is <strong>not unknown</strong>" if "unknown" == definition[:value1]
    end
  end

  # used to describe a context of a given translation
  def description
    if definition[:part1] == "is"
      return "is a #{definition[:value1]}" if ["male", "female"].include?(definition[:value1])
      return "has a neutral gender" if "neutral" == definition[:value1]
      return "has an unknown gender" if "unknown" == definition[:value1]
    end
    
    if definition[:part1] == "is_not"
      return "is not a #{definition[:value1]}" if ["male", "female"].include?(definition[:value1])
      return "does not have a neutral gender" if "neutral" == definition[:value1]
      return "does not have an unknown gender" if "unknown" == definition[:value1]
    end
  end
end
