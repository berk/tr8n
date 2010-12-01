require File.expand_path(File.dirname(__FILE__) + '/base_test.rb') 

class Tr8n::TokenTest < Tr8n::BaseTest

  test "data tokens" do
    tokens = Tr8n::Tokens::DataToken.parse("Hello {user}, you have {count} messages in your inbox")
    assert_equal ["{user}", "{count}"], tokens.collect{|t| t.full_name}
    assert_equal ["{user}", "{count}"], tokens.collect{|t| t.sanitized_name}
    assert_equal ["user", "count"], tokens.collect{|t| t.name}
    
    tokens = Tr8n::Tokens::DataToken.parse("Hello {user:gender}, you have {count:number} messages in your inbox")
    assert_equal ["{user:gender}", "{count:number}"], tokens.collect{|t| t.full_name}
    assert_equal ["{user}", "{count}"], tokens.collect{|t| t.sanitized_name}
    assert_equal ["user", "count"], tokens.collect{|t| t.name}
    
    tokens = Tr8n::Tokens::DataToken.parse("Hello {user:gender}, you have {count} messages in your inbox")
    assert_equal ["{user:gender}", "{count}"], tokens.collect{|t| t.full_name}
    assert_equal ["{user}", "{count}"], tokens.collect{|t| t.sanitized_name}
    assert_equal ["user", "count"], tokens.collect{|t| t.name}
    
    tokens = Tr8n::Tokens::DataToken.parse("Hello {user:gender}, you have {_count} messages in your inbox")
    assert_equal ["{user:gender}"], tokens.collect{|t| t.full_name}
    assert_equal ["{user}"], tokens.collect{|t| t.sanitized_name}
    assert_equal ["user"], tokens.collect{|t| t.name}
  end

  test "hidden tokens" do
    tokens = Tr8n::Tokens::HiddenToken.parse("{user} updated {_his_her} profile")
    assert_equal ["{_his_her}"], tokens.collect{|t| t.full_name}
    assert_equal ["{_his_her}"], tokens.collect{|t| t.sanitized_name}
    assert_equal ["_his_her"], tokens.collect{|t| t.name}
    assert_equal ["his/her"], tokens.collect{|t| t.humanized_name}

    tokens = Tr8n::Tokens::HiddenToken.parse("{user} has {count} {_posted__items} in {_his_her} inbox")
    assert_equal ["{_posted__items}", "{_his_her}"], tokens.collect{|t| t.full_name}
    assert_equal ["{_posted__items}", "{_his_her}"], tokens.collect{|t| t.sanitized_name}
    assert_equal ["_posted__items", "_his_her"], tokens.collect{|t| t.name}
    assert_equal ["posted items", "his/her"], tokens.collect{|t| t.humanized_name}

    tokens = Tr8n::Tokens::HiddenToken.parse("{user:gender} has {count:number} {_posted__items:number} in {_his_her} inbox")
    assert_equal ["{_his_her}"], tokens.collect{|t| t.full_name}
    assert_equal ["{_his_her}"], tokens.collect{|t| t.sanitized_name}
    assert_equal ["_his_her"], tokens.collect{|t| t.name}
    assert_equal ["his/her"], tokens.collect{|t| t.humanized_name}
  end
  
  test "method tokens" do
    tokens = Tr8n::Tokens::MethodToken.parse("{user} {user.name} updated {_his_her} profile")
    assert_equal ["{user.name}"], tokens.collect{|t| t.full_name}
    assert_equal ["{user.name}"], tokens.collect{|t| t.sanitized_name}
    assert_equal ["user.name"], tokens.collect{|t| t.name}

    tokens = Tr8n::Tokens::MethodToken.parse("{user.first_name} [link: {user.last_name}] updated {_his_her} profile")
    assert_equal ["{user.first_name}", "{user.last_name}"], tokens.collect{|t| t.full_name}
    assert_equal ["{user.first_name}", "{user.last_name}"], tokens.collect{|t| t.sanitized_name}
    assert_equal ["user.first_name", "user.last_name"], tokens.collect{|t| t.name}

    tokens = Tr8n::Tokens::MethodToken.parse("{user.first_name:gender} [link: {user.last_name:gender}] updated {_his_her} profile")
    assert_equal ["{user.first_name:gender}", "{user.last_name:gender}"], tokens.collect{|t| t.full_name}
    assert_equal ["{user.first_name}", "{user.last_name}"], tokens.collect{|t| t.sanitized_name}
    assert_equal ["user.first_name", "user.last_name"], tokens.collect{|t| t.name}
  end
  
  test "transform tokens" do
    tokens = Tr8n::Tokens::TransformToken.parse("{user.name} updated {user|his,her} profile")
    assert_equal ["{user|his,her}"], tokens.collect{|t| t.full_name}
    assert_equal ["{user}"], tokens.collect{|t| t.sanitized_name}
    assert_equal ["user"], tokens.collect{|t| t.name}
    
    tokens = Tr8n::Tokens::TransformToken.parse("{user.name} updated {user:gender|his,her} profile")
    assert_equal ["{user:gender|his,her}"], tokens.collect{|t| t.full_name}
    assert_equal ["{user}"], tokens.collect{|t| t.sanitized_name}
    assert_equal ["user"], tokens.collect{|t| t.name}
    
    tokens = Tr8n::Tokens::TransformToken.parse("{user.name} updated {count:number|message} profile")
    assert_equal ["{count:number|message}"], tokens.collect{|t| t.full_name}
    assert_equal ["{count}"], tokens.collect{|t| t.sanitized_name}
    assert_equal ["count"], tokens.collect{|t| t.name}
    
    tokens = Tr8n::Tokens::TransformToken.parse("{user.name} updated {count||message} profile")
    assert_equal ["{count||message}"], tokens.collect{|t| t.full_name}
    assert_equal ["{count}"], tokens.collect{|t| t.sanitized_name}
    assert_equal ["count"], tokens.collect{|t| t.name}
  end  
  
  test "decoration tokens" do
    tokens = Tr8n::Tokens::DecorationToken.parse("You have [link1: {count} {count:number | new message, new messages}] in [link2: your inbox]")
    assert_equal ["[link1: {count} {count:number | new message, new messages}]", "[link2: your inbox]"], tokens.collect{|t| t.full_name}
    assert_equal ["[link1: ]", "[link2: ]"], tokens.collect{|t| t.sanitized_name}
    assert_equal ["link1", "link2"], tokens.collect{|t| t.name}
  end
  
  test "mixed tokens" do
    label = "{user.name} has [link1: {count} {count:number | new message}] in [link2: {user|his,her} inbox]"
    tokens = Tr8n::Token.register_data_tokens(label)

    assert_equal ["{count}",
                  "{user.name}",
                  "{count:number | new message}", 
                  "{user|his,her}"], tokens.collect{|t| t.full_name}

    assert_equal ["Tr8n::Tokens::DataToken",
                  "Tr8n::Tokens::MethodToken",
                  "Tr8n::Tokens::TransformToken", 
                  "Tr8n::Tokens::TransformToken"], tokens.collect{|t| t.class.name}
                  
    tokens = Tr8n::Token.register_decoration_tokens(label)

    assert_equal ["[link1: {count} {count:number | new message}]",
                  "[link2: {user|his,her} inbox]"], tokens.collect{|t| t.full_name}

    assert_equal ["Tr8n::Tokens::DecorationToken",
                  "Tr8n::Tokens::DecorationToken"], tokens.collect{|t| t.class.name}
  end
  
end
