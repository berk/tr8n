module Tr8n::DashboardHelper

  def language_completeness_chart(language)
    values = [language.total_metric.not_translated_count, language.total_metric.locked_key_count, language.total_metric.translated_key_count - language.total_metric.locked_key_count]
    names = ["Not Translated", "Translated", "Pending Approval"]
    chart_url = "https://chart.googleapis.com/chart?cht=p3&chs=350x80&chd=t:#{values.join(',')}&chl=#{names.join('|')}"
    image_tag(chart_url)
  end
  
  def translator_rank_chart(language = nil)
    metric = language ? tr8n_current_translator.metric_for(language) : tr8n_current_translator.total_metric
    values = [metric.rejected_translations, metric.accepted_translations, metric.pending_vote_translations]
    names = ["Rejected", "Accepted", "Pending Votes"]
    chart_url = "https://chart.googleapis.com/chart?cht=p3&chs=350x80&chd=t:#{values.join(',')}&chl=#{names.join('|')}"
    image_tag(chart_url)
  end  

end