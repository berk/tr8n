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

class Tr8n::TranslatorController < Tr8n::BaseController
  unloadable
  
  def index
    @translator = Tr8n::Translator.find_by_id(params[:id]) if params[:id]
    @translator ||= Tr8n::Config.current_translator
    @languages = Tr8n::LanguageUser.languages_for(@translator.user)
  end

  def registration
    if params[:agree] == "yes"
      Tr8n::Config.current_translator # this will register a translator
      trfn("Thank you! You have been register as a translator")
      return redirect_to("/tr8n/phrases")
    end
  end

  def settings
    @fallback_language = (tr8n_current_translator.fallback_language || tr8n_default_language)

    if request.post?
      tr8n_current_translator.update_attributes(params[:translator])
      tr8n_current_translator.reload

      trfn("Your information has been updated")
      @fallback_language = (tr8n_current_translator.fallback_language || tr8n_default_language)
    end
  end

  def generate_access_key
    Tr8n::Config.current_translator.generate_access_key!
    trfn("New access key has be generated")
    redirect_to_source
  end
  
  def follow
    if params[:translation_key_id]
      object = Tr8n::TranslationKey.find_by_id(params[:translation_key_id])
      trfn("You are now following this translation key") if object
    elsif params[:translator_id]
      object = Tr8n::Translator.find_by_id(params[:translator_id])
      trfn("You are now following {translator}", nil, :translator => object ) if object      
    end

    if object
      tr8n_current_translator.follow(object) 
    end

    redirect_to_source
  end

  def unfollow
    if params[:translation_key_id]
      object = Tr8n::TranslationKey.find_by_id(params[:translation_key_id])
    elsif params[:translator_id]
      object = Tr8n::Translator.find_by_id(params[:translator_id])
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
  
  def assignments
    @components = Tr8n::Component.find(:all, 
          :conditions => ["ct.translator_id = ?", Tr8n::Config.current_translator.id],
          :joins => [
            "join tr8n_component_translators as ct on tr8n_components.id = ct.component_id",
          ]
    )
  end

  def notifications
    @notifications = Tr8n::Notification.paginate(:conditions => ["translator_id = ?", Tr8n::Config.current_translator.id],
                                                 :page => page, :per_page => per_page, :order => "created_at desc")
  end

  def lb_notifications
    @notifications = Tr8n::Notification.paginate(:conditions => ["translator_id = ?", Tr8n::Config.current_translator.id],
                                                 :page => page, :per_page => per_page, :order => "created_at desc")
    render :layout => false
  end

  def following
    @translators = Tr8n::TranslatorFollowing.find(:all, 
                   :conditions => ["translator_id = ? and object_type = ?", tr8n_current_translator.id, "Tr8n::Translator"]).collect{|f| f.object}
    @translation_keys = Tr8n::TranslatorFollowing.find(:all, 
                   :conditions => ["translator_id = ? and object_type = ?", tr8n_current_translator.id, "Tr8n::TranslationKey"]).collect{|f| f.object}
  end

end