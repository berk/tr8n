class Tr8n::Admin::LanguageController < Tr8n::Admin::BaseController
  
  def index
    @model_filter = init_model_filter(Tr8n::LanguageFilter)  
    @languages = Tr8n::Language.paginate(:order=>@model_filter.order_clause, :page=>page, :per_page=>@model_filter.per_page, :conditions=>@model_filter.sql_conditions)
  end

  def view
    @lang = Tr8n::Language.find(params[:lang_id])
  end

  def enable
    @language = Tr8n::Language.find(params[:lang_id])
    @language.enable!
    trfn("#{@language.english_name} language has been enabled")
    redirect_to_source
  end
  
  def disable
    @language = Tr8n::Language.find(params[:lang_id])
    @language.disable!
    trfn("#{@language.english_name} language has been disabled")
    redirect_to_source
  end
    
  def charts
    
  end

  def metrics
    @model_filter = init_model_filter(Tr8n::LanguageMetricFilter)  
    @metrics = Tr8n::LanguageMetric.paginate(:order=>@model_filter.order_clause, :page=>page, :per_page=>@model_filter.per_page, :conditions=>@model_filter.sql_conditions)
  end

  def users
    @model_filter = init_model_filter(Tr8n::LanguageUserFilter)  
    @users = Tr8n::LanguageUser.paginate(:order=>@model_filter.order_clause, :page=>page, :per_page=>@model_filter.per_page, :conditions=>@model_filter.sql_conditions)
  end

  def calculate_metrics
    Tr8n::LanguageMetric.calculate_language_metrics
    
    trfn("Languages metrics have been recalculated")
    redirect_to_source
  end
  
  def rules
    @model_filter = init_model_filter(Tr8n::LanguageRuleFilter)  
    @rules = Tr8n::LanguageRule.paginate(:order=>@model_filter.order_clause, :page=>page, :per_page=>@model_filter.per_page, :conditions=>@model_filter.sql_conditions)
  end
  
  def lb_update
    @language = Tr8n::Language.find_by_id(params[:lang_id]) unless params[:lang_id].blank?
    @language = Tr8n::Language.new unless @language
    
    render :layout => false
  end

  def update
    language = Tr8n::Language.find_by_id(params[:language][:id]) unless params[:language][:id].blank?
    
    if language
      trfn("The language has been updated")
      language.update_attributes(params[:language])
    else
      trfn("The new language has been addeded")
      language = Tr8n::Language.create(params[:language])
    end
    
    redirect_to_source
  end
  
end
