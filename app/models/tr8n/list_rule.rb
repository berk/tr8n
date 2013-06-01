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
#-- Tr8n::ListRule Schema Information
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
#
# Indexes
#
#  tr8n_lr_lt    (language_id, translator_id) 
#  tr8n_lr_l     (language_id) 
#
#++

class Tr8n::ListRule < Tr8n::LanguageRule
  
  def self.config
    Tr8n::Config.rules_engine[:list_rule]
  end

  def self.description
    "token object may be a list, which"
  end
  
  def self.dependency
    "list" 
  end

  def self.suffixes
    config[:token_suffixes]
  end

  def self.default_rules_for(language = Tr8n::Config.current_language)
    Tr8n::Config.default_list_rules(language.locale)
  end
  
  def self.operator_options
    [["contains", "contains"]]
  end

  def self.list_options
    [["one element", "one_element"], ["at least 2 elements", "at_least_two_elements"]]
  end
  
  def self.list_size_token_value(token)
    return nil unless token and token.respond_to?(config[:object_method])
    token.send(config[:object_method])
  end

  def list_size_token_value(token)
    self.class.list_size_token_value(token)
  end

  # FORM: [one, many]
  # {actors|| likes, like} this story
  def self.transform_params_to_options(params)
    options = {}
    if params[0].index(':')
      params.each do |arg|
        parts = arg.split(':')
        options[parts.first.strip.to_sym] = parts.last.strip
      end
    else # default falback to {|| male, female} or {|| male, female, unknown} 
      if params.size == 2 # doesn't matter
        options[:one] = params[0]
        options[:other] = params[1]
      else
        raise Tr8n::Exception.new("Invalid number of parameters in the transform token #{token}")
      end  
    end
    options    
  end

  def self.default_transform(token, params)
    options = transform_params_to_options(params)
    options[:many] || options[:other]
  end  

  def evaluate(token)
    return false unless token.kind_of?(Enumerable)
    
    list_size = list_size_token_value(token)
    return false if list_size == nil
    list_size = list_size.to_i

    case definition[:value]
      when "one_element" then
        return true if list_size == 1
      when "at_least_two_elements" then
        return true if list_size >= 2
    end
    
    false
  end

  def to_hash
    {:type => self.class.dependency, :operator => definition[:operator], :value => definition[:value]}
  end

  # used to describe a context of a given translation
  def description
    return "contains one element"              if "one_element" == definition[:value]
    return "contains at least two elements"    if "at_least_two_elements" == definition[:value]
    "has an unknown rule"
  end
end
