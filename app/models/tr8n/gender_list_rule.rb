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
#-- Tr8n::GenderListRule Schema Information
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

class Tr8n::GenderListRule < Tr8n::LanguageRule
  
  def self.config
    Tr8n::Config.rules_engine[:gender_list_rule]
  end

  def self.description
    "token object may be a list, which"
  end
  
  def self.dependency
    "gender_list" 
  end

  def self.dependency_label
    "list"
  end

  def self.suffixes
    config[:token_suffixes]
  end

  def self.default_rules_for(language = Tr8n::Config.current_language)
    Tr8n::Config.default_gender_list_rules(language.locale)
  end
  
  def self.part1_options
    [["contains", "contains"]]
  end

  def self.value1_options
    [["one element", "one_element"], ["at least 2 elements", "at_least_two_elements"]]
  end

  def self.part2_options(value1 = "one_element")
    return [["that are", "are"], ["that are not", "are_not"]] if value1 == "at_least_two_elements"
    [["that is", "is"], ["that is not", "is_not"]]
  end

  def self.value2_options(value1 = "one_element")
    return [["all male", "all_male"], ["all female", "all_female"], ["of mixed genders", "mixed"]] if value1 == "at_least_two_elements"
    [["male", "male"], ["female", "female"], ["unknown", "unknown"], ["neutral", "neutral"]]
  end
  
  def self.list_size_token_value(token)
    return nil unless token and token.respond_to?(config[:object_method])
    token.send(config[:object_method])
  end

  def list_size_token_value(token)
    self.class.list_size_token_value(token)
  end

  def self.male_female_occupants(arr)
    has_male = false  
    has_female = false
    has_unknown = false
    has_neutral = false

    arr.each do |object|
      object_gender = Tr8n::GenderRule.gender_token_value(object)
      return [false, false] unless object_gender
      has_male = true if object_gender == Tr8n::GenderRule.gender_object_value_for("male")
      has_female = true if object_gender == Tr8n::GenderRule.gender_object_value_for("female")
      has_unknown = true if object_gender == Tr8n::GenderRule.gender_object_value_for("unknown")
      has_neutral = true if object_gender == Tr8n::GenderRule.gender_object_value_for("neutral")
    end  
    
    [has_male, has_female, has_unknown, has_neutral]
  end
  
  def male_female_occupants(arr)
    self.class.male_female_occupants(arr)
  end
  
  # FORM: [one element male, one element female, at least two elements]
  # or: [one element, at least two elements]
  # {actors:gender_list|| likes, like} this story
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
    return false unless list_size
    
    list_size = list_size.to_i
    return false if list_size == 0

    has_male, has_female, has_unknown, has_neutral = male_female_occupants(token)
    
    if definition[:value1] == "one_element"
      return false unless list_size == 1
      return true unless definition[:multipart] == "true" 

      if definition[:part2] == "is"
        return true if definition[:value2] == "male"    and has_male
        return true if definition[:value2] == "female"  and has_female
        return true if definition[:value2] == "unknown" and has_unknown
        return true if definition[:value2] == "neutral" and has_neutral
        return false
      end

      if definition[:part2] == "is_not"
        return true if definition[:value2] == "male"    and !has_male
        return true if definition[:value2] == "female"  and !has_female
        return true if definition[:value2] == "unknown" and !has_unknown
        return true if definition[:value2] == "neutral" and !has_neutral
        return false
      end
      
      return false
    end
    
    if definition[:value1] == "at_least_two_elements"
      return false unless list_size >= 2
      return true unless definition[:multipart] == "true" 
    
      if definition[:part2] == "are"
        return true if definition[:value2] == "all_male" and (has_male and !(has_female or has_unknown or has_neutral))
        return true if definition[:value2] == "all_female" and (has_female and !(has_male or has_unknown or has_neutral))
        return true if definition[:value2] == "mixed" and ((has_male and (has_female or has_unknown or has_neutral)) or (has_female and (has_male or has_unknown or has_neutral)))
        return false
      end

      if definition[:part2] == "are_not"
        return true if definition[:value2] == "all_male" and (has_male and (has_female or has_unknown or has_neutral)) 
        return true if definition[:value2] == "all_female" and (has_female and (has_male or has_unknown or has_neutral)) 
        return true if definition[:value2] == "mixed" and ((has_male and !(has_female or has_unknown or has_neutral)) or (has_female and !(has_male or has_unknown or has_neutral)))
        return false
      end
      
      return false
    end
    
    false
  end

  def to_hash
    { :type => self.class.dependency, 
      :multipart => definition[:multipart],   
      :part1 => definition[:part1], :value1 => definition[:value1],
      :part2 => definition[:part2], :value2 => definition[:value2]
    }
  end

  # used to describe a context of a given translation
  def description
    if definition[:value1] == "one_element"
      desc = "contains one element"
      
      if definition[:multipart] == "true"
        if definition[:part2] == "is"
          desc << " that is a #{definition[:value2]}" if ["male", "female"].include?(definition[:value2])
          desc << " that has a neutral gender" if "neutral" == definition[:value2]
          desc << " that has an unknown gender" if "unknown" == definition[:value2]
        else
          desc << " that is not a #{definition[:value2]}" if ["male", "female"].include?(definition[:value2])
          desc << " that does not have a neutral gender" if "neutral" == definition[:value2]
          desc << " that does not have an unknown gender" if "unknown" == definition[:value2]
        end
      end
      
      return desc
    end
    
    if definition[:value1] == "at_least_two_elements"
      desc = "contains at least two elements"
      
      if definition[:multipart] == "true"
        if definition[:part2] == "are"
          desc << " that are all male" if "all_male" == definition[:value2]
          desc << " that are all female" if "all_female" == definition[:value2]
          desc << " that are of mixed genders" if "mixed" == definition[:value2]
        else
          desc << " that are not all male" if "all_male" == definition[:value2]
          desc << " that are not all female" if "all_female" == definition[:value2]
          desc << " that are not of mixed genders" if "mixed" == definition[:value2]
        end
      end
      
      return desc
    end
      
    "has an unknown rule"
  end
end
