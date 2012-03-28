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

class Tr8n::GenderListRule < Tr8n::LanguageRule
  
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
    Tr8n::Config.rules_engine[:gender_list_rule][:token_suffixes]
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
    return nil unless token and token.respond_to?(Tr8n::Config.rules_engine[:gender_list_rule][:object_method])
    token.send(Tr8n::Config.rules_engine[:gender_list_rule][:object_method])
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
  
  # params: [object, one element male, one element female, at least two elements]
  # or: [object, one element, at least two elements]

  # {user_list | one element male, one element female, at least two elements}
  # {user_list | one element, at least two elements}
  def self.transform(*args)
    unless [3, 4].include?(args.size)
      raise Tr8n::Exception.new("Invalid transform arguments")
    end
    
    object = args[0]
    list_size = list_size_token_value(object)

    unless list_size
      raise Tr8n::Exception.new("Token #{object.class.name} does not respond to #{Tr8n::Config.rules_engine[:gender_list_rule][:object_method]}")
    end
    
    list_size = list_size.to_i
    
    if args.size == 3
      return args[1] if list_size == 1
      return args[2]
    end
    
    if list_size == 1
      list_object = object.first
      list_object_gender = Tr8n::GenderRule.gender_token_value(list_object)
      if list_object_gender == Tr8n::GenderRule.gender_object_value_for("male")
        return args[1]
      elsif list_object_gender == Tr8n::GenderRule.gender_object_value_for("female")
        return args[2]
      end
    end
    
    args[3]
  end  
  
  # params: [one element, at least two elements]
  def self.default_transform(*args)
    unless [2, 3].include?(args.size)
      raise Tr8n::Exception.new("Invalid transform arguments for list token")
    end
    
    args.last
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
