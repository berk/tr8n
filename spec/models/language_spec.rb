require File.expand_path('../spec_helper', File.dirname(__FILE__))

describe Tr8n::Language do
  describe 'finding or creating a new language' do
    context 'none existing language' do
      it 'should not be found' do
        lang = Tr8n::Language.for('test')
        lang.should be_nil
      end

      it 'should be created' do
        lang = Tr8n::Language.for('test')
        lang.should be_nil
        
        lang = Tr8n::Language.find_or_create('test', 'Test Language')
        lang.locale.should eql('test')
        lang.english_name.should eql('Test Language')

        lang = Tr8n::Language.for('test')
        lang.should be_a(Tr8n::Language)
        lang.english_name.should eql('Test Language')
      end
    end

    context 'existing language' do
      it 'should be found' do
        Tr8n::Language.create(:locale => 'test123', :english_name => 'Test Language 123')
        lang = Tr8n::Language.for('test123')
        lang.should be_a(Tr8n::Language)
        lang.english_name.should eql('Test Language 123')
      end
    end
  end  

  describe 'current language' do
    before :all do 
      @lang = Tr8n::Language.find_or_create('test', 'Test Language')
      Tr8n::Config.init(@lang.locale)
    end

    after :all do 
      @lang.destroy
    end

    it 'must be set' do
      lang = Tr8n::Language.for('test')
      lang.should be_a(Tr8n::Language)
      lang.current?.should be_true
    end
  end

  describe 'default language' do
    before :all do 
      @lang = Tr8n::Language.find_or_create('test', 'Test Language')
      Tr8n::Config.init(@lang.locale)
    end

    after :all do 
      @lang.destroy
    end

    it 'must be set' do
      Tr8n::Config.stub(:default_locale).and_return(@lang.locale)
      lang = Tr8n::Language.for('test')
      lang.should be_a(Tr8n::Language)
      lang.default?.should be_true
    end
  end

end    