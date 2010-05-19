class Tr8n::LanguageRule < ActiveRecord::Base
  set_table_name :tr8n_language_rules
  establish_connection(Tr8n::Config.database) if Tr8n::Config.use_remote_database?

  belongs_to :language, :class_name => "Tr8n::Language"   
  belongs_to :translator, :class_name => "Tr8n::Translator"   
  
  has_many   :translation_rules, :class_name => "Tr8n::TranslationRule", :dependent => :destroy
  
  def self.options
    [["token object may be a number, which", "Tr8n::NumericRule"], 
     ["token object may have a gender, which", "Tr8n::GenderRule"]]
  end
  
  def rule_options
    raise Tr8n::Exception.new("This method must be implemented in the extending rule") 
  end
  
  def evaluate(token_value)
    raise Tr8n::Exception.new("This method must be implemented in the extending rule") 
  end
  
  def describe
    raise Tr8n::Exception.new("This method must be implemented in the extending rule") 
  end
  
  def describe_rule
    raise Tr8n::Exception.new("This method must be implemented in the extending rule") 
  end
  
  def dependency
    raise Tr8n::Exception.new("This method must be implemented in the extending rule") 
  end
  
  def value1_type
    "text"
  end

  def value2_type
    "text"
  end
  
  def operator_options
    ["and", "or"]
  end
  
  def can_have_multiple_parts?
    false
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
