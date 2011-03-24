#--
# Copyright (c) 2010 Michael Berkovich, Geni Inc
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#++

class Tr8n::Translator < ActiveRecord::Base
  set_table_name :tr8n_translators

  belongs_to :user, :class_name => Tr8n::Config.user_class_name, :foreign_key => :user_id
  
  has_many  :translator_logs,               :class_name => "Tr8n::TranslatorLog",             :dependent => :destroy, :order => "created_at desc"
  has_many  :translator_following,          :class_name => "Tr8n::TranslatorFollowing",       :dependent => :destroy, :order => "created_at desc"
  has_many  :translator_metrics,            :class_name => "Tr8n::TranslatorMetric",          :dependent => :destroy
  has_many  :translations,                  :class_name => "Tr8n::Translation",               :dependent => :destroy
  has_many  :translation_votes,             :class_name => "Tr8n::TranslationVote",           :dependent => :destroy
  has_many  :translation_key_locks,         :class_name => "Tr8n::TranslationKeyLock",        :dependent => :destroy
  has_many  :language_users,                :class_name => "Tr8n::LanguageUser",              :dependent => :destroy
  has_many  :language_forum_topics,         :class_name => "Tr8n::LanguageForumTopic",        :dependent => :destroy
  has_many  :language_forum_messages,       :class_name => "Tr8n::LanguageForumMessage",      :dependent => :destroy
  has_many  :language_forum_abuse_reports,  :class_name => "Tr8n::LanguageForumAbuseReport",  :dependent => :destroy
  has_many  :languages,                     :class_name => "Tr8n::Language",                  :through => :language_users

  belongs_to :fallback_language,            :class_name => 'Tr8n::Language',                  :foreign_key => :fallback_language_id
    
  def self.for(user)
    return nil unless user and user.id 
    return nil if Tr8n::Config.guest_user?(user)
    return user if user.is_a?(Tr8n::Translator)
    
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
    
    translator = Tr8n::Translator.find_or_create(:user => user)
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
  
  def update_level!(actor, new_level, reason = "No reason given")
    update_attributes(:level => new_level)
    Tr8n::TranslatorLog.log_admin(self, :got_new_level, actor, reason, new_level.to_s)
  end
  
  def enable_inline_translations!
    # HACK because of frozen hash in Thread.current
    Tr8n::Translator.find(self.id).update_attributes(:inline_mode => true)
#    update_attributes(:inline_mode => true)
    Tr8n::TranslatorLog.log(self, :enabled_inline_translations, Tr8n::Config.current_language.id)
  end

  def disable_inline_translations!(actor = user)
    # HACK because of frozen hash in Thread.current
    Tr8n::Translator.find(self.id).update_attributes(:inline_mode => false)
#    update_attributes(:inline_mode => false)
    Tr8n::TranslatorLog.log(self, :disabled_inline_translations, Tr8n::Config.current_language.id)
  end

  def switched_language!(language)
    lu = Tr8n::LanguageUser.create_or_touch(user || self, language)
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

  def deleted_language_case!(lcase)
    Tr8n::TranslatorLog.log_manager(self, :deleted_language_case, lcase.id)
  end

  def added_language_case!(lcase)
    Tr8n::TranslatorLog.log_manager(self, :added_language_case, lcase.id)
  end

  def updated_language_case!(lcase)
    Tr8n::TranslatorLog.log_manager(self, :updated_language_case, lcase.id)
  end

  def used_abusive_language!(language = Tr8n::Config.current_language)
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
  def manager?
    return true unless Tr8n::Config.site_user_info_enabled?
    return true if Tr8n::Config.admin_user?(user)
    return true if level >= Tr8n::Config.manager_level
    false
  end

  def last_logs
    Tr8n::TranslatorLog.find(:all, :conditions => ["translator_id = ?", self.id], :order => "created_at desc", :limit => 20)
  end
  
  def name
    unless Tr8n::Config.site_user_info_enabled?
      translator_name = super
      return translator_name unless translator_name.blank?
      return "No Name"
    end  
    
    return "Deleted User" unless user
    user_name = Tr8n::Config.user_name(user)
    return "No Name" if user_name.blank?
    
    user_name
  end

  def gender
    unless Tr8n::Config.site_user_info_enabled?
      translator_gender = super
      return translator_gender unless translator_gender.blank?
      return "unknown"
    end  

    Tr8n::Config.user_gender(user)
  end

  def mugshot
    return super unless Tr8n::Config.site_user_info_enabled?
    return Tr8n::Config.silhouette_image unless user
    img_url = Tr8n::Config.user_mugshot(user)
    return Tr8n::Config.silhouette_image if img_url.blank?
    img_url
  end

  def link
    return super unless Tr8n::Config.site_user_info_enabled?
    return Tr8n::Config.default_url unless user
    Tr8n::Config.user_link(user)
  end

  def admin?
    # stand alone translators are always admins
    return true unless Tr8n::Config.site_user_info_enabled?
    
    return false unless user
    Tr8n::Config.admin_user?(user)
  end  

  def guest?
    return id.nil? unless Tr8n::Config.site_user_info_enabled?

    return true unless user
    Tr8n::Config.guest_user?(user)
  end  

  def level
    return 0 if super.nil?
    super
  end

  def title
    return 'admin' if admin?
    Tr8n::Config.translator_levels[level.to_s] || 'unknown'
  end

  def follow(object)
    Tr8n::TranslatorFollowing.find_or_create(self, object)
  end

  def unfollow(object)
    tf = Tr8n::TranslatorFollowing.find(:first, :conditions => ["object_type = ? and object_id = ?", object.class.name, object.id])
    tf.destroy if tf
  end

  def self.level_options
    @level_options ||= begin
      opts = []
      Tr8n::Config.translator_levels.keys.collect{|key| key.to_i}.sort.each do |key|
        opts << [Tr8n::Config.translator_levels[key.to_s], key.to_s]
      end
      opts
    end
  end

  def update_last_ip(new_ip)
    return unless Tr8n::Config.enable_country_tracking?
    return if self.last_ip == new_ip

    country_code = Tr8n::IpLocation.find_by_ip(new_ip).ctry
    # HACK to get around frozen hash
    s = Tr8n::Translator.where(:id=>self.id).first
    s.update_attributes(:last_ip => new_ip, :country_code => country_code)
  end

  def after_save
    Tr8n::Cache.delete("translator_for_#{user_id}")
  end

  def after_destroy
    Tr8n::Cache.delete("translator_for_#{user_id}")
  end

  def to_s
    name
  end
end
