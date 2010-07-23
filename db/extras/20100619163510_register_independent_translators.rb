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
# if your site does not have users, but you would still like to use tr8n
# or if you want to register independent, not linked translators

class RegisterIndependentTranslators < ActiveRecord::Migration
  def self.up
    add_column :tr8n_translators, :name, :string
    add_column :tr8n_translators, :email, :string
    add_column :tr8n_translators, :password, :string
    add_column :tr8n_translators, :admin, :boolean
    add_column :tr8n_translators, :mugshot, :string
    add_column :tr8n_translators, :link, :string
    add_column :tr8n_translators, :locale, :string
    
    add_index :tr8n_translators, [:email]
    add_index :tr8n_translators, [:email, :password]
  end

  def self.down
    remove_column :tr8n_translators, :name
    remove_column :tr8n_translators, :email
    remove_column :tr8n_translators, :password
    remove_column :tr8n_translators, :admin
    remove_column :tr8n_translators, :mugshot
    remove_column :tr8n_translators, :link
    remove_column :tr8n_translators, :locale
  end
end

