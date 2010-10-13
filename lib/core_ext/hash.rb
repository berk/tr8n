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

class Hash

  # Return all combinations of a hash.
  #
  # Example:
  #   {
  #     :a => [1, 2]
  #     :b => [1, 2]
  #   }.combinations #=> [{:a=>1, :b=>1}, {:a=>1, :b=>2}, {:a=>2, :b=>1}, {:a=>2, :b=>2}]
  #
  def combinations
    return [{}] if empty?

    copy = dup
    values = copy.delete(key = keys.first)

    result = []
    copy.combinations.each do |tail|
      values.each do |value|
        result << tail.merge(key=>value)
      end
    end

    result
  end

  def tr8n_translated
    @tr8n_translated = true
    self
  end

  def tr8n_translated?
    @tr8n_translated
  end

end
