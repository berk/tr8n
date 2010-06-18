class Tr8n::GenderListRule < Tr8n::LanguageRule
  
  def self.description
    "token object may be a list, which"
  end
  
  def self.dependency
    "list" 
  end

  def self.suffixes
    Tr8n::Config.rules_engine[:gender_list_rule][:token_suffixes]
  end

  def self.default_rules_for(language = Tr8n::Config.current_language)
    Tr8n::Config.default_gender_list_rules(language.locale)
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

  def gender_token_value(token)
    self.class.gender_token_value(token)
  end

  def gender_object_value_for(type)
    Tr8n::Config.rules_engine[:gender_rule][:method_values][type]
  end

  def gender_object_value_for(type)
    self.class.gender_object_value_for(type)
  end

  def self.list_size_token_value(token)
    return nil unless token and token.respond_to?(Tr8n::Config.rules_engine[:gender_list_rule][:object_method])
    token.send(Tr8n::Config.rules_engine[:gender_list_rule][:object_method])
  end

  def list_size_token_value(token)
    self.class.list_size_token_value(token)
  end

  def self.male_female_occupants(arr)
    has_male = false  
    has_female = false

    arr.each do |object|
      object_gender = gender_token_value(object)
      return [false, false] unless object_gender
      has_male = true if object_gender == gender_object_value_for("male")
      has_female = true if object_gender == gender_object_value_for("female")
    end  
    
    [has_male, has_female]
  end
  
  def male_female_occupants(arr)
    self.class.male_female_occupants(arr)
  end
  
  # params: [object, all male, all female, mixed genders]
  # {user_list | verb for all male, verb for all female}
  # {user_list | verb for all male, verb for all female, verb for mixed gender}
  def self.transform(*args)
    unless [3, 4].include?(args.size)
      raise Tr8n::Exception.new("Invalid transform arguments")
    end
    
    object = args[0]
    list_size = list_size_token_value(object)

    unless list_size
      raise Tr8n::Exception.new("Token #{object.class.name} does not respond to #{Tr8n::Config.rules_engine[:gender_list_rule][:object_method]}")
    end
    
    has_male, has_female = male_female_occupants(token)
    
    return args[1] if has_male and not has_female
    return args[2] if has_female and not has_male
    
    return args[3] if args.size == 4
    
    "#{args[1]}/#{args[2]}"  
  end  
  
  # params: [all male form, all female form, mixed genders form]
  def self.default_transform(*args)
    unless [2, 3].include?(args.size)
      raise Tr8n::Exception.new("Invalid transform arguments for list token")
    end
    
    return args[2] if args.size == 3
    "#{args[0]}/#{args[1]}"
  end  
  
  def evaluate(token)
    # for now - until we cleanup tokens
    return false unless token.is_a?(Array)
    
    list_size = list_size_token_value(token)
    return false unless list_size
    
    has_male, has_female = male_female_occupants(token)

    case definition[:value]
      when "all_male" then
        return true if has_male and not has_female
      when "all_female" then
        return true if has_female and not has_male
      when "mixed"
        return true if has_male and has_female 
    end
    
    false
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
