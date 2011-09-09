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

class Tr8n::TranslationKeySource < ActiveRecord::Base
  set_table_name :tr8n_translation_key_sources
  after_save      :clear_cache
  after_destroy   :clear_cache

  belongs_to :translation_source, :class_name => "Tr8n::TranslationSource"
  belongs_to :translation_key,    :class_name => "Tr8n::TranslationKey"

  alias :source :translation_source
  alias :key :translation_key

  serialize :details

  def self.for(translation_key, translation_source)
    return nil if translation_key.blank?
    return nil if translation_source.blank?

    Tr8n::Cache.fetch("tks_for_key_#{translation_key.id}_source_#{translation_source.id}") do
      find_or_create translation_key, translation_source
    end
  end

  def self.find_or_create(translation_key, translation_source)
      tks = find(:first, :conditions => ["translation_key_id = ? and translation_source_id = ?", translation_key.id, translation_source.id])
      tks || create(:translation_key => translation_key, :translation_source => translation_source)
    end  
  
  def update_details!(options)
    return unless options[:caller_key]
    
    self.details ||= {}
    return if details[options[:caller_key]]
    
    details[options[:caller_key]] = options[:caller]
    save
  end
  
  def clear_cache
    Tr8n::Cache.delete("tks_for_key_#{translation_key_id}_source_#{translation_source_id}")
    Tr8n::Cache.delete("cached_translation_keys_for_source_#{translation_source_id}")
  end
  
end
