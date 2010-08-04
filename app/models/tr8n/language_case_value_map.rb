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

class Tr8n::LanguageCaseValueMap < ActiveRecord::Base
  set_table_name :tr8n_language_case_value_maps

  belongs_to :language, :class_name => "Tr8n::Language"   
  belongs_to :translator, :class_name => "Tr8n::Translator"   
  
  serialize :map
  
  def self.for(language, key)
    Tr8n::Cache.fetch("language_case_value_map_#{language.id}_#{key}") do 
      find_by_language_id_and_key(language.id, key)
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
  
  def value_for(case_key)
    return unless map
    return map[case_key] unless map[case_key].is_a?(Hash)
    map[case_key]['male']
  end

  def gender_value_for(case_key, gender)
    return unless map
    return map[case_key] unless map[case_key].is_a?(Hash)
    map[case_key][gender]
  end
  
  def save_with_log!(new_translator)
#    if self.id
#      if changed?
#        self.translator = new_translator
#        translator.updated_language_case!(self)
#      end
#    else  
#      self.translator = new_translator
#      translator.added_language_case!(self)
#    end

    save  
  end
  
  def destroy_with_log!(new_translator)
#    new_translator.deleted_language_case!(self)
    
    destroy
  end

  def after_save
    Tr8n::Cache.delete("language_case_value_map_#{language.id}_#{key}")
  end

  def after_destroy
    Tr8n::Cache.delete("language_case_value_map_#{language.id}_#{key}")
  end

end
