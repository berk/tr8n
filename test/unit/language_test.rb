require File.expand_path(File.dirname(__FILE__) + '/base_test.rb') 

class Tr8n::LanguageTest < Tr8n::BaseTest 


  def setup
    super
    @user = Tr8n::Translator.create!(:id => 2, :user_id => 2, :name => "Mike")
    @russian = Tr8n::Language.for("ru")
    @spanish = Tr8n::Language.create!(:id => 1, :locale => "es", :english_name => "Spanish")
  end
  
  test "default language" do
    assert_equal "en-US", Tr8n::Config.default_locale
    assert_equal "en-US", Tr8n::Config.default_language.locale
  end
  
  test "translations" do
    assert_equal "Hello World", @default_language.translate("Hello World")
    assert_equal "Hello World", @default_language.translate("Hello {world}", "", :world => "World")
    
    
  end
  
  
#  
#  
#  test "init and clear language" do
#    Language.clear_language
#    assert_nil Language.current_user 
#    assert_equal Language.default_language, Language.current_language 
#
#    Language.init_language(@language, @user)
#    assert_equal @user, Language.current_user 
#    assert_equal @language, Language.current_language 
#    assert (not Language.current_user_is_a_translator?)
#
#    Language.clear_language
#    assert_nil Language.current_user 
#    assert_equal Language.default_language, Language.current_language 
#  end
#
#  test "create a translator" do
#    Language.init_language(@language, @user)
#    assert Language.current_translator 
#    assert Language.current_user_is_a_translator?
#  end
#  
#  test "language properties" do
#    Language.init_language(@language, @user)
#    assert_equal 'ru', @language.locale  
#    assert_equal 'ru', @language.flag  
#    assert_equal 'Russian', @language.english_name
#    assert (not @language.default_language?)
#  end
#  
#  test "enable and disable language" do
#    @language.disable!
#    assert @language.disabled?
#    assert (not Language.enabled_languages.include?(@language))
#    
#    @language.enable!
#    assert @language.enabled?
#    assert Language.enabled_languages.include?(@language)
#  end
#  
#  test "rules" do
#    assert @language.has_rules?
#    assert @language.has_gender_rules?
#    assert @language.has_numeric_rules?
#    assert @language.default_rule
#    assert @language.default_rules_for(:number)
#    assert @language.default_rules_for(:gender)
#  end
#  
#  test "calculate completeness" do
#    assert @language.calculate_completeness!
#  end
#  
#  test "prohibited words" do
#    Language.default_language.update_attributes(:curse_words => "word1, word2, word3")
#    assert_equal ["word1", "word2", "word3"], @language.bad_words  
#    assert (not @language.clean_sentence?("I am using word1 in my sentence"))
#
#    @language.reload
#    @language.update_attributes(:curse_words => "-word1, word4, word5")
#    assert_equal ["word4", "word5", "word2", "word3"], @language.bad_words  
#    assert @language.clean_sentence?("I am using word1 in my sentence")
#  end
#  
#  test "translate" do
#    assert_equal "Hello World", @language.translate("Hello World")
#  end
#
#  test "localize date" do
#    time = Time.now
#    assert_equal time.strftime("%m/%d/%Y"), @language.localize_date(time)
#  end
  
end
