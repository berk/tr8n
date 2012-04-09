require File.expand_path('../../spec_helper', File.dirname(__FILE__))

describe Tr8n::Tokens::TransformToken do
  describe 'registering transform tokens' do

    context 'incorrect tokens' do
      it 'should not be registered' do
        [
          'Hello {user}',
          'Hello {user:}',
          'Hello {user::}'
        ].each do |label|
          Tr8n::Tokens::TransformToken.parse(label).should be_empty
        end
      end
    end

    context 'correct tokens' do
      it 'should be registered' do
        [
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
          tokens = Tr8n::Tokens::TransformToken.parse(label)
          tokens.count.should eq(1)
          tokens.first.class.name.should eq("Tr8n::Tokens::TransformToken")
        end

        [
          '{user:gender|He, She} received {count:number||message}',
          '{user:gender | He, She } received {count:number || message, messages }'          
        ].each do |label|
          tokens = Tr8n::Tokens::TransformToken.parse(label)
          tokens.count.should eq(2)
          tokens.first.class.name.should eq("Tr8n::Tokens::TransformToken")
        end

      end
    end

  end  
end
