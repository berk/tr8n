require 'digest/md5'

class Tr8n::TranslationKey < ActiveRecord::Base
  set_table_name :tr8n_translation_keys
  establish_connection(Tr8n::Config.database) if Tr8n::Config.use_remote_database?
  
  has_many :translations,             :class_name => "Tr8n::Translation",           :dependent => :destroy
  has_many :translation_key_locks,    :class_name => "Tr8n::TranslationKeyLock",    :dependent => :destroy
  has_many :translation_key_sources,  :class_name => "Tr8n::TranslationKeySource",  :dependent => :destroy
  has_many :translation_sources,      :class_name => "Tr8n::TranslationSource",     :through => :translation_key_sources
  
  alias :locks :translation_key_locks
  alias :sources :translation_sources
  
  def self.find_or_create(label, desc = "", options = {})
    key = generate_key(label, desc)
    tkey = find_by_key(key) || create(:key => key, :label => label, :description => desc)

    if options[:source] and Tr8n::Config.enabled_key_source_tracking?
      Tr8n::TranslationKeySource.find_or_create(tkey, Tr8n::TranslationSource.find_or_create(options[:source]))
    end
    
    tkey
  end
  
  def self.generate_key(label, desc="")
    key = "#{label};;;#{desc}"
    Digest::MD5.hexdigest(key)
  end
  
  def tokenized_label
    @tokenized_label ||= Tr8n::TokenizedLabel.new(label)
  end
  
  delegate :tokens, :tokens?, :hidden_tokens, :hidden_tokens?, :sanitized_tokens, :sanitized_tokens?, :to => :tokenized_label
  delegate :sanitized_label, :tokenless_label, :words, :to => :tokenized_label

  def dependency_tokens(language = Tr8n::Config.current_language)
    @dependency_tokens ||= begin
      toks = []
      sanitized_tokens.each do |token|
        token_name = Tr8n::TokenizedLabel.strip_token(token)
        
        # if token is of a form {object.method_name}
        token_name = token_name.split(".").first if token_name.index(".")
        
        Tr8n::Config.language_rule_types.each do |type|
          toks << token_name if can_have_dependency?(language, token_name, type)
        end
        
      end

      toks << Tr8n::Config.viewing_user_token
      toks.uniq
    end
  end

  def self.gender_dependent_token?(token)
    return true if token == Tr8n::Config.viewing_user_token
    return true if Tr8n::Config.gender_based_tokens.include?(Tr8n::TokenizedLabel.strip_token(token).split("_").last)
    false
  end
  
  def gender_dependent_token?(token)
    self.class.gender_dependent_token?(token)
  end

  def self.number_dependent_token?(token)
    return true if Tr8n::Config.number_based_tokens.include?(Tr8n::TokenizedLabel.strip_token(token).split("_").last)
    false
  end
  
  def number_dependent_token?(token)
    self.class.number_dependent_token?(token)
  end

  def dependency_rule_options_for(token)
    return [["has a gender, which", "gender"]] if gender_dependent_token?(token)
    return [["is a number, which", "number"]] if number_dependent_token?(token)
    []
  end
  
  def translation_rule_options_for(language, token)
    return rule_options(language.gender_rules) if gender_dependent_token?(token)
    return rule_options(language.numeric_rules) if number_dependent_token?(token)
    []
  end

  def rule_options(language_rules)
    language_rules.collect{|rule| [rule.describe, rule.id.to_s]}
  end

  # returns back a list of rules types available for a given language
  def rule_type_options_for(language)
    @dependency_options ||= begin
      opts = []
      opts << "gender" if language.has_gender_rules?
      opts << "numeric" if language.has_numeric_rules?
      opts
    end
  end
  
  def can_have_dependency?(language, token, type)
    return false if type == "gender" and (not language.has_gender_rules?)
    return false if type == "numeric" and (not language.has_numeric_rules?)
    return true if type == "gender" and gender_dependent_token?(token)
    return true if type == "numeric" and number_dependent_token?(token)
    false
  end
  
  def glossary
    @glossary ||= Tr8n::Glossary.find(:all, :conditions => ["keyword in (?)", words], :order => "keyword asc")
  end
  
  def glossary?
    not glossary.empty?
  end
  
  def locked?(language = Tr8n::Config.current_language)
    Tr8n::TranslationKeyLock.locked?(self, language)
  end

  def unlocked?(language = Tr8n::Config.current_language)
    not locked?
  end

  def lock!(language = Tr8n::Config.current_language, translator = Tr8n::Config.current_translator)
    Tr8n::TranslationKeyLock.lock(self, language, translator)
  end

  def unlock!(language = Tr8n::Config.current_language, translator = Tr8n::Config.current_translator)
    Tr8n::TranslationKeyLock.unlock(self, language, translator)
  end
    
  def combination_exists?(language_translations, translator, dependencies)
    language_translations.each do |translation|
      return true if translation.translator == translator and translation.dependencies == dependencies
    end
    false
  end
    
  def add_translation(label, context_rules = [], language = Tr8n::Config.current_language, translator = Tr8n::Config.current_translator)
    raise Tr8n::Exception.new("The sentence contains dirty words") unless language.clean_sentence?(label)
    
    translation = Tr8n::Translation.create(:translation_key => self, :language => language, 
                                           :translator => translator, :label => label)
                       
    dependencies = {}
    context_rules.each do |rule|
      dependencies.merge!(rule.dependency)
      rule.translation = translation
      rule.save
    end

    translation.update_attributes(:dependencies => (dependencies.empty? ? nil : dependencies))
    translation.vote!(translator, 1)
    translation
  end

  def inline_translations_for(language)
    Tr8n::Translation.find(:all, :conditions => ["translation_key_id = ? and language_id = ? and rank > -50", self.id, language.id], :order => "rank desc, dependencies asc")
  end
  
  def translations_for(language)
    Tr8n::Translation.find(:all, :conditions => ["translation_key_id = ? and language_id = ?", self.id, language.id], :order => "rank desc, dependencies asc")
  end
  
  def valid_translations_for(language)
    Tr8n::Translation.find(:all, :conditions => ["translation_key_id = ? and language_id = ? and rank >= ?", 
                                            self.id, language.id, Tr8n::Config.minimal_translation_rank], :order => "rank desc")
  end
  
  def delete_unused_combinations(language, profile)
    trans = Translation.find(:all, :conditions => ["translation_key_id = ? and language_id = ? and profile_id = ? and dependencies is not null", self.id, language.id, profile.id])
    trans.each do |tran|
      tran.destroy
    end
  end
  
  def process_dependency_combinations(language, translator, dependencies)
    return if dependencies.blank?
    
    token_rules = {}
    
    dependencies.each do |token, rule_types|
      rule_types.keys.each do |rule_type|
        rules = language.default_rules_for(rule_type)
        token_rules[token] = [] unless token_rules[token]
        token_rules[token] << rules
        token_rules[token].flatten!
      end
    end
    
    language_translations = translations_for(language)
    
    token_rules.combinations.each do |combination|
      dependencies = {} 
      combination.each do |token, language_rule|
        dependencies.merge!({"#{token}" => {language_rule.dependency => "true"}})  
      end
      
      # if the user has previously create this particular combination, move on...
      next if combination_exists?(language_translations, translator, dependencies)
       
      translation = Tr8n::Translation.create(:translation_key => self, :language => language, :translator => translator, :label => sanitized_label, :dependencies => dependencies)
      combination.each do |token, language_rule|
        Tr8n::TranslationRule.create(:translation => translation, :language_rule => language_rule, :token => token)
      end
    end
  end

  def self.random
    find(:first, :offset => rand(count - 1))
  end
  
  def default_translation_rule(language)
    Tr8n::TranslationRule.new(:token => Tr8n::Config.viewing_user_token, :language_rule => language.gender_rules.first)
  end
  
  def find_first_valid_translation(translations, token_values)
    translations.each do |translation|
      return translation if translation.matched_conditions?(token_values)
    end
    nil
  end
  
  def translate(language = Tr8n::Config.current_language, token_values = {}, options = {})
    prepare_token_values(token_values, options)
    
    if Tr8n::Config.disabled? or language.default?
      return substitute_tokens(label, token_values, options.merge(:fallback => false))
    end
    
    translation = find_first_valid_translation(valid_translations_for(language), token_values)
    
    # if the language has a fallback language, use it
    unless translation
      # we don't want to always go back to english... just process the current translation
      if language.fallback_language and not language.fallback_language.default?
        return translate(language.fallback_language, token_values, options.merge(:fallback => true))
      end
    end
    
    if options[:default_label] 
      options.merge!(:fallback => false)
      return decorate_translation(language, label, translation != nil, options)
    end
    
    if translation
      translated_label = translation.translate(token_values, options)
      return decorate_translation(language, translated_label, translation != nil, options)
    end
    
    options.merge!(:fallback => false)
    translated_label = substitute_tokens(label, token_values, options)
    decorate_translation(language, translated_label, translation != nil, options)  
  end

  # this is done when the translations engine is disabled
  def self.substitute_tokens(label, tokens, options = {})
    Tr8n::TranslationKey.new(:label => label).substitute_tokens(label, tokens, options)
  end

  def handle_default_lambda(lambda_token_name, lambda_token_value, token_values)
    return "{invalid lambda token}" unless Tr8n::Config.default_lambdas[lambda_token_name.to_s]
    
    # make sure that only the lambdas from the original label can be used in the translated label
    allowed_tokens = tokenized_label.lambda_tokens.collect{|lt| Tr8n::TokenizedLabel.parse_lambda_token(lt).first}
    return lambda_token_value unless allowed_tokens.include?(lambda_token_name)

    lambda_value = Tr8n::Config.default_lambdas[lambda_token_name.to_s].clone
    
    params = [lambda_token_value]
    params += token_values[lambda_token_name] if token_values[lambda_token_name]
    
    params.each_with_index do |param, index|
      lambda_value.gsub!("{$#{index}}", param.to_s)
    end
    
    lambda_value
  end
  
  def substitute_tokens(label, token_values, options = {})
    translated_label = label.clone

    # substitute basic tokens
    tokens.each do |token|
      translated_label.gsub!(token, token_value(token, token_values, options)) 
    end

    # substitute lambda tokens
    tokenized_label.lambda_tokens(translated_label).each do |token|
      lambda_token_name, lambda_token_value = Tr8n::TokenizedLabel.parse_lambda_token(token)
      next if lambda_token_name.blank?
      
      # lambda token provided
      if token_values[lambda_token_name] 
        
        # evaluate lambda proc
        if token_values[lambda_token_name].is_a?(Proc)
          lambda_value = token_values[lambda_token_name].call(lambda_token_value)
        
        # evaluate default lambda with params
        elsif token_values[lambda_token_name].is_a?(Array)
          lambda_value = handle_default_lambda(lambda_token_name, lambda_token_value, token_values)

        else
          lambda_value = token_values[lambda_token_name].to_s.gsub("{$0}", lambda_token_value)
          
        end  
      elsif Tr8n::Config.default_lambdas[lambda_token_name.to_s]
        lambda_value = handle_default_lambda(lambda_token_name, lambda_token_value, token_values)
        
      else  
        lambda_value = "{invalid lambda token}"
      end
      
      translated_label.gsub!(token, lambda_value) 
    end
    
    translated_label
  end

  def token_value(token, token_values, options = {})
    stripped_token = Tr8n::TokenizedLabel.strip_token(token)
    
    # token is an object method call
    if stripped_token.index(".")  # object based token
      obj_name, method_name = stripped_token.split(".")
      
      obj = token_values[obj_name.to_sym]
      return "{missing token value}" unless obj
      
      return obj.send(method_name)
    end
      
    value = token_values[stripped_token.to_sym]
    return "{missing token value}" unless value
    
    # token is an array
    if value.is_a?(Array)
      # if you provided an array, it better have some values
      return "{invalid array token value}" if value.empty?
      
      # if single object in the array return string value of the object
      return value.first.to_s if value.size == 1
      
      params = value[2..-1]
      params_with_object = [value.first] + params

      # if second param is symbol, invoke the method on the object with the remaining values
      return value.first.send(value.second, *params).to_s if value.second.is_a?(Symbol) 

      # if second param is lambda, call lambda with the remaining values
      return value.second.call(*params_with_object).to_s if value.second.is_a?(Proc)
      
      # if the second param is a string, substitute all of the numeric params,  
      # with the original object and all the following params
      parametrized_value = value.second.clone
      params_with_object.each_with_index do |val, i|
        parametrized_value.gsub!("{$#{i}}", val.to_s)  
      end
      return parametrized_value
    end

    # simple token
    value.to_s
  end
  
  def decorate_translation(language, translated_label, translated = true, options = {})
    return translated_label if options[:skip_decorations]
    return translated_label if locked?(language)

    return translated_label if Tr8n::Config.current_user_is_guest?
    return translated_label unless Tr8n::Config.current_user_is_translator?
    return translated_label unless Tr8n::Config.current_translator.enable_inline_translations?
      
    classes = ['translatable']
    
    if language.default?
      classes << 'not_translated'
    elsif options[:fallback] 
      classes << 'fallback'
    else
      classes << (translated ? 'translated' : 'not_translated')
    end  

    html = "<span class='#{classes.join(' ')}' translation_key='#{id}'>"
    html << translated_label
    html << "</span>"
    html
  end

  def prepare_token_values(token_values, options) 
    return unless options[:api]
    
    token_values.each do |name, value|
      token_values[name.to_sym] = value

      if value.is_a?(String) and value.first == "~"
        token_values[name.to_sym] = create_token_object(value)
      elsif value.is_a?(Array) and value.first.is_a?(String) and value.first.first == "~"
        token_values[name.to_sym][0] = create_token_object(value.first)
      end
    end
  end
  
  def create_token_object(token)
    class_name, object_id = token.split("@")
    return nil unless class_name and object_id
    class_name[1..-1].constantize.find_by_id(object_id)
  end    
    
end
