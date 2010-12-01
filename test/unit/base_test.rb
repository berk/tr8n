require File.expand_path(File.dirname(__FILE__) + '/../test_helper.rb') 

class Tr8n::BaseTest < ActiveRecord::TestCase

  def setup
    @current_user = Tr8n::Translator.create!(:id => 1, :user_id => 1, :name => "Mike", :gender => "male")
    @default_language = Tr8n::Language.create!(:locale => Tr8n::Config.default_locale, :english_name => "English")
    @current_language = Tr8n::Language.create!(:id => 1, :locale => "ru", :english_name => "Russian")
    Tr8n::Config.init(@current_language.locale, @current_user)
  end
  
end