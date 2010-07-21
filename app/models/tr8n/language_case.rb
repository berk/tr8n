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

class Tr8n::LanguageCase < ActiveRecord::Base
  set_table_name :tr8n_language_cases

  belongs_to :language, :class_name => "Tr8n::Language"   
  belongs_to :translator, :class_name => "Tr8n::Translator"   
  
  def self.for_id(case_id)
    Tr8n::Cache.fetch("language_case_#{case_id}") do 
      find_by_id(case_id)
    end
  end
  
  def self.for(language)
    find(:all, :conditions => ["language_id = ?", language.id])
  end

  def save_with_log!(new_translator)
    if self.id
      if changed?
        self.translator = new_translator
        translator.updated_language_case!(self)
      end
    else  
      self.translator = new_translator
      translator.added_language_case!(self)
    end

    save  
  end
  
  def destroy_with_log!(new_translator)
    new_translator.deleted_language_case!(self)
    
    destroy
  end

  def after_save
    Tr8n::Cache.delete("language_case_#{id}")
  end

  def after_destroy
    Tr8n::Cache.delete("language_case_#{id}")
  end

end
