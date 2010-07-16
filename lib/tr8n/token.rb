#--
# Copyright (c) 2010 Michael Berkovich, Geni Inc
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#++

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

  def self.expression
    raise Tr8n::TokenException.new("This method must be implemented in the extending class")
  end
  
  def self.parse(label)
    tokens = []
    label.scan(expression).uniq.each do |token_array|
      tokens << self.new(label, token_array.first) 
    end
    tokens
  end
  
  def initialize(label, token)
    @label = label
    @full_name = token 
  end

  def original_label
    @label
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
    
    raise Tr8n::TokenException.new("Invalid array second token value: #{full_name} in #{original_label}")
  end

  
  ##########################################################################################
  #
  # tr("{user_list} joined Geni", "", {:user_list => [[user1, user2, user3], :name]}}
  #
  # first element is an array, the rest of the elements are similar to the regular tokens
  # lambda, symbol, string, with parameters that follow
  #
  # if you want to pass options, then make the second parameter an array as well    
  # tr("{user_list} joined Geni", "", 
  #       {:user_list => [[user1, user2, user3], 
  #                       [:name],          # this can be any of the value methods
  #                       {:expandable => true, 
  #                        :to_sentence => true, 
  #                        :limit => 3, 
  #                        :separator => ','
  #                       }
  #                      ]}}
  # 
  # acceptable params:  expandable, to_sentence, limit, separator
  #
  ##########################################################################################
  
  def token_array_value(token_value, options = {}) 
    objects = token_value.first
    
    objects = objects.collect do |obj|
      if token_value.second.is_a?(Array)
        evaluate_token_method_array(obj, [obj] + token_value.second, options)
      else
        evaluate_token_method_array(obj, token_value, options)
      end
    end
 
    # if there is only one element in the array, use it and get out
    return objects.first if objects.size == 1
    
    list_options = {
      :expandable => true,
      :to_sentence => true,
      :limit => 4,
      :separator => ", "
    }
    
    if token_value.second.is_a?(Array) and token_value.size == 3
      list_options.merge!(token_value.last) 
    end
 
    list_options[:expandable] = false if options[:skip_decorations]
    
    return objects.join(list_options[:separator]) unless list_options[:to_sentence]

    if objects.size <= list_options[:limit]
      return "#{objects[0..-2].join(list_options[:separator])} #{"and".translate("List elements joiner", {}, options)} #{objects.last}"
    end

    display_ary = objects[0..(list_options[:limit]-1)]
    remaining_ary = objects[list_options[:limit]..-1]
    result = "#{display_ary.join(list_options[:separator])}"
    
    unless list_options[:expandable]
      result << " " << "and".translate("List elements joiner", {}, options) << " "
      result << "{num} {_others}".translate("List elements joiner", 
                {:num => remaining_ary.size, :_others => "other".pluralize_for(remaining_ary.size)}, options)
      return result
    end             
             
    uniq_id = Tr8n::TranslationKey.generate_key(original_label, objects.join(","))         
    result << "<span id=\"tr8n_other_link_#{uniq_id}\">" << " " << "and".translate("List elements joiner", {}, options) << " "
    result << "<a href='#' onClick=\"$('tr8n_other_link_#{uniq_id}').hide(); $('tr8n_other_elements_#{uniq_id}').show(); return false;\">"
    result << "{num} {_others}".translate("List elements joiner", {:num => remaining_ary.size, :_others => "other".pluralize_for(remaining_ary.size)}, options)
    result << "</a></span>"
    result << "<span id=\"tr8n_other_elements_#{uniq_id}\" style='display:none'>" << list_options[:separator]
    result << "#{remaining_ary[0..-2].join(list_options[:separator])} #{"and".translate("List elements joiner", {}, options)} #{remaining_ary.last}"
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
      if object.first.kind_of?(Enumerable)
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
    unless values.key?(name_key)
      raise Tr8n::TokenException.new("Missing value for a token: #{full_name}")
    end
    
    object = values[name_key]
    
    if object.nil? and not Tr8n::Config.allow_nil_token_values?
      raise Tr8n::TokenException.new("Token value is nil for a token: #{full_name}")
    end
    
    object = object.to_s if object.nil?
    label.gsub(full_name, token_value(object, options))
  end
  
  # return sanitized form
  def prepare_label_for_translator(label)
    label.gsub(full_name, sanitized_name)
  end

  # return tokenless form
  def prepare_label_for_suggestion(label)
    label.gsub(full_name, "")
  end
  
  def to_s
    full_name
  end
end