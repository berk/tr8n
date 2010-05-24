class Tr8n::Cache
  
  def self.cache
    @cache ||= begin
      store_params = [Tr8n::Config.cache_store].flatten
      store_params[0] = store_params[0].to_sym
      ActiveSupport::Cache.lookup_store(*store_params)
    end
  end
  
  def self.enabled?
    Tr8n::Config.enable_caching?
  end
  
  def self.fetch(key, options = {})
#    pp "fetching #{key}"
    return yield unless enabled?
    cache.fetch(key, options) do 
      yield
    end
  end

  def self.delete(key, options = nil)
#    pp "deleting #{key}"
    return unless enabled?
    cache.delete(key, options)
  end
  
end