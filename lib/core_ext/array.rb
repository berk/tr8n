class Array

  # translates an array of options for a select tag
  def tro(description = "")
    return [] if empty?

    collect do |opt|
      if opt.is_a?(Array) and opt.first.is_a?(String) 
        [opt.first.trl(description), opt.last]
      elsif opt.is_a?(String)
        [opt.trl(description), opt]
      else  
        opt
      end
    end
  end

end
