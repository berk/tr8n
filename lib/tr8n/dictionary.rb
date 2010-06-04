require 'rexml/document'

class Tr8n::Dictionary
  
  def self.load_definitions_for(words)
    words = [words] unless words.is_a?(Array)
    
    definitions = {}
    
    words.each do |word|
      Net::HTTP.start("services.aonaware.com") do |http|
        response = http.get("/DictService/DictService.asmx/Define?word=#{word}")

        doc = REXML::Document.new(response.body)
        doc.elements.each('WordDefinition/Definitions/Definition') do |d|
          word = d.elements["Word"].text.downcase
          source = d.elements["Dictionary"].elements["Name"].text
          definition = d.elements["WordDefinition"].text
          
          definitions[word] ||= []
          definitions[word] << {:source => source, :definition => definition}
        end
      end    
    end

    definitions
  end

end
