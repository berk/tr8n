class Tr8n::Notification < ActiveRecord::Base
  set_table_name :tr8n_notifications

  belongs_to :translator, :class_name => "Tr8n::Translator"

  belongs_to :actor, :class_name => "Tr8n::Translator", :foreign_key => :actor_id
  belongs_to :target, :class_name => "Tr8n::Translator", :foreign_key => :target_id
  belongs_to :object, :polymorphic => true

  def self.distribute(object)
    "#{object.class.name}Notification".constantize.distribute(object)
  end

  def self.key(object)
    object.class.name.underscore.split("/").last
  end

  def self.commenters(tkey, language)
    Tr8n::TranslationKeyComment.find(:all, 
        :conditions => ["translation_key_id = ? and language_id = ?", 
                         tkey.id, language.id]
    ).collect{|f| f.translator}
  end

  def self.followers(obj)
    Tr8n::TranslatorFollowing.find(:all, 
          :conditions => ["object_type = ? and object_id = ?", 
                          obj.class.name, obj.id]
    ).collect{|f| f.translator}
  end

  def key
    self.class.key(object)
  end

  def valid?
    return false unless object
    true
  end

  def tr(label, description, tokens = {}, options = {})
    label.translate(description, tokens, options.merge(:source => "tr8n/notifications/#{key}"))
  end

  def title
    raise "#{self.class.name} must implement title method"
  end

end
