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

class Tr8n::TranslationKeyLock < ActiveRecord::Base
  set_table_name :tr8n_translation_key_locks

  belongs_to :translation_key,  :class_name => "Tr8n::TranslationKey"
  belongs_to :language,         :class_name => "Tr8n::Language"
  belongs_to :translator,       :class_name => "Tr8n::Translator"

  alias :key :translation_key
  
  def self.find_or_create(translation_key, language)
    lock = find(:first, :conditions => ["translation_key_id = ? and language_id = ?", translation_key.id, language.id])
    lock || create(:translation_key => translation_key, :language => language)
  end

  def self.for(translation_key, language)
    Tr8n::Cache.fetch("translation_key_lock_#{language.locale}_#{translation_key.key}") do 
      find_or_create(translation_key, language)
    end
  end

  def lock!(translator = Tr8n::Config.current_translator)
    update_attributes(:locked => true, :translator => translator)
    translator.locked_translation_key!(translation_key, language)
    key.update_metrics!(language)
  end

  def unlock!(translator = Tr8n::Config.current_translator)
    update_attributes(:locked => false, :translator => translator)
    translator.unlocked_translation_key!(translation_key, language)
    key.update_metrics!(language)
  end
  
  def after_save
    Tr8n::Cache.delete("translation_key_lock_#{language.locale}_#{translation_key.key}")
  end
end
