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

class Tr8n::RelationshipKey < Tr8n::TranslationKey

  def self.normalize_key(label)
    label.gsub(" ", "").downcase
  end

  def self.find_or_create(key, label = nil, description = nil, options = {})
    Tr8n::Cache.fetch("relationship_key_#{key}") do
        find_by_key(key) || create(:key => key, :label => label || key, :description => description, :level => 0, :admin => false)
    end
  end
  
  def self.for_key(key)
    Tr8n::Cache.fetch("relationship_key_#{key}") do
        find_by_key(key)
    end
  end

  def after_save
    Tr8n::Cache.delete("relationship_key_#{key}")
  end

  def after_destroy
    Tr8n::Cache.delete("relationship_key_#{key}")
  end

  # must be overloaded
  def gender 
    'unknown'
  end

  def self.with_valid_translations_for_locale(locale = Tr8n::Config.current_language.locale)
    lang = Tr8n::Language.for(locale)
    return [] unless lang

    # need to add caching...

    conditions = [""]
    conditions[0] << " tr8n_translation_keys.id in (select tr8n_translations.translation_key_id from tr8n_translations where tr8n_translations.language_id = ? and tr8n_translations.rank >= ?) "
    conditions << lang.id
    conditions << Tr8n::Config.translation_threshold
    Tr8n::RelationshipKey.find(:all, :conditions => conditions)
  end


  def translate(language = Tr8n::Config.current_language, token_values = {}, options = {})
    return find_all_valid_translations(valid_translations_for(language)) if options[:api]
    
    translation_language, translation = find_first_valid_translation_for_language(language, token_values)
    
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

  def default_translation
    @default_translation ||= begin
      trn = valid_translations_for(Tr8n::Config.default_language).first
      trn.nil? ? "" : trn.label
    end  
  end

  ###############################################################
  ## Feature Related Stuff
  ###############################################################

  def locked?(language = Tr8n::Config.current_language)
    return !Tr8n::Config.current_user_is_admin? if language.default?
    lock_for(language).locked?
  end

  def self.title
    "Relationship Key".translate
  end

  def self.help_url
    '/relationships/help'
  end

  def suggestion_label
    default_translation.gsub('"', '\"')
  end

#  def rules?
#    false
#  end

  def dictionary?
    false
  end

  def sources?
    false
  end

  def sort_key
    label
  end
  
  ###############################################################
  ## Search Related Stuff
  ###############################################################

  def self.search_conditions_for(params)
    conditions = [""]

    unless params[:search].blank?
      conditions[0] << " and " unless conditions[0] == ""
      conditions[0] << " (tr8n_translation_keys.label like ? or tr8n_translation_keys.description like ?)"
      conditions << "%#{params[:search]}%"
      conditions << "%#{params[:search]}%"
    end

    # for with and approved, allow user to specify the kinds
    if params[:phrase_type] == "with"
      conditions[0] << " and " unless conditions[0].blank?
      conditions[0] << " tr8n_translation_keys.id in (select tr8n_translations.translation_key_id from tr8n_translations where tr8n_translations.language_id = ?) "
      conditions << Tr8n::Config.current_language.id

      # if approved, ensure that translation key is locked
      if params[:phrase_status] == "approved"
        conditions[0] << " and " unless conditions[0].blank?
        conditions[0] << " tr8n_translation_keys.id in (select tr8n_translation_key_locks.translation_key_id from tr8n_translation_key_locks where tr8n_translation_key_locks.language_id = ? and tr8n_translation_key_locks.locked = ?) "
        conditions << Tr8n::Config.current_language.id
        conditions << true

        # if approved, ensure that translation key does not have a lock or unlocked
      elsif params[:phrase_status] == "pending"
        conditions[0] << " and " unless conditions[0].blank?
        conditions[0] << " tr8n_translation_keys.id not in (select tr8n_translation_key_locks.translation_key_id from tr8n_translation_key_locks where tr8n_translation_key_locks.language_id = ? and tr8n_translation_key_locks.locked = ?) "
        conditions << Tr8n::Config.current_language.id
        conditions << true
      end

    elsif params[:phrase_type] == "without"
      conditions[0] << " and " unless conditions[0].blank?
      conditions[0] << " tr8n_translation_keys.id not in (select tr8n_translations.translation_key_id from tr8n_translations where tr8n_translations.language_id = ?)"
      conditions << Tr8n::Config.current_language.id

    elsif params[:phrase_type] == "followed"
      conditions[0] << " and " unless conditions[0].blank?
      conditions[0] << " tr8n_translation_keys.id in (select tr8n_translator_following.object_id from tr8n_translator_following where tr8n_translator_following.translator_id = ? and tr8n_translator_following.object_type = ?)"

      conditions << Tr8n::Config.current_translator.id
      conditions << 'Tr8n::TranslationKey'
    end

    if params[:phrase_lock] == "locked"
      conditions[0] << " and " unless conditions[0].blank?
      conditions[0] << " tr8n_translation_keys.id in (select tr8n_translation_key_locks.translation_key_id from tr8n_translation_key_locks where tr8n_translation_key_locks.language_id = ? and tr8n_translation_key_locks.locked = ?) "
      conditions << Tr8n::Config.current_language.id
      conditions << true

    elsif params[:phrase_lock] == "unlocked"
      conditions[0] << " and " unless conditions[0].blank?
      conditions[0] << " tr8n_translation_keys.id not in (select tr8n_translation_key_locks.translation_key_id from tr8n_translation_key_locks where tr8n_translation_key_locks.language_id = ? and tr8n_translation_key_locks.locked = ?) "
      conditions << Tr8n::Config.current_language.id
      conditions << true
    end

    conditions
  end

end
