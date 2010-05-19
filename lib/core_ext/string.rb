class String

  def translate(language = Tr8n::Config.current_language, desc = "", tokens = {}, options = {})
#    options.merge!(:skip_decorations => true) if options[:skip_decorations].blank?
    language.translate(self, desc, tokens, options)
  end

  def pluralize_for(count, plural = nil)
    return self if count==1
    plural || pluralize
  end

end
