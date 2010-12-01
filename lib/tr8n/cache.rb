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

class Tr8n::Cache
  def self.cache
    @cache ||= begin
      if Tr8n::Config.cache_adapter == 'ActiveSupport::Cache'
        store_params = [Tr8n::Config.cache_store].flatten
        store_params[0] = store_params[0].to_sym
        ActiveSupport::Cache.lookup_store(*store_params)
      else
        eval(Tr8n::Config.cache_adapter)  
      end
    end
  end
  
  def self.enabled?
    Tr8n::Config.enable_caching?
  end
  
  def self.versioned_key(key)
    "#{Tr8n::Config.cache_version}_#{key}"
  end
  
  def self.fetch(key, options = {})
    return yield unless enabled?
    cache.fetch(versioned_key(key), options) do 
      yield
    end
  end

  def self.delete(key, options = nil)
    return unless enabled?
    cache.delete(versioned_key(key), options)
  end
  
end