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

class Tr8n::LanguageCasesController < Tr8n::BaseController
  unloadable

  before_filter :validate_current_translator
  before_filter :validate_language_management, :only => [:index]
    
  # used by a client app
  def index
    conditions = ["language_id = ? and (reported is null or reported = ?)", tr8n_current_language.id, false]
    
    unless params[:search].blank?
      conditions[0] << " and keyword like ?" 
      conditions << "%#{params[:search]}%"
    end
    
    @maps = Tr8n::LanguageCaseValueMap.paginate(:per_page => per_page, :page => page, :conditions => conditions, :order => "updated_at desc")    
  end
  
  def manager
    @lcase = Tr8n::LanguageCase.by_id(params[:case_id]) unless params[:case_id].blank?
    @rule = Tr8n::LanguageCaseRule.by_id(params[:rule_id]) unless params[:rule_id].blank?
    
    @map = Tr8n::LanguageCaseValueMap.by_language_and_keyword(tr8n_current_language, params[:case_key])
    @map ||= Tr8n::LanguageCaseValueMap.new(:language => tr8n_current_language, :translator => tr8n_current_translator, :keyword => params[:case_key])
    
    render :layout => false
  end
  
  def switch_manager_mode
    @map = Tr8n::LanguageCaseValueMap.by_language_and_keyword(tr8n_current_language, params[:map_keyword])
    @map ||= Tr8n::LanguageCaseValueMap.new(:language => tr8n_current_language, :keyword => params[:case_key], :reported => false)
    
    render :partial => params[:mode]
  end
  
  def update_value_map
    map = Tr8n::LanguageCaseValueMap.find_by_id(params[:map_id]) unless params[:map_id].blank?
    map ||= Tr8n::LanguageCaseValueMap.new(:language => tr8n_current_language, :reported => false)
    map.keyword = params[:case_key]
    map.map = params[:map][:map]
    map.save_with_log!(tr8n_current_translator)

    redirect_to_source
  end
  
  def delete_value_map
    map = Tr8n::LanguageCaseValueMap.find_by_id(params[:map_id]) if params[:map_id]
    map.destroy_with_log!(tr8n_current_translator) if map

    redirect_to_source
  end
  
  def report_value_map
    map = Tr8n::LanguageCaseValueMap.find_by_id(params[:map_id]) unless params[:map_id].blank?
    map.report_with_log!(tr8n_current_translator) if map
    
    redirect_to_source
  end
  
end