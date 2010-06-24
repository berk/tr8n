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

class Tr8n::TotalLanguageMetric < Tr8n::LanguageMetric

  def update_metrics!
    attribs = default_attributes
    attribs.each do |key, value|
      attribs[key] = Tr8n::DailyLanguageMetric.sum(key, :conditions => ["language_id = ?", language_id])
    end
    update_attributes(attribs)

    language.update_attributes(:completeness => language_completeness)
  end
  
  def language_completeness
    keys_with_approved_translations_count = Tr8n::TranslationKey.count("distinct tr8n_translation_keys.id", 
        :conditions => ["tr8n_translations.language_id = ? and tr8n_translations.rank >= ?", language_id, Tr8n::Config.translation_threshold], 
        :joins => "join tr8n_translations on tr8n_translation_keys.id = tr8n_translations.translation_key_id") 
    
    return 0 if keys_with_approved_translations_count == 0
    
    (keys_with_approved_translations_count * 100 / key_count)
  end
  
  def completeness
    language.completeness
  end
  
end
