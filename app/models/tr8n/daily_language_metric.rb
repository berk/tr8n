#--
# Copyright (c) 2010-2011 Michael Berkovich, tr8n.net
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

class Tr8n::DailyLanguageMetric < Tr8n::LanguageMetric

  def update_metrics!
    self.user_count = Tr8n::LanguageUser.count(:conditions => ["language_id = ? and created_at >= ? and created_at < ?", language_id, metric_date, metric_date + 1.day])
    self.translator_count = Tr8n::LanguageUser.count(:conditions => ["language_id = ? and created_at >= ? and created_at < ? and translator_id is not null", language_id, metric_date, metric_date + 1.day])
    self.translation_count = Tr8n::Translation.count(:conditions => ["language_id = ? and created_at >= ? and created_at < ?", language_id, metric_date, metric_date + 1.day])

    self.key_count = Tr8n::TranslationKey.count(:conditions => ["created_at >= ? and created_at < ?", metric_date, metric_date + 1.day])
    self.locked_key_count = Tr8n::TranslationKey.count("distinct tr8n_translation_keys.id",
        :conditions => ["tr8n_translation_key_locks.language_id = ? and tr8n_translation_key_locks.locked = ? and tr8n_translation_key_locks.created_at >= ? and tr8n_translation_key_locks.created_at < ?", language_id, true, metric_date, metric_date + 1.day],
        :joins => "join tr8n_translation_key_locks on tr8n_translation_keys.id = tr8n_translation_key_locks.translation_key_id") 
    self.translated_key_count = Tr8n::TranslationKey.count("distinct tr8n_translation_keys.id", 
        :conditions => ["tr8n_translations.language_id = ? and tr8n_translations.created_at >= ? and tr8n_translations.created_at < ?", language_id, metric_date, metric_date + 1.day], 
        :joins => "join tr8n_translations on tr8n_translation_keys.id = tr8n_translations.translation_key_id") 
    
    save
  end
  
end
