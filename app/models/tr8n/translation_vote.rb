class Tr8n::TranslationVote < ActiveRecord::Base
  set_table_name :tr8n_translation_votes
  establish_connection(Tr8n::Config.database) if Tr8n::Config.use_remote_database?
  
  belongs_to :translation,  :class_name => "Tr8n::Translation",  :dependent => :destroy
  belongs_to :translator,   :class_name => "Tr8n::Translator"
    
  def self.find_or_create(translation, translator)
    vote = find(:first, :conditions => ["translation_id = ? and translator_id = ?", translation.id, translator.id])
    vote = create(:translation => translation, :translator => translator, :vote => 0) unless vote
    vote
  end
  
end
