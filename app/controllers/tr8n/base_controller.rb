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

module Tr8n
  class BaseController < ApplicationController

    layout Tr8n::Config.site_info[:tr8n_layout]

    if Tr8n::Config.tr8n_helpers.any?
      helper *Tr8n::Config.tr8n_helpers
    end

    if Tr8n::Config.skip_before_filters.any?
      skip_before_filter *Tr8n::Config.skip_before_filters
    end

    if Tr8n::Config.before_filters.any?
      before_filter *Tr8n::Config.before_filters
    end
  
    if Tr8n::Config.after_filters.any?
      after_filter *Tr8n::Config.after_filters
    end
  
    before_filter :validate_tr8n_enabled, :except => [:translate]
    before_filter :validate_guest_user, :except => [:select, :switch, :translate, :table, :registration]
    before_filter :validate_current_translator, :except => [:select, :switch, :translate, :table, :registration]
    before_filter :validate_remote_application

    layout Tr8n::Config.site_info[:tr8n_layout]
  
  private
  
    def validate_remote_application
      return if params[:origin].blank?
      domain = Tr8n::TranslationDomain.find_or_create(params[:origin])
      Tr8n::Config.set_remote_application(domain.application)
    end

    def render_lightbox
      render(:layout => false)
    end

    def dismiss_lightbox
      redirect_to(:controller => "/tr8n/help", :action => "lb_done", :origin => params[:origin])
    end
  
    def tr8n_features_tabs
      @tabs ||= begin 
        tabs = Tr8n::Config.features.clone
        unless Tr8n::Config.multiple_base_languages?
          tabs = tabs.select{|tab| tab[:default_language]} if tr8n_current_language.default?
        end
    
        unless tr8n_current_user_is_translator? and tr8n_current_translator.manager?
          tabs = tabs.select{|tab| !tab[:manager_only]}  
        end

        if tr8n_current_language.dir == 'rtl'
          tabs = tabs.reverse 
        end
        
        tabs
      end
    end
    helper_method :tr8n_features_tabs

    def redirect_to_source
      # Do not allow redirects to external websites
      escaped_origin_host = Regexp.escape("#{request.protocol}#{request.host}")
      if(!params[:source_url].blank? && params[:source_url] =~ /^#{escaped_origin_host}/)
        return redirect_to(params[:source_url])
      end
      return redirect_to(request.env['HTTP_REFERER']) unless request.env['HTTP_REFERER'].blank?
      redirect_to_site_default_url
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
  #  do not double escape    
  #  CGI::escapeHTML(label.strip)
     ERB::Util.html_escape(label.strip)
    end

    # handle disabled state for tr8n
    def validate_tr8n_enabled
      if Tr8n::Config.disabled?
        trfe("You don't have rights to access that section.")
        return redirect_to(Tr8n::Config.default_url)
      end
    end

    # guest users can still switch between languages outside of the site
    def validate_guest_user
      if tr8n_current_user_is_guest?
        trfe("You must be a registered user in order to access this section of the site.")
        return redirect_to(Tr8n::Config.default_url)
      end
    end

    # make sure that the current user is a translator
    def validate_current_translator
      if tr8n_current_user_is_translator? and tr8n_current_translator.blocked?
        trfe("Your translation privileges have been revoked. Please contact the site administrator for more details.")
        return redirect_to(Tr8n::Config.default_url)
      end

      return if Tr8n::Config.current_user_is_translator?

      redirect_to("/tr8n/translator/registration")
    end

    # make sure that the current user is a language manager
    def validate_language_management
      # admins can do everything
      return if tr8n_current_user_is_admin?
    
      if tr8n_current_language.default?
        trfe("Only administrators can modify this language")
        return redirect_to(tr8n_features_tabs.first[:link])
      end

      unless tr8n_current_user_is_translator? and tr8n_current_translator.manager? 
        trfe("In order to manage a language you first must request to become a manager of that language.")
        return redirect_to(tr8n_features_tabs.first[:link])
      end
    end
  
    def validate_default_language
      return if Tr8n::Config.multiple_base_languages?
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
end