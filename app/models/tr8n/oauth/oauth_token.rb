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

class Tr8n::Oauth::OauthToken < ActiveRecord::Base
  self.table_name = :tr8n_oauth_tokens
  attr_accessible :token, :application_id, :translator_id, :scope, :expires_at, :application, :translator

  belongs_to :application, :class_name => 'Tr8n::Application'
  belongs_to :translator, :class_name => 'Tr8n::Translator'

  before_create :generate_token

  def valid_token?(requested_scope = nil)
    return false if Time.now > self.expires_at
    return false if requested_scope and requested_scope != self.scope
    true
  end

  def self.for(token)
    where("token = ?", token).first
  end

  def self.find_or_create(translator, application = nil)
    if application
      where("application_id = ? and translator_id = ?", application.id, translator.id).first || create(:application => application, :translator => translator)
    else
      where("translator_id = ?", translator.id).first || create(:translator => translator)
    end
  end

  def expire_in(interval)
    return if interval.nil?
    self.expires_at = (Time.now + interval)
  end

  def expire_in!(interval)
    expire_in(interval)
    save!
  end

  def generate_token
    self.token = Tr8n::Config.guid if token.nil?
  end

end
