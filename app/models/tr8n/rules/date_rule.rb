class Tr8n::DateRule < Tr8n::LanguageRule
  
  def self.description
    "token object may be a date, which"
  end
  
  def self.dependency
    "date" 
  end

  def self.default_rules_for(language = Tr8n::Config.current_language)
    Tr8n::Config.default_date_rules(language.locale)
  end
  
  def self.dependant?(token)
    Tr8n::Config.rules_engine[:date_rule][:token_suffixes].include?(Tr8n::TokenizedLabel.token_suffix(token))
  end
  
  def self.operator_options
    [["is in the", "is_in"]]
  end

  def self.date_options
    [["past", "past"], ["present", "present"], ["future", "future"]]
  end

  def date_token_value(token)
    return nil unless token and token.respond_to?(Tr8n::Config.rules_engine[:date_rule][:object_method])
    token.send(Tr8n::Config.rules_engine[:date_rule][:object_method])
  end

  def evaluate(token)
    token_date = date_token_value(token)
    return false unless token_date
    
    current_date = Date.today
    
    case definition[:value]
      when "past" then
          return true if token_date < current_date
      when "present" then
          return true if token_date == current_date
      when "future" then
          return true if token_date > current_date
    end

    false    
  end

  # used by language rules setup page
  def token_description
    if self.class.date_options.collect{|o| o.last}.include?(definition[:value])
      return "token object may be a date, which is in the <strong>#{definition[:value]}</strong>"
    end
    
    "unknown rule"
  end

  # used to describe a context of a given translation
  def description
    if self.class.date_options.collect{|o| o.last}.include?(definition[:value])
      return "is in the #{definition[:value]}"
    end
    
    "unknown rule"
  end
end
