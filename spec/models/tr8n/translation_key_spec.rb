require File.expand_path('../../spec_helper', File.dirname(__FILE__))

describe Tr8n::TranslationKey do
  describe 'creation' do

    before :all do 
      @user = User.create(:first_name => "Mike", :gender => "male")
      @translator = Tr8n::Translator.create!(:name => "Mike", :user => @user, :gender => "male")

      @user2 = User.create(:first_name => "Anna", :gender => "female")
      @translator2 = Tr8n::Translator.create!(:name => "Anna", :user => @user2, :gender => "female")

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
        
        key = Tr8n::TranslationKey.find_or_create("{user:gender} updated {user:gender|his,her} profile")
        key.translate(@english, {:user => @user}).should == "Mike updated his profile"
        key.translate(@english, {:user => @user2}).should == "Anna updated her profile"
      end
    end

    describe "translating labels into a foreign language" do
      context "labels with no rules" do
        it "should return correct translations" do
          key = Tr8n::TranslationKey.find_or_create("Hello World")
          key.add_translation("Privet Mir", nil, @russian, @translator)
          key.translate(@russian).should eq("Privet Mir")

          key = Tr8n::TranslationKey.find_or_create("Hello {user}")
          key.add_translation("Privet {user}", nil, @russian, @translator)
          key.translate(@russian, {:user => @user}).should eq("Privet Mike")

          key = Tr8n::TranslationKey.find_or_create("You have {count} messages.")
          key.add_translation("U vas est {count} soobshenii.", nil, @russian, @translator)
          key.translate(@russian, {:count => 5}).should eq("U vas est 5 soobshenii.")
        end
      end

      context "labels with numeric rules" do
        it "should return correct translations" do

          definition = {multipart: true, part1: "ends_in", value1: "1", operator: "and", part2: "does_not_end_in", value2: "11"}
          rule1 = Tr8n::NumericRule.create(:language => @russian, :definition => definition)

          definition = {multipart: true, part1: "ends_in", value1: "2,3,4", operator: "and", part2: "does_not_end_in", value2: "12,13,14"}
          rule2 = Tr8n::NumericRule.create(:language => @russian, :definition => definition)

          definition = {multipart: false, part1: "ends_in", value1: "0,5,6,7,8,9,11,12,13,14"}
          rule3 = Tr8n::NumericRule.create(:language => @russian, :definition => definition)

          key = Tr8n::TranslationKey.find_or_create("You have {count||message}.")
          key.add_translation("U vas est {count} soobshenie.", [{:token=>"count", :rule_id=>[rule1.id]}], @russian, @translator)
          key.add_translation("U vas est {count} soobsheniya.", [{:token=>"count", :rule_id=>[rule2.id]}], @russian, @translator)
          key.add_translation("U vas est {count} soobshenii.", [{:token=>"count", :rule_id=>[rule3.id]}], @russian, @translator)

          key.translate(@russian, {:count => 1}).should eq("U vas est 1 soobshenie.")
          key.translate(@russian, {:count => 101}).should eq("U vas est 101 soobshenie.")
          key.translate(@russian, {:count => 11}).should eq("U vas est 11 soobshenii.")
          key.translate(@russian, {:count => 111}).should eq("U vas est 111 soobshenii.")

          key.translate(@russian, {:count => 5}).should eq("U vas est 5 soobshenii.")
          key.translate(@russian, {:count => 26}).should eq("U vas est 26 soobshenii.")
          key.translate(@russian, {:count => 106}).should eq("U vas est 106 soobshenii.")

          key.translate(@russian, {:count => 3}).should eq("U vas est 3 soobsheniya.")
          key.translate(@russian, {:count => 13}).should eq("U vas est 13 soobshenii.")
          key.translate(@russian, {:count => 23}).should eq("U vas est 23 soobsheniya.")
          key.translate(@russian, {:count => 103}).should eq("U vas est 103 soobsheniya.")
        end
      end
    end

  end  
end
