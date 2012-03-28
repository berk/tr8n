require File.expand_path('../spec_helper', File.dirname(__FILE__))

describe Tr8n::LanguageController do  
  
  it "should redirect the guest user to homepage" do
    get :index
    response.should redirect_to('/')
  end

 end 