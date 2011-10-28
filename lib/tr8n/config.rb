#--
# Copyright (c) 2010-2011 Michael Berkovich
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

require 'json'

module Tr8n
  class Config

    #########################################################
    # Basic Stuff
  
    # initializes language, user and translator
    # the variables are kept in a thread safe form throughout the request
    def self.init(site_current_locale, site_current_user = nil, site_current_source = nil)
      Thread.current[:tr8n_current_language]   = Tr8n::Language.for(site_current_locale) || default_language
      Thread.current[:tr8n_current_user]       = site_current_user
      Thread.current[:tr8n_current_translator] = Tr8n::Translator.for(site_current_user)
      Thread.current[:tr8n_current_source]     = site_current_source
      Thread.current[:tr8n_block_options]      = {}
    end
  
    def self.current_user
      Thread.current[:tr8n_current_user]
    end

    def self.current_source
      Thread.current[:tr8n_current_source]
    end
  
    def self.current_language
      Thread.current[:tr8n_current_language] ||= default_language
    end
  
    def self.current_user_is_translator?
      Thread.current[:tr8n_current_translator] != nil
    end
  
    def self.block_options
      Thread.current[:tr8n_block_options] ||= {}
    end
  
    # when this method is called, we create the translator record right away
    # and from this point on, will track the user
    # this can happen any time user tries to translate something or enables inline translations
    def self.current_translator
      Thread.current[:tr8n_current_translator] ||= Tr8n::Translator.register
    end
  
    def self.default_language
      return Tr8n::Language.new(:locale => default_locale) if disabled?
      @default_language ||= Tr8n::Language.for(default_locale) || Tr8n::Language.new(:locale => default_locale)
    end
    
    # only one allowed per system
    def self.system_translator
      @system_translator ||= Tr8n::Translator.where(:level => system_level).first || Tr8n::Translator.create(:user_id => 0, :level => system_level)
    end

    # only one allowed per application
    def self.application_translator_for(user)
      Tr8n::Translator.where(:user_id => user.id, :level => application_level).first || Tr8n::Translator.create(:user_id => user.id, :level => application_level)
    end
  
    def self.reset!
      # thread based variables
      Thread.current[:tr8n_current_language]  = nil
      Thread.current[:tr8n_current_user] = nil
      Thread.current[:tr8n_current_translator] = nil
      Thread.current[:tr8n_block_options]  = nil
      Thread.current[:tr8n_current_source] = nil
    end

    def self.models
      [ 
         Tr8n::LanguageRule, Tr8n::LanguageUser, Tr8n::Language, Tr8n::LanguageMetric,
         Tr8n::LanguageCase, Tr8n::LanguageCaseValueMap, Tr8n::LanguageCaseRule,
         Tr8n::TranslationKey, Tr8n::TranslationKeySource, Tr8n::TranslationKeyComment, Tr8n::TranslationKeyLock,
         Tr8n::TranslationSource, Tr8n::TranslationDomain, Tr8n::TranslationSourceLanguage,
         Tr8n::Translation, Tr8n::TranslationVote,
         Tr8n::Translator, Tr8n::TranslatorLog, Tr8n::TranslatorMetric, 
         Tr8n::TranslatorFollowing, Tr8n::TranslatorReport, 
         Tr8n::LanguageForumTopic, Tr8n::LanguageForumMessage, Tr8n::LanguageForumAbuseReport,
         Tr8n::Glossary, Tr8n::IpLocation
      ]    
    end

    # will clean all tables and initialize default values
    # never ever do it on live !!!
    def self.reset_all!
      puts "Resetting tr8n tables..."
      models.each do |cls|
        puts ">> Resetting #{cls.name}..."
        cls.delete_all
      end
      puts "Done."

      init_default_languages
      init_glossary
    
      puts "Done."
    end

    def self.init_default_languages
      puts "Initializing default languages..."
      default_languages.each do |locale, info|
        puts ">> Initializing #{info[:english_name]}..."
        lang = Tr8n::Language.find_or_create(locale, info[:english_name])
        info[:right_to_left] = false if info[:right_to_left].nil?
        fallback_key = info.delete(:fallback_key)
        lang.update_attributes(info)
        lang.reset!
      end
      puts "Created #{default_languages.size} languages."    
    end

    def self.init_glossary
      puts "Initializing default glossary..."
      default_glossary.each do |keyword, description|
        Tr8n::Glossary.create(:keyword => keyword, :description => description)
      end    
    end
  
    def self.root
      Rails.root
    end
  
    def self.env
      Rails.env
    end
  
    # json support
    def self.load_json(file_path)
      json = JSON.parse(File.read("#{root}#{file_path}"))
      return HashWithIndifferentAccess.new(json) if json.is_a?(Hash)
      map = {"map" => json}
      HashWithIndifferentAccess.new(map)[:map]
    end

    def self.load_yml(file_path, for_env = env)
      yml = YAML.load_file("#{root}#{file_path}")
      yml = yml[for_env] unless for_env.nil?
      HashWithIndifferentAccess.new(yml)
    end
  
    def self.dump_config
      save_to_yaml("config.yaml", config)
    end
  
    def self.config
      @config ||= load_yml("/config/tr8n/config.yml")
    end

    def self.default_languages
      @default_languages ||= load_yml("/config/tr8n/site/default_languages.yml", nil)
    end

    def self.default_decoration_tokens
      @default_decoration_tokens ||= load_yml("/config/tr8n/tokens/decorations.yml", nil)
    end

    def self.default_data_tokens
      @default_data_tokens ||= load_yml("/config/tr8n/tokens/data.yml", nil)
    end

    def self.default_glossary
      @default_glossary ||= load_yml("/config/tr8n/site/default_glossary.yml", nil)
    end

    def self.features
      @features ||= begin
        defs = load_yml("/config/tr8n/site/features.yml")
        feats = []
        defs[:enabled_features].each do |key|
          defs[key][:key] = key
          feats << defs[key] 
        end
        feats
      end
    end
  
    def self.enabled?
      config[:enable_tr8n] 
    end
  
    def self.disabled?
      not enabled?
    end

    def self.enable_software_keyboard?
      config[:enable_software_keyboard]
    end

    def self.enable_keyboard_shortcuts?
      config[:enable_keyboard_shortcuts]
    end

    def self.default_shortcuts
      @default_shortcuts ||= load_yml("/config/tr8n/site/shortcuts.yml", nil)
    end

    def self.enable_inline_translations?
      config[:enable_inline_translations]
    end
  
    def self.enable_language_cases?
      config[:enable_language_cases]
    end
  
    def self.enable_key_source_tracking?
      config[:enable_key_source_tracking]
    end

    def self.enable_key_caller_tracking?
      config[:enable_key_caller_tracking]
    end

    def self.enable_google_suggestions?
      config[:enable_google_suggestions]
    end

    def self.enable_glossary_hints?
      config[:enable_glossary_hints]
    end

    def self.enable_dictionary_lookup?
      config[:enable_dictionary_lookup]
    end

    def self.enable_language_flags?
      config[:enable_language_flags]
    end

    def self.enable_language_stats?
      config[:enable_language_stats]
    end

    def self.open_registration_mode?
      config[:open_registration_mode]
    end
  
    def self.enable_fallback_languages?
      config[:enable_fallback_languages]
    end

    def self.enable_translator_language?
      config[:enable_translator_language]
    end

    def self.enable_admin_translations?
      config[:enable_admin_translations]
    end

    def self.enable_admin_inline_mode?
      config[:enable_admin_inline_mode]
    end

    def self.enable_country_tracking?
      config[:enable_country_tracking]
    end
  
    #########################################################
    # Config Sections
    def self.caching
      config[:caching]
    end

    def self.logger
      config[:logger]
    end
  
    def self.site_info
      config[:site_info]
    end

    def self.rules_engine
      config[:rules_engine]
    end

    def self.localization
      config[:localization]
    end

    def self.api
      config[:api]
    end

    def self.synchronization
      config[:synchronization]
    end

    #########################################################
    # Caching
    def self.enable_caching?
      caching[:enabled]
    end

    def self.cache_adapter
      caching[:adapter]
    end

    def self.cache_store
      caching[:store]
    end

    def self.cache_version
      caching[:version]
    end
    #########################################################

    #########################################################
    # Logger
    def self.enable_logger?
      logger[:enabled]
    end

    def self.log_path
      logger[:log_path]
    end

    def self.enable_paranoia_mode?
      logger[:enable_paranoia_mode]
    end
    #########################################################
  
    #########################################################
    # Site Info
    def self.site_title
      site_info[:title] 
    end

    def self.splash_screen
      site_info[:splash_screen]  
    end
  
    def self.default_locale
      return block_options[:default_locale] if block_options[:default_locale]
      site_info[:default_locale]
    end

    def self.multiple_base_languages?
      'en-US' == default_locale
    end

    def self.default_url
      site_info[:default_url]
    end

    def self.current_locale_method
      site_info[:current_locale_method]
    end

    def self.enable_tr8n_method
      site_info[:enable_tr8n_method]
    end
  
    def self.sitemap_sections
      @sitemap_sections ||= load_json(site_info[:sitemap_path])
    end

    def self.effects_library_path
      site_info[:effects_library_path]
    end

    def self.enable_effects?
      site_info[:enable_effects]
    end

    def self.tr8n_helpers
      return [] unless site_info[:tr8n_helpers]
      @tr8n_helpers ||= site_info[:tr8n_helpers].collect{|helper| helper.to_sym}
    end

    def self.admin_helpers
      return [] unless site_info[:admin_helpers]
      @admin_helpers ||= site_info[:admin_helpers].collect{|helper| helper.to_sym}
    end
  
    def self.skip_before_filters
      return [] unless site_info[:skip_before_filters]
      @skip_before_filters ||= site_info[:skip_before_filters].collect{|filter| filter.to_sym}
    end

    def self.before_filters
      return [] unless site_info[:before_filters]
      @before_filters ||= site_info[:before_filters].collect{|filter| filter.to_sym}
    end

    def self.after_filters
      return [] unless site_info[:after_filters]
      @after_filters ||= site_info[:after_filters].collect{|filter| filter.to_sym}
    end

    #########################################################
    # site user info
    # The following methods could be overloaded in the initializer
    #########################################################
    def self.site_user_info
      site_info[:user_info]
    end

    def self.current_user_method
      site_user_info[:current_user_method]
    end

    def self.site_user_info_enabled?
      site_user_info[:enabled].nil? ? true : site_user_info[:enabled]
    end

    def self.site_user_info_disabled?
      !site_user_info_enabled?
    end
  
    def self.user_class_name
      return site_user_info[:class_name] if site_user_info_enabled?
      "Tr8n::Translator"  
    end

    def self.user_class
      user_class_name.constantize
    end

    def self.user_id(user)
      return 0 unless user
      user.send(site_user_info[:methods][:id])
    rescue Exception => ex
      Tr8n::Logger.error("Failed to fetch user id: #{ex.to_s}")
      0
    end

    def self.user_name(user)
      return "Unknown user" unless user
      user.send(site_user_info[:methods][:name])
    rescue Exception => ex
      Tr8n::Logger.error("Failed to fetch #{user_class_name} name: #{ex.to_s}")
      "Invalid user"
    end

    def self.user_gender(user)
      return "unknown" unless user
      user.send(site_user_info[:methods][:gender])
    rescue Exception => ex
      Tr8n::Logger.error("Failed to fetch #{user_class_name} name: #{ex.to_s}")
      "unknown"
    end

    def self.user_mugshot(user)
      return silhouette_image unless user
      user.send(site_user_info[:methods][:mugshot])
    rescue Exception => ex
      Tr8n::Logger.error("Failed to fetch #{user_class_name} image: #{ex.to_s}")
      silhouette_image
    end

    def self.user_link(user)
      return "/tr8n" unless user
      user.send(site_user_info[:methods][:link])
    rescue Exception => ex
      Tr8n::Logger.error("Failed to fetch #{user_class_name} link: #{ex.to_s}")
      "/tr8n"
    end

    def self.user_locale(user)
      return default_locale unless user
      user.send(site_user_info[:methods][:locale])
    rescue Exception => ex
      Tr8n::Logger.error("Failed to fetch #{user_class_name} locale: #{ex.to_s}")
      default_locale
    end

    def self.admin_user?(user = Tr8n::Config.current_user)
      return false unless user
      user.send(site_user_info[:methods][:admin])
    rescue Exception => ex
      Tr8n::Logger.error("Failed to fetch #{user_class_name} admin flag: #{ex.to_s}")
      false
    end

    def self.current_user_is_admin?
      admin_user?
    end
  
    def self.guest_user?(user = Tr8n::Config.current_user)
      return true unless user
      user.send(site_user_info[:methods][:guest])
    rescue Exception => ex
      Tr8n::Logger.error("Failed to fetch #{user_class_name} guest flag: #{ex.to_s}")
      true
    end
  
    def self.current_user_is_guest?
      guest_user?
    end
  
    def self.silhouette_image
      "/assets/tr8n/photo_silhouette.gif"
    end

    def self.system_image
      "/assets/tr8n/photo_system.gif"
    end
  
    #########################################################
    # rules engine
  
    def self.language_rule_classes
      @language_rule_classes ||= rules_engine[:language_rule_classes].collect{|lrc| lrc.constantize}
    end

    def self.language_rule_dependencies
      @language_rule_dependencies ||= begin
        depts = {}
        language_rule_classes.each do |cls|
          if depts[cls.dependency]
            raise Tr8n::Exception.new("The same dependency key #{cls.dependency} has been registered for multiple rules. This is not allowed.")
          end  
          depts[cls.dependency] = cls
        end
        depts
      end
    end

    def self.universal_language_rules
      @universal_language_rules ||= begin
        urs = []
        language_rule_classes.each do |cls|
          next unless cls.suffixes.is_a?(String)
          urs << cls if cls.suffixes == "*"
        end
        urs
      end
    end

    def self.language_rule_suffixes
      @language_rule_suffixes ||= begin
        sfx = {}
        language_rule_classes.each do |cls|
          next unless cls.suffixes.is_a?(Array)
          cls.suffixes.each do |suffix|
            if suffix.index("_")
              raise Tr8n::Exception.new("Incorrect rule suffix: #{suffix}. Suffix may not have '_' in it.")
            end
            sfx[suffix] ||= []
            sfx[suffix] << cls
          end
        end
        sfx
      end
    end

    def self.language_rules_for_suffix(suffix)
      suffix_rules = language_rule_suffixes[suffix] || []
      suffix_rules + universal_language_rules
    end

    def self.allow_nil_token_values?
      rules_engine[:allow_nil_token_values]
    end
  
    def self.data_token_classes
      @data_token_classes ||= rules_engine[:data_token_classes].collect{|tc| tc.constantize}
    end

    def self.decoration_token_classes
      @decoration_token_classes ||= rules_engine[:decoration_token_classes].collect{|tc| tc.constantize}
    end
  
    def self.viewing_user_token_for(label)
      Tr8n::Tokens::DataToken.new(label, "{#{rules_engine[:viewing_user_token]}:gender}")
    end

    def self.translation_threshold
      rules_engine[:translation_threshold]
    end

    def self.default_rank_styles
      @default_rank_styles ||= begin
        styles = {}
        rules_engine[:translation_rank_styles].each do |key, value|
          range = Range.new(*(key.to_s.split("..").map{|v| v.to_i}))
          styles[range] = value
        end
        styles  
      end
    end

    # get rules for specified locale, or get default language rules
    def self.load_default_rules(rules_type, locale = default_locale)
      @default_rules ||= {}
      @default_rules[rules_type] ||= load_yml("/config/tr8n/rules/default_#{rules_type}_rules.yml", nil)
      rules_for_locale = @default_rules[rules_type][locale.to_s]
    
      return rules_for_locale.values unless rules_for_locale.nil?
      return [] if @default_rules[rules_type][default_locale].nil?
      @default_rules[rules_type][default_locale].values
    end

    def self.default_gender_rules(locale = default_locale)
      load_default_rules("gender", locale)
    end

    def self.default_gender_list_rules(locale = default_locale)
      load_default_rules("gender_list", locale)
    end

    def self.default_list_rules(locale = default_locale)
      load_default_rules("list", locale)
    end

    def self.default_numeric_rules(locale = default_locale)
      load_default_rules("numeric", locale)
    end

    def self.default_date_rules(locale = default_locale)
      load_default_rules("date", locale)
    end

    def self.default_value_rules(locale = default_locale)
      load_default_rules("value", locale)
    end

    def self.default_language_cases_for(locale = default_locale)
      @default_cases ||= load_yml("/config/tr8n/rules/default_language_cases.yml", nil)
      return [] unless @default_cases[locale.to_s]
      @default_cases[locale.to_s].values
    end

    #########################################################
    # localization
    #########################################################
  
    def self.strftime_symbol_to_token(symbol)
      {
        "%a" => "{short_week_day_name}",
        "%A" => "{week_day_name}",
        "%b" => "{short_month_name}",
        "%B" => "{month_name}",
        "%p" => "{am_pm}",
        "%d" => "{days}",
        "%e" => "{day_of_month}", 
        "%j" => "{year_days}",
        "%m" => "{months}",
        "%W" => "{week_num}",
        "%w" => "{week_days}",
        "%y" => "{short_years}",
        "%Y" => "{years}",
        "%l" => "{trimed_hour}", 
        "%H" => "{full_hours}", 
        "%I" => "{short_hours}", 
        "%M" => "{minutes}", 
        "%S" => "{seconds}", 
        "%s" => "{since_epoch}"
      }[symbol]
    end
  
    def self.default_day_names
      localization[:default_day_names]
    end

    def self.default_abbr_day_names
      localization[:default_abbr_day_names]
    end

    def self.default_month_names
      localization[:default_month_names]
    end

    def self.default_abbr_month_names
      localization[:default_abbr_month_names]
    end
  
    def self.default_date_formats
      localization[:custom_date_formats]
    end

    #########################################################
    # Translator Roles and Levels
    #########################################################
    def self.translator_roles
      config[:translator_roles]
    end

    def self.translator_levels
      @translator_levels ||= begin
        levels = HashWithIndifferentAccess.new
        translator_roles.each do |key, val|
          levels[val] = key
        end
        levels
      end
    end

    def self.manager_level
      1000
    end

    def self.admin_level
      10000
    end

    def self.application_level
      100000
    end

    def self.system_level
      1000000
    end

    def self.default_translation_key_level
      config[:default_translation_key_level] || 0
    end
  
    #########################################################
    # API
    #########################################################
    def self.enable_api?
      api[:enabled]
    end

    def self.enable_client_sdk?
      config[:enable_client_sdk]
    end

    #########################################################
    # Sync Process
    #########################################################
    def self.synchronization_batch_size
      synchronization[:batch_size]
    end
    
    def self.synchronization_server
      synchronization[:server]
    end
    
    def self.synchronization_key
      synchronization[:key]
    end

    def self.synchronization_secret
      synchronization[:secret]
    end

    def self.synchronization_create_rules?
      synchronization[:create_rules]
    end

    def self.synchronization_all_languages?
      synchronization[:all_languages]
    end
  end
end