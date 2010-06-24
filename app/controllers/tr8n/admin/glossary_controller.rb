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

class Tr8n::Admin::GlossaryController < Tr8n::Admin::BaseController

  def index
    @model_filter = init_model_filter("Tr8n::Glossary")
    @terms = Tr8n::Glossary.paginate(:order=>@model_filter.order_clause, :page=>page, :per_page=>@model_filter.per_page, :conditions=>@model_filter.sql_conditions)
  end
  
  def lb_update
    @glossary = Tr8n::Glossary.find_by_id(params[:glossary_id]) if params[:glossary_id]
    @glossary = Tr8n::Glossary.new unless @glossary
    
    render :layout => false
  end

  def update
    glossary = Tr8n::Glossary.find_by_id(params[:glossary][:id]) unless params[:glossary][:id].blank?
    
    if glossary
      glossary.update_attributes(params[:glossary])
    else
      glossary = Tr8n::Glossary.create(params[:glossary])
    end
    
    redirect_to_source
  end
  
  def delete
    glossary = Tr8n::Glossary.find_by_id(params[:glossary_id]) if params[:glossary_id]
    glossary.destroy if glossary

    redirect_to_source
  end  
    
end
