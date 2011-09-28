#--
# Copyright (c) 2010-2011 Michael Berkovich
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

class Tr8n::LanguageCase < ActiveRecord::Base
  set_table_name :tr8n_language_cases
  after_save :clear_cache
  after_destroy :clear_cache

  belongs_to :language, :class_name => "Tr8n::Language"   
  belongs_to :translator, :class_name => "Tr8n::Translator"   
  has_many   :language_case_rules, :class_name => "Tr8n::LanguageCaseRule", :order => 'position asc', :dependent => :destroy
  
  serialize :definition
  
  def self.by_id(case_id)
    Tr8n::Cache.fetch("language_case_#{case_id}") do 
      find_by_id(case_id)
    end
  end
  
  def self.by_language(language)
    find(:all, :conditions => ["language_id = ?", language.id])
  end

  def rules
    return language_case_rules if id.blank?
    
    Tr8n::Cache.fetch("language_case_rules_#{id}") do 
      language_case_rules
    end
  end

  def save_with_log!(new_translator)
    if self.id
      if changed?
        self.translator = new_translator
        translator.updated_language_case!(self)
      end
    else  
      self.translator = new_translator
      translator.added_language_case!(self)
    end

    save  
  end
  
  def destroy_with_log!(new_translator)
    new_translator.deleted_language_case!(self)
    
    destroy
  end

  def apply(object, value, options)
    html_tag_expression = /<\/?[^>]*>/
    html_tokens = value.scan(html_tag_expression).uniq
    sanitized_value = value.gsub(html_tag_expression, "")
    
    if application == 'phrase'
      words = [sanitized_value]
    else  
      words = sanitized_value.split(" ").uniq
    end
    
    # replace html tokens with temporary placeholders
    html_tokens.each_with_index do |html_token, index|
      value = value.gsub(html_token, "{$#{index}}")
    end
    
#    pp words
    words.each do |word|
      lcvm = Tr8n::LanguageCaseValueMap.by_language_and_keyword(language, word)
      
      if lcvm
        # first see if there is an exception for the value
        map_case_value = lcvm.value_for(object, keyword)
        case_value = map_case_value unless map_case_value.blank?
      else
        # try evaluating the rules
        case_rule = evaluate_rules(object, word)
#        pp case_rule, word
        case_value = case_rule.apply(word) if case_rule  
      end

      if options[:skip_decorations]
      if options[:skip_decorations] == true # skip decorations has to be explicetally set to true
        value = value.gsub(word, case_value || word)
      else
        value = value.gsub(word, decorate_language_case(word, case_value || word, case_rule))
      end
    end
    
    # replace back the temporary placeholders with the html tokens  
    html_tokens.each_with_index do |html_token, index|
      value = value.gsub("{$#{index}}", html_token)
    end
     
    value
  end

  def evaluate_rules(object, value)
    rules.each do |rule|
      return rule if rule.evaluate(object, value)
    end
    nil
  end

  def decorate_language_case(case_map_key, case_value, case_rule)
    "<span class='tr8n_language_case' case_id='#{id}' rule_id='#{case_rule ? case_rule.id : ''}' case_key='#{case_map_key.gsub("'", "\'")}'>#{case_value}</span>"
  end

  def self.application_options
    [["every word", "words"], ["entire phrase", "phrase"]]
  end

  def clear_cache
    Tr8n::Cache.delete("language_case_#{id}")
    Tr8n::Cache.delete("language_case_rules_#{id}") 
  end

end
