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