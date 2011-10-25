class LoginController < ApplicationController

  def index
    if request.post?
      user = User.find_by_email_and_password(params[:email], params[:password])
      
      if user
        login!(user)
        return redirect_to("/tr8n/dashboard")
      end
      
      trfe('Incorrect email or password')
    end
  end

  def register
    if request.post?
      unless validate_registration
        user = User.create(:email => params[:email], 
                  :password => params[:password], 
                  :first_name => params[:first_name], 
                  :last_name => params[:last_name], 
                  :gender => params[:gender], 
                  :mugshot => params[:mugshot], 
                  :link => params[:link])
        login!(user)
        
        trfn('Thank you for registering.')
        return redirect_to("/tr8n/dashboard")
      end
    end
  end

  def out
    logout!
    redirect_to("/home") 
  end

private

  def validate_registration
    params[:email].strip!
     
    if params[:email].blank?
      return trfe('Email is missing')
    end

    user = User.find_by_email(params[:email])
    if user
      return trfe('This email is already used by another user')
    end

    if params[:password].blank?
      return trfe('Password is missing')
    end
  end

end
