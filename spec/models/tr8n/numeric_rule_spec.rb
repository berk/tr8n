require File.expand_path('../../spec_helper', File.dirname(__FILE__))

describe Tr8n::NumericRule do
	before :all do 
		@lang = Tr8n::Language.create(:locale => "elb", :english_name => "Elbonian")
	end

	after :all do 
		@lang.destroy
	end

	describe 'class methods'	do
		it 'should respec configuration settings' do
			Tr8n::Config.stub!(:rules_engine).and_return({
				:numeric_rule => {
													token_suffixes: ["count", "num"],
	      									object_method:   "to_i"
	      								 } 
			})

			Tr8n::NumericRule.dependency.should eq("number")
			Tr8n::NumericRule.suffixes.should eq(["count", "num"])
			Tr8n::NumericRule.number_token_value(5).should eq(5)

			obj = mock("numeric_object")
			obj.should_receive(:to_i).and_return(42)
			Tr8n::NumericRule.number_token_value(obj).should eq(42)
		end

		describe 'default transform without token value' do
			it 'should return the pluralized form of the noun' do
				Tr8n::NumericRule.default_transform("car", "cars").should eq("cars")
				Tr8n::NumericRule.default_transform("car").should eq("cars")
			end
		end

		describe 'transform with a token value' do
			it 'should return the form based on the token value' do
				Tr8n::NumericRule.transform(1, "person", "people").should eq("person")
				Tr8n::NumericRule.transform(2, "person", "people").should eq("people")
				Tr8n::NumericRule.transform(2, "car").should eq("cars")
			end
		end

		describe 'sanitize values' do
			it 'should strip values' do
				Tr8n::NumericRule.sanitize_values("1,  2, 3 ,  4 ").should eq(["1","2","3","4"])
				Tr8n::NumericRule.sanitize_values("1,2,3,4").should eq(["1","2","3","4"])
			end
		end

		describe 'humanize values' do
			it 'should strip values' do
				Tr8n::NumericRule.humanize_values("1,  2, 3 ,  4 ").should eq("1, 2, 3, 4")
				Tr8n::NumericRule.humanize_values("1,2,3,4").should eq("1, 2, 3, 4")
			end
		end

		describe 'evaluating a rule fragment' do
			it 'should return correct results' do 
				Tr8n::NumericRule.evaluate_rule_fragment(5, 	:is, [5]).should be_true
				Tr8n::NumericRule.evaluate_rule_fragment(5, 	:is, [2,3,5]).should be_true
				Tr8n::NumericRule.evaluate_rule_fragment(5, 	:is, [4]).should be_false

				Tr8n::NumericRule.evaluate_rule_fragment(5, 	:is_not, [4]).should be_true
				Tr8n::NumericRule.evaluate_rule_fragment(5, 	:is_not, [4,2,3]).should be_true
				Tr8n::NumericRule.evaluate_rule_fragment(5, 	:is_not, [5]).should be_false

				Tr8n::NumericRule.evaluate_rule_fragment(5,  	:ends_in, [5]).should be_true
				Tr8n::NumericRule.evaluate_rule_fragment(25, 	:ends_in, [5]).should be_true
				Tr8n::NumericRule.evaluate_rule_fragment(25, 	:ends_in, [2,3,4,5]).should be_true
				Tr8n::NumericRule.evaluate_rule_fragment(5, 	:ends_in, [2]).should be_false
				Tr8n::NumericRule.evaluate_rule_fragment(5, 	:ends_in, [2,3,4]).should be_false

				Tr8n::NumericRule.evaluate_rule_fragment(5, 	:does_not_end_in, [2,3,4]).should be_true
				Tr8n::NumericRule.evaluate_rule_fragment(25, 	:does_not_end_in, [2,4]).should be_true
				Tr8n::NumericRule.evaluate_rule_fragment(25, 	:does_not_end_in, [2,5]).should be_false
				Tr8n::NumericRule.evaluate_rule_fragment(25, 	:does_not_end_in, [5]).should be_false
			end
		end
	end

	describe 'instance methods' do
		describe 'creating a rule' do
			it 'should create a rule object' do 
				definition = {multipart: false, part1: "is", value1: "1"}
				rule = Tr8n::NumericRule.create(:language => @lang, :definition => definition)
				rule.should be_a(Tr8n::NumericRule)
			end
		end

		describe 'evaluating a simple rule' do
			it 'should return correct results' do 
				definition = {multipart: false, part1: "is", value1: "1,2,3,4"}
				rule = Tr8n::NumericRule.create(:language => @lang, :definition => definition)
				rule.evaluate(5).should be_false
				rule.evaluate(1).should be_true

				definition = {multipart: false, part1: "is_not", value1: "2,3,4,5"}
				rule = Tr8n::NumericRule.create(:language => @lang, :definition => definition)
				rule.evaluate(5).should be_false
				rule.evaluate(1).should be_true

				definition = {multipart: false, part1: "ends_in", value1: "2,3,4,5"}
				rule = Tr8n::NumericRule.create(:language => @lang, :definition => definition)
				rule.evaluate(25).should be_true
				rule.evaluate(1).should be_false

				definition = {multipart: false, part1: "does_not_end_in", value1: "2,3,4,5"}
				rule = Tr8n::NumericRule.create(:language => @lang, :definition => definition)
				rule.evaluate(25).should be_false
				rule.evaluate(1).should be_true
			end
		end

		describe 'evaluating multipart rule' do
			it 'should return correct results' do 
				definition = {multipart: true, part1: "ends_in", value1: "1", operator: "and", part2: "does_not_end_in", value2: "11"}
				rule = Tr8n::NumericRule.create(:language => @lang, :definition => definition)
				rule.evaluate(1).should be_true
				rule.evaluate(21).should be_true
				rule.evaluate(231).should be_true
				rule.evaluate(1021).should be_true
				rule.evaluate(2).should be_false
				rule.evaluate(11).should be_false
				rule.evaluate(211).should be_false
				rule.evaluate(1011).should be_false

				definition = {multipart: true, part1: "ends_in", value1: "2,3,4", operator: "and", part2: "does_not_end_in", value2: "12,13,14"}
				rule = Tr8n::NumericRule.create(:language => @lang, :definition => definition)
				rule.evaluate(2).should be_true
				rule.evaluate(1023).should be_true
				rule.evaluate(34).should be_true
				rule.evaluate(1013).should be_false
				rule.evaluate(14).should be_false
			end
		end

		describe 'hashing a rule' do
			it 'should produce a correct hash' do 
				definition = {multipart: true, part1: "ends_in", value1: "2,3,4", operator: "and", part2: "does_not_end_in", value2: "12,13,14"}
				rule = Tr8n::NumericRule.create(:language => @lang, :definition => definition)
				rule.to_hash.should eq({:type=>"number", :multipart=>true, :operator=>"and", :part1=>"ends_in",
																:value1=>"2,3,4", :part2=>"does_not_end_in", :value2=>"12,13,14"})
			end
		end	

		describe 'describing a rule' do
			it 'should produce a correct description' do 
				definition = {multipart: true, part1: "ends_in", value1: "2,3,4", operator: "and", part2: "does_not_end_in", value2: "12,13,14"}
				rule = Tr8n::NumericRule.create(:language => @lang, :definition => definition)
				rule.description.should eq("ends in 2, 3, 4, but not in 12, 13, 14")

				definition = {multipart: false, part1: "does_not_end_in", value1: "2,3,4,5"}
				rule = Tr8n::NumericRule.create(:language => @lang, :definition => definition)
				rule.description.should eq("does not end in 2, 3, 4, 5")
			end
		end

	end

end
