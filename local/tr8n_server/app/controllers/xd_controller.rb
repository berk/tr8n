class XdController < ApplicationController

  def index
    data = Tr8n::Config.decode_and_verify_params(params[:sr])
    ts = Time.at(data[:ts])
    if ts > (Time.now + 10.seconds)
      raise Tr8n::Exception("Request expired")
    end

    pp data

    if data[:action] == 'login'
      user = User.find_by_remote_id(data[:user_id])
      if user
        login!(user) 
      else  
        session[:remote_user] = {
          :id => data[:user_id],
          :email => data[:email],
          :first_name => data[:first_name],
          :last_name => data[:last_name]
        }
      end
    end
    render(:text => "")
  end

end
