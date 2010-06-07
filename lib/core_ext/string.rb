class String

  def translate(desc = "", tokens = {}, options = {}, language = Tr8n::Config.current_language)
    language.translate(self, desc, tokens, options)
  end

  def pluralize_for(count, plural = nil)
    return self if count==1
    plural || pluralize
  end

  def trl(desc = "", tokens = {}, options = {}, language = Tr8n::Config.current_language)
    translate(desc, tokens, options.merge!(:skip_decorations => true), language)
  end

end
