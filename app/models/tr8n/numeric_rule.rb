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
#-- Tr8n::NumericRule Schema Information
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

class Tr8n::NumericRule < Tr8n::LanguageRule

  def self.description
    "token object may be a number, which"
  end

  def self.dependency
    "number" 
  end

  def self.config
    Tr8n::Config.rules_engine[:numeric_rule]
  end

  def self.suffixes
    config[:token_suffixes]
  end

  def self.default_rules_for(language = Tr8n::Config.current_language)
    Tr8n::Config.default_numeric_rules(language.locale)
  end

  def self.rule_options
    [["is", "is"], ["is not", "is_not"], ["ends in", "ends_in"], ["does not end in", "does_not_end_in"]]
  end
  
  def self.operator_options
    ["and", "or"]
  end

  def self.number_token_value(token)
    return nil unless token and token.respond_to?(config[:object_method])
    token.send(config[:object_method])
  end

  def self.sanitize_values(values)
    return [] unless values
    values.split(",").collect{|val| val.strip} 
  end

  def self.humanize_values(values)
    sanitize_values(values).join(", ")
  end

  # FORM: [singular(, plural)]
  # {count | message}
  # {count | person, people}
  # {count | one: person, other: people}
  # "У вас есть {count|| one: сообщение, few: сообщения, many: сообщений}"
  def self.transform_params_to_options(params)
    options = {}
    if params[0].index(':')
      params.each do |arg|
        parts = arg.split(':')
        options[parts.first.strip.to_sym] = parts.last.strip
      end
    else # default falback to {|| singular} or {|| singular, plural} - mostly for English support
      if params.size == 1 # {|| singular}
        options[:one] = params[0]
        options[:many] = params[0].pluralize
      elsif params.size == 2
        options[:one] = params[0]
        options[:many] = params[1]
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
  
  def self.evaluate_rule_fragment(token_value, name, values)
    if name == :is
      return true if values.include?(token_value)
      return false
    end
    
    if name == :is_not
      return true unless values.include?(token_value)
      return false
    end

    if name == :ends_in
      values.each do |value|
        return true if token_value.to_s =~ /#{value.to_s}$/  
      end
      return false
    end

    if name == :does_not_end_in
      values.each do |value|
        return false if token_value.to_s =~ /#{value.to_s}$/  
      end
      return true
    end
    
    false
  end

  def evaluate(token)
    token_value = number_token_value(token)  
    return false unless token_value
    
    result1 = self.class.evaluate_rule_fragment(token_value.to_s, definition[:part1].to_sym, sanitize_values(definition[:value1]))
    return result1 unless definition[:multipart].to_s == "true"
    
    result2 = self.class.evaluate_rule_fragment(token_value.to_s, definition[:part2].to_sym, sanitize_values(definition[:value2]))
    return (result1 or result2) if definition[:operator] == "or"
    return (result1 and result2)
    
    false
  end

  def number_token_value(token)
    self.class.number_token_value(token)
  end

  def sanitize_values(values)
    self.class.sanitize_values(values)
  end

  def humanize_values(values)
    self.class.humanize_values(values)
  end

  def to_hash
    { :type => self.class.dependency, 
      :multipart => definition[:multipart], :operator => definition[:operator],  
      :part1 => definition[:part1], :value1 => definition[:value1],
      :part2 => definition[:part2], :value2 => definition[:value2]
    }
  end

  # used to describe a context of a given translation
  def description
    rule_desc = describe_partial_rule(definition[:part1].to_sym, definition[:value1])
    return rule_desc unless definition[:multipart].to_s == "true"
    
    rule_desc << " " << definition[:operator] << " " 
    rule_desc << describe_partial_rule(definition[:part2].to_sym, definition[:value2])
    humanize_description(rule_desc)   
  end
  
  def describe_partial_rule(name, value)
    return "is #{humanize_values(value)}" if name == :is
    return "is not #{humanize_values(value)}" if name == :is_not
    return "ends in #{humanize_values(value)}" if name == :ends_in
    return "does not end in #{humanize_values(value)}" if name == :does_not_end_in

    "has an unknown rule"
  end
  
  def humanize_description(desc)
    desc.gsub(" and does not end in", ", but not in")
  end
  
end
