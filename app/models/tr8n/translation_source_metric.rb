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
#-- Tr8n::TranslationSourceMetric Schema Information
#
# Table name: tr8n_translation_source_metrics
#
#  id                       INTEGER     not null, primary key
#  translation_source_id    integer     not null
#  language_id              integer     not null
#  key_count                integer     default = 0
#  locked_key_count         integer     default = 0
#  translation_count        integer     default = 0
#  translated_key_count     integer     default = 0
#  created_at               datetime    not null
#  updated_at               datetime    not null
#
# Indexes
#
#  tr8n_trans_source_metrs_tsili    (translation_source_id, language_id) 
#
#++

class Tr8n::TranslationSourceMetric < ActiveRecord::Base
  self.table_name = :tr8n_translation_source_metrics
  
  attr_accessible :translation_source, :language, :language_id, :key_count, :locked_key_count, :translation_count, :translated_key_count

  belongs_to  :translation_source,            :class_name => "Tr8n::TranslationSource"
  belongs_to  :language,                      :class_name => "Tr8n::Language"
  
  after_destroy   :clear_cache
  after_save      :clear_cache
  after_create    :update_metrics!

  def self.cache_key(application, source, locale)
    if application
      "source_metric_[#{application.id}]_[#{source.to_s}]_[#{locale}]"
    else
      "source_metric_[deleted]_[#{source.to_s}]_[#{locale}]"
    end
  end

  def cache_key
    self.class.cache_key(translation_source.application, translation_source.source, language.locale)
  end

  def clear_cache
    Tr8n::Cache.delete(cache_key)
  end

  def self.find_or_create(translation_source, language = Tr8n::Config.current_language)
    Tr8n::Cache.fetch(cache_key(translation_source.application, translation_source.source, language.locale)) do 
      translation_source_metric = where("translation_source_id = ? and language_id = ?", translation_source.id, language.id).first
      translation_source_metric || create(:translation_source => translation_source, :language_id => language.id)
    end
  end

  def update_metrics!(opts = {})
    return Tr8n::OfflineTask.schedule(self, :update_metrics!, {:offline => true}) unless opts[:offline]

    self.key_count = Tr8n::TranslationKey.count("distinct tr8n_translation_keys.id",
        :conditions => ["tks.translation_source_id = ?", translation_source_id],
        :joins => [
          "join tr8n_translation_key_sources as tks on tr8n_translation_keys.id = tks.translation_key_id"
        ]
    ) 

    self.translation_count = Tr8n::Translation.count("distinct tr8n_translations.id", 
        # :conditions => ["tr8n_translations.language_id = ? and tr8n_translations.translation_key_id in (select tr8n_translation_key_sources.translation_key_id from tr8n_translation_key_sources where tr8n_translation_key_sources.translation_source_id = ?)", language_id, translation_source_id],
        :conditions => ["tr8n_translations.language_id = ? and tr8n_translation_key_sources.translation_source_id = ?", language_id, translation_source_id],
        :joins => "join tr8n_translation_key_sources on tr8n_translation_key_sources.translation_key_id = tr8n_translations.translation_key_id"
    )
    
    self.locked_key_count = Tr8n::TranslationKey.count("distinct tr8n_translation_keys.id",
        :conditions => ["tkl.language_id = ? and tks.translation_source_id = ? and tkl.locked = ?", language_id, translation_source_id, true],
        :joins => [
          "join tr8n_translation_key_locks as tkl on tr8n_translation_keys.id = tkl.translation_key_id",
          "join tr8n_translation_key_sources as tks on tr8n_translation_keys.id = tks.translation_key_id"
        ]
    ) 

    self.translated_key_count = Tr8n::TranslationKey.count("distinct tr8n_translation_keys.id", 
        :conditions => ["t.language_id = ? and tks.translation_source_id = ?", language_id, translation_source_id], 
        :joins => [
          "join tr8n_translations as t on tr8n_translation_keys.id = t.translation_key_id",
          "join tr8n_translation_key_sources as tks on tr8n_translation_keys.id = tks.translation_key_id"
        ]
    ) 

    save

    # this needs to be done as an average of all languages for the source
    unless key_count == 0
      translation_source.completeness = 0
      translation_source.save
    end    

    self
  end
  
  def not_translated_count
    return key_count unless translated_key_count
    key_count - translated_key_count    
  end
  
  def pending_approval_count
    return translated_key_count unless locked_key_count
    translated_key_count - locked_key_count
  end

  def completeness
    return 0 if key_count.nil? or key_count == 0
    (locked_key_count * 100)/key_count
  end

  def translation_completeness
    return 0 if key_count.nil? or key_count == 0
    (translated_key_count * 100)/key_count
  end

end
