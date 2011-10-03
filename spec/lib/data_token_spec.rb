require File.expand_path('../spec_helper', File.dirname(__FILE__))

describe Tr8n::Tokens::DataToken do
  describe '#register_data_tokens' do

    context "registering correct data tokens" do
      it "should register all tokens" do
        tokens = Tr8n::Tokens::DataToken.parse("Hello {user}")
        tokens.count.should == 1
        tokens.first.class.name.should == "Tr8n::Tokens::DataToken"
        
        tokens = Tr8n::Tokens::DataToken.parse("{user} has {count} messages")
        tokens.count.should == 2
        tokens.first.class.name.should == "Tr8n::Tokens::DataToken"
      end
    end

    context "registering incorrect data tokens" do
      it "should not register any tokens" do
        Tr8n::Tokens::DataToken.parse("Hello {user:}").count.should == 0
        Tr8n::Tokens::DataToken.parse("Hello {}").count.should == 0
        Tr8n::Tokens::DataToken.parse("Hello {user::}").count.should == 0
      end
    end
  end  
end
