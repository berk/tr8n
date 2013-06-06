
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

class Tr8n::Tools::LanguageSelectorController < Tr8n::BaseController

  skip_before_filter :validate_guest_user
  skip_before_filter :validate_current_translator

  layout 'tr8n/tools/lightbox'

  # language selector window
  def index
    @inline_translations_allowed = false
    @inline_translations_enabled = false
  
    if tr8n_current_user_is_translator? 
      unless tr8n_current_translator.blocked?
        @inline_translations_allowed = true
        @inline_translations_enabled = tr8n_current_translator.enable_inline_translations?
      end
    else
      @inline_translations_allowed = Tr8n::Config.open_registration_mode?
    end
  
    @inline_translations_allowed = true if tr8n_current_user_is_admin?
  
    @source_url = request.env['HTTP_REFERER']
    @source_url.gsub!("locale", "previous_locale") if @source_url
  
    @all_languages = Tr8n::Language.enabled_languages
    @user_languages = Tr8n::LanguageUser.languages_for(tr8n_current_user) unless tr8n_current_user_is_guest?
  end

  def change
    Tr8n::LanguageUser.create_or_touch(tr8n_current_user, Tr8n::Language.find_by_locale(params[:locale]))

    if can_generate_signed_request?
      @generate_signed_request = true
    end

    render(:layout => false)
  end

  def toggle_inline_translations
    # redirect to login if not a translator
    if tr8n_current_user_is_translator?
      tr8n_current_translator.toggle_inline_translations!
    end
    
    if can_generate_signed_request?
      @generate_signed_request = true
    end

    render(:layout => false)
  end

private 

  def can_generate_signed_request?
    Tr8n::Config.remote_application and tr8n_current_translator and Tr8n::Config.remote_application.translators.include?(tr8n_current_translator)
  end

end