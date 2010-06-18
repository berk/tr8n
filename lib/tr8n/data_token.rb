class Tr8n::DataToken < Tr8n::Token
  
  # tokens of a form
  # {count} 
  # {count:number} 
  # {user:gender} 
  # {user.name}  - this notation should be depricated in the future
  # {user.name:gender}
  def self.parse(label)
    tokens = []
    label.scan(/(\{[^_][\w]+(:[\w]+)?\})/).uniq.each do |token_array|
      tokens << self.new(token_array.first) 
    end
    tokens
  end

end
