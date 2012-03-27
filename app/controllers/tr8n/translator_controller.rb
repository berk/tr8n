#--
# Copyright (c) 2010-2011 Michael Berkovich, tr8n.net
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

class Tr8n::TranslatorController < Tr8n::BaseController

  def registration
    if params[:agree] == "yes"
      Tr8n::Config.current_translator # this will register a translator
      trfn("Thank you! You have been register as a translator")
      return redirect_to("/tr8n/phrases")
    end
  end

  def index
    @fallback_language = (tr8n_current_translator.fallback_language || tr8n_default_language)
  end

  def update_translator_section
    @fallback_language = (tr8n_current_translator.fallback_language || tr8n_default_language)
    unless request.post?
      return render(:partial => params[:section], :locals => {:mode => params[:mode].to_sym})
    end
    
    tr8n_current_translator.update_attributes(params[:translator])
    
    tr8n_current_translator.reload
    @fallback_language = (tr8n_current_translator.fallback_language || tr8n_default_language)
    render(:partial => params[:section], :locals => {:mode => :view})
  end
  
  def follow
    if params[:translation_key_id]
      object = Tr8n::TranslationKey.find_by_id(params[:translation_key_id])
      trfn("You are now following this translation key") if object
    end
    tr8n_current_translator.follow(object) if object
    redirect_to_source
  end

  def unfollow
    if params[:translation_key_id]
      object = Tr8n::TranslationKey.find_by_id(params[:translation_key_id])
    end
    tr8n_current_translator.unfollow(object) if object
    redirect_to_source
  end
  
  def lb_report
    if params[:translation_key_id]
      @reported_object = Tr8n::TranslationKey.find_by_id(params[:translation_key_id])
    elsif params[:translation_id]
      @reported_object = Tr8n::Translation.find_by_id(params[:translation_id])
    elsif params[:message_id]
      @reported_object = Tr8n::LanguageForumMessage.find_by_id(params[:message_id])
    elsif params[:comment_id]
      @reported_object = Tr8n::TranslationKeyComment.find_by_id(params[:comment_id])
    end
    render :layout => false
  end
  
  def submit_report
    if request.post?
      reported_object = params[:object_type].constantize.find(params[:object_id])
      Tr8n::TranslatorReport.submit(Tr8n::Config.current_translator, reported_object, params[:reason], params[:comment])
      trfn("Thank you for submitting your report.")
    end
    
    redirect_to_source
  end
  
end