class Tr8n::TokenizedLabel
   
  # constracts the label  
  def initialize(label)
    @label = label
  end

  def label
    @label
  end

  # scans for all token types    
  def data_tokens
    @data_tokens ||= Tr8n::Token.register_data_tokens(label)
  end

  def data_tokens?
    data_tokens.any?
  end

  def decoration_tokens
    @decoration_tokens ||= Tr8n::Token.register_decoration_tokens(label)
  end

  def decoration_tokens?
    decoration_tokens.any?
  end

  def tokens
    @tokens = data_tokens + decoration_tokens
  end

  def tokens?
    tokens.any?
  end

  # tokens that can be used by the user in translation
  def translation_tokens
    @translation_tokens ||= tokens.select{|token| token.allowed_in_translation?} 
  end

  def translation_tokens?
    translation_tokens.any?
  end

  def sanitized_label
    @sanitized_label ||= begin 
      lbl = label.clone
      data_tokens.each do |token|
        lbl = token.sanitize_label(lbl)
      end
      lbl
    end 
  end
  
  # used for google suggestions
  # TODO: need to fix decoration tokens
  def tokenless_label
    @tokenless_label ||= begin
      lbl = sanitized_label.clone
      data_tokens.each{|token| lbl.gsub!(token.full_name, "")}
      lbl.strip
    end
  end 
  
  def words
    return [] if label.blank?
    
    @words ||= begin 
      clean_label = sanitized_label
      parts = []
      clean_label = clean_label.gsub(/[\,\.\;\!\-\:\'\"\[\]{}]/, "")
      
      clean_label.split(" ").each do |w|
        parts << w.strip.capitalize if w.length > 3
      end
      parts
    end
  end
  
end