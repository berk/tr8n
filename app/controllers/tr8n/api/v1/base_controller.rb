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

class Tr8n::Api::V1::BaseController < ApplicationController
  unloadable

  before_filter :check_api_enabled
  

  if Tr8n::Config.api_skip_before_filters.any?
    skip_before_filter *Tr8n::Config.api_skip_before_filters
  end

  if Tr8n::Config.api_before_filters.any?
    before_filter *Tr8n::Config.api_before_filters
  end
  
  if Tr8n::Config.api_after_filters.any?
    after_filter *Tr8n::Config.api_after_filters
  end

private

  def check_api_enabled
    sanitize_api_response({"error" => "Api is disabled"}) unless Tr8n::Config.enable_api?
  end

  def check_guest_user
    sanitize_api_response({:guest => true}) if tr8n_current_user_is_guest?
  end

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
  
  def sanitize_label(label)
    label.strip
  end
  
  def sanitize_api_response(response)
    if Tr8n::Config.api[:response_encoding] == "xml"
      render(:text => response.to_xml)
    else
      render(:text => response.to_json)
    end      
  end

end