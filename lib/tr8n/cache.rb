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
      
      # pp "fetch #{key}"
      
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
  
    #################################################################
    # Cache Source Methods
    #################################################################
    
    # For local cache, the source+language = updated_at must always be present
    # These keys cannot expire, or refreshing of the resources will never take place
    def self.sources_timestamps
      @sources_timestamps ||= {}
    end
    
    def self.last_updated_at(translation_source_language)
      sources_timestamps[translation_source_language.id] ||= 365.days.ago
    end

    def self.invalidate_source(source_name, language = Tr8n::Config.current_language)
      return if disabled? or language.default? 
      
      # only memory store needs this kind of reloading
      # memcached and other stores will expire shared keys 
      return unless memory_store?
      
      # pp [:memory_times, sources_timestamps]
      
      translation_source = Tr8n::TranslationSource.find_or_create(source_name)

      # this is the only record that will never be cached and will always be loaded from the database
      translation_source_language = Tr8n::TranslationSourceLanguage.find_or_create(translation_source, language)

      if last_updated_at(translation_source_language) < translation_source_language.updated_at
        keys = Tr8n::TranslationKey.where(["id in (select translation_key_id from #{Tr8n::TranslationKeySource.table_name} where translation_source_id = ?) and updated_at > ?", 
                                          translation_source.id, last_updated_at(translation_source_language)])
                                          
        # pp "****************************** Found #{keys.count} outdated keys for this language"                                  
        keys.each do |key|
          key.clear_translations_cache_for_language(language)
        end
        
        sources_timestamps[translation_source_language.id] = translation_source_language.updated_at
      end
    end
    
  end
end