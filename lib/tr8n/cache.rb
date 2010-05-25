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
  
  def self.fetch(key, options = {})
    return yield unless enabled?
    cache.fetch(key, options) do 
      yield
    end
  end

  def self.delete(key, options = nil)
    return unless enabled?
    cache.delete(key, options)
  end
  
end