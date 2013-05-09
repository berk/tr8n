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
#-- Tr8n::TranslationVote Schema Information
#
# Table name: tr8n_translation_votes
#
#  id                INTEGER     not null, primary key
#  translation_id    integer     not null
#  translator_id     integer     not null
#  vote              integer     not null
#  created_at        datetime    not null
#  updated_at        datetime    not null
#
# Indexes
#
#  tr8n_tv_tt    (translation_id, translator_id) 
#  tr8n_tv_t     (translator_id) 
#
#++

class Tr8n::TranslationVote < ActiveRecord::Base
  self.table_name = :tr8n_translation_votes
  
  attr_accessible :translation_id, :translator_id, :vote
  attr_accessible :translation, :translator

  belongs_to :translation,  :class_name => "Tr8n::Translation"
  belongs_to :translator,   :class_name => "Tr8n::Translator"
  
  after_destroy :update_translation_rank  

  def self.find_or_create(translation, translator)
    vote = where("translation_id = ? and translator_id = ?", translation.id, translator.id).first
    vote ||= create(:translation => translation, :translator => translator, :vote => 0)
  end
  
  def update_translation_rank
    translation.update_rank!
  end
end
