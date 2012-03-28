require File.expand_path('../../spec_helper', File.dirname(__FILE__))

describe Tr8n::Translator do
  describe 'finding translator' do
  	it 'should create a correct cache_key' do
  		user = User.create(:first_name => 'Mike')
  		Tr8n::Translator.cache_key(user.id).should eq("translator_#{user.id}")
  	end

  	it 'should return nil for guest user' do 
  		user = User.new(:first_name => 'Mike')
  		Tr8n::Translator.for(user).should be_nil
  	end

  	it 'should return nil for nil user' do 
  		Tr8n::Translator.for(nil).should be_nil
  	end

  	it 'should return itself if the user is a translator' do 
  		u = User.new(:first_name => 'Mike')
  		t = Tr8n::Translator.create(:user => u)
  		Tr8n::Translator.for(u).should eq(t)
  	end

  	it 'should not create a new translator for guest user' do
  		u = User.new(:first_name => 'Mike')
			t = Tr8n::Translator.find_or_create(u)
			t.should be_nil
  	end

    it 'should create a new translator' do
      u = User.create(:first_name => 'Mike')
      t = Tr8n::Translator.find_or_create(u)
      t.user.should eq(u)
    end

  	it 'should find an existing translator' do
  		u = User.new(:first_name => 'Mike')
  		t = Tr8n::Translator.create(:user => u)
			Tr8n::Translator.find_or_create(u).should eq(t)
  	end
  end

  describe 'registering a translator' do
  	context 'when user is not defined' do
	  	it 'should not register a translator' do 
        Tr8n::Config.init('en-US', nil)
	  		Tr8n::Translator.register.should be_nil
			end  	
	  	it 'should not register a translator for guest user' do 
	  		u = User.new(:first_name => 'Mike')
	  		Tr8n::Config.init('en-US', u)
	  		Tr8n::Translator.register.should be_nil
			end  	
		end
		
  	context 'when user is defined' do
      it 'should register a translator and update language users' do 
        u = User.create(:first_name => 'Mike')
        lang = Tr8n::Language.create(:locale => 'elbonian', :english_name => 'Elbonian')
        Tr8n::LanguageUser.create(:user => u, :language => lang)

        Tr8n::Config.init('en-US', u)
        t = Tr8n::Translator.register
        t.should be_a(Tr8n::Translator)
        t.language_users.count.should eq(1)
        t.language_users.first.user.should eq(u)
        t.language_users.first.translator.should eq(t)
      end   
		end
	end  

  describe 'metric' do
    context 'when translator is created' do
      before :all do 
        @u = User.create(:first_name => 'Mike')
        @t = Tr8n::Translator.register(@u)
      end

      it 'it should have a metric' do
        @t.total_metric.should be_a(Tr8n::TranslatorMetric)
      end

      it 'it should have zero rank' do
        @t.rank.should eq(0)
      end
    end
  end

  describe 'blocking and unblocking translators' do
    context 'when translator is blocked' do
      before :all do 
        @admin = User.create(:first_name => 'Admin')
        @lang = Tr8n::Language.create(:locale => 'elbonian', :english_name => 'Elbonian')
        @user = User.create(:first_name => 'Mike')
        @translator = Tr8n::Translator.register(@user)
        @translator.block!(@admin)

        @tkey = Tr8n::TranslationKey.find_or_create("Hello World")
        Tr8n::Config.init(@lang.locale, @user)
      end

      it 'should prevent the translator from submitting translations' do
        @translator.blocked?.should be_true
        expect { @tkey.add_translation('Privet Mir') }.should raise_error
      end
    end

    context 'when translator is not blocked' do
      before :all do 
        @lang = Tr8n::Language.create(:locale => 'elbonian', :english_name => 'Elbonian')
        @user = User.create(:first_name => 'Mike')
        @translator = Tr8n::Translator.register(@user)

        @tkey = Tr8n::TranslationKey.find_or_create("Hello World")
        Tr8n::Config.init(@lang.locale, @user)
      end

      it 'should prevent the translator from submitting translations' do
        @translator.blocked?.should eq(false)
        @tkey.add_translation('Privet Mir').should be_a(Tr8n::Translation)
      end
    end    
  end

  describe 'toggling inline translations' do
    context 'enables it on and off' do
      it 'should be on' do
        @user = User.create(:first_name => 'Mike')
        @translator = Tr8n::Translator.register(@user)
        @translator.inline_mode.should be_false
        @translator.enable_inline_translations!
        @translator.inline_mode.should be_true
        @translator.disable_inline_translations!
        @translator.inline_mode.should be_false
      end
    end
  end

end
