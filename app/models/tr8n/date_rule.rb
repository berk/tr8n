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
#  keyword          varchar(255)    
#
# Indexes
#
#  tr8n_lr_tlk    (type, language_id, keyword) 
#  tr8n_lr_lt     (language_id, translator_id) 
#  tr8n_lr_l      (language_id) 
#
#++

class Tr8n::DateRule < Tr8n::LanguageRule
  
  def self.config
    Tr8n::Config.rules_engine[:date_rule]
  end
  
  def self.description
    "token object may be a date, which"
  end
  
  def self.dependency
    "date" 
  end

  def self.suffixes
    config[:token_suffixes]
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
    return nil unless token and token.respond_to?(config[:object_method])
    token.send(config[:object_method])
  end

  def date_token_value(token)
    self.class.date_token_value(token)
  end

  # FORM: [past, present, future]
  # This event {date| past: took place, present: is taking place, future: will take place} on {date}.
  def self.transform_params_to_options(params)
    options = {}
    if params[0].index(':')
      params.each do |arg|
        parts = arg.split(':')
        options[parts.first.strip.to_sym] = parts.last.strip
      end
    else # default falback to {|| male, female} or {|| male, female, unknown} 
      if params.size == 3 # doesn't matter
        options[:past] = params[0]
        options[:present] = params[1]
        options[:other] = params[2]
      else
        raise Tr8n::Exception.new("Invalid number of parameters in the transform token #{token}")
      end  
    end
    options    
  end

  def self.default_transform(token, params)
    options = transform_params_to_options(params)
    options[:past] || options[:other]
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

  def to_hash
    { 
      :type => self.class.dependency, 
      :value => definition[:value]
    }
  end

end
