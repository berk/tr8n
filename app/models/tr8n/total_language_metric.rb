class Tr8n::TotalLanguageMetric < Tr8n::LanguageMetric

  def update_metrics!
    attribs = default_attributes
    attribs.each do |key, value|
      attribs[key] = Tr8n::DailyLanguageMetric.sum(key, :conditions => ["language_id = ?", language_id])
    end
    update_attributes(attribs)
  end
  
  def completeness
    return 0 if key_count == 0
    @completeness ||= (locked_key_count * 100 / key_count)
  end
  
end
