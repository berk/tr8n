class Tr8n::DailyLanguageMetric < Tr8n::LanguageMetric

  def update_metrics!
    self.user_count = Tr8n::LanguageUser.count(:conditions => ["language_id = ? and created_at >= ? and created_at < ?", language_id, metric_date, metric_date + 1.day])
    self.translator_count = Tr8n::LanguageUser.count(:conditions => ["language_id = ? and created_at >= ? and created_at < ? and translator_id is not null", language_id, metric_date, metric_date + 1.day])
    self.translation_count = Tr8n::Translation.count(:conditions => ["language_id = ? and created_at >= ? and created_at < ?", language_id, metric_date, metric_date + 1.day])
    save
  end
  
end
