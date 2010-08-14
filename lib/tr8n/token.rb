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

  def pipeless_name
    @pipeless_name ||= declared_name.split('|').first
  end
  
  def case_key
    return nil unless declared_name.index('::')
    
    @case_key ||= begin
      cases = declared_name.scan(/((::[\w]+)+)/).flatten.uniq
      if cases.any?
        cases.last.gsub("::", "")
      else
        nil
      end
    end
  end
  
  def has_case_key?
    not case_key.blank?
  end
  
  def caseless_name
    @caseless_name ||= begin
      if has_case_key?
        pipeless_name.gsub("::#{case_key}", "")
      else  
        pipeless_name
      end
    end
  end
  
  def name_with_case
    return name unless has_case_key?
    "#{name}::#{case_key}"
  end

  # used by the translator submit dialog
  def name_for_case(case_key)
    "#{name}::#{case_key}"
  end
  
  # used by the translator submit dialog
  def sanitized_name_for_case(case_key)
    "{#{name_for_case(case_key)}}"
  end
  
  def type
    return nil unless caseless_name.index(':')
    @type ||= begin 
      parts = caseless_name.split(':')
      if parts.size == 1 # provided : without a type
        nil
      else
        parts.last
      end
    end
  end
  
  def has_type?
    not type.blank?
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

  def sanitize_token_value(object, value, options, language)
    value = "#{value.to_s}" unless value.is_a?(String)
    
    if options[:sanitize_values] and not value.html_safe?
      value = ERB::Util.html_escape(value)
    end
    
    if has_case_key?
      value = apply_case(object, value, options, language)
    end
    
    value
  end

  ##############################################################################
  #
  # gets the value based on various evaluation methods
  #
  # examples:
  #
  # tr("Hello {user}", "", {:user => [current_user, current_user.name]}}
  # tr("Hello {user}", "", {:user => [current_user, "{$0} {$1}", "param1"]}}
  # tr("Hello {user}", "", {:user => [current_user, :name]}}
  # tr("Hello {user}", "", {:user => [current_user, :method_name, "param1"]}}
  # tr("Hello {user}", "", {:user => [current_user, lambda{|user| user.name}]}}
  # tr("Hello {user}", "", {:user => [current_user, lambda{|user, param1| user.name}, "param1"]}}
  #
  ##############################################################################
  def evaluate_token_method_array(object, method_array, options, language)
    # if single object in the array return string value of the object
    if method_array.size == 1
      return sanitize_token_value(object, object.to_s, options, language)
    end  
    
    # second params identifies the method to be used with the object
    method = method_array.second
    params = method_array[2..-1]
    params_with_object = [object] + params

    # if the second param is a string, substitute all of the numeric params,  
    # with the original object and all the following params
    if method.is_a?(String)
      parametrized_value = method.clone
      if parametrized_value.index("{$")
        params_with_object.each_with_index do |val, i|
           parametrized_value.gsub!("{$#{i}}", sanitize_token_value(object, val, options.merge(:skip_decorations => true), language))  
        end
      end
      return sanitize_token_value(object, parametrized_value, options, language)
    end

    # if second param is symbol, invoke the method on the object with the remaining values
    if method.is_a?(Symbol)
      return sanitize_token_value(object, object.send(method, *params), options.merge(:sanitize_values => true), language)
    end

    # if second param is lambda, call lambda with the remaining values
    if method.is_a?(Proc)
      return sanitize_token_value(object, method.call(*params_with_object), options, language)
    end
    
    raise Tr8n::TokenException.new("Invalid array second token value: #{full_name} in #{original_label}")
  end
  
  ##############################################################################
  #
  # tr("Hello {user_list}!", "", {:user_list => [[user1, user2, user3], :name]}}
  #
  # first element is an array, the rest of the elements are similar to the 
  # regular tokens lambda, symbol, string, with parameters that follow
  #
  # if you want to pass options, then make the second parameter an array as well    
  # tr("{user_list} joined Geni", "", 
  #       {:user_list => [[user1, user2, user3], 
  #                         [:name],      # this can be any of the value methods
  #                         { :expandable => true, 
  #                           :to_sentence => true, 
  #                           :limit => 3, 
  #                           :separator => ',',
  #                           :translate_items => false,
  #                           :minimizable => true
  #                         }
  #                       ]
  #                      ]})
  # 
  # acceptable params:  expandable, 
  #                     to_sentence, 
  #                     limit, 
  #                     separator, 
  #                     translate_items,
  #                     minimizable
  #
  ##############################################################################
  def token_array_value(token_value, options, language) 
    objects = token_value.first
    
    objects = objects.collect do |obj|
      if token_value.second.is_a?(Array)
        evaluate_token_method_array(obj, [obj] + token_value.second, options, language)
      else
        evaluate_token_method_array(obj, token_value, options, language)
      end
    end

    list_options = {
      :translate_items => false,
      :expandable => true,
      :minimizable => true,
      :to_sentence => true,
      :limit => 4,
      :separator => ", "
    }
    
    if token_value.second.is_a?(Array) and token_value.size == 3
      list_options.merge!(token_value.last) 
    end

    objects = objects.collect{|obj| obj.translate("List element", {}, options)} if list_options[:translate_items]

    # if there is only one element in the array, use it and get out
    return objects.first if objects.size == 1
 
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
    result << "<a href='#' onClick=\"Tr8n.Effects.hide('tr8n_other_link_#{uniq_id}'); Tr8n.Effects.show('tr8n_other_elements_#{uniq_id}'); return false;\">"
    result << "{num|| other}".translate("List elements joiner", {:num => remaining_ary.size}, options)
    result << "</a></span>"
    result << "<span id=\"tr8n_other_elements_#{uniq_id}\" style='display:none'>" << list_options[:separator]
    result << "#{remaining_ary[0..-2].join(list_options[:separator])} #{"and".translate("List elements joiner", {}, options)} #{remaining_ary.last}"

    if list_options[:minimizable]
      result << "<a href='#' style='font-size:smaller;white-space:nowrap' onClick=\"Tr8n.Effects.show('tr8n_other_link_#{uniq_id}'); Tr8n.Effects.hide('tr8n_other_elements_#{uniq_id}'); return false;\"> "
      result << "&laquo; less".translate("List elements joiner", {}, options)    
      result << "</a>"
    end
    
    result << "</span>"
  end

  # evaluate all possible methods for the token value and return sanitized result
  def token_value(object, options, language)
    # token is an array
    if object.is_a?(Array)
      # if you provided an array, it better have some values
      if object.empty?
        return raise Tr8n::TokenException.new("Invalid array value for a token: #{full_name}")
      end

      # if the first value of an array is an array handle it here
      if object.first.kind_of?(Enumerable)
        return token_array_value(object, options, language)
      end

      # if the first item in the array is an object, process it
      return evaluate_token_method_array(object.first, object, options, language)
    end

    # simple token
    sanitize_token_value(object, object.to_s, options, language)    
  end

  def allowed_in_translation?
    true
  end

  def decorate_language_case(case_map_key, case_value, options = {})
    return case_value if options[:skip_decorations]
    return case_value if Tr8n::Config.current_user_is_guest?
    return case_value unless Tr8n::Config.current_user_is_translator?
    return case_value unless Tr8n::Config.current_translator.enable_inline_translations?
    
    "<span class='tr8n_language_case' case_key='#{case_map_key.gsub("'", "\'")}'>#{case_value}</span>"
  end


  ##############################################################################
  #
  # chooses the appropriate case for the token value. case is identified with ::
  #
  # examples:
  #
  # tr("Hello {user::nom}", "", :user => current_user)
  # tr("{actor} gave {target::dat} a present", "", :actor => user1, :target => user2)
  # tr("This is {user::pos} toy", "", :user => current_user) 
  #
  ##############################################################################
  def apply_case(object, value, options, language)
    return value unless Tr8n::Config.enable_language_cases?
    return value unless language.cases? and language.valid_case?(case_key)
    
    html_tag_expression = /<\/?[^>]*>/
    html_tokens = value.scan(html_tag_expression).uniq
    parts = value.gsub(html_tag_expression, "").split(" ").uniq
    
    # replace html tokens with temporary placeholders
    html_tokens.each_with_index do |html_token, index|
      value = value.gsub(html_token, "{$#{index}}")
    end
    
    parts.each do |p|
      lcvm = Tr8n::LanguageCaseValueMap.for(language, p)
      case_value = p
      
      if lcvm
        map_case_value = lcvm.value_for(object, case_key)
        case_value = map_case_value unless map_case_value.blank?
      end

      value = value.gsub(p, decorate_language_case(p, case_value, options))
    end
    
    # replace back the temporary placeholders with the html tokens  
    html_tokens.each_with_index do |html_token, index|
      value = value.gsub("{$#{index}}", html_token)
    end

    value
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
    
    value = token_value(object, options, language)
    label.gsub(full_name, value)
  end
  
  # return sanitized form
  def prepare_label_for_translator(label)
    label.gsub(full_name, sanitized_name)
  end

  # return tokenless form
  def prepare_label_for_suggestion(label, index)
    label.gsub(full_name, "(#{index})")
  end
  
  def to_s
    full_name
  end
end