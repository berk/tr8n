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
    
    if definition[:operator] == "is"
      return true if token_value == gender_object_value_for(definition[:value])
    elsif definition[:operator] == "is_not"
      return true if token_value != gender_object_value_for(definition[:value])
    end
    
    false    
  end

  def to_hash
    {:type => self.class.dependency, :operator => definition[:operator], :value => definition[:value]}
  end

  # used by language rules setup page
  def token_description
    if definition[:operator] == "is"
      return "token object may have a gender, which is <strong>a #{definition[:value]}</strong>" if ["male", "female"].include?(definition[:value])
      return "token object may have <strong>a neutral gender</strong>" if "neutral" == definition[:value]
      return "token object may have <strong>an unknown gender</strong>" if "unknown" == definition[:value]
    end
    
    if definition[:operator] == "is_not"
      return "token object may have a gender, which is <strong>not a #{definition[:value]}</strong>" if ["male", "female"].include?(definition[:value])
      return "token object may have a gender, which is <strong>not neutral</strong>" if "neutral" == definition[:value]
      return "token object may have a gender, which is <strong>not unknown</strong>" if "unknown" == definition[:value]
    end
  end

  # used to describe a context of a given translation
  def description
    if definition[:operator] == "is"
      return "is a #{definition[:value]}" if ["male", "female"].include?(definition[:value])
      return "has a neutral gender" if "neutral" == definition[:value]
      return "has an unknown gender" if "unknown" == definition[:value]
    end
    
    if definition[:operator] == "is_not"
      return "is not a #{definition[:value]}" if ["male", "female"].include?(definition[:value])
      return "does not have a neutral gender" if "neutral" == definition[:value]
      return "does not have an unknown gender" if "unknown" == definition[:value]
    end
  end

end
