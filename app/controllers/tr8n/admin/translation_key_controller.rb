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

class Tr8n::Admin::TranslationKeyController < Tr8n::Admin::BaseController

  def index
    @model_filter = init_model_filter(Tr8n::TranslationKeyFilter)
    @keys = Tr8n::TranslationKey.paginate(:order=>@model_filter.order_clause, :page=>page, :per_page=>@model_filter.per_page, :conditions=>@model_filter.sql_conditions)
  end

  def view
    @key = Tr8n::TranslationKey.find(params[:key_id])
  end

  def delete
    key = Tr8n::TranslationKey.find_by_id(params[:key_id]) if params[:key_id]
    key.destroy if key
    
    if params[:source] == "key"
      redirect_to(:action => :index)
    else
      redirect_to_source 
    end
  end

  def key_sources
    @model_filter = init_model_filter(Tr8n::TranslationKeySourceFilter)
    @key_sources = Tr8n::TranslationKeySource.paginate(:order=>@model_filter.order_clause, :page=>page, :per_page=>@model_filter.per_page, :conditions=>@model_filter.sql_conditions)
  end

  def sources
    @model_filter = init_model_filter(Tr8n::TranslationSourceFilter)
    @sources = Tr8n::TranslationSource.paginate(:order=>@model_filter.order_clause, :page=>page, :per_page=>@model_filter.per_page, :conditions=>@model_filter.sql_conditions)
  end

  def locks
    @model_filter = init_model_filter(Tr8n::TranslationKeyLockFilter)
    @locks = Tr8n::TranslationKeyLock.paginate(:order=>@model_filter.order_clause, :page=>page, :per_page=>@model_filter.per_page, :conditions=>@model_filter.sql_conditions)
  end
   
   def lb_caller
     @key_source = Tr8n::TranslationKeySource.find(params[:key_source_id])
     @caller = @key_source.details[params[:caller_key]]
     render :layout => false
   end
   
end
