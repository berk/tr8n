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
