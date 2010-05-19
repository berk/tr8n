class Tr8n::LanguageForumAbuseReport < ActiveRecord::Base
  set_table_name :tr8n_language_forum_abuse_reports
  establish_connection(Tr8n::Config.database) if Tr8n::Config.use_remote_database?

  belongs_to :language,               :class_name => "Tr8n::Language"  
  belongs_to :translator,             :class_name => "Tr8n::Translator"   
  belongs_to :language_forum_message, :class_name => "Tr8n::LanguageForumMessage"
  
end
