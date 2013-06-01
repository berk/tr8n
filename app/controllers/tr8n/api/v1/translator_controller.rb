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

class Tr8n::Api::V1::TranslatorController < Tr8n::Api::V1::BaseController

  def index
    ensure_get
    ensure_translator     

    render_response(translator)
  end

  def applications
    ensure_get
    ensure_translator      

    render_response(translator.applications)
  end

  def authorize
    ensure_post

    # ensure that there is a way to authenticate the user in the container application
    user = Tr8n::Config.user_class_name.constantize.authenticate(params[:email], params[:password])
    unless user 
      return render_error("Invlaid email/password combination")
    end
    
    unless user.translator
      return render_error("Please visit the site and accept the terms of use")
    end

    access_token = Tr8n::AccessToken.find_or_create(user.translator)
    render_response(:access_token => access_token.token)
  end

  def enable_inline_translations
    ensure_get
    ensure_translator
    Tr8n::Translator.register.enable_inline_translations!
    render_success
  end
  
  def disable_inline_translations
    ensure_get
    ensure_translator
    Tr8n::Translator.register.disable_inline_translations!
    render_success
  end

end