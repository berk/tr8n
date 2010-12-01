require File.expand_path(File.dirname(__FILE__) + '/base_test.rb') 

class Tr8n::TranslationKeyTest < Tr8n::BaseTest

  def setup
    super
    @user = Tr8n::Translator.create!(:id => 2, :user_id => 2, :name => "Mike")
    @russian = Tr8n::Language.for("ru")
    @spanish = Tr8n::Language.create!(:id => 1, :locale => "es", :english_name => "Spanish")
  end

  test "find or create a translation key" do
    key = Tr8n::TranslationKey.find_or_create("Hello World", "We must start with this sentence!")
    assert key.key   
    the_key = Tr8n::TranslationKey.find_or_create("Hello World", "We must start with this sentence!")
    assert key.key, the_key.key
  end

  test "tokens" do
    key = Tr8n::TranslationKey.find_or_create("Hello {user}, you have {count} messages in your inbox")

    assert key.key
    assert key.translation_tokens?
    assert (not key.decoration_tokens?)
    
    assert_equal ["{user}", "{count}"], key.tokens.collect{|t| t.sanitized_name}
    assert_equal ["{user}", "{count}"], key.translation_tokens.collect{|t| t.sanitized_name}
  end
  
  test "basic translations" do
    key = Tr8n::TranslationKey.find_or_create("Hello World")
    t = key.translate(@default_language)
    assert_equal "Hello World", t

    key = Tr8n::TranslationKey.find_or_create("Hello {world}")
    assert_equal ["{world}"], key.tokens.collect{|t| t.sanitized_name}
    t = key.translate(@default_language, :world => "World")
    assert_equal "Hello World", t

    key = Tr8n::TranslationKey.find_or_create("{hello_world}")
    assert_equal ["{hello_world}"], key.tokens.collect{|t| t.sanitized_name}
    t = key.translate(@default_language, :hello_world => "Hello World")
    assert_equal "Hello World", t
  end

  test "gender based translations in English" do
    @user.stubs(:name).returns("Mike")
    @user.stubs(:gender).returns("male")

    key = Tr8n::TranslationKey.find_or_create("Dear {user}")
    assert_equal ["{user}"], key.tokens.collect{|t| t.sanitized_name}
    assert_equal "Dear Mike", key.translate(@default_language, :user => @user)

    key = Tr8n::TranslationKey.find_or_create("Dear {user:gender}")
    assert_equal ["{user}"], key.tokens.collect{|t| t.sanitized_name}
    assert_equal "Dear Mike", key.translate(@default_language, :user => @user)
    assert_equal "Dear Mike", key.translate(@default_language, :user => [@user, @user.name])
    assert_equal "Dear Mike", key.translate(@default_language, :user => [@user, :name])
    assert_equal "Dear Mike", key.translate(@default_language, :user => [@user, lambda{|user| user.name}])
    assert_equal "Dear Mike and Tom", key.translate(@default_language, :user => [@user, lambda{|user, tom| "#{user.name} and #{tom}"}, "Tom"])

    key = Tr8n::TranslationKey.find_or_create("{custom:gender} updated {custom:gender|his,her} profile")
    assert_equal ["{custom:gender}", "{custom:gender|his,her}"], key.tokens.collect{|t| t.full_name}
    assert_equal ["Tr8n::Tokens::DataToken", "Tr8n::Tokens::TransformToken"], key.tokens.collect{|t| t.class.name}
    assert_equal "Mike updated his profile", key.translate(@default_language, {:custom => @user})
    
    key = Tr8n::TranslationKey.find_or_create("{user} updated {user|his,her} profile")
    assert_equal ["{user}", "{user|his,her}"], key.tokens.collect{|t| t.full_name}
    assert_equal ["Tr8n::Tokens::DataToken", "Tr8n::Tokens::TransformToken"], key.tokens.collect{|t| t.class.name}
    assert_equal "Mike updated his profile", key.translate(@default_language, :user => @user)
    
    @user.stubs(:name).returns("Tina")
    @user.stubs(:gender).returns("female")
    assert_equal "Tina updated her profile", key.translate(@default_language, :user => @user)
    
    @user.stubs(:name).returns("Alex")
    @user.stubs(:gender).returns("unknown")
    assert_equal "Alex updated his/her profile", key.translate(@default_language, :user => @user)
    
    key = Tr8n::TranslationKey.find_or_create("{user} updated {user | his, her, his-her} profile")
    assert_equal ["{user}", "{user | his, her, his-her}"], key.tokens.collect{|t| t.full_name}
    assert_equal ["Tr8n::Tokens::DataToken", "Tr8n::Tokens::TransformToken"], key.tokens.collect{|t| t.class.name}
    assert_equal "Alex updated his-her profile", key.translate(@default_language, :user => @user)

    # double pipe approach - will include the name
    key = Tr8n::TranslationKey.find_or_create("{user || updated his, updated her, updated his/her} profile")
    assert_equal ["{user || updated his, updated her, updated his/her}"], key.tokens.collect{|t| t.full_name}
    assert_equal ["Tr8n::Tokens::TransformToken"], key.tokens.collect{|t| t.class.name}
    assert_equal "Alex updated his/her profile", key.translate(@default_language, :user => [@user, :name])
  end
  
  test "number based translations in English" do
    # old way of doing things
    key = Tr8n::TranslationKey.find_or_create("{val:number} {_messages}")
    assert_equal ["{val}", "{_messages}"], key.tokens.collect{|t| t.sanitized_name}
    assert_equal ["Tr8n::Tokens::DataToken", "Tr8n::Tokens::HiddenToken"], key.tokens.collect{|t| t.class.name}
    assert_equal "5 messages", key.translate(@default_language, :val => 5, :_messages => "message".pluralize_for(5))

    key = Tr8n::TranslationKey.find_or_create("{count} {_messages}")
    assert_equal ["{count}", "{_messages}"], key.tokens.collect{|t| t.sanitized_name}
    assert_equal ["Tr8n::Tokens::DataToken", "Tr8n::Tokens::HiddenToken"], key.tokens.collect{|t| t.class.name}
    assert_equal "5 messages", key.translate(@default_language, :count => 5, :_messages => "message".pluralize_for(5))

    @user.stubs(:name).returns("Alex")
    @user.stubs(:age).returns(5)
    key = Tr8n::TranslationKey.find_or_create("{user} is now {years} {_years} old")
    assert_equal ["{user}", "{years}", "{_years}"], key.tokens.collect{|t| t.sanitized_name}
    assert_equal ["Tr8n::Tokens::DataToken", "Tr8n::Tokens::DataToken", "Tr8n::Tokens::HiddenToken"], key.tokens.collect{|t| t.class.name}
    assert_equal "Alex is now 5 years old", key.translate(@default_language, :user => [@user, :name], :years => @user.age, :_years => "year".pluralize_for(@user.age))

    # new way 
    key = Tr8n::TranslationKey.find_or_create("{user} is now {age} {age|year} old")
    assert_equal ["{user}", "{age}", "{age|year}"], key.tokens.collect{|t| t.full_name}
    assert_equal ["{user}", "{age}", "{age}"], key.tokens.collect{|t| t.sanitized_name}
    assert_equal ["Tr8n::Tokens::DataToken", "Tr8n::Tokens::DataToken", "Tr8n::Tokens::TransformToken"], key.tokens.collect{|t| t.class.name}
    assert_equal "Alex is now 5 years old", key.translate(@default_language, :user => [@user, :name], :age => @user.age)

    key = Tr8n::TranslationKey.find_or_create("{user} is now {age || year} old")
    assert_equal ["{user}", "{age}"], key.tokens.collect{|t| t.sanitized_name}
    assert_equal ["Tr8n::Tokens::DataToken", "Tr8n::Tokens::TransformToken"], key.tokens.collect{|t| t.class.name}
    assert_equal "Alex is now 5 years old", key.translate(@default_language, :user => [@user, :name], :age => @user.age)

    key = Tr8n::TranslationKey.find_or_create("{user} is now {age || year, years} old")
    assert_equal ["{user}", "{age || year, years}"], key.tokens.collect{|t| t.full_name}
    assert_equal ["{user}", "{age}"], key.tokens.collect{|t| t.sanitized_name}
    assert_equal ["Tr8n::Tokens::DataToken", "Tr8n::Tokens::TransformToken"], key.tokens.collect{|t| t.class.name}
    assert_equal "Alex is now 5 years old", key.translate(@default_language, :user => [@user, :name], :age => @user.age)

    key = Tr8n::TranslationKey.find_or_create("{count||person,people}")
    assert_equal ["{count||person,people}"], key.tokens.collect{|t| t.full_name}
    assert_equal ["{count}"], key.tokens.collect{|t| t.sanitized_name}
    assert_equal ["Tr8n::Tokens::TransformToken"], key.tokens.collect{|t| t.class.name}
    assert_equal "1 person", key.translate(@default_language, :count => 1)
    assert_equal "2 people", key.translate(@default_language, :count => 2)
    assert_equal "0 people", key.translate(@default_language, :count => 0)
  end  
  
  test "decoration tokens" do
    Tr8n::Config.stubs(:default_lambdas).returns({"b" => "<strong>{$0}</strong>"})

    key = Tr8n::TranslationKey.find_or_create("[b: hello world]")
    assert_equal ["[b: hello world]"], key.tokens.collect{|t| t.full_name}
    assert_equal ["[b: ]"], key.tokens.collect{|t| t.sanitized_name}
    assert_equal ["Tr8n::Tokens::DecorationToken"], key.tokens.collect{|t| t.class.name}
    assert_equal "<b>hello world</b>", key.translate(@default_language, :b => lambda{|str| "<b>#{str}</b>"})
    assert_equal "<b>hello world</b>", key.translate(@default_language, :b => "<b>{$0}</b>")
    assert_equal "<strong>hello world</strong>", key.translate(@default_language)
    
    Tr8n::Config.stubs(:default_lambdas).returns({"link" => "<a href='{$1}'>{$0}</a>"})
    key = Tr8n::TranslationKey.find_or_create("[link: click here]")
    assert_equal ["[link: click here]"], key.tokens.collect{|t| t.full_name}
    assert_equal ["[link: ]"], key.tokens.collect{|t| t.sanitized_name}
    assert_equal ["Tr8n::Tokens::DecorationToken"], key.tokens.collect{|t| t.class.name}
    assert_equal "<a href='www.google.com' style=''>click here</a>", key.translate(@default_language, :link => ["www.google.com"])

    Tr8n::Config.stubs(:default_lambdas).returns({"link" => "<a href='{$1}' style='{$2}'>{$0}</a>"})
    assert_equal "<a href='www.google.com' style=''>click here</a>", key.translate(@default_language, :link => ["www.google.com"])
  end
  
  test "nested tokens" do
    Tr8n::Config.stubs(:default_lambdas).returns({"b" => "<b>{$0}</b>"})
    @user.stubs(:name).returns("Michael")

    key = Tr8n::TranslationKey.find_or_create("Hello [b: {user.name}]")
    assert_equal ["{user.name}", "[b: {user.name}]"], key.tokens.collect{|t| t.full_name}
    assert_equal ["{user.name}", "[b: ]"], key.tokens.collect{|t| t.sanitized_name}
    assert_equal ["Tr8n::Tokens::MethodToken", "Tr8n::Tokens::DecorationToken"], key.tokens.collect{|t| t.class.name}
    assert_equal "Hello <strong>Michael</strong>", key.translate(@default_language, :user => @user)
    
    key = Tr8n::TranslationKey.find_or_create("Dear {user}, you have [b: {count||message}] in your inbox")
    assert_equal ["{user}", "{count||message}", "[b: {count||message}]"], key.tokens.collect{|t| t.full_name}
    assert_equal ["{user}", "{count}", "[b: ]"], key.tokens.collect{|t| t.sanitized_name}
    assert_equal ["Tr8n::Tokens::DataToken", "Tr8n::Tokens::TransformToken", "Tr8n::Tokens::DecorationToken"], key.tokens.collect{|t| t.class.name}
    assert_equal "Dear Michael, you have <strong>5 messages</strong> in your inbox", key.translate(@default_language, :user => @user, :count => 5)
  end  
