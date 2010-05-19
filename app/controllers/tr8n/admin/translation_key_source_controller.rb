class Tr8n::Admin::TranslationKeySourceController < Tr8n::Admin::BaseController

  def index
    @model_filter = init_model_filter(Tr8n::TranslationSourceFilter)
    @sources = Tr8n::TranslationSource.paginate(:order=>@model_filter.order_clause, :page=>page, :per_page=>@model_filter.per_page, :conditions=>@model_filter.sql_conditions)
  end
  
end
