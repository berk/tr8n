#--
# Copyright (c) 2010 Michael Berkovich, Geni Inc
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#++

class Tr8n::ChartController < Tr8n::BaseController

  before_filter :validate_current_translator

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
