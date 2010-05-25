class Tr8n::LanguageForumMessage < ActiveRecord::Base
  set_table_name :tr8n_language_forum_messages
  
  belongs_to :language,               :class_name => "Tr8n::Language"  
  belongs_to :translator,             :class_name => "Tr8n::Translator"  
  belongs_to :language_forum_topic,   :class_name => "Tr8n::LanguageForumTopic"
  
  has_many :language_forum_abuse_reports, :class_name => "Tr8n::LanguageForumAbuseReport", :dependent => :destroy

end
