class Tr8n::Translation < ActiveRecord::Base
  set_table_name :tr8n_translations

  belongs_to :language,         :class_name => "Tr8n::Language"
  belongs_to :translation_key,  :class_name => "Tr8n::TranslationKey"
  belongs_to :translator,       :class_name => "Tr8n::Translator"
  
  has_many   :translation_votes, :class_name => "Tr8n::TranslationVote", :dependent => :destroy
  
  serialize :rules
    
  alias :key :translation_key
  alias :votes :translation_votes

  def vote!(translator, score)
    vote = Tr8n::TranslationVote.find_or_create(self, translator)
    vote.update_attributes(:vote => score.to_i)
    update_rank!
    
    self.translator.update_rank!(language) if self.translator
    
    translator.voted_on_translation!(self)
    translator.update_metrics!(language)
  end
  
  def update_rank!
    self.rank = Tr8n::TranslationVote.sum("vote", :conditions => ["translation_id = ?", self.id])
    save
  end
  
  def reset_votes!(translator)
    Tr8n::TranslationVote.delete_all("translation_id = #{self.id}")
    vote!(translator, 1)
  end
  
  def rank_style(rank)
    Tr8n::Config.default_rank_styles.each do |range, color|
      return color if range.include?(rank)
    end
    "color:grey"
  end
  
  def rank_label
    return "<span style='color:grey'>0</span>" if rank.blank?
    
    prefix = (rank > 0) ? "+" : ""
    "<span style='#{rank_style(rank)}'>#{prefix}#{rank}</span>" 
  end

  # populate language rules from the internal rules hash
  def rules
    return nil if super.nil? or super.empty?
    
    @loaded_rules ||= begin
      rulz = []
      super.each do |rule|
        language_rule = Tr8n::LanguageRule.for_id(rule[:rule_id])
        rulz << rule.merge({:rule => language_rule}) if language_rule  
      end
      rulz
    end
  end

  def rules_hash
    return nil if rules.nil? or rules.empty? 
    
    @rules_hash ||= begin
      rulz = {}
      rules.each do |rule|
        rulz[rule[:token]] = rule[:rule_id]  
      end
      rulz
    end
  end

  def rules_definitions
    return nil if rules.nil? or rules.empty? 
    @rules_definitions ||= begin
      rulz = {}
      rules.each do |rule|
        rulz[rule[:token].clone] = rule[:rule].to_hash  
      end
      rulz
    end
  end

  def context
    return nil if rules.nil? or rules.empty? 
    
    @context ||= begin
      context_rules = []  
      rules.each do |rule|
        context_rules << "<strong>#{rule[:token]}</strong> #{rule[:rule].description}" 
      end
      context_rules.join(" and ")
    end
  end

  def matches_rules?(token_values)
    return true if rules.nil? # doesn't have any rules
    return false if rules.empty?  # had some rules that have been removed
    
    rules.each do |rule|
      token_value = token_values[rule[:token].to_sym]
      token_value = token_value.first if token_value.is_a?(Array)
      result = rule[:rule].evaluate(token_value)
      return false unless result
    end
    
    true
  end
  
  def matches_rule_definitions?(new_rules_hash)
    rules_hash == new_rules_hash
  end

  def self.default_translation(translation_key, language, translator)
    trans = find(:first, 
      :conditions => ["translation_key_id = ? and language_id = ? and translator_id = ? and rules is null", 
                       translation_key.id, language.id, translator.id], :order => "rank desc")
    trans ||= new(:translation_key => translation_key, :language => language, :translator => translator, :label => translation_key.sanitized_label)
    trans  
  end

  def blank?
    self.label.blank?    
  end

  def uniq?
    # for now, treat all translations as uniq
    return true
    
    conditions = ["translation_key_id = ? and language_id = ? and label = ?", translation_key.id, language.id, label]
    if self.id
      conditions[0] << " and id <> ?"
      conditions << self.id
    end
    
    self.class.find(:all, :conditions => conditions).empty?
  end
  
  def clean?
    language.clean_sentence?(label)
  end
  
  def can_be_edited_by?(editor)
    return false if translation_key.locked?
    translator == editor
  end

  def can_be_deleted_by?(editor)
    return false if translation_key.locked?
    return true if editor.manager?
    
    translator == editor
  end

  def save_with_log!(translator)
    if self.id
      translator.updated_translation!(self) if changed?
    else  
      translator.added_translation!(self)
    end
    
    save
  end
  
  def destroy_with_log!(translator)
    translator.deleted_translation!(self)
    
    destroy
  end
  
  def after_save
    Tr8n::Cache.delete("translations_#{language.locale}_#{translation_key.key}")
  end

  def after_destroy
    Tr8n::Cache.delete("translations_#{language.locale}_#{translation_key.key}")
  end
  
  ###############################################################
  ## Search Related Stuff
  ###############################################################
  
  def self.filter_status_options
    [["all translations", "all"], 
     ["accepted translations", "accepted"], 
     ["pending translations", "pending"], 
     ["rejected translations", "rejected"]].collect{|option| [option.first.trl("Translation filter status option"), option.last]}    
  end
  
  def self.filter_submitter_options
    [["anyone", "anyone"], 
     ["me", "me"]].collect{|option| [option.first.trl("Translation filter submitter option"), option.last]}
  end
  
  def self.filter_date_options
    [["any date", "any"], 
     ["today", "today"], 
     ["yesterday", "yesterday"], 
     ["in the last week", "last_week"]].collect{|option| [option.first.trl("Translation filter date option"), option.last]}
  end
  
  def self.filter_order_by_options
    [["date", "date"], 
     ["rank", "rank"]].collect{|option| [option.first.trl("Translation filter order by option"), option.last]}
  end
  

  def self.filter_group_by_options
    [["nothing", "nothing"], 
     ["translator", "translator"], 
     ["context rule", "context"], 
     ["rank", "rank"], 
     ["date", "date"]].collect{|option| [option.first.trl("Translation filter group by option"), option.last]}
  end
  
  def self.search_conditions_for(params, language = Tr8n::Config.current_language)
    conditions = ["language_id = ?", language.id]
    
    unless params[:search].blank?
      conditions[0] << " and " unless conditions[0].blank?
      conditions[0] << "label like ?" 
      conditions << "%#{params[:search]}%"
    end

    if params[:with_status] == "accepted"
      conditions[0] << " and " unless conditions[0].blank?
      conditions[0] << " rank >= ? "
      conditions << Tr8n::Config.translation_threshold
    elsif params[:with_status] == "pending"
      conditions[0] << " and " unless conditions[0].blank?
      conditions[0] << " rank >= 0 and rank < ? "
      conditions << Tr8n::Config.translation_threshold
    elsif params[:with_status] == "rejected"
      conditions[0] << " and " unless conditions[0].blank?
      conditions[0] << " rank < 0 "
    end
    
    if params[:submitted_by] == "me"
      conditions[0] << " and " unless conditions[0].blank?
      conditions[0] << " translator_id = ? "
      conditions << Tr8n::Config.current_translator.id
    end
    
    if params[:submitted_on] == "today"
      date = Date.today
      conditions[0] << " and " unless conditions[0].blank?
      conditions[0] << "created_at >= ? and created_at < ?" 
      conditions << date
      conditions << (date + 1.day)
    elsif params[:submitted_on] == "yesterday"
      date = Date.today - 1.days
      conditions[0] << " and " unless conditions[0].blank?
      conditions[0] << "created_at >= ? and created_at < ?" 
      conditions << date
      conditions << (date + 1.day)
    elsif params[:submitted_on] == "last_week"
      date = Date.today - 7.days
      conditions[0] << " and " unless conditions[0].blank?
      conditions[0] << "created_at >= ? and created_at < ?" 
      conditions << date
      conditions << Date.today
    end    
    conditions
  end 
    
end
