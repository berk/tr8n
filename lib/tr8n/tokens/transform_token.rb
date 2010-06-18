####################################################################### 
# 
# Transform Token Form
#
# {count | message}   - will not include count: "messages" 
# {count | message, messages} 
# {count:number | message, messages} 
# {user:gender | he, she, he/she}
# {now:date | did, does, will do}
# {users:list | all male, all female, mixed genders}
#
# {count || message, messages}  - will include count:  "5 messages" 
# 
####################################################################### 

class Tr8n::TransformToken < Tr8n::Token
    
  def self.expression
    /(\{[^_][\w]+(:[\w]+)?\s*\|\|?[^{^}]+\})/
  end

  def name
    @name ||= declared_name.split('|').first.split(':').first.strip
  end
  
  def sanitized_name
    "{#{name}}"
  end

  def pipe_separator
    @pipe_separator ||= (full_name.index("||") ? "||" : "|") 
  end
  
  def piped_params
    @piped_params ||= declared_name.split(pipe_separator).last.split(",").collect{|param| param.strip}
  end
  
  def allowed_in_translation?
    pipe_separator == "||" 
  end
  
  def token_object(object)
    # token is an array
    if object.is_a?(Array)
      # if you provided an array, it better have some values
      if object.empty?
        return raise Tr8n::TokenException.new("Invalid array object for a transform token: #{full_name}")
      end

      # if the first item in the array is an object, process it
      return object.first
    end

    object    
  end
  
  # return with the default transform substitution
  def prepare_label_for_translator(label)
    unless dependant?
      raise Tr8n::TokenException("Unknown dependency type for #{full_name} token; no way to apply the transform method.")
    end
    
    unless language_rule.respond_to?(:default_transform)
      raise Tr8n::TokenException("#{language_rule.class.name} does not respond to the default transform method.")
    end
    
    substitution_value = "" 
    substitution_value << token_value(object, options) if allowed_in_translation?
    substitution_value << " " unless substitution_value.blank?
    substitution_value << language_rule.default_transform(*piped_params)
    
    label.gsub(full_name, substitution_value)    
  end

  # return only the internal part
  def prepare_label_for_suggestion(label)
    prepare_label_for_translator(label)
  end
  
  def substitute(label, values = {}, options = {}, language = Tr8n::Config.current_language)
    # only the default language allows for the transform tokens
    return label unless language.default?
    
    object = values[name_key]
    unless object
      raise Tr8n::TokenException.new("Missing value for a token: #{full_name}")
    end
    
    unless dependant?
      raise Tr8n::TokenException("Unknown dependency type for #{full_name} token; no way to apply the transform method.")
    end
    
    unless language_rule.respond_to?(:transform)
      raise Tr8n::TokenException("#{language_rule.class.name} does not respond to the transform method.")
    end
    
    params = [token_object(object)] + piped_params
    substitution_value = "" 
    substitution_value << token_value(object, options) if allowed_in_translation?
    substitution_value << " " unless substitution_value.blank?
    substitution_value << language_rule.transform(*params)
    
    label.gsub(full_name, substitution_value)    
  end
  
end
