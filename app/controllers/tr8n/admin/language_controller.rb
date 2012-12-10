#--
# Copyright (c) 2010-2012 Michael Berkovich, tr8nhub.com
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
    params[:languages] = [params[:lang_id]] if params[:lang_id]
    if params[:languages]
      params[:languages].each do |lang_id|
        language = Tr8n::Language.find_by_id(lang_id)
        language.enable! if language
      end  
    end
    redirect_to_source
  end
  
  def disable
    params[:languages] = [params[:lang_id]] if params[:lang_id]
    if params[:languages]
      params[:languages].each do |lang_id|
        language = Tr8n::Language.find_by_id(lang_id)
        language.disable! if language
      end  
    end
    redirect_to_source
  end

  def users
    @users = Tr8n::LanguageUser.filter(:params => params, :filter => Tr8n::LanguageUserFilter)
  end

  def calculate_metrics
    Tr8n::LanguageMetric.calculate_language_metrics
    redirect_to_source
  end

  def calculate_total_metrics
    Tr8n::LanguageMetric.calculate_total_metrics
    redirect_to_source
  end
  
  def rules
    @rules = Tr8n::LanguageRule.filter(:params => params, :filter => Tr8n::LanguageRuleFilter)
  end

  def cases
    @cases = Tr8n::LanguageCase.filter(:params => params, :filter => Tr8n::LanguageCaseFilter)
  end
  
  def lb_update
    @language = Tr8n::Language.find_by_id(params[:lang_id]) unless params[:lang_id].blank?
    @language = Tr8n::Language.new unless @language
    
    render :layout => false
  end

  def update
    language = Tr8n::Language.find_by_id(params[:language][:id]) unless params[:language][:id].blank?
    
    if language
      language.update_attributes(params[:language])
    else
      language = Tr8n::Language.create(params[:language])
      language.reset!
    end
    
    redirect_to(:controller => "/tr8n/help", :action => "lb_done", :origin => params[:origin])
  end

  def case_rules
    @case_rules = Tr8n::LanguageCaseRule.filter(:params => params, :filter => Tr8n::LanguageCaseRuleFilter)
  end
  
  def case_values
    @case_values = Tr8n::LanguageCaseValueMap.filter(:params => params, :filter => Tr8n::LanguageCaseValueMapFilter)
  end
  
  def lb_value_map
    @map = Tr8n::LanguageCaseValueMap.find_by_id(params[:map_id]) if params[:map_id]
    @map ||= Tr8n::LanguageCaseValueMap.new(:language => tr8n_current_language)
    
    render :layout => false
  end
  
  def delete_value_map
    map = Tr8n::LanguageCaseValueMap.find_by_id(params[:map_id]) if params[:map_id]
    map.destroy if map

    redirect_to(:action => :index)
  end
  
  
end
