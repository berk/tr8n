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

Rails.application.routes.draw do 
  [:awards, :chart, :dashboard, :forum, :glossary, :help, :language_cases,
   :language, :phrases, :translations, :translator, :home, :login].each do |ctrl|
    match "/tr8n/#{ctrl}(/:action)", :controller => "tr8n/#{ctrl}"
  end

  [:chart, :clientsdk, :forum, :glossary, :language, :translation, 
   :translation_key, :translator, :domain].each do |ctrl|
    match "/tr8n/admin/#{ctrl}(/:action)", :controller => "tr8n/admin/#{ctrl}"
  end
  
  [:language, :translation, :translator].each do |ctrl|
    match "/tr8n/api/v1/#{ctrl}(/:action)", :controller => "tr8n/api/v1/#{ctrl}"
  end

  namespace :tr8n do
    root :to => "home#index"
    namespace :admin do
      root :to => "language#index"
    end
  end

  root :to => "tr8n/home#index"
end
