class Tr8n::Translation < ActiveRecord::Base
  set_table_name :tr8n_translations
  establish_connection(Tr8n::Config.database) if Tr8n::Config.use_remote_database?

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
    return nil if super.nil?
    
    @loaded_rules ||= begin
      rulz = []
      super.each do |rule|
        language_rule = Tr8n::LanguageRule.find_by_id(rule[:rule_id])
        rulz << rule.merge({:rule => language_rule}) if language_rule  
      end
      rulz
    end
  end

  def rules_hash
    return nil if rules.nil?
    
    @rules_hash ||= begin
      rulz = {}
      rules.each do |rule|
        rulz[rule[:token]] = rule[:rule_id]  
      end
      rulz
    end
  end

  def context
    return nil if rules.empty?
    
    @context ||= begin
      context_rules = []  
      rules.each do |rule|
        context_rules << "<strong>#{rule[:token]}</strong> #{rule[:rule].description}" 
      end
      "#{context_rules.join(" and ")}."
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
  
  def clean?
    language.clean_sentence?(label)
  end
  
  def translate(token_values, options = {})
    translation_key.substitute_tokens(label, token_values, options)
  end
  
  def can_be_edited_by?(editor)
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
  
end
