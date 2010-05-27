require "pp"

class Tr8n::BaseController < ApplicationController

  before_filter :validate_current_user, :except => [:select, :switch]
  
  layout Tr8n::Config.site_info[:tr8n_layout]

  def tr8n_current_user
    Tr8n::Config.current_user
  end
  helper_method :tr8n_current_user

  def tr8n_current_language
    Tr8n::Config.current_language
  end
  helper_method :tr8n_current_language

  def tr8n_default_language
    Tr8n::Config.default_language
  end
  helper_method :tr8n_default_language

  def tr8n_current_translator
    Tr8n::Config.current_translator
  end
  helper_method :tr8n_current_translator
  
  def tr8n_current_user_is_admin?
    Tr8n::Config.current_user_is_admin?
  end
  helper_method :tr8n_current_user_is_admin?
  
  def tr8n_current_user_is_translator?
    Tr8n::Config.current_user_is_translator?
  end
  helper_method :tr8n_current_user_is_translator?

  def tr8n_current_user_is_manager?
    return false unless Tr8n::Config.current_user_is_translator?
    tr8n_current_translator.manager?
  end
  helper_method :tr8n_current_user_is_manager?
  
  def tr8n_current_user_is_guest?
    Tr8n::Config.current_user_is_guest?
  end
  helper_method :tr8n_current_user_is_guest?
  
private
  
  def tr8n_features_tabs
    @tabs ||= begin 
      tabs = Tr8n::Config.features.clone
      tabs = tabs.select{|tab| tab[:default_language]} if tr8n_current_language.default?
    
      unless tr8n_current_user_is_translator? and tr8n_current_translator.manager?
        tabs = tabs.select{|tab| !tab[:manager_only]}  
      end
      tabs
    end
  end
  helper_method :tr8n_features_tabs

  def redirect_to_source
    return redirect_to(params[:source_url]) unless params[:source_url].blank?
    redirect_to(request.env['HTTP_REFERER'])
  end

  def redirect_to_site_default_url
    redirect_to(Tr8n::Config.default_url)
  end

  def page
    params[:page] || 1
  end
  
  def per_page
    params[:per_page] || 30
  end
  
  def sanitize_label(label)
    CGI::escapeHTML(label.strip)
  end

  def validate_current_user
    if tr8n_current_user_is_guest?
      trfe("Your must be a registered user or a translator in order to access this section of the site.")
      return redirect_to(Tr8n::Config.default_url)
    end
  end

  def validate_current_translator
    if tr8n_current_user_is_translator? and tr8n_current_translator.blocked?
      trfe("Your translation privileges have been revoked. Please contact the site administrator for more details.")
      return redirect_to(Tr8n::Config.default_url)
    end
  end

  def validate_language_management
    # admins can do everything
    return if tr8n_current_user_is_admin?
    
    if tr8n_current_language.default?
      trfe("Only administrators can modify this language")
      return redirect_to(@tabs.first[:link])
    end

    unless tr8n_current_user_is_translator? and tr8n_current_translator.manager? 
      trfe("In order to manage a language you first must request to become a manager of that language. Please send your request to Geni support.")
      return redirect_to(@tabs.first[:link])
    end
  end
  
  def validate_default_language
    redirect_to(tr8n_features_tabs.first[:link]) if tr8n_current_language.default?
  end
  
  def validate_language
    return unless params[:language]
    return if params[:language][:fallback_language_id].blank? # default
    
    fallback_language = Tr8n::Language.find(params[:language][:fallback_language_id])
    
    while fallback_language do
      if fallback_language == tr8n_current_language
        return "You are creating an infinite loop with fallback languages. Please ensure that languages do not fall back onto each other."
      end
      fallback_language = fallback_language.fallback_language
    end
  end
    
  def validate_admin
    unless tr8n_current_user_is_admin?
      trfe("You must be an admin in order to view this section of the site")
      redirect_to_site_default_url
    end
  end
end