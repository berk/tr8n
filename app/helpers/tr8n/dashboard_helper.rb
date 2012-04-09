#--
# Copyright (c) 2010-2012 Michael Berkovich, tr8n.net
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

module Tr8n::DashboardHelper

  def language_completeness_chart(language)
    values = [language.total_metric.not_translated_count, language.total_metric.locked_key_count, language.total_metric.translated_key_count - language.total_metric.locked_key_count]
    names = ["Not Translated", "Translated", "Pending Approval"]
    colors = ['FF0000', '00FF00', 'FFFF00']
    chart_url = "https://chart.googleapis.com/chart?cht=p3&chs=350x80&chd=t:#{values.join(',')}&chl=#{names.join('|')}&chco=#{colors.join('|')}"
    image_tag(chart_url)
  end
  
  def translator_rank_chart(language = nil)
    metric = language ? tr8n_current_translator.metric_for(language) : tr8n_current_translator.total_metric
    values = [metric.rejected_translations, metric.accepted_translations, metric.pending_vote_translations]
    names = ["Rejected", "Accepted", "Pending Votes"]
    colors = ['FF0000', '00FF00', 'FFFF00']
    chart_url = "https://chart.googleapis.com/chart?cht=p3&chs=350x80&chd=t:#{values.join(',')}&chl=#{names.join('|')}&chco=#{colors.join('|')}"
    image_tag(chart_url)
  end  

end