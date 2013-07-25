#--
# Copyright (c) 2010-2013 Michael Berkovich, tr8nhub.com
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
    def self.init(application, language, user = nil, source = nil, component = nil)
      set_application(application)
      set_language(language)
      set_current_user(user)
      set_current_translator(Tr8n::Translator.for(user))
      set_source(Tr8n::TranslationSource.find_or_create(source || "undefined"))

      # register source with component
      unless component.nil?
        set_current_component(component)
        component.register_source(current_source)
      else
        set_current_component(nil)
      end

      # register the total metric for the current source and language
      current_source.total_metric 

      Thread.current[:tr8n_block_options]      = []
    end
  
    def self.current_user
      Thread.current[:tr8n_user]
    end

    def self.set_current_user(user)
      Thread.current[:tr8n_user] = user
    end

    def self.current_application
      Thread.current[:tr8n_application]
    end  

    def self.set_application(application)
      application = Tr8n::Application.for(application) if application.is_a?(String)
      Thread.current[:tr8n_application] = application
    end

    def self.current_source
      Thread.current[:tr8n_source]
    end
  
    def self.set_source(source)
      source = Tr8n::TranslationSource.find_or_create(source) if source.is_a?(String)
      Thread.current[:tr8n_source] = source
    end

    def self.current_component
      Thread.current[:tr8n_component]
    end  

    def self.set_current_component(component)
      component = Tr8n::Component.find_or_create(component) if component.is_a?(String)
      Thread.current[:tr8n_component] = component
    end

    def self.current_language
      Thread.current[:tr8n_language] ||= default_language
    end
  
    def self.set_language(language)
      language = Tr8n::Language.for(language) if language.is_a?(String)
      Thread.current[:tr8n_language] = language
    end

    def self.current_user_is_translator?
      Thread.current[:tr8n_translator] != nil
    end
  
    def self.current_user_is_authorized_to_view_component?(component = current_component)
      return true if component.nil? # no component present, so be it

      component = Tr8n::Component.find_by_key(component.to_s) if component.is_a?(Symbol)

      return true unless component.restricted?
      return false unless Tr8n::Config.current_user_is_translator?
      return true if component.translator_authorized?

      if Tr8n::Config.current_user_is_admin?
        Tr8n::ComponentTranslator.find_or_create(component, Tr8n::Config.current_translator)
        return true
      end
      
      false
    end

    def self.current_user_is_authorized_to_view_language?(component = current_component, language = current_language)
      return true if component.nil? # no component present, so be it

      component = Tr8n::Component.find_by_key(component.to_s) if component.is_a?(Symbol)

      if Tr8n::Config.current_user_is_translator? 
        return true if component.translators.include?(Tr8n::Config.current_translator)
      end

      component.component_languages.each do |cl|
        return cl.live? if cl.language_id == language.id 
      end
      
      true
    end

    def self.current_translator
      Thread.current[:tr8n_translator]
    end
  
    def self.set_current_translator(translator)
      Thread.current[:tr8n_translator]  = translator
    end

    def self.default_language
      return Tr8n::Language.new(:locale => default_locale) if disabled?
      @default_language ||= Tr8n::Language.for(default_locale) || Tr8n::Language.new(:locale => default_locale)
    end
    
    # only one allowed per system
    def self.system_translator
      @system_translator ||= Tr8n::Translator.where(:level => system_level).first || Tr8n::Translator.create(:user_id => 0, :level => system_level)
    end
  
    def self.reset!
      # thread based variables
      Thread.current[:tr8n_application] = nil 
      Thread.current[:tr8n_language]  = nil
      Thread.current[:tr8n_user] = nil
      Thread.current[:tr8n_translator] = nil
      Thread.current[:tr8n_block_options]  = nil
      Thread.current[:tr8n_source] = nil
      Thread.current[:tr8n_component] = nil
      Thread.current[:tr8n_remote_application] = nil 
    end

    def self.models
      [ 
         Tr8n::LanguageRule, Tr8n::LanguageUser, Tr8n::Language, Tr8n::LanguageMetric,
         Tr8n::LanguageCase, Tr8n::LanguageCaseValueMap, Tr8n::LanguageCaseRule,
         Tr8n::TranslationKey, Tr8n::RelationshipKey, Tr8n::ConfigurationKey, 
         Tr8n::TranslationKeySource, Tr8n::TranslationKeyComment, Tr8n::TranslationKeyLock,
         Tr8n::TranslationSource, Tr8n::TranslationDomain, Tr8n::TranslationSourceLanguage, 
         Tr8n::Translation, Tr8n::TranslationVote, Tr8n::TranslationSourceMetric,
         Tr8n::Translator, Tr8n::TranslatorLog, Tr8n::TranslatorMetric, 
         Tr8n::TranslatorFollowing, Tr8n::TranslatorReport, 
         Tr8n::LanguageForumTopic, Tr8n::LanguageForumMessage,
         Tr8n::Glossary, Tr8n::IpLocation, Tr8n::SyncLog, Tr8n::Application, 
         Tr8n::Component, Tr8n::ComponentSource, Tr8n::ComponentTranslator, Tr8n::ComponentLanguage,
         Tr8n::Notification,
         Tr8n::Oauth::OauthToken
      ]    
    end

    def self.guid
      (0..16).to_a.map{|a| rand(16).to_s(16)}.join
    end

    def self.default_application
       @default_application = Tr8n::Application.find_by_key("default") || init_application
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

      init_languages
      init_glossary
      init_application

      puts "Done."
    end

    def self.init_application
      puts "Initializing default application..."

      app = Tr8n::Application.find_by_key("default") || Tr8n::Application.create(:key => "default", :name => site_title, :description => "Automatically created during initialization")

      # setup for base url
      uri = URI.parse(base_url)
      domain = Tr8n::TranslationDomain.find_by_name(uri.host) || Tr8n::TranslationDomain.create(:name => uri.host)
      domain.application = app
      domain.save

      # setup for development environment
      domain = Tr8n::TranslationDomain.find_by_name("localhost") || Tr8n::TranslationDomain.create(:name => "localhost")
      domain.application = app
      domain.save

      ["en-US", "ru", "fr", "es"].each do |locale|
        app.add_language(Tr8n::Language.for(locale))
      end

      app
    end

    def self.init_languages
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
      yml = yml['defaults'].rmerge(yml[for_env] || {}) unless for_env.nil?
      HashWithIndifferentAccess.new(yml)
    end
  
    def self.dump_config
      save_to_yaml("config.yml.dump", config)
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
  
    def self.enable_key_caller_tracking?
      config[:enable_key_caller_tracking]
    end

    def self.enable_google_suggestions?
      config[:enable_google_suggestions]
    end

    def self.google_api_key
      config[:google_api_key]
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

    def self.enable_registration_disclaimer?
      config[:enable_registration_disclaimer]
    end

    def self.registration_disclaimer_path
      config[:registration_disclaimer_path] || "/tr8n/common/terms_of_service"
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
  
    def self.enable_relationships?
      config[:enable_relationships]
    end

    def self.enable_translator_tabs?
      config[:enable_translator_tabs]
    end

    def self.offline_task_method
      config[:offline_task_method]
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
    #########################################################
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
    #########################################################
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
    #########################################################
    def self.site_title
      site_info[:title] 
    end

    def self.contact_email
      site_info[:contact_email]
    end

    def self.splash_screen
      site_info[:splash_screen]  
    end
  
    def self.default_locale
      return block_options[:default_locale] if block_options[:default_locale]
      site_info[:default_locale]
    end

    def self.default_admin_locale
      return block_options[:default_admin_locale] if block_options[:default_admin_locale]
      site_info[:default_admin_locale]
    end

    def self.multiple_base_languages?
      self.default_admin_locale == default_locale
    end

    def self.base_url
      site_info[:base_url]
    end

    def self.default_url
      site_info[:default_url]
    end

    def self.login_url
      site_info[:login_url]
    end

    def self.current_locale_method
      site_info[:current_locale_method]
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
  
    def self.user_class_name
      site_user_info[:class_name]
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

    def self.user_email(user)
      user.send(site_user_info[:methods][:email])
    rescue Exception => ex
      Tr8n::Logger.error("Failed to fetch #{user_class_name} name: #{ex.to_s}")
      "Unknown user"
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

    def self.current_user_is_manager?
      return false unless current_user_is_translator?
      return true if current_user_is_admin?
      current_translator.manager?
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
    # RULES ENGINE
    #########################################################
    
    def self.language_rule_classes
      @language_rule_classes ||= rules_engine[:language_rule_classes].collect{|lrc| lrc.constantize}
    end

    def self.language_rule_dependencies
      @language_rule_dependencies ||= begin
        depts = HashWithIndifferentAccess.new
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

    def self.token_classes(category = :data)
      rules_engine["#{category}_token_classes".to_sym].collect{|tc| tc.constantize}
    end

    # deprecated
    def self.data_token_classes
      @data_token_classes ||= rules_engine[:data_token_classes].collect{|tc| tc.constantize}
    end

    # deprecated
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
    
      return rules_for_locale unless rules_for_locale.nil?
      return {} if @default_rules[rules_type][default_locale].nil?
      @default_rules[rules_type][default_locale]
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

    def self.country_from_ip(remote_ip)
      default_country = config["default_country"] || "USA"
      return default_country unless Tr8n::IpAddress.routable?(remote_ip)
      location = Tr8n::IpLocation.find_by_ip(remote_ip)
      (location and location.cntry) ? location.cntry : default_country
    end

    #########################################################
    # LOCALIZATION
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

    def self.application_level
      100000
    end

    def self.system_level
      1000000
    end

    def self.admin_level
      100000000
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

    def self.enable_browser_cache?
      config[:enable_browser_cache]
    end

    def self.enable_tml?
      config[:enable_tml]
    end

    def self.default_client_interval
      5000
    end

    def self.api_skip_before_filters
      return [] unless api[:skip_before_filters]
      @api_skip_before_filters ||= api[:skip_before_filters].collect{|filter| filter.to_sym}
    end

    def self.api_before_filters
      return [] unless api[:before_filters]
      @api_before_filters ||= api[:before_filters].collect{|filter| filter.to_sym}
    end

    def self.api_after_filters
      return [] unless api[:after_filters]
      @api_after_filters ||= api[:after_filters].collect{|filter| filter.to_sym}
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

    def self.synchronization_all_languages?
      synchronization[:all_languages]
    end

    def self.synchronization_push_enabled?
      synchronization[:enable_push]
    end
    
    def self.synchronization_push_servers
      synchronization[:push_servers]
    end
    
    #########################################################
    # Sharing
    #########################################################
    def self.remote_application
      Thread.current[:tr8n_remote_application]
    end  

    def self.set_remote_application(application)
      application = Tr8n::Application.for(application) if application.is_a?(String)
      Thread.current[:tr8n_remote_application] = application
    end

    def self.signed_request_name
      "tr8n_#{remote_application.key}"
    end

    def self.signed_request_body
      params = {
        'locale'  => current_language.locale,
      }

      if current_translator
        request_token = remote_application.find_or_create_request_token(current_translator)
        params.merge!({
          'code' => request_token.token,
          'translator' => {
            'id'      => current_translator.id,
            'inline'  => current_translator.inline_mode,
            'manager' => current_translator.manager?,
          }
        })
      end

      sign_and_encode_params(params, remote_application.secret)
    end

    def self.sign_and_encode_params(params, secret)  
      payload = Base64.encode64(params.merge(:algorithm => 'HMAC-SHA256', :ts => Time.now.to_i).to_json)
      sig = OpenSSL::HMAC.digest('sha256', secret, payload)
      encoded_sig = Base64.encode64(sig)
      data = URI::encode("#{encoded_sig}.#{payload}")
      pp :encoded_sig, encoded_sig
      data
    end

    def self.decode_and_verify_params(signed_request, secret)  
      signed_request = URI::decode(signed_request)

      encoded_sig, payload = signed_request.split('.', 2)
      sig = Base64.decode64(encoded_sig)

      data = JSON.parse(Base64.decode64(payload))
      if data['algorithm'].to_s.upcase != 'HMAC-SHA256'
        raise Tr8n::Exception.new("Bad signature algorithm: %s" % data['algorithm'])
      end
      expected_sig = OpenSSL::HMAC.digest('sha256', secret, payload)

      if expected_sig != sig
        raise Tr8n::Exception.new("Bad signature")
      end
      HashWithIndifferentAccess.new(data)
    end

    #########################################################
    ### BLOCK OPTIONS
    #########################################################
    def self.block_options
      (Thread.current[:tr8n_block_options] || []).last || {}
    end

    def self.current_source_from_block_options
      arr = Thread.current[:tr8n_block_options] || []
      arr.reverse.each do |opts|
        return Tr8n::TranslationSource.find_or_create(opts[:source]) unless opts[:source].blank?
      end
      nil
    end

    def self.current_component_from_block_options
      arr = Thread.current[:tr8n_block_options] || []
      arr.reverse.each do |opts|
        return Tr8n::Component.find_or_create(opts[:component]) unless opts[:component].blank?
      end
      Tr8n::Config.current_component
    end

    #########################################################
    ### RELATIONSHIP AND CONFIGURATION KEYS
    #########################################################
    def self.init_relationship_keys
      puts "Initializing default relationship keys..." unless env.test?

      Tr8n::RelationshipKey.delete_all if env.test? or env.development?
      
      sys_translator = system_translator
      
      default_relationship_keys.each do |key, data|
        puts key unless env.test?
        rkey = Tr8n::RelationshipKey.find_or_create(key)
        rkey.description ||= data.delete(:description)
        rkey.level = curator_level # only admins and curators can see them for now
        rkey.save
        
        data.each do |locale, labels|
          language = Tr8n::Language.for(locale)
          next unless language
          labels = [labels].flatten # there could be a few translation variations
          labels.each do |lbl|
            trn = rkey.add_translation(lbl, nil, language, sys_translator)
          end
        end
      end
    end
    
    def self.default_relationship_keys
      @default_relationship_keys ||= load_yml("/config/tr8n/data/default_relationship_keys.yml", nil)
    end
    
    def self.init_configuration_keys
      puts "Initializing default configuration keys..." unless env.test?

      Tr8n::ConfigurationKey.delete_all if env.test? or env.development?
      
      sys_translator = system_translator
      
      default_configuration_keys.each do |key, value|
        puts key unless env.test?
        rkey = Tr8n::ConfigurationKey.find_or_create(key, value[:label], value[:description])
        rkey.level = curator_level # only admins and curators can see them for now
        rkey.save
        
        translations = value[:translations] || {}
        translations.each do |locale, lbl|
          language = Tr8n::Language.for(locale)
          next unless language
          rkey.add_translation(lbl, nil, language, sys_translator)
        end
      end
    end
    
    def self.default_configuration_keys
      @default_configuration_keys ||= load_yml("/config/tr8n/data/default_configuration_keys.yml", nil)
    end
  end
end
