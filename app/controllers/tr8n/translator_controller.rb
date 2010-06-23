class Tr8n::TranslatorController < Tr8n::BaseController

  def index
    @fallback_language = (tr8n_current_translator.fallback_language || tr8n_default_language)
  end

  # if the site does not have any users, translators table can be used as the primary table
  def login
    # to be implemented
  end

  def logout
    # to be implemented
  end

  def register
    # to be implemented
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
end