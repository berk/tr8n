require File.expand_path('../../spec_helper', File.dirname(__FILE__))

describe Tr8n::LanguageCaseRule do
  describe "language case rule creation" do
    before :all do
      @user = User.create(:first_name => "Mike", :gender => "male")
      @translator = Tr8n::Translator.create(:name => "Mike", :user => @user, :gender => "male")
      @english = Tr8n::Language.create(:locale => "en-US", :english_name => "English")
      @russian = Tr8n::Language.create(:locale => "ru", :english_name => "Russian")

	    @lcase_en = Tr8n::LanguageCase.create(
	      language:     @english,
	      keyword:      "pos",
	      latin_name:   "Possessive",
	      native_name:  "Possessive", 
	      description:  "Used to indicate possession (i.e., ownership). It is usually created by adding 's to the word", 
	      application:  "phrase")

	    @lcase_ru = Tr8n::LanguageCase.create(
	      language:     @russian,
	      keyword:      "pos",
	      latin_name:   "Possessive",
	      native_name:  "Possessive", 
	      description:  "Used to indicate possession (i.e., ownership).", 
	      application:  "words")
    end

    after :all do
      [@user, @translator, @english, @russian, 
      	@lcase_en, @lcase_ru].each do |obj|
        obj.destroy
       end       
    end

    describe "evaluating simple rules without genders" do
      it "should result in correct substitution" do
        lcrule = Tr8n::LanguageCaseRule.create(
        		:language => @english,
        		:language_case => @lcase_en,
        		:definition => {
        			part1: "ends_in", 
        			value1: "s", 
        			operation: "append", 
        			operation_value: "'"
        })

        lcrule.should be_a(Tr8n::LanguageCaseRule)

        lcrule.definition[:part1].should eq("ends_in")
        lcrule.definition["part1"].should eq("ends_in")

        lcrule.evaluate_part("Michael", 1).should be_false
        lcrule.evaluate(nil, "Michael").should be_false

        lcrule.evaluate_part("Anna", 1).should be_false
        lcrule.evaluate(nil, "Anna").should be_false

        lcrule.evaluate_part("friends", 1).should be_true
        lcrule.evaluate(nil, "friends").should be_true
        lcrule.apply("friends").should eq("friends'")


        lcrule = Tr8n::LanguageCaseRule.create(
        		:language => @english,
        		:language_case => @lcase_en,
        		:definition => {
        			part1: "does_not_end_in", 
        			value1: "s", operation: "append", 
        			operation_value: "'s"
        })

        lcrule.evaluate(nil, "Michael").should be_true
        lcrule.apply("Michael").should eq("Michael's")

        lcrule.evaluate(nil, "Anna").should be_true
        lcrule.apply("Anna").should eq("Anna's")

        lcrule.evaluate(nil, "friends").should be_false

        lcrule = Tr8n::LanguageCaseRule.create(
        		:language => @english,
        		:language_case => @lcase_en,
        		:definition => {
			        part1: "is",
			        value1: "1",
			        operation: "replace",
			        operation_value: "first",
        })

        lcrule.evaluate(nil, "2").should be_false
        lcrule.evaluate(nil, "1").should be_true
        lcrule.apply("1").should eq("first")

        lcrule = Tr8n::LanguageCaseRule.create(
        		:language => @english,
        		:language_case => @lcase_en,
        		:definition => {
			        part1: "ends_in",
			        value1: "0,4,5,6,7,8,9,11,12,13",
			        operation: "append",
			        operation_value: "th",
        })

        lcrule.evaluate(nil, "4").should be_true
        lcrule.apply("4").should eq("4th")

        lcrule.evaluate(nil, "7").should be_true
        lcrule.apply("7").should eq("7th")

      end
    end

    describe "evaluating simple rules with genders" do
      it "should result in correct substitution" do
        lcrule1 = Tr8n::LanguageCaseRule.create(
        		:language => @russian,
        		:language_case => @lcase_ru,
        		:definition => {
        			gender: "female", 
			        part1: "is",
			        value1: "1",
			        operation: "replace",
			        operation_value: "pervaya",
        })

        lcrule2 = Tr8n::LanguageCaseRule.create(
        		:language => @russian,
        		:language_case => @lcase_ru,
        		:definition => {
        			gender: "male", 
			        part1: "is",
			        value1: "1",
			        operation: "replace",
			        operation_value: "pervii",
        })

        anna = mock("female")
        anna.stub!(:to_s).and_return("Anna")
        anna.stub!(:gender).and_return("female")

        michael = mock("male")
        michael.stub!(:to_s).and_return("Michael")
        michael.stub!(:gender).and_return("male")

        lcrule1.evaluate(michael, "1").should be_false
        lcrule1.evaluate(anna, "1").should be_true
        lcrule1.apply("1").should eq("pervaya")

        lcrule2.evaluate(anna, "1").should be_false
        lcrule2.evaluate(michael, "1").should be_true
        lcrule2.apply("1").should eq("pervii")
			end
		end   

    describe "applying rules" do
    	describe "when using replace" do
     	 	it "it should correctly replace values" do
	        lcrule = Tr8n::LanguageCaseRule.create(
	        		:language => @english,
	        		:language_case => @lcase_ru,
	        		:definition => {
				        part1: "is",
				        value1: "1",
				        operation: "replace",
				        operation_value: "1st",
	        })

	        lcrule.evaluate(nil, "1").should be_true
        	lcrule.apply("1").should eq("1st")
     	 	end
      end

    	describe "when using append" do
     	 	it "it should correctly append values" do
	        lcrule = Tr8n::LanguageCaseRule.create(
	        		:language => @english,
	        		:language_case => @lcase_ru,
	        		:definition => {
				        part1: "is",
				        value1: "1",
				        operation: "append",
				        operation_value: "st",
	        })

	        lcrule.evaluate(nil, "1").should be_true
	        lcrule.apply("1").should eq("1st")
     	 	end
      end

    	describe "when using prepand" do
     	 	it "it should correctly prepand values" do
	        lcrule = Tr8n::LanguageCaseRule.create(
	        		:language => @english,
	        		:language_case => @lcase_ru,
	        		:definition => {
				        part1: "starts_with",
				        value1: "q,w,r,t,p,s,d,f,g,j,k,h,l,z,x,c,v,b,n,m",
				        operation: "prepand",
				        operation_value: "a ",
	        })

	        lcrule.evaluate(nil, "car").should be_true
	        lcrule.apply("car").should eq("a car")

	        lcrule = Tr8n::LanguageCaseRule.create(
	        		:language => @english,
	        		:language_case => @lcase_ru,
	        		:definition => {
				        part1: "starts_with",
				        value1: "e,u,i,o,a",
				        operation: "prepand",
				        operation_value: "an ",
	        })

	        lcrule.evaluate(nil, "apple").should be_true
	        lcrule.apply("apple").should eq("an apple")
     	 	end
      end

		end

	end
end
