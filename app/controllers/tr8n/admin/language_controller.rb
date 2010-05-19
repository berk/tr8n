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

  def calculate_completeness
    keys = Tr8n::TranslationKey.all 
    
    Tr8n::Language.all.each do |lang|
      lang.calculate_completeness!(keys)
    end
    
    trfn("Languages metrics have been recalculated")
    redirect_to_source
  end
    
  def metrics
    
  end
    
end
