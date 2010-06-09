class Tr8n::LanguageRule < ActiveRecord::Base
  set_table_name :tr8n_language_rules

  belongs_to :language, :class_name => "Tr8n::Language"   
  belongs_to :translator, :class_name => "Tr8n::Translator"   
  
  serialize :definition
  
  def self.for(language)
    find(:all, :conditions => ["language_id = ?", language.id])
  end
  
  def self.options
    @options ||= Tr8n::Config.language_rule_classes.collect{|kls| [kls.dependency, kls.name]}
  end
  
  def evaluate(token_value)
    raise Tr8n::Exception.new("This method must be implemented in the extending rule") 
  end
  
  def description
    raise Tr8n::Exception.new("This method must be implemented in the extending rule") 
  end
  
  def token_description
    raise Tr8n::Exception.new("This method must be implemented in the extending rule") 
  end
  
  def dependency
    raise Tr8n::Exception.new("This method must be implemented in the extending rule") 
  end
  
  def save_with_log!(new_translator)
    if self.id
      if changed?
        self.translator = new_translator
        translator.updated_language_rule!(self)
      end
    else  
      self.translator = new_translator
      translator.added_language_rule!(self)
    end

    save  
  end
  
  def destroy_with_log!(new_translator)
    new_translator.deleted_language_rule!(self)
    
    destroy
  end

end
