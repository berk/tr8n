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
    return self if frozen?
    @tr8n_translated = true
    self
  end

  def tr8n_translated?
    @tr8n_translated
  end

  # 
  # = Hash Recursive Merge
  # 
  # Merges a Ruby Hash recursively, Also known as deep merge.
  # Recursive version of Hash#merge and Hash#merge!.
  # 
  # Category::    Ruby
  # Package::     Hash
  # Author::      Simone Carletti <weppos@weppos.net>
  # Copyright::   2007-2008 The Authors
  # License::     MIT License
  # Link::        http://www.simonecarletti.com/
  # Source::      http://gist.github.com/gists/6391/
  
  #
  # Recursive version of Hash#merge!
  # 
  # Adds the contents of +other_hash+ to +hsh+, 
  # merging entries in +hsh+ with duplicate keys with those from +other_hash+.
  # 
  # Compared with Hash#merge!, this method supports nested hashes.
  # When both +hsh+ and +other_hash+ contains an entry with the same key,
  # it merges and returns the values from both arrays.
  # 
  #    h1 = {"a" => 100, "b" => 200, "c" => {"c1" => 12, "c2" => 14}}
  #    h2 = {"b" => 254, "c" => 300, "c" => {"c1" => 16, "c3" => 94}}
  #    h1.rmerge!(h2)   #=> {"a" => 100, "b" => 254, "c" => {"c1" => 16, "c2" => 14, "c3" => 94}}
  #    
  # Simply using Hash#merge! would return
  # 
  #    h1.merge!(h2)    #=> {"a" => 100, "b" = >254, "c" => {"c1" => 16, "c3" => 94}}
  # 
  def rmerge!(other_hash)
    merge!(other_hash) do |key, oldval, newval| 
        oldval.class == self.class ? oldval.rmerge!(newval) : newval
    end
  end

  #
  # Recursive version of Hash#merge
  # 
  # Compared with Hash#merge!, this method supports nested hashes.
  # When both +hsh+ and +other_hash+ contains an entry with the same key,
  # it merges and returns the values from both arrays.
  # 
  # Compared with Hash#merge, this method provides a different approch
  # for merging nasted hashes.
  # If the value of a given key is an Hash and both +other_hash+ abd +hsh
  # includes the same key, the value is merged instead replaced with
  # +other_hash+ value.
  # 
  #    h1 = {"a" => 100, "b" => 200, "c" => {"c1" => 12, "c2" => 14}}
  #    h2 = {"b" => 254, "c" => 300, "c" => {"c1" => 16, "c3" => 94}}
  #    h1.rmerge(h2)    #=> {"a" => 100, "b" => 254, "c" => {"c1" => 16, "c2" => 14, "c3" => 94}}
  #    
  # Simply using Hash#merge would return
  # 
  #    h1.merge(h2)     #=> {"a" => 100, "b" = >254, "c" => {"c1" => 16, "c3" => 94}}
  # 
  def rmerge(other_hash)
    r = {}
    merge(other_hash)  do |key, oldval, newval| 
      r[key] = oldval.class == self.class ? oldval.rmerge(newval) : newval
    end
  end

end
