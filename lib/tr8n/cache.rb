class Tr8n::Cache
  def self.cache
    @cache ||= begin
      if Tr8n::Config.cache_adapter == 'ActiveSupport::Cache'
        store_params = [Tr8n::Config.config[:cache_store]].flatten
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