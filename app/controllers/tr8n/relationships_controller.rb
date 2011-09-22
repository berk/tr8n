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
      return trfe("Relationship key must be provided") if params[:key].blank?

      @key =  Tr8n::RelationshipKey.normalize_key(params[:key])
      @relationship_key = Tr8n::RelationshipKey.for_key(@key)

      return trfe("Translation must be provided") if params[:translation].blank?
      
      new_key = false
      unless @relationship_key
        @relationship_key = Tr8n::RelationshipKey.find_or_create(@key, params[:key], params[:description])
        Tr8n::TranslatorLog.log(Tr8n::Config.current_translator, :added_relationship_key)
        new_key = true
      end
    
      @relationship_key.add_translation(params[:translation])
      
      if new_key      
        trfn("Relationship key has been registered.")
      else
        trfn("Relationship key {key} already exist. Your translation has been added to the key.", "", :key => @relationship_key.key)
      end
    
      return redirect_to(:controller => "/tr8n/phrases", :action => :view, :translation_key_id => @relationship_key.id)
    end
  
    @relationship_key = Tr8n::RelationshipKey.new
  rescue Exception => ex
    if ex.is_a?(Tr8n::Exception)
      trfe(ex.message)
    else  
      trfe("The relationship key you provided is invalid. Please refer to the [link: help section] to see the proper syntax for relationship keys.", "", :link => ["/tr8n/help/relationship_keys"])
    end
  end
  
  def path
    @relationship_keys = Tr8n::RelationshipKey.with_valid_translations_for_locale
    @relationship_keys = @relationship_keys.sort_by(&:sort_key).reverse
  end
  
  def eval_path
    value = Path.new(params[:etps]).translate.to_s
    value = "The eTPS you provided could not be matched to any relationship keys" if value.blank?
    render :text => value
  rescue Exception => ex 
    pp ex, ex.backtrace
    render :text => "Failed to evaluate relationship path with error: #{ex.message}"
  end

end