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

class String

  def translate(desc = "", tokens = {}, options = {}, language = Tr8n::Config.current_language)
    language.translate(self, desc, tokens, options)
  end

  def pluralize_for(count, plural = nil)
    return self if count==1
    plural || pluralize
  end

  def trl(desc = "", tokens = {}, options = {}, language = Tr8n::Config.current_language)
    translate(desc, tokens, options.merge!(:skip_decorations => true), language)
  end

  def tr8n_translated
    return self if frozen?
    @tr8n_translated = true
    self.html_safe
  end

  def tr8n_translated?
    @tr8n_translated
  end
  
end
