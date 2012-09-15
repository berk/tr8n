#--
# Copyright (c) 2010-2012 Michael Berkovich, tr8n.net
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
  class Cache
    
    def self.cache_store_params
      [Tr8n::Config.cache_store].flatten
    end
    
    def self.cache
      return nil unless enabled?
      
      @cache ||= begin
        if Tr8n::Config.cache_adapter == 'ActiveSupport::Cache'
          store_params = cache_store_params
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

    def self.disabled?
      not enabled?
    end
    
    def self.version
      Tr8n::Config.cache_version
    end
    
    def self.versioned_key(key)
      "#{version}_#{key}"
    end

    def self.memory_store?
      cache_store_params.first == 'memory_store'
    end
    
    #################################################################
    # Cache Adapter Methods
    #################################################################
    def self.fetch(key, opts = {})
      return yield unless enabled?
      
      cache.fetch(versioned_key(key), opts) do 
        yield
      end
    end

    def self.delete(key, opts = nil)
      return unless enabled?

      # pp "delete #{key}"

      cache.delete(versioned_key(key), opts)
    end
    
    def self.exist?(name, opts = nil)
      return unless enabled?
      cache.exists?(name, opts)
    end

    def self.clear(opts = nil)
      return unless enabled?
      cache.clear(opts)
    end

    def self.cleanup(opts = nil)
      return unless enabled?
      cache.cleanup(opts)
    end

    def self.increment(name, amount = 1, opts = nil)
      return unless enabled?
      cache.increment(name, amount, opts)
    end

    def self.decrement(name, amount = 1, opts = nil)
      return unless enabled?
      cache.decrement(name, amount, opts)
    end

  end
end