#--
# Copyright (c) 2010-2013 Michael Berkovich, tr8nhub.com
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

class Tr8n::Api::V1::OauthController < Tr8n::Api::V1::BaseController
  
  # http://tools.ietf.org/html/draft-ietf-oauth-v2-16#section-4.2
  # supported grant_type = authorization_code, password, refresh_token, client_credentials
  def request_token
    if request_param(:client_id).blank?
      return render_response(:error_description => "client_id must be provided", :error => :invalid_request)
    end

    unless application
      return render_response(:error_description => "Invalid client application id", :error => :unauthorized_client)
    end
    
    unless ["authorization_code", "password", "client_credentials"].include?(grant_type)
      return render_response(:error_description => "Only authorization_code, password and client_credentials grant types are currently supported", :error => :unsupported_grant_type)
    end

    send("oauth2_request_token_#{grant_type}")
  end 
  
  def validate_token
    token = Tr8n::Oauth::AccessToken.find_by_token(request_param(:access_token))
    if token && token.valid_token?
      render_response(:result => "OK")
    else
      render_response(:error => :invalid_token, :error_description => "invalid token")
    end
  end

  # add jsonp support
  def invalidate_token
    token = Tr8n::Oauth::AccessToken.find_by_token(request_param(:access_token))
    token.destroy if token
    render_response(:result => "OK")
  end
  
private

  def request_param(key)
    params[key].to_s.strip.blank? ? nil : params[key].to_s.strip
  end

  def grant_type
    @grant_type ||= request_param(:grant_type) || "authorization_code" 
  end

  def response_type
    @response_type ||= request_param(:response_type) || "code" 
  end
  
  # needs to be configured through Tr8n::Config
  def authenticate_user(username, password)
    Tr8n::Config.user_class_name.constantize.authenticate(username, password)
  end

  # request token with grant_type = authorization_code
  def oauth2_request_token_authorization_code
    if request_param(:code).blank?
      return render_response(:error_description => "Code must be provided", :error => :invalid_request)
    end
    
    request_token = Tr8n::Oauth::RequestToken.where("application_id = ? and token = ? and expires_at > ?", application.id, request_param(:code), Time.now).first
    unless request_token
      return render_response(:error_description => "Invalid authorization code", :error => :invalid_request)
    end
    
    unless request_token.valid_token?
      return render_response(:error_description => "Authorization code expired", :error => :invalid_request)
    end
    
    access_token = application.find_or_create_access_token(request_token.translator, request_token.scope)   
    refresh_token = application.create_refresh_token(access_token.translator, access_token.scope)
    request_token.destroy

    render_response(:access_token => access_token.token, :refresh_token => refresh_token.token, :expires_in => (access_token.expires_at.to_i - Time.now.to_i))
  end

  # request token with grant_type = password
  def oauth2_request_token_password
    if request_param(:username).blank?
      return render_response(:error_description => "Username must be provided", :error => :invalid_request)
    end
    
    if request_param(:password).nil?
      return render_response(:error_description => "Password must be provided", :error => :invalid_request)
    end

    user = authenticate_user(request_param(:username), request_param(:password))
    unless user and user.translator
      return render_response(:error_description => "Invalid username and/or password combination", :error => :invalid_request)
    end
    
    access_token = application.find_or_create_access_token(user.translator)
    refresh_token = application.create_refresh_token(access_token.translator, access_token.scope)
    render_response(:access_token => access_token.token, :refresh_token => refresh_token.token, :expires_in => (access_token.expires_at.to_i - Time.now.to_i))
  end

  # request token with grant_type = client_credentials
  def oauth2_request_token_client_credentials
    if request_param(:client_secret).blank?
      return render_response(:error_description => "Application secret must be provided", :error => :invalid_request)
    end

    if request_param(:client_secret) != application.secret
      return render_response(:error_description => "Invalid application secret", :error => :invalid_request)
    end

    client_token = application.create_client_token
    refresh_token = application.create_refresh_token(nil, client_token.scope)
    render_response(:access_token => client_token.token, :refresh_token => refresh_token.token, :expires_in => (client_token.expires_at.to_i - Time.now.to_i))
  end

  # request token with grant_type = refresh_token
  def oauth2_request_token_refresh_token
    if request_param(:refresh_token).blank?
      return render_response(:error_description => "Refresh token must be provided", :error => :invalid_request)
    end
    
    refresh_token = Tr8n::Oauth::RefreshToken.where("application_id = ? and token = ?", application.id, request_param(:refresh_token)).first
    unless refresh_token
      return render_response(:error_description => "Invalid refresh token", :error => :invalid_request)
    end

    unless refresh_token.valid_token?
      return render_response(:error_description => "Refresh token expired", :error => :invalid_request)
    end

    if refresh_token.translator
      access_token = refresh_token.application.create_access_token(refresh_token.translator, refresh_token.scope)
    else
      access_token = refresh_token.application.create_client_token(refresh_token.scope)
    end    
    refresh_token.destroy  

    refresh_token = application.create_refresh_token(access_token.translator, access_token.scope)
    render_response(:access_token => access_token.token, :refresh_token => refresh_token.token, :expires_in => (access_token.expires_at.to_i - Time.now.to_i))
  end
  
  # used by the request token process
  def render_response(response_params, opts = {})
    response_params = HashWithIndifferentAccess.new(response_params)
    
    # preserve state
    response_params[:state] = request_param(:state) if request_param(:state)
    
    # more scope validation must be done
    response_params[:scope] = request_param(:scope) if request_param(:scope)

    opts[:status] ||= begin
      if [:unsupported_grant_type, :invalid_request, :invalid_token].include?(response_params[:error])
        400
      elsif [:unauthorized_application].include?(response_params[:error])
        401
      else
        200
      end
    end
    render(:text => response_params.to_json, :status => opts[:status], :content_type => "text/json")
  end
  
end