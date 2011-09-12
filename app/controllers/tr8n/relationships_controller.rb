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

class Tr8n::RelationshipsController < Tr8n::BaseController

  def index
    conditions = Tr8n::RelationshipKey.search_conditions_for(params)
    @relationship_keys = Tr8n::RelationshipKey.paginate(:per_page => per_page, :page => page, :conditions => conditions, :order => "label asc") 
  end
  
  def new
    if request.post?
      @relationship_key = Tr8n::RelationshipKey.find_or_create(params[:key], params[:key], params[:description])
      
      if params[:translation].blank?
        return trfe("Translation must be provided")
      end
      
      trn = Tr8n::Translation.create( :translation_key => @relationship_key, 
                                      :label => params[:translation],
                                      :language => Tr8n::Config.current_language,
                                      :translator => Tr8n::Config.current_translator)
      trn.vote!(Tr8n::Config.current_translator, 1)
      
      trfn("Relatinship key has been registered")
      return redirect_to(:controller => "/tr8n/phrases", :action => :view, :translation_key_id => @relationship_key.id)
    end
  
    @relationship_key = Tr8n::RelationshipKey.new
  end
  
  def path
    
  end
  
  def eval_path
    value = Path.new(params[:etps]).translate.to_s
    value = "The eTPS you provided could not be matched to any relationship keys" if value.blank?
    render :text => value
  rescue Exception => ex 
    pp ex, ex.backtrace
    render :text => "Failed to evaluate relationship path with error: #{ex.message}"
  end
  
  def configure
    
  end

  def help
  end

end