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
#-- Tr8n::Application Schema Information
#
# Table name: tr8n_applications
#
#  id             INTEGER         not null, primary key
#  key            varchar(255)    
#  name           varchar(255)    
#  description    varchar(255)    
#  created_at     datetime        not null
#  updated_at     datetime        not null
#
# Indexes
#
#  tr8n_apps    (key) 
#
#++

class Tr8n::Application < ActiveRecord::Base
  self.table_name = :tr8n_applications
  attr_accessible :key, :name, :description

  has_many :components, :class_name => 'Tr8n::Component', :dependent => :destroy

  has_many :translation_domains, :class_name => 'Tr8n::TranslationDomain', :dependent => :destroy
  alias :domains :translation_domains

  has_many :translation_sources, :class_name => 'Tr8n::TranslationSource', :dependent => :destroy
  alias :sources :translation_sources

  has_many :application_languages, :class_name => 'Tr8n::ApplicationLanguage', :dependent => :destroy
  alias :languages :application_languages

  has_many :application_translators, :class_name => 'Tr8n::ApplicationTranslator', :dependent => :destroy
  alias :translators :application_translators

  before_create :generate_keys

  def self.options
    Tr8n::Application.find(:all, :order => "name asc").collect{|app| [app.name, app.id]}
  end

protected

  def generate_keys
    self.key = Tr8n::Config.guid if key.nil?
    self.secret = Tr8n::Config.guid if secret.nil?
  end

end
