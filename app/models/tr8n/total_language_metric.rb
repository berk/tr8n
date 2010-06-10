class Tr8n::TotalLanguageMetric < Tr8n::LanguageMetric

  def update_metrics!
    attribs = default_attributes
    attribs.each do |key, value|
      attribs[key] = Tr8n::DailyLanguageMetric.sum(key, :conditions => ["language_id = ?", language_id])
    end
    update_attributes(attribs)

    language.update_attributes(:completeness => language_completeness)
  end
  
  def language_completeness
    keys_with_approved_translations_count = Tr8n::TranslationKey.count("distinct tr8n_translation_keys.id", 
        :conditions => ["tr8n_translations.language_id = ? and tr8n_translations.rank >= ?", language_id, Tr8n::Config.translation_threshold], 
        :joins => "join tr8n_translations on tr8n_translation_keys.id = tr8n_translations.translation_key_id") 
    
    return 0 if keys_with_approved_translations_count == 0
    
    (keys_with_approved_translations_count * 100 / key_count)
  end
  
  def completeness
    language.completeness
  end
  
end
