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

class LoginController < ApplicationController

  def index    
    if request.post?
      user = login(params[:email], params[:password])
      if lightbox?
        return redirect_to(:action=>:cookies, :origin => params[:origin]) if user
      end

      return redirect_to("/home") if user
      trfe('Incorrect email or password')
    end

    return render(:layout=>"lightbox") if lightbox?
  end

  def out
    logout!
    if lightbox?
      return redirect_to(:action=>:cookies, :origin => params[:origin])
    end
    trfn("You have been logged out")
  end
      
  def cookies
    application = Tr8n::TranslationDomain.find_or_create(params[:origin]).application
    Tr8n::Config.set_remote_application(application)
    render(:layout=>"lightbox")
  end

end
