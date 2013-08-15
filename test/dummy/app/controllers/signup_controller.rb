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

class SignupController < ApplicationController

  def index
    layout = lightbox? ? 'lightbox' : 'application'

    if request.post?
      @user = User.new(params[:user])

      @user.email.strip!
      if @user.email.blank?
        trfe("Email must be provided.")
        return render(:layout=>layout)
      end

      if User.find_by_email(@user.email)
        trfe("This email has already been registered.") 
        return render(:layout=>layout)
      end

      unless @user.save
        trfe(@user.errors.full_messages.first)
        return render(:layout=>layout)
      end
      
      login!(@user)
      trfn('Thank you for registering.')
      return redirect_to(:controller => :home)
    else 
      @user = User.new
    end

    render(:layout=>layout)
  end

end
