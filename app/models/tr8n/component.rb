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
#-- Tr8n::Component Schema Information
#
# Table name: tr8n_components
#
#  id                INTEGER         not null, primary key
#  application_id    integer         
#  key               varchar(255)    
#  state             varchar(255)    
#  name              varchar(255)    
#  description       varchar(255)    
#  created_at        datetime        not null
#  updated_at        datetime        not null
#
# Indexes
#
#  tr8n_comp_app_id    (application_id) 
#
#++

class Tr8n::Component < ActiveRecord::Base
  self.table_name = :tr8n_components
  attr_accessible :application_id, :key, :name, :description, :state
  
  belongs_to :application, :class_name => 'Tr8n::Application'

  has_many :component_sources, :class_name => 'Tr8n::ComponentSource', :dependent => :destroy
  has_many :translation_sources, :class_name => 'Tr8n::TranslationSource', :through => :component_sources
  has_many :translation_key_sources, :class_name => 'Tr8n::TranslationKeySource', :through => :translation_sources
  has_many :translation_keys, :class_name => 'Tr8n::TranslationKey', :through => :translation_key_sources

  has_many :component_languages, :class_name => 'Tr8n::ComponentLanguage', :dependent => :destroy
  has_many :languages, :class_name => 'Tr8n::Language', :through => :component_languages

  has_many :component_translators, :class_name => 'Tr8n::ComponentTranslator', :dependent => :destroy
  has_many :translators, :class_name => 'Tr8n::Translator', :through => :component_translators

  alias :sources :translation_sources

  after_destroy :clear_cache
  after_save :clear_cache

  def self.cache_key(key)
    "component_[#{key.to_s}]"
  end

  def cache_key
    self.class.cache_key(key)
  end

  def self.find_or_create(key, application = Tr8n::Config.current_application)
    return component if key.is_a?(Tr8n::Component)
    key = key.to_s

    Tr8n::Cache.fetch(cache_key(key)) do 
      where("application_id = ? and key = ?", application.id, key.to_s).first || create(:application => application, :key => key.to_s, :state => "restricted")
    end  
  end

  def register_source(source)
    Tr8n::ComponentSource.find_or_create(self, source)
  end

  def self.state_options
    ["live", "restricted"]
  end

  def live?
    state == "live"
  end

  def restricted?
    state == "restricted"
  end

  def translator_authorized?(translator = Tr8n::Config.current_translator)
    return true unless restricted?
    translators.include?(translator)
  end

  def title
    return key if name.blank?
    name
  end

  def name_and_key
    return key if name.blank?
    "#{name} (#{key})"
  end

  def clear_cache
    Tr8n::Cache.delete(cache_key)
  end

  def to_api_hash(opts = {})
    {
      :key => self.key,
      :name => self.name,
      :description => self.description,
      :state => self.state
    }
  end

end
