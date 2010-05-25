class Tr8n::TranslationKeyLock < ActiveRecord::Base
  set_table_name :tr8n_translation_key_locks

  belongs_to :translation_key,  :class_name => "Tr8n::TranslationKey"
  belongs_to :language,         :class_name => "Tr8n::Language"
  belongs_to :translator,       :class_name => "Tr8n::Translator"

  def self.find_or_create(translation_key, language)
    lock = find(:first, :conditions => ["translation_key_id = ? and language_id = ?", translation_key.id, language.id])
    lock || create(:translation_key => translation_key, :language => language)
  end

  def self.for(translation_key, language)
    Tr8n::Cache.fetch("translation_key_lock_#{language.locale}_#{translation_key.key}") do 
      find_or_create(translation_key, language)
    end
  end

  def lock!(translator = Tr8n::Config.current_translator)
    update_attributes(:locked => true, :translator => translator)
    translator.locked_translation_key!(translation_key, language)
    tkl
  end

  def unlock!(translator = Tr8n::Config.current_translator)
    update_attributes(:locked => false, :translator => translator)
    translator.unlocked_translation_key!(translation_key, language)
    tkl
  end
  
  def after_save
    Tr8n::Cache.delete("translation_key_lock_#{language.locale}_#{translation_key.key}")
  end
end
