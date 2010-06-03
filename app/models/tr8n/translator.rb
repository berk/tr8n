class Tr8n::Translator < ActiveRecord::Base
  set_table_name :tr8n_translators

  belongs_to :user, :class_name => Tr8n::Config.user_class_name, :foreign_key => :user_id
  
  has_many  :translator_logs,               :class_name => "Tr8n::TranslatorLog",     :dependent => :destroy, :order => "created_at desc"
  has_many  :translator_metrics,            :class_name => "Tr8n::TranslatorMetric",  :dependent => :destroy
  has_many  :language_users,                :class_name => "Tr8n::LanguageUser"
  has_many  :language_forum_topics,         :class_name => "Tr8n::LanguageForumTopic"
  has_many  :language_forum_messages,       :class_name => "Tr8n::LanguageForumMessage"
  has_many  :language_forum_abuse_reports,  :class_name => "Tr8n::LanguageForumAbuseReport"
  has_many  :languages,                     :class_name => "Tr8n::Language",          :through => :language_users
    
  def self.for(user)
    return nil unless user and user.id
    Tr8n::Cache.fetch("translator_for_#{user.id}") do 
      find_by_user_id(user.id)
    end
  end
  
  def self.find_or_create(user)
    trn = find(:first, :conditions => ["user_id = ?", user.id])
    trn = create(:user => user) unless trn
    trn
  end

  def self.register(user = Tr8n::Config.current_user)
    return unless user
    
    translator = Tr8n::Translator.create(:user => user)
    Tr8n::LanguageUser.find(:all, :conditions => ["user_id = ?", user.id]).each do |lu|
      lu.update_attributes(:translator => translator)
    end
    translator
  end
  
  def total_metric
    @total_metric ||= Tr8n::TranslatorMetric.find_or_create(self, nil)
  end

  def metric_for(language)
    Tr8n::TranslatorMetric.find_or_create(self, language)
  end

  def update_metrics!(language = Tr8n::Config.current_language)
    # calculate total metrics
    total_metric.update_metrics!
    
    # calculate language specific metrics
    metric_for(language).update_metrics!
  end
  
  def update_rank!(language = Tr8n::Config.current_language)
    # calculate total rank
    total_metric.update_rank!
    
    # calculate language specific rank
    metric_for(language).update_rank!
  end
    
  def rank
    total_metric.rank
  end
    
  def block!(actor, reason = "No reason given")
    update_attributes(:blocked => true, :inline_mode => false)
    Tr8n::TranslatorLog.log_admin(self, :got_blocked, actor, reason)
  end
  
  def unblock!(actor, reason = "No reason given")
    update_attributes(:blocked => false)
    Tr8n::TranslatorLog.log_admin(self, :got_unblocked, actor, reason)
  end
  
  def promote!(actor, language, reason = "No reason given")
    lu = Tr8n::LanguageUser.find_or_create(user, language)
    lu.update_attributes(:manager => true, :translator => self)
    Tr8n::TranslatorLog.log_admin(self, :got_promoted, actor, reason, language.id)
  end
  
  def demote!(actor, language, reason = "No reason given")
    lu = Tr8n::LanguageUser.find_or_create(user, language)
    lu.update_attributes(:manager => false, :translator => self)
    Tr8n::TranslatorLog.log_admin(self, :got_demoted, actor, reason, language.id)
  end
  
  def enable_inline_translations!
    update_attributes(:inline_mode => true)
    Tr8n::TranslatorLog.log(self, :enabled_inline_translations, Tr8n::Config.current_language.id)
  end

  def disable_inline_translations!(actor = user)
    update_attributes(:inline_mode => false)
    Tr8n::TranslatorLog.log(self, :disabled_inline_translations, Tr8n::Config.current_language.id)
  end

  def switched_language!(language)
    lu = Tr8n::LanguageUser.create_or_touch(user, language)
    lu.update_attributes(:translator => self) unless lu.translator
    Tr8n::TranslatorLog.log(self, :switched_language, language.id)
  end

  def deleted_language_rule!(rule)
    Tr8n::TranslatorLog.log_manager(self, :deleted_language_rule, rule.id)
  end

  def added_language_rule!(rule)
    Tr8n::TranslatorLog.log_manager(self, :added_language_rule, rule.id)
  end

  def updated_language_rule!(rule)
    Tr8n::TranslatorLog.log_manager(self, :updated_language_rule, rule.id)
  end

  def used_abusive_language!(language = Tr8n::current_language)
    Tr8n::TranslatorLog.log_abuse(self, :used_abusive_language, language.id)
  end

  def added_translation!(translation)
    Tr8n::TranslatorLog.log(self, :added_translation, translation.id)
  end

  def updated_translation!(translation)
    Tr8n::TranslatorLog.log(self, :updated_translation, translation.id)
  end

  def deleted_translation!(translation)
    Tr8n::TranslatorLog.log(self, :deleted_translation, translation.id)
  end

  def voted_on_translation!(translation)
    Tr8n::TranslatorLog.log(self, :voted_on_translation, translation.id)
  end

  def locked_translation_key!(translation_key, language)
    Tr8n::TranslatorLog.log_manager(self, :locked_translation_key, translation_key.id)
  end

  def unlocked_translation_key!(translation_key, language)
    Tr8n::TranslatorLog.log_manager(self, :unlocked_translation_key, translation_key.id)
  end

  def tried_to_perform_unauthorized_action!(action)
    Tr8n::TranslatorLog.log_abuse(self, action)
  end
  
  def enable_inline_translations?
    inline_mode == true
  end
  
  # all admins are always manager for all languages
  def manager?(language = Tr8n::Config.current_language)
    return true if Tr8n::Config.admin_user?(user)
    lu = Tr8n::LanguageUser.find_or_create(user, language)
    lu.manager?
  end

  def manager_for_any_language?
    return true if Tr8n::Config.admin_user?(user)
    Tr8n::LanguageUser.find_all_by_user_id_and_manager(user.id, true).any?
  end

  def last_logs
    Tr8n::TranslatorLog.find(:all, :conditions => ["translator_id = ?", self.id], :order => "created_at desc", :limit => 20)
  end
  
  def name
    return "Deleted User" unless user
    Tr8n::Config.user_name(user)
  end

  def user_mugshot
    return Tr8n::Config.silhouette_image unless user
    img_url = Tr8n::Config.user_mugshot(user)
    return Tr8n::Config.silhouette_image if img_url.blank?
    img_url
  end

  def user_link
    return Tr8n::Config.default_url unless user
    Tr8n::Config.user_link(user)
  end

  def admin?
    return false unless user
    Tr8n::Config.admin_user?(user)
  end  

  def guest?
    return true unless user
    Tr8n::Config.guest_user?(user)
  end  

  def after_save
    Tr8n::Cache.delete("translator_for_#{user_id}")
  end

end
