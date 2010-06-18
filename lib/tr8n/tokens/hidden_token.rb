####################################################################### 
# 
# Hidden Token Forms:
#
# {_he_she} 
# {_posted__items}
#
#  '_' escaped as '/'
#  '__' escaped as '__'
# 
# Hidden tokens cannot have rules and are there for default language
# substitutions only
#
####################################################################### 


class Tr8n::HiddenToken < Tr8n::Token
  
  def self.expression
    /(\{_[\w]+\})/
  end

  def allowed_in_translation?
    false
  end

  def language_rule
    nil
  end

  # return humanized form
  def prepare_label_for_translator(label)
    label.gsub(full_name, humanized_name)
  end

  # return humanized form
  def prepare_label_for_suggestion(label)
    label.gsub(full_name, humanized_name)
  end
  
  def humanized_name
    @humanized_name ||= begin
      hnm = name[1..-1].clone
      hnm.gsub!('__', ' ')
      hnm.gsub!('_', '/')
      hnm
    end
  end
  
end
