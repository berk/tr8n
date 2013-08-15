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

class Tr8n::Api::BaseController < ApplicationController
  
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

  rescue_from StandardError do |e|
    pp e, e.backtrace
    # log_exception(e)
    render_response("error" => e.message)
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

  def application
    return nil if params[:client_id].blank?
    @application ||= Tr8n::Application.find_by_key(params[:client_id])
  end

  def translator
    return nil if params[:access_token].blank?
    @translator ||= begin
      token = Tr8n::Oauth::AccessToken.find_by_token(params[:access_token])
      if token
        token.translator
      else
        nil
      end
    end
  end

  def language
    return nil if params[:locale].blank?
    @language ||= Tr8n::Language.for(params[:locale])
  end

  def ensure_get
    unless request.get?
      raise Tr8n::Exception.new("Must be a GET API call") 
    end
  end

  def ensure_post
    unless request.post?
      raise Tr8n::Exception.new("Must be a POST API call") 
    end
  end

  def ensure_translator
    unless translator
      raise Tr8n::Exception.new("Must be an authorized API call. Access token is missing or invalid.")
    end
  end

  def ensure_application
    unless application
      raise Tr8n::Exception.new("Valid aplication key must be provided.")
    end
  end

  def ensure_language
    unless language
      raise Tr8n::Exception.new("Valid locale must be provided.")
    end
  end

  def ensure_authorized_call
    # The call is either made on behalf a translator or application - signed with secret
    # ensure_translator
    # unless translator.admin?
    #   raise Tr8n::Exception.new("Must be an administrator to perform this operation.")
    # end
  end

  def ensure_valid_signature
    # params[:sig] - miust be signed with the app secret
    # only authorized apps can register keys
  end

  def limit
    params[:limit] || 20
  end

  def offset
    params[:offset] || 0
  end

  def page
    (params[:page] || 1).to_i
  end

  def per_page
    (params[:per_page] || 20).to_i
  end
  
  def sanitize_label(label)
    label.strip
  end
  
  def render_response(response)
    if params[:callback] # JSONP support
      return render(:text => "#{params[:callback]}(#{response.to_json});", :content_type => "text/javascript")
    end 
    
    if response.is_a?(Array)
      results = []
      response.collect do |obj| 
        if obj.class.method_defined?(:to_api_hash)
          results << obj.to_api_hash
        else
          results << obj
        end
      end 
      response = {:results => results}

      response['page']          = page if page > 1 || limit == results.size
      response['previous_page'] = prev_page if page > 1
      response['next_page']     = next_page if limit == results.size

    elsif response.class.method_defined?(:to_api_hash)
      response = response.to_api_hash
    end

    render(:text => response.to_json, :content_type => "text/json")
  end

  def render_error(msg)
    render_response(:error => msg)
  end

  def render_success(msg = nil)
    render_response(:status => msg || "Ok")
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