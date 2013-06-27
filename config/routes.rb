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

Tr8n::Engine.routes.draw do
  [:awards, :chart, :forum, :glossary, :help, :language_cases,
   :language, :phrases, :translations, :translator].each do |ctrl|
    match "#{ctrl}(/:action)", :controller => "#{ctrl}"
  end
  
  [:applications, :components, :sources, :chart, :clientsdk, :forum, :glossary, :language, :translation, 
   :translation_key, :translator, :domain, :metrics].each do |ctrl|
    match "admin/#{ctrl}(/:action)", :controller => "admin/#{ctrl}"
  end
  
  [:application, :source, :component, :language, :translation_key, :translation, :translator, :proxy, :oauth].each do |ctrl|
    match "api/#{ctrl}(/:action)", :controller => "api/#{ctrl}"
  end

  [:translator, :language_selector, :language_case_manager, :utils].each do |ctrl|
    match "tools/#{ctrl}(/:action)", :controller => "tools/#{ctrl}"
  end
  
  match "api/language/translate.js", :controller => "api/language", :action => "translate"

  namespace :tr8n do
    root :to => "translator#index"
    namespace :admin do
      root :to => "applications#index"
    end
  end
  
  root :to => "translator#index"
end
