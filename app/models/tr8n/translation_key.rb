#--
# Copyright (c) 2010 Michael Berkovich, Geni Inc
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#++

require 'digest/md5'

class Tr8n::TranslationKey < ActiveRecord::Base
  set_table_name :tr8n_translation_keys
  
  has_many :translations,             :class_name => "Tr8n::Translation",           :dependent => :destroy
  has_many :translation_key_locks,    :class_name => "Tr8n::TranslationKeyLock",    :dependent => :destroy
  has_many :translation_key_sources,  :class_name => "Tr8n::TranslationKeySource",  :dependent => :destroy
  has_many :translation_sources,      :class_name => "Tr8n::TranslationSource",     :through => :translation_key_sources
  has_many :translation_key_comments, :class_name => "Tr8n::TranslationKeyComment", :dependent => :destroy, :order => "created_at desc"
  
  alias :locks :translation_key_locks
  alias :sources :translation_sources
  
  def self.find_or_create(label, desc = "", options = {})
    key = generate_key(label, desc)
    
    # translation keys don't ever change, so no real reason to invalidate them  
    tkey = Tr8n::Cache.fetch("translation_key_#{key}") do 
      existing_key = find_by_key(key) 
      
      unless existing_key
        if options[:api] and (not Tr8n::Config.api[:allow_key_registration])
          raise Tr8n::KeyRegistrationException.new("Key registration through API is disabled!")  
        end
      end
      
      existing_key ||= begin
        new_tkey = create(:key => key, 
                          :label => label, 
                          :description => desc, 
                          :locale => (Tr8n::Config.block_options[:default_locale] || Tr8n::Config.default_locale),
                          :admin => Tr8n::Config.block_options[:admin])
        unless options[:source].blank?
          # at the time of creation - mark the first source of the key
          Tr8n::TranslationKeySource.find_or_create(new_tkey, Tr8n::TranslationSource.find_or_create(options[:source]))
        end  
        new_tkey
      end  

      # for backwards compatibility only
      mark_as_admin(existing_key, options)
      update_default_locale(existing_key, options)
      
      # mark each key as verified - but only if caching is enabled
      if Tr8n::Config.enable_caching?
        existing_key.update_attributes(:verified_at => Time.now)
      end  
      existing_key
    end
    
    # for detailed tracking of all sources and caller stack - only needed for debugging - expensive
    track_source(tkey, options)  
    tkey  
  end

  # for backwards compatibility only - new keys will be marked as such
  def self.mark_as_admin(tkey, options)
    return if options[:skip_block_options]
    return unless Tr8n::Config.block_options[:admin]
    return if tkey.admin?
    tkey.update_attributes(:admin => true)
  end
  
  # for backwards compatibility only - if locale is provided update it in the key
  def self.update_default_locale(tkey, options)
    return if options[:skip_block_options]
    return unless tkey.locale.blank?
    key_locale = Tr8n::Config.block_options[:default_locale] || Tr8n::Config.default_locale
    tkey.update_attributes(:locale => key_locale)
  end

  # used to create associations between the translation keys and source
  # primarely used for the site map and only needs to be enabled 
  # for a short period of time on a single machine
  def self.track_source(tkey, options)
    return unless Tr8n::Config.enable_key_source_tracking?
    return if options[:source].blank?
    
    key_source = Tr8n::TranslationKeySource.find_or_create(tkey, Tr8n::TranslationSource.find_or_create(options[:source]))
    return unless Tr8n::Config.enable_key_caller_tracking?
    
    options[:caller] ||= caller
    options[:caller_key] = options[:caller].is_a?(Array) ? options[:caller].join(", ") : options[:caller].to_s
    options[:caller_key] = generate_key(options[:caller_key])
    key_source.update_details!(options)
  end
  
  def self.generate_key(label, desc = "")
    Digest::MD5.hexdigest("#{label};;;#{desc}")
  end

  def reset_key!
    # remove old key from cache
    Tr8n::Cache.delete("translation_key_#{key}")
    
    self.key = self.class.generate_key(label, description)
    save
  end
  
  def language
    @language ||= (locale ? Tr8n::Language.for(locale) : Tr8n::Config.default_language)
  end
  
  def tokenized_label
    @tokenized_label ||= Tr8n::TokenizedLabel.new(label)
  end
  
  # comments are left for a specific language
  def comments(language = Tr8n::Config.current_language)
    Tr8n::TranslationKeyComment.find(:all, :conditions => ["language_id = ? and translation_key_id = ?", language.id, self.id])
  end
  
  delegate :tokens, :tokens?, :to => :tokenized_label
  delegate :data_tokens, :data_tokens?, :to => :tokenized_label
  delegate :decoration_tokens, :decoration_tokens?, :to => :tokenized_label
  delegate :translation_tokens, :translation_tokens?, :to => :tokenized_label
  delegate :sanitized_label, :tokenless_label, :suggestion_tokens, :words, :to => :tokenized_label

  # returns only the tokens that depend on one or more rules of the language, if any defined for the language
  def language_rules_dependant_tokens(language = Tr8n::Config.current_language)
    toks = []
    included_token_hash = {}
    
    data_tokens.each do |token|
      next unless token.dependant?
      next if included_token_hash[token.name]
      
      token.language_rules.each do |rule_class|
        if language.rule_classes.include?(rule_class)
          toks << token
          included_token_hash[token.name] = token
        end
      end
    end

    toks << Tr8n::Config.viewing_user_token_for(label) if language.gender_rules?
    toks.uniq
  end

  # determines whether the key can have rules generated for the language
  def permutatable?(language = Tr8n::Config.current_language)
    language_rules_dependant_tokens(language).any?
  end

  def glossary
    @glossary ||= Tr8n::Glossary.find(:all, :conditions => ["keyword in (?)", words], :order => "keyword asc")
  end
  
  def glossary?
    not glossary.empty?
  end
  
  def lock_for(language)
    Tr8n::TranslationKeyLock.for(self, language)
  end
  
  def lock!(language = Tr8n::Config.current_language, translator = Tr8n::Config.current_translator)
    lock_for(language).lock!(translator)
  end

  def unlock!(language = Tr8n::Config.current_language, translator = Tr8n::Config.current_translator)
    lock_for(language).unlock!(translator)
  end

  def unlock_all!
    locks.each do |lock|
      lock.unlock!
    end
  end
  
  def locked?(language = Tr8n::Config.current_language)
    lock_for(language).locked?
  end

  def unlocked?(language = Tr8n::Config.current_language)
    not locked?(language)
  end
    
  def add_translation(label, rules = nil, language = Tr8n::Config.current_language, translator = Tr8n::Config.current_translator)
    raise Tr8n::Exception.new("The sentence contains dirty words") unless language.clean_sentence?(label)
    
    translation = Tr8n::Translation.create(:translation_key => self, :language => language, 
                                           :translator => translator, :label => label, :rules => rules)
    translation.vote!(translator, 1)
    translation
  end

  # returns all translations for the key, language and minimal rank
  def translations_for(language, rank = nil)
    conditions = ["translation_key_id = ? and language_id = ?", self.id, language.id]
    
    if rank
      conditions[0] << " and rank >= ?"
      conditions << rank
    end

    Tr8n::Translation.find(:all, :conditions => conditions, :order => "rank desc")
  end

  # used by the inline popup dialog, we don't want to show blocked translations
  def inline_translations_for(language)
    translations_for(language, -50)
  end
  
  # returns only the translations that meet the minimum rank
  def valid_translations_for(language)
    Tr8n::Cache.fetch("translations_#{language.locale}_#{self.key}") do
      translations_for(language, Tr8n::Config.translation_threshold)
    end
  end
  
  def translation_with_such_rules_exist?(language_translations, translator, rules_hash)
    language_translations.each do |translation|
      return true if translation.matches_rule_definitions?(rules_hash)
    end
    false
  end
  
  # {"actor"=>{"gender"=>"true"}, "target"=>{"gender"=>"true", "value"=>"true"}}
  def generate_rule_permutations(language, translator, dependencies)
    return if dependencies.blank?
    
    token_rules = {}
    
    dependency_mapping = {}
    
    # make into {"actor"=>[1], "target"=>[1], "target_@1"=>[2]}
    dependencies.each do |dependency, rule_types|
      rule_types.keys.each_with_index do |rule_type, index|
        token_key = dependency + "_@#{index}"
        dependency_mapping[token_key] = dependency
        
        rules = language.default_rules_for(rule_type)
        token_rules[token_key] = [] unless token_rules[token_key]
        token_rules[token_key] << rules
        token_rules[token_key].flatten!
      end
    end
    
    language_translations = translations_for(language)
    
    new_translations = []
    token_rules.combinations.each do |combination|
      rules = []
      rules_hash = {}
      
      combination.each do |token, language_rule|
        token_key = dependency_mapping[token]
        rules_hash[token_key] ||= [] 
        rules_hash[token_key] << language_rule.id.to_s
      end
      
      rules = rules_hash.collect{|token_key, rule_ids| {:token => token_key, :rule_id => rule_ids}}

      # if the user has previously create this particular combination, move on...
      next if translation_with_such_rules_exist?(language_translations, translator, rules_hash)
      new_translations << Tr8n::Translation.create(:translation_key => self, :language => language, :translator => translator, :label => sanitized_label, :rules => rules)
    end
    
    new_translations
  end

  def self.random
    find(:first, :offset => rand(count - 1))
  end

  # returns back grouped by context
  def find_all_valid_translations(translations)
    if translations.empty?
      return {:key => self.key, :label => self.label, :original => true}
    end
    
    # if the first translation does not depend on any of the context rules
    # use it... we don't care about the rest of the rules.
    if translations.first.rules_hash.blank?
      return {:key => self.key, :label => translations.first.label}
    end
    
    # build a context hash for every kind of context rules combinations
    # only the first one in the list should be used
    context_hash_matches = {}
    valid_translations = []
    translations.each do |translation|
      context_key = translation.rules_hash || ""
      next if context_hash_matches[context_key]
      context_hash_matches[context_key] = true
      if translation.rules_definitions
        valid_translations << {:label => translation.label, :context => translation.rules_definitions.clone}
      else
        valid_translations << {:label => translation.label}
      end
    end

    # always add the default one at the end, so if none of the rules matched, use the english one
    valid_translations << {:label => self.label} unless context_hash_matches[""]
    {:key => self.key, :labels => valid_translations}
  end

  def find_first_valid_translation(language, token_values)
    # find the first translation in the order of the rank that matches the rules
    valid_translations_for(language).each do |translation|
      return translation if translation.matches_rules?(token_values)
    end
    
    nil
  end

  # language fallback approach
  # each language can have a fallback language
  def find_first_valid_translation_for_language(language, token_values)
    translation = find_first_valid_translation(language, token_values)
    return [language, translation] if translation

    if Tr8n::Config.enable_fallback_languages?
      # recursevily go into the fallback language and look there
      # no need to go to the default language - there obviously won't be any translations for it
      # unless you really won't to keep the keys in the text, and translate the default language
      if language.fallback_language and not language.fallback_language.default?
        return find_first_valid_translation_for_language(language.fallback_language, token_values)
      end
    end  
    
    [language, nil]
  end
  
  # translator fallback approach
  # each translator can have a fallback language, which may have a fallback language
  def find_first_valid_translation_for_translator(language, translator, token_values)
    translation = find_first_valid_translation(language, token_values)
    return [language, translation] if translation
    
    if translator.fallback_language and not translator.fallback_language.default?
      return find_first_valid_translation_for_language(translator.fallback_language, token_values)
    end

    [language, nil]
  end
  
  def translate(language = Tr8n::Config.current_language, token_values = {}, options = {})
    return find_all_valid_translations(valid_translations_for(language)) if options[:api]
    
    if Tr8n::Config.disabled? or language.default?
      return substitute_tokens(label, token_values, options.merge(:fallback => false), language)
    end
    
    if Tr8n::Config.enable_translator_language? and Tr8n::Config.current_user_is_translator?
      translation_language, translation = find_first_valid_translation_for_translator(language, Tr8n::Config.current_translator, token_values)
    else  
      translation_language, translation = find_first_valid_translation_for_language(language, token_values)
    end
    
    # if you want to present the label in it's sanitized form - for the phrase list
    if options[:default_language] 
      return decorate_translation(language, sanitized_label, translation != nil, options)
    end
    
    if translation
      translated_label = substitute_tokens(translation.label, token_values, options, language)
      return decorate_translation(language, translated_label, translation != nil, options.merge(:fallback => (translation_language != language)))
    end

    # no translation found  
    translated_label = substitute_tokens(label, token_values, options, Tr8n::Config.default_language)
    decorate_translation(language, translated_label, translation != nil, options)  
  end

  ###############################################################
  ## Substitution and Decoration Related Stuff
  ###############################################################

  # this is done when the translations engine is disabled
  def self.substitute_tokens(label, tokens, options = {}, language = Tr8n::Config.default_language)
    return label.to_s if options[:skip_substitution] 
    Tr8n::TranslationKey.new(:label => label.to_s).substitute_tokens(label.to_s, tokens, options, language)
  end

  def substitute_tokens(translated_label, token_values, options = {}, language = Tr8n::Config.current_language)
    processed_label = translated_label.to_s.clone

    # substitute all data tokens
    Tr8n::TokenizedLabel.new(processed_label).data_tokens.each do |token|
      next unless tokenized_label.allowed_token?(token)
      processed_label = token.substitute(processed_label, token_values, options, language) 
    end

    # substitute all decoration tokens
    Tr8n::TokenizedLabel.new(processed_label).decoration_tokens.each do |token|
      next unless tokenized_label.allowed_token?(token)
      processed_label = token.substitute(processed_label, token_values, options, language) 
    end
    
    processed_label
  end
  
  def default_decoration(language = Tr8n::Config.current_language, options = {})
    return label if Tr8n::Config.current_user_is_guest?
    return label unless Tr8n::Config.current_user_is_translator?
    return label if locked?(language)

    classes = ['tr8n_translatable']

    if valid_translations_for(language).any?
      classes << 'tr8n_translated'
    else
      classes << 'tr8n_not_translated'
    end

    html = "<span class='#{classes.join(' ')}' translation_key_id='#{id}'>"
    html << label
    html << "</span>"
    html    
  end
  
  def decorate_translation(language, translated_label, translated = true, options = {})
    return translated_label if options[:skip_decorations]
    return translated_label if Tr8n::Config.current_user_is_guest?
    return translated_label unless Tr8n::Config.current_user_is_translator?
    return translated_label unless Tr8n::Config.current_translator.enable_inline_translations?
    return translated_label if locked?(language)
    return translated_label if self.language == language

    classes = ['tr8n_translatable']
    
    if language.default?
      classes << 'tr8n_not_translated'
    elsif options[:fallback] 
      classes << 'tr8n_fallback'
    else
      classes << (translated ? 'tr8n_translated' : 'tr8n_not_translated')
    end  

    html = "<span class='#{classes.join(' ')}' translation_key_id='#{id}'>"
    html << translated_label
    html << "</span>"
    html
  end
      
  def verify!(time = Time.now)
    update_attributes(:verified_at => time)
  end
      
  def update_translation_count!
    update_attributes(:translation_count => Tr8n::Translation.count(:conditions => ["translation_key_id = ?", self.id]))
  end
      
  def after_save
    Tr8n::Cache.delete("translation_key_#{key}")
  end

  def after_destroy
    Tr8n::Cache.delete("translation_key_#{key}")
  end

  ###############################################################
  ## Search Related Stuff
  ###############################################################
  
  def self.filter_phrase_type_options
    [["all", "any"], 
     ["without translations", "without"], 
     ["with translations", "with"]] 
  end
  
  def self.filter_phrase_status_options
     [["any", "any"],
      ["pending approval", "pending"], 
      ["approved", "approved"]]
  end
  
  def self.search_conditions_for(params)
    conditions = ["tr8n_translation_keys.locale <> ?", Tr8n::Config.current_language.locale]
    
    if Tr8n::Config.enable_caching?
      conditions[0] << "verified_at is not null"
    end  
    
    unless params[:search].blank?
      conditions[0] << " and " unless conditions[0].blank?
      conditions[0] << "(tr8n_translation_keys.label like ? or tr8n_translation_keys.description like ?)" 
      conditions << "%#{params[:search]}%"
      conditions << "%#{params[:search]}%"  
    end

    # for with and approved, allow user to specify the kinds
    if params[:phrase_type] == "with"
      conditions[0] << " and " unless conditions[0].blank?
      conditions[0] << "tr8n_translation_keys.id in (select tr8n_translations.translation_key_id from tr8n_translations where tr8n_translations.language_id = ?) "
      conditions << Tr8n::Config.current_language.id
      
      # if approved, ensure that translation key is locked
      if params[:phrase_status] == "approved" 
        conditions[0] << " and " unless conditions[0].blank?
        conditions[0] << "tr8n_translation_keys.id in (select tr8n_translation_key_locks.translation_key_id from tr8n_translation_key_locks where tr8n_translation_key_locks.language_id = ? and tr8n_translation_key_locks.locked = ?) "
        conditions << Tr8n::Config.current_language.id
        conditions << true
      
        # if approved, ensure that translation key does not have a lock or unlocked
      elsif params[:phrase_status] == "pending" 
        conditions[0] << " and " unless conditions[0].blank?
        conditions[0] << "tr8n_translation_keys.id not in (select tr8n_translation_key_locks.translation_key_id from tr8n_translation_key_locks where tr8n_translation_key_locks.language_id = ? and tr8n_translation_key_locks.locked = ?) "
        conditions << Tr8n::Config.current_language.id
        conditions << true
      end
            
    elsif params[:phrase_type] == "without"
      conditions[0] << " and " unless conditions[0].blank?
      conditions[0] << "tr8n_translation_keys.id not in (select tr8n_translations.translation_key_id from tr8n_translations where tr8n_translations.language_id = ?)"
      conditions << Tr8n::Config.current_language.id
    end
    
    conditions
  end    
end
