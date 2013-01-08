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
    self.user_count = Tr8n::LanguageUser.count(:conditions => ["language_id = ?", language_id])
    self.translator_count = Tr8n::LanguageUser.count(:conditions => ["language_id = ? and translator_id is not null", language_id])
    self.translation_count = Tr8n::Translation.count(:conditions => ["language_id = ?", language_id])
    self.key_count = Tr8n::TranslationKey.count
    
    self.locked_key_count = Tr8n::TranslationKey.count("distinct tr8n_translation_keys.id",
        :conditions => ["tr8n_translation_key_locks.language_id = ? and tr8n_translation_key_locks.locked = ?", language_id, true],
        :joins => "join tr8n_translation_key_locks on tr8n_translation_keys.id = tr8n_translation_key_locks.translation_key_id") 
    self.translated_key_count = Tr8n::TranslationKey.count("distinct tr8n_translation_keys.id", 
        :conditions => ["tr8n_translations.language_id = ?", language_id], 
        :joins => "join tr8n_translations on tr8n_translation_keys.id = tr8n_translations.translation_key_id") 
    save
      
    language.completeness = (locked_key_count * 100 / key_count)
    language.save
    
    self
  end
  
  def completeness
    language.completeness
  end
  
end
