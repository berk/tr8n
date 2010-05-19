class Tr8n::GlossaryController < Tr8n::BaseController

  before_filter :validate_current_translator
  
  def index
    conditions = [""]
    
    unless params[:search].blank?
      conditions[0] << "(keyword like ? or description like ?)" 
      conditions << "%#{params[:search]}%"
      conditions << "%#{params[:search]}%"  
    end
    
    @terms = Tr8n::Glossary.paginate(:order=>"keyword asc", :page=>page, :per_page=>per_page, :conditions=>conditions)
  end
    
end