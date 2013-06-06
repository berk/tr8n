2#--
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
  has_many :languages, :class_name => 'Tr8n::Language', :through => :application_languages

  has_many :application_translators, :class_name => 'Tr8n::ApplicationTranslator', :dependent => :destroy
  has_many :translators, :class_name => 'Tr8n::Translator', :through => :application_translators

  before_create :generate_keys

  after_destroy :clear_cache
  after_save :clear_cache

  def self.cache_key(key)
    "application_[#{key.to_s}]"
  end

  def cache_key
    self.class.cache_key(key)
  end

  def self.for(key)
    Tr8n::Cache.fetch(cache_key(key)) do 
      where("key = ?", key.to_s).first
    end  
  end

  def self.options
    Tr8n::Application.find(:all, :order => "name asc").collect{|app| [app.name, app.id]}
  end

  def clear_cache
    Tr8n::Cache.delete(cache_key)
  end

  def add_translator(translator)
    Tr8n::ApplicationTranslator.find_or_create(self, translator)
  end

  def add_language(language)
    Tr8n::ApplicationLanguage.find_or_create(self, language)
  end

  def to_api_hash(opts = {})
    {
      :key => self.key,
      :name => self.name,
      :description => self.description,
    }
  end

  def create_oauth_token(klass, translator, scope, expire_in) 
    token = klass.new
    token.application = self
    token.translator = translator
    token.scope = scope
    token.generate_token
    token.expire_in(expire_in)
    token.save!
    token    
  end

  def create_request_token(translator, scope = 'basic', expire_in = 3.months)
    create_oauth_token(Tr8n::Oauth::RequestToken, translator, scope, expire_in) 
  end

  def create_refresh_token(translator, scope = 'basic', expire_in = 5.months)
    create_oauth_token(Tr8n::Oauth::RefreshToken, translator, scope, expire_in) 
  end

  def create_client_token(scope = 'basic', expire_in = 3.months)
    create_oauth_token(Tr8n::Oauth::ClientToken, nil, scope, expire_in) 
  end

  def create_access_token(translator, scope = 'basic', expire_in = 3.months)
    create_oauth_token(Tr8n::Oauth::AccessToken, translator, scope, expire_in) 
  end

  def find_valid_token_for_scope(tokens, scope)
    valid_token = nil
    tokens.each do |token|
      if token.valid_token?(scope) and valid_token.nil?
        valid_token = token
      else
        token.destroy
      end
    end
    valid_token
  end

  def find_or_create_request_token(translator, scope = 'basic', expire_in = 3.months)
    tokens = Tr8n::Oauth::RequestToken.where("application_id = ? and translator_id = ?", self.id, translator.id).all
    valid_token = find_valid_token_for_scope(tokens, scope)
    valid_token ||= create_request_token(translator, scope, expire_in)

    valid_token    
  end

  def find_or_create_access_token(translator, scope = 'basic', expire_in = 3.months)
    tokens = Tr8n::Oauth::AccessToken.where("application_id = ? and translator_id = ?", self.id, translator.id).all
    valid_token = find_valid_token_for_scope(tokens, scope)
    valid_token ||= create_access_token(translator, scope, expire_in)
    Tr8n::ApplicationTranslator.touch(self, user)

    valid_token
  end  

protected

  def generate_keys
    self.key = Tr8n::Config.guid if key.nil?
    self.secret = Tr8n::Config.guid if secret.nil?
  end

end
