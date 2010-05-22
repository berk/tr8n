class Tr8n::TranslatorLog < ActiveRecord::Base
  set_table_name :tr8n_translator_logs
  establish_connection(Tr8n::Config.database) if Tr8n::Config.use_remote_database?
  
  belongs_to :translator, :class_name => "Tr8n::Translator"
  belongs_to :user,       :class_name => Tr8n::Config.user_class_name, :foreign_key => :user_id
  
  TRANSLATOR_LEVEL = 0
  MANAGER_LEVEL = 10
  ADMIN_LEVEL = 20
  ABUSE_LEVEL = 100
  
  ACTIONS = [:got_blocked, :got_unblocked, :got_promoted, :got_demoted, :enabled_inline_translations, 
  :disabled_inline_translations, :switched_language, :deleted_language_rule, :added_language_rule,
  :updated_language_rule, :used_abusive_language, :added_translation, :updated_translation, :deleted_translation, 
  :voted_on_translation, :locked_translation_key, :unlocked_translation_key]
  
  
  def self.log_admin(translator, action, user, reason = "n/a", reference = nil)
    return unless Tr8n::Config.enable_paranoia_mode?
    log = create(:translator => translator, :user => (user || translator.user), 
        :action => action.to_s, :action_level => ADMIN_LEVEL, :reason => reason, :reference => reference.to_s)
    Tr8n::Config.logger.debug(log.full_description)
  end

  def self.log_manager(translator, action, reference = nil, user = nil)
    return unless Tr8n::Config.enable_paranoia_mode?
    log = create(:translator => translator, :user => (user || translator.user), 
        :action => action.to_s, :action_level => MANAGER_LEVEL, :reference => reference.to_s)
    Tr8n::Config.logger.debug(log.full_description)
  end
  
  def self.log(translator, action, reference = nil, user = nil)
    return unless Tr8n::Config.enable_paranoia_mode?
    log = create(:translator => translator, :user => (user || translator.user), 
        :action => action.to_s, :action_level => TRANSLATOR_LEVEL, :reference => reference.to_s)
    Tr8n::Config.logger.debug(log.full_description)
  end

  def self.log_abuse(translator, action, reference = nil, user = nil)
    return unless Tr8n::Config.enable_paranoia_mode?
    log = create(:translator => translator, :user => (user || translator.user), 
        :action => action.to_s, :action_level => ABUSE_LEVEL, :reference => reference.to_s)
    Tr8n::Config.logger.debug(log.full_description)
  end
  
  def decoration
    return "color:red;font-weight:bold" if action_level == ABUSE_LEVEL
    return "color:green;font-weight:bold" if action_level == ADMIN_LEVEL
    return "color:green" if action_level == MANAGER_LEVEL
    "color:black"
  end

  def full_description
    "#{translator.name} (#{translator.id}) #{describe}"
  end
  
  def describe
    html = action.to_s.gsub("_", " ")
    act = action.to_sym
    if [:got_blocked, :got_unblocked, :got_promoted, :got_demoted].include?(act)
      html << " by " << user.name if user
      html << " because \"" << reason << "\"" unless reason.blank?
    elsif [:enabled_inline_translations, :disabled_inline_translations].include?(act)
      lang = Tr8n::Language.find_by_id(reference) unless reference.blank?
      html << " for " << lang.english_name if lang
    elsif [:switched_language].include?(act)
      lang = Tr8n::Language.find_by_id(reference) unless reference.blank?
      html << " to " << lang.english_name if lang
    elsif [:deleted_language_rule, :added_language_rule, :updated_language_rule].include?(act)
      rule = Tr8n::LanguageRule.find_by_id(reference) unless reference.blank?
      html << " for " << rule.language.english_name if rule and rule.language
      html << " : " << rule.description if rule
    elsif [:used_abusive_language].include?(act)
      lang = Tr8n::Language.find_by_id(reference) unless reference.blank?
      html << " in " << lang.english_name if lang
    elsif [:added_translation, :updated_translation, :deleted_translation, :voted_on_translation].include?(act)
      trans = Tr8n::Translation.find_by_id(reference) unless reference.blank?
      html << " in " << trans.language.english_name if trans and trans.language
      html << " : " << trans.translation_key.label if trans
    elsif [:locked_translation_key, :unlocked_translation_key].include?(act)
      trans_key = Tr8n::TranslationKey.find_by_id(reference) unless reference.blank?
      html << " : " << trans_key.label if trans
    end
    
    html
  end
end
