class Tr8n::Glossary < ActiveRecord::Base
  set_table_name :tr8n_glossary
  establish_connection(Tr8n::Config.database) if Tr8n::Config.use_remote_database?
  
  def self.populate_defaults
    delete_all
    Tr8n::Config.default_glossary.each do |vals|
      create(:keyword => vals[0], :description => vals[1])
    end
  end
  
end
