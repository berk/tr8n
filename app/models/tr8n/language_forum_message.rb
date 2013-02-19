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

class Tr8n::LanguageForumMessage < ActiveRecord::Base
  set_table_name :tr8n_language_forum_messages
  
  belongs_to :language,               :class_name => "Tr8n::Language"  
  belongs_to :translator,             :class_name => "Tr8n::Translator"  
  belongs_to :language_forum_topic,   :class_name => "Tr8n::LanguageForumTopic"
  
  has_many :language_forum_abuse_reports, :class_name => "Tr8n::LanguageForumAbuseReport", :dependent => :destroy

  alias :topic :language_forum_topic

  def submit_abuse_report(reporter)
    report = Tr8n::LanguageForumAbuseReport.find(:first, :conditions => ["language_forum_message_id = ? and translator_id = ?", self.id, reporter.id])
    report ||= Tr8n::LanguageForumAbuseReport.create(:language_forum_message => self, :translator => reporter, :language => language)
    translator.update_attributes(:reported => true)
    report
  end
  
  def toHTML
    return "" unless message
    ERB::Util.html_escape(message).gsub("\n", "<br>")
  end

  def after_create
    Tr8n::Notification.distribute(self)    
  end
  
end
