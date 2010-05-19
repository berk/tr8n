class Tr8n::MonthlyLanguageMetric < Tr8n::LanguageMetric

  def update_metrics!
    self.user_count = Tr8n::DailyLanguageMetric.sum(:user_count, :conditions => ["language_id = ? and metric_date >= ? and metric_date < ?", language_id, metric_date, metric_date + 1.month])
    self.translator_count = Tr8n::DailyLanguageMetric.sum(:translator_count, :conditions => ["language_id = ? and metric_date >= ? and metric_date < ?", language_id, metric_date, metric_date + 1.month])
    self.translation_count = Tr8n::DailyLanguageMetric.sum(:translation_count, :conditions => ["language_id = ? and metric_date >= ? and metric_date < ?", language_id, metric_date, metric_date + 1.month])
    save
  end
  
end
