require 'json'

class Tr8n::Config

  #########################################################
  # Basic Stuff
  
  # initializes language, user and translator
  # the variables are kept in a thread safe form throughout the request
  def self.init(locale, site_current_user)
    return if disabled?

    Thread.current[:current_language]   = Tr8n::Language.for(locale) || default_language
    Thread.current[:current_user]       = site_current_user
    Thread.current[:current_translator] = Tr8n::Translator.for(site_current_user)
  end
  
  def self.current_user
    Thread.current[:current_user]
  end
  
  def self.current_translator
    Thread.current[:current_translator]
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
  
  # Resets all of the cached variables
  def self.reset!
    @enabled                = nil
    @config                 = nil
    @default_languages      = nil
    @default_lambdas        = nil
    @sitemap_sections       = nil
    @default_gender_rules   = nil
    @default_rank_styles    = nil
    @default_numeric_rules  = nil
    @default_language       = nil
  end

  # will clean all tables and initialize default values
  # never ever do it on live !!!
  def self.reset_all!
    models.each do |cls|
      cls.delete_all
    end

    default_languages.each do |l|
      lang = Tr8n::Language.find_or_create(l[0], l[1])
      lang.update_attributes(:english_name => l[1], :native_name => l[2], :enabled => l[3], :right_to_left => l[4])
      lang.rules.delete_all
      
      language_rule_classes.each do |rule_class|
        rule_class.default_rules_for(lang).each do |definition|
          rule_class.create(:language => lang, :definition => definition)
        end
      end
    end
    
    Tr8n::Glossary.delete_all
    default_glossary.each do |g|
      Tr8n::Glossary.create(:keyword => g[0], :description => g[1])
    end
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
  
  # json support
  def self.load_json(file_path)
    json = JSON.parse(File.read("#{RAILS_ROOT}#{file_path}"))
    return HashWithIndifferentAccess.new(json) if json.is_a?(Hash)
    map = {"map" => json}
    HashWithIndifferentAccess.new(map)[:map]
  end

  def self.load_yml(file_path)
    yml = YAML.load_file("#{RAILS_ROOT}#{file_path}")[RAILS_ENV]
    HashWithIndifferentAccess.new(yml)
  end
  
  def self.dump_config
    save_to_yaml("config.yaml", config)
  end
  
  def self.config
    @config ||= load_yml("/config/tr8n/config.yml")
#    @config ||= begin 
#      cfg = load_json("/config/tr8n/config.json")
#      cfg[:defaults].merge(cfg[RAILS_ENV])
#    end
  end

  def self.default_languages
    @default_languages ||= load_json("/config/tr8n/default_languages.json")
  end

  def self.default_lambdas
    @default_lambdas ||= load_json("/config/tr8n/default_lambdas.json")
  end

  def self.default_glossary
    @default_glossary ||= load_json("/config/tr8n/default_glossary.json")
  end

  def self.features
    @features ||= begin
      defs = load_yml("/config/tr8n/features.yml")
      feats = []
      defs[:enabled_features].each do |key|
        defs[key][:key] = key
        feats << defs[key] 
      end
      feats
    end
  end
  
  def self.enabled?
    return eval(site_info[:enable_tr8n_method]) if site_info[:enable_tr8n_method]
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

  def self.enable_inline_translations?
    config[:enable_inline_translations]
  end
  
  def self.enabled_key_source_tracking?
    config[:enable_key_source_tracking]
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

  def self.use_remote_database?
    config[:use_remote_database]
  end

  def self.database
    return {} unless use_remote_database?
    config[:database]
  end

  def self.enable_caching?
    config[:enable_caching]
  end

  def self.cache_adapter
    config[:cache_adapter]
  end

  def self.open_translator_mode?
    config[:open_translator_mode]
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
    site_user_info[:enabled] || true
  end
  
  def self.user_class_name
    site_user_info[:class_name]
  end

  def self.user_class
    user_class_name.constantize
  end

  def self.user_id(user)
    return unless user and site_user_info_enabled?
    user.send(site_user_info[:methods][:id])
  end

  def self.user_name(user)
    user.send(site_user_info[:methods][:name])
  end

  def self.user_mugshot(user)
    user.send(site_user_info[:methods][:mugshot])
  end

  def self.user_link(user)
    user.send(site_user_info[:methods][:link])
  end

  def self.admin_user?(user = current_user)
    return false unless user and site_user_info_enabled?
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
  
  def self.viewing_user_token
    rules_engine[:viewing_user_token]
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

  def self.default_gender_rules(locale = default_locale)
    @default_gender_rules ||= load_json("/config/tr8n/default_gender_rules.json")
    return @default_gender_rules[locale.to_s] if @default_gender_rules[locale.to_s]
    @default_gender_rules[default_locale]
  end

  def self.default_numeric_rules(locale = default_locale)
    @default_numeric_rules ||= load_json("/config/tr8n/default_numeric_rules.json")
    return @default_numeric_rules[locale.to_s] if @default_numeric_rules[locale.to_s]
    @default_numeric_rules[default_locale]
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
