#--
# Copyright (c) 2010-2012 Michael Berkovich, Geni Inc
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

class Tr8n::Admin::TranslatorController < Tr8n::Admin::BaseController
  unloadable

  def index
    @translators = Tr8n::Translator.filter(:params => params, :filter => Tr8n::TranslatorFilter)
  end

  def view
    @translator = Tr8n::Translator.find(params[:translator_id])
    redirect_to(:action => :index) unless @translator

    klass = {
      :metrics => Tr8n::TranslatorMetric,
      :languages => Tr8n::LanguageUser,
      :translations => Tr8n::Translation,
      :votes => Tr8n::TranslationVote,
      :locks => Tr8n::TranslationKeyLock,
      :following => Tr8n::TranslatorFollowing,
      :messages => Tr8n::LanguageForumMessage,
      :reports => Tr8n::TranslatorReport,
      :activity => Tr8n::TranslatorLog,
    }[params[:mode].to_sym] if params[:mode]
    klass ||= Tr8n::TranslatorLog

    if params[:mode] == "languages"
      filter = {"wf_c0" => "user_id", "wf_o0" => "is", "wf_v0_0" => @translator.user_id}
      extra_params = {:user_id => @translator.user_id, :mode => params[:mode]}
    else
      filter = {"wf_c0" => "translator_id", "wf_o0" => "is", "wf_v0_0" => @translator.id}
      extra_params = {:translator_id => @translator.id, :mode => params[:mode]}
    end
    
    @results = klass.filter(:params => params.merge(filter))
    @results.wf_filter.extra_params.merge!(extra_params)
  end

  def delete
    params[:translators] = [params[:translator_id]] if params[:translator_id]
    if params[:translators]
      params[:translators].each do |translator_id|
        translator = Tr8n::Translator.find_by_id(translator_id)
        translator.destroy if translator
      end  
    end
    redirect_to_source
  end

  def block
    @translator = Tr8n::Translator.find(params[:translator_id])
    @translator.block!(tr8n_current_user, params[:reason])
    redirect_to_source
  end

  def unblock
    @translator = Tr8n::Translator.find(params[:translator_id])    
    @translator.unblock!(tr8n_current_user, params[:reason])
    redirect_to_source
  end

  def update_level
    @translator = Tr8n::Translator.find(params[:translator_id])
    @translator.update_level!(tr8n_current_user, params[:new_level], params[:reason])
    redirect_to_source
  end

  def demote
    @translator = Tr8n::Translator.find(params[:translator_id])
    @translator.demote!(tr8n_current_user, params[:reason])
    redirect_to_source
  end
  
  def update_stats
    Tr8n::Translator.all.each do |trans|
      trans.update_total_metrics!
    end
  
    redirect_to :action => :index
  end
   
  def lb_register
    @translator = Tr8n::Translator.new    
    render :layout => false
  end

  def register
    user_class = Tr8n::Config.site_info[:user_info][:class_name]
    user = user_class.constantize.find_by_id(params[:translator][:user_id])
    unless user
      return redirect_to_source
    end
    
    translator = Tr8n::Translator.find_by_user_id(user.id)
    if translator
      return redirect_to_source
    end
    
    Tr8n::Translator.create(:user_id => params[:translator][:user_id])
    redirect_to_source
  end

  def following
    @following = Tr8n::TranslatorFollowing.filter(:params => params, :filter => Tr8n::TranslatorFollowingFilter)
  end

  def reports
    @reports = Tr8n::TranslatorReport.filter(:params => params, :filter => Tr8n::TranslatorReportFilter)
  end
   
  def log
    @logs = Tr8n::TranslatorLog.filter(:params => params, :filter => Tr8n::TranslatorLogFilter)
  end

  def metrics
    @metrics = Tr8n::TranslatorMetric.filter(:params => params, :filter => Tr8n::TranslatorMetricFilter)
  end

  def ip_locations
    @ip_locations = Tr8n::IpLocation.filter(:params => params, :filter => Tr8n::IpLocationFilter)
  end
     
  def generate_access_key
    @translator = Tr8n::Translator.find(params[:translator_id])
    redirect_to(:action => :index) unless @translator
    @translator.generate_access_key!(tr8n_current_user)
    redirect_to_source
  end   
end
