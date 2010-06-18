class Tr8n::HiddenToken < Tr8n::Token
  
  # tokens of a form
  # {_he_she} 
  # {_posted__items} 
  def self.parse(label)
    tokens = []
    label.scan(/\{_[\w]+\}/).uniq.each do |token|
      tokens << self.new(token) 
    end
    tokens
  end

  def allowed_in_translation?
    false
  end

  def language_rule
    nil
  end

  def sanitize_label(label)
    label.gsub(full_name, humanized_name)
  end
  
  def humanized_name
    @humanized_name ||= begin
      hnm = name[1..-1].clone
      hnm.gsub!('__', ' ')
      hnm.gsub!('_', '/')
      hnm
    end
  end
  
end
