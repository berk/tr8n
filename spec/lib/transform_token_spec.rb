require File.expand_path('../spec_helper', File.dirname(__FILE__))

describe Tr8n::Tokens::TransformToken do
  describe '#register_data_tokens' do

    context "registering correct transform tokens" do
      it "should register all tokens" do
        Tr8n::Tokens::TransformToken.parse("{user:gender|his,her}").count.should == 1
        Tr8n::Tokens::TransformToken.parse("{count:number|message}").count.should == 1
        Tr8n::Tokens::TransformToken.parse("{count:number||message}").count.should == 1
      end
    end

    context "registering incorrect transform tokens" do
      it "should not register any tokens" do
        Tr8n::Tokens::TransformToken.parse("Hello {user}").count.should == 0
        Tr8n::Tokens::TransformToken.parse("Hello {user:}").count.should == 0
        Tr8n::Tokens::TransformToken.parse("Hello {user::}").count.should == 0
      end
    end
  end  
end
