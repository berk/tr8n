require 'json'

class Tr8n::Config

  #########################################################
  # Basic Stuff
  
  # initializes language, user and translator
  # the variables are kept in a thread safe form throughout the request
  def self.init(locale, site_current_user)
    Thread.current[:current_language]   = Tr8n::Language.for(locale) || default_language
    Thread.current[:current_user]       = site_current_user
    Thread.current[:current_translator] = Tr8n::Translator.for(site_current_user)
  end
  
  def self.current_user
    Thread.current[:current_user]
  end
  
  def self.current_language
    Thread.current[:current_language] ||= default_language
  end
  
  def self.current_user_is_translator?
    Thread.current[:current_translator] != nil
  end
  
  # when this method is called, we create the translator record right away
  # and from this point on, will track the user
  # this can happen any time user tries to translate something or enables inline translations
  def self.current_translator
    Thread.current[:current_translator] ||= Tr8n::Translator.register
  end
  
  def self.default_language
    return Tr8n::Language.new(:locale => default_locale) if disabled?
    @default_language ||= Tr8n::Language.for(default_locale) || Tr8n::Language.new(:locale => default_locale)
  end
  
  def self.reset!
#    thread based variables

    Thread.current[:current_language]  = nil
    Thread.current[:current_user] = nil
    Thread.current[:current_translator] = nil
    
#    the following can be shared between threads and requests

#    @enabled                    = nil
#    @config                     = nil
#    @features                   = nil
#    @sitemap_sections           = nil
#
#    @language_rule_classes      = nil
#    @language_rule_dependencies = nil
#    @language_rule_suffixes     = nil
#    
#    @data_token_classes         = nil
#    @decoration_token_classes   = nil
#
#    @default_language           = nil
#    
#    @default_rank_styles        = nil
#    @default_rules              = nil
#    @default_languages          = nil
#    @default_decorations        = nil
#    @default_glossary           = nil
#    @default_shortcuts          = nil
  end

  def self.models
    [ 
       Tr8n::LanguageRule, Tr8n::LanguageUser, Tr8n::Language, Tr8n::LanguageMetric,
       Tr8n::TranslationKey, Tr8n::TranslationKeySource, Tr8n::TranslationSource, Tr8n::TranslationKeyLock,
       Tr8n::Translation, Tr8n::TranslationVote, Tr8n::Glossary,
       Tr8n::Translator, Tr8n::TranslatorLog, Tr8n::TranslatorMetric,
       Tr8n::LanguageForumTopic, Tr8n::LanguageForumMessage, Tr8n::LanguageForumAbuseReport    
    ]    
  end

  # will clean all tables and initialize default values
  # never ever do it on live !!!
  def self.reset_all!
    models.each do |cls|
      cls.delete_all
    end

    default_languages.each do |locale, info|
      lang = Tr8n::Language.find_or_create(locale, info[:english_name])
      info[:right_to_left] = false if info[:right_to_left].nil?
      lang.update_attributes(info.merge(:enabled => true))
      lang.rules.delete_all
      
      language_rule_classes.each do |rule_class|
        rule_class.default_rules_for(lang).each do |definition|
          rule_class.create(:language => lang, :definition => definition)
        end
      end
    end
    
    Tr8n::Glossary.delete_all
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

  def self.default_decorations
    @default_decorations ||= load_yml("/config/tr8n/tokens/decorations.yml", nil)
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
  
  def self.enable_key_source_tracking?
    config[:enable_key_source_tracking]
  end

  def self.enable_key_caller_tracking?
    config[:enable_key_caller_tracking]
  end

  def self.enable_paranoia_mode?
    config[:enable_paranoia_mode]
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

  def self.enable_caching?
    config[:enable_caching]
  end

  def self.cache_adapter
    config[:cache_adapter]
  end

  def self.cache_version
    config[:cache_version]
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
  
  #########################################################
  # Config Sections
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
  
  #########################################################
  # Site Info
  def self.site_title
    site_info[:title] 
  end

  def self.splash_screen
    site_info[:splash_screen]  
  end
  
  def self.default_locale
    site_info[:default_locale]
  end

  def self.default_url
    site_info[:default_url]
  end
  
  def self.current_user_method
    site_info[:current_user_method]
  end

  def self.current_locale_method
    site_info[:current_locale_method]
  end

  def self.enable_tr8n_method
    site_info[:enable_tr8n_method]
  end
  
  def self.sitemap_sections
    @sitemap_sections ||= load_json(site_info[:sitemap_json])
  end
  
  #########################################################
  # site user info
  # The following methods could be overloaded in the initializer
  
  def self.site_user_info
    site_info[:user_info]
  end

  def self.site_user_info_enabled?
    site_user_info[:enabled].nil? ? true : site_user_info[:enabled]
  end

  def self.site_user_info_disabled?
    !site_user_info_enabled?
  end
  
  def self.user_class_name
    raise Tr8n::Exception.new("Site user integration is disabled") unless site_user_info_enabled?
    site_user_info[:class_name]
  end

  def self.user_class
    raise Tr8n::Exception.new("Site user integration is disabled") unless site_user_info_enabled?
    user_class_name.constantize
  end

  def self.user_id(user)
    raise Tr8n::Exception.new("Site user integration is disabled") unless site_user_info_enabled?
    user.send(site_user_info[:methods][:id])
  end

  def self.user_name(user)
    raise Tr8n::Exception.new("Site user integration is disabled") unless site_user_info_enabled?
    user.send(site_user_info[:methods][:name])
  end

  def self.user_mugshot(user)
    raise Tr8n::Exception.new("Site user integration is disabled") unless site_user_info_enabled?
    user.send(site_user_info[:methods][:mugshot])
  end

  def self.user_link(user)
    raise Tr8n::Exception.new("Site user integration is disabled") unless site_user_info_enabled?
    user.send(site_user_info[:methods][:link])
  end

  def self.user_locale(user)
    raise Tr8n::Exception.new("Site user integration is disabled") unless site_user_info_enabled?
    user.send(site_user_info[:methods][:locale])
  end

  def self.admin_user?(user = current_user)
    raise Tr8n::Exception.new("Site user integration is disabled") unless site_user_info_enabled?
    user.send(site_user_info[:methods][:admin])
  end

  def self.current_user_is_admin?
    admin_user?
  end
  
  def self.guest_user?(user = current_user)
    return true unless user
    user.send(site_user_info[:methods][:guest])
  end
  
  def self.current_user_is_guest?
    guest_user?
  end
  
  def self.silhouette_image
    "/tr8n/images/photo_silhouette.gif"
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

  def self.language_rule_suffixes
    @language_rule_suffixes ||= begin
      sfx = {}
      language_rule_classes.each do |cls|
        cls.suffixes.each do |suffix|
          if sfx[suffix]
            raise Tr8n::Exception.new("The same suffix #{suffix} has been registered for multiple rules. This is not allowed.")
          end
          if sfx.index("_")
            raise Tr8n::Exception.new("Incorrect rule suffix: #{suffix}. Suffix may not have '_' in it.")
          end
          sfx[suffix] = cls
        end
      end
      sfx
    end
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
    Tr8n::DataToken.new(label, "{#{rules_engine[:viewing_user_token]}:gender}")
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

  def self.default_numeric_rules(locale = default_locale)
    load_default_rules("numeric", locale)
  end

  def self.default_date_rules(locale = default_locale)
    load_default_rules("date", locale)
  end

  #########################################################
  # localization
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
  # localization
  def self.enable_api?
    api[:enabled]
  end
  
end
