class Tr8n::TotalLanguageMetric < Tr8n::LanguageMetric

  def update_metrics!
    self.user_count = Tr8n::DailyLanguageMetric.sum(:user_count, :conditions => ["language_id = ?", language_id])
    self.translator_count = Tr8n::DailyLanguageMetric.sum(:translator_count, :conditions => ["language_id = ?", language_id])
    self.translation_count = Tr8n::DailyLanguageMetric.sum(:translation_count, :conditions => ["language_id = ?", language_id])
    save
  end
  
end
