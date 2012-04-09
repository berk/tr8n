require File.expand_path('../spec_helper', File.dirname(__FILE__))

describe Tr8n::LanguageCasesController do  
  
  describe "guest user" do 
	  it "should be redirect to homepage" do
	    get :index
	    response.should redirect_to('/')
	  end
  end	  


 end 