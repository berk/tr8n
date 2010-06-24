#--
# Copyright (c) 2010 Michael Berkovich, Geni Inc
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#++

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
        lbl = token.prepare_label_for_translator(lbl)
      end
      lbl
    end 
  end
  
  def tokenless_label
    @tokenless_label ||= begin
      lbl = label.clone
      data_tokens.each do |token|
        lbl = token.prepare_label_for_suggestion(lbl)
      end
      lbl
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