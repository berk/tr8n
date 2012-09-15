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
#
#-- Tr8n::TranslationSource Schema Information
#
# Table name: tr8n_translation_sources
#
#  id                       INTEGER         not null, primary key
#  source                   varchar(255)    
#  translation_domain_id    integer         
#  created_at               datetime        
#  updated_at               datetime        
#
# Indexes
#
#  tr8n_sources_source    (source) 
#
#++

class Tr8n::TranslationSource < ActiveRecord::Base
  self.table_name = :tr8n_translation_sources

  attr_accessible :source, :translation_domain_id
  attr_accessible :translation_domain

  after_destroy   :clear_cache
  
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

  def self.find_or_create(url, translation_domain = nil)
    # we don't want parameters in the source
    source = url.split("://").last.split("?").first
    Tr8n::Cache.fetch(cache_key(source)) do 
      translation_domain ||= Tr8n::TranslationDomain.find_or_create(url)
      translation_source = where("source = ? and translation_domain_id = ?", source, translation_domain.id).first
      translation_source ||= create(:source => source, :translation_domain => translation_domain)
      translation_source.update_attributes(:translation_domain => translation_domain) unless translation_source.translation_domain
      translation_source
    end  
  end

  def clear_cache
    Tr8n::Cache.delete(cache_key)
  end

  def cache_key_for_language(language = Tr8n::Config.current_language)
    "valid_translations_for_source_#{self.id}_and_locale_#{language.locale}"
  end

  def cache(language = Tr8n::Config.current_language)
    @cache ||= {}
    @cache[language.locale] ||= begin
      Tr8n::Cache.fetch(cache_key_for_language(language)) do 
        hash = {}
        translation_keys.each do |tkey|
          hash[tkey.key] = {
            "translation_key" => tkey,
            "translations" => tkey.valid_translations_for_language(language)
          }
        end
        hash
      end
    end
  end

  def translation_key_for_key(key)
    (cache[key] || {})["translation_key"]
  end

  def valid_translations_for_key_and_language(key, language = Tr8n::Config.current_language)
    (cache[key] || {})["translations"]
  end

  def clear_cache_for_language(language = Tr8n::Config.current_language)
    Tr8n::Cache.delete(cache_key_for_language(language))
  end

end
