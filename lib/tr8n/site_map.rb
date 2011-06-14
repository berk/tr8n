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

class Tr8n::SiteMap

  def self.roots
    @roots ||= begin
      roots = [] 
      Tr8n::Config.sitemap_sections.each do |root_section|
        root_node = Tr8n::SiteMapSection.new(root_section)
        generate_sitemap_sections(root_section[:sections], root_node)
        roots << root_node
      end
      roots
    end
  end

  def self.section_for_source(source)
    sections = []
    roots.each do |root|
      find_sections_by_source(root, source, sections)
    end  
    sections.empty? ? nil : sections.first
  end

  def self.section_for_key(key)
    sections = []
    roots.each do |root|
      find_sections_by_key(root, key, sections)
    end
    sections.empty? ? nil : sections.first
  end

  def self.to_s
    roots.each do |root| 
      pp root.to_hash
    end
  end
  
private
  
  def self.generate_sitemap_sections(sub_sections, parent)
    return if sub_sections.blank? or sub_sections.empty?
    sub_sections.each do |sub_section|
      node = Tr8n::SiteMapSection.new(sub_section, parent)
      generate_sitemap_sections(sub_section[:sections], node)
    end
  end    

  def self.find_sections_by_source(node, source, sections)
    sections << node if node.source == source
    node.children.each do |child|
      find_sections_by_source(child, source, sections)
    end
    nil
  end
  
  def self.find_sections_by_key(node, key, sections)
    sections << node if node.key == key
    node.children.each do |child|
      find_sections_by_key(child, key, sections)
    end
  end
  
end