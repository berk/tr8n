require File.expand_path('../../spec_helper', File.dirname(__FILE__))

describe Tr8n::LanguageCase do
  describe "language case creation" do
    before :all do
      @user = User.create(:first_name => "Mike", :gender => "male")
      @translator = Tr8n::Translator.create!(:name => "Mike", :user => @user, :gender => "male")
      @english = Tr8n::Language.create!(:locale => "en-US", :english_name => "English")
      @russian = Tr8n::Language.create!(:locale => "ru", :english_name => "Russian")
    end

    after :all do
      [@user, @translator, @english, @russian].each do |obj|
        obj.destroy
       end       
    end

    describe "registering cache key" do
      it "should contain language and keyword" do
        lcase = Tr8n::LanguageCase.create(
          language:     @english,
          keyword:      "pos",
          latin_name:   "Possessive",
          native_name:  "Possessive", 
          description:  "Used to indicate possession (i.e., ownership). It is usually created by adding 's to the word", 
          application:  "phrase")
        
        lcase.cache_key.should eq("language_case_en-US_pos")

        Tr8n::LanguageCase.by_keyword("pos", @english).should eq(lcase)
      end
    end

    describe "apply" do
      it "should substitute the tokens with appropriate case" do
        lcase = Tr8n::LanguageCase.create(
          language:     @english,
          keyword:      "pos",
          latin_name:   "Possessive",
          native_name:  "Possessive", 
          description:  "Used to indicate possession (i.e., ownership). It is usually created by adding 's to the word", 
          application:  "phrase")
        
        lcase.add_rule({multipart: false, gender: "none", part1: "ends_in", value1: "s", operation: "append", operation_value: "'"})
        lcase.add_rule({multipart: false, gender: "none", part1: "does_not_end_in", value1: "s", operation: "append", operation_value: "'s"})

        michael = mock("male")
        michael.stub!(:to_s).and_return("Michael")
        michael.stub!(:gender).and_return("male")

        lcase.apply(michael, "Michael", {}).should eq("Michael's")
      end
    end
  end
end
