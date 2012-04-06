#--
# Copyright (c) 2010-2012 Michael Berkovich, tr8n.net
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
#-- Tr8n::TotalLanguageMetric Schema Information
#
# Table name: tr8n_language_metrics
#
#  id                      INTEGER         not null, primary key
#  type                    varchar(255)    
#  language_id             integer         not null
#  metric_date             date            
#  user_count              integer         default = 0
#  translator_count        integer         default = 0
#  translation_count       integer         default = 0
#  key_count               integer         default = 0
#  locked_key_count        integer         default = 0
#  translated_key_count    integer         default = 0
#  created_at              datetime        
#  updated_at              datetime        
#
# Indexes
#
#  index_tr8n_language_metrics_on_created_at     (created_at) 
#  index_tr8n_language_metrics_on_language_id    (language_id) 
#
#++

class Tr8n::TotalLanguageMetric < Tr8n::LanguageMetric

  def update_metrics!
    self.user_count = Tr8n::LanguageUser.where("language_id = ?", language_id).count
    self.translator_count = Tr8n::LanguageUser.where("language_id = ? and translator_id is not null", language_id).count
    self.translation_count = Tr8n::Translation.where("language_id = ?", language_id).count
    self.key_count = Tr8n::TranslationKey.count
    
    # TODO: switch to the Rails 3.1 way
    self.locked_key_count = Tr8n::TranslationKey.count("distinct tr8n_translation_keys.id",
        :conditions => ["tr8n_translation_key_locks.language_id = ? and tr8n_translation_key_locks.locked = ?", language_id, true],
        :joins => "join tr8n_translation_key_locks on tr8n_translation_keys.id = tr8n_translation_key_locks.translation_key_id") 
    self.translated_key_count = Tr8n::TranslationKey.count("distinct tr8n_translation_keys.id", 
        :conditions => ["tr8n_translations.language_id = ?", language_id], 
        :joins => "join tr8n_translations on tr8n_translation_keys.id = tr8n_translations.translation_key_id") 
    save

    language.update_attributes(:completeness => calculate_language_completeness)
    
    self
  end
  
  def calculate_language_completeness
    keys_with_approved_translations_count = Tr8n::TranslationKey.count("distinct tr8n_translation_keys.id", 
        :conditions => ["tr8n_translations.language_id = ? and tr8n_translations.rank >= ?", language_id, Tr8n::Config.translation_threshold], 
        :joins => "join tr8n_translations on tr8n_translation_keys.id = tr8n_translations.translation_key_id") 
    
    return 0 if keys_with_approved_translations_count == 0 or key_count == 0
    
    (keys_with_approved_translations_count * 100 / key_count)
  end
  
  def completeness
    language.completeness
  end
  
end
