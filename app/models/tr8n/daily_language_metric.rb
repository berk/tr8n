class Tr8n::DailyLanguageMetric < Tr8n::LanguageMetric

  def update_metrics!
    self.user_count = Tr8n::LanguageUser.count(:conditions => ["language_id = ? and created_at >= ? and created_at < ?", language_id, metric_date, metric_date + 1.day])
    
    self.translator_count = Tr8n::LanguageUser.count(:conditions => ["language_id = ? and created_at >= ? and created_at < ? and translator_id is not null", language_id, metric_date, metric_date + 1.day])
    
    self.translation_count = Tr8n::Translation.count(:conditions => ["language_id = ? and created_at >= ? and created_at < ?", language_id, metric_date, metric_date + 1.day])
    
    self.key_count = Tr8n::TranslationKey.count(:conditions => ["created_at >= ? and created_at < ?", metric_date, metric_date + 1.day])
    
    locked_keys = "select tr8n_translation_key_locks.translation_key_id from tr8n_translation_key_locks where tr8n_translation_key_locks.language_id = ? and locked = ? and tr8n_translation_key_locks.created_at >= ? and tr8n_translation_key_locks.created_at < ?"
    self.locked_key_count = Tr8n::TranslationKey.count(:conditions => ["id in (#{locked_keys})", language_id, true, metric_date, metric_date + 1.day])
    
    save
  end
  
  
  
end
