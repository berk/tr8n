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
 
end
