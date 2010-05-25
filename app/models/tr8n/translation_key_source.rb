class Tr8n::TranslationKeySource < ActiveRecord::Base
  set_table_name :tr8n_translation_key_sources

  belongs_to :translation_source, :class_name => "Tr8n::TranslationSource"
  belongs_to :translation_key,    :class_name => "Tr8n::TranslationKey"

  def self.find_or_create(translation_key, translation_source)
    tks = find(:first, :conditions => ["translation_key_id = ? and translation_source_id = ?", translation_key.id, translation_source.id])
    tks || create(:translation_key => translation_key, :translation_source => translation_source)
  end
end
