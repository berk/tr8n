class Tr8n::TranslationSource < ActiveRecord::Base
  set_table_name :tr8n_translation_sources
  establish_connection(Tr8n::Config.database) if Tr8n::Config.use_remote_database?
  
  has_many :translation_key_sources,  :class_name => "Tr8n::TranslationKeySource",  :dependent => :destroy
  has_many :translation_keys,         :class_name => "Tr8n::TranslationKey",        :through => :translation_key_sources
  
  def self.find_or_create(source_name)
    find_by_source(source_name) || create(:source => source_name)
  end
  
end
