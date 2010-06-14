class Tr8n::GenderListRule < Tr8n::LanguageRule
  
  def self.description
    "token object may be a list, which"
  end
  
  def self.dependency
    "list" 
  end

  def self.default_rules_for(language = Tr8n::Config.current_language)
    Tr8n::Config.default_gender_list_rules(language.locale)
  end
  
  def self.dependant?(token)
    Tr8n::Config.rules_engine[:gender_list_rule][:token_suffixes].include?(Tr8n::TokenizedLabel.token_suffix(token))
  end
  
  def self.operator_options
    [["contains", "contains"]]
  end

  def self.gender_list_options
    [["all male objects", "all_male"], ["all female objects", "all_female"], ["objects of mixed gender", "mixed"]]
  end
  
  def gender_token_value(token)
    return nil unless token and token.respond_to?(Tr8n::Config.rules_engine[:gender_rule][:object_method])
    token.send(Tr8n::Config.rules_engine[:gender_rule][:object_method])
  end

  def gender_object_value_for(type)
    Tr8n::Config.rules_engine[:gender_rule][:method_values][type]
  end
  
  def list_size_token_value(token)
    return nil unless token and token.respond_to?(Tr8n::Config.rules_engine[:gender_list_rule][:object_method])
    token.send(Tr8n::Config.rules_engine[:gender_list_rule][:object_method])
  end
  
  def evaluate(token)
    # for now - until we cleanup tokens
    return false unless token.is_a?(Array)
    
    list_size = list_size_token_value(token)
    return false unless list_size
    
    has_male = false  
    has_female = false

    token.each do |object|
      object_gender = gender_token_value(object)
      return false unless object_gender
      
      case definition[:value]
        when "all_male" then
          has_male = true
          return false if object_gender != gender_object_value_for("male")
        when "all_female" then
          has_female = true
          return false if object_gender != gender_object_value_for("female")
      end
    end
    
    if definition[:value] == "mixed"
      return false unless has_male and has_female
    end
    
    true    
  end

  def to_hash
    {:type => self.class.dependency, :operator => definition[:operator], :value => definition[:value]}
  end

  # used by language rules setup page
  def token_description
    return "token object may have a list, which contains <strong>all male objects</strong>"          if "all_male" == definition[:value]
    return "token object may have a list, which contains <strong>all female objects</strong>"        if "all_female" == definition[:value]
    return "token object may have a list, which contains <strong>male and female objects</strong>"   if "mixed" == definition[:value]
    "unknown rule"
  end

  # used to describe a context of a given translation
  def description
    return "contains all male objects"         if "all_male" == definition[:value]
    return "contains all female objects"       if "all_female" == definition[:value]
    return "contains male and female objects"  if "mixed" == definition[:value]
    "unknown rule"
  end
end
