class Tr8n::Translation < ActiveRecord::Base
  set_table_name :tr8n_translations
  establish_connection(Tr8n::Config.database) if Tr8n::Config.use_remote_database?

  belongs_to :language,         :class_name => "Tr8n::Language"
  belongs_to :translation_key,  :class_name => "Tr8n::TranslationKey"
  belongs_to :translator,       :class_name => "Tr8n::Translator"
  
  has_many   :translation_votes, :class_name => "Tr8n::TranslationVote", :dependent => :destroy
  has_many   :translation_rules, :class_name => "Tr8n::TranslationRule", :order => "token asc", :dependent => :destroy

  serialize :dependencies
    
  alias :key :translation_key
  alias :votes :translation_votes
  alias :rules :translation_rules
  
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

  def context
    return nil if translation_rules.empty?
    @context ||= begin
      rules = []  
      translation_rules.each do |rule|
        rules << rule.describe
      end
      "#{rules.join(" and ")}."
    end
  end

  def matched_conditions?(token_values)
    return true if translation_rules.empty?
    
    translation_rules.each do |translation_rule|
      result = translation_rule.evaluate(token_values)
      return false unless result
    end
    
    true
  end

  def self.default_translation(translation_key, language, translator)
    trans = find(:first, 
      :conditions => ["translation_key_id = ? and language_id = ? and translator_id = ? and dependencies is null", 
                       translation_key.id, language.id, translator.id], :order => "rank desc")
    trans ||= new(:translation_key => translation_key, :language => language, :translator => translator, :label => translation_key.sanitized_label)
    trans  
  end
  
  # the translation rules can always be recreated for the translation
  # they are just links between language rules and translation
  def add_context_rules!(rules)
    translation_rules.each{|rule| rule.destroy}
    new_dependencies = {}
    rules.each do |rule|
      new_dependencies.merge!(rule.dependency)
      rule.translation = self
      rule.save
    end
    self.dependencies = (new_dependencies.empty? ? nil : new_dependencies)  
    save
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
