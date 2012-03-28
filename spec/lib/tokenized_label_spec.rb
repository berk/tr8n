require File.expand_path('../spec_helper', File.dirname(__FILE__))

describe Tr8n::TokenizedLabel do
  describe 'registering tokens' do

    context "registering correct tokens" do
      it "should register all tokens" do
        str = 'Dear {user:gender}, you have [bold: {count:number|| new message}] in your mailbox!'

        label = Tr8n::TokenizedLabel.new(str)
        label.label.should eq(str)

        label.tokens?.should be_true
        label.data_tokens?.should be_true
        label.decoration_tokens?.should be_true

        label.data_tokens.count.should eq(2)
        label.decoration_tokens.count.should eq(1)

        label.tokens.count.should eq(3)

        label.sanitized_tokens_hash.keys.should eq(["{user}", "{count}", "[bold: ]"])

        label.translation_tokens?.should be_true
        label.translation_tokens.count.should eq(3)

        san_str = "Dear {user}, you have [bold: {count} new messages] in your mailbox!"
        label.sanitized_label.should eq(san_str)

        label.suggestion_tokens.should eq(["{user}", "{count}", "bold"])

        label.words.should eq(["Dear", "User", "Have", "Bold", "Count", "Messages", "Your", "Mailbox"])

        label.tokens.each do |token|
          label.allowed_token?(token).should be_true
        end

      end
    end

  end  
end
