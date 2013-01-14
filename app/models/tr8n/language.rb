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
#-- Tr8n::Language Schema Information
#
# Table name: tr8n_languages
#
#  id                      INTEGER         not null, primary key
#  locale                  varchar(255)    not null
#  english_name            varchar(255)    not null
#  native_name             varchar(255)    
#  enabled                 boolean         
#  right_to_left           boolean         
#  completeness            integer         
#  fallback_language_id    integer         
#  curse_words             text            
#  featured_index          integer         default = 0
#  google_key              varchar(255)    
#  facebook_key            varchar(255)    
#  created_at              datetime        
#  updated_at              datetime        
#
# Indexes
#
#  index_tr8n_languages_on_locale    (locale) 
#
#++

class Tr8n::Language < ActiveRecord::Base
  self.table_name = :tr8n_languages
  
  attr_accessible :locale, :english_name, :native_name, :enabled, :right_to_left, :completenss, :fallback_language_id, :curse_words, :featured_index, :google_key, :facebook_key
  attr_accessible :fallback_language

  after_save      :update_cache
  after_destroy   :update_cache

  belongs_to :fallback_language,    :class_name => 'Tr8n::Language', :foreign_key => :fallback_language_id
  
  has_many :language_rules,         :class_name => 'Tr8n::LanguageRule',        :dependent => :destroy, :order => "type asc"
  has_many :language_cases,         :class_name => 'Tr8n::LanguageCase',        :dependent => :destroy, :order => "id asc"
  has_many :language_users,         :class_name => 'Tr8n::LanguageUser',        :dependent => :destroy
  has_many :translations,           :class_name => 'Tr8n::Translation',         :dependent => :destroy
  has_many :translation_key_locks,  :class_name => 'Tr8n::TranslationKeyLock',  :dependent => :destroy
  has_many :language_metrics,       :class_name => 'Tr8n::LanguageMetric'
  
  def self.cache_key(locale)
    "language_#{locale}"
  end

  def cache_key
    self.class.cache_key(locale)
  end
  
  def self.for(locale)
    return nil if locale.nil?
    Tr8n::Cache.fetch(cache_key(locale)) do 
      find_by_locale(locale)
    end
  end

  def self.find_or_create(lcl, english_name)
    find_by_locale(lcl) || create(:locale => lcl, :english_name => english_name) 
  end

  def rules
    Tr8n::Cache.fetch("language_rules_#{locale}") do 
      language_rules
    end
  end

  def cases
    Tr8n::Cache.fetch("language_cases_#{locale}") do 
      language_cases
    end
  end

  def reset!
    reset_language_rules!
    reset_language_cases!
  end
  
  # reloads rules for the language from the yml file
  def reset_language_rules!
    rules.delete_all
    Tr8n::Config.language_rule_classes.each do |rule_class|
      rule_class.default_rules_for(self).each do |definition|
        rule_class.create(:language => self, :definition => definition)
      end
    end
  end
  
  # reloads language cases for the language from the yml file
  def reset_language_cases!
    cases.delete_all
    Tr8n::Config.default_language_cases_for(locale).each do |lcase|
      rules = lcase.delete(:rules)
      language_case = Tr8n::LanguageCase.create(lcase.merge(:language => self, :translator => Tr8n::Config.system_translator))
      next if rules.blank?
      rules.keys.sort.each_with_index do |lrkey, index|
        lcrule = rules[lrkey]
        Tr8n::LanguageCaseRule.create(:language_case => language_case, :language => self, :translator => Tr8n::Config.system_translator, :position => index, :definition => lcrule)
      end
    end
  end
  
  def current?
    self.locale == Tr8n::Config.current_language.locale
  end
  
  def default?
    self.locale == Tr8n::Config.default_locale
  end
  
  def flag
    locale
  end
  
  # deprecated
  def has_rules?
    rules?
  end

  def rules?
    not rules.empty?
  end
  
  def gender_rules?
    return false unless rules?
    
    rules.each do |rule|
      return true if rule.class.dependency == 'gender'
    end
    false
  end

  def cases?
    not cases.empty?
  end

  def case_keyword_maps
    @case_keyword_maps ||= begin
      hash = {} 
      cases.each do |lcase| 
        hash[lcase.keyword] = lcase
      end
      hash
    end
  end
  
  def suggestible?
    not google_key.blank?
  end
  
  def case_for(case_keyword)
    case_keyword_maps[case_keyword]
  end
  
  def valid_case?(case_keyword)
    case_for(case_keyword) != nil
  end
  
  def full_name
    return english_name if english_name == native_name
    "#{english_name} - #{native_name}"
  end

  def self.options
    enabled_languages.collect{|lang| [lang.english_name, lang.id.to_s]}
  end
  
  def self.locale_options
    enabled_languages.collect{|lang| [lang.english_name, lang.locale]}
  end

  def self.filter_options
    find(:all, :order => "english_name asc").collect{|lang| [lang.english_name, lang.id.to_s]}
  end
  
  def enable!
    self.enabled = true
    save
  end

  def disable!
    self.enabled = false
    save
  end
  
  def disabled?
    not enabled?
  end
  
  def dir
    right_to_left? ? "rtl" : "ltr"
  end
  
  def align(dest)
    return dest unless right_to_left?
    dest.to_s == 'left' ? 'right' : 'left'
  end
  
  def self.enabled_languages
    Tr8n::Cache.fetch("enabled_languages") do 
      find(:all, :conditions => ["enabled = ?", true], :order => "english_name asc")
    end
  end

  def self.featured_languages
    Tr8n::Cache.fetch("featured_languages") do 
      find(:all, :conditions => ["enabled = ? and featured_index is not null and featured_index > 0", true], :order => "featured_index desc")
    end
  end

  def self.translate(label, desc = "", tokens = {}, options = {})
    # raise Tr8n::Exception.new("The label is blank") if label.blank?
    raise Tr8n::Exception.new("The label is being translated twice") if label.tr8n_translated?

    return Tr8n::TranslationKey.substitute_tokens(label, tokens, options).tr8n_translated unless Tr8n::Config.enabled?
    return Tr8n::TranslationKey.substitute_tokens(label, tokens, options).tr8n_translated if Tr8n::Config.current_language.default?

    options.delete(:source) unless Tr8n::Config.enable_key_source_tracking?
    Tr8n::Config.current_language.translate(label, desc, tokens, options).tr8n_translated
  end

  def translate(label, desc = "", tokens = {}, options = {})
    # raise Tr8n::Exception.new("The label is blank") if label.blank?
    raise Tr8n::Exception.new("The label is being translated twice") if label.tr8n_translated?

    return Tr8n::TranslationKey.substitute_tokens(label, tokens, options, self).tr8n_translated unless Tr8n::Config.enabled?
    return Tr8n::TranslationKey.substitute_tokens(label, tokens, options, self).tr8n_translated if default?

    translation_key = Tr8n::TranslationKey.find_or_create(label, desc, options)
    translation_key.translate(self, tokens.merge(:viewing_user => Tr8n::Config.current_user), options).tr8n_translated
  end
  alias :tr :translate

  def trl(label, desc = "", tokens = {}, options = {})
    tr(label, desc, tokens, options.merge(:skip_decorations => true))
  end

  def default_rule
    @default_rule ||= Tr8n::Config.language_rule_classes.first.new(:language => self, :definition => {})
  end
  
  def rule_classes  
    @rule_classes ||= rules.collect{|r| r.class}.uniq
  end

  def rule_class_names  
    @rule_class_names ||= rule_classes.collect{|r| r.name}
  end

  def dependencies  
    @dependencies ||= rule_classes.collect{|r| r.dependency}.uniq
  end

  def default_rules_for(dependency)
    rules.select{|r| r.class.dependency == dependency}
  end

  def has_gender_rules?
    dependencies.include?("gender")
  end

  def update_daily_metrics_for(metric_date)
    metric = Tr8n::DailyLanguageMetric.find(:first, :conditions => ["language_id = ? and metric_date = ?", self.id, metric_date])
    metric ||= Tr8n::DailyLanguageMetric.create(:language_id => self.id, :metric_date => metric_date)
    metric.update_metrics!
  end

  def update_monthly_metrics_for(metric_date)
    metric = Tr8n::MonthlyLanguageMetric.find(:first, :conditions => ["language_id = ? and metric_date = ?", self.id, metric_date])
    metric ||= Tr8n::MonthlyLanguageMetric.create(:language_id => self.id, :metric_date => metric_date)
    metric.update_metrics!
  end

  def total_metric
    @total_metric ||= begin
      metric = Tr8n::TotalLanguageMetric.find(:first, :conditions => ["language_id = ?", self.id])
      metric || Tr8n::TotalLanguageMetric.create(Tr8n::LanguageMetric.default_attributes.merge(:language_id => self.id))
    end
  end

  def update_total_metrics
    total_metric.update_metrics!
  end

  def prohibited_words
    return [] if curse_words.blank?
    @prohibited_words ||= begin
      wrds = self.curse_words.split(",").collect{|w| w.strip.downcase} 
      wrds << fallback_language.prohibited_words if fallback_language
      wrds.flatten.uniq
    end
  end

  # you can add -bad_words to override the fallback language rules
  def accepted_prohibited_words
    return [] if curse_words.blank?
    @accepted_prohibited_words ||= begin
      wrds = self.curse_words.split(",").select{|w| w.first=='-'}
      wrds << wrds.collect{|w| w.strip.gsub('-', '').downcase}
      wrds << fallback_language.accepted_prohibited_words if fallback_language
      wrds.flatten.uniq
    end
  end
  
  def bad_words
    @bad_words ||= begin
      bw = prohibited_words + Tr8n::Config.default_language.prohibited_words
      bw.flatten.uniq - accepted_prohibited_words
    end
  end
  
  def clean_sentence?(sentence)
    return true if sentence.blank?

    # we need to solve the downcase problem - it doesn't work for russian and others
    sentence = sentence.downcase

    bad_words.each do |w|
      return false unless sentence.scan(/#{w}/).empty?
    end
    
    true
  end

  def translations_changed!
    # TODO: handle change event - count translations, update total metrics
  end
  
  def update_cache
    Tr8n::Cache.delete(cache_key)
    Tr8n::Cache.delete("language_rules_#{locale}")
    Tr8n::Cache.delete("language_cases_#{locale}")
    Tr8n::Cache.delete("featured_languages")
    Tr8n::Cache.delete("enabled_languages")
  end

  def recently_added_forum_messages
    @recently_added_forum_messages ||= Tr8n::LanguageForumMessage.where("language_id = ?", self.id).order("created_at desc").limit(5)    
  end

  def recently_added_translations
    @recently_added_translations ||= Tr8n::Translation.where("language_id = ?", self.id).order("created_at desc").limit(5)    
  end

  def recently_updated_translations
    @recently_updated_translations ||= begin
      trans =  Tr8n::Translation.where("language_id = ?", self.id)
      trans = trans.where("translation_key_id in (select id from tr8n_translation_keys where level <= ?)", Tr8n::Config.current_translator.level)
      trans.order("updated_at desc").limit(5)
    end
  end
  
  def recently_updated_votes(translator = Tr8n::Config.current_translator)
    @recently_updated_votes ||= Tr8n::TranslationVote.where("translation_id in (select tr8n_translations.id from tr8n_translations where tr8n_translations.language_id = ? and tr8n_translations.translator_id = ?)", self.id, translator.id).order("updated_at desc").limit(5)
  end
  
  def threshold
    Tr8n::Config.translation_threshold
  end

end
