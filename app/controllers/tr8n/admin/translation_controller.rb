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

class Tr8n::Admin::TranslationController < Tr8n::Admin::BaseController

  def index
    @translations = Tr8n::Translation.filter(:params => params, :filter => Tr8n::TranslationFilter)
  end

  def view
    @translation = Tr8n::Translation.find_by_id(params[:translation_id])
    return redirect_to(:action => :index) unless @translation
    @votes = Tr8n::TranslationVote.find(:all, :conditions => ["translation_id = ?", @translation.id], :order => "created_at desc", :limit => 20)
  end

  def delete
    params[:translations] = [params[:translation_id]] if params[:translation_id]
    if params[:translations]
      params[:translations].each do |translation_id|
        translation = Tr8n::Translation.find_by_id(translation_id)
        translation.destroy if translation
      end  
    end
    redirect_to_source
  end

  def votes
    @votes = Tr8n::TranslationVote.filter(:params => params, :filter => Tr8n::TranslationVoteFilter)
  end

  def delete_vote
    vote = Tr8n::TranslationVote.find(params[:vote_id])
    translation = vote.translation
    vote.destroy
    
    translation.reload
    translation.update_rank!
    redirect_to_source
  end
end
