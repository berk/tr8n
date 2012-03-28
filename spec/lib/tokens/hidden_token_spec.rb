require File.expand_path('../../spec_helper', File.dirname(__FILE__))

describe Tr8n::Tokens::HiddenToken do
  describe 'registering tokens' do

    context "incorrect tokens" do
      it "should not be registered" do
        [
          'Hello {user:}',
          'Hello {} and welcome',
          'Hello {user::}',
          'You have {count} messages',
          'You have {count:number}',
          'Hello {user:gender}',
          'Today is {today:date}',
          'Hello {user_list:list}',
          '{long_token_name} like this message',
          'Hello {user1}',
          'Hello {user1:user}',
          'Hello {user1:user::pos} and welcome',
          '{user:gender|his,her}',
          '{count:number|message}',
          '{count:number||message}',
          'Dear {user:gender}, you have {count:number||message}',
          '{count | message}',
          '{count | message, messages}',
          '{count:number | message, messages}',
          '{user:gender | he, she, he/she}',
          '{now:date | did, does, will do}',
          '{users:list | all male, all female, mixed genders}',
          '{count || message, messages}'
        ].each do |label|
          Tr8n::Tokens::HiddenToken.parse(label).count.should eq(0)
        end
      end
    end

    context "correct tokens" do
      it "should be registered" do
        [
          '{_he_she}',
          '{_posted__items}'
          'Hello {user.name} you have {count} {_posted__items}'
        ].each do |label|
          tokens = Tr8n::Tokens::HiddenToken.parse(label)
          tokens.count.should eq(1)
          tokens.first.class.name.should eq("Tr8n::Tokens::HiddenToken")
        end
      end
    end

  end  
end
