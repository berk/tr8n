require File.expand_path('../../spec_helper', File.dirname(__FILE__))

describe Tr8n::GenderRule do
	before :all do 
		@lang = Tr8n::Language.create(:locale => "elb", :english_name => "Elbonian")
	end

	after :all do 
		@lang.destroy
	end

	describe 'class methods'	do
		it 'should respec configuration settings' do
			Tr8n::Config.stub!(:rules_engine).and_return({
				:gender_rule => {
														token_suffixes: ["user", "actor", "target"],
      											object_method:   "gender",
      											method_values:  {
        											female:        "f",
        											male:          "m",
        											neutral:       "n",
        											unknown:       "u"	      								 
        										} 
      									}
			})

			Tr8n::GenderRule.dependency.should eq("gender")
			Tr8n::GenderRule.suffixes.should eq(["user", "actor", "target"])

			Tr8n::GenderRule.gender_object_value_for(:female).should eq("f")
			Tr8n::GenderRule.gender_object_value_for(:male).should eq("m")
			Tr8n::GenderRule.gender_object_value_for(:neutral).should eq("n")
			Tr8n::GenderRule.gender_object_value_for(:unknown).should eq("u")

			obj = mock("object_with_gender")
			obj.should_receive(:gender).and_return("m")
			Tr8n::GenderRule.gender_token_value(obj).should eq("m")
		end

		describe 'default transform without token value' do
			it 'should always use a musculine form' do
				Tr8n::GenderRule.default_transform("he").should eq("he")
				Tr8n::GenderRule.default_transform("he", "she").should eq("he")
				Tr8n::GenderRule.default_transform("his", "her").should eq("his")
			end
		end

		describe 'transform with a token value' do
			it 'should return the form based on the token value' do
				male = mock("male")
				male.stub!(:gender).and_return("male")
				female = mock("male")
				female.stub!(:gender).and_return("female")
				unknown = mock("unknown")
				unknown.stub!(:gender).and_return("unknown")

				Tr8n::GenderRule.transform(male, "registered on").should eq("registered on")
				Tr8n::GenderRule.transform(male, "he", "she").should eq("he")
				Tr8n::GenderRule.transform(male, "his", "her").should eq("his")
				Tr8n::GenderRule.transform(male, "he", "she", "he/she").should eq("he")

				Tr8n::GenderRule.transform(female, "registered on").should eq("registered on")
				Tr8n::GenderRule.transform(female, "he", "she").should eq("she")
				Tr8n::GenderRule.transform(female, "his", "her").should eq("her")
				Tr8n::GenderRule.transform(female, "he", "she", "he/she").should eq("she")

				Tr8n::GenderRule.transform(unknown, "registered on").should eq("registered on")
				Tr8n::GenderRule.transform(unknown, "he", "she").should eq("he/she")
				Tr8n::GenderRule.transform(unknown, "his", "her").should eq("his/her")
				Tr8n::GenderRule.transform(unknown, "he", "she", "he/she").should eq("he/she")
			end
		end
	end	

	describe 'instance methods'	do
		describe 'evaluate rule' do
			it 'should return results based on gender' do
				male = mock("male")
				male.stub!(:gender).and_return("male")
				female = mock("male")
				female.stub!(:gender).and_return("female")
				unknwon = mock("unknwon")
				unknwon.stub!(:gender).and_return("unknwon")

				definition = {operator: "is", value: "male"}
				rule = Tr8n::GenderRule.create(:language => @lang, :definition => definition)
				rule.evaluate(male).should be_true
				rule.evaluate(female).should be_false
				rule.evaluate(unknwon).should be_false

				definition = {operator: "is_not", value: "male"}
				rule = Tr8n::GenderRule.create(:language => @lang, :definition => definition)
				rule.evaluate(male).should be_false
				rule.evaluate(female).should be_true
				rule.evaluate(unknwon).should be_true

				definition = {operator: "is", value: "female"}
				rule = Tr8n::GenderRule.create(:language => @lang, :definition => definition)
				rule.evaluate(male).should be_false
				rule.evaluate(female).should be_true
				rule.evaluate(unknwon).should be_false

				definition = {operator: "is_not", value: "female"}
				rule = Tr8n::GenderRule.create(:language => @lang, :definition => definition)
				rule.evaluate(male).should be_true
				rule.evaluate(female).should be_false
				rule.evaluate(unknwon).should be_true
			end
		end

		describe 'hashing a rule' do
			it 'should produce a correct hash' do 
				definition = {operator: "is", value: "male"}
				rule = Tr8n::GenderRule.create(:language => @lang, :definition => definition)
				rule.to_hash.should eq({:type=>"gender", :operator=>"is", :value=>"male"})
			end
		end	

		describe 'describing a rule' do
			it 'should produce a correct description' do 
				definition = {operator: "is", value: "male"}
				rule = Tr8n::GenderRule.create(:language => @lang, :definition => definition)
				rule.description.should eq("is a male")

				definition = {operator: "is", value: "unknown"}
				rule = Tr8n::GenderRule.create(:language => @lang, :definition => definition)
				rule.description.should eq("has an unknown gender")

				definition = {operator: "is_not", value: "female"}
				rule = Tr8n::GenderRule.create(:language => @lang, :definition => definition)
				rule.description.should eq("is not a female")

				definition = {operator: "is_not", value: "unknown"}
				rule = Tr8n::GenderRule.create(:language => @lang, :definition => definition)
				rule.description.should eq("does not have an unknown gender")
			end
		end

	end	

end
