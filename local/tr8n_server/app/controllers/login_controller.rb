class LoginController < ApplicationController

  def index
    if request.post?
      user = User.authenticate(params[:email], params[:password])
      if user
        login!(user)
        return redirect_to("/tr8n/dashboard")
      end
      trfe('Incorrect email or password')
    end
  end

  def register
    if request.post?
      user = User.new(:email => params[:email], 
                :password => params[:password], 
                :first_name => params[:first_name], 
                :last_name => params[:last_name], 
                :gender => params[:gender], 
                :mugshot => params[:mugshot], 
                :link => params[:link])

      if user.save
        login!(user)
        trfn('Thank you for registering.')
        return redirect_to("/tr8n/phrases")
      end    
      trfe(user.errors.full_messages.first)
    end
  end

  def out
    logout!
    redirect_to("/home") 
  end

end
