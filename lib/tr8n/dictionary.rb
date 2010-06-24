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
