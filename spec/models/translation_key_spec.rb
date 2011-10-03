require File.expand_path('../spec_helper', File.dirname(__FILE__))

describe Tr8n::TranslationKey do
  describe '#creation' do

    before :all do 
      @user = @translator = Tr8n::Translator.create!(:name => "Mike", :user_id => 0, :gender => "male")
      @user2 = @translator2 = Tr8n::Translator.create!(:name => "Anna", :user_id => 0, :gender => "female")
      @english = Tr8n::Language.create!(:locale => "en-US", :english_name => "English")
      @russian = Tr8n::Language.create!(:locale => "ru", :english_name => "Russian")
      @spanish = Tr8n::Language.create!(:locale => "es", :english_name => "Spanish")      
      
      Tr8n::Config.init(@english.locale, @translator)
    end
    
    context "creating new translation key" do
      it "should create a unique hash" do
        key = Tr8n::TranslationKey.find_or_create("Hello World", "We must start with this sentence!")
        assert key.key   
        the_key = Tr8n::TranslationKey.find_or_create("Hello World", "We must start with this sentence!")
        assert key.key, the_key.key
      end
    end
    
    context "creating new translation key with tokens" do
      it "should parse the tokens correctly" do
        key = Tr8n::TranslationKey.find_or_create("Hello {user}, you have {count} messages in your inbox")

        key.key.should_not be(nil)
        key.translation_tokens.should_not be_empty
        key.decoration_tokens.should be_empty
        key.tokens.count.should == 2
        key.tokens.collect{|t| t.sanitized_name}.should include("{user}", "{count}")
        key.translation_tokens.collect{|t| t.sanitized_name}.should include("{user}", "{count}")
      end
    end
    
    context "translating simple strings with default language" do
      it "should return original value" do
        key = Tr8n::TranslationKey.find_or_create("Hello World")
        key.translate(@english).should == "Hello World"

        key = Tr8n::TranslationKey.find_or_create("Hello {world}")
        key.translate(@english, :world => "World").should == "Hello World"

        key = Tr8n::TranslationKey.find_or_create("{hello_world}")
        key.translate(@english, :hello_world => "Hello World").should == "Hello World"
        
        key = Tr8n::TranslationKey.find_or_create("Dear {user:gender}")
        key.translate(@english, :user => @user).should == "Dear Mike"
        key.translate(@english, :user => [@user, @user.name]).should == "Dear Mike"
        key.translate(@english, :user => [@user, :name]).should == "Dear Mike"
        key.translate(@english, :user => [@user, lambda{|user| user.name}]).should == "Dear Mike"
        key.translate(@english, :user => [@user, lambda{|user, tom| "#{user.name} and #{tom}"}, "Tom"]).should == "Dear Mike and Tom"
        
        # key = Tr8n::TranslationKey.find_or_create("{user:gender} updated {user:gender|his,her} profile")
        # key.translate(@english, {:user => @user}).should == "Mike updated his profile"
        # key.translate(@english, {:user => @user2}).should == "Anna updated her profile"
      end
    end
    
  end  
end
