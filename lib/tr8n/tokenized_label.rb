class Tr8n::TokenizedLabel
    
  def initialize(label)
    @label = label
  end

  def label
    @label
  end
  
  def tokens
    @tokens ||= label.scan(/\{[\w\.]*\}/).uniq
  end

  def tokens?
    not tokens.empty?
  end

  def self.hidden_token?(token)
    stripped_token = strip_token(token)
    stripped_token.first == "_" 
  end

  def hidden_token?(token)
    self.class.hidden_token?(token)
  end

  def hidden_tokens
    @hidden_tokens ||= tokens.select{|token| hidden_token?(token)}
  end

  def hidden_tokens?
    not hidden_tokens.empty?
  end

  def sanitized_tokens
    @sanitized_tokens ||= (tokens - hidden_tokens)
  end

  def sanitized_tokens?
    sanitized_tokens.any?
  end

  def lambda_tokens(translated_label = label)
    @lambda_tokens ||= translated_label.scan(/\[[\w\.\,\{\}\s\-\:\/]*\]/)  
  end

  def lambda_tokens?
    not lambda_tokens.empty?
  end

  def self.parse_lambda_token(token)
    lambda_parts = token.gsub("[", "").gsub("]", "").split(":")
    return [nil, nil] if lambda_parts.size != 2
    [lambda_parts.first.strip.to_sym, lambda_parts.last.strip]
  end

  def parse_lambda_token(token)
    self.class.parse_lambda_token(token)
  end

  def sanitized_lambda_tokens(translated_label = label)
    @sanitized_lambda_tokens ||= lambda_tokens(translated_label).collect{|lt| parse_lambda_token(lt).first}
  end

  def sanitized_lambda_tokens?
    sanitized_lambda_tokens.any?
  end

  def self.strip_token(token)
    token.gsub("{", "").gsub("}", "")
  end

  def strip_token(token)
    self.class.strip_token(token)
  end

  def self.token_suffix(token)
    strip_token(token).split("_").last
  end
  
  def humanize_token(token)
    humanized_token = strip_token(token)[1..-1]
    {"_"=>"/", "__"=>" "}.each do |key, value|
      humanized_token.gsub!(key, value)
    end
    humanized_token
  end
  
  def sanitized_label
    @sanitized_label ||= begin 
      lbl = label.clone
      tokens.each do |token| 
        next unless hidden_token?(token)
        lbl.gsub!(token, humanize_token(token))
      end
      lbl
    end 
  end
  
  # used for google suggestions
  def tokenless_label
    @tokenless_label ||= begin
      lbl = sanitized_label.clone
      tokens.each do |token| 
        lbl.gsub!(token, "")
      end
      lbl.gsub("  ", " ").strip
    end
  end 
  
  def words
    return [] if label.blank?
    
    @words ||= begin 
      clean_label = sanitized_label
      parts = []
      [",", ".", ";", "!", "-", ":", "'", "\"", "[", "]", "{", "}"].each do |p|
        clean_label = clean_label.gsub(p, "")
      end
      
      clean_label.split(" ").each do |w|
        parts << w.strip.capitalize if w.length > 3
      end
      parts
    end
  end
  
end