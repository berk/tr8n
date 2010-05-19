class Tr8n::Admin::TranslatorLogController < Tr8n::Admin::BaseController

  def index
    @model_filter = init_model_filter(Tr8n::TranslatorLogFilter)
    @logs = Tr8n::TranslatorLog.paginate(:order=>@model_filter.order_clause, :page=>page, :per_page=>@model_filter.per_page, :conditions=>@model_filter.sql_conditions)
  end
  
end
