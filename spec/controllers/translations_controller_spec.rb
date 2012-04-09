require File.expand_path('../spec_helper', File.dirname(__FILE__))

describe Tr8n::TranslationsController do  
  
  
  describe "guest user" do 
	  it "should be redirect to homepage" do
	    get :index
	    response.should redirect_to('/')
	  end
  end	  

  describe "logged in user" do
	  it "should redirect the guest user to homepage" do
	    @user = User.create(:first_name => "Mike", :gender => "male")
	    request.session[:user_id] = @user.id

	    get :index
	    response.should be_success
	  end
	end

 end 