class Tr8n::Admin::TranslationController < Tr8n::Admin::BaseController

  def index
    @model_filter = init_model_filter(Tr8n::TranslationFilter)
    @translations = Tr8n::Translation.paginate(:order=>@model_filter.order_clause, :page=>page, :per_page=>@model_filter.per_page, :conditions=>@model_filter.sql_conditions)
  end

  def view
    @translation = Tr8n::Translation.find(params[:translation_id])
  end

  def delete
    translation = Tr8n::Translation.find_by_id(params[:translation_id]) if params[:translation_id]
    translation.destroy if translation
    
    if params[:source] == "translation"
      redirect_to(:action => :index)
    else
      redirect_to_source  
    end
  end

end
