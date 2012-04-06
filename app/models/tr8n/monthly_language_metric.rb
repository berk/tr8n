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
#
#-- Tr8n::MonthlyLanguageMetric Schema Information
#
# Table name: tr8n_language_metrics
#
#  id                      INTEGER         not null, primary key
#  type                    varchar(255)    
#  language_id             integer         not null
#  metric_date             date            
#  user_count              integer         default = 0
#  translator_count        integer         default = 0
#  translation_count       integer         default = 0
#  key_count               integer         default = 0
#  locked_key_count        integer         default = 0
#  translated_key_count    integer         default = 0
#  created_at              datetime        
#  updated_at              datetime        
#
# Indexes
#
#  index_tr8n_language_metrics_on_created_at     (created_at) 
#  index_tr8n_language_metrics_on_language_id    (language_id) 
#
#++

class Tr8n::MonthlyLanguageMetric < Tr8n::LanguageMetric

  def update_metrics!
    attribs = default_attributes
    attribs.each do |key, value|
      attribs[key] = Tr8n::DailyLanguageMetric.where("language_id = ? and metric_date >= ? and metric_date < ?", language_id, metric_date, metric_date + 1.month).sum(key)
    end
    update_attributes(attribs)
  end
  
end
