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

class Tr8n::TranslatorLog < ActiveRecord::Base
  set_table_name :tr8n_translator_logs
  
  belongs_to :translator, :class_name => "Tr8n::Translator"
  belongs_to :user,       :class_name => Tr8n::Config.user_class_name, :foreign_key => :user_id
  
  TRANSLATOR_LEVEL = 0
  MANAGER_LEVEL = 10
  ADMIN_LEVEL = 20
  ABUSE_LEVEL = 100
  
  ACTIONS = [:got_blocked, :got_unblocked, :got_promoted, :got_demoted, 
  :enabled_inline_translations, :disabled_inline_translations, :switched_language, 
  :deleted_language_rule, :added_language_rule, :updated_language_rule, 
  :deleted_language_case, :added_language_case, :updated_language_case, 
  :used_abusive_language, :added_translation, :updated_translation, :deleted_translation, 
  :voted_on_translation, :locked_translation_key, :unlocked_translation_key, :got_new_level,
  :added_relationship_key]
  
  
  def self.log_admin(translator, action, user, reason = "n/a", reference = nil)
    return unless Tr8n::Config.enable_paranoia_mode?
    log = create(:translator => translator, :user => (user || translator.user), 
        :action => action.to_s, :action_level => ADMIN_LEVEL, :reason => reason, :reference => reference.to_s)
    Tr8n::Logger.debug(log.full_description)
  end

  def self.log_manager(translator, action, reference = nil, user = nil)
    return unless Tr8n::Config.enable_paranoia_mode?
    log = create(:translator => translator, :user => (user || translator.user), 
        :action => action.to_s, :action_level => MANAGER_LEVEL, :reference => reference.to_s)
    Tr8n::Logger.debug(log.full_description)
  end
  
  def self.log(translator, action, reference = nil, user = nil)
    return unless Tr8n::Config.enable_paranoia_mode?
    log = create(:translator => translator, :user => (user || translator.user), 
        :action => action.to_s, :action_level => TRANSLATOR_LEVEL, :reference => reference.to_s)
    Tr8n::Logger.debug(log.full_description)
  end

  def self.log_abuse(translator, action, reference = nil, user = nil)
    return unless Tr8n::Config.enable_paranoia_mode?
    log = create(:translator => translator, :user => (user || translator.user), 
        :action => action.to_s, :action_level => ABUSE_LEVEL, :reference => reference.to_s)
    Tr8n::Logger.debug(log.full_description)
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
      html << " (" << reason << ")" unless reason.blank?
    elsif [:got_new_level].include?(act)
      html << " " << reference unless reference.blank?
      html << " from " << user.name if user
      html << " (" << reason << ")" unless reason.blank?
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
    elsif [:deleted_language_case, :added_language_case, :updated_language_case].include?(act)
      lcase = Tr8n::LanguageCase.find_by_id(reference) unless reference.blank?
      html << " for " << lcase.language.english_name if lcase and lcase.language
      html << " : " << lcase.description if lcase
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
