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

class Tr8n::Firefox::TranslatorController < Tr8n::Firefox::BaseController

  before_filter :init_tr8n
  
  def index
    @source_url = params[:source] || "Firefox"
    
    if params[:label]
      @translation_key = Tr8n::TranslationKey.find_or_create(params[:label], "", {:source => @source_url})
    else
      @translation_key = Tr8n::TranslationKey.find(params[:translation_key_id])
    end
    
    @translations = @translation_key.inline_translations_for(tr8n_current_language)
    @translation = Tr8n::Translation.default_translation(@translation_key, tr8n_current_language, tr8n_current_translator)
    
    if params[:mode]  # switching modes
      @mode = params[:mode]
      return render(:partial => "translator_#{@mode}")
    else 
      @mode = (@translations.empty? ? "submit" : "votes") unless @mode
    end

    render(:layout => false)    
  end

  def translate
    @translation_key = Tr8n::TranslationKey.find(params[:translation_key_id])
    @translations = @translation_key.translations_for(tr8n_current_language)
    @source_url = params[:source_url] || request.env['HTTP_REFERER']
    
    pp @source_url
    
    unless request.post?
      trfe("Please use a translator window for submitting translations")
      return redirect_to(:action => :index, :label => @translation_key.label)
    end

    if params[:translation_id].blank?
      @translation = Tr8n::Translation.new(:translation_key => @translation_key, :language => tr8n_current_language, :translator => tr8n_current_translator)
    else  
      @translation = Tr8n::Translation.find(params[:translation_id])
    end
    
    @translation.label = sanitize_label(params[:translation][:label])

    unless @translation.can_be_edited_by?(tr8n_current_translator)
      tr8n_current_translator.tried_to_perform_unauthorized_action!("tried to update translation which is locked or belongs to another translator")
      trfe("You are not authorized to edit this translation")
      return redirect_to(:action => :index, :label => @translation_key.label)
    end  

    if @translation.blank?
      tr8n_current_translator.tried_to_perform_unauthorized_action!("tried to submit an empty translation")
      trfe("Your translation was empty and was not accepted")
      return redirect_to(:action => :index, :label => @translation_key.label)
    end
    
    unless @translation.uniq?
      tr8n_current_translator.tried_to_perform_unauthorized_action!("tried to submit an identical translation")
      trfe("There already exists such translation for this phrase. Please vote on it instead or suggest an elternative translation.")
      return redirect_to(:action => :index, :label => @translation_key.label)
    end
    
    unless @translation.clean?
      tr8n_current_translator.used_abusive_language!
      trfe("Your translation contains prohibited words and will not be accepted")
      return redirect_to(:action => :index, :label => @translation_key.label)
    end

    @translation.save_with_log!(tr8n_current_translator)
    @translation.reset_votes!(tr8n_current_translator)
    
    render :layout => false
  end

  def vote
    translation = Tr8n::Translation.find(params[:translation_id])
    translation.vote!(tr8n_current_translator, params[:vote])
    translation_key = translation.translation_key

    # this is called from the inline translator with reordering the translations based on ranks
    translations = translation_key.inline_translations_for(tr8n_current_language)
    render(:partial => '/tr8n/firefox/translator/translation_votes', :locals => {:translation_key => translation_key, :translations => translations, :section_key => ""})
  end

  def splash_screen
    render :layout => false
  end

private

  def current_user
    User.last
  end

  def current_locale
    "ru"
  end
  
  def init_tr8n
    Tr8n::Config.init(current_locale, current_user)
  end
end
