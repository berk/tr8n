class Tr8n::LanguageForumTopic < ActiveRecord::Base
  set_table_name :tr8n_language_forum_topics

  belongs_to :language, :class_name => "Tr8n::Language"    
  belongs_to :translator, :class_name => "Tr8n::Translator"    
  
  has_many :language_forum_messages, :class_name => "Tr8n::LanguageForumMessage", :dependent => :destroy
  
  def post_count
    @post_count ||= Tr8n::LanguageForumMessage.count(:conditions => ["language_forum_topic_id = ?", self.id])
  end

  def last_post
    @last_post ||= Tr8n::LanguageForumMessage.find(:first, :conditions => ["language_forum_topic_id = ?", self.id], :order => "created_at desc")
  end
  
  def describe
    return "#{language.english_name} Language Forum" if language
    "General Forum"
  end
end
