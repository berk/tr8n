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

class Tr8n::Admin::ForumController < Tr8n::Admin::BaseController

  def index
    @topics = Tr8n::LanguageForumTopic.filter(:params => params, :filter => Tr8n::LanguageForumTopicFilter)
  end

  def messages
    @messages = Tr8n::LanguageForumMessage.filter(:params => params, :filter => Tr8n::LanguageForumMessageFilter)
  end

  def reports
    @reports = Tr8n::LanguageForumAbuseReport.filter(:params => params, :filter => Tr8n::LanguageForumAbuseReportFilter)
  end

  def delete_topic
    topic = Tr8n::LanguageForumTopic.find_by_id(params[:topic_id]) if params[:topic_id]
    topic.destroy if topic

    redirect_to_source
  end  

  def delete_message
    message = Tr8n::LanguageForumMessage.find_by_id(params[:msg_id]) if params[:msg_id]
    message.destroy if message

    redirect_to_source
  end  
    
end
