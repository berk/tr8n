class Fixnum

  def translate(desc = "", tokens = {}, options = {}, language = Tr8n::Config.current_language)
    to_s.translate(desc, tokens, options, language)
  end
  alias tr translate
  
  def trl(desc = "", tokens = {}, options = {}, language = Tr8n::Config.current_language)
    to_s.trl(desc, tokens, options, language)
  end

end
