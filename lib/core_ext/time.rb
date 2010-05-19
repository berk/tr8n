class Time

  def localize(language = Tr8n::Config.current_language, format = :default, options = {})
#    options.merge!(:skip_decorations => true) if options[:skip_decorations].blank?
    language.localize_date(self, format, options)
  end

end
