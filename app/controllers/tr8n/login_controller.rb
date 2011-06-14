#--
# Copyright (c) 2010-2011 Michael Berkovich
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

class Tr8n::LoginController < ApplicationController

  layout Tr8n::Config.site_info[:tr8n_layout]

  def index
    if request.post?
      translator = Tr8n::Translator.find_by_email_and_password(params[:email], params[:password])
      
      if translator
        login!(translator)
        return redirect_to("/tr8n/dashboard")
      end
      
      trfe('Incorrect email or password')
    end
  end

  def register
    if request.post?
      unless validate_registration
        translator = Tr8n::Translator.create(:user_id => 0, :email => params[:email], 
                  :password => params[:password], :name => params[:name], :gender => params[:gender], 
                  :mugshot => params[:mugshot], :link => params[:link])
        login!(translator)
        
        trfn('Thank you for registering.')
        return redirect_to("/tr8n/dashboard")
      end
    end
  end

  def out
    logout!
    redirect_to("/tr8n") 
  end

private

  def validate_registration
    params[:email].strip!
     
    if params[:email].blank?
      return trfe('Email is missing')
    end

    translator = Tr8n::Translator.find_by_email(params[:email])
    if translator
      return trfe('This email is already used by another user')
    end

    if params[:password].blank?
      return trfe('Password is missing')
    end
  end

  def login!(translator)
    session[:tr8n_translator_id] = translator.id
  end

  def logout!
    session[:tr8n_translator_id] = nil
  end  
end
