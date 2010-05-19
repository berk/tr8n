class Tr8n::TranslationKeyLock < ActiveRecord::Base
  set_table_name :tr8n_translation_key_locks
  establish_connection(Tr8n::Config.database) if Tr8n::Config.use_remote_database?

  belongs_to :translation_key,  :class_name => "Tr8n::TranslationKey"
  belongs_to :language,         :class_name => "Tr8n::Language"
  belongs_to :translator,       :class_name => "Tr8n::Translator"

  def self.locked?(translation_key, language)
    find(:first, :conditions => ["translation_key_id = ? and language_id = ?", translation_key.id, language.id])
  end

  def self.lock(translation_key, language, translator)
    tkl = find(:first, :conditions => ["translation_key_id = ? and language_id = ?", translation_key.id, language.id])
    tkl ||= create(:translation_key => translation_key, :language => language, :translator => translator)
    tkl.update_attributes(:translator => translator) if tkl.translator != translator
    translator.locked_translation_key!(translation_key, language)
    tkl
  end

  def self.unlock(translation_key, language, translator)
    tkl = find(:first, :conditions => ["translation_key_id = ? and language_id = ?", translation_key.id, language.id])
    return unless tkl
    translator.unlocked_translation_key!(translation_key, language)
    tkl.destroy
  end
  
end