#  
#  test "words" do
#    key = Tr8n::TranslationKey.find_or_create("Hello [link1: {user}], you have [link2: {count} {_posted__items}]")
#    assert_equal ["Hello", "Link1", "User", "Have", "Link2", "Count", "Posted", "Items"], key.words
#  end
#  
#  
##  test "dependency tokens" do
##    ["user", "{profile}", "actor", "{target}", "first_user", "my_profile", "{story_actor}", "viewing_user"].each do |token|
##      assert Tr8n::TranslationKey.gender_dependent_token?(token)
##    end
##    
##    ["message_count", "message_num", "{my_age}", "{hours}", "current_minutes", "years", "seconds"].each do |token|
##      assert Tr8n::TranslationKey.number_dependent_token?(token)
##    end
##
##    key = Tr8n::TranslationKey.find_or_create("Hello [link1: {user}], you have [link2: {count} {_posted__items}]")
##    assert_equal ["user", "count", "viewing_user"], key.dependency_tokens
##  end
#  
#  
#  test "locking translation key" do
#    key = Tr8n::TranslationKey.find_or_create("Hello [link1: {user}], you have [link2: {count} {_posted__items}]")
#    assert key.unlocked?
#    key.lock!
#    assert key.locked?
#    key.unlock!
#    assert key.unlocked?
#  end
#  
#  test "simple translations" do
#    key = Tr8n::TranslationKey.find_or_create("Hello World")
#
#    assert key.add_translation("Привет Мир")
#    
#    # for Russian
#    assert_equal "Привет Мир", key.translate(@russian)
#    
#    # for Spanish
#    assert_equal "Hello World", key.translate(@spanish)
#  end
#
#  test "simple token translations" do
#    key = Tr8n::TranslationKey.find_or_create("Hello {name}")
#
#    assert key.add_translation("Привет {name}")
#    
#    # for Russian
#    assert_equal "Привет Mike", key.translate(@russian, :name => "Mike")
#    
#    # for Spanish
#    assert_equal "Hello Mike", key.translate(@spanish, :name => "Mike")
#  end
#
#  test "object translations" do
#    key = Tr8n::TranslationKey.find_or_create("Hello {user.first_name}")
#    assert key.add_translation("Привет {user.first_name}")
#    
#    # for Russian
#    assert_equal "Привет Mike", key.translate(@russian, :user => @user)
#    
#    # for Spanish
#    assert_equal "Hello Mike", key.translate(@spanish, :user => @user)
#  end
#
#  test "more object translations" do
#    key = Tr8n::TranslationKey.find_or_create("Hello {user}")
#    assert key.add_translation("Привет {user}")
#    
#    assert_equal "Привет Mike", key.translate(@russian, :user => [@user, @user.name])
#    assert_equal "Привет Mike", key.translate(@russian, :user => [@user, :name])
#  end
#
#  test "number based translations" do
##    key = Tr8n::TranslationKey.find_or_create("{count} {_messages}")
##    lrule1 = NumericRule.create(:language => @russian, :multipart => false, :part1 => "is", :value1 => "1")    
##    lrule2 = NumericRule.create(:language => @russian, :multipart => false, :part1 => "is_not", :value1 => "1")    
##
##    assert key.add_translation("{count} сообщение", [TranslationRule.new(:language_rule => lrule1, :token => "count")])
###    assert key.add_translation("{count} сообщений", [TranslationRule.new(:language_rule => lrule2, :token => "count")])
##    
##    assert_equal "1 сообщение", key.translate(@russian, :count => 1, :_messages => "message")
## #   assert_equal "10 сообщений", key.translate(@russian, :count => 10, :_messages => "messages")
#  end

end
