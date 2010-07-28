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

class Tr8n::ForumController < Tr8n::BaseController

  before_filter :validate_current_translator
  
  def index
    @topics = Tr8n::LanguageForumTopic.paginate(:all, :conditions => ["language_id = ?", tr8n_current_language.id], :page => page, :per_page => per_page, :order => "created_at desc")
  end

  def topic
    if request.post?
      if params[:topic_id]
        topic = Tr8n::LanguageForumTopic.find_by_id(params[:topic_id])
      else
        topic = Tr8n::LanguageForumTopic.create(:language_id => tr8n_current_language.id, :translator => tr8n_current_translator, :topic => params[:topic])
      end
      
      Tr8n::LanguageForumMessage.create(:language_forum_topic => topic, :language_id => tr8n_current_language.id, :message => params[:message], :translator => tr8n_current_translator)
      return redirect_to(:action => :topic, :topic_id => topic.id, :last_page => true)
    end
    
    unless params[:mode] == "create"
      @topic = Tr8n::LanguageForumTopic.find_by_id(params[:topic_id])
      if params[:last_page]
        params[:page] = (@topic.post_count / per_page.to_i) 
        params[:page] += 1 unless (@topic.post_count % per_page.to_i == 0) 
      end

      @messages = Tr8n::LanguageForumMessage.paginate(:all, :conditions => ["language_forum_topic_id = ?", @topic.id], :page => page, :per_page => per_page, :order => "created_at asc")
    end
  end

  def delete_topic
    topic = Tr8n::LanguageForumTopic.find_by_id(params[:topic_id])
    
    if topic.translator != tr8n_current_translator
      trfe("You cannot delete topics you didn't create.")
      return redirect_to(:action => :index)
    end
    
    topic.destroy if topic
    trfn("The topic \"#{topic.topic}\" has been removed")
    redirect_to(:action => :index)
  end

  def delete_message
    message = Tr8n::LanguageForumMessage.find_by_id(params[:message_id])
    
    unless message
      trfe("This message does not exist")
      return redirect_to(:action => :index)
    end  

    if message.translator != tr8n_current_translator
      trfe("You cannot delete messages you didn't post.")
      redirect_to(:action => :topic, :topic_id => message.language_forum_topic.id)
    end
    
    message.destroy
    trfn("The message has been removed")
    redirect_to(:action => :topic, :topic_id => message.language_forum_topic.id)
  end  

  def report_message
    message = Tr8n::LanguageForumMessage.find_by_id(params[:message_id])
    
    unless message
      trfe("This message does not exist")
      return redirect_to(:action => :index)
    end  

    message.submit_abuse_report(tr8n_current_translator)
    
    trfn("The message has been reported")
    redirect_to(:action => :topic, :topic_id => message.language_forum_topic.id)    
  end

end