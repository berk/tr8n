class Tr8n::ChartController < Tr8n::BaseController

  def language_completeness
    lang = Tr8n::Language.find(params[:language_id])

    sets = []
    sets << ["Not Translated", lang.total_metric.not_translated_count]
    sets << ["Translated", lang.total_metric.locked_key_count]
    sets << ["Pending Approval", lang.total_metric.translated_key_count - lang.total_metric.locked_key_count]
    
    result = generate_chart_xml(:sets => sets, :caption => "",  :subcaption => "",
                                :subject=>'Phrase', :xAxisName=>'Language', 
                                :yAxisName=>'Phrase', :showNames => '0',
                                :colors => ['FF0000', '00FF00', 'FFFF00'])
    send_data(result, :type=>'text/xml', :charset=>'utf-8')
  end
  
  def translator_rank
    if params[:language_id]
      metric = tr8n_current_translator.metric_for(Tr8n::Language.find(params[:language_id]))
    else
      metric = tr8n_current_translator.total_metric  
    end

    sets = []
    sets << ["Rejected", metric.rejected_translations]
    sets << ["Accepted", metric.accepted_translations]
    sets << ["Pending Votes", metric.pending_vote_translations]
    
    result = generate_chart_xml(:sets => sets, :caption => "",  :subcaption => "",
                                :subject=>'Translation', :xAxisName=>'Language', 
                                :yAxisName=>'Phrase', :showNames => '0',
                                :colors => ['FF0000', '00FF00', 'FFFF00'])
    send_data(result, :type=>'text/xml', :charset=>'utf-8')
  end  
end
