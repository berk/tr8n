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
#-- Tr8n::DateRule Schema Information
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

class Tr8n::DateRule < Tr8n::LanguageRule
  
  def self.description
    "token object may be a date, which"
  end
  
  def self.dependency
    "date" 
  end

  def self.suffixes
    Tr8n::Config.rules_engine[:date_rule][:token_suffixes]
  end

  def self.default_rules_for(language = Tr8n::Config.current_language)
    Tr8n::Config.default_date_rules(language.locale)
  end
  
  def self.operator_options
    [["is in the", "is_in"]]
  end

  def self.date_options
    [["past", "past"], ["present", "present"], ["future", "future"]]
  end

  def self.date_token_value(token)
    return nil unless token and token.respond_to?(Tr8n::Config.rules_engine[:date_rule][:object_method])
    token.send(Tr8n::Config.rules_engine[:date_rule][:object_method])
  end

  def date_token_value(token)
    self.class.date_token_value(token)
  end

  # params: [object, past, present, future]
  # form: {date | did, is doing, will do}
  def self.transform(*args)
    if args.size != 4
      raise Tr8n::Exception.new("Invalid transform arguments")
    end
    
    object = args[0]
    object_date = date_token_value(object)

    unless object_date
      raise Tr8n::Exception.new("Token #{object.class.name} does not respond to #{Tr8n::Config.rules_engine[:date_rule][:object_method]}")
    end

    current_date = Date.today
    
    if object_date < current_date
      return args[1]
    elsif object_date > current_date
      return args[3]
    end
    
    args[2]
  end  

  # params: [past, present, future]
  # form: {date | did, is doing, will do}
  def self.default_transform(*args)
    if args.size != 3
      raise Tr8n::Exception.new("Invalid transform arguments for date token")
    end
    
    args[1]
  end  

  def evaluate(token)
    # for now - until we cleanup tokens
    return false unless token.is_a?(Date) or token.is_a?(Time)
    
    token_date = date_token_value(token)
    return false unless token_date
    
    current_date = Date.today
    
    case definition[:value]
      when "past" then
          return true if token_date < current_date
      when "present" then
          return true if token_date == current_date
      when "future" then
          return true if token_date > current_date
    end

    false    
  end

  # used to describe a context of a given translation
  def description
    if definition and self.class.date_options.collect{|o| o.last}.include?(definition[:value])
      return "is in the #{definition[:value]}"
    end
    
    "has an unknown rule"
  end
end
