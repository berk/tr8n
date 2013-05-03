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
#  created_at              datetime        not null
#  updated_at              datetime        not null
#
# Indexes
#
#  tr8n_lm_c    (created_at) 
#  tr8n_lm_l    (language_id) 
#
#++

class Tr8n::TotalLanguageMetric < Tr8n::LanguageMetric

  after_create :generate_metrics   

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

    language.completeness = (locked_key_count * 100 / key_count)
    language.save
    
    self
  end
  
  def completeness
    language.completeness
  end
  
  def translation_completeness
    return 0 if key_count.nil? or key_count == 0
    (translated_key_count * 100)/key_count
  end
  
  ###############################################################
  ## Offline Tasks
  ###############################################################
  def generate_metrics
    Tr8n::OfflineTask.schedule(self.class.name, :update_metrics_offline, {
                               :language_metric_id => self.id
    })
  end

  def self.update_metrics_offline(opts)
    Tr8n::LanguageMetric.find_by_id(opts[:language_metric_id]).update_metrics!
  end

end
