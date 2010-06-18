class Tr8n::MethodToken < Tr8n::Token
  
  # tokens of a form
  # {count} 
  # {count:number} 
  # {user:gender} 
  # {user.name}  - this notation should be depricated in the future
  # {user.name:gender}
  def self.parse(label)
    tokens = []
    label.scan(/(\{[^_][\w]+(\.[\w]+)(:[\w]+)?\})/).uniq.each do |token_array|
      tokens << self.new(token_array.first) 
    end
    tokens
  end

  def object_name
    @object_name ||= name.split(".").first
  end

  def object_method_name
    @object_method_name ||= name.split(".").last
  end

  def substitute(label, values = {}, options = {}, language = Tr8n::Config.current_language)
    object = values[object_name.to_sym]
    raise Tr8n::TokenException.new("Missing value for a token: #{full_name}") unless object
    object_value = sanitize_token_value(object.send(object_method_name), options.merge(:sanitize_values => true))
    label.gsub(full_name, object_value)
  end
  
end
