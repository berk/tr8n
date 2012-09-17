class Tr8n::LoginController < ApplicationController
  unloadable

  layout Tr8n::Config.site_info[:tr8n_layout]

  before_filter :validate_open_registration_enabled, :only => :register

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

  def validate_open_registration_enabled
    if !Tr8n::Config.open_registration_mode?
      trfe("You don't have rights to access that section.")
      return redirect_to(Tr8n::Config.default_url)
    end
  end

  def login!(translator)
    session[:tr8n_translator_id] = translator.id
  end

  def logout!
    session[:tr8n_translator_id] = nil
  end  
end
