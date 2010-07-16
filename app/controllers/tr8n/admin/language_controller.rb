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

class Tr8n::Admin::LanguageController < Tr8n::Admin::BaseController
  
  def index
    @languages = Tr8n::Language.filter(:params => params, :filter => Tr8n::LanguageFilter)
  end

  def view
    @lang = Tr8n::Language.find(params[:lang_id])
  end

  def enable
    @language = Tr8n::Language.find(params[:lang_id])
    @language.enable!
    trfn("#{@language.english_name} language has been enabled")
    redirect_to_source
  end
  
  def disable
    @language = Tr8n::Language.find(params[:lang_id])
    @language.disable!
    trfn("#{@language.english_name} language has been disabled")
    redirect_to_source
  end
    
  def charts
    
  end

  def metrics
    @metrics = Tr8n::LanguageMetric.filter(:params => params, :filter => Tr8n::LanguageMetricFilter)
  end

  def users
    @users = Tr8n::LanguageUser.filter(:params => params, :filter => Tr8n::LanguageUserFilter)
  end

  def calculate_metrics
    Tr8n::LanguageMetric.calculate_language_metrics
    
    trfn("Languages metrics have been recalculated")
    redirect_to_source
  end
  
  def rules
    @rules = Tr8n::LanguageRule.filter(:params => params, :filter => Tr8n::LanguageRuleFilter)
  end
  
  def lb_update
    @language = Tr8n::Language.find_by_id(params[:lang_id]) unless params[:lang_id].blank?
    @language = Tr8n::Language.new unless @language
    
    render :layout => false
  end

  def update
    language = Tr8n::Language.find_by_id(params[:language][:id]) unless params[:language][:id].blank?
    
    if language
      trfn("The language has been updated")
      language.update_attributes(params[:language])
    else
      trfn("The new language has been addeded")
      language = Tr8n::Language.create(params[:language])
    end
    
    redirect_to_source
  end
  
end
