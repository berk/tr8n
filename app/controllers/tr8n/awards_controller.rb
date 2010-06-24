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

class Tr8n::AwardsController < Tr8n::BaseController

  before_filter :validate_current_translator
  
  def index
    params[:mode] = "all" if tr8n_current_language.default?
    
    if params[:mode] == "all"
      @translator_metrics = Tr8n::TranslatorMetric.find(:all, :conditions => ["language_id is null"], 
                  :order => "total_translations desc, total_votes desc", :limit => 23)
    else
      @translator_metrics = Tr8n::TranslatorMetric.find(:all, :conditions => ["language_id = ?", tr8n_current_language.id], 
                  :order => "total_translations desc, total_votes desc", :limit => 23)
    end
    
    @leaders = @translator_metrics[0..2]
    @runners = (@translator_metrics.size > 3) ? @translator_metrics[3..-1] : []
  end
    
end