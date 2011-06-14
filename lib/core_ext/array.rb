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

class Array

  # translates an array of options for a select tag
  def tro(description = "", options = {}, language = Tr8n::Config.current_language)
    return [] if empty?

    collect do |opt|
      if opt.is_a?(Array) and opt.first.is_a?(String) 
        [opt.first.trl(description, {}, options, language), opt.last]
      elsif opt.is_a?(String)
        [opt.trl(description, {}, options, language), opt]
      else  
        opt
      end
    end
  end

  # creates a sentence with tr "and" joiner
  def tr_sentence(options = {}, language = Tr8n::Config.current_language)
    return "" if empty?
    return first if size == 1

    result = "#{self[0..-2].join(", ")}"
    result << " " << "and".translate("List elements joiner", {}, options, language) << " "
    result << self.last
  end

  def tr8n_translated
    return self if frozen?
    @tr8n_translated = true
    self
  end

  def tr8n_translated?
    @tr8n_translated
  end

end
