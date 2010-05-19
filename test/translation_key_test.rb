require File.dirname(__FILE__) + '/../../functional_test_helper'

class TranslationKeyTest < ActiveSupport::TestCase 

  before(:all) do
    # Tr8nConfig.reset_all!
    
    @user = Factory.create_profile(:first_name => "Mike")
    @russian = Language.find_by_locale('ru')
    Language.init_language(@russian, @user)
    
    @spanish = Language.find_by_locale('es')
  end

  test "find or create a translation key" do
    key = TranslationKey.find_or_create("Hello World", "We must start with this sentence!")
    assert key.key   
    the_key = TranslationKey.find_or_create("Hello World", "We must start with this sentence!")
    assert key.key, the_key.key
  end

  test "tokens" do
    key = TranslationKey.find_or_create("Hello {user}, you have {count} messages in your inbox")
    assert key.key
    assert key.sanitized_tokens?
    assert (not key.hidden_tokens?) 
    assert (not key.tokenized_label.lambda_tokens?) 
    assert_equal ["{user}", "{count}"], key.tokens
    assert_equal ["{user}", "{count}"], key.sanitized_tokens
  end
  
  test "hidden tokens rules" do
    assert Tr8nTokenizedLabel.hidden_token?("{_token1}")
    assert Tr8nTokenizedLabel.hidden_token?("{_token_1}")
    assert Tr8nTokenizedLabel.hidden_token?("{_token__1}")
    assert (not Tr8nTokenizedLabel.hidden_token?("{token1}"))
  end
  
  test "sanitized tokens and labels" do
    key = TranslationKey.find_or_create("{user} has {count} {_messages} in {_his_her} inbox")
    assert key.tokens?
    assert key.sanitized_tokens?
    assert key.hidden_tokens? 
    assert (not key.tokenized_label.lambda_tokens?) 
    assert_equal ["{user}", "{count}", "{_messages}", "{_his_her}"], key.tokens
    assert_equal ["{_messages}", "{_his_her}"], key.hidden_tokens
    assert_equal ["{user}", "{count}"], key.sanitized_tokens
    assert_equal "{user} has {count} messages in his/her inbox", key.sanitized_label
    
    key = TranslationKey.find_or_create("{user} has {count} {_posted__items} in {_his_her} inbox")
    assert_equal ["{_posted__items}", "{_his_her}"], key.hidden_tokens
    assert_equal "{user} has {count} posted items in his/her inbox", key.sanitized_label
    assert_equal "has posted items in his/her inbox", key.tokenless_label
  end
  
  test "lambda tokens" do
    key = TranslationKey.find_or_create("Hello [link1: {user}], you have [link2: {count} {_posted__items}]")
    assert key.tokens?
    assert key.sanitized_tokens?
    assert key.tokenized_label.lambda_tokens?
    assert_equal ["{user}", "{count}", "{_posted__items}"], key.tokens
    assert_equal ["{_posted__items}"], key.hidden_tokens
    assert_equal ["{user}", "{count}"], key.sanitized_tokens
    assert_equal ["[link1: {user}]", "[link2: {count} {_posted__items}]"], key.tokenized_label.lambda_tokens
    
    assert_equal [:link1, "{user}"], Tr8nTokenizedLabel.parse_lambda_token("[link1: {user}]")
  end
  
  test "dependency tokens" do
    ["user", "{profile}", "actor", "{target}", "first_user", "my_profile", "{story_actor}", "viewing_user"].each do |token|
      assert TranslationKey.gender_dependent_token?(token)
    end
    
    ["message_count", "message_num", "{my_age}", "{hours}", "current_minutes", "years", "seconds"].each do |token|
      assert TranslationKey.number_dependent_token?(token)
    end

    key = TranslationKey.find_or_create("Hello [link1: {user}], you have [link2: {count} {_posted__items}]")
    assert_equal ["user", "count", "viewing_user"], key.dependency_tokens
  end
  
  test "words" do
    key = TranslationKey.find_or_create("Hello [link1: {user}], you have [link2: {count} {_posted__items}]")
    assert_equal ["Hello", "Link1", "User", "Have", "Link2", "Count", "Posted", "Items"], key.words
  end
  
  test "locking translation key" do
    key = TranslationKey.find_or_create("Hello [link1: {user}], you have [link2: {count} {_posted__items}]")
    assert key.unlocked?
    key.lock!
    assert key.locked?
    key.unlock!
    assert key.unlocked?
  end
  
  test "simple translations" do
    key = TranslationKey.find_or_create("Hello World")

    assert key.add_translation("Привет Мир")
    
    # for Russian
    assert_equal "Привет Мир", key.translate(@russian)
    
    # for Spanish
    assert_equal "Hello World", key.translate(@spanish)
  end

  test "simple token translations" do
    key = TranslationKey.find_or_create("Hello {name}")

    assert key.add_translation("Привет {name}")
    
    # for Russian
    assert_equal "Привет Mike", key.translate(@russian, :name => "Mike")
    
    # for Spanish
    assert_equal "Hello Mike", key.translate(@spanish, :name => "Mike")
  end

  test "object translations" do
    key = TranslationKey.find_or_create("Hello {user.first_name}")
    assert key.add_translation("Привет {user.first_name}")
    
    # for Russian
    assert_equal "Привет Mike", key.translate(@russian, :user => @user)
    
    # for Spanish
    assert_equal "Hello Mike", key.translate(@spanish, :user => @user)
  end

  test "more object translations" do
    key = TranslationKey.find_or_create("Hello {user}")
    assert key.add_translation("Привет {user}")
    
    assert_equal "Привет Mike", key.translate(@russian, :user => [@user, @user.first_name])
    assert_equal "Привет Mike", key.translate(@russian, :user => [@user, :first_name])
    assert_equal "Привет Mike", key.translate(@russian, {:user => @user}, {"{user}" => @user.first_name})
  end

  test "number based translations" do
    key = TranslationKey.find_or_create("{count} {_messages}")
    lrule1 = NumericRule.create(:language => @russian, :multipart => false, :part1 => "is", :value1 => "1")    
    lrule2 = NumericRule.create(:language => @russian, :multipart => false, :part1 => "is_not", :value1 => "1")    

    assert key.add_translation("{count} сообщение", [TranslationRule.new(:language_rule => lrule1, :token => "count")])
#    assert key.add_translation("{count} сообщений", [TranslationRule.new(:language_rule => lrule2, :token => "count")])
    
    assert_equal "1 сообщение", key.translate(@russian, :count => 1, :_messages => "message")
 #   assert_equal "10 сообщений", key.translate(@russian, :count => 10, :_messages => "messages")
  end

end
