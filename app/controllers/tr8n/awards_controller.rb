class Tr8n::AwardsController < Tr8n::BaseController

  before_filter :validate_current_translator
  
  def index
    params[:mode] = "all" if tr8n_current_language.default?
    
    if params[:mode] == "all"
      @translator_metrics = Tr8n::TranslatorMetric.find(:all, :conditions => ["language_id is null"], 
                  :order => "total_translations desc, total_votes desc", :limit => 23)
    else
      @translator_metrics = Tr8n::TranslatorMetric.find(:all, :conditions => ["language_id = ?", tr8n_current_language.id], 
                  :order => "total_translations desc, total_votes desc", :limit => 23)
    end
    
    @leaders = @translator_metrics[0..2]
    @runners = (@translator_metrics.size > 3) ? @translator_metrics[3..-1] : []
  end
    
end