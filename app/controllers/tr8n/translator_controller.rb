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
  
end