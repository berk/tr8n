class Tr8n::Language < ActiveRecord::Base
  set_table_name :tr8n_languages
  establish_connection(Tr8n::Config.database) if Tr8n::Config.use_remote_database?

  belongs_to :fallback_language,    :class_name => 'Tr8n::Language', :foreign_key => :fallback_language_id
  
  has_many :language_rules,         :class_name => 'Tr8n::LanguageRule',        :dependent => :destroy, :order => "type asc"
  has_many :language_users,         :class_name => 'Tr8n::LanguageUser',        :dependent => :destroy
  has_many :translations,           :class_name => 'Tr8n::Translation',         :dependent => :destroy
  has_many :translation_votes,      :class_name => 'Tr8n::TranslationKey',      :dependent => :destroy
  has_many :translation_key_locks,  :class_name => 'Tr8n::TranslationKeyLock',  :dependent => :destroy
  has_many :language_metrics,       :class_name => 'Tr8n::LanguageMetric'
  
  alias :rules :language_rules
  alias :users :language_users

  def self.populate_defaults
    # we do not want to delete existing languages, ever!
    Tr8n::Config.default_languages.each do |l|
      lang = find_or_create(l[0], l[1])
      lang.update_attributes(:english_name => l[1], :native_name => l[2], :enabled => l[3], :right_to_left => l[4])
      lang.generate_default_rules
    end
  end

  def self.find_or_create(lcl, english_name)
    find_by_locale(lcl) || create(:locale => lcl, :english_name => english_name) 
  end
  
  def self.for(locale)
    find_by_locale(locale)
  end

  def current?
    self == Tr8n::Config.current_language
  end
  
  def default?
    self == Tr8n::Config.default_language
  end
  
  def flag
    locale
  end
  
  def has_rules?
    not rules.empty?
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
    @filter_options ||= begin
      opts = []
      find(:all, :order => "english_name asc").each do |lang|
        opts << [lang.english_name, lang.id]
      end
      opts
    end
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
  
  def self.enabled_languages
    find(:all, :conditions => ["enabled = ?", true], :order => "english_name asc")
  end

  def self.translate(label, desc = "", tokens = {}, options = {})
    return Tr8n::TranslationKey.substitute_tokens(label, tokens, options) unless Tr8n::Config.enabled?
    options.delete(:source) unless Tr8n::Config.enabled_key_source_tracking?
    Tr8n::Config.current_language.translate(label, desc, tokens, options)
  end

  def translate(label, desc = "", tokens = {}, options = {})
    translation_key = Tr8n::TranslationKey.find_or_create(label, desc, options)
    translation_key.translate(self, tokens.merge(:viewing_user => Tr8n::Config.current_user), options)
  end
  alias :tr :translate

  def default_rule
    @default_rule ||= Tr8n::Config.language_rule_classes.first.new(:language => self, :definition => {})
  end
  
  def rule_classes  
    @rule_classes ||= rules.collect{|r| r.class}.uniq
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

  def calculate_completeness!(keys = Tr8n::TranslationKey.all)
    return update_attributes(:completeness => 100) if default?
    
    trans_count = Tr8n::Translation.count(:conditions => ["language_id = ?", id])
    return update_attributes(:completeness => 0) if trans_count == 0
  
    trans_count = 0  
    keys.each do |key|
      trans_count += 1 if key.valid_translations_for(self).size > 0
    end

    self.completeness = (trans_count * 100 / keys.size)
    save
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

  def update_total_metrics
    metric = Tr8n::TotalLanguageMetric.find(:first, :conditions => ["language_id = ?", self.id])
    metric ||= Tr8n::TotalLanguageMetric.create(:language_id => self.id)
    metric.update_metrics!
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

  def generate_default_rules
    rules.each{|r| r.destroy}
    
    Tr8n::Config.language_rule_classes.each do |rule_class|
      rule_class.default_rules_for(self).each do |definition|
        rule_class.create(:language => self, :definition => definition)
      end
    end
  end
  
end
