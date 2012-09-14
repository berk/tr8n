#--
# Copyright (c) 2010-2012 Michael Berkovich, tr8n.net
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
#  created_at       datetime        
#  updated_at       datetime        
#
# Indexes
#
#  index_tr8n_language_rules_on_language_id_and_translator_id    (language_id, translator_id) 
#  index_tr8n_language_rules_on_language_id                      (language_id) 
#
#++

class Tr8n::ListRule < Tr8n::LanguageRule
  def self.description
    "token object may be a list, which"
  end
  
  def self.dependency
    "list" 
  end

  def self.suffixes
    Tr8n::Config.rules_engine[:list_rule][:token_suffixes]
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
    return nil unless token and token.respond_to?(Tr8n::Config.rules_engine[:list_rule][:object_method])
    token.send(Tr8n::Config.rules_engine[:list_rule][:object_method])
  end

  def list_size_token_value(token)
    self.class.list_size_token_value(token)
  end

  # params: [object, one element, at least two elements]
  # {user_list | one element, at least two elements}
  def self.transform(*args)
    unless args.size == 3
      raise Tr8n::Exception.new("Invalid transform arguments")
    end
    
    object = args[0]
    list_size = list_size_token_value(object)

    unless list_size
      raise Tr8n::Exception.new("Token #{object.class.name} does not respond to #{Tr8n::Config.rules_engine[:gender_list_rule][:object_method]}")
    end
    
    list_size = list_size.to_i
    
    return args[1] if list_size == 1
    return args[2] if list_size >= 2
    
    # should we raise an exception here if the list is empty?
    ""  
  end  
  
  # params: [one element, at least two elements]
  def self.default_transform(*args)
    unless args.size == 2
      raise Tr8n::Exception.new("Invalid transform arguments for list token")
    end
    
    args[1]
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
