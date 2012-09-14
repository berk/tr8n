#--
# Copyright (c) 2010-2012 Michael Berkovich, tr8n.net
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
#
#-- Tr8n::Translator Schema Information
#
# Table name: tr8n_translators
#
#  id                      INTEGER         not null, primary key
#  user_id                 integer         not null
#  inline_mode             boolean         
#  blocked                 boolean         
#  reported                boolean         
#  fallback_language_id    integer         
#  rank                    integer         default = 0
#  name                    varchar(255)    
#  gender                  varchar(255)    
#  email                   varchar(255)    
#  password                varchar(255)    
#  mugshot                 varchar(255)    
#  link                    varchar(255)    
#  locale                  varchar(255)    
#  level                   integer         default = 0
#  manager                 integer         
#  last_ip                 varchar(255)    
#  country_code            varchar(255)    
#  created_at              datetime        
#  updated_at              datetime        
#  remote_id               integer         
#
# Indexes
#
#  index_tr8n_translators_on_email_and_password    (email, password) 
#  index_tr8n_translators_on_email                 (email) 
#  index_tr8n_translators_on_created_at            (created_at) 
#  index_tr8n_translators_on_user_id               (user_id) 
#
#++

class Tr8n::Translator < ActiveRecord::Base
  self.table_name = :tr8n_translators

  attr_accessible :user_id, :inline_mode, :blocked, :reported, :fallback_language_id, :rank, :name, :gender, :email, :password, :mugshot, :link, :locale, :level, :manager, :last_ip, :country_code, :remote_id
  attr_accessible :user

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
  has_many  :languages,                     :class_name => "Tr8n::Language",                  :through => :language_users

  belongs_to :fallback_language,            :class_name => 'Tr8n::Language',                  :foreign_key => :fallback_language_id
    
  def self.cache_key(user_id)
    "translator_#{user_id}"
  end

  def cache_key
    self.class.cache_key(key)
  end

  def self.for(user)
    return nil unless user and user.id 
    return nil if Tr8n::Config.guest_user?(user)
    translator = Tr8n::Cache.fetch(cache_key(user.id)) do 
      find_by_user_id(user.id)
    end
  end
  
  def self.find_or_create(user)
    return nil unless user and user.id 

    trn = where(:user_id => user.id).first
    trn = create(:user => user) unless trn
    trn
  end

  def self.register(user = Tr8n::Config.current_user)
    translator = Tr8n::Translator.find_or_create(user)
    return unless translator

    # update all language user entries to add a translator id
    Tr8n::LanguageUser.where(:user_id => user.id).each do |lu|
      lu.update_attributes(:translator => translator)
    end
    translator
  end
  
  def self.top_translators_for_language(lang = Tr8n::Config.current_language, limit = 5)
    Tr8n::TranslatorMetric.where(:language_id => lang.id).order("total_translations desc, total_votes desc").limit(limit)
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
    update_attributes(:inline_mode => true)
    Tr8n::TranslatorLog.log(self, :enabled_inline_translations, Tr8n::Config.current_language.id)
  end

  def disable_inline_translations!(actor = user)
    update_attributes(:inline_mode => false)
    Tr8n::TranslatorLog.log(self, :disabled_inline_translations, Tr8n::Config.current_language.id)
  end

  def toggle_inline_translations!
    inline_mode ? disable_inline_translations! : enable_inline_translations!
  end

  def switched_language!(language)
    lu = Tr8n::LanguageUser.create_or_touch(user || self, language)
    lu.update_attributes(:translator_id => self.id) unless lu.translator
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
    return true if Tr8n::Config.admin_user?(user)
    return true if level >= Tr8n::Config.manager_level
    false
  end

  # for translators registered on the exchange server
  def remote?
    return false if user
    not remote_id.nil?
  end

  def system?
    level == Tr8n::Config.system_level
  end

  def application?
    level == Tr8n::Config.application_level
  end
  
  def last_logs
    Tr8n::TranslatorLog.where("translator_id = ?", self.id).order("created_at desc").limit(20)
  end
  
  def name
    return "Tr8n Network" if system?
    return super if remote?

    return "Deleted User" unless user
    user_name = Tr8n::Config.user_name(user)
    return "No Name" if user_name.blank?
    
    user_name
  end

  def gender
    return "unknown" if system?
    return super if remote?
    
    Tr8n::Config.user_gender(user)
  end

  # TODO: change db to mugshot_url
  def mugshot
    return Tr8n::Config.system_image if system?
    return super if remote?
    return Tr8n::Config.silhouette_image unless user
    img_url = Tr8n::Config.user_mugshot(user)
    return Tr8n::Config.silhouette_image if img_url.blank?
    img_url
  end

  # TODO: change db to link_url
  def link
    # return super if remote? 
    return Tr8n::Config.default_url unless user
    Tr8n::Config.user_link(user)
  end

  def admin?
    # stand alone translators are always admins
    return false unless user
    Tr8n::Config.admin_user?(user)
  end  

  def guest?
    return true unless user
    Tr8n::Config.guest_user?(user)
  end  

  def level
    return Tr8n::Config.admin_level if admin?
    return super if remote?
    return 0 if super.nil?
    super
  end

  def title
    return 'admin' if admin?
    return super if remote?
    Tr8n::Config.translator_levels[level.to_s] || 'unknown'
  end

  def follow(object)
    Tr8n::TranslatorFollowing.find_or_create(self, object)
  end

  def unfollow(object)
    tf = Tr8n::TranslatorFollowing.where("object_type = ? and object_id = ?", object.class.name, object.id).first
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

#    need to figure out what to do with it
#    ipl = Tr8n::IpLocation.find_by_ip(new_ip)
#    update_attributes(:last_ip => new_ip, :country_code => (ipl? ? ipl.ctry : nil))
  end

  def to_s
    name
  end
  
  ###############################################################
  ## Synchronization Methods
  ###############################################################
  def to_sync_hash(opts = {})
    { 
      "id" => opts[:remote] ? self.remote_id : self.id, 
      "name" => self.name, 
      "gender" => self.gender, 
      "mugshot" => self.mugshot, 
      "link" => self.link
    }
  end

  def self.create_from_sync_hash(thash, opts = {})
    Tr8n::Translator.find_by_remote_id(thash[:id]) || Tr8n::Translator.create(
      :user_id => 0,
      :remote_id => thash[:id], 
      :name => thash[:name], 
      :gender => thash[:gender], 
      :mugshot => thash[:mugshot], 
      :link => thash[:link]
    )
  end
  
  def merge_into(master, opts = {})
    Tr8n::TranslatorMetric.delete_all_metrics_for_translator(self)
    Tr8n::LanguageUser.delete_all_languages_for_translator(self)

    Tr8n::Config.models.each do |model|
      next unless model.columns.collect{|c| c.name}.include?("translator_id")
      model.connection.execute("update #{model.table_name} set translator_id = #{master.id} where translator_id = #{self.id}")
    end
    
    Tr8n::TranslatorMetric.update_all_metrics_for_translator(master)

    self.destroy if opts[:delete]
  end
end
