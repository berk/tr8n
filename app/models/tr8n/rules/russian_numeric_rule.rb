# This is an example of how you could implement the transform 
# function for the default transform_tokens 
# if your default site language is Russian

class Tr8n::RussianNumericRule < Tr8n::NumericRule

  # FORM: [object, (ends in 1, but not in 11), (ends in 2, 3, 4 and is not 12, 13, 14), (ends in 0, 5, 6, 7, 8, 9, 11, 12, 13, 14)]
  # {count | собака, собаки, собак}
  # {count | сообщение, сообщения, сообщений}
  def self.transform(*args)
    if args.size != 4
      raise Tr8n::Exception.new("Invalid transform arguments")
    end
    
    object = args[0]
    object_value = number_token_value(object)
    unless object_value
      raise Tr8n::Exception.new("Token #{object.class.name} does not respond to #{Tr8n::Config.rules_engine[:numeric_rule][:object_method]}")
    end

    string_value = object_value.to_s

    if string_value.last == "1" and string_value != "11"
      return args[1]
    elsif ['2', '3', '4'].include?(string_value.last) and not ['12', '13', '14'].include?(string_value)
      return args[2]
    end
    
    args[3]
  end
  
end
