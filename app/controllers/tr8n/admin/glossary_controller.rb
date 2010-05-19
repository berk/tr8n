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
