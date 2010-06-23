module Tr8n::BaseHelper

  def tr8n_will_paginate(collection = nil, options = {})
    super(collection, options.merge(:skip_decorations => true))
  end

  def tr8n_page_entries_info(collection, options = {})
    super(collection, options.merge(:skip_decorations => true))
  end
  
end
