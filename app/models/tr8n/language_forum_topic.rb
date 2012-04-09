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
#-- Tr8n::LanguageForumTopic Schema Information
#
# Table name: tr8n_language_forum_topics
#
#  id               INTEGER     not null, primary key
#  translator_id    integer     not null
#  language_id      integer     
#  topic            text        not null
#  created_at       datetime    
#  updated_at       datetime    
#
# Indexes
#
#  tr8n_forum_topics_translator_id    (translator_id) 
#  tr8n_forum_topics_lang_id          (language_id) 
#
#++

class Tr8n::LanguageForumTopic < ActiveRecord::Base
  set_table_name :tr8n_language_forum_topics

  belongs_to :language, :class_name => "Tr8n::Language"    
  belongs_to :translator, :class_name => "Tr8n::Translator"    
  
  has_many :language_forum_messages, :class_name => "Tr8n::LanguageForumMessage", :dependent => :destroy
  
  alias :messages :language_forum_messages
  
  def post_count
    @post_count ||= Tr8n::LanguageForumMessage.where("language_forum_topic_id = ?", self.id).count
  end

  def last_post
    @last_post ||= Tr8n::LanguageForumMessage.where("language_forum_topic_id = ?", self.id).order("created_at desc").first
  end
end
