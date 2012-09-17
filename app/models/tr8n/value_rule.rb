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

class Tr8n::ValueRule < Tr8n::LanguageRule
  
  def self.description
    "token object may have a value, which"
  end
  
  def self.dependency
    "value" 
  end
  
  def self.dependant?(token)
    token.name != Tr8n::Config.rules_engine[:viewing_user_token]
  end

  def self.suffixes
    Tr8n::Config.rules_engine[:value_rule][:token_suffixes]
  end

  def self.default_rules_for(language = Tr8n::Config.current_language)
    Tr8n::Config.default_value_rules(language.locale)
  end
  
  def self.operator_options
    [["starts with", "starts_with"], ["does not start with", "does_not_start_with"], 
     ["ends in", "ends_in"], ["does not end in", "does_not_end_in"],
     ["is", "is"], ["is not", "is_not"]]
  end

  def self.transformable?
    false
  end

  def self.token_value(token)
    return nil unless token and token.respond_to?(Tr8n::Config.rules_engine[:value_rule][:object_method])
    token.send(Tr8n::Config.rules_engine[:value_rule][:object_method])
  end

  def evaluate(token)
    token_value = self.class.token_value(token)
    return false unless token_value

    token_value = token_value.gsub(/<\/?[^>]*>/, "")
    values = Tr8n::LanguageRule.sanitize_values(definition["value"])
    
    case definition["operator"]
      when "starts_with" 
        values.each do |value|
          return true if token_value.to_s =~ /^#{value.to_s}/  
        end
        return false
      when "does_not_start_with"         
        values.each do |value|
          return false if token_value.to_s =~ /^#{value.to_s}/  
        end
        return true
      when "ends_in"
        values.each do |value|
          return true if token_value.to_s =~ /#{value.to_s}$/  
        end
        return false
      when "does_not_end_in"         
        values.each do |value|
          return false if token_value.to_s =~ /#{value.to_s}$/  
        end
        return true
      when "is"         
        return values.include?(token_value)
      when "is_not"        
        return !values.include?(token_value)
    end
    
    false
  end

  def to_hash
    {:type => self.class.dependency, :operator => definition[:operator], :value => definition[:value]}
  end

  # used to describe a context of a given translation
  def description
    desc = ""
    case definition["operator"]
      when "starts_with" then desc << " starts with"
      when "does_not_start_with" then desc << " does not start with"        
      when "ends_in" then desc << " ends in"        
      when "does_not_end_in" then desc << " does not end in"        
      when "is" then desc << " is"        
      when "is_not" then desc << " is not"        
    end
    desc << " <strong>'" << Tr8n::LanguageRule.humanize_values(definition["value"]) << "'</strong>"
    desc.html_safe
  end

end
