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

class Tr8n::Api::V1::BaseController < ApplicationController
  
  before_filter :check_api_enabled
  before_filter :cors_preflight_check

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
  
  # If this is a preflight OPTIONS request, then short-circuit the
  # request, return only the necessary headers and return an empty
  # text/plain.
  def cors_preflight_check
    if request.headers["HTTP_ORIGIN"] and access_control_allow_origin
      headers['Access-Control-Allow-Origin'] = request.headers["HTTP_ORIGIN"]
      headers['Access-Control-Expose-Headers'] = 'ETag'
      headers['Access-Control-Allow-Methods'] = 'GET, POST, PATCH, PUT, DELETE, OPTIONS, HEAD'
      headers['Access-Control-Allow-Headers'] = '*,X-Requested-With,X-Prototype-Version,Content-Type,If-Modified-Since,If-None-Match,Auth-User-Token'
      headers['Access-Control-Max-Age'] = '1728000'
      headers['Access-Control-Allow-Credentials'] = 'true'

      if request.method == :options
        return render(:text => '', :content_type => 'text/plain')
      end
    end    
  end

  def access_control_allow_origin
    #if request.headers["HTTP_ORIGIN"] && /^https?:\/\/(.*)\.some\.site\.com$/i.match(request.headers["HTTP_ORIGIN"])
    # origin    = request.headers['Origin'].to_s
    # from_geni = origin =~ /geni.com/
    # from_ssl  = ["http://#{SITE}", "https://#{SITE}"].include? origin

    # if from_geni || from_ssl
    #   origin
    # else
    #   ''
    # end
    true
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
    if params[:callback]
      return render(:text => "#{params[:callback]}(#{response.to_json});", :content_type => "text/javascript")
    end 
    
    if Tr8n::Config.api[:response_encoding] == "xml"
      render(:text => response.to_xml)
    else
      render(:text => response.to_json)
    end      
  end

  def source
    @source ||= begin
      if params[:source].blank?
        uri = URI.parse(request.env['HTTP_REFERER'])
        uri.query = nil
        uri.to_s
      else 
        CGI.unescape(params[:source])
      end
    end
  end

end