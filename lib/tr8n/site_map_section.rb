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

module Tr8n
  class SiteMapSection
    attr_accessor :key, :parent, :data
  
    def initialize(section_data = {}, parent_section = nil)
      @data = section_data
      @parent = parent_section
      @key = Tr8n::TranslationKey.generate_key(data[:label], data[:description])
      @parent.children << self if @parent
    end
  
    def enabled?
      return true if data[:enabled] == nil
      data[:enabled]
    end
  
    def children
      @children ||= []
    end
  
    def sources
      data[:sources]  
    end
  
    def source
      return "" if sources.blank? or sources.empty?
      sources.first
    end
  
    def label
      data[:label] || ''
    end
  
    def description
      data[:description] || ''
    end
  
    def link(params)
      return data[:link] if data[:link]
      return "/" unless source
      lnk = "/#{source}" unless source.first == '/'
      return "#{lnk}?#{object[:param]}=#{params[object[:param]]}" if object 
      lnk
    end
  
    def object
      data[:object]    
    end  
  
    def title(params = {})
      if object
        cls = object[:class].constantize.find(params[object[:param]])
        return ERB::Util.html_escape(cls.send(object[:method]))
      end
      # has to be smart about the objects
      label.translate(description)
    end
  
    def to_s
      label
    end
  
    def parents
      @parents ||= begin
        path = [self]
        node = self.parent
        while node
          path << node
          node = node.parent
        end
        path.reverse
      end
    end
  
    def to_hash(deep=true)
      hash = { 
         :label => label, 
         :description => description,
         :sources => sources
     }
     hash[:sources] = sources if sources
     hash[:sections] = children.collect{|child| child.to_hash} if deep
     hash
    end
  
  end
end