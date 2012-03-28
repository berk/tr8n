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

class Tr8n::LanguageUser < ActiveRecord::Base
  set_table_name :tr8n_language_users
  
  belongs_to :user, :class_name => Tr8n::Config.user_class_name, :foreign_key => :user_id
  belongs_to :language, :class_name => "Tr8n::Language"
  belongs_to :translator, :class_name => "Tr8n::Translator"
  
  # this object can belong to both the user and the translator
  # users may choose to switch to a language without becoming translators
  # once user becomes a translator, this record will be associated with both for ease of use
  # when users get promoted, they are automatically get associated with a language and marked as translators
  
  def self.find_or_create(user, language)
    lu = where("user_id = ? and language_id = ?", user.id, language.id).first
    lu || create(:user_id => user.id, :language_id => language.id)
  end

  def self.check_default_language_for(user)
     find_or_create(user, Tr8n::Config.default_language)
  end

  def self.languages_for(user)
    return [] unless user.id
    check_default_language_for(user)
    where("user_id = ?", user.id).order("updated_at desc")
  end

  def self.create_or_touch(user, language)
    return unless user.id
    lu = Tr8n::LanguageUser.find_or_create(user, language)
    lu.update_attributes(:updated_at => Time.now)
    lu
  end
  
  def translator?
    translator != nil
  end
end
