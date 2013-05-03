#--
# Copyright (c) 2010-2013 Michael Berkovich, tr8nhub.com
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
#
#-- Tr8n::LanguageCase Schema Information
#
# Table name: tr8n_language_cases
#
#  id               INTEGER         not null, primary key
#  language_id      integer         not null
#  translator_id    integer         
#  keyword          varchar(255)    
#  latin_name       varchar(255)    
#  native_name      varchar(255)    
#  description      text            
#  application      varchar(255)    
#  created_at       datetime        not null
#  updated_at       datetime        not null
#
# Indexes
#
#  tr8n_lc_lk    (language_id, keyword) 
#  tr8n_lc_lt    (language_id, translator_id) 
#  tr8n_lc_l     (language_id) 
#
#++

class Tr8n::LanguageCase < ActiveRecord::Base
  self.table_name = :tr8n_language_cases
  attr_accessible :language_id, :translator_id, :keyword, :latin_name, :native_name, :description, :application
  attr_accessible :language, :translator

  after_save :clear_cache
  after_destroy :clear_cache

  belongs_to :language, :class_name => "Tr8n::Language"   
  belongs_to :translator, :class_name => "Tr8n::Translator"   
  has_many   :language_case_rules, :class_name => "Tr8n::LanguageCaseRule", :order => 'position asc', :dependent => :destroy
  
  serialize :definition
  
  def self.cache_key(locale, keyword)
    "language_case_[#{locale}]_[#{keyword}]"
  end

  def cache_key
    self.class.cache_key(language.locale, keyword)
  end

  def self.by_keyword(keyword, language = Tr8n::Config.current_language)
    Tr8n::Cache.fetch(cache_key(language.locale, keyword)) do 
      where(:language_id => language.id, :keyword => keyword).first
    end
  end

  def self.language_case_cache_key(id)
    "language_case_[#{id}]"
  end

  def language_case_cache_key
    self.class.language_case_cache_key(id)
  end

  def self.language_case_rules_cache_key(id)
    "language_case_rules_[#{id}]"
  end

  def language_case_rules_cache_key
    self.class.language_case_rules_cache_key(id)
  end

  def self.by_id(case_id)
    Tr8n::Cache.fetch(language_case_cache_key(case_id)) do 
      find_by_id(case_id)
    end
  end

  def self.by_language(language)
    where("language_id = ?", language.id).all
  end

  def add_rule(definition, opts = {})
    opts[:position] ||= language_case_rules.count
    opts[:translator] ||= Tr8n::Config.current_translator
    Tr8n::LanguageCaseRule.create(:language_case => self,           :language => language, 
                                  :translator => opts[:translator], :position => opts[:position], 
                                  :definition => definition)
  end

  def rules
    return language_case_rules if id.blank?
    
    Tr8n::Cache.fetch(language_case_rules_cache_key) do 
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

  def apply(object, value, options = {})
    value = value.to_s
    html_tag_expression = /<\/?[^>]*>/
    html_tokens = value.scan(html_tag_expression).uniq
    sanitized_value = value.gsub(html_tag_expression, "")
    
    if application == 'phrase'
      words = [sanitized_value]
    else  
      words = sanitized_value.split(/[\s\/\\]/).uniq
    end
    
    # replace html tokens with temporary placeholders {$h1}
    html_tokens.each_with_index do |html_token, index|
      value = value.gsub(html_token, "{$#{index}}")
    end

    # replace words with temporary placeholders {$w1}
    words.each_with_index do |word, index|
      value = value.gsub(word, "{$w#{index}}")
    end
    
    transformed_words = []
    words.each do |word|
      lcvm = Tr8n::LanguageCaseValueMap.by_language_and_keyword(language, word)
      
      if lcvm
        map_case_value = lcvm.value_for(object, keyword)
        case_value = map_case_value.blank? ? word : map_case_value
      else
        case_rule = evaluate_rules(object, word)
        case_value = case_rule ? case_rule.apply(word) : word 
      end

      transformed_words << decorate_language_case(word, case_value || word, case_rule, options)
    end
    
    # replace back the temporary placeholders with the html tokens  
    transformed_words.each_with_index do |word, index|
      value = value.gsub("{$w#{index}}", word)
    end
    
    # replace back the temporary placeholders with the html tokens  
    html_tokens.each_with_index do |html_token, index|
      value = value.gsub("{$h#{index}}", html_token)
    end
     
    value
  end

  def evaluate_rules(object, value)
    rules.each do |rule|
      return rule if rule.evaluate(object, value)
    end
    nil
  end

  def decorate_language_case(case_map_key, case_value, case_rule, options = {})
    return case_value if options[:skip_decorations]
    return case_value if language.default?
    return case_value if Tr8n::Config.current_user_is_guest?
    return case_value unless Tr8n::Config.current_user_is_translator?
    return case_value unless Tr8n::Config.current_translator.enable_inline_translations?
    
    "<span class='tr8n_language_case' case_id='#{id}' rule_id='#{case_rule ? case_rule.id : ''}' case_key='#{case_map_key.gsub("'", "\'")}'>#{case_value}</span>"
  end

  def self.application_options
    [["every word", "words"], ["entire phrase", "phrase"]]
  end

  def clear_cache
    Tr8n::Cache.delete(language_case_cache_key)
    Tr8n::Cache.delete(language_case_rules_cache_key) 
  end

end
