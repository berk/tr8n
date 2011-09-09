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

class Tr8n::ConfigurationKey < Tr8n::TranslationKey

  def self.find_or_create(key, label = nil, description = nil, options = {})
    Tr8n::Cache.fetch("configuration_key_#{key}") do
        find_by_key(key) || create(:key => key, :label => label, :description => description, :level => 0, :admin => false)
    end
  end
  
  def self.for_key(key)
    Tr8n::Cache.fetch("configuration_key_#{key}") do
        find_by_key(key.to_s)
    end
  end

  def after_save
    Tr8n::Cache.delete("configuration_key_#{key}")
  end

  def after_destroy
    Tr8n::Cache.delete("configuration_key_#{key}")
  end

  def translate(language = Tr8n::Config.current_language, token_values = {}, options = {})
    return find_all_valid_translations(valid_translations_for(language)) if options[:api]
    
    translation_language, translation = find_first_valid_translation_for_language(language, token_values)
    
    if translation
      translated_label = substitute_tokens(translation.label, token_values, options, language)
      return decorate_translation(language, translated_label, translation != nil, options.merge(:fallback => (translation_language != language)))
    end

    # no translation found  
    translated_label = substitute_tokens(label, token_values, options, Tr8n::Config.default_language)
    decorate_translation(language, translated_label, translation != nil, options)  
  end
  
  ###############################################################
  ## Feature Related Stuff
  ###############################################################

  def self.title
    "Configuration Key".translate
  end

  def self.help_url
    '/relationships/help'
  end

  def suggestions?
    false
  end

  def rules?
    true
  end

  def dictionary?
    false
  end

  def sources?
    false
  end

end
