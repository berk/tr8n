#--
# Copyright (c) 2010-2011 Michael Berkovich
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

class Tr8n::LanguageCaseValueMap < ActiveRecord::Base
  set_table_name :tr8n_language_case_value_maps
  after_save :clear_cache
  after_destroy :clear_cache
  
  belongs_to :language, :class_name => "Tr8n::Language"   
  belongs_to :translator, :class_name => "Tr8n::Translator"   
  
  serialize :map
  
  def self.by_language_and_keyword(language, keyword)
    Tr8n::Cache.fetch("language_case_value_map_#{language.id}_#{keyword}") do 
      find_by_language_id_and_keyword_and_reported(language.id, keyword, false)
    end
  end
  
  # add a better way to determine the gender dependency
  def gender_based?
    return false unless map
    map.each do |key, value|
      return true if value.is_a?(Hash) 
    end
    false
  end
  
  def value_for(object, case_key)
    return unless map
    
    # male female definition
    if map[case_key].is_a?(Hash)
      object_gender = Tr8n::GenderRule.gender_token_value(object)
      if object_gender == Tr8n::GenderRule.gender_object_value_for("female")
        return map[case_key]['female']
      end
      return map[case_key]['male']
    end
    
    map[case_key] 
  end

  def implied_value_for(case_key)
    return unless map
    return gender_value_for(case_key, "male") if map[case_key].is_a?(Hash)   
    map[case_key]
  end
  
  def gender_value_for(case_key, gender)
    return unless map
    return map[case_key] unless map[case_key].is_a?(Hash)
    map[case_key][gender]
  end
  
  def save_with_log!(new_translator)
#    new_translator.updated_language_case_values!(self)

    self.translator = new_translator
    save  
  end
  
  def destroy_with_log!(new_translator)
#    new_translator.deleted_language_case_values!(self)
    
    destroy
  end

  def report_with_log!(new_translator)
    # new_translator.reported_language_case_values!(self)

    update_attributes(:reported => true)
    self.translator.update_attributes(:reported => true) 
  end

  def clear_cache
    Tr8n::Cache.delete("language_case_value_map_#{language.id}_#{keyword}")
  end

end
