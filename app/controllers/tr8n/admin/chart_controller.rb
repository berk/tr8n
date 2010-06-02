class Tr8n::Admin::ChartController < Tr8n::Admin::BaseController

  def users_by_language
    sets = []
    Tr8n::Language.all.each do |lang|
      metric = Tr8n::TotalLanguageMetric.find_by_language_id(lang.id)
      next unless metric
      sets << [lang.english_name, metric.user_count]
    end
    
    result = generate_chart_xml(:sets=>sets, :subject=>'Users', :xAxisName=>'Language', :yAxisName=>'User Count')
    send_data(result, :type=>'text/xml', :charset=>'utf-8')
  end

  def translators_by_language
    sets = []
    Tr8n::Language.all.each do |lang|
      metric = Tr8n::TotalLanguageMetric.find_by_language_id(lang.id)
      next unless metric
      sets << [lang.english_name, metric.translator_count]
    end
    
    result = generate_chart_xml(:sets=>sets, :subject=>'Translator', :xAxisName=>'Language', :yAxisName=>'Translator Count')
    send_data(result, :type=>'text/xml', :charset=>'utf-8')
  end

  def translations_by_language
    sets = []
    Tr8n::Language.all.each do |lang|
      metric = Tr8n::TotalLanguageMetric.find_by_language_id(lang.id)
      next unless metric
      sets << [lang.english_name, metric.translation_count]
    end
    
    result = generate_chart_xml(:sets=>sets, :subject=>'Translation', :xAxisName=>'Language', :yAxisName=>'Translation Count')
    send_data(result, :type=>'text/xml', :charset=>'utf-8')
  end

  def locked_keys_by_language
    sets = []
    Tr8n::Language.all.each do |lang|
      metric = Tr8n::TotalLanguageMetric.find_by_language_id(lang.id)
      next unless metric
      sets << [lang.english_name, metric.locked_key_count]
    end
    
    result = generate_chart_xml(:sets=>sets, :subject=>'Locked Key', :xAxisName=>'Language', :yAxisName=>'Locked Key Count')
    send_data(result, :type=>'text/xml', :charset=>'utf-8')
  end
  
end
