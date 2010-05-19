class Tr8n::TranslationRule < ActiveRecord::Base
  set_table_name :tr8n_translation_rules
  establish_connection(Tr8n::Config.database) if Tr8n::Config.use_remote_database?
 
  belongs_to :translation,    :class_name => "Tr8n::Translation"
  belongs_to :language_rule,  :class_name => "Tr8n::LanguageRule"
  
  def describe
    return "<strong>#{token}</strong> invalid language rule" unless language_rule
    "<strong>#{token}</strong> #{language_rule.describe}"
  end
  
  def evaluate(token_values)
    return false unless language_rule
    
    token_value = token_values[token.to_sym]
    token_value = token_value.first if token_value.is_a?(Array)
    language_rule.evaluate(token_value)
  end
  
  def dependency
    return unless language_rule
    {"#{token}" => {language_rule.dependency => "true"}}
  end
  
end
