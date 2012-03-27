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

class Tr8n::TranslationSource < ActiveRecord::Base
  set_table_name :tr8n_translation_sources
  
  belongs_to  :translation_domain,            :class_name => "Tr8n::TranslationDomain"
  
  has_many    :translation_key_sources,       :class_name => "Tr8n::TranslationKeySource",  :dependent => :destroy
  has_many    :translation_keys,              :class_name => "Tr8n::TranslationKey",        :through => :translation_key_sources
  has_many    :translation_source_languages,  :class_name => "Tr8n::TranslationSourceLanguage"
  
  alias :domain   :translation_domain
  alias :sources  :translation_key_sources
  alias :keys     :translation_keys
  
  def self.cache_key(source)
    "translation_source_#{source}"
  end

  def cache_key
    self.class.cache_key(source)
  end

  def self.find_or_create(source, url = nil)
    Tr8n::Cache.fetch(cache_key(source)) do 
      translation_domain = Tr8n::TranslationDomain.find_or_create(url)
      translation_source = find(:first, :conditions => ["source = ? and translation_domain_id = ?", source, translation_domain.id])
      translation_source ||= create(:source => source, :translation_domain => translation_domain)
      translation_source.update_attributes(:translation_domain => translation_domain) unless translation_source.translation_domain
      translation_source
    end  
  end

  def after_destroy
    Tr8n::Cache.delete(cache_key)
  end
  
  def after_save
    Tr8n::Cache.delete(cache_key)
  end

end
