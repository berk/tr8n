#--
# Copyright (c) 2010-2013 Michael Berkovich, tr8nhub.com
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
#
#-- Tr8n::GenderRule Schema Information
#
# Table name: tr8n_language_rules
#
#  id               INTEGER         not null, primary key
#  language_id      integer         not null
#  translator_id    integer         
#  type             varchar(255)    
#  definition       text            
#  created_at       datetime        not null
#  updated_at       datetime        not null
#  keyword          varchar(255)    
#
# Indexes
#
#  tr8n_lr_tlk    (type, language_id, keyword) 
#  tr8n_lr_lt     (language_id, translator_id) 
#  tr8n_lr_l      (language_id) 
#
#++

class Tr8n::GenderRule < Tr8n::LanguageRule
  
  def self.config
    Tr8n::Config.rules_engine[:gender_rule]
  end

  def self.description
    "token object may have a gender, which"
  end
  
  def self.dependency
    "gender" 
  end

  def self.suffixes
    config[:token_suffixes]
  end

  def self.default_rules_for(language = Tr8n::Config.current_language)
    Tr8n::Config.default_gender_rules(language.locale)
  end
  
  def self.operator_options
    [["is", "is"], ["is not", "is_not"]]
  end

  def self.gender_options
    [["a male", "male"], ["a female", "female"], ["neutral", "neutral"], ["unknown", "unknown"]]
  end
  
  def self.gender_token_value(token)
    if token.is_a?(Hash)
      return nil unless token and token[:object]
      return token[:object][config[:object_method]]
    end

    return nil unless token and token.respond_to?(config[:object_method])
    token.send(config[:object_method])
  end
  
  def gender_token_value(token)
    self.class.gender_token_value(token)
  end

  def self.gender_object_value_for(type)
    config[:method_values][type]
  end

  def gender_object_value_for(type)
    self.class.gender_object_value_for(type)
  end
  
  # FORM: [male, female(, unknown)]
  # {user | registered on}
  # {user | he, she}
  # {user | he, she, he/she}
  # {user | male: he, female: she, unknown: he/she}
  # {user | female: she, other: he}
  def self.transform_params_to_options(params)
    options = {}
    if params[0].index(':')
      params.each do |arg|
        parts = arg.split(':')
        options[parts.first.strip.to_sym] = parts.last.strip
      end
    else # default falback to {|| male, female} or {|| male, female, unknown} 
      if params.size == 1 # doesn't matter
        options[:other] = params[0]
      elsif params.size == 2 # {|| singular}
        options[:male] = params[0]
        options[:female] = params[1]
        options[:other] = "#{params[0]}/#{params[1]}"
      elsif params.size == 3
        options[:male] = params[0]
        options[:female] = params[1]
        options[:other] = params[2]
      else
        raise Tr8n::Exception.new("Invalid number of parameters in the transform token #{token}")
      end  
    end
    options    
  end

  def self.default_transform(token, params)
    options = transform_params_to_options(params)
    options[:male] || options[:female] || options[:other]
  end  

  def evaluate(token)
    token_value = gender_token_value(token)
    return false unless token_value
    
    if definition[:operator] == "is"
      return true if token_value == gender_object_value_for(definition[:value])
    elsif definition[:operator] == "is_not"
      return true if token_value != gender_object_value_for(definition[:value])
    end
    
    false    
  end

  def to_hash
    {:type => self.class.dependency, :operator => definition[:operator], :value => definition[:value]}
  end

  # used to describe a context of a given translation
  def description
    if definition[:operator] == "is"
      return "is a #{definition[:value]}" if ["male", "female"].include?(definition[:value])
      return "has a neutral gender" if "neutral" == definition[:value]
      return "has an unknown gender" if "unknown" == definition[:value]
    end
    
    if definition[:operator] == "is_not"
      return "is not a #{definition[:value]}" if ["male", "female"].include?(definition[:value])
      return "does not have a neutral gender" if "neutral" == definition[:value]
      return "does not have an unknown gender" if "unknown" == definition[:value]
    end

    "has an unknown rule"
  end

end
