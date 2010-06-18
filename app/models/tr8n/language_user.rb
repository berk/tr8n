class Tr8n::LanguageUser < ActiveRecord::Base
  set_table_name :tr8n_language_users
  
  belongs_to :user, :class_name => Tr8n::Config.user_class_name, :foreign_key => :user_id
  belongs_to :language, :class_name => "Tr8n::Language"
  belongs_to :translator, :class_name => "Tr8n::Translator"
  
  # this object can belong to both the user and the translator
  # users may choose to switch to a language without becoming translators
  # once user becomes a translator, this record will be associated with both for ease of use
  # when users get promoted, they are automatically get associated with a language and marked as translators
  
  def self.find_or_create(user, language)
    pl = find(:first, :conditions => ["user_id = ? and language_id = ?", user.id, language.id])
    pl || create(:user => user, :language => language)
  end

  def self.check_default_language_for(user)
     find_or_create(user, Tr8n::Config.default_language)
  end

  def self.languages_for(user)
    return [] unless user.id
    check_default_language_for(user)
    find(:all, :conditions => ["user_id = ?", user.id], :order => "updated_at desc")
  end

  def self.create_or_touch(user, language)
    return unless user.id
    lu = Tr8n::LanguageUser.find_or_create(user, language)
    lu.update_attributes(:updated_at => Time.now)
    lu
  end
  
  def translator?
    translator != nil
  end
end
