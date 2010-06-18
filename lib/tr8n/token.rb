class Tr8n::Token
  
  def self.register_data_tokens(label)
    tokens = []
    Tr8n::Config.data_token_classes.each do |token_class|
      tokens << token_class.parse(label)
    end
    tokens.flatten
  end

  def self.register_decoration_tokens(label)
    tokens = []
    Tr8n::Config.decoration_token_classes.each do |token_class|
      tokens << token_class.parse(label)
    end
    tokens.flatten
  end
  
  def self.parse(label)
    raise Tr8n::TokenException.new("This method must be implemented in the extending class")
  end
  
  def initialize(token)
    @full_name = token 
  end

  def full_name
    @full_name
  end
  
  def declared_name
    @declared_name ||= full_name.gsub(/[{}\[\]]/, '')
  end
  
  def name
    @name ||= declared_name.split(':').first.strip
  end
  
  def suffix
    @suffix ||= name.split('_').last
  end

  # used for the UI substitution
  def sanitized_name
    "{#{name}}"
  end

  def name_key
    name.to_sym
  end

  def type
    return nil unless declared_name.index(':')
    @type ||= declared_name.split('|').first.split(':').last
  end
  
  def has_type?
    type != nil
  end
  
  def language_rule
    @language_rule ||= begin
      if has_type?
        rule = Tr8n::Config.language_rule_dependencies[type]
        unless rule
          raise Tr8n::TokenException.new("Unknown dependency type for #{full_name} token")
        end
        rule
      else
        Tr8n::Config.language_rule_suffixes[suffix]
      end
    end
  end

  def dependency
    return nil unless dependant?
    language_rule.dependency
  end

  def dependant?
    language_rule != nil
  end

  def sanitize_token_value(value, options = {})
    return value.to_s if (not options[:sanitize_values]) or value.html_safe?
    ERB::Util.html_escape(value.to_s)
  end

  def evaluate_token_method_array(object, method_array, options)
    # if single object in the array return string value of the object
    return sanitize_token_value(object) if method_array.size == 1
    
    method = method_array.second
    params = method_array[2..-1]
    params_with_object = [object] + params

    # if second param is symbol, invoke the method on the object with the remaining values
    if method.is_a?(Symbol)
      return sanitize_token_value(object.send(method, *params), options.merge(:sanitize_values => true))
    end

    # if second param is lambda, call lambda with the remaining values
    if method.is_a?(Proc)
      return sanitize_token_value(method.call(*params_with_object))
    end
    
    # if the second param is a string, substitute all of the numeric params,  
    # with the original object and all the following params
    if method.is_a?(String)
      parametrized_value = method.clone
      params_with_object.each_with_index do |val, i|
        parametrized_value.gsub!("{$#{i}}", sanitize_token_value(val, options))  
      end
      return parametrized_value
    end
    
    return "{invalid second token value}"
  end
  
  def token_array_value(token_value, options = {}) 
    objects = token_value.first
    
    # options are: second value is a lambda, second value is a string, second value is a symbol
    # third value is a hash of options - :pretty_list => true, :list_limit => 3  - "and 4 others" will be added
    # tr("{user_list} joined Geni", "", {:user_list => [[user1, user2, user3], :name]}, {:pretty_list => true, :list_limit => 3}}
    
    objects = objects.collect do |obj|
      evaluate_token_method_array(obj, token_value, options)
    end
 
    return objects.first if objects.size == 1
 
    separator = options[:separator] || ", "
    list_limit = options[:list_limit] || objects.size
    pretty_list = options[:pretty_list].nil? ? true : options[:pretty_list]
    smart_list = options[:smart_list].nil? ? false : options[:smart_list]
    smart_list = false if options[:skip_decorations]
    
    return objects.join(separator) unless pretty_list

    if objects.size <= list_limit
      return "#{objects[0..-2].join(separator)} #{"and".translate("List elements joiner", {}, options)} #{objects.last}"
    end

    display_ary = objects[0..(list_limit-1)]
    remaining_ary = objects[list_limit..-1]
    result = "#{display_ary.join(separator)}"
    
    unless smart_list
      result << " " << "and".translate("List elements joiner", {}, options) << " "
      result << "{num} {_others}".translate("List elements joiner", 
                {:num => remaining_ary.size, :_others => "other".pluralize_for(remaining_ary.size)}, options)
      return result
    end             
             
    uniq_id = Time.now.to_i.to_s         
    result << "<span id=\"tr8n_other_link_#{uniq_id}\">" << " " << "and".translate("List elements joiner", {}, options) << " "
    result << "<a href='#' onClick=\"$('tr8n_other_link_#{uniq_id}').hide(); $('tr8n_other_elements_#{uniq_id}').show(); return false;\">"
    result << "{num} {_others}".translate("List elements joiner", {:num => remaining_ary.size, :_others => "other".pluralize_for(remaining_ary.size)}, options)
    result << "</a></span>"
    result << "<span id=\"tr8n_other_elements_#{uniq_id}\" style='display:none'>" << separator
    result << "#{remaining_ary[0..-2].join(separator)} #{"and".translate("List elements joiner", {}, options)} #{remaining_ary.last}"
    result << "<a href='#' style='font-size:smaller;white-space:nowrap' onClick=\"$('tr8n_other_link_#{uniq_id}').show(); $('tr8n_other_elements_#{uniq_id}').hide(); return false;\"> "
    result << "&laquo; less".translate("List elements joiner", {}, options)    
    result << "</a></span>"
  end

  def token_value(object, options)
    # token is an array
    if object.is_a?(Array)
      # if you provided an array, it better have some values
      if object.empty?
        return raise Tr8n::TokenException.new("Invalid array value for a token: #{full_name}")
      end

      # if the first value of an array is an array handle it here
      if object.first.is_a?(Array)
        return token_array_value(object, options)
      end

      # if the first item in the array is an object, process it
      return evaluate_token_method_array(object.first, object, options)
    end

    # simple token
    sanitize_token_value(object)    
  end

  def allowed_in_translation?
    true
  end
  
  def substitute(label, values = {}, options = {}, language = Tr8n::Config.current_language)
    object = values[name_key]
    raise Tr8n::TokenException.new("Missing value for a token: #{full_name}") unless object
    
    label.gsub(full_name, token_value(object, options))
  end
  
  # for most tokens don't do anything, hidden tokens will take care of themselves
  def sanitize_label(label)
    label
  end
  
  def to_s
    full_name
  end
end