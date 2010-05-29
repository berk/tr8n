class Tr8n::MonthlyLanguageMetric < Tr8n::LanguageMetric

  def update_metrics!
    attribs = {:user_count => 0, :translator_count => 0, :translation_count => 0, :key_count => 0, :locked_key_count => 0}
    attribs.each do |key, value|
      attribs[key] = Tr8n::DailyLanguageMetric.sum(key, :conditions => ["language_id = ? and metric_date >= ? and metric_date < ?", language_id, metric_date, metric_date + 1.month])
    end
    update_attributes(attribs)
  end
  
end
