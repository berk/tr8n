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
#-- Tr8n::TranslatorMetric Schema Information
#
# Table name: tr8n_translator_metrics
#
#  id                       INTEGER     not null, primary key
#  translator_id            integer     not null
#  language_id              integer     
#  total_translations       integer     default = 0
#  total_votes              integer     default = 0
#  positive_votes           integer     default = 0
#  negative_votes           integer     default = 0
#  accepted_translations    integer     default = 0
#  rejected_translations    integer     default = 0
#  created_at               datetime    
#  updated_at               datetime    
#
# Indexes
#
#  index_tr8n_translator_metrics_on_created_at                       (created_at) 
#  index_tr8n_translator_metrics_on_translator_id_and_language_id    (translator_id, language_id) 
#  index_tr8n_translator_metrics_on_translator_id                    (translator_id) 
#
#++

class Tr8n::TranslatorMetric < ActiveRecord::Base
  self.table_name = :tr8n_translator_metrics
  
  attr_accessible :translator_id, :language_id, :total_translations, :total_votes, :positive_votes, :negative_votes, :accepted_translations, :rejected_translations
  attr_accessible :translator, :language

  belongs_to :translator, :class_name => "Tr8n::Translator"
  belongs_to :language, :class_name => "Tr8n::Language"
  
  def self.find_or_create(translator, language = nil)
    tm = where("translator_id = ?", translator.id)
    tm = where("language_id = ?", language.id) if language
    return tm.first if tm.first
    
    create(:translator => translator, :language => language, :total_translations => 0, :total_votes => 0, :positive_votes => 0, :negative_votes => 0)
  end
  
  def self.update_all_metrics_for_translator(translator)
    Tr8n::LanguageUser.where(:user_id => translator.user_id).each do |lang|
      find_or_create(translator, lang.language).update_metrics!
    end
    find_or_create(translator).update_metrics!
  end

  def self.delete_all_metrics_for_translator(translator)
    Tr8n::TranslatorMetric.connection.execute("delete from #{Tr8n::TranslatorMetric.table_name} where translator_id = #{translator.id}")
  end

  # updated when an action is done by the translator
  def update_metrics!
    if language
      self.total_translations = Tr8n::Translation.where("translator_id = ? and language_id = ?", translator.id, language.id).count
      self.total_votes = Tr8n::TranslationVote.where("tr8n_translation_votes.translator_id = ? and tr8n_translations.language_id = ?", translator.id, language.id).joins(:translation).count
      self.positive_votes = Tr8n::TranslationVote.where("tr8n_translation_votes.translator_id = ? and tr8n_translation_votes.vote > 0 and tr8n_translations.language_id = ?", translator.id, language.id).joins(:translation).count
      self.negative_votes = self.total_votes - self.positive_votes
    else
      self.total_translations = Tr8n::Translation.where("translator_id = ?", translator.id).count
      self.total_votes = Tr8n::TranslationVote.where("translator_id = ?", translator.id).count
      self.positive_votes = Tr8n::TranslationVote.where("translator_id = ? and vote > 0", translator.id).count
      self.negative_votes = self.total_votes - self.positive_votes
    end
    
    save
  end
  
  # updated when an action is done to the translator's translations
  def update_rank!
    if language
      self.accepted_translations = Tr8n::Translation.where("translator_id = ? and language_id = ? and rank >= ?", translator.id, language.id, language.threshold).count
      self.rejected_translations = Tr8n::Translation.where("translator_id = ? and language_id = ? and rank < ?", translator.id, language.id, 0).count
    else
      self.accepted_translations = Tr8n::Translation.where("translator_id = ? and rank >= ?", translator.id, Tr8n::Config.translation_threshold).count
      self.rejected_translations = Tr8n::Translation.where("translator_id = ? and rank < ?", translator.id, 0).count
    end
    
    save
  end  
  
  def rank 
    return 0 unless total_translations and accepted_translations
    total_translations == 0 ? 0 : (accepted_translations * 100.0/total_translations)
  end
  
  def pending_vote_translations
    return total_translations unless accepted_translations and rejected_translations
    total_translations - accepted_translations - rejected_translations
  end
end
